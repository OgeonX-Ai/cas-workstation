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
    12. release staleness: latest SemVer tag is >30 days old with commits merged
        since it, or no SemVer tag exists at all (local git only, no gh dependency)
    13. multi-AI coordination lease (A2 - GLOBAL_AGENTS.md "Working-Tree Lease
        Protocol"): a .cas-lease.json past its ttl_hours ('stale-lease'), or a
        dirty working tree with no lease file at all ('unleased-dirty', advisory)
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
    [switch]$Json,
    [switch]$SkipStackManifestChecks,
    [switch]$RootOnly
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

function Resolve-WorkspaceTool([string]$CommandName, [string[]]$FallbackPaths = @()) {
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

function Get-Repos([string]$RootPath) {
    $repos = @([pscustomobject]@{ Name = 'root'; Path = $RootPath })
    if ($RootOnly) {
        return $repos
    }
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

function Get-TrackedPowerShellFiles([string]$RepoPath) {
    if (-not $gitExe) {
        return @()
    }

    $tracked = & $gitExe -C $RepoPath ls-files -- '*.ps1' 2>$null
    foreach ($relativePath in @($tracked)) {
        if (-not $relativePath) { continue }
        $fullPath = Join-Path $RepoPath $relativePath
        if ($fullPath -match '\\node_modules\\|\\bin\\|\\obj\\|\\.git\\') { continue }
        if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
            Get-Item -LiteralPath $fullPath -ErrorAction SilentlyContinue
        }
    }
}

foreach ($repo in Get-Repos $Root) {
    if (-not $gitExe) {
        Add-Finding $repo.Name 'git-missing' "git.exe was not found in PATH or standard Git for Windows install locations."
        continue
    }

    # 1. Dirty working tree
    $dirty = & $gitExe -C $repo.Path status --porcelain 2>$null
    if ($dirty) {
        Add-Finding $repo.Name 'dirty' ("{0} uncommitted change(s), e.g. {1}" -f @($dirty).Count, (@($dirty)[0].Trim()))
    }

    # 2. Current vs default branch
    $branch = (& $gitExe -C $repo.Path branch --show-current 2>$null)
    $defRef = (& $gitExe -C $repo.Path symbolic-ref refs/remotes/origin/HEAD --short 2>$null)
    $default = if ($defRef) { $defRef -replace '^origin/', '' } else { $null }
    if ($default -and $branch -and $branch -ne $default) {
        Add-Finding $repo.Name 'off-default-branch' "on '$branch', default is '$default'"
    }

    # 3. Unpushed commits
    if ($branch) {
        $upstream = (& $gitExe -C $repo.Path rev-parse --abbrev-ref "@{u}" 2>$null)
        if ($upstream) {
            $ahead = (& $gitExe -C $repo.Path rev-list --count "$upstream..HEAD" 2>$null)
            if ([int]$ahead -gt 0) {
                Add-Finding $repo.Name 'unpushed' "$ahead commit(s) ahead of $upstream"
            }
        } else {
            Add-Finding $repo.Name 'no-upstream' "branch '$branch' has no upstream - nothing is backed up"
        }
    }

    # 4. Gitlinks without .gitmodules coverage
    $gitlinks = (& $gitExe -C $repo.Path ls-files -s 2>$null) | Where-Object { $_ -match '^160000\s' }
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
    $wtBlocks = (& $gitExe -C $repo.Path worktree list --porcelain 2>$null) -join "`n" -split "`n`n"
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
        $last = (& $gitExe -C $wtPath log -1 --format=%ct 2>$null)
        if ($last) {
            $ageDays = [int](([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() - [long]$last) / 86400)
            if ($ageDays -gt $WorktreeStaleDays) {
                Add-Finding $repo.Name 'stale-worktree' "'$wtPath' last commit ${ageDays}d ago (threshold ${WorktreeStaleDays}d)"
            }
        }
    }

    # 6. Credential helper WSL-path normalization
    $helper = & $gitExe -C $repo.Path config --get credential.helper 2>$null
    if ($helper -match '/mnt/[a-z]/') {
        Add-Finding $repo.Name 'credential-helper-wsl-path' "credential.helper='$helper' uses WSL /mnt/ path; run 'git config credential.helper manager' to normalize to Windows Credential Manager"
    }

    # 13. Multi-AI coordination lease (A2 - GLOBAL_AGENTS.md "Working-Tree
    # Lease Protocol"): a lease past its ttl_hours is 'stale-lease' (may be
    # replaced); a dirty tree with no lease file at all is 'unleased-dirty'
    # (advisory only - not every writer in this workspace is an AI session
    # honoring the convention yet, so this must not become a hard blocker).
    $leasePath = Join-Path $repo.Path '.cas-lease.json'
    $hasLease = Test-Path -LiteralPath $leasePath -PathType Leaf
    if ($hasLease) {
        try {
            $lease = Get-Content -LiteralPath $leasePath -Raw | ConvertFrom-Json
            $leaseSince = [DateTimeOffset]::Parse($lease.since)
            $ttlHours = if ($lease.ttl_hours) { [double]$lease.ttl_hours } else { 4 }
            $ageHours = ([DateTimeOffset]::UtcNow - $leaseSince).TotalHours
            if ($ageHours -gt $ttlHours) {
                Add-Finding $repo.Name 'stale-lease' ("lease by '{0}/{1}' is {2:N1}h old (ttl {3}h) - may be replaced" -f $lease.agent, $lease.session, $ageHours, $ttlHours)
            }
        } catch {
            Add-Finding $repo.Name 'stale-lease' "'.cas-lease.json' exists but could not be parsed as a valid lease: $($_.Exception.Message)"
        }
    } elseif ($dirty) {
        Add-Finding $repo.Name 'unleased-dirty' "working tree has uncommitted changes but no '.cas-lease.json' - advisory: declare a lease before mutating (see GLOBAL_AGENTS.md Working-Tree Lease Protocol)"
    }
}

# 7. Stale open PRs (workspace-wide: needs gh + org context, not local git)
# $env:WH_SKIP_GH lets callers (e.g. offline Pester runs) skip this network-
# dependent check entirely without needing a real gh auth session.
if (-not $env:WH_SKIP_GH -and (Get-Command gh -ErrorAction SilentlyContinue)) {
    foreach ($repo in Get-Repos $Root) {
        try {
            if (-not $gitExe) { continue }
            $originUrl = & $gitExe -C $repo.Path remote get-url origin 2>$null
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
if ($rootRepo -and -not $SkipStackManifestChecks) {
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
    $psFiles = @(Get-TrackedPowerShellFiles -RepoPath $repo.Path)
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

# 12. Release staleness (local git only, no gh dependency)
foreach ($repo in Get-Repos $Root) {
    if (-not $gitExe) { continue }
    $tags = & $gitExe -C $repo.Path tag --list 'v[0-9]*.[0-9]*.[0-9]*' --sort=-version:refname 2>$null
    $latestTag = @($tags) | Where-Object { $_ } | Select-Object -First 1
    if (-not $latestTag) {
        $commitCount = (& $gitExe -C $repo.Path rev-list --count HEAD 2>$null)
        if ($commitCount -and [int]$commitCount -gt 0) {
            Add-Finding $repo.Name 'release-stale' "no SemVer release tag exists ($commitCount commit(s) on HEAD)"
        }
        continue
    }
    $tagEpoch = & $gitExe -C $repo.Path log -1 --format=%ct $latestTag 2>$null
    if (-not $tagEpoch) { continue }
    $ageDays = [int](([DateTimeOffset]::UtcNow.ToUnixTimeSeconds() - [long]$tagEpoch) / 86400)
    $sinceCount = (& $gitExe -C $repo.Path rev-list --count "$latestTag..HEAD" 2>$null)
    if ($ageDays -gt 30 -and $sinceCount -and [int]$sinceCount -gt 0) {
        Add-Finding $repo.Name 'release-stale' "'$latestTag' is ${ageDays}d old (threshold 30d) with $sinceCount commit(s) merged since"
    }
}

# 10. .refiner/blackboard.json is gitignored (see Task 34-01/1); this comment
# documents why it no longer appears as a false-positive dirty finding.

# 11. Unclassified housekeeping directories (untracked and not gitignored)
foreach ($dirName in @('antigravity-export', 'evidence')) {
    $dirPath = Join-Path $Root $dirName
    if (-not (Test-Path -LiteralPath $dirPath)) { continue }
    if (-not $gitExe) {
        Add-Finding 'root' 'git-missing' "git.exe was not found in PATH or standard Git for Windows install locations."
        break
    }
    & $gitExe -C $Root check-ignore -q $dirName 2>$null
    $isIgnored = $LASTEXITCODE -eq 0
    if ($isIgnored) { continue }
    $tracked = & $gitExe -C $Root ls-files $dirName 2>$null
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
