---
phase: 31-org-ci-supply-chain-hardening
plan: 04
subsystem: infra
tags: [github-actions, supply-chain, sha-pinning, least-privilege, codeql]

requires:
  - phase: 31-org-ci-supply-chain-hardening
    provides: "scripts/workflow-lint.ps1 falsifier and org-wide violation inventory (31-01)"
provides:
  - "cas-workstation fully SHA-pinned across codeql.yml, pages.yml, pr-lint.yml, stale.yml (PR #19, not merged)"
  - "cloud-security-service-model fully SHA-pinned across codeql.yml, pages.yml, pr-lint.yml, stale.yml (PR #14, not merged)"
  - "gsd-orchestrator fully SHA-pinned + codeql.yml gains a missing permissions block (PR #18, not merged)"
  - "org-dotgithub (Coding-Autopilot-System/.github) fully SHA-pinned across codeql.yml, pages.yml, pr-lint.yml, stale.yml (PR #13, not merged)"
affects: [phase-31-wave-3-reverify]

tech-stack:
  added: []
  patterns: ["SHA-pin third-party GitHub Actions with trailing # vX.Y.Z comment", "re-resolve SHA table live against tags actually present in target files rather than trusting a plan-authored snapshot"]

key-files:
  created: []
  modified:
    - portfolio/cas-workstation/.github/workflows/codeql.yml
    - portfolio/cas-workstation/.github/workflows/pages.yml
    - portfolio/cas-workstation/.github/workflows/pr-lint.yml
    - portfolio/cas-workstation/.github/workflows/stale.yml
    - portfolio/cloud-security-service-model/.github/workflows/codeql.yml
    - portfolio/cloud-security-service-model/.github/workflows/pages.yml
    - portfolio/cloud-security-service-model/.github/workflows/pr-lint.yml
    - portfolio/cloud-security-service-model/.github/workflows/stale.yml
    - portfolio/gsd-orchestrator/.github/workflows/ci.yml
    - portfolio/gsd-orchestrator/.github/workflows/codeql.yml
    - portfolio/gsd-orchestrator/.github/workflows/pages.yml
    - portfolio/gsd-orchestrator/.github/workflows/pr-lint.yml
    - portfolio/gsd-orchestrator/.github/workflows/stale.yml
    - portfolio/org-dotgithub/.github/workflows/codeql.yml
    - portfolio/org-dotgithub/.github/workflows/pages.yml
    - portfolio/org-dotgithub/.github/workflows/pr-lint.yml
    - portfolio/org-dotgithub/.github/workflows/stale.yml

key-decisions:
  - "Plan's interfaces-block SHA table (resolved 2026-07-06 against @v4/@v3/@v5/@v8 tags) was stale across all 4 repos — every target workflow file had already moved to newer tags (checkout@v7, codeql-action@v4, setup-python@v6, upload-pages-artifact@v5, deploy-pages@v5, action-semantic-pull-request@v6, stale@v10, setup-dotnet@v5, upload-artifact@v7) by execution time, via prior dependabot merges. Re-resolved all 9 SHAs live via `gh api repos/<owner>/<action>/commits/<tag>` against the tags actually present in each file, then cross-checked each resolved SHA against the top full-semver release tag (e.g. v7.0.0) to confirm it points to a real pinned release, and further cross-checked against already-pinned sibling files in the same repos (quality.yml, ci.yml, static.yml, contract-registry-live.yml) where the same action/tag pair already appeared — all matched exactly."
  - "gsd-orchestrator's ci.yml, pr-lint.yml, and stale.yml already carried job-level least-privilege permissions blocks at execution time (added upstream between the plan's 2026-07-06 audit and this run), with scopes matching exactly what the plan called for (contents: read / pull-requests: read / issues+pull-requests: write respectively). Left unchanged rather than duplicating or restructuring into top-level blocks, since job-level permissions already satisfy workflow-lint's missing-permissions check and the least-privilege intent. Only codeql.yml was genuinely missing a permissions block and got one added, mirroring portfolio/cas-platform/.github/workflows/codeql.yml's structure exactly."
  - "Used a git worktree per repo (branched off freshly-fetched origin/main) rather than switching branches in-place, because 3 of the 4 target repos had pre-existing uncommitted changes or were checked out on unrelated branches (cas-workstation: dirty main; cloud-security-service-model: on fix/bicep-lint-api-version-pinning; gsd-orchestrator: on feat/phase-26-coverage-gates with unrelated modified files). This avoided disturbing any other agent's or the user's in-progress work in those checkouts."
  - "Scanned all 17 modified files for Azure deploy steps (OPERATOR LOCK / NO-AZURE rule) — none found in any of the 4 repos. All 'deploy' hits are GitHub Pages deploys (actions/deploy-pages), not Azure. Explicitly noted 'operator lock does not apply' in each PR body."
  - "org-dotgithub's PR was opened against --repo Coding-Autopilot-System/.github per the plan's explicit correction (the local directory is named org-dotgithub but the GitHub remote is the org's .github profile repo)."

patterns-established:
  - "Before applying a plan's pre-resolved SHA table, re-verify the tags in the interfaces block still match the tags currently in the target files — dependabot or other agents may have moved tags between plan authoring and execution across the whole batch, not just one file."

requirements-completed: [REQ-1.4.10]

duration: 32min
completed: 2026-07-07
---

# Phase 31 Plan 04: Per-Repo Workflow Hardening Batch (cas-workstation, cloud-security-service-model, gsd-orchestrator, org-dotgithub) Summary

**SHA-pinned all third-party GitHub Actions across 4 portfolio repos' remaining unpinned workflows and added a genuinely-missing permissions block to gsd-orchestrator's codeql.yml — 4 PRs opened, none merged.**

## Performance

- **Duration:** ~32 min
- **Started:** 2026-07-07T15:08:00Z
- **Completed:** 2026-07-07T15:40:00Z
- **Tasks:** 3 (all completed)
- **Files modified:** 17

## Accomplishments
- cas-workstation: codeql.yml, pages.yml, pr-lint.yml, stale.yml fully SHA-pinned. CodeQL `language: ['actions']` matrix confirmed unregressed. quality.yml left untouched (already pinned).
- cloud-security-service-model: codeql.yml, pages.yml, pr-lint.yml, stale.yml fully SHA-pinned. CodeQL `language: ['actions']` matrix confirmed unregressed. ci.yml and static.yml left untouched (already pinned).
- gsd-orchestrator: ci.yml, codeql.yml, pages.yml, pr-lint.yml, stale.yml fully SHA-pinned. codeql.yml gained the genuinely-missing permissions block (mirroring cas-platform's pattern). contract-registry-live.yml left untouched (already pinned + permissions).
- org-dotgithub (Coding-Autopilot-System/.github): codeql.yml, pages.yml, pr-lint.yml, stale.yml fully SHA-pinned.
- All 4 repos verified clean via `powershell.exe -File scripts/workflow-lint.ps1 -Path <repo> -Json` against the PR branch content before pushing.
- No Azure deploy steps found in any of the 4 repos' workflows — OPERATOR LOCK/NO-AZURE gating did not apply; noted explicitly in each PR body.
- 4 PRs opened against `main` (or the correct `.github` remote for org-dotgithub), none merged, no branch protection touched.

## Task Commits

1. **Task 1: cas-workstation** - `1a881a9` (ci) — branch `ci/sha-pin-actions`, PR https://github.com/Coding-Autopilot-System/cas-workstation/pull/19
2. **Task 1: cloud-security-service-model** - `33940d7` (ci) — branch `ci/sha-pin-actions`, PR https://github.com/Coding-Autopilot-System/cloud-security-service-model/pull/14
3. **Task 2: gsd-orchestrator** - `30170fd` (ci) — branch `ci/sha-pin-and-least-privilege`, PR https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/18
4. **Task 3: org-dotgithub** - `cee7137` (ci) — branch `ci/sha-pin-actions`, PR https://github.com/Coding-Autopilot-System/.github/pull/13

**Plan metadata:** committed to `.planning/` in this repo (PersonalRepo), separate from the 4 target-repo commits above.

## Files Created/Modified
- `portfolio/cas-workstation/.github/workflows/codeql.yml` - SHA-pinned checkout@v7.0.0, codeql-action/{init,autobuild,analyze}@v4.36.3
- `portfolio/cas-workstation/.github/workflows/pages.yml` - SHA-pinned checkout@v7.0.0, setup-python@v6.3.0, upload-pages-artifact@v5.0.0, deploy-pages@v5.0.0
- `portfolio/cas-workstation/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/cas-workstation/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0
- `portfolio/cloud-security-service-model/.github/workflows/codeql.yml` - same 4-action pin set as cas-workstation
- `portfolio/cloud-security-service-model/.github/workflows/pages.yml` - same 4-action pin set as cas-workstation
- `portfolio/cloud-security-service-model/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/cloud-security-service-model/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0
- `portfolio/gsd-orchestrator/.github/workflows/ci.yml` - SHA-pinned checkout@v7.0.0, setup-dotnet@v5.4.0, upload-artifact@v7.0.1
- `portfolio/gsd-orchestrator/.github/workflows/codeql.yml` - SHA-pinned checkout@v7.0.0, codeql-action/{init,autobuild,analyze}@v4.36.3; added top-level `permissions: contents: read` and job-level `permissions: actions/contents: read, security-events: write` on the `analyze` job (mirrors cas-platform)
- `portfolio/gsd-orchestrator/.github/workflows/pages.yml` - same 4-action pin set as cas-workstation
- `portfolio/gsd-orchestrator/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/gsd-orchestrator/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0
- `portfolio/org-dotgithub/.github/workflows/codeql.yml` - same 4-action pin set as cas-workstation
- `portfolio/org-dotgithub/.github/workflows/pages.yml` - same 4-action pin set as cas-workstation
- `portfolio/org-dotgithub/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/org-dotgithub/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0

## Decisions Made
- Re-resolved all SHA pins live against the tags actually present in each file (@v7/@v4/@v6/@v5/@v6/@v10/@v5/@v7) rather than the plan's interfaces-block table (resolved 2026-07-06 against @v4/@v3/@v5/@v8), since dependabot had already bumped every target repo's tags forward by execution time. Verified each resolved SHA two ways: (1) against the corresponding top full-semver release tag (e.g. `v7.0.0`) to confirm it isn't a stale/moved ref, and (2) by cross-checking against already-pinned sibling files in the same repos (cas-workstation's quality.yml, cloud-security-service-model's ci.yml/static.yml, gsd-orchestrator's contract-registry-live.yml) that already reference the same action/tag pairs — all matched byte-for-byte.
- Used per-repo git worktrees (branched off a freshly-fetched `origin/main`) instead of switching branches in the existing checkouts, since 3 of the 4 repos had pre-existing uncommitted work or were on unrelated branches. This kept the existing working trees (and any concurrent agent's in-progress work there) completely undisturbed.
- Did not modify gsd-orchestrator's ci.yml, pr-lint.yml, or stale.yml permissions — all three already had correctly-scoped job-level `permissions:` blocks at execution time, matching what the plan called for. Only codeql.yml was genuinely missing a permissions block; added it per the plan's cas-platform-mirroring instruction.
- Confirmed no Azure deploy steps exist in any of the 17 modified files (or their sibling workflows) via a grep sweep across all 4 worktrees for azure/deploy/az-login patterns — every "deploy" hit is a GitHub Pages deploy. The NO-AZURE OPERATOR LOCK gating rule was evaluated and found not applicable; documented in each PR body rather than silently skipped.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Plan's pre-resolved SHA table was stale against current file content, across all 4 repos**
- **Found during:** Task 1 (reading cas-workstation's workflow files before editing)
- **Issue:** The plan's interfaces block provided SHAs resolved on 2026-07-06 for `actions/checkout@v4`, `setup-python@v5`, `upload-pages-artifact@v3`, `deploy-pages@v4`, `codeql-action/*@v3`, `action-semantic-pull-request@v5`, `stale@v8`, `setup-dotnet@v5`, `upload-artifact@v4` — but every actual workflow file across all 4 repos at execution time referenced newer tags (`@v7`, `@v6`, `@v5`, `@v5`, `@v4`, `@v6`, `@v10`, `@v5`, `@v7` respectively). Using the plan's table verbatim would have pinned every file to the wrong (older) action versions, silently downgrading them and producing SHAs that don't correspond to any `uses:` line actually in the files.
- **Fix:** Re-resolved fresh SHAs via `gh api repos/<owner>/<action>/commits/<tag>` for each tag actually present in the files (9 unique action/tag pairs total), cross-verified each against the top current full-semver release tag, and cross-checked against already-pinned sibling files in the same repos where the same pair appeared.
- **Files modified:** all 17 files listed above
- **Verification:** `powershell.exe -File scripts/workflow-lint.ps1 -Path <repo> -Json` reports `workflow-lint: clean.` for all 4 repos post-edit; `grep -n "language:"` confirms both CodeQL matrices unregressed.
- **Committed in:** 1a881a9, 33940d7, 30170fd, cee7137

**2. [Rule 1 - Bug] gsd-orchestrator's actual permissions-block gap did not match the plan's audit**
- **Found during:** Task 2 (reading gsd-orchestrator's 5 workflow files before editing)
- **Issue:** The plan's must_haves and interfaces block stated ci.yml, codeql.yml, pr-lint.yml, and stale.yml were all missing `permissions:` entirely. At execution time, ci.yml, pr-lint.yml, and stale.yml already had job-level `permissions:` blocks with exactly the scopes the plan wanted (added upstream between the plan's audit and execution). Only codeql.yml was actually missing permissions.
- **Fix:** Added the permissions block only to codeql.yml (top-level `contents: read` plus job-level `actions: read`/`contents: read`/`security-events: write` on the `analyze` job, mirroring cas-platform's codeql.yml exactly). Left ci.yml, pr-lint.yml, and stale.yml unchanged since duplicating or restructuring their already-correct job-level blocks into top-level blocks would be unnecessary churn with no lint or security benefit.
- **Files modified:** portfolio/gsd-orchestrator/.github/workflows/codeql.yml (permissions addition); ci.yml, pr-lint.yml, stale.yml received only SHA-pinning, no permissions changes
- **Verification:** `powershell.exe -File scripts/workflow-lint.ps1 -Path portfolio/gsd-orchestrator -Json` reports `workflow-lint: clean.` (zero `missing-permissions` findings across all 5 files); `git diff --stat` confirms `contract-registry-live.yml` untouched.
- **Committed in:** 30170fd

---

**Total deviations:** 2 auto-fixed (both Rule 1 corrections to stale plan-provided data — SHA table and permissions-gap audit — against live repo state)
**Impact on plan:** Both fixes were necessary for correctness. No scope creep — no files outside the plan's declared `files_modified` list were touched in any of the 4 repos.

## Skipped Work (per scope_and_rules)

None. The scope instructions named autogen, cas-contracts, and cas-evals as repos to skip — none of those repos appear in this plan's `files_modified` list (they belong to other plans in this phase), so no skips were needed for this plan specifically.

## Issues Encountered
- `pwsh` is not on PATH in the Bash tool's Git Bash environment; fell back to `powershell.exe -File scripts/workflow-lint.ps1 ...`, which is functionally equivalent on this Windows host (the script is documented as PowerShell 5.1-compatible per 31-01's summary) and produced `workflow-lint: clean.` for all 4 repos.
- `git push` from the gsd-orchestrator worktree printed a benign warning (`"/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential store: line 1: ... No such file or directory`) from a misconfigured credential helper path lookup, but the push itself succeeded (branch created on remote) — no action needed.

## User Setup Required

None — no external service configuration required. All 4 PRs are open and awaiting human review/merge, which is explicitly out of scope for this plan (no merge, no branch-protection changes performed).

## Next Phase Readiness
- cas-workstation, cloud-security-service-model, gsd-orchestrator, and org-dotgithub are each fully SHA-pinned on their PR branches with zero workflow-lint findings, closing out this plan's stated success criteria.
- Both CodeQL `language:` matrices in cas-workstation and cloud-security-service-model remain `['actions']`, confirmed unregressed by this plan's edits.
- PRs #19 (cas-workstation), #14 (cloud-security-service-model), #18 (gsd-orchestrator), and #13 (Coding-Autopilot-System/.github) are open against `main` and await human review/merge.
- Phase 31 wave 3's re-verification sweep (re-run `workflow-lint.ps1 -Path portfolio` across all repos) can now include all 4 of these repos' PR branch content as expected-clean.

---
*Phase: 31-org-ci-supply-chain-hardening*
*Completed: 2026-07-07*

## Self-Check: PASSED

- FOUND: commit 1a881a9 in cas-workstation repo (branch ci/sha-pin-actions)
- FOUND: commit 33940d7 in cloud-security-service-model repo (branch ci/sha-pin-actions)
- FOUND: commit 30170fd in gsd-orchestrator repo (branch ci/sha-pin-and-least-privilege)
- FOUND: commit cee7137 in org-dotgithub (Coding-Autopilot-System/.github) repo (branch ci/sha-pin-actions)
- FOUND: PR #19 open at https://github.com/Coding-Autopilot-System/cas-workstation/pull/19 (state=OPEN)
- FOUND: PR #14 open at https://github.com/Coding-Autopilot-System/cloud-security-service-model/pull/14 (state=OPEN)
- FOUND: PR #18 open at https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/18 (state=OPEN)
- FOUND: PR #13 open at https://github.com/Coding-Autopilot-System/.github/pull/13 (state=OPEN)
