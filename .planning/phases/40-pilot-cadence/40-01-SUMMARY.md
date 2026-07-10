---
phase: 40-pilot-cadence
plan: 01
subsystem: pilot-cadence
tags: [powershell, ci-evidence, github-issues, worktrees]
dependency-graph:
  requires: [tests/Loop.Pilot.Tests.ps1, evidence/compliance/snapshots precedent]
  provides: [scripts/run-pilot-cadence.ps1, scripts/file-pilot-regression-issue.ps1, evidence/pilot-cadence schema]
  affects: [portfolio/gsd-orchestrator (read-only worktree), portfolio/autogen (read-only worktree), OgeonX-Ai/cas-workstation master (via PR)]
tech-stack:
  added: []
  patterns:
    - "Sync-ReadOnlyWorktree: fetch-only against source repo, worktree add/re-checkout for isolated read execution"
    - "Invoke-CapturedCommand: PS 5.1 native-command stderr capture without ErrorActionPreference=Stop false-terminations"
    - "Evidence-via-dedicated-worktree-and-PR instead of direct commit to primary checkout"
key-files:
  created:
    - scripts/run-pilot-cadence.ps1
    - scripts/file-pilot-regression-issue.ps1
    - evidence/pilot-cadence/README.md
    - evidence/pilot-cadence/2026-07-10.json (via evidence PR #13)
  modified: []
decisions:
  - "Reused Sync-ReadOnlyWorktree for the evidence-commit worktree too (Ref=origin/master instead of origin/main), per plan's explicit instruction"
  - "Fixed a plan-literal bug: the best-effort fetch inside Sync-ReadOnlyWorktree is now derived from $Ref (main/master) instead of hardcoded 'fetch origin main', since the root repo's default branch is master, not main"
  - "Added Invoke-CapturedCommand wrapper for every git/dotnet/pytest/gh invocation to prevent PowerShell 5.1's native-command stderr-to-ErrorRecord promotion from throwing under $ErrorActionPreference='Stop'"
metrics:
  duration: "~90 minutes"
  completed: "2026-07-10"
---

# Phase 40 Plan 01: Pilot-Cadence Runner + Issue Filer Summary

Local pilot-cadence runner that re-executes the four v1.0 loop pilot scenarios plus both repos' Phase 28 fault-injection suites from isolated worktrees pinned to origin/main, producing dated git-committed evidence and a dedupe-guarded auto-filed GitHub issue on any regression.

## What Was Built

- **`scripts/run-pilot-cadence.ps1`** -- orchestrates three suites (`loop-pilots`, `gsd-orchestrator-fault-injection`, `autogen-fault-injection`), each isolated via `Sync-ReadOnlyWorktree` (fetch-only against the source repo, `git worktree add --detach` / re-checkout for execution -- never touches either sub-repo's primary checkout or currently-checked-out branch). Writes a dated evidence summary to `evidence/pilot-cadence/{date}.json` and full raw logs to the gitignored `scratch/pilot-cadence-logs/{date}/`. Commits the evidence file via a dedicated `worktrees/cas-workstation-pilot-cadence` worktree + `evidence/pilot-cadence-{date}` branch, then opens (or reuses, on same-day re-run) a PR against `OgeonX-Ai/cas-workstation` master -- the primary `C:\PersonalRepo` working tree (branch `docs/phase-38-plan-fixes` with unrelated in-progress work) is never staged, committed, or checked out against.
- **`scripts/file-pilot-regression-issue.ps1`** -- dedupe-guarded issue filer: `gh issue list --state open --search` with client-side exact-title filtering (title has no date component: `pilot-cadence: {suite-id} regression`), comments on an existing match instead of opening a duplicate, retries `gh issue create` once without `--label` if the label doesn't exist in the target repo, and never throws on a transient `gh` failure (the evidence JSON remains the source of truth regardless of issue-filing success).
- **`evidence/pilot-cadence/README.md`** -- documents the schema (`schemaVersion`, `runDate`, `startedAt`/`finishedAt`, `overallStatus`, `suites[]` with `failureExcerpt` on non-green, `issuesFiled[]`) and the storage-split rationale (committed summary JSON vs. gitignored full logs).
- Wired: `run-pilot-cadence.ps1` calls the issue filer for every non-green suite unless `-NoIssueFile`, records `{suiteId, issueUrl, deduped}` into the evidence JSON's `issuesFiled` array before it is written to disk.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Hardcoded `fetch origin main` inside `Sync-ReadOnlyWorktree` broke the evidence-worktree reuse**
- **Found during:** Task 1 first real-run verification
- **Issue:** The plan's literal text for `Sync-ReadOnlyWorktree` specifies a hardcoded `git -C $SourceRepo fetch origin main` best-effort step. The plan also directs reusing this same function for the evidence-commit worktree with `$Ref = 'origin/master'`. `OgeonX-Ai/cas-workstation`'s remote only has a `master` branch (confirmed via `git ls-remote --heads origin`), so the hardcoded fetch threw `fatal: couldn't find remote ref main`, which (combined with issue #2 below) aborted the whole run uncaught.
- **Fix:** The best-effort fetch now derives the branch name from `$Ref` (`$Ref -replace '^origin/', ''`) instead of hardcoding `main`, so it correctly fetches `main` for the two portfolio repos and `master` for the root repo's evidence worktree.
- **Files modified:** `scripts/run-pilot-cadence.ps1`
- **Commit:** 80f8ff1

**2. [Rule 1 - Bug] PowerShell 5.1 native-command stderr promoted to terminating errors under `$ErrorActionPreference = 'Stop'`**
- **Found during:** Task 1 first real-run verification
- **Issue:** Windows PowerShell 5.1 wraps any native-command stderr line captured via `2>&1` as an `ErrorRecord`; with `$ErrorActionPreference = 'Stop'` in effect (as the plan requires for setup), the first such record throws a terminating exception, unconditionally aborting the script -- even for "best-effort" operations the plan explicitly says must not fail the run (e.g. the offline-tolerant fetch), and even inside suite scriptblocks that are supposed to only be caught via non-zero `$LASTEXITCODE`. This is exactly the failure mode the plan's own instruction ("capture $LASTEXITCODE per suite instead of letting -Stop throw on a non-zero exit from an external command") anticipates but the literal per-call pattern described doesn't actually prevent under PS 5.1.
- **Fix:** Added an `Invoke-CapturedCommand` helper that temporarily sets `$ErrorActionPreference = 'Continue'` for the duration of each native call (git/dotnet/pytest/gh/powershell), captures combined stdout+stderr as plain text, and restores the prior preference -- used uniformly everywhere an external command is invoked in both scripts.
- **Files modified:** `scripts/run-pilot-cadence.ps1`, `scripts/file-pilot-regression-issue.ps1`
- **Commit:** 80f8ff1, 166f998

## Auth / Verification Notes

`gh auth status` confirmed logged in as `OgeonX-Ai` with `repo`/`workflow` scopes before the real run; no auth gate encountered.

## First Real Run (all three suites, `-NoIssueFile`)

Ran `scripts/run-pilot-cadence.ps1 -NoIssueFile` for real from the plan-execution worktree against the actual `C:\PersonalRepo` root and both portfolio sub-repos' `origin/main`. All three suites were legitimately green:

| Suite | Status | Duration | Commit SHA (origin/main or root HEAD) |
|---|---|---|---|
| loop-pilots | passed | 0.94s | da50712 (root HEAD) |
| gsd-orchestrator-fault-injection | passed | 4.8s | d141f42 |
| autogen-fault-injection | passed | 2.7s | e20478b |

`overallStatus: "passed"`. Evidence written to `evidence/pilot-cadence/2026-07-10.json`, full logs to `scratch/pilot-cadence-logs/2026-07-10/{suite-id}.log`. Evidence committed via `worktrees/cas-workstation-pilot-cadence` on branch `evidence/pilot-cadence-2026-07-10` (commit b9a43be) and opened as PR **[#13](https://github.com/OgeonX-Ai/cas-workstation/pull/13)** against master -- CI (Analyze/CodeQL, commit-integrity, pester x2, workspace-health) all green.

Since all three suites were green, `-NoIssueFile` had no observable effect on this run (no suite was non-green to file against); the filer's exact-title dedupe logic and the runner's `issuesFiled` wiring are verified via Task 2's grep-based check plus schema-level confirmation (`issuesFiled: []` present and correctly empty on the all-green re-run) -- full end-to-end proof of a real filed-then-deduped issue is deferred to Plan 02's falsifier task per the plan's `<verification>` section.

## Isolation Verification

- Primary `C:\PersonalRepo` checkout: branch `docs/phase-38-plan-fixes` before and after every run, `git status --short` identical to the pre-existing baseline (only the script's designed local-artifact writes to `evidence/pilot-cadence/` and gitignored `scratch/pilot-cadence-logs/` appeared transiently during testing and were cleaned up before the final state; no git operations of any kind ran against this checkout).
- `portfolio/gsd-orchestrator` primary checkout: remained on `feat/phase-26-coverage-gates` with its pre-existing uncommitted changes untouched; suite ran from a separate detached-HEAD worktree at `worktrees/gsd-orchestrator-pilot-cadence` (commit d141f42).
- `portfolio/autogen` primary checkout: remained on `feat/phase-26-coverage-gates` with its pre-existing uncommitted changes untouched; suite ran from a separate detached-HEAD worktree at `worktrees/autogen-pilot-cadence` (commit e20478b).
- This plan's own script-authoring work was done entirely inside a dedicated worktree (`worktrees/phase-40-pilot-cadence`, branch `feat/phase-40-pilot-cadence`, based on `origin/master`), pushed and opened as PR **[#14](https://github.com/OgeonX-Ai/cas-workstation/pull/14)** -- never committed directly to the primary checkout's current branch. CI on PR #14 (Analyze/CodeQL, commit-integrity, pester x2, workspace-health) all green.

## Commits

| Commit | Message | Branch |
|---|---|---|
| 80f8ff1 | feat(40-01): add pilot-cadence runner with isolated worktrees and dated evidence | feat/phase-40-pilot-cadence |
| 166f998 | feat(40-01): add dedupe-guarded regression issue filer, wire into runner | feat/phase-40-pilot-cadence |
| b9a43be | docs(pilot-cadence): evidence for 2026-07-10 (passed) | evidence/pilot-cadence-2026-07-10 (auto-created by the runner) |

## PRs

- **Scripts PR:** https://github.com/OgeonX-Ai/cas-workstation/pull/14 (`feat/phase-40-pilot-cadence` -> `master`) -- OPEN, mergeable, CI green.
- **First evidence PR:** https://github.com/OgeonX-Ai/cas-workstation/pull/13 (`evidence/pilot-cadence-2026-07-10` -> `master`) -- OPEN, CI green. Auto-created by the runner during real-run verification, exactly as designed.

Neither PR was merged or approved by this execution (per rules: never merge/approve).

## Self-Check: PASSED

- FOUND: C:\PersonalRepo\worktrees\phase-40-pilot-cadence\scripts\run-pilot-cadence.ps1
- FOUND: C:\PersonalRepo\worktrees\phase-40-pilot-cadence\scripts\file-pilot-regression-issue.ps1
- FOUND: C:\PersonalRepo\worktrees\phase-40-pilot-cadence\evidence\pilot-cadence\README.md
- FOUND: commit 80f8ff1 (git log --oneline --all)
- FOUND: commit 166f998 (git log --oneline --all)
- FOUND: PR #13 https://github.com/OgeonX-Ai/cas-workstation/pull/13 (gh pr view 13)
- FOUND: PR #14 https://github.com/OgeonX-Ai/cas-workstation/pull/14 (gh pr view 14)
