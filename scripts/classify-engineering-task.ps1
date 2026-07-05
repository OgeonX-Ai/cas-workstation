[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Task,
    [switch]$AsJson
)

$text = $Task.ToLowerInvariant()
$security = $text -match 'security|threat|credential|secret|identity|production|rbac'
$defect = $text -match 'bug|defect|fix|failure|exception|intermittent|reproduce'
$architecture = $text -match 'architecture|cross-repository|orchestrat|migration|redesign'
$documentation = $text -match 'document|readme|summar|map repository|file read|extract'
$trivial = $text -match 'typo|one-line|rename|format' -and -not ($security -or $architecture)

$decision = [ordered]@{
    taskClass = 'substantial'
    risk = 'medium'
    complexity = 'moderate'
    parallelizable = [bool]($documentation -or $architecture)
    sdlcProfile = 'standard'
    roleAlias = 'standard'
    confidence = 0.78
    escalationReason = $null
}

if ($security) {
    $decision.taskClass = 'security'; $decision.risk = 'critical'
    $decision.complexity = 'ambiguous'; $decision.sdlcProfile = 'critical'
    $decision.roleAlias = 'adjudicator'; $decision.confidence = 0.95
    $decision.escalationReason = 'Security or identity impact requires critical gates and human acceptance.'
} elseif ($trivial) {
    $decision.taskClass = 'trivial'; $decision.risk = 'low'
    $decision.complexity = 'bounded'; $decision.parallelizable = $false
    $decision.sdlcProfile = 'quick'; $decision.roleAlias = 'light'; $decision.confidence = 0.94
} elseif ($documentation -and $text -match 'map repository|summar|document|readme|file read|extract') {
    $decision.taskClass = 'documentation'; $decision.risk = 'low'
    $decision.complexity = 'bounded'; $decision.parallelizable = $true
    $decision.sdlcProfile = 'quick'; $decision.roleAlias = 'light'; $decision.confidence = 0.91
} elseif ($architecture) {
    $decision.taskClass = 'substantial'; $decision.risk = 'high'
    $decision.complexity = 'ambiguous'; $decision.sdlcProfile = 'critical'
    $decision.roleAlias = 'strong'; $decision.confidence = 0.9
    $decision.escalationReason = 'Cross-boundary architecture requires strong synthesis and critical verification.'
} elseif ($defect) {
    $decision.taskClass = 'defect'; $decision.risk = 'medium'
    $decision.complexity = 'ambiguous'; $decision.parallelizable = $false
    $decision.sdlcProfile = 'standard'; $decision.roleAlias = 'strong'; $decision.confidence = 0.86
    $decision.escalationReason = 'Reproduce-first debugging may require stronger reasoning.'
} elseif ($documentation) {
    $decision.taskClass = 'documentation'; $decision.risk = 'low'
    $decision.complexity = 'bounded'; $decision.parallelizable = $true
    $decision.sdlcProfile = 'quick'; $decision.roleAlias = 'light'; $decision.confidence = 0.91
}

$result = [pscustomobject]$decision
if ($AsJson) { $result | ConvertTo-Json -Depth 4 -Compress } else { $result }
