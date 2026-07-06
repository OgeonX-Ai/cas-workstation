<#
.SYNOPSIS
  Workspace-health sweep for C:\PersonalRepo (REQ-1.4.12).
.DESCRIPTION
  Checks the root repo, every portfolio/* sub-repo, and gemini-nano for the
  drift classes found in the 2026-07-06 workspace-integrity survey:
    - dirty working trees (untracked non-ignored files, modified tracked files)
    - unpushed commits (ahead of upstream)
    - checkout not on the default branch
    - gitlinks (mode 160000) with no .gitmodules entry
    - worktrees with last commit older than -WorktreeStaleDays (default 14)
  Emits a findings table and exits non-zero when anything is found, so it can
  gate CI and run under Task Scheduler.
.EXAMPLE
  pwsh -File scripts\workspace-health.ps1
  pwsh -File scripts\workspace-health.ps1 -Root C:\PersonalRepo -WorktreeStaleDays 7
#>
[CmdletBinding()]
param(
    [string]$Root = "C:\PersonalRepo",
    [int]$WorktreeStaleDays = 14,
    [switch]$Json
)

# 'Continue' on purpose: git writes advisory output to stderr and PS 5.1 wraps
# native stderr in ErrorRecords; a sweep must survive broken repos, not die on them.
$ErrorActionPreference = 'Continue'
$findings = New-Object System.Collections.Generic.List[object]

function Add-Finding([string]$Repo, [string]$Check, [string]$Detail) {
    $findings.Add([pscustomobject]@{ Repo = $Repo; Check = $Check; Detail = $Detail })
}

function Get-Repos([string]$RootPath) {
    $repos = @([pscustomobject]@{ Name = 'root'; Path = $RootPath })
    foreach ($d in Get-ChildItem -Directory (Join-Path $RootPath 'portfolio') -ErrorAction SilentlyContinue) {
        if (Test-Path (Join-Path $d.FullName '.git')) {
            $repos += [pscustomobject]@{ Name = "portfolio/$($d.Name)"; Path = $d.FullName }
        }
    }
    $gn = Join-Path $RootPath 'gemini-nano'
    if (Test-Path (Join-Path $gn '.git')) {
        $repos += [pscustomobject]@{ Name = 'gemini-nano'; Path = $gn }
    }
    return $repos
}

foreach ($repo in Get-Repos $Root) {
    $g = { param([string[]]$GitArgs) & git -C $repo.Path @GitArgs 2>$null }

    # 1. Dirty working tree
    $dirty = & git -C $repo.Path status --porcelain 2>$null
    if ($dirty) {
        Add-Finding $repo.Name 'dirty' ("{0} uncommitted change(s), e.g. {1}" -f @($dirty).Count, (@($dirty)[0].Trim()))
    }

    # 2. Current vs default branch
    $branch = (& git -C $repo.Path branch --show-current 2>$null)
    $defRef = (& git -C $repo.Path symbolic-ref refs/remotes/origin/HEAD --short 2>$null)
    $default = if ($defRef) { $defRef -replace '^origin/', '' } else { $null }
    if ($default -and $branch -and $branch -ne $default) {
        Add-Finding $repo.Name 'off-default-branch' "on '$branch', default is '$default'"
    }

    # 3. Unpushed commits
    if ($branch) {
        $upstream = (& git -C $repo.Path rev-parse --abbrev-ref "@{u}" 2>$null)
        if ($upstream) {
            $ahead = (& git -C $repo.Path rev-list --count "$upstream..HEAD" 2>$null)
            if ([int]$ahead -gt 0) {
                Add-Finding $repo.Name 'unpushed' "$ahead commit(s) ahead of $upstream"
            }
        } else {
            Add-Finding $repo.Name 'no-upstream' "branch '$branch' has no upstream - nothing is backed up"
        }
    }

    # 4. Gitlinks without .gitmodules coverage
    $gitlinks = (& git -C $repo.Path ls-files -s 2>$null) | Where-Object { $_ -match '^160000\s' }
    foreach ($gl in $gitlinks) {
        $glPath = ($gl -split "`t")[-1]
        $inModules = $false
        $gmFile = Join-Path $repo.Path '.gitmodules'
        if (Test-Path $gmFile) {
            $inModules = [bool](Select-String -Path $gmFile -Pattern ("path\s*=\s*{0}\s*$" -f [regex]::Escape($glPath)) -Quiet)
        }
        if (-not $inModules) {
            Add-Finding $repo.Name 'gitlink-no-gitmodules' "gitlink '$glPath' has no .gitmodules entry - unrecoverable on fresh clone"
        }
    }

    # 5. Stale worktrees registered to this repo
    $wtBlocks = (& git -C $repo.Path worktree list --porcelain 2>$null) -join "`n" -split "`n`n"
    foreach ($block in $wtBlocks) {
        if ($block -notmatch 'worktree (.+)') { continue }
        $wtPath = $Matches[1].Trim()
        if ($wtPath -match '^/mnt/([a-z])/(.*)$') {
            # Unix-style registration violates the Windows-first path rule and breaks git on Windows.
            Add-Finding $repo.Name 'worktree-unix-path' "'$wtPath' registered with WSL /mnt/ path; run 'git worktree repair' or remove it"
            $wtPath = "$(($Matches[1]).ToUpper()):\$($Matches[2] -replace '/', '\')"
        }
        if (-not (Test-Path -LiteralPath $wtPath)) {
            Add-Finding $repo.Name 'worktree-missing' "registered worktree path '$wtPath' does not exist - run 'git worktree prune'"
            continue
        }
        if ((Resolve-Path -LiteralPath $wtPath -ErrorAction SilentlyContinue).Path -eq (Resolve-Path $repo.Path).Path) { continue }
        $last = (& git -C $wtPath log -1 --format=%ct 2>$null)
        if ($last) {
            $ageDays = [int](([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() - [long]$last) / 86400)
            if ($ageDays -gt $WorktreeStaleDays) {
                Add-Finding $repo.Name 'stale-worktree' "'$wtPath' last commit ${ageDays}d ago (threshold ${WorktreeStaleDays}d)"
            }
        }
    }
}

if ($Json) {
    $findings | ConvertTo-Json -Depth 3
} elseif ($findings.Count -gt 0) {
    $findings | Format-Table -AutoSize | Out-String | Write-Host
}

if ($findings.Count -gt 0) {
    Write-Host ("workspace-health: {0} finding(s)." -f $findings.Count) -ForegroundColor Red
    exit 1
}
Write-Host "workspace-health: clean." -ForegroundColor Green
exit 0
