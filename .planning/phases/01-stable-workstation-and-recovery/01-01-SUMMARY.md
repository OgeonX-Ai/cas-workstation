---
phase: 01-stable-workstation-and-recovery
plan: "01"
subsystem: workstation
tags: [powershell, manifest, mcp, doctor]
requires: []
provides:
  - Exact C:\PersonalRepo workstation contract
  - Manifest-driven Promptimprover MCP configuration
  - Read-only MCP runtime health reporting
affects: [stable-workstation, operator-observability]
tech-stack:
  added: []
  patterns: [manifest-driven configuration, hermetic PowerShell contract tests]
key-files:
  created: [tests/Workstation.Contract.Tests.ps1, cas.ps1]
  modified: [stack.manifest.json, scripts/Cas.Workstation.psm1, doctor.ps1, schemas/doctor.schema.json, README.md, docs/support-matrix.md]
key-decisions:
  - "MCP client generation copies the shared manifest command, args, and transport without reconstructing paths."
  - "Doctor treats a missing or invalid MCP runtime as degraded health."
patterns-established:
  - "PowerShell contract tests use temporary fixtures and never apply workstation configuration."
requirements-completed: [STAB-01, STAB-02]
duration: 20min
completed: 2026-06-30
---

# Phase 1 Plan 1: Stable Workstation Contract Summary

**Exact Windows workstation paths, complete loop repository inventory, and manifest-driven Promptimprover MCP health with a dependency-free regression gate**

## Performance

- **Duration:** 20 min
- **Started:** 2026-06-30T14:39:00Z
- **Completed:** 2026-06-30T14:59:26Z
- **Tasks:** 3
- **Files modified:** 9

## Accomplishments

- Corrected the authoritative root, repository root, full profile inventory, and Universal Refiner entrypoint.
- Added a hermetic PowerShell contract runner and structured doctor MCP health.
- Added the documented `cas.ps1 setup|doctor|start` operator surface.

## Task Commits

1. **Task 1: Add RED workstation contract tests** - `750db93`
2. **Task 2: Make manifest, MCP generation, and doctor GREEN** - `c1e50f7`
3. **Task 3: Align operator documentation and run read-only smoke** - `6ffc215`

## Verification

- `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Workstation.Contract.Tests.ps1` — passed.
- Manifest and doctor schema parsed with `ConvertFrom-Json` — passed.
- Read-only doctor JSON smoke — passed; `MCP=ready`, report status `not-ready` solely because workstation tools were unavailable in the normalized process environment.

## Deviations from Plan

### Auto-fixed Issues

1. **[Rule 2 - Missing Critical] Added the documented command dispatcher** — Documentation required `cas.ps1 setup|doctor|start`, but no dispatcher existed. Added `cas.ps1` with a bounded command map.
2. **[Rule 1 - Bug] Initialized native command status for strict-mode shims** — `npm.ps1` read an unset `$LASTEXITCODE` during doctor. The command-capture boundary now initializes it before invoking PowerShell shims.
3. **[Rule 1 - Test Fixture] Made missing-runtime health hermetic** — The real Universal Refiner build existed, so the test now uses a cloned temporary manifest and missing script.

**Total deviations:** 3 auto-fixed. **Impact:** Required for a truthful operator surface and deterministic Windows PowerShell verification; no global configuration was changed.

## Issues Encountered

- Two initial smoke commands used shell-expanded PowerShell variables or an invalid explicit temp path. Corrected commands used a PowerShell-resolved `$env:TEMP`; product behavior was unaffected.

## User Setup Required

None.

## Next Phase Readiness

- Root workstation contract is green.
- Ready for failed-state recovery work in the isolated `gsd-orchestrator` worktree.

## Self-Check: PASSED

---
*Phase: 01-stable-workstation-and-recovery*
*Completed: 2026-06-30*
