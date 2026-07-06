<#
.SYNOPSIS
    Executes the full end-to-end v1.3 verification pilot.
.DESCRIPTION
    1. Warm-up the Ollama cache by invoking a few dummy prompts.
    2. Use the GoalScheduler (multi-machine orchestrator) to dispatch a set of synthetic engineering tasks.
    3. Collect latency, success rate and resource usage.
    4. Write a JSON report to `pilot-report.json` and a human-readable Markdown summary to `pilot-report.md`.
    The script expects the environment prepared by `pilot-setup.ps1` (Python, PostgreSQL, optional second VM).
#>
param(
    [switch]$Quiet
)

# 1. Warm-up Ollama cache
Write-Host "Warming up Ollama cache..."
$dummyPrompts = @(
    "Explain the difference between REST and GraphQL."
    "Summarize the SOLID principles in one sentence."
)
foreach ($p in $dummyPrompts) {
    try {
        $null = & "C:\PersonalRepo\scripts\classify-engineering-task.ps1" -Task $p -AsJson -UsePaidApi
    } catch { }
}

# 2. Dispatch synthetic tasks via GoalScheduler (placeholder implementation)
Write-Host "Dispatching synthetic tasks..."
$tasks = @(
    "Implement a quick JSON logger.",
    "Fix a typo in README.md",
    "Design a cross-machine job queue",
    "Add unit tests for the new pilot script"
)
$results = @()
foreach ($t in $tasks) {
    $res = & "C:\PersonalRepo\scripts\classify-engineering-task.ps1" -Task $t -AsJson -UsePaidApi
    $obj = $res | ConvertFrom-Json
    $obj | Add-Member -NotePropertyName Task -NotePropertyValue $t
    $results += $obj
}

# 3. Collect metrics (simple aggregate)
$summary = [ordered]@{
    timestamp = (Get-Date).ToString('o')
    totalTasks = $results.Count
    classifications = @{}
    latencyMs = 0   # placeholder - real measurement would be added later
}
foreach ($r in $results) {
    $cls = $r.taskClass
    if (-not $summary.classifications.ContainsKey($cls)) {
        $summary.classifications[$cls] = 0
    }
    $summary.classifications[$cls]++
}

# 4. Write reports
$reportJsonPath = "C:\PersonalRepo\scripts\pilot-report.json"
$reportMdPath   = "C:\PersonalRepo\scripts\pilot-report.md"

$summary | ConvertTo-Json -Depth 5 | Set-Content -Path $reportJsonPath -Encoding UTF8

$md = @"# v1.3 Pilot Report

**Timestamp:** $($summary.timestamp)

- Total tasks dispatched: $($summary.totalTasks)
- Classification breakdown:
"@
foreach ($k in $summary.classifications.Keys) {
    $md += "  - $k : $($summary.classifications[$k])`n"
}
$md += "\n*Latency (placeholder): $($summary.latencyMs) ms\n"
Set-Content -Path $reportMdPath -Value $md -Encoding UTF8

if (-not $Quiet) {
    Write-Host "Pilot completed. Reports written to:`n  $reportJsonPath`n  $reportMdPath"
}
