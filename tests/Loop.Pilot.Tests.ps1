[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $repoRoot 'scripts\Test-LoopPilotEvidence.ps1'
& $validator
if (-not $?) { exit 1 }
Write-Host 'CAS loop pilot contract passed.'
