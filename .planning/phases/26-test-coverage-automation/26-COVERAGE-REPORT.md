# Phase 26 Coverage Report

## Status

Task 1 of `26-03` is complete.

Task 2 remains pending because the plan requires an explicit human checkpoint after the coverage report is assembled. This report packages the current evidence needed for that review.

## PR Status

| Repo | PR | Title | Status | Branch-gate evidence |
|---|---|---|---|---|
| `gsd-orchestrator` | [#16](https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/16) | `test(coverage): ratchet gsd-orchestrator branch gate` | Open, CI green | `build` passed and `PR Lint` was repaired by renaming the PR to a conventional title; the CI workflow enforces `branch-rate >= 0.7314` from cobertura |
| `autogen` | [#11](https://github.com/Coding-Autopilot-System/autogen/pull/11) | `test(coverage): ratchet autogen branch coverage gate` | Open, CI green | `Python 3.12 / ubuntu-latest` and `Python 3.12 / windows-latest` passed; the workflow emits branch telemetry and enforces `branch-rate >= 53.5` from `coverage.xml` |

## Coverage Ledger

| Repo | Task-1 baseline branch % | Final branch % | Enforced branch gate | Other enforced gate | Deferred branches / low-coverage areas |
|---|---|---:|---|---|---|
| `gsd-orchestrator` | `69.13%` (`0.6913`) | `73.14%` (`0.7314`) | `branch-rate >= 0.7314` in `.github/workflows/ci.yml` | none | `MafProcessLoopWorker.ExecuteAsync`; `CommittingState.ExecuteAsync`; `FileCheckpointStore.SaveAsync`; `GoalControlPlane.Required/StartAsync`; `SqliteGoalStore.LoadAsync/LoadOneAsync/LoadProjectionAsync`; `FileWatchStateStore.MarkProcessedAsync`; multiple workflow-state GitHub/LLM error-path methods listed in `26-01-SUMMARY.md` |
| `autogen` | Not recoverable from the current checked-in `26-02` artifacts | `53.67%` (`0.5367`) on clean PR commit `23361a1` | branch telemetry step requires `53.5%` in `.github/workflows/ci.yml` | `--cov-fail-under=73` on total coverage | `maf_starter/provider_fallback.py` (`29%`); `maf_starter/cli.py` (`0%`); `maf_starter/tools.py` (`57%`); `maf_starter/approval_policy.py` (`78%`); `maf_starter/gsd_autofill.py` (`79%`); `maf_starter/loop_workers.py` (`82%`); `maf_starter/loop_worker_cli.py` (`84%`); `maf_starter/routing_policy.py` (`85%`) |

## Autogen Evidence Gap

The current checked-in `26-02-SUMMARY.md` preserves the final clean-branch result (`53.67%`) and the superseded local checkpoint (`54.65%`), but it does not preserve the original Task-1 baseline number. This report does not fabricate that missing historical value. For `autogen`, the authoritative current truth is the clean PR commit `23361a1`, its green remote CI, and the clean-worktree coverage rerun recorded below.

## Verification Evidence

### gsd-orchestrator

- `gh pr checks 16 --repo Coding-Autopilot-System/gsd-orchestrator` is green after correcting the PR title.
- `.github/workflows/ci.yml` reads cobertura `branch-rate` and compares it to `$Baseline = 0.7314`.
- `26-01-SUMMARY.md` records the measured Task-1 baseline (`0.6913`), the raised branch gate (`0.7314`), and 37 new meaningful tests.

### autogen

- `gh pr checks 11 --repo Coding-Autopilot-System/autogen` is green.
- `.github/workflows/ci.yml` runs:
  - `python -m pytest -q --tb=short --cov --cov-branch --cov-report=xml --cov-fail-under=73`
  - a branch telemetry step that parses `coverage.xml` and fails if `branch-rate < 53.5`
- Clean-worktree rerun at PR commit `23361a1`:
  - `143 passed, 2 skipped, 1 warning, 16 subtests passed`
  - `branch-rate = 0.5367` (`53.67%`)
  - `line-rate = 0.7854` (`78.54%`)

## REQ Coverage

### REQ-1.4.1

`REQ-1.4.1` is satisfied for this ratchet phase as an enforced no-regression branch gate in both repos, with the remaining delta to 100% explicitly recorded instead of hidden.

- `gsd-orchestrator`: enforced by cobertura `branch-rate >= 0.7314` in CI, with PR `#16` green.
- `autogen`: enforced by branch telemetry `branch-rate >= 53.5` plus the total-coverage floor `--cov-fail-under=73`, with PR `#11` green and clean-branch `branch-rate = 53.67%`.

This does not claim that either repo has reached the milestone's aspirational `100%` branch target. The unmet delta is preserved in the deferred-item ledger above.

### REQ-1.4.4

`REQ-1.4.4` is satisfied by retroactive coverage work landed in both repos.

- `gsd-orchestrator`: `26-01-SUMMARY.md` records 37 new meaningful tests and the branch-rate lift from `69.13%` to `73.14%`.
- `autogen`: the coverage PR expanded the focused regression suites in `tests/test_maf_setup.py` and `tests/test_phase3_routing.py`; the clean PR commit rerun passed `143` tests total, and the focused follow-up validation for the phase-specific suites passed `40` tests plus `3` subtests in the earlier verification step recorded in `26-02-SUMMARY.md`.

## Human Checkpoint Packet

Use this packet for the blocking `26-03` review:

1. Open PR `#16` and PR `#11`.
2. Confirm the relevant CI checks are green:
   - `gsd-orchestrator`: `build` and green `PR Lint`, with `.github/workflows/ci.yml` reading cobertura `branch-rate`.
   - `autogen`: `Python 3.12 / ubuntu-latest` and `Python 3.12 / windows-latest`, with branch telemetry parsing `coverage.xml`.
3. Confirm the gate logic is branch-oriented:
   - `gsd-orchestrator`: `$xml.coverage.'branch-rate'`
   - `autogen`: `--cov-branch` plus telemetry `ET.parse(coverage_file).getroot().attrib["branch-rate"]`
4. Confirm the deferred ledger is explicit rather than implied.

## Next Action

If the operator approves the checkpoint, `26-03` can be summarized and Phase 26 can be closed cleanly.
