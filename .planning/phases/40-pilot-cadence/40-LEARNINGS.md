<!-- Canonical template referenced by /gsd:extract-learnings and by
     engineering-os/OPERATING-CONTRACT.md's Phase-Close Learning Extraction checklist. -->

---
phase: 40
phase_name: "Pilot Cadence"
project: "cas-workstation (PersonalRepo)"
generated: "2026-07-11"
counts:
  decisions: 4
  lessons: 5
  patterns: 3
  surprises: 1
missing_artifacts:
  - "40-01-SUMMARY.md and 40-02-SUMMARY.md at time of writing lived only on branch origin/feat/phase-40-pilot-cadence (PRs cas-workstation#13/#14), not yet merged to origin/master"
---

# Phase 40 Learnings: Pilot Cadence

## Decisions

### Evidence committed via a dedicated worktree + PR, never a direct commit to the primary checkout
`run-pilot-cadence.ps1` commits its dated evidence JSON via a separate
`worktrees/cas-workstation-pilot-cadence` worktree and an `evidence/pilot-cadence-{date}` branch,
opening (or reusing, on same-day re-run) a PR against `master`. The primary `C:\PersonalRepo`
working tree — which had unrelated in-progress work on another branch throughout this phase — is
never staged, committed, or checked out against.

**Rationale:** A weekly-scheduled automated task must not risk colliding with, or silently
committing on top of, whatever branch a human operator happens to have checked out at the moment
the scheduled task fires.
**Source:** 40-01-SUMMARY.md ("What Was Built", "Isolation Verification")

### Suite execution isolated via read-only worktrees synced against the source repo's own remote
Each of the two portfolio sub-repo suites (`gsd-orchestrator-fault-injection`,
`autogen-fault-injection`) runs from a dedicated detached-HEAD worktree, fetch-only against the
source repo, never touching that repo's own primary checkout or currently-checked-out branch —
even when the primary checkout is itself dirty and parked on an unrelated feature branch.

**Rationale:** The pilot-cadence runner must be safe to run at any time, regardless of what a
human or another agent currently has checked out in the same sub-repo.
**Source:** 40-01-SUMMARY.md (tech-stack patterns: "Sync-ReadOnlyWorktree")

### Live weekly Windows Scheduled Task registered idempotently, mirroring the existing workspace-health pattern
`register-pilot-cadence-task.ps1` mirrors `register-workspace-health-task.ps1`'s idempotent
Get-ScheduledTask-check-then-Set-or-Register pattern, deliberately omitting that script's
`Test-Path`-based "script not found" pre-check because `run-pilot-cadence.ps1` did not yet exist
at the production path at registration time (only in the plan's worktree, pending merge) — Windows
Task Scheduler does not validate the target script's existence at registration time, so this is
safe.

**Rationale:** Reuse a proven pattern exactly where it applies, but consciously diverge where a
literal pre-check would block a legitimate pre-merge registration.
**Source:** 40-02-SUMMARY.md ("Decisions Made")

### A falsifier drill must be end-to-end and throwaway, never merged to any real branch
REQ-1.5.4's second falsifier (seeded regression auto-files an issue within one cycle) was proven
using a never-pushed `gsd-orchestrator` worktree commit: red suite -> issue filed -> dedupe
comment on rerun -> issue closed -> full cleanup, with `origin/main` unchanged and the seeded SHA
confirmed unreachable from any branch afterward.

**Rationale:** Proving an alerting mechanism works requires actually triggering it with a real
failure, but that failure must never contaminate any branch a human or CI would ever see.
**Source:** 40-02-SUMMARY.md ("Accomplishments"); 42-PREVERIFICATION.md ("Seeded SHA unreachable" — independently re-verified via `gh api .../commits/<sha>` returning 422)

---

## Lessons

### PowerShell 5.1's native-command argument marshalling corrupts embedded double-quote characters — this silently broke issue dedupe
`file-pilot-regression-issue.ps1`'s dedupe search built `--search "in:title `"$Title`""`
(embedding literal `"` characters inside the PowerShell string passed to `gh.exe`). Windows
PowerShell 5.1's native-command argument marshalling corrupts arguments containing embedded double
quotes, splitting the phrase into separate unrecognized tokens
(`gh.exe : unknown arguments ["gsd-orchestrator-fault-injection" "regression"]`). This made
`gh issue list` fail on **every** call, so the dedupe check always failed closed (no existing
issue ever found) — meaning every future rerun would have filed a **new** duplicate issue instead
of commenting on the existing one, directly defeating REQ-1.5.4's dedupe falsifier.

**Context:** The bug was introduced in 40-01 and only surfaced when 40-02's own falsifier drill
exercised the dedupe path for the first time — a bug that would have silently broken the
mechanism's core promise (no duplicate spam) on every real future regression, undetected until
then.
**Source:** 40-02-SUMMARY.md ("Deviations from Plan" — Rule 1 auto-fix #1)

### The fix: don't wrap the search phrase in embedded quotes at all — rely on client-side exact-match filtering instead
Removed the embedded-quote wrapping (`"in:title $Title"` instead of `"in:title `"$Title`""`),
safe because the script already filters results client-side to an exact title match
(`Where-Object { $_.title -eq $Title }`) — so GitHub's own substring/token search does not need
query-side exact phrasing.

**Context:** The general rule: when a `gh` CLI query string must round-trip through PowerShell
5.1's native-arg marshalling, avoid embedding literal double-quote characters inside the argument
value if there's a way to make the search looser and rely on client-side post-filtering for
precision instead.
**Source:** 40-02-SUMMARY.md ("Deviations from Plan" — Rule 1 auto-fix #1, "Fix")

### A hardcoded `fetch origin main` inside a reused helper broke on a repo whose default branch is `master`
The plan's literal `Sync-ReadOnlyWorktree` text specified a hardcoded
`git -C $SourceRepo fetch origin main` best-effort step, but the same helper is reused for the
root repo's evidence worktree with `$Ref = 'origin/master'` — and the root repo's remote has no
`main` branch at all, so the hardcoded fetch threw `fatal: couldn't find remote ref main`.

**Context:** Combined with the PS 5.1 stderr-promotion bug below, this uncaught fatal aborted the
entire run on first real execution.
**Source:** 40-01-SUMMARY.md ("Deviations from Plan" — Rule 1 auto-fix #1)

### PowerShell 5.1 promotes native-command stderr to terminating errors under `$ErrorActionPreference = 'Stop'`, even for explicitly "best-effort" steps
Windows PowerShell 5.1 wraps any native-command stderr line captured via `2>&1` as an
`ErrorRecord`; with `$ErrorActionPreference = 'Stop'` in effect, the first such record throws a
terminating exception and aborts the whole script — even for operations the plan explicitly
designed to be non-fatal (the offline-tolerant fetch), and even inside suite scriptblocks meant to
only be caught via non-zero `$LASTEXITCODE`.

**Context:** This is exactly the failure mode the plan's own instruction ("capture
`$LASTEXITCODE` per suite instead of letting `-Stop` throw on a non-zero exit") anticipates, but
the literal per-call pattern described in the plan text doesn't actually prevent it under PS 5.1
specifically (the same code would behave differently under PowerShell 7+). Fixed with an
`Invoke-CapturedCommand` helper that temporarily sets `$ErrorActionPreference = 'Continue'` around
every native call, capturing combined stdout+stderr as plain text.
**Source:** 40-01-SUMMARY.md ("Deviations from Plan" — Rule 1 auto-fix #2)

### A seeded drill's test class name must actually match the runner's own filter substring, or the suite silently reports a false "passed"
The first drill attempt seeded a test class named `DrillSeededFailureTests`, which did not contain
the substring `FaultInjectionTests` or `CheckpointCorruptionTests` that
`run-pilot-cadence.ps1`'s `dotnet test --filter` expression selects on — so the seeded test was
never even run, and the suite reported a false "passed" instead of the expected red result.

**Context:** Renamed to `DrillFaultInjectionTests` (containing the required substring) and
re-ran; the drill only became trustworthy evidence after this fix. A drill that "passes" when it
should fail is a worse outcome than an honest failure to run — it looks like proof when it proves
nothing.
**Source:** 40-02-SUMMARY.md ("Deviations from Plan" — Rule 1 auto-fix #2, "Patterns Established")

---

## Patterns

### Falsifier drills must name test fixtures to match the runner's own filter substrings
Established directly from the seeded-test-name mismatch above: any future falsifier drill that
seeds a failing test into a filtered suite must first confirm the seed's fully-qualified name
actually matches the runner's `--filter`/`-k` expression, or the drill silently proves nothing.

**When to use:** Any drill or fault-injection exercise that relies on a test runner's name-based
filter to select the seeded failure.
**Source:** 40-02-SUMMARY.md (patterns-established)

### `gh.exe` invocations from PowerShell 5.1 must avoid embedding literal double-quote characters in argument strings
Established directly from the dedupe-search bug above — a durable rule for any future script on
this workstation that shells out to `gh` from PowerShell 5.1 (not PowerShell 7+, which handles
native-arg marshalling differently).

**When to use:** Any `gh` CLI invocation from a `.ps1` script targeting Windows PowerShell 5.1,
where the argument value might contain spaces or would otherwise be quoted.
**Source:** 40-02-SUMMARY.md (tech-stack patterns)

### Windows Task Scheduler idempotent registration: check-then-Set-or-Register
`Get-ScheduledTask -TaskName` check, then `Set-ScheduledTask` (if it exists) or
`Register-ScheduledTask` (if it doesn't) — verified live by running the registration script twice
and confirming exactly one task exists afterward.

**When to use:** Any script that registers a recurring Windows Scheduled Task and must be safe to
re-run (e.g., on every phase re-execution or CI re-run) without creating duplicates.
**Source:** 40-02-SUMMARY.md ("Accomplishments", tech-stack patterns)

---

## Surprises

### REQ-1.5.4's "2 consecutive weekly runs" falsifier is legitimately time-gated, not a code gap
Only one dated evidence artifact existed at phase-close time
(`evidence/pilot-cadence/2026-07-10.json`) — a second week had not yet elapsed since the scheduled
task's first `StartBoundary`. Phase 42's pre-verification explicitly flagged this as
**expected, not a defect**, deferring the falsifier's full confirmation to the task's second
Monday firing rather than treating it as an incomplete implementation.

**Impact:** Not every falsifier can be satisfied at plan-execution time — some are inherently
time-gated by their own definition (e.g., "N consecutive weekly runs"), and a verification pass
must distinguish "not yet met because time hasn't passed" from "not yet met because the mechanism
doesn't work." Conflating the two would either falsely block phase-close on something outside the
plan's control, or falsely pass a mechanism that hasn't actually been proven over real elapsed
time.
**Source:** 42-PREVERIFICATION.md ("Phase 40 — Pilot Cadence" table, "REQ-1.5.4 falsifier: evidence for 2 consecutive weekly runs")
