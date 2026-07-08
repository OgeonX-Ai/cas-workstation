# Deferred Items — Phase 34 (workspace-guardrails)

## 34-01: Pre-existing Pester container failure — tests/Workstation.Contract.Tests.ps1

**Discovered during:** Task 3 verification (`Invoke-Pester -Path tests/*.Tests.ps1 -CI`)

**Status:** Out of scope for 34-01. Not fixed. Deferred.

**Details:**

`tests/Workstation.Contract.Tests.ps1` fails at Pester discovery time (throws during
script execution before any `It` blocks run, so it counts as 1 failed container, 0
tests):

```
CAS workstation contract failed:
 - defaults.configPath expected 'C:\Users\KimHarjamaki\.cas' but was 'C:\Users\KimHarjamäki\.cas'.
```

Root cause: the test hardcodes the expected `configPath` as ASCII
`C:\Users\KimHarjamaki\.cas` (line 35 of the test file), but the real
`stack.manifest.json` `defaults.configPath` is `C:\Users\KimHarjamäki\.cas` (with
the umlaut matching the actual Windows user profile directory name). These two values
can never match — this is a data/assertion mismatch between the test's hardcoded
expectation and the manifest's actual (correct) value, not an encoding artifact of
this plan's changes.

**Why deferred, not fixed:**
- Neither `tests/Workstation.Contract.Tests.ps1` nor `stack.manifest.json` is in
  34-01's `files_modified` list (`scripts/workspace-health.ps1`,
  `tests/Workspace.Health.Tests.ps1`, `.gitignore`,
  `.refiner/blackboard.snapshot.json`, `GLOBAL_AGENTS.md`).
- `git log --oneline -- tests/Workstation.Contract.Tests.ps1` shows it has been
  unchanged since the initial commit (`55a9394`) — this predates any Phase 34 work.
- Deciding whether to fix the test's hardcoded expectation or treat the manifest's
  non-ASCII `configPath` as itself a violation of the "ASCII-only" workspace hygiene
  rule this phase is introducing is a judgment call belonging to whoever owns
  `stack.manifest.json` / `Cas.Workstation.psm1` contract tests — out of scope for
  the workspace-health sweep extension plan.

**Suggested follow-up (not actioned here):** a future phase-34 plan (or a `chore`
housekeeping task) should either (a) fix the test's hardcoded expected string to
include the umlaut, or (b) if non-ASCII paths are meant to be avoided per this
phase's ASCII-hygiene goals, change `defaults.configPath` to an ASCII-safe path and
update the test accordingly.

**Verification that 34-01's own required suites are green:**
- `tests/Workspace.Health.Tests.ps1`: 6/6 passed.
- `tests/Workflow.Lint.Tests.ps1`: passed (explicitly required not to break, per task
  instructions).
- Full `tests/*.Tests.ps1` run: 6/6 individual tests passed, 1 pre-existing container
  failure (`Workstation.Contract.Tests.ps1`, unrelated, documented above).
