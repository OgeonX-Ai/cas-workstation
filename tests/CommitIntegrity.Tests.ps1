Set-StrictMode -Version Latest

Describe 'commit-integrity-check.ps1' {

    BeforeAll {
        $script:ScriptUnderTest = (Resolve-Path (Join-Path $PSScriptRoot '..\scripts\commit-integrity-check.ps1')).Path
        # Dot-source to get Test-CommitIntegrity in scope without invoking the
        # CLI wrapper (guarded by $MyInvocation.InvocationName -ne '.').
        . $script:ScriptUnderTest

        function New-CiFixture {
            param([string]$Suffix = 'base')
            $dir = Join-Path $env:TEMP ("ci-test-{0}-{1}" -f $Suffix, [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            git -C $dir init -q 2>$null
            git -C $dir config user.email 'ci-test@example.com' 2>$null
            git -C $dir config user.name 'CI Test' 2>$null
            Set-Content -LiteralPath (Join-Path $dir 'README.md') -Value 'fixture' -Encoding ASCII
            git -C $dir add README.md 2>$null
            git -C $dir commit -q -m 'chore: init fixture' 2>$null
            return $dir
        }

        function Add-CiCommit {
            param(
                [Parameter(Mandatory)][string]$Dir,
                [Parameter(Mandatory)][string]$Message,
                [Parameter(Mandatory)][string[]]$Files
            )
            foreach ($relPath in $Files) {
                $full = Join-Path $Dir $relPath
                $parent = Split-Path -Parent $full
                if ($parent -and -not (Test-Path -LiteralPath $parent)) {
                    New-Item -ItemType Directory -Path $parent -Force | Out-Null
                }
                Set-Content -LiteralPath $full -Value ("content for {0}" -f $relPath) -Encoding ASCII
                git -C $Dir add -- $relPath 2>$null
            }
            git -C $Dir commit -q -m $Message 2>$null
        }

        function Remove-CiFixture {
            param([string]$Path)
            if ($Path -and (Test-Path -LiteralPath $Path)) {
                Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    Context 'b4e0868 regression case (test:-typed commit touching zero test paths)' {
        BeforeAll {
            $script:Fixture1 = New-CiFixture -Suffix 'b4e0868'
            Add-CiCommit -Dir $script:Fixture1 `
                -Message 'test: add full coverage suites for gsd-orchestrator and autogen' `
                -Files @('.planning/PROJECT.md', '.planning/ROADMAP.md', '.planning/STATE.md', 'engineering-os/OPERATING-CONTRACT.md')
        }
        AfterAll {
            Remove-CiFixture -Path $script:Fixture1
        }
        It 'flags the commit as a violation' {
            $violations = Test-CommitIntegrity -Range 'HEAD~1..HEAD' -Path $script:Fixture1
            $violations.Count | Should -Be 1
            $violations[0].Subject | Should -Be 'test: add full coverage suites for gsd-orchestrator and autogen'
        }
    }

    Context 'Real test-adding commit (true positive avoided)' {
        BeforeAll {
            $script:Fixture2 = New-CiFixture -Suffix 'realtest'
            Add-CiCommit -Dir $script:Fixture2 `
                -Message 'test: add fixture for X' `
                -Files @('tests/Fixture.Tests.ps1')
        }
        AfterAll {
            Remove-CiFixture -Path $script:Fixture2
        }
        It 'passes cleanly with no violation' {
            $violations = Test-CommitIntegrity -Range 'HEAD~1..HEAD' -Path $script:Fixture2
            $violations.Count | Should -Be 0
        }
    }

    Context 'Non-test-typed commit is exempt' {
        BeforeAll {
            $script:Fixture3 = New-CiFixture -Suffix 'docs'
            Add-CiCommit -Dir $script:Fixture3 `
                -Message 'docs: update README' `
                -Files @('README.md')
        }
        AfterAll {
            Remove-CiFixture -Path $script:Fixture3
        }
        It 'is never flagged regardless of path patterns' {
            $violations = Test-CommitIntegrity -Range 'HEAD~1..HEAD' -Path $script:Fixture3
            $violations.Count | Should -Be 0
        }
    }

    Context 'Scope-qualified test commit is still recognized as test:-typed' {
        BeforeAll {
            $script:Fixture4 = New-CiFixture -Suffix 'scoped'
            Add-CiCommit -Dir $script:Fixture4 `
                -Message 'test(phase34): add commit-integrity coverage' `
                -Files @('notes.md')
        }
        AfterAll {
            Remove-CiFixture -Path $script:Fixture4
        }
        It 'is flagged as a violation despite the parenthetical scope, proving prefix recognition' {
            $violations = Test-CommitIntegrity -Range 'HEAD~1..HEAD' -Path $script:Fixture4
            $violations.Count | Should -Be 1
            $violations[0].Subject | Should -Be 'test(phase34): add commit-integrity coverage'
        }
    }

    Context 'Multi-commit range reports one violation row per offending commit' {
        BeforeAll {
            $script:Fixture5 = New-CiFixture -Suffix 'multi'
            # Commit A: clean test commit (touches a real test path) -> no violation.
            Add-CiCommit -Dir $script:Fixture5 `
                -Message 'test: add coverage for A' `
                -Files @('tests/A.Tests.ps1')
            # Commit B: docs commit -> exempt, no violation.
            Add-CiCommit -Dir $script:Fixture5 `
                -Message 'docs: update notes' `
                -Files @('docs/notes.md')
            # Commit C: violating test commit (touches only non-test paths) -> violation.
            Add-CiCommit -Dir $script:Fixture5 `
                -Message 'test: add coverage for C' `
                -Files @('src/c.txt')
        }
        AfterAll {
            Remove-CiFixture -Path $script:Fixture5
        }
        It 'reports exactly one violation, for the offending commit only' {
            $violations = Test-CommitIntegrity -Range 'HEAD~3..HEAD' -Path $script:Fixture5
            $violations.Count | Should -Be 1
            $violations[0].Subject | Should -Be 'test: add coverage for C'
        }
    }
}
