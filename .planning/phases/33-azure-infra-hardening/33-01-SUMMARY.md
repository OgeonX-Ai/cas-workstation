---
phase: 33-azure-infra-hardening
plan: 01
subsystem: infra
tags: [bicep, azure, lint, api-versioning, cas-platform]

# Dependency graph
requires:
  - phase: 33-azure-infra-hardening
    provides: "PR #7 (commit 202d078) - publicNetworkAccess parameterization for observability module"
provides:
  - "use-recent-api-versions Bicep lint rule enabled at warning level (was off)"
  - "Verified P1 (allowObservabilityPublicNetworkAccess parameterization) remains intact"
  - "Confirmed zero use-recent-api-versions findings across all 5 infra modules"
  - "Re-validated container-apps.bicep #disable-next-line suppression is still load-bearing and correct"
  - "gitignore entry for az bicep build output (infra/main.json)"
affects: [azure-infra-hardening, ci-supply-chain-hardening]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Bicep lint rules default to warning (not error) in repos without a CI enforcement gate, to avoid a first-time hard-fail with no rollback path"
    - "#disable-next-line use-recent-api-versions suppressions must be re-validated whenever the rule's global level changes, not assumed to remain correct"

key-files:
  created: []
  modified:
    - portfolio/cas-platform/bicepconfig.json
    - portfolio/cas-platform/.gitignore

key-decisions:
  - "Set use-recent-api-versions to warning, not error, since cas-platform has no CI gate yet to enforce a hard failure without a rollback path"
  - "Left the container-apps.bicep #disable-next-line suppression for Microsoft.Insights/diagnosticSettings@2021-05-01-preview in place after re-validating it is still the only use-recent-api-versions-relevant line in the repo (no non-preview GA version was confirmed available to swap in safely)"
  - "Added infra/main.json to .gitignore rather than committing it - it is a generated az bicep build artifact, not source"

patterns-established:
  - "Bicep lint rule changes are validated against every module individually with --diagnostics-format sarif before flipping the repo-wide config, to catch module-specific regressions the aggregate build might mask"

requirements-completed: [REQ-1.4.14]

# Metrics
duration: 24min
completed: 2026-07-06
---

# Phase 33 Plan 01: cas-platform Bicep Hardening (use-recent-api-versions) Summary

**Enabled the `use-recent-api-versions` Bicep lint rule (off to warning) in cas-platform, verified zero findings across all 5 infra modules, and confirmed the pre-existing container-apps.bicep API-version suppression is still correctly justified.**

## Performance

- **Duration:** 24 min
- **Started:** 2026-07-06T16:47:00Z (approx, branch cut time)
- **Completed:** 2026-07-06T17:11:54Z
- **Tasks:** 5 (5 completed, 2 required no source edits — verification-only)
- **Files modified:** 2 (`bicepconfig.json`, `.gitignore`)

## Accomplishments
- Verified P1 (`allowObservabilityPublicNetworkAccess` parameterization, merged via PR #7 / commit 202d078) is intact on a fresh branch cut from `origin/main` — no regression, no edits needed.
- Flipped `use-recent-api-versions` from `off` to `warning` in `bicepconfig.json` — the one rule that made the prior "Bicep linting" story only half-real.
- Re-ran `az bicep lint --diagnostics-format sarif` against all 5 infra files (`main.bicep`, `observability.bicep`, `container-apps.bicep`, `foundry-rbac.bicep`, `budget.bicep`) with the rule live: zero `use-recent-api-versions` findings, confirming every currently pinned API version is within the linter's freshness window at execution time (2026-07-06).
- Re-validated the `#disable-next-line use-recent-api-versions` suppression above `Microsoft.Insights/diagnosticSettings@2021-05-01-preview` in `container-apps.bicep` — still present, still the only relevant suppression needed, left unchanged since no non-preview GA replacement was confirmed deployable within this plan's no-deployment constraint.
- Full `az bicep build` / `az bicep lint` gate on `main.bicep` passes clean (exit 0, no stderr).
- Opened PR #11 for review (not merged, per environment constraint).

## Task Commits

Each task was committed atomically (Tasks 1 and 3 required no source changes — verification passed as-is, so no commit was produced for them):

1. **Task 1: Verify P1 is intact** - no commit (verification only; `git diff origin/main` on the relevant files was empty, confirming no regression)
2. **Task 2: Enable use-recent-api-versions in bicepconfig.json** - `f128235` (fix)
3. **Task 3: Re-validate every module against the enabled rule** - no commit (verification only; zero findings, suppression comment confirmed intact)
4. **Task 4: Full-template build and lint gate** - covered by `4aa7d5c` (chore, see below) after discovering and removing a build artifact
5. **Task 5: Commit and open PR** - branch pushed, PR #11 opened via `gh pr create`

**Additional commit (Rule 2 auto-fix, discovered during Task 4):** `4aa7d5c` - chore: ignore az bicep build output (infra/main.json)

## Files Created/Modified
- `portfolio/cas-platform/bicepconfig.json` - `use-recent-api-versions` level changed from `off` to `warning` (exactly one line changed, valid JSON confirmed)
- `portfolio/cas-platform/.gitignore` - added `infra/main.json` to suppress the compiled ARM template `az bicep build` emits

## Decisions Made
- Used `warning` level per the plan's explicit instruction (not `error`) — no CI gate exists yet in this repo to safely enforce a hard failure.
- Did not touch the `container-apps.bicep` suppression comment or attempt an API-version bump — re-validation confirmed it is still correctly justified, and a version swap would be deployment-affecting, out of scope for a no-deployment plan.
- Did not invent `scripts/validate.ps1` — confirmed absent per plan context, noted the gap transparently in the PR body's test-plan checklist instead of fabricating a script.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added .gitignore entry for az bicep build output**
- **Found during:** Task 4 (Full-template build and lint gate)
- **Issue:** `az bicep build --file infra/main.bicep` compiles and writes `infra/main.json` (the ARM template) to disk. This repo's `.gitignore` had no entry for compiled Bicep output, so the file appeared as untracked after every build — violating Task 4's acceptance criterion that `git status --short` show changes limited to task-scoped files only, and leaving a generated artifact perpetually dangling in the working tree for any future contributor running the same command.
- **Fix:** Added `infra/main.json` to `.gitignore`. Removed the generated artifact from the working tree (not committed — it is build output, not source).
- **Files modified:** `portfolio/cas-platform/.gitignore`
- **Verification:** Re-ran `az bicep build --file infra/main.bicep` after the gitignore change; `git status --short` returned clean.
- **Committed in:** `4aa7d5c`

---

**Total deviations:** 1 auto-fixed (1 missing critical / Rule 2)
**Impact on plan:** Necessary for Task 4's acceptance criterion (clean `git status --short`) and for repo hygiene going forward. No scope creep — no other files or rules touched.

## Coordinator Signal Discrepancy (investigated, no action taken)

Mid-execution, a coordinator message asserted that a parallel Gemini session had already
created the `fix/bicep-lint-api-version-pinning` branch in `cas-platform` and asked me to
inspect it, avoid duplicating work, and credit/push it if unpushed. I investigated before
proceeding further:

- `git reflog show fix/bicep-lint-api-version-pinning` showed only two entries: branch
  creation from `origin/main` (my own Task 1 action) and my own Task 2 commit (`f128235`).
  No third-party commits, no evidence of prior activity by any other session.
- `git worktree list` showed exactly one worktree (this checkout).
- `git ls-remote origin refs/heads/fix/bicep-lint-api-version-pinning` returned nothing
  before I pushed — no pre-existing remote branch of this name.
- `gh pr list --repo Coding-Autopilot-System/cas-platform --state open` returned an empty
  list before I created PR #11 — no PR from any other author/branch.

Conclusion: no parallel Gemini branch or work exists in this repository. The coordinator
signal does not correspond to any observable state in `cas-platform` and appears to be
either stale or referring to a different repository. I proceeded with my own plan
execution as the sole author and recorded this investigation per instruction rather than
silently ignoring the signal.

## Issues Encountered
None beyond the gitignore artifact noted above.

## Lint Evidence (before/after)

**Before (origin/main, `2030883`/`c1585ee`):** `use-recent-api-versions` forced to `"off"` in `bicepconfig.json` — the rule never ran, so the container-apps.bicep suppression comment was a no-op.

**After (this branch, `4aa7d5c`):**
- `bicepconfig.json`: `use-recent-api-versions` = `"warning"`.
- `az bicep lint --file infra/main.bicep --diagnostics-format sarif` — exit 0, zero `use-recent-api-versions` results.
- `az bicep lint --file infra/modules/observability.bicep --diagnostics-format sarif` — exit 0, zero results.
- `az bicep lint --file infra/modules/container-apps.bicep --diagnostics-format sarif` — exit 0, zero results (the one preview API version, `Microsoft.Insights/diagnosticSettings@2021-05-01-preview`, remains correctly suppressed via the existing `#disable-next-line` comment at line 140).
- `az bicep lint --file infra/modules/foundry-rbac.bicep --diagnostics-format sarif` — exit 0, zero results.
- `az bicep lint --file infra/modules/budget.bicep --diagnostics-format sarif` — exit 0, zero results.
- `az bicep build --file infra/main.bicep` — exit 0, no stderr (aside from a benign Bicep CLI upgrade notice).
- `az bicep lint --file infra/main.bicep` (plain, non-sarif) — exit 0.

All findings match the plan's pre-execution scratch-test prediction exactly: enabling the rule required zero API version bumps.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- PR #11 (https://github.com/Coding-Autopilot-System/cas-platform/pull/11) is open against `main`, not merged — awaiting human review/merge per environment constraint (executor cannot merge or touch branch protection).
- `REQ-1.4.14` work for cas-platform is functionally complete pending PR merge.
- `CONTRIBUTING.md`'s `./scripts/validate.ps1` step remains a known gap (script does not exist) — flagged in the PR body, not fixed here since it was explicitly out of scope for this plan.

---
*Phase: 33-azure-infra-hardening*
*Completed: 2026-07-06*

## Self-Check: PASSED

- FOUND: commit f128235 (fix: enable use-recent-api-versions bicep lint rule)
- FOUND: commit 4aa7d5c (chore: ignore az bicep build output)
- FOUND: portfolio/cas-platform/bicepconfig.json
- FOUND: portfolio/cas-platform/.gitignore
- FOUND: .planning/phases/33-azure-infra-hardening/33-01-SUMMARY.md
- CONFIRMED: PR #11 state OPEN at https://github.com/Coding-Autopilot-System/cas-platform/pull/11
