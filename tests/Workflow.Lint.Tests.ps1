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
$exemptFixture = $null
$ghStubDir = $null
$reachableFixture = $null
$unreachableFixture = $null
$notFoundFixture = $null
$skippedFixture = $null
$originalPath = $env:PATH

# --- A1 gh stub: fakes `gh api repos/<owner>/<repo>[/compare/<base>...<sha>] --jq <field>` ---
# Existing (pre-A1) assertions below exercise unrelated checks and must stay
# deterministic/offline regardless of whether the machine running this test
# has an authenticated `gh` session, so WL_SKIP_GH is set for them.
$env:WL_SKIP_GH = '1'

function New-GhStub {
    param([string]$Dir)
    New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    $stubPs1 = Join-Path $Dir 'gh-stub.ps1'
    $stubContent = @'
$joined = $args -join " "
if ($joined -match "/compare/[^.]+\.\.\.(?<sha>[0-9a-fA-F]{40})") {
    switch ($Matches["sha"]) {
        "f288e5e3b67b29a2c08880b76da7b852f4a132d0" { Write-Output "diverged"; exit 0 }
        "2222222222222222222222222222222222222222" { [Console]::Error.WriteLine("gh: Not Found (HTTP 404)"); exit 1 }
        default { Write-Output "identical"; exit 0 }
    }
}
else {
    Write-Output "main"
    exit 0
}
'@
    Set-Content -LiteralPath $stubPs1 -Value $stubContent -Encoding ASCII
    $stubCmd = Join-Path $Dir 'gh.cmd'
    Set-Content -LiteralPath $stubCmd -Value "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0gh-stub.ps1`" %*`r`nexit /b %errorlevel%`r`n" -Encoding ASCII
    return $Dir
}

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

    # ============================================================
    # A1 SHA-reachability gate
    # ============================================================
    $ghStubDir = Join-Path $env:TEMP ("wf-lint-gh-stub-" + [guid]::NewGuid().ToString("N"))
    New-GhStub -Dir $ghStubDir | Out-Null
    $env:PATH = "$ghStubDir;$originalPath"
    Remove-Item Env:\WL_SKIP_GH -ErrorAction SilentlyContinue

    # --- Test 4: reachable SHA (gh stub returns 'identical') exits 0, no unreachable-pin ---
    $reachableFixture = Join-Path $env:TEMP ("wf-lint-reach-" + [guid]::NewGuid().ToString("N"))
    $reachWfDir = Join-Path $reachableFixture ".github\workflows"
    New-Item -ItemType Directory -Path $reachWfDir -Force | Out-Null
    $reachYaml = @"
name: ci
on: [push]
permissions:
  contents: read
jobs:
  build:
    timeout-minutes: 10
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@1111111111111111111111111111111111111111 # reachable (stub)
"@
    Set-Content -LiteralPath (Join-Path $reachWfDir "ci.yml") -Value $reachYaml -Encoding ASCII
    $reachOutput = & $psExe -NoProfile -File $lintScript -Path $reachableFixture -Json 2>&1
    $reachExit = $LASTEXITCODE
    Assert-CasEqual -Name "Reachable-SHA fixture exit code" -Expected 0 -Actual $reachExit
    $reachRaw = $reachOutput | Where-Object { $_ -is [string] -and $_.Trim() -ne "" -and $_.Trim() -ne 'workflow-lint: clean.' } | Out-String
    $reachFindings = @()
    if ($reachRaw.Trim() -ne '') {
        try { $reachFindings = @($reachRaw | ConvertFrom-Json) } catch { $reachFindings = @() }
    }
    Assert-CasTrue -Name "Reachable-SHA fixture has zero findings" -Condition ($reachFindings.Count -eq 0)

    # --- Test 5 (RED fixture): unreachable/diverged SHA (real stranded f288e5e3... SHA
    # from docs/merge-train-runbook.md Phase 42 incident) is caught as 'unreachable-pin' ---
    $unreachableFixture = Join-Path $env:TEMP ("wf-lint-unreach-" + [guid]::NewGuid().ToString("N"))
    $unreachWfDir = Join-Path $unreachableFixture ".github\workflows"
    New-Item -ItemType Directory -Path $unreachWfDir -Force | Out-Null
    $unreachYaml = @"
name: release-please
on: [push]
permissions:
  contents: read
jobs:
  release:
    timeout-minutes: 10
    uses: OgeonX-Ai/.github/.github/workflows/release-please.yml@f288e5e3b67b29a2c08880b76da7b852f4a132d0
"@
    Set-Content -LiteralPath (Join-Path $unreachWfDir "release-please.yml") -Value $unreachYaml -Encoding ASCII
    $unreachOutput = & $psExe -NoProfile -File $lintScript -Path $unreachableFixture -Json 2>&1
    $unreachExit = $LASTEXITCODE
    Assert-CasEqual -Name "Unreachable-SHA fixture exit code" -Expected 1 -Actual $unreachExit
    $unreachJson = ($unreachOutput | Where-Object { $_ -is [string] }) -join "`n"
    $unreachFindings = @()
    try { $parsed = $unreachJson | ConvertFrom-Json; $unreachFindings = @($parsed) } catch { $unreachFindings = @() }
    $unreachChecks = @($unreachFindings | ForEach-Object { $_.Check })
    Assert-CasTrue -Name "Unreachable-SHA fixture has unreachable-pin finding" -Condition ($unreachChecks -contains 'unreachable-pin')
    $pinFinding = $unreachFindings | Where-Object { $_.Check -eq 'unreachable-pin' } | Select-Object -First 1
    Assert-CasTrue -Name "unreachable-pin finding detail references the stranded SHA" -Condition ($pinFinding -and $pinFinding.Detail -match 'f288e5e3b67b29a2c08880b76da7b852f4a132d0')
    Assert-CasTrue -Name "unreachable-pin finding detail reports status=diverged" -Condition ($pinFinding -and $pinFinding.Detail -match 'status=diverged')

    # --- Test 6: gh 404 (repo/commit not found) is also caught as 'unreachable-pin' ---
    $notFoundFixture = Join-Path $env:TEMP ("wf-lint-404-" + [guid]::NewGuid().ToString("N"))
    $notFoundWfDir = Join-Path $notFoundFixture ".github\workflows"
    New-Item -ItemType Directory -Path $notFoundWfDir -Force | Out-Null
    $notFoundYaml = @"
name: ci
on: [push]
permissions:
  contents: read
jobs:
  build:
    timeout-minutes: 10
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@2222222222222222222222222222222222222222 # stub returns 404
"@
    Set-Content -LiteralPath (Join-Path $notFoundWfDir "ci.yml") -Value $notFoundYaml -Encoding ASCII
    $notFoundOutput = & $psExe -NoProfile -File $lintScript -Path $notFoundFixture -Json 2>&1
    $notFoundExit = $LASTEXITCODE
    Assert-CasEqual -Name "404-SHA fixture exit code" -Expected 1 -Actual $notFoundExit
    $notFoundJson = ($notFoundOutput | Where-Object { $_ -is [string] }) -join "`n"
    $notFoundFindings = @()
    try { $parsed = $notFoundJson | ConvertFrom-Json; $notFoundFindings = @($parsed) } catch { $notFoundFindings = @() }
    $notFoundChecks = @($notFoundFindings | ForEach-Object { $_.Check })
    Assert-CasTrue -Name "404-SHA fixture has unreachable-pin finding" -Condition ($notFoundChecks -contains 'unreachable-pin')

    # --- Test 7: WL_SKIP_GH offline guard suppresses the check entirely, even on the
    # same unreachable SHA that Test 5 flags when the guard is not set ---
    $skippedFixture = $unreachableFixture
    $env:WL_SKIP_GH = '1'
    $skippedOutput = & $psExe -NoProfile -File $lintScript -Path $skippedFixture -Json 2>&1
    $skippedExit = $LASTEXITCODE
    Assert-CasEqual -Name "WL_SKIP_GH fixture exit code" -Expected 0 -Actual $skippedExit
    $skippedRaw = $skippedOutput | Where-Object { $_ -is [string] -and $_.Trim() -ne "" -and $_.Trim() -ne 'workflow-lint: clean.' } | Out-String
    $skippedFindings = @()
    if ($skippedRaw.Trim() -ne '') {
        try { $skippedFindings = @($skippedRaw | ConvertFrom-Json) } catch { $skippedFindings = @() }
    }
    Assert-CasTrue -Name "WL_SKIP_GH suppresses unreachable-pin check" -Condition (-not (@($skippedFindings | ForEach-Object { $_.Check }) -contains 'unreachable-pin'))
}
finally {
    $env:PATH = $originalPath
    Remove-Item Env:\WL_SKIP_GH -ErrorAction SilentlyContinue
    if ($cleanFixture -and (Test-Path $cleanFixture)) { Remove-Item -LiteralPath $cleanFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($dirtyFixture -and (Test-Path $dirtyFixture)) { Remove-Item -LiteralPath $dirtyFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($exemptFixture -and (Test-Path $exemptFixture)) { Remove-Item -LiteralPath $exemptFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($reachableFixture -and (Test-Path $reachableFixture)) { Remove-Item -LiteralPath $reachableFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($unreachableFixture -and (Test-Path $unreachableFixture)) { Remove-Item -LiteralPath $unreachableFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($notFoundFixture -and (Test-Path $notFoundFixture)) { Remove-Item -LiteralPath $notFoundFixture -Recurse -Force -ErrorAction SilentlyContinue }
    if ($ghStubDir -and (Test-Path $ghStubDir)) { Remove-Item -LiteralPath $ghStubDir -Recurse -Force -ErrorAction SilentlyContinue }
}

if ($failures.Count -gt 0) {
    Write-Error ("Workflow.Lint.Tests: " + ($failures -join "; "))
    exit 1
}
Write-Host "Workflow.Lint.Tests: all assertions passed."
exit 0
