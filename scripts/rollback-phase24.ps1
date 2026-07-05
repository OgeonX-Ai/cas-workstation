$ErrorActionPreference = 'Stop'
Write-Host "Rolling back Phase 24 changes..."

$baseDir = Split-Path -Parent $PSScriptRoot

$classifierPath = Join-Path $PSScriptRoot "classify-engineering-task.ps1"
$classifierBak = Join-Path $PSScriptRoot "classify-engineering-task.ps1.bak"
if (Test-Path $classifierBak) {
    Copy-Item -Path $classifierBak -Destination $classifierPath -Force
    Write-Host "Restored $classifierPath"
}

$casWorkstationPath = Join-Path $PSScriptRoot "Cas.Workstation.psm1"
$casWorkstationBak = Join-Path $PSScriptRoot "Cas.Workstation.psm1.bak"
if (Test-Path $casWorkstationBak) {
    Copy-Item -Path $casWorkstationBak -Destination $casWorkstationPath -Force
    Write-Host "Restored $casWorkstationPath"
}

$paidPolicyPath = Join-Path $baseDir "engineering-os\router\paid-api-policy.json"
if (Test-Path $paidPolicyPath) {
    Remove-Item -Path $paidPolicyPath -Force
    Write-Host "Removed $paidPolicyPath"
}

Write-Host "Rollback complete."
