[CmdletBinding()]
param(
    [string]$Path = ".",
    [switch]$Json
)

$ErrorActionPreference = 'Continue'
$findings = New-Object System.Collections.Generic.List[object]

# A1 SHA-reachability gate: per-run caches so a SHA/repo pair pinned in
# multiple workflow files (or multiple lines) only costs one `gh api` call.
# WL_SKIP_GH lets offline/CI-less callers (e.g. Pester runs without a `gh`
# auth session) opt out of the network-dependent check entirely.
$script:DefaultBranchCache = @{}
$script:ShaReachabilityCache = @{}

function Add-Finding {
    param([string]$File, [string]$Check, [string]$Detail)
    $findings.Add([pscustomobject]@{ File = $File; Check = $Check; Detail = $Detail })
}

function Test-IsShaPin {
    param([string]$Ref)
    return $Ref -match '^[0-9a-f]{40}$'
}

function Get-UsesOwnerRepo {
    param([string]$Ref)
    # Ref is the part before '@', e.g. 'actions/checkout' or
    # 'OgeonX-Ai/.github/.github/workflows/release-please.yml'
    if ($Ref -match '^([^/]+)/([^/]+)') {
        return [pscustomobject]@{ Owner = $matches[1]; Repo = $matches[2] }
    }
    return $null
}

function Get-DefaultBranchForRepo {
    param([string]$Owner, [string]$Repo)
    $key = "$Owner/$Repo"
    if ($script:DefaultBranchCache.ContainsKey($key)) {
        return $script:DefaultBranchCache[$key]
    }
    $branch = $null
    try {
        $out = & gh api "repos/$Owner/$Repo" --jq '.default_branch' 2>$null
        if ($LASTEXITCODE -eq 0 -and $out) {
            $branch = ($out | Select-Object -First 1).ToString().Trim()
        }
    }
    catch {
        $branch = $null
    }
    $script:DefaultBranchCache[$key] = $branch
    return $branch
}

function Test-ShaReachability {
    # Returns @{ Ok = <bool>; Status = <string> }. Per A1 spec: identical/behind
    # from the provider's default branch = OK; diverged or a 404 (commit/repo
    # not found, e.g. an orphaned branch-tip SHA after a squash-merge deleted
    # the source branch) = FINDING 'unreachable-pin'.
    param([string]$Owner, [string]$Repo, [string]$Sha)

    $cacheKey = "$Owner/$Repo@$Sha"
    if ($script:ShaReachabilityCache.ContainsKey($cacheKey)) {
        return $script:ShaReachabilityCache[$cacheKey]
    }

    $result = $null
    $default = Get-DefaultBranchForRepo -Owner $Owner -Repo $Repo
    if (-not $default) {
        # Could not resolve the default branch (repo not found, auth issue,
        # transient error). Do not fail the gate on infrastructure noise.
        $result = [pscustomobject]@{ Ok = $true; Status = 'default-branch-unresolved' }
        $script:ShaReachabilityCache[$cacheKey] = $result
        return $result
    }

    try {
        $out = & gh api "repos/$Owner/$Repo/compare/$default...$Sha" --jq '.status' 2>$null
        $exitCode = $LASTEXITCODE
        $status = if ($out) { (($out | Select-Object -First 1).ToString()).Trim() } else { $null }
        if ($exitCode -ne 0 -or -not $status) {
            $result = [pscustomobject]@{ Ok = $false; Status = '404' }
        }
        elseif ($status -eq 'diverged') {
            $result = [pscustomobject]@{ Ok = $false; Status = 'diverged' }
        }
        else {
            # identical, behind, ahead, or any other status GitHub returns.
            $result = [pscustomobject]@{ Ok = $true; Status = $status }
        }
    }
    catch {
        $result = [pscustomobject]@{ Ok = $true; Status = 'error' }
    }

    $script:ShaReachabilityCache[$cacheKey] = $result
    return $result
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
            elseif (-not $env:WL_SKIP_GH -and (Get-Command gh -ErrorAction SilentlyContinue)) {
                # --- Check 4 (A1): SHA-reachability from the provider's default branch ---
                $ownerRepo = Get-UsesOwnerRepo -Ref $ref.Substring(0, $atIdx)
                if ($ownerRepo) {
                    $reach = Test-ShaReachability -Owner $ownerRepo.Owner -Repo $ownerRepo.Repo -Sha $pin
                    if (-not $reach.Ok) {
                        Add-Finding -File $rel -Check 'unreachable-pin' -Detail "Line $($i+1): $ref (sha=$pin owner/repo=$($ownerRepo.Owner)/$($ownerRepo.Repo) status=$($reach.Status))"
                    }
                }
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
