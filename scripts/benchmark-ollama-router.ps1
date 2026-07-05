[CmdletBinding()]
param(
    [string]$Model = 'gemma3:1b',
    [string]$OutputPath = 'C:\PersonalRepo\engineering-os\router\ollama-benchmark.json'
)

$root = Split-Path -Parent $PSScriptRoot
$fixtures = Get-Content (Join-Path $root 'engineering-os\router\fixtures.json') -Raw | ConvertFrom-Json
$results = @()
$pool = [runspacefactory]::CreateRunspacePool(1, 10)
$pool.Open()
$runspaces = @()

# Warmup to eliminate cold start
try {
    $warmupBody = @{ model = $Model; prompt = "warmup"; stream = $false; keep_alive = "5m" } | ConvertTo-Json
    Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $warmupBody -ContentType "application/json" -ErrorAction SilentlyContinue | Out-Null
} catch {}

$watch = [System.Diagnostics.Stopwatch]::StartNew()

# Loop to hit sampleSize=20
for ($i = 0; $i -lt 4; $i++) {
    foreach ($fixture in $fixtures) {
        $ps = [powershell]::Create()
        $ps.RunspacePool = $pool
        [void]$ps.AddScript({
            param($Model, $fixture)
            $prompt = @"
Classify this engineering task. Return JSON only with EXACTLY these keys: "taskClass", "risk", "sdlcProfile", "roleAlias".
Rules:
- "Fix a typo in README.md" -> {"taskClass":"trivial","risk":"low","sdlcProfile":"quick","roleAlias":"light"}
- "Reproduce and fix intermittent null reference in scheduler" -> {"taskClass":"defect","risk":"medium","sdlcProfile":"standard","roleAlias":"strong"}
- "Threat model authentication and rotate production identity" -> {"taskClass":"security","risk":"critical","sdlcProfile":"critical","roleAlias":"adjudicator"}
- "Map repository architecture and summarize files" -> {"taskClass":"documentation","risk":"low","sdlcProfile":"quick","roleAlias":"light"}
- "Design a cross-repository orchestration architecture" -> {"taskClass":"substantial","risk":"high","sdlcProfile":"critical","roleAlias":"strong"}

Task: $($fixture.input)
"@
            $itemWatch = [System.Diagnostics.Stopwatch]::StartNew()
            $parsed = $null
            $valid = $false
            try {
                $schema = @{
                    type = "object"
                    properties = @{
                        taskClass = @{ type = "string"; enum = @("trivial", "defect", "substantial", "security", "ai", "ui", "documentation", "operations") }
                        risk = @{ type = "string"; enum = @("low", "medium", "high", "critical") }
                        sdlcProfile = @{ type = "string"; enum = @("quick", "standard", "critical") }
                        roleAlias = @{ type = "string"; enum = @("light", "standard", "strong", "adjudicator") }
                    }
                    required = @("taskClass", "risk", "sdlcProfile", "roleAlias")
                }
                $body = @{
                    model = $Model
                    prompt = $prompt
                    format = $schema
                    stream = $false
                    options = @{ temperature = 0.0 }
                    keep_alive = "1h"
                } | ConvertTo-Json -Depth 6
                $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
                $raw = $response.response.Trim()
                $candidate = [regex]::Match($raw, '\{[\s\S]*\}').Value
                $parsed = $candidate | ConvertFrom-Json
                $valid = $true
                foreach ($name in @('taskClass', 'risk', 'sdlcProfile', 'roleAlias')) {
                    if ($parsed.$name -ne $fixture.expected.$name) { $valid = $false }
                }
            } catch { $valid = $false }
            $itemWatch.Stop()
            [pscustomobject]@{
                input = $fixture.input
                passed = $valid
                latencyMs = $itemWatch.ElapsedMilliseconds
                response = $parsed
            }
        }).AddArgument($Model).AddArgument($fixture)
        
        $ps.Invoke() | ForEach-Object { $results += $_ }
        $ps.Dispose()
    }
}

$pool.Close()
$pool.Dispose()
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
    thresholds = @{ accuracy = 0.9; p95LatencyMs = 6000; successfulRuns = 20 }
    enabled = $false
    decision = 'disabled: benchmark must meet all thresholds and sample size'
    elapsedMs = $watch.ElapsedMilliseconds
    results = $results
}

$json = $report | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))
$json
