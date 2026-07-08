---
phase: 34-workspace-guardrails
plan: 01
subsystem: workspace-health-sweep
tags: [powershell, pester, git-hygiene, ci, ascii-guard]
requires: []
provides:
  - workspace-health.ps1 checks 6-11 (stale-pr, credential-helper-wsl-path,
    stack-manifest-version, non-ascii-ps1, unclassified-housekeeping-dir)
  - tests/Workspace.Health.Tests.ps1 red-fixture Pester coverage
  - GLOBAL_AGENTS.md Azure hard-lock + Workspace Hygiene Locks sections
affects:
  - CI Pester run (tests/*.Tests.ps1)
  - future Task Scheduler / CI gating on workspace-health.ps1 exit code
tech-stack:
  added: []
  patterns:
    - "Console/native-command output encoding forced to UTF-8 at script top
      to survive non-ASCII paths (PS 5.1 OEM-codepage decoding bug)"
    - "-Json mode suppresses all Write-Host output to keep the JSON stream
      machine-parseable when invoked as a nested powershell -File child"
key-files:
  created:
    - tests/Workspace.Health.Tests.ps1
    - .planning/phases/34-workspace-guardrails/deferred-items.md
  modified:
    - scripts/workspace-health.ps1
    - GLOBAL_AGENTS.md
    - .gitignore
decisions:
  - "GLOBAL_AGENTS.md Azure hard-lock and Workspace Hygiene Locks sections
    were committed in THIS plan (34-01) per direct executor instruction,
    superseding 34-01-PLAN.md's original success_criteria line that deferred
    GLOBAL_AGENTS.md changes to 34-02."
  - "Pre-existing tests/Workstation.Contract.Tests.ps1 Pester container
    failure (unrelated hardcoded-ASCII-vs-actual-umlaut config path
    mismatch) is out of scope and logged to deferred-items.md rather than
    fixed, per Scope Boundary rule — neither file is in 34-01's
    files_modified list and both predate this plan (commit 55a9394)."
metrics:
  duration: "~90 minutes across investigation, fixes, and 4 commits"
  completed: 2026-07-07
---

# Phase 34 Plan 01: Workspace-health sweep extensions + Pester coverage Summary

Extended `scripts/workspace-health.ps1` with the 6 planned drift checks (stale PRs,
WSL-style credential helper, stack.manifest.json version drift, non-ASCII `.ps1`
guard, refiner-blackboard-ignore documentation, unclassified housekeeping dirs),
added a full 6-test Pester red-fixture suite, and closed out GLOBAL_AGENTS.md's
uncommitted Azure hard-lock + new Workspace Hygiene Locks documentation.

## What Was Done

**Task 1 (`.refiner/blackboard.json` gitignore + snapshot):** Already complete and
committed prior to this session (commit `87b7273`). Verified: `git check-ignore -v
.refiner/blackboard.json` succeeds, `.refiner/blackboard.snapshot.json` exists and is
tracked.

**Task 2 (sweep extensions):** Checks 6-11 were already implemented in the working
tree (uncommitted) from a prior interrupted attempt. Verified the sweep runs cleanly
end-to-end (`powershell -NoProfile -File scripts\workspace-health.ps1 -Json`) and
found + fixed two real bugs surfaced during verification:

1. **JSON-mode `Write-Host` leak (Rule 1 — bug):** The trailing summary lines
   (`workspace-health: N finding(s).` / `workspace-health: clean.`) ran
   unconditionally regardless of `-Json`, and when the script is invoked as a nested
   `powershell.exe -File` child process (exactly how CI/Pester invoke it), that
   `Write-Host` text gets folded into the same captured stdout stream as the JSON,
   producing `Invalid JSON primitive` errors for any programmatic consumer. Fixed by
   suppressing all `Write-Host` output when `-Json` is set.
2. **OEM-codepage corruption of non-ASCII git output (Rule 1 — bug):** PS 5.1's
   default console/native-command output encoding is the legacy OEM codepage
   (`ibm850` on this machine), which corrupts UTF-8 bytes git writes for
   paths/branches/config values containing non-ASCII characters — concretely, this
   machine's own user profile directory (`C:\Users\KimHarjamäki`) triggered a
   false `worktree-missing` finding for a repo's own primary worktree, since
   `Test-Path` on the corrupted path string returned false. Fixed by forcing
   `[Console]::OutputEncoding` and `$OutputEncoding` to UTF-8 at script start.

Both fixes are general-purpose (not test-only workarounds) and materially improve the
sweep's correctness for any repo path containing non-ASCII characters, which is a
real condition on this exact workstation.

Also added the `$env:WH_SKIP_GH` guard on the `gh pr list` block (Rule 2 — missing
critical functionality for offline/CI reliability) so the stale-PR check can be
disabled without needing a real `gh` auth session — used by the new Pester suite.

**Task 3 (Pester red-fixture suite):** Wrote `tests/Workspace.Health.Tests.ps1` from
scratch (idiomatic Pester 5 `Describe`/`Context`/`It`, matching the CI invocation
`Invoke-Pester -Path tests/*.Tests.ps1 -CI`). All fixtures are built under
`$env:TEMP` with GUID-suffixed unique directories and cleaned up in `AfterAll`
blocks — nothing touches the real `C:\PersonalRepo` tree. Six tests, one per behavior
from the plan:

1. Clean baseline fixture -> only `no-upstream` finding (proves no false positives on
   a minimal clean repo).
2. Orphaned untracked file -> `dirty` finding.
3. Unpushed commit against a local bare-repo origin -> `unpushed` finding, count 1.
4. Synthetic `stack.manifest.json` with `minimumVersion: "999.0.0"` for `git`
   (copied alongside a real copy of `Cas.Workstation.psm1`) -> `stack-manifest-version`
   finding.
5. Runtime-generated non-ASCII `.ps1` file (em-dash via `[char]0x2014`, written with
   `[System.IO.File]::WriteAllText(...,[System.Text.Encoding]::UTF8)`) ->
   `non-ascii-ps1` finding.
6. `credential.helper` written directly into `.git/config` (bypassing PowerShell
   native-argument quoting issues with embedded `!"..."` syntax) with a WSL `/mnt/`
   path -> `credential-helper-wsl-path` finding.

The credential.helper fixture writes directly to `.git\config` rather than via
`git config credential.helper '...'` because passing a value containing embedded
double-quotes through PowerShell's native-command argument marshaling
(`! "/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential`) reliably produced
`error: no action specified` from git — a PowerShell/Windows argv quoting quirk, not
a script bug. Writing the INI section directly sidesteps it entirely and is more
deterministic for a fixture anyway.

**GLOBAL_AGENTS.md (explicit executor task, superseding the original plan's deferral
to 34-02):**
- Split-staged and committed the pre-existing uncommitted Azure hard-lock section
  (`docs(agents): record Azure deploy hard lock from operator session`) as its own
  commit, unmodified from what was already in the working tree.
- Added and committed a new "Workspace Hygiene Locks" section documenting the two
  hygiene rules this plan's sweep now enforces: no WSL-created worktrees, and `.ps1`
  files must be ASCII-only or explicitly UTF-8-with-BOM
  (`docs(agents): add workspace hygiene locks`).

**`.gitignore`:** Added `testResults.xml` (Pester `-CI`'s default JUnit-style output
file, regenerated by every local/CI Pester run) to prevent it from showing up as a
perpetually-dirty untracked file — the exact "unbounded drift" failure class this
phase exists to close.

## Verification

- ASCII-only check: `LC_ALL=C.UTF-8 grep -cP '[^\x00-\x7F]' scripts/workspace-health.ps1`
  = 0; same check on `tests/Workspace.Health.Tests.ps1` = 0.
- `powershell -NoProfile -File scripts\workspace-health.ps1 -Json` runs to completion,
  exits 1 (findings exist on the real dirty tree, as expected), emits clean parseable
  JSON with no trailing text.
- `Invoke-Pester -Path tests/Workspace.Health.Tests.ps1 -CI`: 6/6 passed.
- `Invoke-Pester -Path tests/*.Tests.ps1 -CI` (full suite): 6/6 individual tests
  passed (`Workspace.Health.Tests.ps1`); `Workflow.Lint.Tests.ps1` and
  `Workstation.Contract.Tests.ps1`'s sibling custom-assert scripts
  (`CAS loop pilot evidence`, `CAS loop pilot contract`) all pass. One pre-existing,
  unrelated container failure documented below.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `-Json` mode leaked `Write-Host` summary text into stdout**
- **Found during:** Task 3 verification (Pester `Invoke-Wh` helper failed to parse
  JSON output from a nested `powershell -File` invocation).
- **Issue:** The script's final block ran `Write-Host "workspace-health: N
  finding(s)."` / `"...clean."` unconditionally, even in `-Json` mode. Nested
  `powershell.exe -File` child processes fold `Write-Host` output into the same
  captured stdout stream, corrupting the JSON.
- **Fix:** Suppress all `Write-Host` output when `-Json` is set; JSON is now the sole
  stdout content in that mode.
- **Files modified:** `scripts/workspace-health.ps1`
- **Commit:** `eff903b`

**2. [Rule 1 - Bug] OEM-codepage console encoding corrupted non-ASCII git output**
- **Found during:** Task 3 verification (real fixture under `$env:TEMP`, whose path
  includes this machine's non-ASCII username, produced a false `worktree-missing`
  finding for its own primary worktree).
- **Issue:** PS 5.1 defaults `[Console]::OutputEncoding` to the legacy OEM codepage
  (`ibm850` here), which mis-decodes UTF-8 bytes git writes for non-ASCII
  paths/branches/config values, breaking string/`Test-Path` comparisons downstream.
- **Fix:** Force `[Console]::OutputEncoding` and `$OutputEncoding` to UTF-8 at script
  start, before any git invocation.
- **Files modified:** `scripts/workspace-health.ps1`
- **Commit:** `eff903b`

### Auto-added Functionality

**3. [Rule 2 - Missing critical functionality] `$env:WH_SKIP_GH` offline guard**
- **Trigger:** Task instructions explicitly called for an env guard so the gh-backed
  stale-PR check doesn't force a network dependency on Pester runs.
- **Action:** Added `$env:WH_SKIP_GH` check alongside the existing `Get-Command gh`
  gate on the stale-PR block; set in the Pester suite's `BeforeAll`.
- **Files modified:** `scripts/workspace-health.ps1`, `tests/Workspace.Health.Tests.ps1`
- **Commit:** `eff903b`, `a108593`

**4. [Rule 2 - Missing critical functionality] gitignore `testResults.xml`**
- **Trigger:** `Invoke-Pester -CI` (used both here and in `.github/workflows/ci.yml`)
  writes `testResults.xml` to the repo root by default, which showed up as a new
  untracked file after verification runs — exactly the class of drift this phase
  exists to prevent.
- **Action:** Added `testResults.xml` to `.gitignore`.
- **Files modified:** `.gitignore`
- **Commit:** `f0f5cc5`

### Scope Adjustment (explicit executor instruction)

**5. GLOBAL_AGENTS.md handled in 34-01, not deferred to 34-02**
34-01-PLAN.md's own success_criteria stated "GLOBAL_AGENTS.md unchanged in this plan
(prevention note deferred to 34-02...)". The invoking task for this session explicitly
instructed committing the Azure hard-lock hunk and adding a Workspace Hygiene Locks
section as part of 34-01. Followed the direct instruction; documented here since it
diverges from the plan file's own stated scope.

## Deferred / Out of Scope

**Pre-existing `tests/Workstation.Contract.Tests.ps1` container failure** — fails at
Pester discovery time comparing a hardcoded ASCII expected string
(`C:\Users\KimHarjamaki\.cas`) against `stack.manifest.json`'s actual value
(`C:\Users\KimHarjamäki\.cas`, with the umlaut matching the real Windows profile
directory). Confirmed via `git log -- tests/Workstation.Contract.Tests.ps1` and `git
status` that neither file has been touched in this session or by any Phase 34 work —
predates this plan (commit `55a9394`). Not in 34-01's `files_modified` list. Logged
in full detail, including a suggested fix direction, to
`.planning/phases/34-workspace-guardrails/deferred-items.md`.

## Known Stubs

None.

## Threat Flags

None — all new surface (gh shellout, filesystem scan, Pester fixtures) was already
covered by 34-01-PLAN.md's threat model (T-34-01 through T-34-04), and the
mitigations described there (gh guarded + try/catch, fixtures confined to
`$env:TEMP`, findings report paths/check-names only) are implemented as specified.

## Commits

| Commit | Message |
|--------|---------|
| `5a8d734` | docs(agents): record Azure deploy hard lock from operator session |
| `f739251` | docs(agents): add workspace hygiene locks |
| `eff903b` | feat(34-01): extend workspace-health sweep with 6 drift checks |
| `a108593` | test(34-01): add red-fixture Pester suite for workspace-health |
| `f0f5cc5` | chore(34-01): ignore Pester -CI testResults.xml artifact |

## Self-Check: PASSED

- `scripts/workspace-health.ps1` — FOUND (extended, committed in `eff903b`)
- `tests/Workspace.Health.Tests.ps1` — FOUND (created, committed in `a108593`)
- `.gitignore` — FOUND (updated, committed in `f0f5cc5`; `.refiner/blackboard.json`
  entry was already present from prior commit `87b7273`)
- `.refiner/blackboard.snapshot.json` — FOUND (already tracked from prior commit
  `87b7273`)
- `GLOBAL_AGENTS.md` — FOUND (Azure lock in `5a8d734`, hygiene locks in `f739251`)
- `.planning/phases/34-workspace-guardrails/deferred-items.md` — FOUND (created this
  session, untracked pending orchestrator commit of `.planning/` state)
- Commit `5a8d734` — FOUND in `git log --oneline --all`
- Commit `f739251` — FOUND in `git log --oneline --all`
- Commit `eff903b` — FOUND in `git log --oneline --all`
- Commit `a108593` — FOUND in `git log --oneline --all`
- Commit `f0f5cc5` — FOUND in `git log --oneline --all`
