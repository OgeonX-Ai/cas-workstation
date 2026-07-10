<#
.SYNOPSIS
  Dedupe-guarded regression issue filer for scripts\run-pilot-cadence.ps1
  (REQ-1.5.4 / Phase 40-01, T-40-03 mitigation).
.DESCRIPTION
  Files (or comments on an existing) GitHub issue for a single non-green
  pilot-cadence suite. The issue title has no date component, so repeat
  searches always match the same string regardless of which day the
  regression first fired: "pilot-cadence: {SuiteId} regression".

  Performs an exact-title dedupe check via `gh issue list --search` before
  creating: gh's search endpoint does substring/token matching rather than
  exact match, so results are filtered client-side to an exact title match
  to avoid false-positive dedupes against unrelated issues that happen to
  share words. A match produces a comment instead of a second issue -- one
  issue max per suite per open-regression window.

  Never throws on a gh call failing for a reason other than a missing label
  (e.g. transient network error): a failed issue-file must not be allowed to
  mask the fact that a regression was already correctly detected and already
  lives in the evidence JSON and the redacted log -- the evidence JSON is the
  source of truth regardless of whether this side-effect succeeds.
.EXAMPLE
  powershell -NoProfile -File scripts\file-pilot-regression-issue.ps1 `
    -Repo Coding-Autopilot-System/gsd-orchestrator -SuiteId gsd-orchestrator-fault-injection `
    -FailureExcerpt "...redacted tail..." -RunDate 2026-07-10
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Repo,
    [Parameter(Mandatory = $true)][string]$SuiteId,
    [Parameter(Mandatory = $true)][string]$FailureExcerpt,
    [Parameter(Mandatory = $true)][string]$RunDate
)

$ErrorActionPreference = 'Stop'

function Invoke-CapturedCommand {
    <#
    Runs a native command, capturing combined stdout+stderr as a single text
    blob via $LASTEXITCODE, without letting Windows PowerShell 5.1's native-
    command stderr behavior promote stderr lines into terminating errors
    under $ErrorActionPreference = 'Stop'.
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

$Title = "pilot-cadence: $SuiteId regression"
$result = [pscustomobject]@{
    SuiteId  = $SuiteId
    IssueUrl = $null
    Deduped  = $false
}

try {
    # Note: the search query intentionally omits wrapping the title in literal
    # embedded double-quote characters (e.g. "in:title `"$Title`""). Windows
    # PowerShell 5.1's native-argument marshalling corrupts arguments that
    # contain embedded `"` characters when invoking gh.exe, splitting the
    # quoted phrase into separate unrecognized arguments and making the dedupe
    # search fail closed on every call. Passing the raw phrase is safe because
    # the results are already filtered client-side to an exact title match
    # below, so GitHub's substring/token search does not need query-side exact
    # phrasing.
    $listResult = Invoke-CapturedCommand {
        & gh issue list --repo $Repo --state open --search "in:title $Title" --json number,title,url
    }

    $existingIssue = $null
    if ($listResult.ExitCode -eq 0) {
        try {
            $candidates = @($listResult.Text | ConvertFrom-Json)
            # gh's search endpoint does substring/token matching, not exact
            # match -- filter client-side to an exact title match so this
            # never dedupes against an unrelated issue that merely shares
            # words with the stable title.
            $existingIssue = $candidates | Where-Object { $_.title -eq $Title } | Select-Object -First 1
        } catch {
            $existingIssue = $null
        }
    } else {
        Write-Warning "gh issue list failed for $Repo -- $($listResult.Text)"
    }

    if ($existingIssue) {
        $commentBody = "pilot-cadence: regression recurred on $RunDate.`n`n``````text`n$FailureExcerpt`n``````"
        $commentResult = Invoke-CapturedCommand {
            & gh issue comment $existingIssue.number --repo $Repo --body $commentBody
        }
        if ($commentResult.ExitCode -eq 0) {
            $result.IssueUrl = $existingIssue.url
            $result.Deduped = $true
            Write-Host "deduped: commented on #$($existingIssue.number)"
        } else {
            Write-Warning "gh issue comment failed on #$($existingIssue.number) for $Repo -- $($commentResult.Text)"
            $result.IssueUrl = $existingIssue.url
            $result.Deduped = $true
        }
    } else {
        $issueBody = "Suite: $SuiteId`nRun date: $RunDate`n`n``````text`n$FailureExcerpt`n``````"
        $createResult = Invoke-CapturedCommand {
            & gh issue create --repo $Repo --title $Title --body $issueBody --label 'pilot-cadence,regression'
        }
        if ($createResult.ExitCode -ne 0) {
            # Retry once without --label in case either label does not exist
            # in the target repo -- a missing label must not fail the whole run.
            $createResult = Invoke-CapturedCommand {
                & gh issue create --repo $Repo --title $Title --body $issueBody
            }
        }
        if ($createResult.ExitCode -eq 0) {
            $result.IssueUrl = $createResult.Text.Trim()
            $result.Deduped = $false
            Write-Host "filed: $($result.IssueUrl)"
        } else {
            Write-Warning "gh issue create failed for $Repo -- $($createResult.Text)"
        }
    }
} catch {
    Write-Warning "file-pilot-regression-issue.ps1 encountered an unexpected error for suite $SuiteId on $Repo -- $($_.Exception.Message)"
}

return $result
