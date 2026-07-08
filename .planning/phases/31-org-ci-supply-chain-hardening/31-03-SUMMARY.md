---
phase: 31-org-ci-supply-chain-hardening
plan: 03
subsystem: infra
tags: [github-actions, supply-chain, sha-pinning, least-privilege, codeql]

requires:
  - phase: 31-org-ci-supply-chain-hardening
    provides: "scripts/workflow-lint.ps1 falsifier and org-wide violation inventory (31-01)"
provides:
  - "cas-contracts fully SHA-pinned across all 6 workflows (PR #19, not merged)"
  - "cas-evals fully SHA-pinned across codeql/pages/pr-lint/stale (PR #10, not merged)"
  - "cas-platform fully SHA-pinned across codeql/pages/pr-lint/stale, CodeQL language: ['actions'] matrix confirmed unregressed (PR #12, not merged)"
  - "cas-reference-product fully SHA-pinned across codeql/pages (ci.yml already compliant) (PR #12, not merged)"
affects: [phase-31-wave-3-reverify]

tech-stack:
  added: []
  patterns: ["SHA-pin third-party GitHub Actions with trailing # vX.Y.Z comment", "re-resolve SHA table live against tags actually present in target files rather than trusting a plan-authored snapshot", "cross-check resolved SHAs against already-pinned sibling files in the same repo/portfolio for a second verification signal"]

key-files:
  created: []
  modified:
    - portfolio/cas-contracts/.github/workflows/ci.yml
    - portfolio/cas-contracts/.github/workflows/codeql.yml
    - portfolio/cas-contracts/.github/workflows/compatibility.yml
    - portfolio/cas-contracts/.github/workflows/pages.yml
    - portfolio/cas-contracts/.github/workflows/pr-lint.yml
    - portfolio/cas-contracts/.github/workflows/stale.yml
    - portfolio/cas-evals/.github/workflows/codeql.yml
    - portfolio/cas-evals/.github/workflows/pages.yml
    - portfolio/cas-evals/.github/workflows/pr-lint.yml
    - portfolio/cas-evals/.github/workflows/stale.yml
    - portfolio/cas-platform/.github/workflows/codeql.yml
    - portfolio/cas-platform/.github/workflows/pages.yml
    - portfolio/cas-platform/.github/workflows/pr-lint.yml
    - portfolio/cas-platform/.github/workflows/stale.yml
    - portfolio/cas-reference-product/.github/workflows/codeql.yml
    - portfolio/cas-reference-product/.github/workflows/pages.yml

key-decisions:
  - "Plan's interfaces-block SHA table (resolved 2026-07-06 against @v4/@v3/@v5/@v8 tags) was stale across all 4 repos — every target workflow file had already moved to newer tags (checkout@v7, setup-node@v6, setup-python@v6, configure-pages@v6, upload-pages-artifact@v5, deploy-pages@v5, upload-artifact@v7, codeql-action@v4, action-semantic-pull-request@v6, stale@v10) via prior dependabot merges. Re-resolved all 10 unique action/tag pairs live via `gh api repos/<owner>/<action>/commits/<tag>`, then cross-checked checkout@v7 and setup-python@v6 against cas-reference-product's already-pinned ci.yml (byte-for-byte match) and codeql-action@v4 against its top full-semver tag v4.36.3."
  - "cas-contracts' three workflows the plan flagged as missing permissions: (codeql.yml, pr-lint.yml, stale.yml) already carried job-level least-privilege permissions blocks with exactly the scopes the plan wanted, added upstream between the plan's 2026-07-06 audit and execution time. No permissions changes were made anywhere in this batch — only SHA-pinning."
  - "Used a git worktree per repo (branched off freshly-fetched origin/main into C:/PersonalRepo/.worktrees/<repo>-ci, matching plan 31-04's proven pattern) rather than switching branches in-place, since all 4 target repos had pre-existing uncommitted changes or were checked out on unrelated branches (cas-contracts: dirty working tree + open PR #18 on fix/registry-resolvable-id; cas-evals: on feat/registry-fetch-smoke-check; cas-platform: on fix/bicep-lint-api-version-pinning; cas-reference-product: has active agent worktrees under .claude/worktrees/). All worktrees removed after PRs were pushed; existing checkouts left completely undisturbed."
  - "Confirmed open PR #18 in cas-contracts (fix/registry-resolvable-id) touches only CHANGELOG.md, docs/DISTRIBUTION.md, schemas/*.json, scripts/lib.mjs, and tests/registry.test.mjs — no overlap with this plan's 6 workflow files, so no merge-order dependency exists between the two PRs; noted explicitly in the cas-contracts PR body regardless, per the plan's scope instruction."
  - "Scanned all 16 modified files for Azure deploy steps (OPERATOR LOCK / NO-AZURE rule) — none found in any of the 4 repos. All deploy steps use actions/deploy-pages (GitHub Pages), not Azure. Explicitly noted 'operator lock does not apply' in each PR body."

patterns-established:
  - "Before applying a plan's pre-resolved SHA table, re-verify the tags in the interfaces block still match the tags currently in the target files — dependabot or other agents may have moved tags between plan authoring and execution across the whole batch, not just one file (second confirmation of the pattern first observed in 31-04)."

requirements-completed: [REQ-1.4.10]

duration: 28min
completed: 2026-07-07
---

# Phase 31 Plan 03: Workflow Hardening Batch (cas-contracts, cas-evals, cas-platform, cas-reference-product) Summary

**SHA-pinned all third-party GitHub Actions across 4 portfolio repos' remaining unpinned workflows; confirmed all previously-flagged missing-permissions gaps had already been closed upstream — 4 PRs opened, none merged.**

## Performance

- **Duration:** ~28 min
- **Started:** 2026-07-07T15:45:00Z
- **Completed:** 2026-07-07T16:13:00Z
- **Tasks:** 3 (all completed)
- **Files modified:** 16

## Accomplishments
- cas-contracts: ci.yml, codeql.yml, compatibility.yml, pages.yml, pr-lint.yml, stale.yml fully SHA-pinned (6 files). All 3 files the plan flagged as missing permissions (codeql.yml, pr-lint.yml, stale.yml) were already compliant at execution time — verified and left unchanged.
- cas-evals: codeql.yml, pages.yml, pr-lint.yml, stale.yml fully SHA-pinned (4 files). Permissions/timeout already present on all, unchanged.
- cas-platform: codeql.yml, pages.yml, pr-lint.yml, stale.yml fully SHA-pinned (4 files). CodeQL `language: ['actions']` matrix confirmed unregressed via post-edit grep.
- cas-reference-product: codeql.yml, pages.yml fully SHA-pinned (2 files). ci.yml confirmed already fully pinned per the 2026-07-06 audit — left untouched.
- All 4 repos verified clean via `powershell.exe -File scripts/workflow-lint.ps1 -Path <repo> -Json` against the PR branch content before pushing.
- No Azure deploy steps found in any of the 4 repos' workflows — OPERATOR LOCK/NO-AZURE gating did not apply; noted explicitly in each PR body.
- 4 PRs opened against `main`, none merged, no branch protection touched, cas-contracts' open PR #18 (fix/registry-resolvable-id) left untouched and confirmed non-overlapping.

## Task Commits

Each task was committed atomically inside its own per-repo git worktree (not this PersonalRepo checkout — see Files Created/Modified for target-repo paths):

1. **Task 1: cas-contracts** - `d2d57ef` (ci) — branch `ci/sha-pin-and-least-privilege`, PR https://github.com/Coding-Autopilot-System/cas-contracts/pull/19
2. **Task 2: cas-evals** - `4120c04` (ci) — branch `ci/sha-pin-actions`, PR https://github.com/Coding-Autopilot-System/cas-evals/pull/10
3. **Task 2: cas-platform** - `69296e0` (ci) — branch `ci/sha-pin-actions`, PR https://github.com/Coding-Autopilot-System/cas-platform/pull/12
4. **Task 3: cas-reference-product** - `2b066a0` (ci) — branch `ci/sha-pin-actions`, PR https://github.com/Coding-Autopilot-System/cas-reference-product/pull/12

**Plan metadata:** committed to `.planning/` in this repo (PersonalRepo), separate from the 4 target-repo commits above.

## Files Created/Modified
- `portfolio/cas-contracts/.github/workflows/ci.yml` - SHA-pinned checkout@v7.0.0, setup-node@v6.4.0
- `portfolio/cas-contracts/.github/workflows/codeql.yml` - SHA-pinned checkout@v7.0.0, codeql-action/{init,autobuild,analyze}@v4.36.3
- `portfolio/cas-contracts/.github/workflows/compatibility.yml` - SHA-pinned checkout@v7.0.0, setup-node@v6.4.0, upload-artifact@v7.0.1
- `portfolio/cas-contracts/.github/workflows/pages.yml` - SHA-pinned checkout@v7.0.0, setup-python@v6.3.0, setup-node@v6.4.0, configure-pages@v6.0.0, upload-pages-artifact@v5.0.0, deploy-pages@v5.0.0
- `portfolio/cas-contracts/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/cas-contracts/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0
- `portfolio/cas-evals/.github/workflows/codeql.yml` - same codeql-action pin set as cas-contracts
- `portfolio/cas-evals/.github/workflows/pages.yml` - SHA-pinned checkout@v7.0.0, setup-python@v6.3.0, upload-pages-artifact@v5.0.0, deploy-pages@v5.0.0
- `portfolio/cas-evals/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/cas-evals/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0
- `portfolio/cas-platform/.github/workflows/codeql.yml` - same codeql-action pin set; `language: ['actions']` matrix unchanged
- `portfolio/cas-platform/.github/workflows/pages.yml` - same pin set as cas-evals/pages.yml
- `portfolio/cas-platform/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/cas-platform/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0
- `portfolio/cas-reference-product/.github/workflows/codeql.yml` - same codeql-action pin set as cas-contracts
- `portfolio/cas-reference-product/.github/workflows/pages.yml` - same pin set as cas-evals/pages.yml

## Decisions Made
- Re-resolved all SHA pins live against the tags actually present in each file (@v7/@v6/@v6/@v6/@v5/@v5/@v7/@v4/@v6/@v10) rather than the plan's interfaces-block table (resolved 2026-07-06 against @v4/@v3/@v5/@v8), since dependabot had already bumped every target repo's tags forward by execution time. Verified each resolved SHA two ways: (1) cross-checked checkout@v7 and setup-python@v6 against cas-reference-product's own already-pinned ci.yml (byte-for-byte match), and (2) verified codeql-action@v4 resolves to the current top full-semver tag v4.36.3.
- Used per-repo git worktrees (branched off a freshly-fetched `origin/main`, staged under `C:/PersonalRepo/.worktrees/<repo>-ci`) instead of switching branches in the existing checkouts, matching plan 31-04's proven pattern — all 4 repos had pre-existing uncommitted work or were on unrelated branches. Worktrees were removed after each PR was pushed.
- Did not add any permissions blocks to cas-contracts' codeql.yml, pr-lint.yml, or stale.yml as the plan instructed — all three already had job-level `permissions:` blocks with exactly the scopes the plan called for (added upstream between the plan's audit and execution), matching the pattern seen in 31-04's gsd-orchestrator finding.
- Confirmed no Azure deploy steps exist in any of the 16 modified files via a grep sweep across all 4 worktrees for azure/deploy/az-login patterns — every "deploy" hit is a GitHub Pages deploy (actions/deploy-pages). The NO-AZURE OPERATOR LOCK gating rule was evaluated and found not applicable; documented in each PR body rather than silently skipped.
- Confirmed cas-contracts' open PR #18 (fix/registry-resolvable-id) has zero file overlap with this plan's 6 workflow files (it touches CHANGELOG.md, docs, schemas, scripts/lib.mjs, tests) — no merge-order dependency exists, but noted this explicitly in the PR #19 body per the plan's scope instruction.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Plan's pre-resolved SHA table was stale against current file content, across all 4 repos**
- **Found during:** Task 1 (reading cas-contracts' workflow files before editing)
- **Issue:** The plan's interfaces block provided SHAs resolved on 2026-07-06 for `actions/checkout@v4`, `setup-node@v4`, `setup-python@v5`, `configure-pages@v5`, `upload-pages-artifact@v3`, `deploy-pages@v4`, `upload-artifact@v4`, `codeql-action/*@v3`, `action-semantic-pull-request@v5`, `stale@v8` — but every actual workflow file across all 4 repos at execution time referenced newer tags (`@v7`, `@v6`, `@v6`, `@v6`, `@v5`, `@v5`, `@v7`, `@v4`, `@v6`, `@v10` respectively). Using the plan's table verbatim would have pinned every file to the wrong (older) action versions.
- **Fix:** Re-resolved fresh SHAs via `gh api repos/<owner>/<action>/commits/<tag>` for each tag actually present in the files (10 unique action/tag pairs total), cross-verified checkout@v7 and setup-python@v6 against cas-reference-product's already-pinned `ci.yml`, and confirmed codeql-action@v4 resolves to the current top release `v4.36.3`.
- **Files modified:** all 16 files listed above
- **Verification:** `powershell.exe -File scripts/workflow-lint.ps1 -Path <repo> -Json` reports `workflow-lint: clean.` for all 4 repos post-edit; `grep -n "language:"` confirms cas-platform's CodeQL matrix unregressed.
- **Committed in:** d2d57ef, 4120c04, 69296e0, 2b066a0

**2. [Rule 1 - Bug] cas-contracts' actual permissions-block gap did not match the plan's audit**
- **Found during:** Task 1 (reading cas-contracts' codeql.yml, pr-lint.yml, stale.yml before editing)
- **Issue:** The plan's must_haves and interfaces block stated codeql.yml, pr-lint.yml, and stale.yml were all missing `permissions:` entirely and instructed adding specific blocks. At execution time, all three already had job-level `permissions:` blocks with exactly the scopes the plan wanted (added upstream between the plan's audit and execution).
- **Fix:** Made no permissions changes to any of the three files — only SHA-pinned their `uses:` lines. Verified via `Read` that codeql.yml's `analyze` job already had `actions: read` / `contents: read` / `security-events: write`, pr-lint.yml's `main` job already had `pull-requests: read`, and stale.yml's `stale` job already had `issues: write` / `pull-requests: write`.
- **Files modified:** codeql.yml, pr-lint.yml, stale.yml received SHA-pinning only, no permissions changes
- **Verification:** `powershell.exe -File scripts/workflow-lint.ps1 -Path portfolio/cas-contracts -Json` reports `workflow-lint: clean.` (zero `missing-permissions` findings across all 6 files)
- **Committed in:** d2d57ef

---

**Total deviations:** 2 auto-fixed (both Rule 1 corrections to stale plan-provided data — SHA table and permissions-gap audit — against live repo state, mirroring the same class of deviation documented in 31-04)
**Impact on plan:** Both fixes were necessary for correctness. No scope creep — no files outside the plan's declared `files_modified` list were touched in any of the 4 repos.

## Issues Encountered
- `pwsh` is not on PATH in the Bash tool's Git Bash environment; used `powershell.exe -File scripts/workflow-lint.ps1 ...` instead, which is functionally equivalent on this Windows host and produced `workflow-lint: clean.` for all 4 repos.
- `git push` from each worktree printed a benign warning (`"/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential store: line 1: ... No such file or directory`) from a misconfigured credential helper path lookup, but every push succeeded (branch created on remote, PR opened) — no action needed, matching the same benign warning documented in 31-04.

## User Setup Required

None — no external service configuration required. All 4 PRs are open and awaiting human review/merge, which is explicitly out of scope for this plan (no merge, no branch-protection changes performed).

## Next Phase Readiness
- cas-contracts, cas-evals, cas-platform, and cas-reference-product are each fully SHA-pinned on their PR branches with zero workflow-lint findings, closing out this plan's stated success criteria.
- cas-platform's CodeQL `language:` matrix remains `['actions']`, confirmed unregressed by this plan's edits.
- PRs #19 (cas-contracts), #10 (cas-evals), #12 (cas-platform), and #12 (cas-reference-product) are open against `main` and await human review/merge.
- cas-contracts' PR #19 has no file overlap with the still-open PR #18 (fix/registry-resolvable-id, awaiting a human compatibility label) — both can merge independently in either order.
- Phase 31 wave 3's re-verification sweep (re-run `workflow-lint.ps1 -Path portfolio` across all repos) can now include all 4 of these repos' PR branch content as expected-clean.

---
*Phase: 31-org-ci-supply-chain-hardening*
*Completed: 2026-07-07*

## Self-Check: PASSED

- FOUND: commit d2d57ef in cas-contracts repo (branch ci/sha-pin-and-least-privilege)
- FOUND: commit 4120c04 in cas-evals repo (branch ci/sha-pin-actions)
- FOUND: commit 69296e0 in cas-platform repo (branch ci/sha-pin-actions)
- FOUND: commit 2b066a0 in cas-reference-product repo (branch ci/sha-pin-actions)
- FOUND: PR #19 open at https://github.com/Coding-Autopilot-System/cas-contracts/pull/19 (state=OPEN)
- FOUND: PR #10 open at https://github.com/Coding-Autopilot-System/cas-evals/pull/10 (state=OPEN)
- FOUND: PR #12 open at https://github.com/Coding-Autopilot-System/cas-platform/pull/12 (state=OPEN)
- FOUND: PR #12 open at https://github.com/Coding-Autopilot-System/cas-reference-product/pull/12 (state=OPEN)
