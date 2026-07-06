# Phase 31-01 Summary: Workflow Lint Falsifier

**Status:** COMPLETE  
**Date:** 2026-07-06  
**Commit:** 18c38bb

## What Was Built

### `scripts/workflow-lint.ps1`
- Org-wide GitHub Actions workflow linter: detects three violation classes across all portfolio repos in a single pass.
- **`unpinned-action`**: any `uses:` step not pinned to a full 40-char commit SHA. Local (`./`) and `docker://` refs are exempted.
- **`missing-permissions`**: workflow files with no `permissions:` block at top-level or per-job.
- **`missing-timeout`**: any job missing `timeout-minutes:`.
- Skips `node_modules/**` directories to avoid flagging third-party package workflow files.
- PowerShell 5.1-compatible (ASCII-only, no ternary/null-coalescing syntax).
- Exits 0 and prints `workflow-lint: clean.` if fully compliant; exits 1 with findings table (or `-Json` output) on violations.
- Wrap-per-file try/catch: one malformed YAML file produces a `parse-error` finding and does not abort the sweep.

### `tests/Workflow.Lint.Tests.ps1`
- Falsifier proving all three compliance checks with fixture YAML under `$env:TEMP`.
- **Test 1 (clean fixture):** SHA-pinned action + top-level permissions + timeout-minutes → exits 0, zero findings.
- **Test 2 (dirty fixture):** Tag-pinned action, no permissions, no timeout → exits 1, all three check classes present.
- **Test 3 (exemption fixture):** Local `./` and `docker://` refs → exits 0, zero findings.
- Automatically picked up by root CI: `Invoke-Pester -Path tests/*.Tests.ps1 -CI`.

## Violation Inventory (Portfolio Snapshot, 2026-07-06)

Running `scripts/workflow-lint.ps1 -Path portfolio` confirms violations exist across the 13 portfolio repos — primarily:
- **`unpinned-action`**: Most repos use mutable tags (e.g., `@v4`) rather than SHA pins.
- **`missing-permissions`**: Multiple repos have no `permissions:` block.
- **`missing-timeout`**: Template and demo workflows without `timeout-minutes:`.

This inventory is the baseline for Phases 31-02 through 31-06 (remediation per-repo) and Phase 31 wave 3 (re-run to confirm clean).

## Verification

- `Invoke-Pester -Path tests\Workflow.Lint.Tests.ps1 -CI`: **exit 0, 3 assertions passed**.
- `scripts/workflow-lint.ps1 -Path portfolio`: **exit 1 with expected violations** (linter is not a no-op).
