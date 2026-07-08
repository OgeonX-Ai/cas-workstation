<#
.SYNOPSIS
  Commit-integrity heuristic check (REQ-1.4.13 / Phase 34-02).
.DESCRIPTION
  Catches the "untruthful commit" failure class typified by commit b4e0868
  (message "test: add full coverage suites for gsd-orchestrator and autogen",
  diff touching only .planning/*.md and engineering-os/*.md -- zero actual
  test files).

  Heuristic: for every commit in the given range whose Conventional Commit
  type prefix is literally "test" (optionally scoped, e.g. "test(phase34):"),
  the commit's changed paths must include at least one path matching a
  test-pattern regex. Commits of any other type are exempt (no check
  applies).

  This is a heuristic, not a semantic verifier -- it can be gamed by
  touching an unrelated file matching a test-pattern path without adding a
  real test. See 34-02-PLAN.md threat_model (T-34-08, accepted).
.EXAMPLE
  pwsh -File scripts\commit-integrity-check.ps1
  pwsh -File scripts\commit-integrity-check.ps1 -Range 'HEAD~5..HEAD'
#>
[CmdletBinding()]
param(
    [string]$Range = 'HEAD~1..HEAD',
    [string]$Path = (Get-Location).Path
)

# 'Continue' on purpose: git writes advisory output to stderr and PS 5.1 wraps
# native stderr in ErrorRecords; this check must survive broken repos/ranges,
# not die on them.
$ErrorActionPreference = 'Continue'

# Same PS 5.1 OEM-codepage hazard addressed in workspace-health.ps1: force
# UTF-8 decoding of native command output so non-ASCII paths/messages
# round-trip correctly.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Only commits whose Conventional Commit type prefix is literally "test"
# (case-sensitive), optionally scoped (e.g. "test(phase34):"), are subject
# to this check. All other types are exempt.
$script:TestTypeRegex = '^(\w+)(\([^)]*\))?:'

# A changed path "counts" as a test path if it matches any of these
# patterns. Kept in one alternation so a single -match call suffices.
$script:TestPathRegex = '(\.Tests\.ps1$)|(^tests?/)|(test_.*\.py$)|(\.test\.[jt]sx?$)|(_test\.go$)|(Test[A-Z]\w*\.(cs|java)$)'

function Test-CommitIntegrity {
    <#
    .SYNOPSIS
      Returns an array of violation objects for test:-typed commits in
      $Range (evaluated against the repo at $Path) whose diff touches zero
      test-pattern paths. Empty array if the range is clean.
    #>
    [CmdletBinding()]
    param(
        [string]$Range = 'HEAD~1..HEAD',
        [string]$Path = (Get-Location).Path
    )

    $violations = New-Object System.Collections.Generic.List[object]

    $logLines = & git -C $Path log --format='%H%x00%s' $Range 2>$null
    if (-not $logLines) {
        # Comma operator: prevent PS 5.1 pipeline unrolling so callers always
        # receive a real array whose .Count works under Set-StrictMode.
        return ,$violations.ToArray()
    }

    foreach ($line in @($logLines)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $parts = $line -split [char]0x00, 2
        if ($parts.Count -lt 2) { continue }
        $hash = $parts[0]
        $subject = $parts[1]

        $match = [regex]::Match($subject, $script:TestTypeRegex)
        if (-not $match.Success) { continue }
        # Case-sensitive comparison: only the literal word "test" triggers
        # this check (e.g. "testify:" or "Test:" do not match).
        if ($match.Groups[1].Value -cne 'test') { continue }

        $changedRaw = & git -C $Path show --name-only --format= $hash 2>$null
        $changedPaths = @($changedRaw | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

        $touchesTestPath = [bool]($changedPaths | Where-Object { $_ -match $script:TestPathRegex } | Select-Object -First 1)

        if (-not $touchesTestPath) {
            $shortHash = (& git -C $Path rev-parse --short $hash 2>$null)
            if ([string]::IsNullOrWhiteSpace($shortHash)) { $shortHash = $hash.Substring(0, [Math]::Min(7, $hash.Length)) }
            $pathsForReport = if ($changedPaths.Count -gt 0) { $changedPaths -join ', ' } else { '(no changes)' }
            $violations.Add([pscustomobject]@{
                Hash         = $shortHash
                Subject      = $subject
                ChangedPaths = $pathsForReport
            })
        }
    }

    return ,$violations.ToArray()
}

# CLI entry point. Guarded so this file can be dot-sourced (e.g. by Pester,
# to get Test-CommitIntegrity in scope without invoking the CLI wrapper)
# as well as run directly via `pwsh -File`.
if ($MyInvocation.InvocationName -ne '.') {
    $violations = Test-CommitIntegrity -Range $Range -Path $Path
    if ($violations.Count -gt 0) {
        $violations | Format-Table -AutoSize | Out-String | Write-Host
        Write-Host ("commit-integrity: {0} violation(s)." -f $violations.Count) -ForegroundColor Red
        exit 1
    } else {
        Write-Host "commit-integrity: clean." -ForegroundColor Green
        exit 0
    }
}
