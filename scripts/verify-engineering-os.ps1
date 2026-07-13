[CmdletBinding()]
param(
    [switch]$IncludeGlobalAdapters
)

$repo = Split-Path -Parent $PSScriptRoot
$osRoot = Join-Path $repo 'engineering-os'
$errors = [System.Collections.Generic.List[string]]::new()

$required = @(
    'OPERATING-CONTRACT.md',
    'compatibility\tool-matrix.json',
    'models\codex.json', 'models\claude.json', 'models\gemini.json', 'models\antigravity.json',
    'policies\sdlc-profiles.json', 'policies\gsd-routing.json',
    'schemas\routing-decision.schema.json', 'schemas\sdlc-override.schema.json',
    'schemas\task-packet.schema.json', 'schemas\telemetry-event.schema.json',
    'router\fixtures.json', 'router\ollama-policy.json'
)
foreach ($relative in $required) {
    if (-not (Test-Path (Join-Path $osRoot $relative))) { $errors.Add("Missing artifact: $relative") }
}

Get-ChildItem $osRoot -Filter '*.json' -Recurse | ForEach-Object {
    try { Get-Content $_.FullName -Raw | ConvertFrom-Json | Out-Null }
    catch { $errors.Add("Invalid JSON: $($_.FullName): $($_.Exception.Message)") }
}

$roles = @('light', 'standard', 'strong', 'adjudicator')
Get-ChildItem (Join-Path $osRoot 'models') -Filter '*.json' | ForEach-Object {
    $map = Get-Content $_.FullName -Raw | ConvertFrom-Json
    foreach ($role in $roles) {
        if (-not $map.aliases.PSObject.Properties[$role]) { $errors.Add("$($_.Name) missing role $role") }
    }
    if ($map.tool -eq 'antigravity' -and $map.perSubagentOverride -ne $false) {
        $errors.Add('Antigravity must not claim per-subagent model override without live proof.')
    }
}

$matrix = Get-Content (Join-Path $osRoot 'compatibility\tool-matrix.json') -Raw | ConvertFrom-Json
if ($matrix.tools.ollama.enabled -ne $false) { $errors.Add('Ollama must remain disabled until benchmark thresholds pass.') }

$geminiMap = Get-Content (Join-Path $osRoot 'models\gemini.json') -Raw | ConvertFrom-Json
if ($matrix.tools.gemini.auth -match 'ineligible' -and $geminiMap.enabled -ne $false) {
    $errors.Add('Gemini mapping must be disabled while the installed OAuth tier is ineligible.')
}

$policy = Get-Content (Join-Path $osRoot 'router\ollama-policy.json') -Raw | ConvertFrom-Json
if ($policy.enabled -and $policy.fallback -ne 'deterministic-rules') { $errors.Add('Enabled Ollama routing still requires deterministic fallback.') }
if ($policy.allowedPurpose -ne 'routing-classification-only') { $errors.Add('Ollama purpose must remain routing-classification-only.') }
foreach ($decision in @('security-final', 'architecture-final', 'completion-final')) {
    if ($policy.forbiddenDecisions -notcontains $decision) { $errors.Add("Ollama policy missing forbidden decision: $decision") }
}
if ($policy.enabled) {
    $benchmark = Get-Content (Join-Path $osRoot 'router\ollama-benchmark.json') -Raw | ConvertFrom-Json
    if ($benchmark.sampleSize -lt $policy.thresholds.successfulRuns -or $benchmark.accuracy -lt $policy.thresholds.accuracy -or $benchmark.p95LatencyMs -gt $policy.thresholds.p95LatencyMs) {
        $errors.Add('Ollama is enabled without meeting benchmark thresholds.')
    }
}

$profiles = Get-Content (Join-Path $osRoot 'policies\sdlc-profiles.json') -Raw | ConvertFrom-Json
if ($profiles.profiles.critical.humanAcceptance -ne $true) { $errors.Add('Critical profile must require human acceptance.') }
$securityDecision = & (Join-Path $PSScriptRoot 'classify-engineering-task.ps1') -Task 'security threat identity production'
if ($securityDecision.roleAlias -ne 'adjudicator' -or $securityDecision.sdlcProfile -ne 'critical') { $errors.Add('Security routing must select critical/adjudicator.') }

& python (Join-Path $PSScriptRoot 'validate-engineering-json.py')
if (-not $?) { $errors.Add('Engineering JSON/schema examples failed validation.') }
& (Join-Path $PSScriptRoot 'validate-task-packets.ps1') -Path (Join-Path $osRoot 'examples\task-packets.json')
if (-not $?) { $errors.Add('Task packet collision validation failed.') }
& (Join-Path $PSScriptRoot 'test-engineering-controls.ps1')
if (-not $?) { $errors.Add('Engineering control fixtures failed.') }

$planFiles = Get-ChildItem (Join-Path $repo '.planning\phases') -Filter '*-PLAN.md' -Recurse -ErrorAction SilentlyContinue
foreach ($planFile in $planFiles) {
    $planText = Get-Content $planFile.FullName -Raw
    foreach ($field in @('sdlcProfile:', 'riskClass:', 'requiredVerifiers:', 'evidenceLocations:', 'overrideState:')) {
        if ($planText -notmatch [regex]::Escape($field)) { $errors.Add("Planning metadata missing $field in $($planFile.FullName)") }
    }
}

$profileRoot = $env:USERPROFILE
if (-not (Test-Path -LiteralPath (Join-Path $profileRoot '.claude\CLAUDE.md'))) {
    $activeProfile = 'C:\Users\KimHarjamäki'
    if (Test-Path -LiteralPath (Join-Path $activeProfile '.claude\CLAUDE.md')) { $profileRoot = $activeProfile }
}
$adapterPaths = @(
    'C:\codex-home\AGENTS.md',
    (Join-Path $profileRoot '.codex\AGENTS.md'),
    (Join-Path $profileRoot '.claude\CLAUDE.md'),
    (Join-Path $profileRoot '.gemini\gemini.md'),
    (Join-Path $profileRoot '.config\ai-agents\GLOBAL_AGENTS.md')
)
if ($IncludeGlobalAdapters) {
    foreach ($path in $adapterPaths) {
        if (-not (Test-Path -LiteralPath $path)) { $errors.Add("Missing global adapter: $path"); continue }
        $content = Get-Content -LiteralPath $path -Raw
        if ($content -notmatch [regex]::Escape('C:\PersonalRepo\engineering-os\OPERATING-CONTRACT.md')) {
            $errors.Add("Global adapter does not reference canonical contract: $path")
        }
        if ($content -match '(?i)infinite healing loop|zero-touch deployment|direct deployment to production') {
            $errors.Add("Unsafe or conflicting global directive: $path")
        }
    }
}

Get-ChildItem $osRoot,$PSScriptRoot -File -Recurse | Where-Object { $_.Extension -in @('.md', '.json', '.ps1', '.py') } | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '(?i)(api[_-]?key|token|secret)\s*[:=]\s*["''][A-Za-z0-9_\-]{20,}') {
        $errors.Add("Potential embedded credential: $($_.FullName)")
    }
}

$routerOutput = & (Join-Path $PSScriptRoot 'test-engineering-router.ps1')
if (-not $?) { $errors.Add('Deterministic router fixtures failed.') }
else { $routerOutput | Write-Output }

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output 'Engineering OS verification passed.'
