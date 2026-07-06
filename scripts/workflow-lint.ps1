[CmdletBinding()]
param(
    [string]$Path = ".",
    [switch]$Json
)

$ErrorActionPreference = 'Continue'
$findings = New-Object System.Collections.Generic.List[object]

function Add-Finding {
    param([string]$File, [string]$Check, [string]$Detail)
    $findings.Add([pscustomobject]@{ File = $File; Check = $Check; Detail = $Detail })
}

function Test-IsShaPin {
    param([string]$Ref)
    return $Ref -match '^[0-9a-f]{40}$'
}

function Invoke-WorkflowLint {
    param([string]$WorkflowFile)

    $rel = $WorkflowFile
    $lines = @()
    try {
        $lines = Get-Content -LiteralPath $WorkflowFile -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        Add-Finding -File $rel -Check 'parse-error' -Detail $_.Exception.Message
        return
    }

    # --- Check 1: unpinned third-party actions ---
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*(?:-\s*)?uses:\s*(\S+)') {
            $ref = $matches[1]
            # Exempt local relative and docker:// refs
            if ($ref -match '^\./' -or $ref -match '^docker://') {
                continue
            }
            $atIdx = $ref.LastIndexOf('@')
            if ($atIdx -lt 0) {
                Add-Finding -File $rel -Check 'unpinned-action' -Detail "Line $($i+1): $ref (no @ref)"
                continue
            }
            $pin = $ref.Substring($atIdx + 1)
            # Strip inline comment if present (e.g. @abc123 # v4)
            $pin = ($pin -split '\s')[0]
            if (-not (Test-IsShaPin -Ref $pin)) {
                Add-Finding -File $rel -Check 'unpinned-action' -Detail "Line $($i+1): $ref (ref=$pin)"
            }
        }
    }

    # --- Check 2: missing permissions block ---
    $hasTopLevelPermissions = $false
    $hasJobPermissions = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^permissions:') {
            $hasTopLevelPermissions = $true
            break
        }
        if ($line -match '^\s{2,}permissions:') {
            $hasJobPermissions = $true
            break
        }
    }
    if (-not $hasTopLevelPermissions -and -not $hasJobPermissions) {
        Add-Finding -File $rel -Check 'missing-permissions' -Detail 'No top-level or per-job permissions: block found'
    }

    # --- Check 3: missing timeout-minutes per job ---
    $inJobsBlock = $false
    $currentJobName = $null
    $currentJobStart = -1
    $jobBlocks = New-Object System.Collections.Generic.List[object]

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if ($line -match '^jobs:\s*$') {
            $inJobsBlock = $true
            continue
        }
        if ($inJobsBlock) {
            # Detect a new top-level key (end of jobs block)
            if ($line -match '^[A-Za-z0-9_-]' -and $line -notmatch '^jobs:') {
                $inJobsBlock = $false
                if ($currentJobName) {
                    $jobBlocks.Add([pscustomobject]@{ Name = $currentJobName; Start = $currentJobStart; End = $i - 1 })
                    $currentJobName = $null
                }
                continue
            }
            # Detect a job name: exactly 2 spaces + identifier + colon
            if ($line -match '^  ([A-Za-z0-9_-]+):\s*$') {
                if ($currentJobName) {
                    $jobBlocks.Add([pscustomobject]@{ Name = $currentJobName; Start = $currentJobStart; End = $i - 1 })
                }
                $currentJobName = $matches[1]
                $currentJobStart = $i
            }
        }
    }
    if ($currentJobName) {
        $jobBlocks.Add([pscustomobject]@{ Name = $currentJobName; Start = $currentJobStart; End = $lines.Count - 1 })
    }

    foreach ($job in $jobBlocks) {
        $hasTimeout = $false
        for ($i = $job.Start; $i -le $job.End; $i++) {
            if ($lines[$i] -match 'timeout-minutes:') {
                $hasTimeout = $true
                break
            }
        }
        if (-not $hasTimeout) {
            Add-Finding -File $rel -Check 'missing-timeout' -Detail "Job '$($job.Name)' has no timeout-minutes:"
        }
    }
}

# Discover all repos: find directories that contain a .github/workflows subfolder
$searchRoot = Resolve-Path -LiteralPath $Path | Select-Object -ExpandProperty Path
$workflowDirs = Get-ChildItem -LiteralPath $searchRoot -Recurse -Directory -Filter 'workflows' -ErrorAction SilentlyContinue |
    Where-Object {
        $fp = $_.FullName -replace '\\', '/'
        ($fp -match '/\.github/workflows$') -and ($fp -notmatch '/node_modules/')
    }

if ($workflowDirs.Count -eq 0) {
    Write-Host "workflow-lint: no .github/workflows directories found under $searchRoot"
    exit 0
}

foreach ($wfDir in $workflowDirs) {
    $wfFiles = Get-ChildItem -LiteralPath $wfDir.FullName -File -Include '*.yml','*.yaml' -ErrorAction SilentlyContinue
    foreach ($wfFile in $wfFiles) {
        Invoke-WorkflowLint -WorkflowFile $wfFile.FullName
    }
}

if ($Json) {
    $findings | ConvertTo-Json -Depth 4
}
elseif ($findings.Count -gt 0) {
    $findings | Format-Table -AutoSize | Out-String | Write-Host
}

if ($findings.Count -gt 0) {
    exit 1
}
Write-Host "workflow-lint: clean."
exit 0
