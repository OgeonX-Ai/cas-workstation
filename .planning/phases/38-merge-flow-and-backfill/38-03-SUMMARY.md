---
phase: 38-merge-flow-and-backfill
plan: 03
subsystem: infra
tags: [github, branch-protection, codeowners, governance]

requires:
  - phase: 38-merge-flow-and-backfill
    plan: 01
    provides: apply-branch-protection.ps1 as-code mechanism
provides:
  - Root repo (OgeonX-Ai/cas-workstation) CODEOWNERS assigning "*" to the operator identity
  - Root repo Root repo policy section in docs/merge-flow-policy.md recording the decision
  - Verified-live root branch protection (satisfied-by-live-state, PR #7)
affects: [REQ-1.5.2]

tech-stack:
  added: []
  patterns: ["satisfied-by-live-state: verify an already-live posture via gh api rather than re-applying a decision already in effect"]

key-files:
  created:
    - CODEOWNERS
  modified:
    - docs/merge-flow-policy.md
    - docs/merge-train-runbook.md
    - scripts/apply-branch-protection.ps1

key-decisions:
  - "checkpoint:decision auto-selected pr-flow-review (RECOMMENDED / operator standing choice) per auto-mode checkpoint handling and the orchestrator's explicit instruction that this is the standing choice"
  - "Root repo does NOT get the review-bot App installed (separate GitHub org, low PR volume does not justify a second App install) -- plain PR-flow-with-review closes the actual gap"
  - "require_code_owner_reviews left at its live value (false) rather than flipped to true for real, since protection application for root was explicitly -DryRun-only for this plan; -RequireCodeOwnerReviews evidence captured, not applied"

patterns-established: []

requirements-completed: [REQ-1.5.2]

duration: 20min
completed: 2026-07-10
---

# Phase 38 Plan 03: Root repo branch-protection codification Summary

**Root repo (OgeonX-Ai/cas-workstation) CODEOWNERS added and its already-live PR-flow-with-review posture (enforce_admins + 1 approval, landed via PR #7) codified and documented via the shared apply-branch-protection.ps1 mechanism, closing REQ-1.5.2's root-protection item.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-07-10T14:27:00Z (approx, immediately following 38-01)
- **Completed:** 2026-07-10T14:47:00Z
- **Tasks:** 2 of 2 (checkpoint:decision auto-selected, Task 2 executed)
- **Files modified:** 4 (1 created, 3 modified -- 2 of the 3 modified files were touched jointly with Plan 38-01's commits since they share the same policy doc and script)

## Accomplishments
- `CODEOWNERS` at root assigns `*` to `@OgeonX-Ai` (the operator's real GitHub identity, confirmed via `gh api user --jq .login`), so required review always resolves to a non-agent reviewer.
- Verified via `gh api repos/OgeonX-Ai/cas-workstation/branches/master/protection` that root protection is already live: `required_approving_review_count=1`, `enforce_admins.enabled=true`.
- `docs/merge-flow-policy.md` Root repo section records the decision, rationale, and the satisfied-by-live-state status.
- `apply-branch-protection.ps1` extended with `-RequireCodeOwnerReviews` so the CODEOWNERS assignment can be enforced when protection is next applied for real.

## Task Commits

All on the root repo, branch `feat/phase-38-merge-flow` (PR OgeonX-Ai/cas-workstation#18), continuing directly from Plan 38-01's commits on the same branch:

1. **Task 1 (checkpoint:decision, auto-selected pr-flow-review):** no separate commit -- decision recorded directly in `docs/merge-flow-policy.md` Root repo section, committed as part of `dc0fdd9` (38-01 Task 1) and finalized in `2328dca`.
2. **Task 2: CODEOWNERS + codify root posture** - `2328dca` (feat)

## Files Created/Modified
- `CODEOWNERS` - root ownership, `*` -> `@OgeonX-Ai`
- `docs/merge-flow-policy.md` - Root repo section (decision, rationale, satisfied-by-live-state)
- `docs/merge-train-runbook.md` - notes root is PR-flow, points to the enforce_admins break-glass
- `scripts/apply-branch-protection.ps1` - added `-RequireCodeOwnerReviews` (this plan) and `-SkipEligibilityCheck` (discovered as a Rule 1 fix during 38-01, both needed for root's `-DryRun` evidence)

## Decisions Made
- **checkpoint:decision auto-selected `pr-flow-review`** (option 1, RECOMMENDED / operator standing choice) rather than `pr-flow-bot-class` or `keep-direct`. Rationale from the plan's own option analysis: root's PR volume is low, so review-bot's auto-merge value is marginal relative to installing a second GitHub App on a separate org (`OgeonX-Ai`); plain PR-flow-with-review already closes the real gap (the unreviewed direct-push path) using the mechanism already proven on sub-repos.
- Did not apply branch protection for real to root -- it is already live and matches the required posture (`required_approving_review_count=1`, `enforce_admins.enabled=true`), verified via `gh api`. Turning on `require_code_owner_reviews=true` for real (to make CODEOWNERS load-bearing rather than advisory) is deferred to the operator, consistent with protection-application being operator-gated for this phase; `-DryRun` evidence for that exact payload was captured instead.

## Deviations from Plan

None beyond the shared `apply-branch-protection.ps1` fix already documented in the 38-01 Summary (Rule 1 - `-SkipEligibilityCheck`), which this plan's `-DryRun` run against `cas-workstation` is what surfaced the need for.

## Issues Encountered
- `require_code_owner_reviews` is `false` in the live protection payload even after adding CODEOWNERS -- CODEOWNERS is present but not yet enforced. This is intentional under the operator-gated / `-DryRun`-only constraint for this plan; flagged explicitly rather than silently treated as "done," since a reviewer verifying REQ-1.5.2 via `gh api` should not assume CODEOWNERS is load-bearing yet.

## User Setup Required

None beyond the shared App-creation step documented in the 38-01 Summary (that step is for the org sub-repo mechanism; it does not touch root, since root deliberately does not install the review-bot App).

**Optional operator follow-up (not blocking REQ-1.5.2, which is satisfied by the already-live posture):** if CODEOWNERS enforcement should be load-bearing rather than advisory, run:
```
pwsh -File scripts/apply-branch-protection.ps1 -Owner OgeonX-Ai -Repos cas-workstation -SkipEligibilityCheck -RequireCodeOwnerReviews
```
(drop `-DryRun` to apply for real).

## Next Phase Readiness
- REQ-1.5.2's root-protection item is closed: root is governed by an explicit, documented, as-code-verified posture instead of ad-hoc direct-push, with a real non-agent required reviewer (CODEOWNERS) and the existing `enforce_admins` temp-relax/restore break-glass preserved.
- REQ-1.5.2's remaining non-root items (branches, worktree leftovers) are tracked in Plan 38-02, not part of this plan's scope.

---
*Phase: 38-merge-flow-and-backfill*
*Completed: 2026-07-10*
