Set-StrictMode -Version Latest

Describe 'backlog-survey.ps1' {

    BeforeAll {
        $script:ScriptUnderTest = (Resolve-Path (Join-Path $PSScriptRoot '..\scripts\backlog-survey.ps1')).Path
        $script:FixtureRoot = Join-Path $env:TEMP ("backlog-survey-tests-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $script:FixtureRoot -Force | Out-Null

        $script:BacklogFixturePath = Join-Path $script:FixtureRoot 'improvement-backlog.md'
        $script:SnapshotDir = Join-Path $script:FixtureRoot 'snapshots'
        $script:ReportDir = Join-Path $script:FixtureRoot 'reports'

        function Write-BacklogFixture {
            param([string[]]$Ids)
            $fixtureLines = New-Object System.Collections.Generic.List[string]
            $fixtureLines.Add('# Test Backlog')
            $fixtureLines.Add('')
            $fixtureLines.Add('## Tier 1')
            $fixtureLines.Add('')
            $fixtureLines.Add('| # | Item | Sev |')
            $fixtureLines.Add('|---|---|---|')
            foreach ($fixtureId in $Ids) {
                $fixtureLines.Add("| $fixtureId | Test item for $fixtureId | Med |")
            }
            Set-Content -LiteralPath $script:BacklogFixturePath -Value ($fixtureLines -join "`r`n") -Encoding UTF8
        }

        function Invoke-BacklogSurvey {
            $raw = & powershell.exe -NoProfile -File $script:ScriptUnderTest `
                -BacklogPath $script:BacklogFixturePath `
                -SnapshotDir $script:SnapshotDir `
                -ReportDir $script:ReportDir `
                -Json 2>$null
            $joined = ($raw -join "`n").Trim()
            if ([string]::IsNullOrWhiteSpace($joined)) {
                return $null
            }
            return $joined | ConvertFrom-Json
        }
    }

    AfterAll {
        if ($script:FixtureRoot -and (Test-Path -LiteralPath $script:FixtureRoot)) {
            Remove-Item -LiteralPath $script:FixtureRoot -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Context 'First-ever run (no prior snapshot)' {
        BeforeAll {
            Write-BacklogFixture -Ids @('BX1', 'BX2')
            $script:Result1 = Invoke-BacklogSurvey
        }

        It 'reports newFindings containing BX1 and BX2, with zero closedItems' {
            $script:Result1 | Should -Not -BeNullOrEmpty
            $script:Result1.newFindings | Should -Contain 'BX1'
            $script:Result1.newFindings | Should -Contain 'BX2'
            @($script:Result1.newFindings).Count | Should -Be 2
            @($script:Result1.closedItems).Count | Should -Be 0
        }

        It 'reports convergence as BASELINE on the very first run' {
            $script:Result1.convergence | Should -Be 'BASELINE'
        }

        It 'writes exactly one dated snapshot JSON file and one dated delta report markdown file' {
            @(Get-ChildItem -LiteralPath $script:SnapshotDir -Filter 'backlog-survey-*.json' -File).Count | Should -Be 1
            @(Get-ChildItem -LiteralPath $script:ReportDir -Filter '*-backlog-survey-delta.md' -File).Count | Should -Be 1
        }
    }

    Context 'Second run detects the delta (same SnapshotDir as the first run)' {
        BeforeAll {
            Write-BacklogFixture -Ids @('BX2', 'BX3')
            $script:Result2 = Invoke-BacklogSurvey
            $script:ReportFile2 = Get-ChildItem -LiteralPath $script:ReportDir -Filter '*-backlog-survey-delta.md' -File |
                Sort-Object Name -Descending | Select-Object -First 1
            $script:ReportContent2 = Get-Content -LiteralPath $script:ReportFile2.FullName -Raw
        }

        It 'reports newFindings containing only BX3' {
            $script:Result2 | Should -Not -BeNullOrEmpty
            $script:Result2.newFindings | Should -Contain 'BX3'
            @($script:Result2.newFindings).Count | Should -Be 1
        }

        It 'reports closedItems containing only BX1' {
            $script:Result2.closedItems | Should -Contain 'BX1'
            @($script:Result2.closedItems).Count | Should -Be 1
        }

        It 'delta report markdown has a New Findings section listing BX3 and a Closed Items section listing BX1' {
            $script:ReportContent2 | Should -Match '(?s)## New Findings.*BX3'
            $script:ReportContent2 | Should -Match '(?s)## Closed Items.*BX1'
        }

        It 'reports convergence as CONVERGING or NOT_YET_CONVERGING on a subsequent run' {
            $script:Result2.convergence | Should -BeIn @('CONVERGING', 'NOT_YET_CONVERGING')
        }
    }
}
