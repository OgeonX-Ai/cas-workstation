[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Task,
    [switch]$AsJson
)

$policyPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'engineering-os\router\ollama-policy.json'
$ollamaPolicy = $null
if (Test-Path $policyPath) {
    try {
        $ollamaPolicy = Get-Content $policyPath -Raw | ConvertFrom-Json
    } catch {}
}

if ($ollamaPolicy -and $ollamaPolicy.enabled) {
    try {
        $prompt = @"
Classify this engineering task. Return JSON only with taskClass, risk, sdlcProfile, roleAlias.
Allowed taskClass: trivial, defect, substantial, security, ai, ui, documentation, operations.
Allowed risk: low, medium, high, critical.
Allowed sdlcProfile: quick, standard, critical.
Allowed roleAlias: light, standard, strong, adjudicator.
Task: $Task
"@
        $schema = @{
            type = "object"
            properties = @{
                taskClass = @{ type = "string" }
                risk = @{ type = "string" }
                sdlcProfile = @{ type = "string" }
                roleAlias = @{ type = "string" }
            }
            required = @("taskClass", "risk", "sdlcProfile", "roleAlias")
        }
        $body = @{
            model = $ollamaPolicy.candidate
            prompt = $prompt
            format = $schema
            stream = $false
            keep_alive = "5m"
        } | ConvertTo-Json -Depth 6
        
        # Determine appropriate timeout if available, otherwise rely on standard Invoke-RestMethod handling
        $resp = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        $raw = $resp.response.Trim()
        $candidate = [regex]::Match($raw, '\{[\s\S]*\}').Value
        $parsed = $candidate | ConvertFrom-Json
        
        if ($parsed.taskClass -and $parsed.risk -and $parsed.sdlcProfile -and $parsed.roleAlias) {
            $decision = [ordered]@{
                taskClass = $parsed.taskClass
                risk = $parsed.risk
                complexity = if ($parsed.complexity) { $parsed.complexity } else { 'moderate' }
                parallelizable = if ($null -ne $parsed.parallelizable) { [bool]$parsed.parallelizable } else { $false }
                sdlcProfile = $parsed.sdlcProfile
                roleAlias = $parsed.roleAlias
                confidence = if ($parsed.confidence) { $parsed.confidence } else { 0.90 }
                escalationReason = if ($parsed.escalationReason) { $parsed.escalationReason } else { $null }
            }
            $result = [pscustomobject]$decision
            if ($AsJson) { return ($result | ConvertTo-Json -Depth 4 -Compress) }
            return $result
        }
    } catch {
        # Fallback to Paid API before deterministic rules
        $paidPolicyPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'engineering-os\router\paid-api-policy.json'
        $paidPolicy = $null
        if (Test-Path $paidPolicyPath) {
            try { $paidPolicy = Get-Content $paidPolicyPath -Raw | ConvertFrom-Json } catch {}
        }
        
        if ($paidPolicy -and $paidPolicy.enabled) {
            try {
                $headers = @{ "Content-Type" = "application/json" }
                if ($paidPolicy.apiKeyEnv -and [Environment]::GetEnvironmentVariable($paidPolicy.apiKeyEnv)) {
                    $headers["Authorization"] = "Bearer " + [Environment]::GetEnvironmentVariable($paidPolicy.apiKeyEnv)
                }
                
                $body = @{
                    model = $paidPolicy.candidate
                    prompt = $prompt
                    format = $schema
                } | ConvertTo-Json -Depth 6
                
                $resp = Invoke-RestMethod -Uri $paidPolicy.endpoint -Method Post -Headers $headers -Body $body -ErrorAction Stop
                
                $raw = if ($resp.response) { $resp.response.Trim() } else { $resp.Trim() }
                $candidate = [regex]::Match($raw, '\{[\s\S]*\}').Value
                $parsed = $candidate | ConvertFrom-Json
                
                if ($parsed.taskClass -and $parsed.risk -and $parsed.sdlcProfile -and $parsed.roleAlias) {
                    $decision = [ordered]@{
                        taskClass = $parsed.taskClass
                        risk = $parsed.risk
                        complexity = if ($parsed.complexity) { $parsed.complexity } else { 'moderate' }
                        parallelizable = if ($null -ne $parsed.parallelizable) { [bool]$parsed.parallelizable } else { $false }
                        sdlcProfile = $parsed.sdlcProfile
                        roleAlias = $parsed.roleAlias
                        confidence = if ($parsed.confidence) { $parsed.confidence } else { 0.85 }
                        escalationReason = if ($parsed.escalationReason) { $parsed.escalationReason } else { $null }
                    }
                    $result = [pscustomobject]$decision
                    if ($AsJson) { return ($result | ConvertTo-Json -Depth 4 -Compress) }
                    return $result
                }
            } catch {
                # Fallback to deterministic regex rules
            }
        }
    }
}

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
