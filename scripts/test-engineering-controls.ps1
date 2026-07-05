[CmdletBinding()]
param()

$root = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $PSScriptRoot 'validate-task-packets.ps1'
$safe = Join-Path $root 'engineering-os\examples\task-packets.json'
$collision = Join-Path $root 'engineering-os\examples\task-packets-collision.json'

& $validator -Path $safe | Write-Output
if (-not $?) { throw 'Safe task packets failed.' }

$collisionRejected = $false
try { & $validator -Path $collision -ErrorAction Stop | Out-Null }
catch { $collisionRejected = $_.Exception.Message -match 'Writer collision' }
if (-not $collisionRejected) { throw 'Expected writer collision was not rejected.' }
Write-Output 'Writer collision fixture rejected.'

$rollbackRoot = Join-Path $env:TEMP ("engineering-os-rollback-test-" + [guid]::NewGuid().ToString('N'))
try {
    & (Join-Path $PSScriptRoot 'restore-engineering-os-adapters.ps1') -Apply -TargetRoot $rollbackRoot -Confirm:$false | Write-Output
    $count = @(Get-ChildItem $rollbackRoot -File).Count
    if ($count -ne 5) { throw "Rollback test restored $count/5 files." }
    Write-Output 'Atomic rollback fixture passed: 5/5 files.'
} finally {
    if (Test-Path $rollbackRoot) { Remove-Item -LiteralPath $rollbackRoot -Recurse -Force }
}
