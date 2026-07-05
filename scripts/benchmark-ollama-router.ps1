[CmdletBinding()]
param(
    [string]$Model = 'gemma3:1b',
    [string]$OutputPath = 'C:\PersonalRepo\engineering-os\router\ollama-benchmark.json'
)

$root = Split-Path -Parent $PSScriptRoot
$fixtures = Get-Content (Join-Path $root 'engineering-os\router\fixtures.json') -Raw | ConvertFrom-Json
$results = @()
$watch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($fixture in $fixtures) {
    $prompt = @"
Classify this engineering task. Return JSON only with taskClass, risk, sdlcProfile, roleAlias.
Allowed taskClass: trivial, defect, substantial, security, ai, ui, documentation, operations.
Allowed risk: low, medium, high, critical.
Allowed sdlcProfile: quick, standard, critical.
Allowed roleAlias: light, standard, strong, adjudicator.
Task: $($fixture.input)
"@
    $itemWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $raw = (& ollama run $Model $prompt 2>&1 | Out-String).Trim()
    $itemWatch.Stop()
    $parsed = $null
    $valid = $false
    try {
        $candidate = [regex]::Match($raw, '\{[\s\S]*\}').Value
        $parsed = $candidate | ConvertFrom-Json
        $valid = $true
        foreach ($name in @('taskClass', 'risk', 'sdlcProfile', 'roleAlias')) {
            if ($parsed.$name -ne $fixture.expected.$name) { $valid = $false }
        }
    } catch { $valid = $false }
    $results += [pscustomobject]@{
        input = $fixture.input
        passed = $valid
        latencyMs = $itemWatch.ElapsedMilliseconds
        response = $parsed
    }
}
$watch.Stop()

$latencies = @($results | ForEach-Object latencyMs | Sort-Object)
$p95Index = [Math]::Max(0, [Math]::Ceiling($latencies.Count * 0.95) - 1)
$passed = @($results | Where-Object passed).Count
$report = [ordered]@{
    capturedAt = (Get-Date).ToUniversalTime().ToString('o')
    model = $Model
    sampleSize = $results.Count
    accuracy = if ($results.Count) { $passed / $results.Count } else { 0 }
    p95LatencyMs = if ($latencies.Count) { $latencies[$p95Index] } else { $null }
    thresholds = @{ accuracy = 0.9; p95LatencyMs = 2500; successfulRuns = 20 }
    enabled = $false
    decision = 'disabled: benchmark must meet all thresholds and sample size'
    elapsedMs = $watch.ElapsedMilliseconds
    results = $results
}

$json = $report | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))
$json
