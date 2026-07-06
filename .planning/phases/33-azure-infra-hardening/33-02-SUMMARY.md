---
phase: 33-azure-infra-hardening
plan: 02
subsystem: infra
tags: [bicep, azure, linting, api-versions, adr, cloud-security-service-model]

# Dependency graph
requires:
  - phase: 33-01
    provides: precedent pattern for cas-platform Bicep API-version pinning (this plan is the sibling repo's equivalent)
provides:
  - use-recent-api-versions bicep lint rule enabled (warning) in cloud-security-service-model
  - Four stale resource API versions pinned to current, GA (non-preview) versions across impl/azure/landing-zone/bicep/modules/
  - ADR-001 recording the intentional DoNotEnforce policy assignment decision
affects: [33-CONTEXT, future-azure-landing-zone-work]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Prefer GA API versions over preview versions when both satisfy a linter freshness rule"
    - "For frequently-evolving resource schemas (networking), select the OLDEST acceptable API version to minimize schema-drift risk rather than the newest"
    - "ADR convention: Context/Decision/Consequences headings, sequential numbering under docs/adr/"

key-files:
  created:
    - portfolio/cloud-security-service-model/docs/adr/001-policy-assignment-enforcement-mode.md
  modified:
    - portfolio/cloud-security-service-model/bicepconfig.json
    - portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/identity.bicep
    - portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/logging-siem.bicep
    - portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/network-hubspoke.bicep
    - portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/policy-assignments.bicep

key-decisions:
  - "Used 'warning' not 'error' for use-recent-api-versions — no CI gate exists yet in this repo to enforce a hard failure"
  - "Pinned identity.bicep to 2024-11-30 (GA) over 2025-01-31-preview (no preview-only feature dependency)"
  - "Pinned logging-siem.bicep to 2025-02-01 for cross-repo consistency with cas-platform's observability.bicep, over the newer 2025-07-01"
  - "Pinned network-hubspoke.bicep (NSG + VNet) to 2024-10-01, the OLDEST acceptable version, to minimize schema-drift risk on networking resources"
  - "Pinned policy-assignments.bicep to 2025-01-01, the older of two acceptable versions, for schema stability"
  - "Kept enforcementMode: DoNotEnforce as-is — reference/stub landing zone, not a deployed environment; recorded as ADR-001 rather than silently left ambiguous or flipped without az deployment validation"

requirements-completed: [REQ-1.4.14]

# Metrics
duration: 25min
completed: 2026-07-06
---

# Phase 33 Plan 02: cloud-security-service-model Bicep Hardening + P4 ADR Summary

**Enabled use-recent-api-versions bicep lint rule and pinned four genuinely stale resource API versions (identity, logging, network x2, policy) in cloud-security-service-model's stub Azure landing zone, plus recorded the intentional DoNotEnforce policy-assignment decision as ADR-001.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-07-06 (session start)
- **Completed:** 2026-07-06
- **Tasks:** 8/8 completed
- **Files modified:** 5 modified, 1 created

## Accomplishments

- Re-enabled `use-recent-api-versions` (warning level) in `bicepconfig.json`, matching the pattern already applied in cas-platform (33-01), but this time against REAL findings — four resources across four modules genuinely failed the freshness check.
- Pinned all four stale resources to current, GA API versions with deliberate version selection reasoning (oldest-acceptable for networking to minimize schema drift, cross-repo consistency for logging, GA-over-preview for identity).
- Left `keyvault.bicep` untouched — confirmed via regression lint that it was already within the freshness window and required no change.
- Created `docs/adr/001-policy-assignment-enforcement-mode.md`, the first ADR in this repo, formally reaffirming that `enforcementMode: 'DoNotEnforce'` on the allowed-locations policy assignment is an intentional design choice for a stub/reference landing zone, not an unreviewed production gap.
- Opened PR #13 against `main` with both changes as two logically separate, reviewable commits.

## Task Commits

Each task was committed atomically (grouped into two logical commits per plan Task 8 guidance):

1. **Tasks 1-5 (bicepconfig.json + 4 API version pins)** - `687b039` (fix)
2. **Task 6 (ADR-001)** - `321e748` (docs)

Tasks 7 (build/lint gate) and 8 (PR) were verification/git-operations steps with no separate commit (Task 7 produced no file changes after removing an incidental `az bicep build` artifact; Task 8 is the push + PR creation).

**Plan metadata:** committed separately per plan protocol (this SUMMARY + STATE.md + ROADMAP.md).

## Files Created/Modified

- `portfolio/cloud-security-service-model/bicepconfig.json` - `use-recent-api-versions` off -> warning
- `portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/identity.bicep` - userAssignedIdentities API version bump
- `portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/logging-siem.bicep` - workspaces API version bump
- `portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/network-hubspoke.bicep` - networkSecurityGroups + virtualNetworks API version bumps
- `portfolio/cloud-security-service-model/impl/azure/landing-zone/bicep/modules/policy-assignments.bicep` - policyAssignments API version bump (enforcementMode untouched)
- `portfolio/cloud-security-service-model/docs/adr/001-policy-assignment-enforcement-mode.md` - new ADR (created)

## Decisions Made

- Confirmed via `git log` that local `main` and `origin/main` were already identical at plan execution time (both at `ca23302`), so the plan's stated 2-commits-behind assumption from research time no longer held — branched from `origin/main` directly per the plan's instruction anyway (no-op fetch, correct either way).
- All API version selections followed the plan's explicit reasoning exactly as specified (see key-decisions above) — no deviation from planned version choices.
- Deferred adding a `.gitignore` entry for `az bicep build` output (`main.json`) — this was an incidental artifact from my own verification command (running build without `--stdout`), not a recurring repo concern; out of the plan's declared file scope, so left untouched rather than expanding scope.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Removed incidental az bicep build artifact before commit**
- **Found during:** Task 7 (full-template build and lint gate)
- **Issue:** Running `az bicep build --file impl/azure/landing-zone/bicep/main.bicep` (without `--stdout`) wrote a compiled ARM template to `impl/azure/landing-zone/bicep/main.json` on disk, appearing as an untracked file not in the plan's `files_modified` list and not matching Task 7's acceptance criterion that `git status --short` show changes limited to the five planned files.
- **Fix:** Deleted the generated `main.json`, then re-ran the build with `--stdout` (as Task 7 originally specified) to confirm a clean exit 0 without leaving any artifact on disk.
- **Files modified:** None (artifact removed, not committed).
- **Verification:** `git status --short` after cleanup showed only the five plan-scoped files.
- **Committed in:** N/A (artifact was never staged or committed).

---

**Total deviations:** 1 auto-fixed (1 blocking/cleanup)
**Impact on plan:** No scope creep — the fix was strictly cleanup of a self-inflicted verification artifact, not a code or behavior change.

## Issues Encountered

None beyond the deviation above.

## User Setup Required

None - no external service configuration required. PR #13 is open at
https://github.com/Coding-Autopilot-System/cloud-security-service-model/pull/13 and requires
human review/merge (executor scope was PR-only, no merge or branch-protection changes).

## Next Phase Readiness

- Phase 33 P2 (Bicep hardening) and P4 (DoNotEnforce ADR) are both closed for
  cloud-security-service-model. Combined with 33-01 (cas-platform), both repos in scope for
  Phase 33 now have `use-recent-api-versions` enabled and pinned resources.
- PR #13 awaiting human merge — not a blocker for phase completion tracking, but flagged
  for follow-up.
- ADR-001 explicitly documents a follow-up obligation for any team that copies this stub
  landing zone into a real subscription: revisit `enforcementMode` before treating it as a
  production control.

---
*Phase: 33-azure-infra-hardening*
*Completed: 2026-07-06*

## Self-Check: PASSED

- FOUND: portfolio/cloud-security-service-model/docs/adr/001-policy-assignment-enforcement-mode.md
- FOUND: portfolio/cloud-security-service-model/bicepconfig.json
- FOUND: commit 687b039
- FOUND: commit 321e748
- PR #13 state: OPEN
