Set-StrictMode -Version Latest

Describe 'workspace-health.ps1 sweep' {

    BeforeAll {
        $script:ScriptUnderTest = (Resolve-Path (Join-Path $PSScriptRoot '..\scripts\workspace-health.ps1')).Path
        $script:ModuleUnderTest = (Resolve-Path (Join-Path $PSScriptRoot '..\scripts\Cas.Workstation.psm1')).Path
        $env:WH_SKIP_GH = '1'
        $script:FixtureRoot = 'C:\temp\workspace-health-tests'
        New-Item -ItemType Directory -Path $script:FixtureRoot -Force | Out-Null
        $script:GitExe = @(
            (Get-Command git.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
            'C:\Program Files\Git\cmd\git.exe',
            'C:\Program Files\Git\bin\git.exe',
            'C:\Program Files (x86)\Git\cmd\git.exe',
            'C:\Program Files (x86)\Git\bin\git.exe'
        ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
        if (-not $script:GitExe) {
            throw 'Git for Windows was not found for Workspace.Health.Tests.ps1.'
        }

        function New-WhFixture {
            param([string]$Suffix = 'base')
            $dir = Join-Path $script:FixtureRoot ("wh-test-{0}-{1}" -f $Suffix, [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            & $script:GitExe -C $dir init -q 2>$null
            & $script:GitExe -C $dir config user.email 'wh-test@example.com' 2>$null
            & $script:GitExe -C $dir config user.name 'WH Test' 2>$null
            Set-Content -LiteralPath (Join-Path $dir 'README.md') -Value 'fixture' -Encoding ASCII
            & $script:GitExe -C $dir add README.md 2>$null
            & $script:GitExe -C $dir commit -q -m 'init' 2>$null
            return $dir
        }

        function Invoke-Wh {
            param([string]$Root)
            $raw = & powershell.exe -NoProfile -File $script:ScriptUnderTest -Root $Root -Json 2>$null
            $joined = ($raw -join "`n").Trim()
            if ([string]::IsNullOrWhiteSpace($joined)) { return @() }
            $parsed = $joined | ConvertFrom-Json
            return @($parsed)
        }

        function Remove-WhFixture {
            param([string]$Path)
            if ($Path -and (Test-Path -LiteralPath $Path)) {
                Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    AfterAll {
        Remove-Item Env:\WH_SKIP_GH -ErrorAction SilentlyContinue
    }

    Context 'Clean baseline fixture' {
        BeforeAll {
            $script:Fixture1 = New-WhFixture -Suffix 'clean'
        }
        AfterAll {
            Remove-WhFixture -Path $script:Fixture1
        }
        It 'reports only the no-upstream finding on a minimal clean repo' {
            $findings = Invoke-Wh -Root $script:Fixture1
            $checks = @($findings | ForEach-Object { $_.Check })
            $checks | Should -Contain 'no-upstream'
            $checks | Should -Not -Contain 'dirty'
            $checks | Should -Not -Contain 'off-default-branch'
            $checks | Should -Not -Contain 'unpushed'
            $checks | Should -Not -Contain 'credential-helper-wsl-path'
            $checks | Should -Not -Contain 'non-ascii-ps1'
        }
    }

    Context 'Orphaned untracked file' {
        BeforeAll {
            $script:Fixture2 = New-WhFixture -Suffix 'dirty'
            Set-Content -LiteralPath (Join-Path $script:Fixture2 'orphan.txt') -Value 'untracked' -Encoding ASCII
        }
        AfterAll {
            Remove-WhFixture -Path $script:Fixture2
        }
        It 'reports a dirty finding referencing the fixture repo' {
            $findings = Invoke-Wh -Root $script:Fixture2
            $dirtyFindings = @($findings | Where-Object { $_.Check -eq 'dirty' -and $_.Repo -eq 'root' })
            $dirtyFindings.Count | Should -Be 1
        }
    }

    Context 'Unpushed commit against a local origin' {
        BeforeAll {
            $script:Fixture3 = New-WhFixture -Suffix 'unpushed'
            $script:Bare3 = Join-Path $script:FixtureRoot ('wh-test-bare-' + [guid]::NewGuid().ToString('N'))
            & $script:GitExe init -q --bare $script:Bare3 2>$null
            $branch3 = (& $script:GitExe -C $script:Fixture3 branch --show-current 2>$null)
            & $script:GitExe -C $script:Fixture3 remote add origin $script:Bare3 2>$null
            & $script:GitExe -C $script:Fixture3 push -q -u origin "HEAD:refs/heads/$branch3" 2>$null
            Set-Content -LiteralPath (Join-Path $script:Fixture3 'more.txt') -Value 'more' -Encoding ASCII
            & $script:GitExe -C $script:Fixture3 add more.txt 2>$null
            & $script:GitExe -C $script:Fixture3 commit -q -m 'second commit' 2>$null
        }
        AfterAll {
            Remove-WhFixture -Path $script:Fixture3
            Remove-WhFixture -Path $script:Bare3
        }
        It 'reports an unpushed finding with count 1' {
            $findings = Invoke-Wh -Root $script:Fixture3
            $unpushed = @($findings | Where-Object { $_.Check -eq 'unpushed' })
            $unpushed.Count | Should -Be 1
            $unpushed[0].Detail | Should -Match '^1 commit\(s\) ahead of'
        }
    }

    Context 'Lying stack.manifest.json version' {
        BeforeAll {
            $script:Fixture4 = Join-Path $script:FixtureRoot ('wh-test-manifest-' + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path (Join-Path $script:Fixture4 'scripts') -Force | Out-Null
            Copy-Item -LiteralPath $script:ModuleUnderTest -Destination (Join-Path $script:Fixture4 'scripts\Cas.Workstation.psm1') -Force
            $manifest = [ordered]@{
                manifestVersion = '1.0.0'
                bundleName      = 'wh-test'
                bundleId        = 'wh-test'
                tools           = @(
                    [ordered]@{
                        id             = 'git'
                        displayName    = 'Git'
                        command        = 'git'
                        versionArgs    = @('--version')
                        versionPattern = '(?<version>\d+\.\d+\.\d+)'
                        minimumVersion = '999.0.0'
                    }
                )
            }
            $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $script:Fixture4 'stack.manifest.json') -Encoding ASCII
        }
        AfterAll {
            Remove-WhFixture -Path $script:Fixture4
        }
        It 'reports a stack-manifest-version finding for the absurdly high minimum version' {
            $findings = Invoke-Wh -Root $script:Fixture4
            $checks = @($findings | ForEach-Object { $_.Check })
            $checks | Should -Contain 'stack-manifest-version'
            $manifestFindings = @($findings | Where-Object { $_.Check -eq 'stack-manifest-version' })
            $manifestFindings[0].Detail | Should -Match "'Git'"
        }

        It 'suppresses stack-manifest-version findings when explicitly skipped' {
            $raw = & powershell.exe -NoProfile -File $script:ScriptUnderTest -Root $script:Fixture4 -Json -SkipStackManifestChecks 2>$null
            $joined = ($raw -join "`n").Trim()
            $findings = if ([string]::IsNullOrWhiteSpace($joined)) { @() } else { @($joined | ConvertFrom-Json) }
            @($findings | ForEach-Object { $_.Check }) | Should -Not -Contain 'stack-manifest-version'
        }
    }

    Context 'Non-ASCII .ps1 guard' {
        BeforeAll {
            $script:Fixture5 = New-WhFixture -Suffix 'nonascii'
            $dash = [char]0x2014
            $content = "# comment with an em-dash $dash character" + [Environment]::NewLine + "Write-Host 'hi'" + [Environment]::NewLine
            [System.IO.File]::WriteAllText((Join-Path $script:Fixture5 'bad.ps1'), $content, (New-Object System.Text.UTF8Encoding($false)))
            & $script:GitExe -C $script:Fixture5 add bad.ps1 2>$null
        }
        AfterAll {
            Remove-WhFixture -Path $script:Fixture5
        }
        It 'reports a non-ascii-ps1 finding for the offending file' {
            $findings = Invoke-Wh -Root $script:Fixture5
            $checks = @($findings | ForEach-Object { $_.Check })
            $checks | Should -Contain 'non-ascii-ps1'
        }

        It 'allows non-ASCII in a UTF-8 BOM script' {
            $bomFile = Join-Path $script:Fixture5 'bom-safe.ps1'
            $dash = [char]0x2014
            [System.IO.File]::WriteAllText($bomFile, "# BOM-safe $dash comment", (New-Object System.Text.UTF8Encoding($true)))
            & $script:GitExe -C $script:Fixture5 add bom-safe.ps1 2>$null

            $findings = Invoke-Wh -Root $script:Fixture5
            $offenders = @($findings | Where-Object { $_.Check -eq 'non-ascii-ps1' })
            $offenders.Count | Should -Be 1
            $offenders[0].Detail | Should -Match 'bad\.ps1'
        }
    }

    Context 'Credential helper WSL path' {
        BeforeAll {
            $script:Fixture6 = New-WhFixture -Suffix 'credhelper'
            $configPath = Join-Path $script:Fixture6 '.git\config'
            Add-Content -LiteralPath $configPath -Value '[credential]'
            Add-Content -LiteralPath $configPath -Value '	helper = !"/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential'
        }
        AfterAll {
            Remove-WhFixture -Path $script:Fixture6
        }
        It 'reports a credential-helper-wsl-path finding' {
            $findings = Invoke-Wh -Root $script:Fixture6
            $checks = @($findings | ForEach-Object { $_.Check })
            $checks | Should -Contain 'credential-helper-wsl-path'
        }
    }

    Context 'Release staleness' {

        Context 'Old tag with commits since it (RED fixture)' {
            BeforeAll {
                $script:Fixture7 = New-WhFixture -Suffix 'releasestale'
                $pastDate = (Get-Date).ToUniversalTime().AddDays(-45).ToString('yyyy-MM-ddTHH:mm:ssK')
                $env:GIT_COMMITTER_DATE = $pastDate
                $env:GIT_AUTHOR_DATE = $pastDate
                Set-Content -LiteralPath (Join-Path $script:Fixture7 'v1.txt') -Value 'v1' -Encoding ASCII
                & $script:GitExe -C $script:Fixture7 add v1.txt 2>$null
                & $script:GitExe -C $script:Fixture7 commit -q -m 'tagged commit' 2>$null
                & $script:GitExe -C $script:Fixture7 tag v0.1.0 2>$null
                Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
                Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
                Set-Content -LiteralPath (Join-Path $script:Fixture7 'v2.txt') -Value 'v2' -Encoding ASCII
                & $script:GitExe -C $script:Fixture7 add v2.txt 2>$null
                & $script:GitExe -C $script:Fixture7 commit -q -m 'untagged commit' 2>$null
            }
            AfterAll {
                Remove-WhFixture -Path $script:Fixture7
            }
            It 'reports a release-stale finding naming the tag, age, and commits since' {
                $findings = Invoke-Wh -Root $script:Fixture7
                $stale = @($findings | Where-Object { $_.Check -eq 'release-stale' })
                $stale.Count | Should -Be 1
                $stale[0].Detail | Should -Match 'v0\.1\.0'
                $stale[0].Detail | Should -Match '(\d+)d old \(threshold 30d\)'
                $matched = $stale[0].Detail -match '(\d+)d old \(threshold 30d\)'
                $matched | Should -BeTrue
                [int]$Matches[1] | Should -BeGreaterThan 30
            }
        }

        Context 'Tag on HEAD, zero commits since it (no false positive)' {
            BeforeAll {
                $script:Fixture8 = New-WhFixture -Suffix 'releasefresh'
                $pastDate = (Get-Date).ToUniversalTime().AddDays(-90).ToString('yyyy-MM-ddTHH:mm:ssK')
                $env:GIT_COMMITTER_DATE = $pastDate
                $env:GIT_AUTHOR_DATE = $pastDate
                Set-Content -LiteralPath (Join-Path $script:Fixture8 'v1.txt') -Value 'v1' -Encoding ASCII
                & $script:GitExe -C $script:Fixture8 add v1.txt 2>$null
                & $script:GitExe -C $script:Fixture8 commit -q -m 'tagged commit' 2>$null
                & $script:GitExe -C $script:Fixture8 tag v0.2.0 2>$null
                Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
                Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
            }
            AfterAll {
                Remove-WhFixture -Path $script:Fixture8
            }
            It 'reports no release-stale finding when HEAD is the tagged commit, regardless of tag age' {
                $findings = Invoke-Wh -Root $script:Fixture8
                $checks = @($findings | ForEach-Object { $_.Check })
                $checks | Should -Not -Contain 'release-stale'
            }
        }

        Context 'Recent tag with commits since it (no false positive)' {
            BeforeAll {
                $script:Fixture9 = New-WhFixture -Suffix 'releaserecent'
                & $script:GitExe -C $script:Fixture9 tag v0.3.0 2>$null
                Set-Content -LiteralPath (Join-Path $script:Fixture9 'v2.txt') -Value 'v2' -Encoding ASCII
                & $script:GitExe -C $script:Fixture9 add v2.txt 2>$null
                & $script:GitExe -C $script:Fixture9 commit -q -m 'untagged commit' 2>$null
            }
            AfterAll {
                Remove-WhFixture -Path $script:Fixture9
            }
            It 'reports no release-stale finding when the tag is less than 30 days old' {
                $findings = Invoke-Wh -Root $script:Fixture9
                $checks = @($findings | ForEach-Object { $_.Check })
                $checks | Should -Not -Contain 'release-stale'
            }
        }

        Context 'No SemVer tag at all (never released)' {
            BeforeAll {
                $script:Fixture10 = New-WhFixture -Suffix 'releasenotag'
            }
            AfterAll {
                Remove-WhFixture -Path $script:Fixture10
            }
            It 'reports a release-stale finding when no SemVer tag exists' {
                $findings = Invoke-Wh -Root $script:Fixture10
                $stale = @($findings | Where-Object { $_.Check -eq 'release-stale' -and $_.Repo -eq 'root' })
                $stale.Count | Should -Be 1
                $stale[0].Detail | Should -Match 'no SemVer release tag'
            }
        }
    }
}
