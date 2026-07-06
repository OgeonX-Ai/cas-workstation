[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$failures = New-Object System.Collections.Generic.List[string]
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')

function Assert-CasTrue {
    param([string]$Name, [bool]$Condition)
    if (-not $Condition) { $failures.Add("$Name was false.") }
}

function Assert-CasEqual {
    param([string]$Name, $Expected, $Actual)
    if ($Expected -ne $Actual) { $failures.Add(("{0}: expected '{1}' but got '{2}'." -f $Name, $Expected, $Actual)) }
}

$cleanFixture = $null
$dirtyFixture = $null

try {
    # --- Build clean fixture ---
    $cleanFixture = Join-Path $env:TEMP ("wf-lint-clean-" + [guid]::NewGuid().ToString("N"))
    $cleanWfDir = Join-Path $cleanFixture ".github\workflows"
    New-Item -ItemType Directory -Path $cleanWfDir -Force | Out-Null
    $cleanYaml = @"
name: ci
on: [push]
permissions:
  contents: read
jobs:
  build:
    timeout-minutes: 10
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4
"@
    Set-Content -LiteralPath (Join-Path $cleanWfDir "ci.yml") -Value $cleanYaml -Encoding ASCII

    # --- Build dirty fixture ---
    $dirtyFixture = Join-Path $env:TEMP ("wf-lint-dirty-" + [guid]::NewGuid().ToString("N"))
    $dirtyWfDir = Join-Path $dirtyFixture ".github\workflows"
    New-Item -ItemType Directory -Path $dirtyWfDir -Force | Out-Null
    $dirtyYaml = @"
name: ci
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
"@
    Set-Content -LiteralPath (Join-Path $dirtyWfDir "ci.yml") -Value $dirtyYaml -Encoding ASCII

    # --- Build exemption fixture (local + docker refs must NOT be flagged) ---
    $exemptFixture = Join-Path $env:TEMP ("wf-lint-exempt-" + [guid]::NewGuid().ToString("N"))
    $exemptWfDir = Join-Path $exemptFixture ".github\workflows"
    New-Item -ItemType Directory -Path $exemptWfDir -Force | Out-Null
    $exemptYaml = @"
name: ci
on: [push]
permissions:
  contents: read
jobs:
  build:
    timeout-minutes: 5
    runs-on: ubuntu-latest
    steps:
      - uses: ./.github/actions/local-thing
      - uses: docker://alpine:3.19
"@
    Set-Content -LiteralPath (Join-Path $exemptWfDir "ci.yml") -Value $exemptYaml -Encoding ASCII

    $lintScript = Join-Path $repoRoot "scripts\workflow-lint.ps1"
    $psExe = 'powershell.exe'

    # --- Test 1: Clean fixture exits 0 with zero findings ---
    $cleanOutput = & $psExe -NoProfile -File $lintScript -Path $cleanFixture -Json 2>&1
    $cleanExit = $LASTEXITCODE
    Assert-CasEqual -Name "Clean fixture exit code" -Expected 0 -Actual $cleanExit
    $cleanRaw = $cleanOutput | Where-Object { $_ -is [string] -and $_.Trim() -ne "" -and $_.Trim() -ne 'workflow-lint: clean.' } | Out-String
    $cleanFindings = @()
    if ($cleanRaw.Trim() -ne '') {
        try { $cleanFindings = @($cleanRaw | ConvertFrom-Json) } catch { $cleanFindings = @() }
    }
    Assert-CasTrue -Name "Clean fixture has zero findings" -Condition ($cleanFindings.Count -eq 0)

    # --- Test 2: Dirty fixture exits 1 with all three finding classes ---
    $dirtyOutput = & $psExe -NoProfile -File $lintScript -Path $dirtyFixture -Json 2>&1
    $dirtyExit = $LASTEXITCODE
    Assert-CasEqual -Name "Dirty fixture exit code" -Expected 1 -Actual $dirtyExit
    $dirtyJson = ($dirtyOutput | Where-Object { $_ -is [string] }) -join "`n"
    $dirtyFindings = @()
    try { $parsed = $dirtyJson | ConvertFrom-Json; $dirtyFindings = @($parsed) } catch { $dirtyFindings = @() }
    $checks = @($dirtyFindings | ForEach-Object { $_.Check })
    Assert-CasTrue -Name "Dirty fixture has unpinned-action finding" -Condition ($checks -contains 'unpinned-action')
    Assert-CasTrue -Name "Dirty fixture has missing-permissions finding" -Condition ($checks -contains 'missing-permissions')
    Assert-CasTrue -Name "Dirty fixture has missing-timeout finding" -Condition ($checks -contains 'missing-timeout')

    # --- Test 3: Exemption fixture (local + docker) exits 0 with zero findings ---
    $exemptOutput = & $psExe -NoProfile -File $lintScript -Path $exemptFixture -Json 2>&1
    $exemptExit = $LASTEXITCODE
    Assert-CasEqual -Name "Exempt fixture exit code" -Expected 0 -Actual $exemptExit
    $exemptRaw = $exemptOutput | Where-Object { $_ -is [string] -and $_.Trim() -ne "" -and $_.Trim() -ne 'workflow-lint: clean.' } | Out-String
    $exemptFindings = @()
    if ($exemptRaw.Trim() -ne '') {
        try { $exemptFindings = @($exemptRaw | ConvertFrom-Json) } catch { $exemptFindings = @() }
    }
    Assert-CasTrue -Name "Exempt fixture has zero findings (local+docker refs not flagged)" -Condition ($exemptFindings.Count -eq 0)
}
finally {
    if ($cleanFixture -and (Test-Path $cleanFixture)) { Remove-Item -LiteralPath $cleanFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($dirtyFixture -and (Test-Path $dirtyFixture)) { Remove-Item -LiteralPath $dirtyFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($exemptFixture -and (Test-Path $exemptFixture)) { Remove-Item -LiteralPath $exemptFixture -Recurse -Force -ErrorAction SilentlyContinue }
}

if ($failures.Count -gt 0) {
    Write-Error ("Workflow.Lint.Tests: " + ($failures -join "; "))
    exit 1
}
Write-Host "Workflow.Lint.Tests: all assertions passed."
exit 0
