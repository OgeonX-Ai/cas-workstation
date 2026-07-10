<#
.SYNOPSIS
  Branch-protection-as-code for the CAS org repos and the root workspace repo.
.DESCRIPTION
  Applies GitHub branch protection to the default branch of each repo in
  -Repos: 1 required approving review, the 'automerge-eligibility' check
  (plus any extra required CI checks passed via -RequiredChecks) as required
  status checks, and enforce_admins honored.

  This is the SAME mechanism reused unchanged for:
    - Plan 38-01 (org sub-repos): -Owner Coding-Autopilot-System (default)
    - Plan 38-03 (root repo): -Owner OgeonX-Ai -Repos cas-workstation
  No bespoke root-repo logic -- one script, one payload shape, applied
  per-repo. Default branch is resolved live per repo via
  `gh api repos/{owner}/{repo} --jq .default_branch` (Promptimprover uses
  'master', most others use 'main' -- this script does not hardcode either).
.PARAMETER Repos
  Bare repo names (no owner prefix), e.g. autogen, cas-workstation.
.PARAMETER Owner
  GitHub org/user that owns the repos. Default: Coding-Autopilot-System.
.PARAMETER RequiredChecks
  Extra required status check contexts to add alongside
  'automerge-eligibility' (e.g. the repo's own CI workflow job name).
  Optional; defaults to none.
.PARAMETER SkipEligibilityCheck
  Do not require the 'automerge-eligibility' status check context. Use this
  for repos that do NOT have the review-bot/classifier workflow installed
  (e.g. the root repo OgeonX-Ai/cas-workstation, which is PR-flow-with-
  review only -- no review-bot App on that org, see docs/merge-flow-policy.md
  Root repo section). Without this switch, requiring a check context that no
  workflow ever reports would leave every PR permanently blocked.
.PARAMETER RequireCodeOwnerReviews
  Set required_pull_request_reviews.require_code_owner_reviews = true. Use
  this for repos that have a CODEOWNERS file whose assignment should be
  enforced (e.g. the root repo, see CODEOWNERS at the repo root). Defaults
  to false to preserve existing behavior for repos without one.
.PARAMETER DryRun
  Prints the exact protection payload per repo without calling the GitHub
  API PUT. Use this to review before applying for real.
.EXAMPLE
  pwsh -File apply-branch-protection.ps1 -DryRun -Repos autogen
  pwsh -File apply-branch-protection.ps1 -Repos org-dotgithub
  pwsh -File apply-branch-protection.ps1 -Owner OgeonX-Ai -Repos cas-workstation -SkipEligibilityCheck -RequireCodeOwnerReviews -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$Repos,

    [string]$Owner = 'Coding-Autopilot-System',

    [string[]]$RequiredChecks = @(),

    [switch]$SkipEligibilityCheck,

    [switch]$RequireCodeOwnerReviews,

    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

function Get-DefaultBranch {
    param([string]$OwnerName, [string]$RepoName)
    $branch = & gh api "repos/$OwnerName/$RepoName" --jq '.default_branch' 2>$null
    if (-not $branch) {
        throw "Unable to resolve default branch for $OwnerName/$RepoName via gh api (repo missing, no access, or gh not authenticated)."
    }
    return $branch.Trim()
}

function New-ProtectionPayload {
    param([string[]]$Contexts, [bool]$RequireCodeOwnerReviews = $false)
    return [ordered]@{
        required_status_checks        = [ordered]@{
            strict   = $true
            contexts = @($Contexts)
        }
        enforce_admins                 = $true
        required_pull_request_reviews  = [ordered]@{
            required_approving_review_count = 1
            dismiss_stale_reviews           = $false
            require_code_owner_reviews      = $RequireCodeOwnerReviews
        }
        restrictions                   = $null
        required_linear_history        = $false
        allow_force_pushes             = $false
        allow_deletions                = $false
    }
}

$results = @()
foreach ($repoName in $Repos) {
    $baseContexts = if ($SkipEligibilityCheck) { @() } else { @('automerge-eligibility') }
    $contexts = @($baseContexts) + @($RequiredChecks)
    $contexts = @($contexts | Select-Object -Unique)

    $defaultBranch = Get-DefaultBranch -OwnerName $Owner -RepoName $repoName
    $payload = New-ProtectionPayload -Contexts $contexts -RequireCodeOwnerReviews $RequireCodeOwnerReviews.IsPresent
    $payloadJson = $payload | ConvertTo-Json -Depth 6

    Write-Host ("Repo: {0}/{1}  Default branch: {2}" -f $Owner, $repoName, $defaultBranch)
    Write-Host $payloadJson

    if ($DryRun) {
        Write-Host ("DRY   would PUT repos/{0}/{1}/branches/{2}/protection" -f $Owner, $repoName, $defaultBranch) -ForegroundColor Yellow
        $results += [pscustomobject]@{ Repo = $repoName; Branch = $defaultBranch; Applied = $false }
        continue
    }

    $tmpFile = New-TemporaryFile
    try {
        $payloadJson | Out-File -FilePath $tmpFile.FullName -Encoding utf8
        & gh api -X PUT "repos/$Owner/$repoName/branches/$defaultBranch/protection" `
            -H "Accept: application/vnd.github+json" `
            --input $tmpFile.FullName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "gh api PUT failed for $Owner/$repoName (exit $LASTEXITCODE)"
        }
        Write-Host ("APPLIED protection to {0}/{1}@{2}" -f $Owner, $repoName, $defaultBranch) -ForegroundColor Green
        $results += [pscustomobject]@{ Repo = $repoName; Branch = $defaultBranch; Applied = $true }
    }
    finally {
        Remove-Item -LiteralPath $tmpFile.FullName -ErrorAction SilentlyContinue
    }
}

$results | Format-Table -AutoSize
exit 0
