<#
.SYNOPSIS
  Squash-aware content gate for a single local branch (REQ-1.5.2).
.DESCRIPTION
  Decides whether a local branch is safe to delete by comparing its CURRENT
  tree directly against the CURRENT tree of the repo's default branch on
  origin.

  WHY TWO-DOT, NOT THREE-DOT:
  A three-dot diff (`git diff A...B`) diffs from the merge-base of A and B to
  B. That is exactly the branch's own historical changes since it diverged --
  it says nothing about whether those changes have since landed on A via a
  squash-merge. A squash-merge creates a brand-new commit on the default
  branch whose tree matches the feature branch's tree, but whose history does
  NOT contain the feature branch's commits. Three-dot diff stays non-empty
  forever in that case (false "still has unmerged work" signal), because it
  never looks at A's current state past the merge-base.
  A two-dot diff (`git diff A B`) instead compares the two CURRENT trees
  directly, ignoring history entirely. If the squash-merge landed the same
  content, the two-dot diff is empty even though the three-dot diff is not.
  That is the squash-awareness contract this gate implements: content parity
  wins over history shape. Two-dot is used here, deliberately, INSTEAD of
  three-dot.

  Fail-closed: this script only ever deletes a branch when the two-dot diff
  is empty. A non-empty diff always means RETAIN, regardless of what the
  three-dot diff would have said.
.PARAMETER RepoPath
  Path to the local git repository containing the branch to evaluate.
.PARAMETER Branch
  Name of the local branch to evaluate.
.PARAMETER DeleteSafe
  Switch. When set AND the disposition is SAFE-TO-DELETE, the branch is
  deleted locally with `git branch -D`. Default is report-only (no deletion).
.PARAMETER Json
  Switch. Emit the result as JSON instead of a formatted table.
.EXAMPLE
  pwsh -File scripts/squash-aware-branch-gate.ps1 -RepoPath portfolio/autogen -Branch feat/phase-26-coverage-gates
.EXAMPLE
  pwsh -File scripts/squash-aware-branch-gate.ps1 -RepoPath portfolio/autogen -Branch feat/phase-26-coverage-gates -DeleteSafe -Json
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RepoPath,

    [Parameter(Mandatory = $true)]
    [string]$Branch,

    [switch]$DeleteSafe,

    [switch]$Json
)

$ErrorActionPreference = 'Continue'

function Resolve-WorkspaceTool([string]$CommandName, [string[]]$FallbackPaths = @()) {
    # Mirrors scripts/workspace-health.ps1's git.exe resolution helper.
    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($path in @($FallbackPaths)) {
        if ($path -and (Test-Path -LiteralPath $path)) {
            return $path
        }
    }

    return $null
}

$gitExe = Resolve-WorkspaceTool -CommandName 'git.exe' -FallbackPaths @(
    (Join-Path ${env:ProgramFiles} 'Git\cmd\git.exe'),
    (Join-Path ${env:ProgramFiles} 'Git\bin\git.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Git\cmd\git.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Git\bin\git.exe')
)

function New-GateResult {
    param(
        [string]$Repo,
        [string]$Branch,
        [string]$Default,
        [string]$Disposition,
        [string]$Evidence,
        [bool]$Deleted = $false
    )
    [pscustomobject]@{
        Repo        = $Repo
        Branch      = $Branch
        Default     = $Default
        Disposition = $Disposition
        Evidence    = $Evidence
        Deleted     = $Deleted
    }
}

function Write-GateResult {
    param($Result)
    if ($Json) {
        $Result | ConvertTo-Json -Depth 3
    } else {
        $Result | Format-Table -AutoSize | Out-String | Write-Host
    }
}

if (-not $gitExe) {
    $result = New-GateResult -Repo $RepoPath -Branch $Branch -Default $null -Disposition 'ERROR' -Evidence 'git.exe was not found in PATH or standard Git for Windows install locations.'
    Write-GateResult $result
    exit 1
}

if (-not (Test-Path -LiteralPath $RepoPath)) {
    $result = New-GateResult -Repo $RepoPath -Branch $Branch -Default $null -Disposition 'ERROR' -Evidence "RepoPath '$RepoPath' does not exist."
    Write-GateResult $result
    exit 1
}

# Fetch/prune so the origin/<default> tracking ref is current before comparing.
& $gitExe -C $RepoPath fetch --prune origin 2>$null | Out-Null

$defRef = (& $gitExe -C $RepoPath symbolic-ref refs/remotes/origin/HEAD --short 2>$null)
if (-not $defRef) {
    $result = New-GateResult -Repo $RepoPath -Branch $Branch -Default $null -Disposition 'ERROR' -Evidence 'Could not resolve refs/remotes/origin/HEAD (no default branch symref).'
    Write-GateResult $result
    exit 1
}
$default = $defRef -replace '^origin/', ''

$branchExists = & $gitExe -C $RepoPath rev-parse --verify --quiet "refs/heads/$Branch" 2>$null
if (-not $branchExists) {
    $result = New-GateResult -Repo $RepoPath -Branch $Branch -Default $default -Disposition 'ERROR' -Evidence "Local branch '$Branch' does not exist."
    Write-GateResult $result
    exit 1
}

# TWO-DOT direct tree compare -- see the comment block above the param() for
# why this is deliberately not `origin/<default>...<branch>` (three-dot).
$diffStat = & $gitExe -C $RepoPath diff --stat "origin/$default" "$Branch" 2>$null
$diffStatText = (@($diffStat) -join "`n").Trim()

$deleted = $false
if ([string]::IsNullOrWhiteSpace($diffStatText)) {
    $disposition = 'SAFE-TO-DELETE'
    $evidence = 'Empty two-dot tree diff: content already present on origin/' + $default + ' (squash-merge or no-op).'
    if ($DeleteSafe) {
        # Content parity already proven above; -D (not -d) is correct here
        # because git's normal --merged check would refuse a squash-merged
        # branch (no direct ancestor relationship in history), even though
        # the tree gate already proved the content is fully landed.
        & $gitExe -C $RepoPath branch -D $Branch 2>$null | Out-Null
        $stillExists = & $gitExe -C $RepoPath rev-parse --verify --quiet "refs/heads/$Branch" 2>$null
        $deleted = [string]::IsNullOrEmpty($stillExists)
    }
} else {
    $disposition = 'RETAIN'
    $evidence = $diffStatText
    # Fail-closed: never delete on a non-empty tree diff, regardless of
    # -DeleteSafe.
}

$result = New-GateResult -Repo $RepoPath -Branch $Branch -Default $default -Disposition $disposition -Evidence $evidence -Deleted $deleted
Write-GateResult $result

if ($disposition -eq 'ERROR') { exit 1 }
exit 0
