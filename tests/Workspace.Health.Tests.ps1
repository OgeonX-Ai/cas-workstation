Set-StrictMode -Version Latest

Describe 'workspace-health.ps1 sweep' {

    BeforeAll {
        $script:ScriptUnderTest = (Resolve-Path (Join-Path $PSScriptRoot '..\scripts\workspace-health.ps1')).Path
        $script:ModuleUnderTest = (Resolve-Path (Join-Path $PSScriptRoot '..\scripts\Cas.Workstation.psm1')).Path
        $env:WH_SKIP_GH = '1'

        function New-WhFixture {
            param([string]$Suffix = 'base')
            $dir = Join-Path $env:TEMP ("wh-test-{0}-{1}" -f $Suffix, [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            git -C $dir init -q 2>$null
            git -C $dir config user.email 'wh-test@example.com' 2>$null
            git -C $dir config user.name 'WH Test' 2>$null
            Set-Content -LiteralPath (Join-Path $dir 'README.md') -Value 'fixture' -Encoding ASCII
            git -C $dir add README.md 2>$null
            git -C $dir commit -q -m 'init' 2>$null
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
            $script:Bare3 = Join-Path $env:TEMP ('wh-test-bare-' + [guid]::NewGuid().ToString('N'))
            git init -q --bare $script:Bare3 2>$null
            $branch3 = (git -C $script:Fixture3 branch --show-current 2>$null)
            git -C $script:Fixture3 remote add origin $script:Bare3 2>$null
            git -C $script:Fixture3 push -q -u origin "HEAD:refs/heads/$branch3" 2>$null
            Set-Content -LiteralPath (Join-Path $script:Fixture3 'more.txt') -Value 'more' -Encoding ASCII
            git -C $script:Fixture3 add more.txt 2>$null
            git -C $script:Fixture3 commit -q -m 'second commit' 2>$null
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
            $script:Fixture4 = Join-Path $env:TEMP ('wh-test-manifest-' + [guid]::NewGuid().ToString('N'))
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
    }

    Context 'Non-ASCII .ps1 guard' {
        BeforeAll {
            $script:Fixture5 = New-WhFixture -Suffix 'nonascii'
            $dash = [char]0x2014
            $content = "# comment with an em-dash $dash character" + [Environment]::NewLine + "Write-Host 'hi'" + [Environment]::NewLine
            [System.IO.File]::WriteAllText((Join-Path $script:Fixture5 'bad.ps1'), $content, [System.Text.Encoding]::UTF8)
        }
        AfterAll {
            Remove-WhFixture -Path $script:Fixture5
        }
        It 'reports a non-ascii-ps1 finding for the offending file' {
            $findings = Invoke-Wh -Root $script:Fixture5
            $checks = @($findings | ForEach-Object { $_.Check })
            $checks | Should -Contain 'non-ascii-ps1'
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
}
