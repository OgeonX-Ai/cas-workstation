# Phase 28-02 Summary

## Outcome

Added shared, structured JSON failure telemetry to the Microsoft Agent
Framework workers in `autogen` and closed the remaining C6 subprocess
size-limit gap, proven by fault-injection tests that simulate a
primary-provider API outage and capture/parse the resulting stderr log
lines. REQ-1.4.3 is satisfied: the existing try/catch boundaries in
`provider_fallback.py` and `worker_boundary.py` already caught failures
correctly — this plan adds the missing observable telemetry emission on top
of them, without changing any existing return values, exception types, or
control flow. Work is committed and pushed on `feat/phase-28-fault-injection`
with an open PR; nothing merged.

## Delivered

- Added `maf_starter/telemetry.py`
  - `emit_failure_telemetry(event: str, **fields) -> None` — stdlib-only
    (`json`, `sys`, `datetime`), writes one flushed, single-line JSON object
    (`{"event", "timestamp", **fields}`) to stderr, and never raises (wraps
    the write in `try/except Exception: return` so a telemetry failure can
    never mask the real error being reported by the caller).
- Wired `emit_failure_telemetry` into `maf_starter/provider_fallback.py`:
  - `fallback_middleware` (non-streaming path) and `_wrap_stream_with_fallback`
    (streaming path) both now emit, at the matching points already caught by
    the existing `except Exception` blocks:
    - `provider_failed` — immediately after the primary-provider exception is
      caught (fields: `provider`, `model`, `error`)
    - `fallback_step_failed` — immediately after each fallback step's own
      except block appends its failed `RouteAttempt` (fields: `provider`,
      `model`, `error`, `fallback_index`)
    - `fallback_succeeded` — at the point a fallback step succeeds after the
      primary failed (fields: `provider`, `model`, `primary_error`)
    - `fallback_exhausted` — immediately before `raise last_error` when the
      fallback loop completes without success (fields: `primary_provider`,
      `attempted_providers`, `final_error`)
  - Added `MAX_CLI_OUTPUT_BYTES = 1_000_000` and `MAX_CLI_PROMPT_BYTES = 1_000_000`
    module-level constants (same 1MB ceiling as `loop_worker_cli.py`'s
    existing `MAX_REQUEST_BYTES` convention — confirmed that guard required
    no changes).
  - `_run_subprocess` now raises `RuntimeError(f"{provider_name} output
    exceeds {MAX_CLI_OUTPUT_BYTES} bytes")` when captured CLI-fallback stdout
    exceeds the cap, checked before the existing empty-output check.
  - `_messages_to_prompt` now raises `ValueError(f"Rendered CLI prompt
    exceeds {MAX_CLI_PROMPT_BYTES} bytes")` when the rendered prompt handed
    to gemini-cli/claude-cli/codex-cli exceeds the cap.
- Wired `emit_failure_telemetry` into `maf_starter/worker_boundary.py`:
  - `WorkerBoundary._run`'s existing `except Exception as exc:` block now
    also calls `emit_failure_telemetry("worker_task_failed", run_id=run_id,
    error=str(exc))` alongside the existing `self._status[run_id] =
    f"error:{exc}"` assignment. The status-string contract
    (`get_status`/`is_done` semantics) is unchanged.
- Added `tests/test_provider_fallback_telemetry.py`
  - `emit_failure_telemetry` writes exactly one parseable JSON line with the
    expected fields, and never raises even when the underlying `sys.stderr`
    write itself fails.
  - A simulated primary-provider outage (`"rate limit"` marker, matching
    `FALLBACK_ERROR_MARKERS`) through `fallback_middleware` with all
    fallback steps also failing produces ordered telemetry: `provider_failed`
    → `fallback_step_failed` (x2) → `fallback_exhausted`.
  - The same simulated outage with a later fallback step succeeding produces
    `provider_failed` → `fallback_succeeded`, with no `fallback_exhausted`
    line, proving telemetry correctly distinguishes recovery from
    exhaustion.
  - `_run_subprocess` rejects oversized captured stdout with `"output
    exceeds N bytes"`.
  - `_messages_to_prompt` rejects an oversized rendered prompt with
    `"Rendered CLI prompt exceeds N bytes"`.
- Extended `tests/test_worker_boundary.py`
  - `test_status_records_error_on_exception` now also captures stderr and
    asserts the emitted `worker_task_failed` telemetry line parses to JSON
    containing the correct `run_id` and `error`.

## Verification Evidence

- `python -m pytest tests/test_provider_fallback_telemetry.py tests/test_worker_boundary.py -v`
  - passed `16/16`
- `python -m pytest tests/test_phase3_routing.py tests/test_maf_setup.py -v`
  - passed `24/24` (regression check on adjacent routing/middleware tests)
- Full suite: `python -m pytest tests/ -q`
  - passed `134 passed, 1 skipped, 16 subtests passed` — no regressions
- All commands run from the repo-local virtualenv at
  `C:\PersonalRepo\portfolio\autogen\.venv\Scripts\python.exe`, keeping
  validation aligned to `requirements.txt` rather than ambient system
  packages.

## Important Execution Detail

This dedicated worktree (`feat/phase-28-fault-injection`, branched from
`origin/main` at `e52e6aa`) already contained a complete, uncommitted
implementation of this exact plan when this execution session began —
`maf_starter/telemetry.py`, `tests/test_provider_fallback_telemetry.py`, and
the corresponding edits to `provider_fallback.py` and `worker_boundary.py`
were present but uncommitted, apparently from a prior interrupted session
(a stale draft of this same SUMMARY.md was also present, with no commit
hashes or PR link, confirming the branch had never been pushed). The
implementation and tests were reviewed line-by-line against the plan's
`<behavior>`, `<action>`, and `<acceptance_criteria>` sections, found to
match exactly (correct event names, correct field names, correct call sites
in both streaming and non-streaming paths, correct 1MB size constants
mirroring `loop_worker_cli.py`'s convention), verified by running the full
test suite, and then committed, pushed, and opened as a PR for this plan's
output rather than being rewritten from scratch. No production-code
deviations from the plan were needed.

The `autogen` sub-repo's primary working tree
(`C:\PersonalRepo\portfolio\autogen`, branch `feat/phase-26-coverage-gates`,
open PR #11) has unrelated dirty foreign files from parallel sessions and
was never touched — all work for this plan was done in the dedicated
`feat/phase-28-fault-injection` git worktree at
`C:\PersonalRepo\portfolio\autogen\PersonalRepoworktreesautogen-phase-28`.

## Commits

- `bfbec1b` — `feat(28-02): emit structured JSON failure telemetry in provider fallback and cap CLI subprocess size`
  (`maf_starter/telemetry.py`, `maf_starter/provider_fallback.py`,
  `tests/test_provider_fallback_telemetry.py`)
- `6208345` — `feat(28-02): emit structured telemetry from WorkerBoundary background task failures`
  (`maf_starter/worker_boundary.py`, `tests/test_worker_boundary.py`)

## Pull Request

https://github.com/Coding-Autopilot-System/autogen/pull/12 (open, not merged)

## Next Phase Readiness

Phase `28` is complete across both planned slices (`28-01` in
`gsd-orchestrator`, `28-02` in `autogen`), together closing REQ-1.4.3's
fault-injection and structured-telemetry requirements for their respective
sub-repos, pending PR review/merge for `#12`.

## Self-Check: PASSED

- FOUND: `maf_starter/telemetry.py`
- FOUND: `tests/test_provider_fallback_telemetry.py`
- FOUND: `maf_starter/provider_fallback.py`
- FOUND: `maf_starter/worker_boundary.py`
- FOUND: `tests/test_worker_boundary.py`
- FOUND commit: `bfbec1b`
- FOUND commit: `6208345`
- CONFIRMED: PR #12 open at https://github.com/Coding-Autopilot-System/autogen/pull/12
