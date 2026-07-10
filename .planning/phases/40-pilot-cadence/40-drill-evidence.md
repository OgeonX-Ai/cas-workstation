# Phase 40-02: Seeded-Regression Falsifier Drill Evidence

REQ-1.5.4 falsifier 2: "a real regression actually produces a filed issue within one cycle."

This drill seeded a deliberately failing test on a **throwaway, never-pushed**
local `gsd-orchestrator` worktree commit, drove it through
`scripts\run-pilot-cadence.ps1` pointed at that commit's SHA, and verified the
regression-to-issue pipeline end to end: red suite -> exactly one filed issue
-> dedupe-on-rerun (comment, not a second issue) -> issue closed -> full
cleanup with zero residue on any real branch or in the real evidence history.

## 1. Seeded commit

- Throwaway worktree: created via `git worktree add --detach <TEMP>\gsd-orchestrator-drill-40-02 origin/main`
  from `portfolio\gsd-orchestrator` (never pushed anywhere).
- Seeded file: `src/GsdOrchestrator.Tests/DrillSeededFailure.cs`, class
  `DrillFaultInjectionTests` (named to match the runner's dotnet test filter
  `FullyQualifiedName~FaultInjectionTests|FullyQualifiedName~CheckpointCorruptionTests`),
  a single `[Fact]` asserting `Assert.Equal(2, 1)` (always fails).
- Local-only commit message: `drill(40-02): seeded failing test - never push`
- **Seeded SHA (final, used for both drill runs): `11641fcb5e7ac1c840434f3796e2eebaa68d1fe6`**
  - (An earlier attempt used SHA `f85b16ecbe8e2bf4a529443c6418493c8ef91511` with
    the test class named `DrillSeededFailureTests`, which did not match the
    dotnet test filter and produced a false "passed" -- amended in place to
    rename the class before the real drill runs below. Both SHAs are confirmed
    unreachable from any branch in section 5.)
- Never pushed to any remote at any point; commit lived only in the throwaway
  worktree's local object store (shared with `portfolio\gsd-orchestrator`'s
  object database via `git worktree`).

## 2. Red suite run (first pass -- file path)

Command:
```
powershell -NoProfile -File scripts\run-pilot-cadence.ps1 `
  -OnlySuites gsd-orchestrator-fault-injection `
  -GsdOrchestratorRef 11641fcb5e7ac1c840434f3796e2eebaa68d1fe6 `
  -NoCommit
```

Result: `gsd-orchestrator-fault-injection: failed (5.3s)`, `Overall status: failed`, exit code 1.

Failure excerpt (from evidence JSON / captured log, redacted repo-root):
```
Test run for <repo-root>\worktrees\gsd-orchestrator-pilot-cadence\src\GsdOrchestrator.Tests\bin\Debug\net10.0\GsdOrchestrator.Tests.dll (.NETCoreApp,Version=v10.0)
A total of 1 test files matched the specified pattern.
GsdOrchestrator.Tests.DrillFaultInjectionTests.Drill_Seeded_Failure_Should_Never_Pass [FAIL]
  Error Message:
   Assert.Equal() Failure: Values differ
Expected: 2
Actual:   1
  Stack Trace:
     at GsdOrchestrator.Tests.DrillFaultInjectionTests.Drill_Seeded_Failure_Should_Never_Pass() in <repo-root>\worktrees\gsd-orchestrator-pilot-cadence\src\GsdOrchestrator.Tests\DrillSeededFailure.cs:line 16
     ...
Failed!  - Failed:     1, Passed:     8, Skipped:     0, Total:     9, Duration: 331 ms - GsdOrchestrator.Tests.dll (net10.0)
```

`run-pilot-cadence.ps1`'s `Sync-ReadOnlyWorktree` correctly checked the real,
dedicated `worktrees\gsd-orchestrator-pilot-cadence` worktree out detached at
the seeded SHA (fetched directly from `portfolio\gsd-orchestrator`'s local
object store, since the throwaway worktree shares that store) -- proving the
interface note that a never-pushed local commit SHA works exactly like
`origin/main` for this pipeline.

**Issue filed:** [Coding-Autopilot-System/gsd-orchestrator#23](https://github.com/Coding-Autopilot-System/gsd-orchestrator/issues/23),
titled `pilot-cadence: gsd-orchestrator-fault-injection regression` (stable
title, no date component). Confirmed via `gh issue list --repo
Coding-Autopilot-System/gsd-orchestrator --state open --search "pilot-cadence"`:
exactly one match.

Pre-drill baseline was verified clean (zero pre-existing `pilot-cadence`
issues on the repo) before this run, so issue #23 is unambiguously the drill's
own artifact.

## 3. Bug found and fixed during the drill (Rule 1)

The first red run's dedupe search (`gh issue list ... --search "in:title
`"$Title`""`) failed with `gh.exe : unknown arguments [...]; please quote all
values that have spaces` -- Windows PowerShell 5.1's native-argument
marshalling corrupts arguments containing embedded literal `"` characters when
invoking `gh.exe`, splitting the quoted phrase into separate unrecognized
arguments. This made the dedupe search fail closed on every call (existing
issue never found), which would have caused every subsequent run to file a
**new** issue instead of deduping -- breaking REQ-1.5.4's second falsifier.

Fixed in `scripts\file-pilot-regression-issue.ps1`: dropped the embedded
`"..."` wrapping around `$Title` in the `--search` argument (query is now
`"in:title $Title"` with no embedded quote characters). Safe because the
script already filters results client-side to an exact title match
(`$candidates | Where-Object { $_.title -eq $Title }`), so GitHub's
substring/token search does not need query-side exact phrasing. Verified fix
directly against `gh.exe` before re-running the drill (see task transcript);
confirmed it returns the exact issue #23 match.

## 4. Dedupe run (second pass -- comment path)

Same command re-run against the same seeded SHA after the fix:
```
powershell -NoProfile -File scripts\run-pilot-cadence.ps1 `
  -OnlySuites gsd-orchestrator-fault-injection `
  -GsdOrchestratorRef 11641fcb5e7ac1c840434f3796e2eebaa68d1fe6 `
  -NoCommit
```

Result: `gsd-orchestrator-fault-injection: failed (5.3s)`, runner output:
`Filing regression issue for suite: gsd-orchestrator-fault-injection ...` ->
`deduped: commented on #23`.

Verification:
- `gh issue list --repo Coding-Autopilot-System/gsd-orchestrator --state open --search "pilot-cadence"`
  still returns exactly **one** issue (#23) -- no second issue filed.
- `gh issue view 23 --json comments --jq '.comments | length'` -> `1` (the
  dedupe comment: "pilot-cadence: regression recurred on 2026-07-10 ...").

## 5. Cleanup

- Issue #23 closed with an explanatory comment ("drill verification -
  closing ..." referencing this evidence file). Confirmed
  `gh issue view 23 --json state` -> `"state": "CLOSED"`.
- Throwaway worktree removed: `git worktree remove --force <TEMP>\gsd-orchestrator-drill-40-02`
  + `git worktree prune`, from `portfolio\gsd-orchestrator`. Post-removal
  `git worktree list` no longer shows the throwaway path.
- The real, scheduled `worktrees\gsd-orchestrator-pilot-cadence` worktree
  (used by the live weekly task) was re-synced back to `origin/main`
  (`d141f42733fdc840535426f8938e976094248fca`) after the drill, removing any
  drill-SHA residue from the scheduled worktree.
- Seeded-SHA unreachability confirmed:
  - `git branch --all --contains 11641fcb5e7ac1c840434f3796e2eebaa68d1fe6` ->
    empty (not reachable from any local or remote-tracking branch).
  - `git branch --all --contains f85b16ecbe8e2bf4a529443c6418493c8ef91511`
    (the pre-amend seeded SHA) -> also empty.
  - `git fetch origin main` + `git rev-parse origin/main` ->
    `d141f42733fdc840535426f8938e976094248fca`, matching the pre-drill value:
    **origin/main unchanged**.
  - Seeded commit was never pushed to any remote at any point.
- Drill scratch evidence deleted: `evidence\pilot-cadence\2026-07-10.json`
  (written locally by both `-NoCommit` runs) and
  `scratch\pilot-cadence-logs\2026-07-10\` (both empty dirs also removed).
  `-NoCommit` meant neither run ever touched the real evidence
  worktree/branch/PR flow -- confirmed `worktrees\cas-workstation-pilot-cadence`
  stayed at its pre-drill commit (`b9a43be`, clean) throughout.
- No residue remains in `evidence\pilot-cadence\` history, in `scratch\pilot-cadence-logs\`,
  or in the scheduled `worktrees\gsd-orchestrator-pilot-cadence` worktree.

## Summary

| Step | Result |
|---|---|
| Seeded SHA | `11641fcb5e7ac1c840434f3796e2eebaa68d1fe6` (throwaway, never pushed) |
| Red suite | `gsd-orchestrator-fault-injection: failed` (Assert.Equal 2 != 1) |
| Issue filed | Exactly one: [gsd-orchestrator#23](https://github.com/Coding-Autopilot-System/gsd-orchestrator/issues/23) |
| Dedupe re-run | Commented on #23, issue count still 1 |
| Issue state post-drill | `closed` |
| origin/main | Unchanged (`d141f42733fdc840535426f8938e976094248fca`) |
| Throwaway worktree | Removed + pruned |
| Scratch/evidence residue | Deleted |
