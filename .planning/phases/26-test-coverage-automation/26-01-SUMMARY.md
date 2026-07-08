---
phase: 26-test-coverage-automation
plan: 01
subsystem: testing
tags: [coverlet, xunit, nsubstitute, cobertura, github-actions, dotnet]

# Dependency graph
requires: []
provides:
  - Ratcheted branch-coverage CI gate (replaces permanently-red line-rate==100% check)
  - Declarative coverlet.runsettings for boilerplate exclusions
  - 37 new tests closing coverage gaps in state-machine/model/process-execution code
affects: [future gsd-orchestrator test-coverage phases, CI supply-chain hardening phases]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Ratcheted coverage gate: $Baseline in ci.yml is raised only when new tests push branch-rate strictly higher; never hardcoded to an aspirational 100%"
    - "Real cross-platform process-executor tests (NativeProcessCommandExecutor) instead of mocking Process, using OS-appropriate shell commands (cmd.exe /c vs /bin/sh -c)"

key-files:
  created:
    - portfolio/gsd-orchestrator/coverlet.runsettings
    - portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests/CoverageGapClosingTests.cs
  modified:
    - portfolio/gsd-orchestrator/.github/workflows/ci.yml
    - portfolio/gsd-orchestrator/.gitignore

key-decisions:
  - "Re-measured branch-rate baseline instead of trusting the plan's stale prior number (0.6732) — actual Debug-mode baseline under new runsettings was 0.6913"
  - "Rounded new baseline DOWN to 4 decimals (0.7314) using Debug-mode measurement (0.7314) as the conservative floor, since Release-mode (CI's actual mode) measured slightly higher (0.7390), giving the gate margin"
  - "Reset the stale local feat/phase-26-coverage-gates branch (unrelated old commit d416968) to origin/main rather than building on top of it"
  - "Cherry-picked stranded local-main commit 4b7aee2 (checkpoint corruption fix, unrelated to this plan's file scope) onto the feat branch per coordinator direction, then also rehomed it to its own fix/checkpoint-corruption branch with a separate PR, since it's an unrelated fix and should not be bundled into the coverage-gate PR review"
  - "Left local main and the parallel Gemini session's uncommitted changes (.planning/REQUIREMENTS.md, .planning/ROADMAP.md, src/GsdOrchestrator/Program.cs) completely untouched, as scoped"

requirements-completed: [REQ-1.4.1, REQ-1.4.4]

duration: 45min
completed: 2026-07-06
---

# Phase 26 Plan 01: gsd-orchestrator Coverage Gates Summary

**Rewrote the gsd-orchestrator CI gate from a permanently-red `line-rate==100%` check to a ratcheted `branch-rate >= 0.7314` gate, and raised measured branch coverage from 0.6913 to 0.7314 with 37 new meaningfully-asserted tests.**

## Performance

- **Duration:** 45 min (resumed from an interrupted attempt; reused its `coverlet.runsettings`)
- **Completed:** 2026-07-06T17:15:48Z
- **Tasks:** 2/2 completed
- **Files modified/created:** 4 (coverlet.runsettings, ci.yml, .gitignore, CoverageGapClosingTests.cs)

## Accomplishments

- `coverlet.runsettings` centralizes boilerplate-exclusion decisions (Obsolete/GeneratedCode/CompilerGenerated/ExcludeFromCodeCoverage attributes; obj/, *.g.cs, Program.cs file globs) so they're declarative instead of scattered CLI flags
- CI "Enforce coverage" step now reads `branch-rate` (not `line-rate`) from cobertura output and fails closed with CAS JSON telemetry on regression or missing coverage file — verified both pass and fail paths locally with a standalone PowerShell simulation before pushing
- Branch coverage raised from measured baseline **0.6913 to 0.7314** (branches-covered 690/998 -> 730/998) via 37 new tests targeting previously low/zero-coverage orchestration and model code
- Rehomed an unrelated stranded commit (checkpoint corruption fix) from local `main` onto its own branch/PR rather than leaving it stuck or bundling it into the coverage-gate review

## Task Commits

1. **Task 1: Add coverlet.runsettings and measure baseline** - `2feb2c9` (feat)
2. **Task 2: Rewrite CI gate to ratcheted threshold, add coverage tests** - `bffdee7` (feat, TDD-style: tests added and confirmed passing against existing implementation, no production-code changes required)

Additionally (out-of-plan, coordinator-directed): `795242f` cherry-picked onto this branch and also pushed standalone as `fix/checkpoint-corruption` (PR #17) — not part of this plan's deliverable, documented for traceability.

**Note:** No separate plan-metadata commit was made in the gsd-orchestrator sub-repo itself; this SUMMARY and STATE.md updates land in the PersonalRepo monorepo per the multi-repo executor convention.

## Files Created/Modified

- `portfolio/gsd-orchestrator/coverlet.runsettings` - Declarative XPlat Code Coverage collector config with attribute/file exclusions
- `portfolio/gsd-orchestrator/.github/workflows/ci.yml` - Test step now passes `--settings coverlet.runsettings`; "Enforce 100% Coverage" step replaced with "Enforce branch coverage (ratchet)" reading `branch-rate`, `$Baseline = 0.7314`, CAS JSON telemetry on pass/fail/missing-file
- `portfolio/gsd-orchestrator/.gitignore` - Added `TestResults/` (was untracked build-artifact output; not previously ignored on origin/main despite scope note assuming otherwise)
- `portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests/CoverageGapClosingTests.cs` - 37 new tests, each with meaningful assertions on observable behavior (state transitions, exception types, published telemetry payloads)

## Reused from the Interrupted Attempt

- `coverlet.runsettings` (untracked in working tree at session start) matched the plan's Task 1 spec exactly (correct DataCollector friendlyName, Format=cobertura, SkipAutoProps, ExcludeByAttribute list, ExcludeByFile globs) — reused as-is, committed unmodified.
- The local `feat/phase-26-coverage-gates` branch existed but pointed at an unrelated stale commit (`d416968 chore: sync phase 17-19 completion`, not based on current origin/main, no coverage-gate work) — reset to `origin/main` via `git checkout -B` rather than building on top of it.
- `TestResults/` and `src/GsdOrchestrator.Tests/TestResults/` untracked build artifacts from the interrupted run were left alone on disk (gitignored now, never staged).

## Before/After Coverage

| Metric | Before (Task 1 baseline, Debug) | After (Task 2, Debug) | After (Release, informational) |
|---|---|---|---|
| branch-rate | 0.6913 | **0.7314** | 0.7390 |
| line-rate | 0.9082 | 0.9349 | 0.9366 |
| branches-covered/valid | 690/998 | 730/998 | - |
| tests passing | 231 | 268 | 268 |

`$Baseline` in ci.yml is set to the Debug-mode value (0.7314) as the conservative floor; CI itself runs in Release mode which measured slightly higher, giving margin against flake.

## Decisions Made

- Re-measured the baseline fresh in Task 1 rather than trusting the plan's stale prior figure (0.6732) — confirmed materially different (0.6913) due to the new exclusions plus the cherry-picked checkpoint fix.
- Targeted new tests at the lowest-branch-coverage, most safely-testable code: `SdlcWorkflowMap.PhaseIdForState` (pure switch, was 0.14 branch-rate), `SdlcProfile.ResolveRollbackOrigin`/`GsdWorkflowContext.Transition`/`WithSdlcVerification` (model logic, easy to assert on returned records), `LoopPolicyGuard` (pure static guard), `NativeProcessCommandExecutor` (real process spawns using OS-appropriate shell one-liners — deterministic, no network/sleep), and `McpTerminalOutcomePublisher` (mocked `IMcpClient` via NSubstitute, asserted the exact JSON payload sent).
- Deliberately did NOT touch `MafProcessLoopWorker` (still 0% branch-rate) — it shells out to a real Python subprocess (`maf_starter.loop_worker_cli`) with no injectable seam; testing it would require either a Python runtime dependency in CI or an architectural refactor to introduce an `IProcessLauncher` abstraction, which is a Rule 4 (architectural) change out of this plan's scope. Recorded as a deferred item below.
- Cherry-picked the stranded `4b7aee2` checkpoint-corruption fix per coordinator direction (confirmed it touches only `FileCheckpointStore.cs`, no overlap with this plan's files, and is a genuine bug fix) — then also pushed it standalone to `fix/checkpoint-corruption` with its own PR (#17) so it gets independent review rather than being buried in the coverage-gate PR.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `.gitignore` did not exclude `TestResults/`**
- **Found during:** Task 1
- **Issue:** Scope note assumed `TestResults/` gitignore exclusion had landed via merged PR #15; verification showed origin/main's `.gitignore` had no such entry, leaving build-artifact XML/TRX files as perpetually untracked noise
- **Fix:** Added `TestResults/` to `.gitignore` under a new "Coverage / test run output" section
- **Files modified:** `portfolio/gsd-orchestrator/.gitignore`
- **Committed in:** `2feb2c9` (Task 1 commit)

**2. [Coordinator-directed, out-of-plan] Rehomed stranded local-main commit**
- **Found during:** mid-execution (coordinator message)
- **Issue:** Local `main` was 1 commit ahead of `origin/main` with an unpushed, unrelated checkpoint-corruption fix from a parallel session; `main` is push-protected so it was stranded
- **Fix:** Cherry-picked onto the feat branch (benefits this plan's own coverage run with correct behavior) and separately created/pushed `fix/checkpoint-corruption` branch + PR #17 for independent review; did not reset or otherwise mutate local `main`
- **Files modified:** `src/GsdOrchestrator/Checkpointing/FileCheckpointStore.cs` (not this plan's file — inherited via cherry-pick)
- **Verification:** `dotnet build` succeeded; full 231-test suite passed unchanged after the cherry-pick, before any Task 2 tests were added
- **Committed in:** `795242f` (cherry-picked, present on both `feat/phase-26-coverage-gates` and `fix/checkpoint-corruption`)

---

**Total deviations:** 2 (1 blocking auto-fix, 1 coordinator-directed rehoming of unrelated stranded work)
**Impact on plan:** Both necessary for a clean, mergeable PR and for not losing the parallel session's work. No scope creep into the plan's own deliverable.

## Known Stubs

None.

## Threat Flags

None. All new tests operate on existing public surface (models, static guards, an already-injectable process-executor interface, and the existing `IMcpClient`/`McpToolDispatcher` seam). No new network endpoints, auth paths, or schema changes were introduced.

## Deferred Items (branches still uncovered after this plan)

| Class/Method | branch-rate | Reason for deferral |
|---|---|---|
| `MafProcessLoopWorker.ExecuteAsync` | 0.0000 | Shells to a real Python subprocess (`maf_starter.loop_worker_cli`); no injectable seam. Needs either a CI Python dependency or an `IProcessLauncher` abstraction — architectural (Rule 4), out of scope |
| `CommittingState.ExecuteAsync` | 0.4166 | Git-command orchestration state; would need a fuller git-process test harness |
| `FileCheckpointStore.SaveAsync` | 0.5000 | Async state-machine branch from the just-cherry-picked flush-to-disk change; not this plan's scope |
| `GoalControlPlane.Required`/`StartAsync` | 0.5000 | Scheduling control-plane guard clauses |
| `SqliteGoalStore.LoadAsync`/`LoadOneAsync`/`LoadProjectionAsync` | 0.5000 | SQLite null-row / not-found branches |
| `FileWatchStateStore.MarkProcessedAsync` | 0.5000 | File-watch dedup branch |
| `AnalyzingState.TrySearchCodeAsync`, `DocumentingState.GenerateChangelogEntryAsync`, `PrCreatingState.GeneratePrDraftAsync`, `ReviewingState.GenerateReviewCommentAsync`, `TestGeneratingState.ReadFileAsync`/`TryReadFileWithShaAsync`, `TriagingState.FetchOpenIssuesSummaryAsync` | 0.5000 each | GitHub/LLM-call error-path branches in workflow states; good candidates for a future coverage-improvement plan |
| `BranchingState.ExecuteAsync`, `PrCreatingState.ExecuteAsync` | 0.5500 | State entry/exit branch variants |
| `AnalyzingState` (class-level), `ReviewingState.FetchPrMetaAsync`, `IdleState.ExecuteAsync`, `ReviewingState` (class-level) | 0.5625-0.5869 | Aggregate class-level branch rates below 0.6, spread across multiple methods each already partially covered |

These are recorded for the next test-coverage phase; none block this plan's gate from passing.

## Issues Encountered

None beyond the deviations above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- CI gate on `feat/phase-26-coverage-gates` (PR #16) is a meaningful, passable, non-regressing signal — ready for review/merge (merge itself is out of this session's scope; PR left open, unmerged, untouched branch protection).
- `fix/checkpoint-corruption` (PR #17) is a separate, independently-reviewable fix, also left open.
- Deferred items above give a concrete backlog for the next coverage-improvement plan (particularly `MafProcessLoopWorker`, which needs an architectural decision on process-launch abstraction before it can be tested).

---
*Phase: 26-test-coverage-automation*
*Completed: 2026-07-06*

## Self-Check: PASSED

- FOUND: portfolio/gsd-orchestrator/coverlet.runsettings
- FOUND: portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests/CoverageGapClosingTests.cs
- FOUND: commit 2feb2c9 (Task 1)
- FOUND: commit bffdee7 (Task 2)
- FOUND: commit 795242f (cherry-picked checkpoint fix)
- FOUND: PR #16 (OPEN) - https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/16
- FOUND: PR #17 (OPEN) - https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/17
