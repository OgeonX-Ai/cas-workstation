---
phase: 38-merge-flow-and-backfill
plan: 02
subsystem: infra
tags: [git, pester, powershell, worktree-hygiene, branch-hygiene, squash-merge]

# Dependency graph
requires:
  - phase: 35-v1.4-verification-and-audit
    provides: 35-normalization-report.md (the 6 "conservatively kept" branches this plan re-evaluates, and the 2 worktree leftovers this plan dispositions)
provides:
  - "scripts/squash-aware-branch-gate.ps1 -- reusable fail-closed squash-aware branch content gate"
  - "scripts/tests/squash-aware-branch-gate.Tests.ps1 -- Pester proof of squash-awareness and fail-closed behavior"
  - ".planning/phases/38-merge-flow-and-backfill/38-backfill-disposition-report.md -- final disposition of the 6 kept branches + 2 worktree leftovers"
affects: [merge-flow-and-backfill, workspace-health, branch-hygiene]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Two-dot direct tree compare (git diff origin/<default> <branch>) instead of three-dot merge-base diff, to correctly read squash-merged branches as content-parity even when their commit history never rejoins default."
    - "Fail-closed disposition gate: script only deletes on an empty two-dot diff; any non-empty diff is RETAIN regardless of -DeleteSafe."
    - "Content-uniqueness probe (git hash-object + git log --all --find-object) for dispositioning an unregistered stray directory that mirrors a real repo's structure, when normal git worktree guards are a no-op (no .git present)."

key-files:
  created:
    - scripts/squash-aware-branch-gate.ps1
    - scripts/tests/squash-aware-branch-gate.Tests.ps1
    - .planning/phases/38-merge-flow-and-backfill/38-backfill-disposition-report.md
  modified: []

key-decisions:
  - "All 6 conservatively-kept branches evaluated RETAIN (0 SAFE-TO-DELETE) -- their tree diffs against current origin/main are non-empty, but every corresponding PR is MERGED, so each is flagged as possible post-merge drift (main advanced with unrelated docs/workflow/loop-coordinator changes after each squash-merge landed) rather than genuine unmerged work. Left in place per fail-closed contract; deletion deferred to an operator follow-up, not auto-resolved here."
  - "pr-maf-workers is not a registered git worktree (no .git, absent from both root and autogen worktree lists) -- disposition it via a content-uniqueness probe instead of git worktree guards, per the plan's corrected Task 3 instructions."
  - "pr-maf-workers moved (never deleted) to scratch/orphaned-worktrees/pr-maf-workers/ after a full 66-file probe found 62 files with matching blobs in autogen's history and the remaining 4 (AGENTS.md + 3 context.md files) already present, unchanged or superseded, in autogen's live working tree -- no unique content anywhere."
  - "v1.1-cas-contracts removed directly (not via git worktree remove) because its gitdir was already gone from cas-contracts/.git/worktrees/ -- pure orphaned residue with no readable HEAD, nothing recoverable."

patterns-established:
  - "Squash-aware branch gate pattern: for hygiene sweeps involving squash-merge workflows, use direct two-dot tree comparison against the resolved default branch, never three-dot merge-base diff, and treat empty-diff as the only safe-to-delete signal."
  - "Unregistered-worktree-lookalike disposition pattern: when a directory mirrors a real repo's file structure but has no .git, use blob-hash content-uniqueness probing (git hash-object + --find-object --all) against the real repo's history before deciding to move/delete; move-not-delete when a filesystem operation could fail partway (e.g. locked/unlinkable files under a nested .venv)."

requirements-completed: [REQ-1.5.2]

# Metrics
duration: ~40min
completed: 2026-07-10
---

# Phase 38 Plan 02: Squash-Aware Branch Gate + Residual Dispositions Summary

**Built a fail-closed, squash-aware branch-content gate (two-dot tree compare, not three-dot) plus Pester proof, then used it to re-evaluate the 6 branches Phase 35 conservatively kept and safely disposition the 2 worktree leftovers -- 0 branches deleted (all 6 flagged as post-merge drift on already-merged PRs), v1.1-cas-contracts pruned/removed, and the unregistered pr-maf-workers sandbox copy moved to scratch/ after a full content-uniqueness probe found nothing unique.**

## Performance

- **Duration:** ~40 min
- **Completed:** 2026-07-10T10:16:22Z
- **Tasks:** 3/3 completed
- **Files modified:** 3 created (script, test, report); 2 worktree-leftover directories dispositioned outside the worktree diff (removal + move, not tracked file changes)

## Accomplishments
- `scripts/squash-aware-branch-gate.ps1`: reusable, ASCII-only, fail-closed gate that resolves the default branch per-repo via `symbolic-ref refs/remotes/origin/HEAD`, does a two-dot `git diff --stat origin/<default> <branch>`, and only deletes (`branch -D`) on an empty diff.
- `scripts/tests/squash-aware-branch-gate.Tests.ps1`: 5 Pester tests (all green) proving squash-merge SAFE-TO-DELETE, the three-dot-vs-two-dot divergence contract (three-dot non-empty, two-dot empty -> gate uses two-dot), RETAIN with evidence for a genuinely diverged branch, actual deletion on `-DeleteSafe` for SAFE-TO-DELETE, and fail-closed non-deletion on `-DeleteSafe` for RETAIN.
- Ran the gate against all 6 conservatively-kept branches from Phase 35 with `-DeleteSafe`: all 6 returned RETAIN; cross-referenced each with `gh pr view --json state` and found all 6 corresponding PRs MERGED, so each is documented as a post-merge-drift flag rather than unresolved work.
- `v1.1-cas-contracts`: confirmed orphaned (gitdir already gone from cas-contracts' `.git/worktrees/`), pruned (no-op), directory removed, re-pruned both repos clean.
- `pr-maf-workers`: confirmed not a registered git worktree; ran a full content-uniqueness probe across all 66 non-`.venv` files against autogen's entire git history (`--find-object --all`); found no unique content; moved the whole directory (including `.venv/`) to `scratch/orphaned-worktrees/pr-maf-workers/` in one operation with no unlinkable-file failure.
- `workspace-health.ps1` sweep confirms `stale-worktree`/`worktree-missing`/`worktree-unix-path` clean for `root` and `portfolio/cas-contracts`.

## Task Commits

Each task was committed atomically on `feat/phase-38-hygiene-backfill` (isolated worktree at `C:/PersonalRepo/worktrees/phase-38-hygiene-backfill`, off `origin/master`):

1. **Task 1: Build the squash-aware branch gate (fail-closed) + tests** - `47b9137` (feat)
2. **Task 2: Apply the gate to the 6 kept branches + write disposition report** - `fa743fb` (feat)
3. **Task 3: Disposition the 2 worktree leftovers with an unpushed-commit guard** - `815cebe` (feat)

_No metadata commit yet -- this SUMMARY.md and STATE.md/ROADMAP.md updates land as the final commit below._

## Files Created/Modified
- `scripts/squash-aware-branch-gate.ps1` - Reusable fail-closed squash-aware branch content gate (two-dot tree compare)
- `scripts/tests/squash-aware-branch-gate.Tests.ps1` - Pester suite proving squash-awareness and fail-closed behavior (5/5 green)
- `.planning/phases/38-merge-flow-and-backfill/38-backfill-disposition-report.md` - Full disposition record: 6 branches (all RETAIN, drift-flagged) + 2 worktree leftovers (removed / moved)

**Outside the worktree diff (sub-repo and filesystem operations, per the plan's rules -- these are not root-repo tracked-file changes):**
- `C:/PersonalRepo/worktrees/v1.1-cas-contracts` - removed (orphaned, gitdir already gone)
- `C:/PersonalRepo/worktrees/pr-maf-workers` -> `C:/PersonalRepo/scratch/orphaned-worktrees/pr-maf-workers/` - moved (unregistered stray sandbox copy, no unique content)
- No files were modified inside any of the 6 sub-repos (`portfolio/autogen`, `portfolio/cas-evals`, `portfolio/cas-platform`, `portfolio/cloud-security-service-model`, `portfolio/gsd-orchestrator`, `portfolio/org-dotgithub`) -- all 6 evaluated RETAIN, so no local branch was deleted and no checkout was switched.

## Decisions Made
- Installed Pester 5+ (landed as 6.0.0) via `Install-Module -Scope CurrentUser` to run the `-CI` Pester invocation the plan's verification requires -- the machine only had Pester 3.4.0 (Windows-bundled) available, and CI (`.github/workflows/ci.yml`) already installs Pester >=5.0.0 the same way, so this mirrors existing project tooling rather than introducing a new dependency choice.
- All 6 kept branches: left in place rather than deleted, since every one is RETAIN under the fail-closed gate. Documented as post-merge-drift flags (not auto-resolved) since resolving them would require either force-deleting on an inference or rebasing/switching a dirty foreign checkout, both out of scope for a dispositioning-only plan.
- pr-maf-workers: moved rather than deleted per the plan's explicit move-not-delete instruction, even though the content-uniqueness probe found nothing unique -- preserves the ability for a human to double-check before permanent deletion.

## Deviations from Plan

None - plan executed exactly as written (including the corrected Task 3 text: pr-maf-workers treated as an unregistered stray sandbox copy via the content-uniqueness probe, never as a `git worktree remove` target).

## Issues Encountered
- Local machine only had Pester 3.4.0 available (no `-CI` support); resolved by installing Pester 5+ for CurrentUser, matching what CI already does. Not a deviation from the plan's content -- required to execute the plan's own specified verification command.
- The `pr-maf-workers` move had previously failed in an earlier, unrelated attempt (per the plan's data section, "an unlinkable `.venv` file previously blocked deletion"). This run's move succeeded in a single operation with no partial-failure fallback needed.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- REQ-1.5.2 (branch + worktree hygiene portions) closed for this plan's scope.
- Operator follow-up recommended (out of scope here, documented in the disposition report): the 6 RETAIN branches can likely be safely deleted directly once confirmed their primary checkouts have no locally-only work beyond the already-merged PR, or re-gated after each checkout is rebased onto current `main`.
- `scripts/squash-aware-branch-gate.ps1` is reusable for future hygiene sweeps across the portfolio.

## Self-Check: PASSED

All created files verified present (script, test suite, disposition report, this summary); all 3 task commits (`47b9137`, `fa743fb`, `815cebe`) verified in git log; `v1.1-cas-contracts` confirmed removed; `pr-maf-workers` confirmed gone from source and present at `scratch/orphaned-worktrees/pr-maf-workers/`.

---
*Phase: 38-merge-flow-and-backfill*
*Completed: 2026-07-10*
