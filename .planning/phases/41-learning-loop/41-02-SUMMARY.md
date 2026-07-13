---
phase: 41-learning-loop
plan: 02
subsystem: continuous-improvement-tooling
tags: [powershell, pester, backlog-survey, convergence-metric, req-1.5.6]

# Dependency graph
requires: []
provides:
  - "scripts/backlog-survey.ps1: deterministic, ID-keyed diff of docs/improvement-backlog.md across runs, producing a dated JSON snapshot + dated delta report markdown with a BASELINE/CONVERGING/NOT_YET_CONVERGING signal"
  - "tests/BacklogSurvey.Tests.ps1: 7 Pester red-fixture tests proving first-run baseline, second-run new/closed detection, and convergence field behavior"
  - "First-ever real survey run committed as evidence under evidence/backlog-survey/ (39 items, convergence BASELINE)"
affects: [42-v1.5-verification-and-audit, future-backlog-convergence-tracking]

tech-stack:
  added: []
  patterns:
    - "ID-keyed markdown-table diffing: snapshot items by their own stable ID, not by row position or content hash, so table reordering/rewording doesn't produce false new/closed signals"
    - "Dated JSON snapshot + dated delta-report markdown pair, mirroring workspace-health.ps1's -Json/report-table convention"

key-files:
  created:
    - scripts/backlog-survey.ps1
    - tests/BacklogSurvey.Tests.ps1
    - evidence/backlog-survey/snapshots/backlog-survey-2026-07-10.json
    - evidence/backlog-survey/reports/2026-07-10-backlog-survey-delta.md
  modified: []

key-decisions:
  - "Worked in an isolated git worktree (worktrees/phase-41-backlog-survey) branched from a freshly-fetched origin/master, per the plan's checker-blocker-#1 correction, since the primary checkout was on an unrelated foreign branch that must never be touched"
  - "Committed Task 1's script + tests as a single test(41-02) commit per the plan's own explicit action text, rather than splitting into separate RED/GREEN commits - the plan's action block directs one commit covering both files, and both were verified green (7/7 passing) before that commit"
  - "For the real baseline-capture run (Task 2), overrode -Root to point at this worktree instead of the script's literal default (C:\\PersonalRepo), since the default would have targeted the untouchable primary checkout; the script's default parameter value itself is unchanged - documented explicitly in the PR body"

requirements-completed: [REQ-1.5.6]

# Metrics
duration: ~35min
completed: 2026-07-10
---

# Phase 41 Plan 02: Repeatable Backlog Survey Summary

**Built `scripts/backlog-survey.ps1`, a deterministic ID-keyed diff of `docs/improvement-backlog.md` producing dated snapshot + delta-report evidence with a BASELINE/CONVERGING/NOT_YET_CONVERGING signal, proved it with 7 green Pester red-fixture tests, and captured the project's first-ever real survey run (39 items, convergence BASELINE) as committed evidence.**

## Performance

- **Duration:** ~35 min
- **Completed:** 2026-07-10
- **Tasks:** 2/2 completed
- **Files created:** 4 (script, test suite, 1 snapshot, 1 delta report)

## Accomplishments

- `scripts/backlog-survey.ps1` parses `docs/improvement-backlog.md`'s markdown table rows keyed by their own stable ID (1-3 letters + digits, e.g. `S1`, `W3`, `E11`), skipping non-matching rows (headers, prose, the ID-less `-` placeholder) without ever throwing.
- Snapshot/diff logic loads the most recent prior snapshot from `-SnapshotDir` (by filename date), computes `newFindings`/`closedItems`/`unchangedCount`, and reports `convergence`: `BASELINE` on the first-ever run, `CONVERGING` when this cycle's new-finding count is lower than its closed-item count, otherwise `NOT_YET_CONVERGING` - matching vNEXT-SEEDS.md's definition of the terminal "nothing left to improve" state.
- Writes a dated JSON snapshot (`{SnapshotDir}\backlog-survey-{date}.json`) and a dated delta-report markdown (`{ReportDir}\{date}-backlog-survey-delta.md`) with New Findings / Closed Items tables and a Trend Counts section referencing REQ-1.5.6 and vNEXT-SEEDS.md by name.
- `tests/BacklogSurvey.Tests.ps1`: 7 Pester tests (first-run baseline with correct newFindings/closedItems/convergence; exactly-one-file-per-run; second-run new/closed detection against the same `-SnapshotDir`; delta-report content assertions; convergence field present and valid on the second run) - all green.
- Both files verified strictly ASCII (`grep -cP "[^\x00-\x7F]"` returns 0 for both).
- Real first-ever run against the live `docs/improvement-backlog.md`: **39 items parsed**, matching the `<interfaces>` block's sanity-check expectation (`grep -cE "^\| [A-Za-z]{1,3}[0-9]+ \|"` = 39) exactly. `convergence: BASELINE`, 0 closed items, as expected for a first-ever run.

## Task Commits

1. **Task 1: backlog-survey.ps1 + red-fixture Pester suite** - `be1e539` (test)
2. **Task 2: capture baseline evidence** - `4d3cf2c` (evidence)

Both commits on branch `feat/phase-41-backlog-survey`, pushed to `origin`, PR opened against `master` on `OgeonX-Ai/cas-workstation`: **https://github.com/OgeonX-Ai/cas-workstation/pull/15**

## Files Created/Modified

- `scripts/backlog-survey.ps1` - deterministic ID-keyed backlog survey (parse, diff, convergence, dated snapshot + delta report, `-Json` mode)
- `tests/BacklogSurvey.Tests.ps1` - 7 Pester red-fixture tests covering all three plan-specified behaviors
- `evidence/backlog-survey/snapshots/backlog-survey-2026-07-10.json` - baseline snapshot, 39 items
- `evidence/backlog-survey/reports/2026-07-10-backlog-survey-delta.md` - baseline delta report, convergence BASELINE

## Decisions Made

- Followed `scripts/workspace-health.ps1`'s established conventions exactly: `[CmdletBinding()]` + `param()` with a `-Root` default, forced UTF-8 console/native-command output encoding at the top (PS 5.1 OEM-codepage hazard), `-Json` mode that suppresses all `Write-Host` output so stdout is pure parseable JSON, and `$ErrorActionPreference = 'Continue'` so one broken row cannot crash the whole survey.
- Kept the row-ID regex (`^\|\s*([A-Za-z]{1,3}[0-9]+)\s*\|(.*)$`) and heading-tracking regex (`^#{2,3}\s+(.*)$`) narrowly scoped exactly as the `<interfaces>` block specified, verified against the real document's 39-row count before trusting the parser.
- Did not use any array-returning PowerShell function in the script (the Phase 34 lesson about PS 5.1's comma-operator/array-unrolling hazard under `Set-StrictMode` was kept in mind, but avoided entirely here by not routing array values through function `return` statements - `newFindings`/`closedItems` are built via direct `Where-Object` pipeline assignment, not a wrapped helper function).
- Committed Task 1's script and tests together in one `test(41-02)` commit exactly as the plan's own action text specified, rather than a strict RED-then-GREEN split - both files were fully green (7/7 Pester tests passing) before that single commit was made.
- For Task 2's real baseline-capture run, explicitly passed `-Root` pointing at this worktree rather than relying on the script's literal default (`C:\PersonalRepo`, the primary checkout), since the primary checkout is on an unrelated foreign branch this plan must never touch. The script's own default parameter value was left unchanged; only the invocation was adapted, and this is called out explicitly in the PR body so a reviewer isn't confused about why the committed evidence's `backlogPath` field points at a worktree path rather than `C:\PersonalRepo`.

## Deviations from Plan

### Auto-fixed Issues

None. Both tasks executed as written, including the plan's own checker-blocker-#1 correction (isolated worktree instead of requiring the primary checkout to be on `master`).

### Scope Adjustment (environment-driven, explicitly documented)

**1. Baseline-capture run used an explicit `-Root` instead of the literal script default**
- **Found during:** Task 2, preparing to run the script "with all defaults" as the plan's action text states
- **Issue:** The plan's literal invocation (`powershell -NoProfile -File scripts\backlog-survey.ps1 -Json`, "all defaults") assumes execution against the primary checkout at `C:\PersonalRepo`. This plan's own Task 1 corrected instructions require all work to happen in an isolated worktree, with the primary checkout never touched - running with the true literal default `-Root` would have targeted the primary checkout's `docs/improvement-backlog.md`, violating that isolation.
- **Resolution:** Passed `-Root` explicitly pointing at the worktree. This is not a change to the script's behavior or default value - it is the correct adaptation of the plan's own worktree-isolation instruction to this specific invocation. Documented explicitly in the PR body so the deviation from "literal defaults" is transparent to a reviewer.
- **Files modified:** None (invocation-only; no script change).

**Total deviations:** 0 auto-fixed bugs; 1 documented environment-driven scope adjustment (invocation parameter only, not a behavior change).
**Impact on plan:** None on correctness - the script itself behaves identically regardless of which `-Root` value is passed; only the specific baseline-capture invocation in this isolated-worktree context needed an explicit override.

## Issues Encountered

- `git push` printed the same benign credential-helper warning documented in prior phases
  (`"/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential store: ... No such file or
  directory`) - the push itself succeeded (branch created on remote, PR opened) - no action
  needed.

## Known Stubs

None. Every file created is complete, functioning content - no placeholder/empty values.

## Threat Flags

None. This plan only reads a local markdown file and writes local JSON/markdown evidence files
under `evidence/backlog-survey/` - no new network endpoints, auth paths, or schema changes.

## User Setup Required

None - no external service configuration required. PR #15 is open and awaits human review/merge
(this session never merges, approves, or touches branch protection, per scope).

## Next Phase Readiness

- PR #15 (`feat/phase-41-backlog-survey` -> `master`) is open on `OgeonX-Ai/cas-workstation`,
  awaiting human review/merge.
- Once merged, running `scripts/backlog-survey.ps1` again after any future backlog edit will
  correctly detect new/closed items against the committed 2026-07-10 baseline snapshot and report
  a real `CONVERGING`/`NOT_YET_CONVERGING` signal instead of `BASELINE`.
- The next real survey run (whenever the operator next triggers one) will be the first true test
  of the convergence metric against actual backlog churn.

---
*Phase: 41-learning-loop*
*Completed: 2026-07-10*

## Self-Check: PASSED

- FOUND: scripts/backlog-survey.ps1
- FOUND: tests/BacklogSurvey.Tests.ps1
- FOUND: evidence/backlog-survey/snapshots/backlog-survey-2026-07-10.json
- FOUND: evidence/backlog-survey/reports/2026-07-10-backlog-survey-delta.md
- FOUND: commit be1e539 (Task 1)
- FOUND: commit 4d3cf2c (Task 2)
- CONFIRMED: `Invoke-Pester -Path tests/BacklogSurvey.Tests.ps1 -CI` -> 7/7 passed, 0 failed
- CONFIRMED: `grep -cP "[^\x00-\x7F]"` returns 0 for both scripts/backlog-survey.ps1 and tests/BacklogSurvey.Tests.ps1
- CONFIRMED: PR #15 opened against master on OgeonX-Ai/cas-workstation
