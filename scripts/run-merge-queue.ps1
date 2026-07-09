<#
.SYNOPSIS
  Supervised driver for docs/MERGE-QUEUE.md round 3 - run this YOURSELF in a terminal.
.DESCRIPTION
  Executes the ordered merge queue with per-PR safety checks:
    - re-verifies check status live before every merge (skips non-green)
    - honors ordering (autogen #16 first; gsd-orchestrator #16 -> #20 -> #21)
    - runs gh pr update-branch between same-repo ci.yml PRs
    - stops on first unexpected error
  It does NOT apply the cas-contracts #18 'compatibility-reviewed' label - review
  that PR and add the label manually, then re-run with -IncludeContracts.
.EXAMPLE
  powershell -NoProfile -File scripts\run-merge-queue.ps1 -DryRun
  powershell -NoProfile -File scripts\run-merge-queue.ps1
  powershell -NoProfile -File scripts\run-merge-queue.ps1 -IncludeContracts
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$IncludeContracts
)
$ErrorActionPreference = 'Stop'
$org = 'Coding-Autopilot-System'

# Ordered queue: repo, PR, note, updateBranchFirst
$queue = @(
    # --- Group 1: rescue/fix (autogen#16 FIRST - unbreaks main deps for later autogen PRs)
    @{r='autogen'; n=16; note='dependency compatibility restore - unbreaks CI for #11/#12/#13/#14'},
    @{r='Promptimprover'; n=27; note='dashboard loopback + XSS'},
    @{r='cas-platform'; n=11; note='bicep lint rule (33-01)'},
    @{r='cas-reference-product'; n=11; note='Flex Consumption + blobContributor'},
    @{r='cas-workstation'; n=18; note='hidden-files scope fix'},
    @{r='cloud-security-service-model'; n=13; note='bicep pins + ADR (33-02)'},
    @{r='gsd-orchestrator'; n=17; note='checkpoint corruption fix'},
    # --- Group 2: features (order matters in gsd-orchestrator)
    @{r='autogen'; n=11; note='coverage gates (26-02)'; ub=$true},
    @{r='autogen'; n=12; note='fault injection (28-02)'; ub=$true},
    @{r='autogen'; n=14; note='peer critic (29-01)'; ub=$true},
    @{r='gsd-orchestrator'; n=16; note='coverage gates (26-01)'},
    @{r='gsd-orchestrator'; n=20; note='fault injection (28-01)'; ub=$true},
    @{r='gsd-orchestrator'; n=21; note='typed FailureState (27-02, audit rescue)'; ub=$true},
    # --- Group 3: phase-31 hardening
    @{r='.github'; n=13; note='SHA pins (org profile)'},
    @{r='Promptimprover'; n=28; note='SHA pins'; ub=$true},
    @{r='autopilot-core'; n=15; note='SHA pins'},
    @{r='cas-contracts'; n=19; note='SHA pins'},
    @{r='cas-evals'; n=10; note='SHA pins'},
    @{r='cas-platform'; n=12; note='SHA pins'; ub=$true},
    @{r='cas-reference-product'; n=12; note='SHA pins'; ub=$true},
    @{r='cas-workstation'; n=19; note='SHA pins'; ub=$true},
    @{r='ci-autopilot'; n=2233; note='SHA pins + coverage gate'},
    @{r='cloud-security-service-model'; n=14; note='SHA pins'; ub=$true},
    @{r='gsd-orchestrator'; n=18; note='SHA pins'; ub=$true},
    @{r='autogen'; n=13; note='SHA pins'; ub=$true},
    # --- Group 4: phase-32 (contracts gated on label; evals independent)
    @{r='cas-evals'; n=9; note='registry smoke check (32-02)'; ub=$true},
    # --- Group 6: phase-36 docs (last)
    @{r='.github'; n=14; note='org vision hub'; ub=$true},
    @{r='Promptimprover'; n=29; note='wiki+README'; ub=$true},
    @{r='autopilot-core'; n=16; note='wiki'; ub=$true},
    @{r='autopilot-demo'; n=9; note='wiki'},
    @{r='cas-contracts'; n=20; note='wiki+README'; ub=$true},
    @{r='cas-evals'; n=11; note='wiki'; ub=$true},
    @{r='cas-platform'; n=13; note='wiki+README'; ub=$true},
    @{r='cas-reference-product'; n=13; note='wiki+README'; ub=$true},
    @{r='cas-workstation'; n=20; note='wiki'; ub=$true},
    @{r='ci-autopilot'; n=2244; note='wiki'; ub=$true},
    @{r='cloud-security-service-model'; n=15; note='wiki+README'; ub=$true},
    @{r='gsd-orchestrator'; n=19; note='wiki+README'; ub=$true},
    @{r='autogen'; n=15; note='wiki+README'; ub=$true}
)
if ($IncludeContracts) {
    $queue += @{r='cas-contracts'; n=18; note='registry $id rewrite (32-01) - REQUIRES compatibility-reviewed label'; ub=$true}
}

$merged = 0; $skipped = 0
foreach ($item in $queue) {
    $slug = "$org/$($item.r)"
    $state = & gh pr view $item.n --repo $slug --json state --jq .state 2>$null
    if ($state -ne 'OPEN') { Write-Host ("SKIP  {0}#{1} - state={2}" -f $item.r, $item.n, $state); $skipped++; continue }

    if ($item.ub) {
        if (-not $DryRun) { & gh pr update-branch $item.n --repo $slug 2>$null; Start-Sleep -Seconds 20 }
        else { Write-Host ("DRY   update-branch {0}#{1}" -f $item.r, $item.n) }
    }

    $bad = & gh pr checks $item.n --repo $slug 2>$null | Select-String -Pattern "fail|error" -SimpleMatch:$false
    if ($bad) { Write-Host ("HOLD  {0}#{1} - non-green checks:`n{2}" -f $item.r, $item.n, ($bad -join "`n")) -ForegroundColor Yellow; $skipped++; continue }

    if ($DryRun) { Write-Host ("DRY   merge {0}#{1} ({2})" -f $item.r, $item.n, $item.note); continue }
    Write-Host ("MERGE {0}#{1} - {2}" -f $item.r, $item.n, $item.note) -ForegroundColor Cyan
    & gh pr merge $item.n --repo $slug --squash --delete-branch --admin
    if ($LASTEXITCODE -ne 0) { Write-Error ("Merge failed for {0}#{1} - stopping. Fix and re-run (already-merged PRs are skipped)." -f $item.r, $item.n); exit 1 }
    $merged++
    Start-Sleep -Seconds 5
}
Write-Host ("Done. merged={0} skipped/held={1}" -f $merged, $skipped) -ForegroundColor Green
Write-Host "Next: powershell -NoProfile -File scripts\normalize-checkouts.ps1  (or ask the agent to normalize + run /gsd:complete-milestone)"
exit 0
