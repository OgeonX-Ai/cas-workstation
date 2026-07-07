<#
.SYNOPSIS
  Workspace-health sweep for C:\PersonalRepo (REQ-1.4.12).
.DESCRIPTION
  Checks the root repo, every portfolio/* sub-repo, and gemini-nano for the
  drift classes found in the 2026-07-06 workspace-integrity survey:
    1. dirty working trees (untracked non-ignored files, modified tracked files)
    2. checkout not on the default branch
    3. unpushed commits (ahead of upstream) / no upstream configured
    4. gitlinks (mode 160000) with no .gitmodules entry
    5. worktrees with last commit older than -WorktreeStaleDays (default 14),
       including WSL-style /mnt/ worktree registrations and missing paths
    6. stale open PRs (age > 7 days) via `gh pr list`, per repo with a GitHub origin
    7. credential.helper configured with a WSL-style /mnt/ path
    8. stack.manifest.json tool version assertions (root only, via Cas.Workstation.psm1)
    9. non-ASCII characters in tracked .ps1 files (PS 5.1 ANSI parsing hazard)
    10. .refiner/blackboard.json is gitignored (see Task 34-01/1); this comment
        documents why it no longer appears as a false-positive dirty finding
    11. unclassified housekeeping directories (untracked and not gitignored)
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

# PS 5.1's default console output encoding is the legacy OEM codepage, which
# mangles UTF-8 bytes git writes for non-ASCII paths/branches/config values
# (e.g. a Windows user profile directory containing a non-ASCII character).
# Force UTF-8 decoding of native command output so those bytes round-trip
# correctly through Test-Path / string comparisons below.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
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

    # 6. Credential helper WSL-path normalization
    $helper = & git -C $repo.Path config --get credential.helper 2>$null
    if ($helper -match '/mnt/[a-z]/') {
        Add-Finding $repo.Name 'credential-helper-wsl-path' "credential.helper='$helper' uses WSL /mnt/ path; run 'git config credential.helper manager' to normalize to Windows Credential Manager"
    }
}

# 7. Stale open PRs (workspace-wide: needs gh + org context, not local git)
# $env:WH_SKIP_GH lets callers (e.g. offline Pester runs) skip this network-
# dependent check entirely without needing a real gh auth session.
if (-not $env:WH_SKIP_GH -and (Get-Command gh -ErrorAction SilentlyContinue)) {
    foreach ($repo in Get-Repos $Root) {
        try {
            $originUrl = & git -C $repo.Path remote get-url origin 2>$null
            if (-not $originUrl) { continue }
            if ($originUrl -notmatch 'github\.com[:/]([^/]+)/([^/.]+)(\.git)?$') { continue }
            $owner = $Matches[1]
            $name = $Matches[2]
            $prJson = & gh pr list --repo "$owner/$name" --state open --json number,createdAt --limit 100 2>$null
            if (-not $prJson) { continue }
            $prs = $prJson | ConvertFrom-Json
            foreach ($pr in @($prs)) {
                $createdAt = [DateTimeOffset]::Parse($pr.createdAt)
                $ageDays = [int]([DateTimeOffset]::UtcNow - $createdAt).TotalDays
                if ($ageDays -gt 7) {
                    Add-Finding $repo.Name 'stale-pr' "PR #$($pr.number) open $ageDays d (threshold 7d)"
                }
            }
        } catch {
            # gh auth failure, rate limit, or malformed JSON must not crash the sweep.
            continue
        }
    }
}

# 8. stack.manifest.json tool version assertions (root only, run once)
$rootRepo = (Get-Repos $Root) | Where-Object { $_.Name -eq 'root' } | Select-Object -First 1
if ($rootRepo) {
    try {
        $manifestPath = Join-Path $Root 'stack.manifest.json'
        if (Test-Path -LiteralPath $manifestPath) {
            Import-Module (Join-Path $Root 'scripts\Cas.Workstation.psm1') -Force -WarningAction SilentlyContinue
            $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
            foreach ($tool in @($manifest.tools)) {
                $status = Get-CasToolStatus -Tool $tool
                if ($status.status -ne 'installed') {
                    Add-Finding 'root' 'stack-manifest-version' "tool '$($tool.displayName)' status=$($status.status) (required >= $($tool.minimumVersion))"
                }
            }
        }
    } catch {
        # A broken manifest or module import must not crash the sweep.
    }
}

# 9. Non-ASCII .ps1 guard (workspace-wide, per repo)
foreach ($repo in Get-Repos $Root) {
    $psFiles = Get-ChildItem -Path $repo.Path -Filter *.ps1 -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\node_modules\\|\\bin\\|\\obj\\|\\.git\\' }
    $offenderCount = 0
    $firstOffender = $null
    foreach ($f in $psFiles) {
        try {
            $text = [System.IO.File]::ReadAllText($f.FullName)
        } catch {
            continue
        }
        $hasNonAscii = [bool]($text.ToCharArray() | Where-Object { [int]$_ -gt 126 } | Select-Object -First 1)
        if ($hasNonAscii) {
            $offenderCount++
            if (-not $firstOffender) { $firstOffender = $f.FullName }
        }
    }
    if ($offenderCount -gt 0) {
        Add-Finding $repo.Name 'non-ascii-ps1' "$firstOffender contains non-ASCII character(s) - PS 5.1 ANSI parsing hazard ($offenderCount file(s) affected)"
    }
}

# 10. .refiner/blackboard.json is gitignored (see Task 34-01/1); this comment
# documents why it no longer appears as a false-positive dirty finding.

# 11. Unclassified housekeeping directories (untracked and not gitignored)
foreach ($dirName in @('antigravity-export', 'evidence')) {
    $dirPath = Join-Path $Root $dirName
    if (-not (Test-Path -LiteralPath $dirPath)) { continue }
    & git -C $Root check-ignore -q $dirName 2>$null
    $isIgnored = $LASTEXITCODE -eq 0
    if ($isIgnored) { continue }
    $tracked = & git -C $Root ls-files $dirName 2>$null
    if (-not $tracked) {
        Add-Finding 'root' 'unclassified-housekeeping-dir' "'$dirName' exists, is untracked and not gitignored - classify as keep (add README + track) or archive/scratch (add to .gitignore)"
    }
}

if ($Json) {
    # JSON mode is the machine-readable contract (consumed by CI and Pester);
    # do not mix Write-Host summary lines into stdout alongside it, since
    # nested/redirected PowerShell hosts can fold Write-Host text into the
    # same captured stream and break downstream ConvertFrom-Json parsing.
    $findings | ConvertTo-Json -Depth 3
} else {
    if ($findings.Count -gt 0) {
        $findings | Format-Table -AutoSize | Out-String | Write-Host
        Write-Host ("workspace-health: {0} finding(s)." -f $findings.Count) -ForegroundColor Red
    } else {
        Write-Host "workspace-health: clean." -ForegroundColor Green
    }
}

if ($findings.Count -gt 0) {
    exit 1
}
exit 0
