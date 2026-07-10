<#
.SYNOPSIS
  Repeatable backlog survey producing a dated delta report (REQ-1.5.6).
.DESCRIPTION
  Parses docs/improvement-backlog.md's markdown table rows, keyed by the
  backlog's own stable IDs (S1, W1, E1, etc - 1-3 letters followed by
  digits). Compares the current parse against the most recent prior
  snapshot in -SnapshotDir to compute newFindings / closedItems /
  unchangedCount, writes a dated JSON snapshot and a dated delta report
  markdown file, and reports a convergence signal (BASELINE on the first
  run, CONVERGING when this cycle's new-finding count is lower than its
  closed-item count, otherwise NOT_YET_CONVERGING) - the terminal condition
  vNEXT-SEEDS.md defines for "nothing left to improve".
.EXAMPLE
  powershell -NoProfile -File scripts\backlog-survey.ps1
  powershell -NoProfile -File scripts\backlog-survey.ps1 -Json
#>
[CmdletBinding()]
param(
    [string]$BacklogPath = "docs\improvement-backlog.md",
    [string]$Root = "C:\PersonalRepo",
    [string]$SnapshotDir,
    [string]$ReportDir,
    [switch]$Json
)

# 'Continue' on purpose: a broken row or unreadable file must not crash the
# whole survey - mirrors scripts/workspace-health.ps1's "must survive broken
# repos, not die on them" convention.
$ErrorActionPreference = 'Continue'

# PS 5.1's default console output encoding is the legacy OEM codepage, which
# mangles UTF-8 bytes for non-ASCII paths/content. Force UTF-8 decoding of
# native/console output so bytes round-trip correctly.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

if (-not $SnapshotDir) {
    $SnapshotDir = Join-Path $Root 'evidence\backlog-survey\snapshots'
}
if (-not $ReportDir) {
    $ReportDir = Join-Path $Root 'evidence\backlog-survey\reports'
}

function Resolve-BacklogFullPath {
    param([string]$Path, [string]$RootPath)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return (Join-Path $RootPath $Path)
}

$resolvedBacklogPath = Resolve-BacklogFullPath -Path $BacklogPath -RootPath $Root

if (-not (Test-Path -LiteralPath $resolvedBacklogPath)) {
    Write-Error ("backlog-survey: BacklogPath does not resolve: {0}" -f $resolvedBacklogPath)
    exit 1
}

New-Item -ItemType Directory -Path $SnapshotDir -Force | Out-Null
New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null

# Table rows carrying a stable ID: 1-3 letters, then digits, e.g. "| S1 | ... |".
# Rows without a real ID (headers, prose, the literal "-" placeholder row) do
# not match and are silently skipped - a parse miss must never throw.
$idRowPattern = '^\|\s*([A-Za-z]{1,3}[0-9]+)\s*\|(.*)$'
$headingPattern = '^#{2,3}\s+(.*)$'

$currentSection = ''
$items = New-Object System.Collections.Generic.List[object]

foreach ($line in (Get-Content -LiteralPath $resolvedBacklogPath -Encoding UTF8)) {
    $trimmedLine = $line.Trim()

    if ($trimmedLine -match $headingPattern) {
        $currentSection = $Matches[1].Trim()
        continue
    }

    if ($trimmedLine -match $idRowPattern) {
        $rowId = $Matches[1]
        $items.Add([pscustomobject]@{
            Id      = $rowId
            Section = $currentSection
            RawRow  = $trimmedLine
        })
    }
}

function Get-LatestSnapshotFile {
    param([string]$Dir)
    if (-not (Test-Path -LiteralPath $Dir)) {
        return $null
    }
    $files = @(Get-ChildItem -LiteralPath $Dir -Filter 'backlog-survey-*.json' -File -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending)
    if ($files.Count -eq 0) {
        return $null
    }
    return $files[0]
}

$previousFile = Get-LatestSnapshotFile -Dir $SnapshotDir
$previousItemsById = @{}

if ($previousFile) {
    $previousData = Get-Content -LiteralPath $previousFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($prevItem in @($previousData.items)) {
        $previousItemsById[$prevItem.Id] = $prevItem
    }
}

$currentIds = @($items | ForEach-Object { $_.Id })
$previousIds = @($previousItemsById.Keys)

$newFindings = @($currentIds | Where-Object { $previousIds -notcontains $_ })
$closedItems = @($previousIds | Where-Object { $currentIds -notcontains $_ })
$unchangedCount = @($currentIds | Where-Object { $previousIds -contains $_ }).Count

if (-not $previousFile) {
    $convergence = 'BASELINE'
}
elseif ($newFindings.Count -lt $closedItems.Count) {
    $convergence = 'CONVERGING'
}
else {
    $convergence = 'NOT_YET_CONVERGING'
}

$today = Get-Date -Format 'yyyy-MM-dd'

# --- Write the dated snapshot -------------------------------------------------

$snapshotPath = Join-Path $SnapshotDir ("backlog-survey-{0}.json" -f $today)
$snapshotItems = @($items | ForEach-Object {
    [ordered]@{ Id = $_.Id; Section = $_.Section; RawRow = $_.RawRow }
})
$snapshotObject = [ordered]@{
    captured_at = (Get-Date).ToString('o')
    backlogPath = $resolvedBacklogPath
    items       = $snapshotItems
}
$snapshotObject | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $snapshotPath -Encoding UTF8

# --- Write the dated delta report ---------------------------------------------

function Get-RowExcerpt {
    param([string]$RawRow)
    $trimmedRow = $RawRow.Trim().Trim('|')
    $cells = $trimmedRow -split '\|'
    if ($cells.Count -ge 2) {
        $text = $cells[1].Trim()
    }
    else {
        $text = ''
    }
    $text = $text -replace '\|', '-'
    if ($text.Length -gt 80) {
        $text = $text.Substring(0, 77) + '...'
    }
    return $text
}

$newFindingsDetails = @($items | Where-Object { $newFindings -contains $_.Id })
$closedItemsDetails = New-Object System.Collections.Generic.List[object]
foreach ($closedId in $closedItems) {
    if ($previousItemsById.ContainsKey($closedId)) {
        $closedItemsDetails.Add($previousItemsById[$closedId])
    }
}

$reportPath = Join-Path $ReportDir ("{0}-backlog-survey-delta.md" -f $today)

$reportLines = New-Object System.Collections.Generic.List[string]
$reportLines.Add("# Backlog Survey Delta Report - $today")
$reportLines.Add("")
$reportLines.Add("Source backlog: $resolvedBacklogPath")
$reportLines.Add("")
$reportLines.Add("## New Findings")
$reportLines.Add("")
if ($newFindingsDetails.Count -gt 0) {
    $reportLines.Add("| Id | Section | Excerpt |")
    $reportLines.Add("|---|---|---|")
    foreach ($newItem in $newFindingsDetails) {
        $reportLines.Add(("| {0} | {1} | {2} |" -f $newItem.Id, $newItem.Section, (Get-RowExcerpt $newItem.RawRow)))
    }
}
else {
    $reportLines.Add("None.")
}
$reportLines.Add("")
$reportLines.Add("## Closed Items")
$reportLines.Add("")
if ($closedItemsDetails.Count -gt 0) {
    $reportLines.Add("| Id | Section |")
    $reportLines.Add("|---|---|")
    foreach ($closedItem in $closedItemsDetails) {
        $reportLines.Add(("| {0} | {1} |" -f $closedItem.Id, $closedItem.Section))
    }
}
else {
    $reportLines.Add("None.")
}
$reportLines.Add("")
$reportLines.Add("## Trend Counts")
$reportLines.Add("")
$reportLines.Add(("- Total current items: {0}" -f $items.Count))
$reportLines.Add(("- New findings: {0}" -f $newFindings.Count))
$reportLines.Add(("- Closed items: {0}" -f $closedItems.Count))
$reportLines.Add(("- Unchanged items: {0}" -f $unchangedCount))
$reportLines.Add(("- Convergence: {0}" -f $convergence))
$reportLines.Add("")

if ($convergence -eq 'BASELINE') {
    $prose = "This is the first-ever survey run (REQ-1.5.6); there is no prior snapshot to diff against, so every parsed item is reported as a new finding and convergence is BASELINE."
}
elseif ($convergence -eq 'CONVERGING') {
    $prose = "Per vNEXT-SEEDS.md's convergence definition (fewer new findings per cycle than it closes), this cycle is CONVERGING: $($newFindings.Count) new finding(s) versus $($closedItems.Count) closed item(s)."
}
else {
    $prose = "Per vNEXT-SEEDS.md's convergence definition (fewer new findings per cycle than it closes), this cycle is NOT_YET_CONVERGING: $($newFindings.Count) new finding(s) versus $($closedItems.Count) closed item(s)."
}
$reportLines.Add($prose)

Set-Content -LiteralPath $reportPath -Value ($reportLines -join "`r`n") -Encoding UTF8

# --- Emit output ---------------------------------------------------------------

if ($Json) {
    $summary = [ordered]@{
        date           = $today
        totalItems     = $items.Count
        newFindings    = $newFindings
        closedItems    = $closedItems
        unchangedCount = $unchangedCount
        convergence    = $convergence
    }
    $summary | ConvertTo-Json -Depth 5
}
else {
    Write-Host ("backlog-survey: {0} total item(s), {1} new, {2} closed, {3} unchanged. convergence={4}" -f $items.Count, $newFindings.Count, $closedItems.Count, $unchangedCount, $convergence)
    Write-Host ("Snapshot: {0}" -f $snapshotPath)
    Write-Host ("Report:   {0}" -f $reportPath)
}

exit 0
