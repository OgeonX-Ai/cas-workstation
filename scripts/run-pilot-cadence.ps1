<#
.SYNOPSIS
  Local pilot-cadence runner (REQ-1.5.4 / Phase 40-01).
.DESCRIPTION
  Re-runs the four v1.0 loop pilot scenarios (via tests\Loop.Pilot.Tests.ps1)
  plus the Phase 28 fault-injection suites in portfolio\gsd-orchestrator and
  portfolio\autogen, from isolated worktrees pinned to origin/main -- never
  touching either sub-repo's primary checkout.

  Writes a dated evidence summary to evidence\pilot-cadence\{date}.json,
  commits it via a dedicated evidence worktree + branch + PR against this
  repo's master (the primary C:\PersonalRepo working tree is never touched),
  and writes full raw suite output to the gitignored
  scratch\pilot-cadence-logs\{date}\ directory.

  On any non-green suite, unless -NoIssueFile is set, calls
  scripts\file-pilot-regression-issue.ps1 to file (or dedupe-comment on) a
  regression issue on the suite's owning repo.
.EXAMPLE
  powershell -NoProfile -File scripts\run-pilot-cadence.ps1
  powershell -NoProfile -File scripts\run-pilot-cadence.ps1 -NoIssueFile
  powershell -NoProfile -File scripts\run-pilot-cadence.ps1 -OnlySuites loop-pilots -NoCommit
#>
[CmdletBinding()]
param(
    [string]$Root = 'C:\PersonalRepo',
    [string]$EvidenceRoot = (Join-Path $Root 'evidence\pilot-cadence'),
    [string]$LogRoot = (Join-Path $Root 'scratch\pilot-cadence-logs'),
    [string[]]$OnlySuites = @('loop-pilots', 'gsd-orchestrator-fault-injection', 'autogen-fault-injection'),
    [string]$GsdOrchestratorRef = 'origin/main',
    [string]$AutogenRef = 'origin/main',
    [switch]$NoCommit,
    [switch]$NoIssueFile
)

$ErrorActionPreference = 'Stop'

$startedAt = (Get-Date).ToUniversalTime()
$runDate = $startedAt.ToString('yyyy-MM-dd')

function Invoke-CapturedCommand {
    <#
    Runs a native command (git/dotnet/pytest/gh/powershell), capturing combined
    stdout+stderr as a single text blob via $LASTEXITCODE, without letting
    Windows PowerShell 5.1's native-command stderr behavior promote stderr
    lines into terminating errors under $ErrorActionPreference = 'Stop'. This
    is the single point every external command in this script goes through so
    that a non-zero exit from git/dotnet/pytest/gh never aborts the run.
    #>
    param(
        [Parameter(Mandatory = $true)][scriptblock]$Command
    )
    $previousEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $raw = & $Command 2>&1
    } finally {
        $ErrorActionPreference = $previousEap
    }
    $text = ($raw | Out-String).Trim()
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text     = $text
    }
}

function Sync-ReadOnlyWorktree {
    <#
    Single point that ever touches $SourceRepo. The only mutation against
    $SourceRepo is a best-effort fetch (read-only) plus worktree registration
    metadata -- this function never checks out, resets, or commits against
    $SourceRepo's own working tree or its currently-checked-out branch.
    #>
    param(
        [Parameter(Mandatory = $true)][string]$SourceRepo,
        [Parameter(Mandatory = $true)][string]$WorktreePath,
        [Parameter(Mandatory = $true)][string]$Ref
    )

    $noteLines = @()
    # Best-effort fetch of the same branch $Ref points at (e.g. "origin/main"
    # -> "main", "origin/master" -> "master") so this works for any ref, not
    # just repos whose default branch happens to be named "main".
    $refBranch = $Ref -replace '^origin/', ''

    $fetchResult = Invoke-CapturedCommand { & git -C $SourceRepo fetch origin $refBranch }
    if ($fetchResult.ExitCode -ne 0) {
        $noteLines += "fetch origin $refBranch against $SourceRepo failed (proceeding with existing local ref state): $($fetchResult.Text)"
    } else {
        $noteLines += "fetch origin $refBranch against $SourceRepo : ok"
    }

    if (-not (Test-Path -LiteralPath $WorktreePath)) {
        $addResult = Invoke-CapturedCommand { & git -C $SourceRepo worktree add --detach $WorktreePath $Ref }
        if ($addResult.ExitCode -ne 0) {
            throw "Sync-ReadOnlyWorktree: 'git worktree add --detach $WorktreePath $Ref' failed -- $($addResult.Text)"
        }
        $noteLines += "worktree add --detach $WorktreePath $Ref : ok"
    } else {
        $fetchWtResult = Invoke-CapturedCommand { & git -C $WorktreePath fetch $SourceRepo $Ref -q }
        if ($fetchWtResult.ExitCode -ne 0) {
            throw "Sync-ReadOnlyWorktree: 'git -C $WorktreePath fetch $SourceRepo $Ref' failed -- $($fetchWtResult.Text)"
        }
        $checkoutResult = Invoke-CapturedCommand { & git -C $WorktreePath checkout --detach FETCH_HEAD -q }
        if ($checkoutResult.ExitCode -ne 0) {
            throw "Sync-ReadOnlyWorktree: 'git -C $WorktreePath checkout --detach FETCH_HEAD' failed -- $($checkoutResult.Text)"
        }
        $noteLines += "worktree $WorktreePath re-synced to fresh $Ref : ok"
    }

    return ($noteLines -join "`n")
}

# Ordered suite registry: Id -> { OwningRepo, Run scriptblock }.
# Each Run scriptblock returns a pscustomobject with Status ('passed'/'failed'),
# DurationSeconds, CommitSha, Output (full combined stdout+stderr).
$allSuiteDefs = [ordered]@{
    'loop-pilots' = @{
        OwningRepo = 'OgeonX-Ai/cas-workstation'
        Run        = {
            param($Root, $GsdOrchestratorRef, $AutogenRef)
            $start = Get-Date
            $testScript = Join-Path $Root 'tests\Loop.Pilot.Tests.ps1'
            $runResult = Invoke-CapturedCommand { & powershell -NoProfile -File $testScript }
            $duration = [math]::Round(((Get-Date) - $start).TotalSeconds, 2)
            $commitSha = (& git -C $Root rev-parse HEAD).Trim()
            [pscustomobject]@{
                Status          = if ($runResult.ExitCode -eq 0) { 'passed' } else { 'failed' }
                DurationSeconds = $duration
                CommitSha       = $commitSha
                Output          = $runResult.Text
            }
        }
    }
    'gsd-orchestrator-fault-injection' = @{
        OwningRepo = 'Coding-Autopilot-System/gsd-orchestrator'
        Run        = {
            param($Root, $GsdOrchestratorRef, $AutogenRef)
            $sourceRepo = Join-Path $Root 'portfolio\gsd-orchestrator'
            $worktreePath = Join-Path $Root 'worktrees\gsd-orchestrator-pilot-cadence'
            $syncNote = Sync-ReadOnlyWorktree -SourceRepo $sourceRepo -WorktreePath $worktreePath -Ref $GsdOrchestratorRef
            $start = Get-Date
            Push-Location $worktreePath
            try {
                $runResult = Invoke-CapturedCommand {
                    & dotnet test 'src\GsdOrchestrator.Tests\GsdOrchestrator.Tests.csproj' --filter 'FullyQualifiedName~FaultInjectionTests|FullyQualifiedName~CheckpointCorruptionTests'
                }
            } finally {
                Pop-Location
            }
            $duration = [math]::Round(((Get-Date) - $start).TotalSeconds, 2)
            $commitSha = (& git -C $worktreePath rev-parse HEAD).Trim()
            [pscustomobject]@{
                Status          = if ($runResult.ExitCode -eq 0) { 'passed' } else { 'failed' }
                DurationSeconds = $duration
                CommitSha       = $commitSha
                Output          = $syncNote + "`n---`n" + $runResult.Text
            }
        }
    }
    'autogen-fault-injection' = @{
        OwningRepo = 'Coding-Autopilot-System/autogen'
        Run        = {
            param($Root, $GsdOrchestratorRef, $AutogenRef)
            $sourceRepo = Join-Path $Root 'portfolio\autogen'
            $worktreePath = Join-Path $Root 'worktrees\autogen-pilot-cadence'
            $syncNote = Sync-ReadOnlyWorktree -SourceRepo $sourceRepo -WorktreePath $worktreePath -Ref $AutogenRef
            # The primary repo-local venv's interpreter is used with the worktree as
            # the working directory; pytest's rootdir-based sys.path insertion means
            # this correctly exercises the worktree's own maf_starter, not the
            # primary checkout's (see interfaces note in 40-01-PLAN.md).
            $pythonExe = Join-Path $Root 'portfolio\autogen\.venv\Scripts\python.exe'
            $start = Get-Date
            Push-Location $worktreePath
            try {
                $runResult = Invoke-CapturedCommand {
                    & $pythonExe -m pytest 'tests\test_provider_fallback_telemetry.py' 'tests\test_worker_boundary.py' -v
                }
            } finally {
                Pop-Location
            }
            $duration = [math]::Round(((Get-Date) - $start).TotalSeconds, 2)
            $commitSha = (& git -C $worktreePath rev-parse HEAD).Trim()
            [pscustomobject]@{
                Status          = if ($runResult.ExitCode -eq 0) { 'passed' } else { 'failed' }
                DurationSeconds = $duration
                CommitSha       = $commitSha
                Output          = $syncNote + "`n---`n" + $runResult.Text
            }
        }
    }
}

$suiteResults = @()

foreach ($suiteId in $OnlySuites) {
    if (-not $allSuiteDefs.Contains($suiteId)) {
        Write-Warning "Unknown suite id '$suiteId' -- skipping."
        continue
    }

    $def = $allSuiteDefs[$suiteId]
    Write-Host "Running suite: $suiteId ..."

    try {
        $result = & $def.Run $Root $GsdOrchestratorRef $AutogenRef
    } catch {
        $result = [pscustomobject]@{
            Status          = 'failed'
            DurationSeconds = 0
            CommitSha       = ''
            Output          = "Suite threw an exception before completion: $($_.Exception.Message)"
        }
    }

    $suiteEntry = [ordered]@{
        id              = $suiteId
        owningRepo      = $def.OwningRepo
        status          = $result.Status
        durationSeconds = $result.DurationSeconds
        commitSha       = $result.CommitSha
    }

    if ($result.Status -ne 'passed') {
        $lines = $result.Output -split "`r?`n"
        $tail = $lines | Select-Object -Last 40
        $excerpt = ($tail -join "`n") -replace [regex]::Escape($Root), '<repo-root>'
        $suiteEntry['failureExcerpt'] = $excerpt
    }

    $suiteResults += [pscustomobject]$suiteEntry

    $logDir = Join-Path $LogRoot $runDate
    if (-not (Test-Path -LiteralPath $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    $logPath = Join-Path $logDir "$suiteId.log"
    Set-Content -LiteralPath $logPath -Value $result.Output -Encoding UTF8

    Write-Host ("  {0}: {1} ({2}s)" -f $suiteId, $result.Status, $result.DurationSeconds)
}

$finishedAt = (Get-Date).ToUniversalTime()
$failedCount = @($suiteResults | Where-Object { $_.status -ne 'passed' }).Count
$overallStatus = if ($failedCount -eq 0) { 'passed' } else { 'failed' }

$issuesFiled = @()
if (-not $NoIssueFile) {
    $issueFilerScript = Join-Path $PSScriptRoot 'file-pilot-regression-issue.ps1'
    foreach ($suite in ($suiteResults | Where-Object { $_.status -ne 'passed' })) {
        Write-Host "Filing regression issue for suite: $($suite.id) ..."
        try {
            $issueResult = & $issueFilerScript -Repo $suite.owningRepo -SuiteId $suite.id -FailureExcerpt $suite.failureExcerpt -RunDate $runDate
        } catch {
            Write-Warning "file-pilot-regression-issue.ps1 threw for suite $($suite.id) -- $($_.Exception.Message)"
            $issueResult = $null
        }
        if ($issueResult) {
            $issuesFiled += [ordered]@{
                suiteId  = $suite.id
                issueUrl = $issueResult.IssueUrl
                deduped  = [bool]$issueResult.Deduped
            }
        }
    }
}

$evidenceEntry = [ordered]@{
    schemaVersion = '1.0.0'
    runDate       = $runDate
    startedAt     = $startedAt.ToString('yyyy-MM-ddTHH:mm:ssZ')
    finishedAt    = $finishedAt.ToString('yyyy-MM-ddTHH:mm:ssZ')
    overallStatus = $overallStatus
    suites        = $suiteResults
    issuesFiled   = $issuesFiled
}

if (-not (Test-Path -LiteralPath $EvidenceRoot)) {
    New-Item -ItemType Directory -Path $EvidenceRoot -Force | Out-Null
}
$evidencePath = Join-Path $EvidenceRoot "$runDate.json"
($evidenceEntry | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath $evidencePath -Encoding UTF8

if (-not $NoCommit) {
    $evidenceWorktreePath = Join-Path $Root 'worktrees\cas-workstation-pilot-cadence'
    $syncNote = Sync-ReadOnlyWorktree -SourceRepo $Root -WorktreePath $evidenceWorktreePath -Ref 'origin/master'
    Write-Host $syncNote

    $branchName = "evidence/pilot-cadence-$runDate"
    Push-Location $evidenceWorktreePath
    try {
        $verifyResult = Invoke-CapturedCommand { & git rev-parse --verify $branchName }
        $branchExistsLocally = ($verifyResult.ExitCode -eq 0)

        if ($branchExistsLocally) {
            $checkoutResult = Invoke-CapturedCommand { & git checkout $branchName -q }
            if ($checkoutResult.ExitCode -eq 0) {
                $checkoutResult = Invoke-CapturedCommand { & git reset --hard origin/master -q }
            }
        } else {
            $checkoutResult = Invoke-CapturedCommand { & git checkout -b $branchName origin/master -q }
        }
        if ($checkoutResult.ExitCode -ne 0) {
            Write-Warning "Could not check out evidence branch $branchName -- $($checkoutResult.Text)"
        }

        $destDir = Join-Path $evidenceWorktreePath 'evidence\pilot-cadence'
        if (-not (Test-Path -LiteralPath $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $evidencePath -Destination (Join-Path $destDir "$runDate.json") -Force

        $addResult = Invoke-CapturedCommand { & git add "evidence/pilot-cadence/$runDate.json" }
        if ($addResult.ExitCode -ne 0) {
            Write-Warning "git add failed on $branchName -- $($addResult.Text)"
        }

        $commitMsg = "docs(pilot-cadence): evidence for $runDate ($overallStatus)"
        $commitResult = Invoke-CapturedCommand { & git commit -m $commitMsg -q }
        if ($commitResult.ExitCode -ne 0) {
            Write-Host "No new evidence changes to commit on $branchName (already up to date): $($commitResult.Text)"
        }

        $pushResult = Invoke-CapturedCommand { & git push -u origin $branchName -q }
        if ($pushResult.ExitCode -ne 0) {
            Write-Warning "git push failed for $branchName -- $($pushResult.Text)"
        }

        $prListResult = Invoke-CapturedCommand { & gh pr list --repo OgeonX-Ai/cas-workstation --head $branchName --json number,url }
        $existingPr = $null
        if ($prListResult.ExitCode -eq 0) {
            try { $existingPr = $prListResult.Text | ConvertFrom-Json } catch { $existingPr = $null }
        }

        if ($existingPr -and @($existingPr).Count -gt 0) {
            $prUrl = @($existingPr)[0].url
            Write-Host "Existing evidence PR: $prUrl"
        } else {
            $prTitle = "docs(pilot-cadence): evidence for $runDate"
            $prBody = "Automated pilot-cadence evidence, overall status: $overallStatus. See evidence/pilot-cadence/$runDate.json."
            $prCreateResult = Invoke-CapturedCommand { & gh pr create --repo OgeonX-Ai/cas-workstation --base master --head $branchName --title $prTitle --body $prBody }
            if ($prCreateResult.ExitCode -eq 0) {
                Write-Host "Evidence PR created: $($prCreateResult.Text)"
            } else {
                Write-Warning "gh pr create failed -- $($prCreateResult.Text)"
            }
        }
    } finally {
        Pop-Location
    }
}

Write-Host ''
Write-Host "Overall status: $overallStatus"
Write-Host "Evidence file: $evidencePath"

if ($overallStatus -eq 'passed') {
    exit 0
} else {
    exit 1
}
