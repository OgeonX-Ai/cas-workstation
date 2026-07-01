[CmdletBinding()]
param(
    [string]$EvidencePath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'evidence\loop-pilots')
)

$ErrorActionPreference = 'Stop'
$required = @('feature', 'repair', 'restart', 'policy')
$documents = @{}

foreach ($scenario in $required) {
    $path = Join-Path $EvidencePath "$scenario.json"
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing pilot evidence: $path" }
    $document = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ($document.schemaVersion -ne '1.0.0' -or $document.scenario -ne $scenario -or $document.status -ne 'passed' -or -not $document.bounded) {
        throw "Invalid pilot header: $scenario"
    }
    if (@($document.events).Count -lt 2 -or @($document.artifacts).Count -lt 1 -or @($document.reproduce).Count -lt 1) {
        throw "Incomplete pilot evidence: $scenario"
    }
    for ($index = 0; $index -lt @($document.events).Count; $index++) {
        if ($document.events[$index].sequence -ne $index) { throw "Non-contiguous event sequence: $scenario" }
    }
    $documents[$scenario] = $document
}

$feature = $documents.feature.assertions
if (-not $feature.parallelAnalysis -or $feature.peakConcurrency -ne 3 -or -not $feature.isolatedImplementation -or $feature.mandatoryVerification -ne 'passed' -or $feature.goalStatus -ne 'completed' -or $feature.terminalLearningPublications -ne 1) { throw 'Feature pilot failed semantic validation.' }
$repair = $documents.repair.assertions
if ($repair.initialVerification -ne 'failed' -or -not $repair.repairCreated -or $repair.repairAttempt -gt $repair.repairLimit -or $repair.subsequentVerification -ne 'passed' -or $repair.terminalLearningPublications -ne 1) { throw 'Repair pilot failed semantic validation.' }
$restart = $documents.restart.assertions
if (-not $restart.leaseReclaimed -or $restart.duplicateCommit -ne 0 -or $restart.duplicateComment -ne 0 -or $restart.duplicatePullRequest -ne 0 -or -not $restart.idempotencyPreserved) { throw 'Restart pilot failed semantic validation.' }
$policy = $documents.policy.assertions
if ($policy.envAccess -ne 'denied' -or $policy.pushBeforeApproval -or $policy.deployBeforeApproval -or -not $policy.approvalRequired) { throw 'Policy pilot failed semantic validation.' }

Write-Host 'CAS loop pilot evidence passed (4/4).'
