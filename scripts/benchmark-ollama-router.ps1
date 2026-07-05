[CmdletBinding()]
param(
    [string]$Model = 'gemma3:1b',
    [string]$OutputPath = 'C:\PersonalRepo\engineering-os\router\ollama-benchmark.json'
)

$root = Split-Path -Parent $PSScriptRoot
$fixtures = Get-Content (Join-Path $root 'engineering-os\router\fixtures.json') -Raw | ConvertFrom-Json
$results = @()
$watch = [System.Diagnostics.Stopwatch]::StartNew()

$pool = [runspacefactory]::CreateRunspacePool(1, 10)
$pool.Open()
$runspaces = @()

foreach ($fixture in $fixtures) {
    $ps = [powershell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
        param($Model, $fixture)
        $prompt = @"
Classify this engineering task. Return JSON only with taskClass, risk, sdlcProfile, roleAlias.
Allowed taskClass: trivial, defect, substantial, security, ai, ui, documentation, operations.
Allowed risk: low, medium, high, critical.
Allowed sdlcProfile: quick, standard, critical.
Allowed roleAlias: light, standard, strong, adjudicator.
Task: $($fixture.input)
"@
        $itemWatch = [System.Diagnostics.Stopwatch]::StartNew()
        $parsed = $null
        $valid = $false
        try {
            $body = @{
                model = $Model
                prompt = $prompt
                stream = $false
                keep_alive = "5m"
            } | ConvertTo-Json
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
    
    $runspaces += [pscustomobject]@{ Pipe = $ps; Status = $ps.BeginInvoke() }
}

$results = foreach ($r in $runspaces) {
    $r.Pipe.EndInvoke($r.Status)
    $r.Pipe.Dispose()
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
    thresholds = @{ accuracy = 0.9; p95LatencyMs = 2500; successfulRuns = 20 }
    enabled = $false
    decision = 'disabled: benchmark must meet all thresholds and sample size'
    elapsedMs = $watch.ElapsedMilliseconds
    results = $results
}

$json = $report | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.UTF8Encoding]::new($false))
$json
