Set-StrictMode -Version Latest

Describe 'squash-aware-branch-gate.ps1' {

    BeforeAll {
        $script:ScriptUnderTest = (Resolve-Path (Join-Path $PSScriptRoot '..\squash-aware-branch-gate.ps1')).Path
        $script:FixtureRoot = Join-Path ([System.IO.Path]::GetTempPath()) 'squash-gate-tests'
        New-Item -ItemType Directory -Path $script:FixtureRoot -Force | Out-Null
        $script:GitExe = @(
            (Get-Command git.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
            'C:\Program Files\Git\cmd\git.exe',
            'C:\Program Files\Git\bin\git.exe',
            'C:\Program Files (x86)\Git\cmd\git.exe',
            'C:\Program Files (x86)\Git\bin\git.exe'
        ) | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
        if (-not $script:GitExe) {
            throw 'Git for Windows was not found for squash-aware-branch-gate.Tests.ps1.'
        }

        function New-GateOrigin {
            param([string]$Suffix)
            $dir = Join-Path $script:FixtureRoot ("origin-{0}-{1}" -f $Suffix, [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            & $script:GitExe -C $dir init -q -b main 2>$null
            & $script:GitExe -C $dir config user.email 'gate-test@example.com' 2>$null
            & $script:GitExe -C $dir config user.name 'Gate Test' 2>$null
            # Allow pushes to the checked-out branch to update the working
            # tree too; test fixtures never inspect origin's own working
            # tree, only its refs.
            & $script:GitExe -C $dir config receive.denyCurrentBranch updateInstead 2>$null
            Set-Content -LiteralPath (Join-Path $dir 'base.txt') -Value 'base' -Encoding ASCII
            & $script:GitExe -C $dir add base.txt 2>$null
            & $script:GitExe -C $dir commit -q -m 'init' 2>$null
            return $dir
        }

        function New-GateClone {
            param([string]$OriginPath, [string]$Suffix)
            $dir = Join-Path $script:FixtureRoot ("clone-{0}-{1}" -f $Suffix, [guid]::NewGuid().ToString('N'))
            & $script:GitExe clone -q $OriginPath $dir 2>$null
            & $script:GitExe -C $dir config user.email 'gate-test@example.com' 2>$null
            & $script:GitExe -C $dir config user.name 'Gate Test' 2>$null
            return $dir
        }

        function Invoke-Gate {
            param([string]$RepoPath, [string]$Branch, [switch]$DeleteSafe)
            $argList = @('-NoProfile', '-File', $script:ScriptUnderTest, '-RepoPath', $RepoPath, '-Branch', $Branch, '-Json')
            if ($DeleteSafe) { $argList += '-DeleteSafe' }
            $raw = & powershell.exe @argList 2>$null
            $joined = ($raw -join "`n").Trim()
            if ([string]::IsNullOrWhiteSpace($joined)) { return $null }
            return ($joined | ConvertFrom-Json)
        }

        function Remove-GateFixture {
            param([string]$Path)
            if ($Path -and (Test-Path -LiteralPath $Path)) {
                Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'Squash-merged branch (content landed on default, history diverged)' {
        BeforeAll {
            $script:Origin1 = New-GateOrigin -Suffix 'squash'
            $script:Repo1 = New-GateClone -OriginPath $script:Origin1 -Suffix 'squash'

            # Feature branch: two-commit history introducing widget.txt.
            & $script:GitExe -C $script:Repo1 checkout -q -b feat/squashed 2>$null
            Set-Content -LiteralPath (Join-Path $script:Repo1 'widget.txt') -Value 'line1' -Encoding ASCII
            & $script:GitExe -C $script:Repo1 add widget.txt 2>$null
            & $script:GitExe -C $script:Repo1 commit -q -m 'widget: line1' 2>$null
            Add-Content -LiteralPath (Join-Path $script:Repo1 'widget.txt') -Value 'line2' -Encoding ASCII
            & $script:GitExe -C $script:Repo1 add widget.txt 2>$null
            & $script:GitExe -C $script:Repo1 commit -q -m 'widget: line2' 2>$null

            # Simulate the squash-merge landing on main as ONE commit with
            # the identical final content (same blob), no feature commits.
            & $script:GitExe -C $script:Repo1 checkout -q main 2>$null
            Set-Content -LiteralPath (Join-Path $script:Repo1 'widget.txt') -Value 'line1' -Encoding ASCII
            Add-Content -LiteralPath (Join-Path $script:Repo1 'widget.txt') -Value 'line2' -Encoding ASCII
            & $script:GitExe -C $script:Repo1 add widget.txt 2>$null
            & $script:GitExe -C $script:Repo1 commit -q -m 'squash: land widget' 2>$null
            & $script:GitExe -C $script:Repo1 push -q origin main 2>$null
            & $script:GitExe -C $script:Repo1 fetch -q --prune origin 2>$null
        }
        AfterAll {
            Remove-GateFixture -Path $script:Repo1
            Remove-GateFixture -Path $script:Origin1
        }

        It 'returns SAFE-TO-DELETE via the two-dot tree compare' {
            $result = Invoke-Gate -RepoPath $script:Repo1 -Branch 'feat/squashed'
            $result.Disposition | Should -Be 'SAFE-TO-DELETE'
            $result.Default | Should -Be 'main'
        }

        It 'has a non-empty three-dot diff even though the two-dot diff is empty (squash-awareness contract)' {
            $twoDot = (@(& $script:GitExe -C $script:Repo1 diff --stat origin/main feat/squashed 2>$null) -join "`n").Trim()
            $threeDot = (@(& $script:GitExe -C $script:Repo1 diff --stat origin/main...feat/squashed 2>$null) -join "`n").Trim()
            $twoDot | Should -BeNullOrEmpty
            $threeDot | Should -Not -BeNullOrEmpty

            $result = Invoke-Gate -RepoPath $script:Repo1 -Branch 'feat/squashed'
            $result.Disposition | Should -Be 'SAFE-TO-DELETE'
        }

        It 'deletes the local branch when -DeleteSafe is passed for a SAFE-TO-DELETE disposition' {
            $result = Invoke-Gate -RepoPath $script:Repo1 -Branch 'feat/squashed' -DeleteSafe
            $result.Disposition | Should -Be 'SAFE-TO-DELETE'
            $result.Deleted | Should -Be $true
            $stillExists = & $script:GitExe -C $script:Repo1 rev-parse --verify --quiet refs/heads/feat/squashed 2>$null
            $stillExists | Should -BeNullOrEmpty
        }
    }

    Context 'Genuinely diverged branch (real unmerged content)' {
        BeforeAll {
            $script:Origin2 = New-GateOrigin -Suffix 'diverged'
            $script:Repo2 = New-GateClone -OriginPath $script:Origin2 -Suffix 'diverged'

            & $script:GitExe -C $script:Repo2 checkout -q -b feat/diverged 2>$null
            Set-Content -LiteralPath (Join-Path $script:Repo2 'unique.txt') -Value 'unique unmerged content' -Encoding ASCII
            & $script:GitExe -C $script:Repo2 add unique.txt 2>$null
            & $script:GitExe -C $script:Repo2 commit -q -m 'unique: add unmerged content' 2>$null
            & $script:GitExe -C $script:Repo2 fetch -q --prune origin 2>$null
        }
        AfterAll {
            Remove-GateFixture -Path $script:Repo2
            Remove-GateFixture -Path $script:Origin2
        }

        It 'returns RETAIN with the tree-diff stat as evidence' {
            $result = Invoke-Gate -RepoPath $script:Repo2 -Branch 'feat/diverged'
            $result.Disposition | Should -Be 'RETAIN'
            $result.Evidence | Should -Match 'unique\.txt'
        }

        It 'never deletes the branch even when -DeleteSafe is passed (fail-closed)' {
            $result = Invoke-Gate -RepoPath $script:Repo2 -Branch 'feat/diverged' -DeleteSafe
            $result.Disposition | Should -Be 'RETAIN'
            $result.Deleted | Should -Be $false
            $stillExists = & $script:GitExe -C $script:Repo2 rev-parse --verify --quiet refs/heads/feat/diverged 2>$null
            $stillExists | Should -Not -BeNullOrEmpty
        }
    }
}
