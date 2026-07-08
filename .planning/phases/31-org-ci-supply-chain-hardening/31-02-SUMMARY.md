---
phase: 31-org-ci-supply-chain-hardening
plan: 02
subsystem: infra
tags: [github-actions, supply-chain, sha-pinning, least-privilege, promptimprover, autogen, autopilot-core, autopilot-demo]

requires:
  - phase: 31-org-ci-supply-chain-hardening
    provides: "scripts/workflow-lint.ps1 falsifier and org-wide violation inventory (31-01)"
provides:
  - "Promptimprover fully SHA-pinned across all 5 workflow files, PR #28 open against master"
  - "autogen fully SHA-pinned across all 5 workflow files, PR #13 open against main (merge-order note re: PR #11/#12)"
  - "autopilot-core fully SHA-pinned across all 9 root workflow files plus 2 demo-repo scaffold templates, PR #15 open against main"
  - "autopilot-demo audited and confirmed already fully compliant against origin/main — no PR opened"
affects: [31-06, phase-31-wave-3-reverify]

tech-stack:
  added: []
  patterns: ["SHA-pin third-party GitHub Actions with trailing # vX comment", "isolate per-repo remediation work in a throwaway git worktree branched off a fetched origin/<default> tip when the repo's checked-out working tree carries unrelated uncommitted/foreign changes"]

key-files:
  created: []
  modified:
    - portfolio/Promptimprover/.github/workflows/ci.yml
    - portfolio/Promptimprover/.github/workflows/codeql.yml
    - portfolio/Promptimprover/.github/workflows/pages.yml
    - portfolio/Promptimprover/.github/workflows/pr-lint.yml
    - portfolio/Promptimprover/.github/workflows/stale.yml
    - portfolio/autogen/.github/workflows/ci.yml
    - portfolio/autogen/.github/workflows/codeql.yml
    - portfolio/autogen/.github/workflows/pages.yml
    - portfolio/autogen/.github/workflows/pr-lint.yml
    - portfolio/autogen/.github/workflows/stale.yml
    - portfolio/autopilot-core/.github/workflows/autopilot-create-issue.yml
    - portfolio/autopilot-core/.github/workflows/autopilot-docs-daily.yml
    - portfolio/autopilot-core/.github/workflows/autopilot-operator.yml
    - portfolio/autopilot-core/.github/workflows/autopilot-org-installer.yml
    - portfolio/autopilot-core/.github/workflows/ci.yml
    - portfolio/autopilot-core/.github/workflows/codeql.yml
    - portfolio/autopilot-core/.github/workflows/pages.yml
    - portfolio/autopilot-core/.github/workflows/pr-lint.yml
    - portfolio/autopilot-core/.github/workflows/stale.yml
    - portfolio/autopilot-core/templates/demo-repo/.github/workflows/autopilot-create-issue.yml
    - portfolio/autopilot-core/templates/demo-repo/.github/workflows/demo-ci.yml

key-decisions:
  - "Plan's interfaces-block SHA table (resolved 2026-07-06 against @v4/@v5/@v6/@v3/@v8 tags) was stale in all 3 repos — dependabot's github-actions ecosystem (already configured in all 3) had bumped every file's tags forward by execution time (checkout@v7, setup-node@v6, setup-python@v6, codeql-action@v4, upload-pages-artifact@v5, deploy-pages@v5, action-semantic-pull-request@v6, stale@v10). Re-resolved fresh SHAs via `gh api repos/<owner>/<action>/commits/<tag>` against the tags actually present, rather than using the plan's table verbatim. `actions/github-script@v9` was the one entry that still matched the table exactly, serving as a cross-check that the resolution methodology was sound."
  - "autogen's codeql.yml, pr-lint.yml, and stale.yml already carried the exact permissions: blocks the plan's interfaces block said were missing (someone/something added them between 31-01's audit on 2026-07-06 and this plan's execution). No permissions changes were needed — SHA-pinning only, matching what the files actually needed rather than what the stale audit claimed."
  - "Used `git worktree add <path> -b <branch> origin/<default>` per repo instead of `git checkout -b` in the existing working tree, to fully isolate remediation work from each repo's dirty/foreign working-tree state (Promptimprover, autogen, and autopilot-core all had unrelated uncommitted changes or were parked on stale feature branches — autogen explicitly flagged in the plan as carrying foreign dirty files that must never be staged/committed/discarded). Removed worktrees after pushing; original working trees, branches, and uncommitted changes were left completely untouched."
  - "Extended autopilot-core's scope beyond the plan's declared 9-file list to also fix templates/demo-repo/.github/workflows/autopilot-create-issue.yml and demo-ci.yml (unpinned action, missing permissions, missing timeout) — these are scanned by workflow-lint's recursive sweep and would have made Task 2's own automated verify command fail otherwise. Documented as Rule 2 deviation."
  - "No Azure-deploy workflows found in any of the 3 repos remediated this plan (grepped for azure/Azure/AZURE across all workflow files in all 3 repos — zero matches), so the plan's NO-AZURE workflow_dispatch-gating instruction did not apply to this batch."
  - "autogen PR body documents the explicit merge-order dependency with the two other open PRs that touch/neighbor ci.yml (#11 coverage-gates, #12 fault-injection) per the plan's instruction: merge #11 first, then update-branch this PR, then handle #12. Neither of those PR branches was read, staged, or touched."

patterns-established:
  - "When a plan's pre-resolved SHA table is more than ~1 day old, re-verify against the tags actually present in the target files before applying — dependabot or other agents may have moved tags forward in the interim (same pattern independently discovered and documented in 31-05's summary for ci-autopilot)."
  - "For repos with dirty/foreign working-tree state that must not be touched, branch remediation work into a `git worktree add -b <branch> origin/<default>` sandbox rather than `git checkout -b` in place — avoids any risk of carrying, committing, or discarding unrelated changes."

requirements-completed: [REQ-1.4.10]

duration: 55min
completed: 2026-07-07
---

# Phase 31 Plan 02: Promptimprover + autogen + autopilot-core + autopilot-demo Workflow Hardening Summary

**SHA-pinned every third-party GitHub Action across 19 workflow files in 3 repos (Promptimprover, autogen, autopilot-core), opened 3 PRs (none merged), and confirmed autopilot-demo is already fully compliant with no changes needed — all remediation done in isolated git worktrees to avoid touching each repo's pre-existing dirty/foreign working-tree state.**

## Performance

- **Duration:** 55 min
- **Started:** 2026-07-07T18:40:00Z
- **Completed:** 2026-07-07T19:35:00Z
- **Tasks:** 3 (all completed)
- **Files modified:** 19 workflow files across 3 repos (+ 2 out-of-scope template files fixed as a Rule 2 deviation)

## Accomplishments

- **Promptimprover** (Task 1, half): all 5 workflow files (`ci.yml`, `codeql.yml`, `pages.yml`, `pr-lint.yml`, `stale.yml`) fully SHA-pinned. `permissions:`/`timeout-minutes:` were already present everywhere — pin-only change. PR #28 open against `master` (confirmed via `gh repo view --json defaultBranchRef`).
- **autogen** (Task 1, half): all 5 workflow files fully SHA-pinned. `codeql.yml`, `pr-lint.yml`, `stale.yml` already had the exact `permissions:` blocks the plan expected to be missing — no permission changes needed. PR #13 open against `main`, with an explicit merge-order note re: PRs #11 (coverage-gates) and #12 (fault-injection), both of which touch/neighbor `ci.yml` — neither branch was read or touched.
- **autopilot-core** (Task 2): all 9 root workflow files fully SHA-pinned, `permissions:`/`timeout-minutes:` already present everywhere. Additionally fixed 2 `templates/demo-repo/` scaffold workflow files (unpinned action, missing permissions, missing timeout) that `workflow-lint`'s recursive scan caught but were outside the plan's declared 9-file list — fixed so the repo's own verify gate passes and installer-scaffolded repos inherit compliant templates. PR #15 open against `main`.
- **autopilot-demo** (Task 3): audited against `origin/main` (`ec62179`) — `workflow-lint.ps1` reports `workflow-lint: clean.` No changes, no branch, no PR — confirmed compliant, not silently skipped.
- All SHAs resolved fresh via `gh api repos/<owner>/<action>/commits/<tag>` on 2026-07-07 rather than reusing the plan's 2026-07-06 table, since dependabot (already configured with a `github-actions` ecosystem entry in all 3 repos) had moved every tag forward by execution time.
- Zero Azure-deploy workflows found in any of the 3 repos (grepped, zero matches) — the plan's NO-AZURE workflow_dispatch-gating step did not apply to this batch.

## Task Commits

| Task | Repo | Commit | Branch | PR |
| ---- | ---- | ------ | ------ | -- |
| 1 | Promptimprover | `f28dbe1` (ci) | `ci/sha-pin-and-least-privilege` | [#28](https://github.com/Coding-Autopilot-System/Promptimprover/pull/28) |
| 1 | autogen | `b35dd88` (ci) | `ci/phase-31-workflow-hardening` | [#13](https://github.com/Coding-Autopilot-System/autogen/pull/13) |
| 2 | autopilot-core | `cbfbc04` (ci) | `ci/sha-pin-actions` | [#15](https://github.com/Coding-Autopilot-System/autopilot-core/pull/15) |
| 3 | autopilot-demo | — (audit only, no commit) | — | none needed |

**Plan metadata:** committed to `.planning/` in this repo (PersonalRepo), separate from the 3 target-repo commits above.

## Files Created/Modified

- `portfolio/Promptimprover/.github/workflows/{ci,codeql,pages,pr-lint,stale}.yml` — SHA-pinned checkout@v7, setup-node@v6, setup-python@v6, codeql-action/{init,autobuild,analyze}@v4, upload-pages-artifact@v5, deploy-pages@v5, action-semantic-pull-request@v6, stale@v10
- `portfolio/autogen/.github/workflows/{ci,codeql,pages,pr-lint,stale}.yml` — same SHA-pinning set (checkout, setup-python, codeql-action, upload-pages-artifact, deploy-pages, action-semantic-pull-request, stale); `contract-registry-live.yml` was already SHA-pinned and left untouched
- `portfolio/autopilot-core/.github/workflows/{autopilot-create-issue,autopilot-docs-daily,autopilot-operator,autopilot-org-installer,ci,codeql,pages,pr-lint,stale}.yml` — SHA-pinned checkout, github-script, setup-python, codeql-action, upload-pages-artifact, deploy-pages, action-semantic-pull-request, stale
- `portfolio/autopilot-core/templates/demo-repo/.github/workflows/autopilot-create-issue.yml` — SHA-pinned github-script@v9, added `timeout-minutes: 10` to `create-issue` job (out-of-scope fix, see Deviations)
- `portfolio/autopilot-core/templates/demo-repo/.github/workflows/demo-ci.yml` — added top-level `permissions: contents: read` and `timeout-minutes: 10` to `demo` job (out-of-scope fix, see Deviations)

## Decisions Made

- Re-resolved every SHA fresh via `gh api` against the tags actually present in each file rather than the plan's 2026-07-06 interfaces-block table, which had gone stale by execution time (dependabot had already bumped checkout to v7, setup-node/setup-python to v6, codeql-action to v4, upload-pages-artifact/deploy-pages to v5, action-semantic-pull-request to v6, stale to v10 in all 3 repos). `actions/github-script@v9` was the one action whose tag matched the table exactly, and its resolved SHA matched the table's SHA exactly — confirming the resolution methodology.
- Did not add `permissions:` blocks to autogen's `codeql.yml`, `pr-lint.yml`, `stale.yml` as the plan instructed, because all three already had the exact blocks the plan wanted added (verified by reading each file before editing). Applying the plan's instructions verbatim would have been a no-op producing duplicate keys; skipped and documented instead.
- Isolated all 3 repos' remediation work in throwaway `git worktree` sandboxes (`git worktree add <path> -b <branch> origin/<default-branch>`) rather than branching in-place, because Promptimprover, autogen, and autopilot-core all had unrelated dirty working-tree state (uncommitted feature work, or — for autogen — an explicit plan instruction never to stage/commit/discard foreign dirty files). Verified after the fact that all 3 original working trees, their checked-out branches, and their uncommitted changes were completely untouched.
- Extended scope in autopilot-core to fix `templates/demo-repo/.github/workflows/*.yml` (2 files, out of the plan's declared 9-file list) because `workflow-lint.ps1 -Path portfolio/autopilot-core` recursively scans the whole repo tree and would have failed Task 2's own automated verify step otherwise. Rule 2 deviation (missing correctness requirement in files the plan's own gate covers).
- Grepped all 3 repos' workflow directories for `azure`/`Azure`/`AZURE` and found zero matches — no Azure-deploy workflows exist in this batch, so the plan's NO-AZURE workflow_dispatch-gating step and PR-body note were not applicable and were skipped.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Plan's pre-resolved SHA table was stale against current file content in all 3 repos**
- **Found during:** Task 1 (Promptimprover, autogen), Task 2 (autopilot-core) — baseline `workflow-lint.ps1 -Json` run before editing
- **Issue:** The plan's interfaces block provided SHAs resolved on 2026-07-06 for `checkout@v4/v5/v6`, `setup-node@v5`, `setup-python@v5`, `upload-pages-artifact@v3`, `deploy-pages@v4`, `codeql-action/*@v3`, `action-semantic-pull-request@v5`, `stale@v8` — but every file in all 3 repos at execution time referenced newer tags (`@v7`, `@v6`, `@v6`, `@v5`, `@v5`, `@v4`, `@v6`, `@v10`). Using the plan's table verbatim would have pinned the files to older action versions than what dependabot had already advanced them to, effectively downgrading them.
- **Fix:** Re-resolved fresh SHAs via `gh api repos/<owner>/<action>/commits/<tag>` for each tag actually present, applied consistently across all 3 repos.
- **Files modified:** all 19 workflow files listed above (across Promptimprover, autogen, autopilot-core)
- **Verification:** `workflow-lint.ps1 -Path <worktree> -Json` returns `workflow-lint: clean.` for all 3 repos; `git diff --stat` in each worktree confirms only `uses:`/`permissions:`/`timeout-minutes:` lines changed, no job logic touched.
- **Committed in:** `f28dbe1` (Promptimprover), `b35dd88` (autogen), `cbfbc04` (autopilot-core)

**2. [Rule 1 - Bug] Plan's interfaces block incorrectly claimed autogen's codeql.yml/pr-lint.yml/stale.yml were missing permissions blocks**
- **Found during:** Task 1 (autogen), reading each file before editing
- **Issue:** The plan instructed adding `permissions:` blocks to 3 autogen files based on the 31-01 audit finding them missing. By execution time all 3 already had the exact blocks specified (`contents: read` + job-level `actions/contents/security-events` for codeql.yml; `pull-requests: read` for pr-lint.yml; `issues/pull-requests: write` for stale.yml).
- **Fix:** Skipped the permissions-block additions entirely (would have been duplicate-key no-ops); SHA-pinning only, matching actual file state.
- **Files modified:** none beyond the SHA-pinning changes already listed
- **Verification:** `workflow-lint.ps1` shows zero `missing-permissions` findings for autogen both before and after this plan's changes.
- **Committed in:** `b35dd88`

**3. [Rule 2 - Missing functionality] autopilot-core's demo-repo scaffold templates had their own unpinned-action/missing-permissions/missing-timeout findings**
- **Found during:** Task 2, baseline `workflow-lint.ps1 -Json` run (recursive scan surfaced `templates/demo-repo/.github/workflows/*.yml`, not part of the plan's declared 9-file list)
- **Issue:** `templates/demo-repo/.github/workflows/autopilot-create-issue.yml` had an unpinned `actions/github-script@v9` and no `timeout-minutes:` on its job; `demo-ci.yml` had no `permissions:` block and no `timeout-minutes:`. These templates are copied verbatim into other repos by `autopilot-org-installer.yml`, and Task 2's own automated verify command (`workflow-lint.ps1 -Path portfolio/autopilot-core -Json`, no path exclusion) would have failed with these findings present.
- **Fix:** SHA-pinned `github-script@v9`, added `timeout-minutes: 10` to the `create-issue` job; added top-level `permissions: contents: read` and `timeout-minutes: 10` to the `demo` job in `demo-ci.yml`.
- **Files modified:** `portfolio/autopilot-core/templates/demo-repo/.github/workflows/autopilot-create-issue.yml`, `portfolio/autopilot-core/templates/demo-repo/.github/workflows/demo-ci.yml`
- **Verification:** `workflow-lint.ps1 -Path .worktrees/autopilot-core-ci -Json` returns `workflow-lint: clean.` after the fix (previously reported 3 findings across these 2 files).
- **Committed in:** `cbfbc04`

---

**Total deviations:** 3 auto-fixed (2 bug-class corrections to plan-provided data, 1 missing-functionality fix required for the plan's own verify gate to pass)
**Impact on plan:** All 3 fixes were necessary for correctness — pinning the right action versions, not creating duplicate permissions keys, and satisfying the plan's own stated verification command. The one scope extension (demo-repo templates) stayed within the same repo and the same category of change (SHA-pin + permissions + timeout) the plan was already making; no unrelated files were touched.

## Issues Encountered

- `pwsh` (PowerShell 7) is not on PATH in the Bash tool's Git Bash environment; fell back to `powershell.exe -File scripts/workflow-lint.ps1 ...` (Windows PowerShell 5.1), which the 31-01 falsifier is explicitly built to be compatible with. Produced identical `workflow-lint: clean.` output to what `pwsh` would have.
- All 3 repos' checked-out working trees had unrelated dirty state or were parked on non-default branches (Promptimprover: uncommitted `.planning`/`universal-refiner` changes on `master`; autogen: on `feat/phase-26-coverage-gates` with many uncommitted files, matching the plan's explicit warning; autopilot-core: one uncommitted `scripts/autopilot-operator.ps1` change on `main`). Worked around entirely via isolated `git worktree` sandboxes branched from a freshly-fetched `origin/<default>` tip — confirmed via `git status --short` before and after that none of that foreign state was staged, committed, or discarded.

## Self-Check: PASSED

- FOUND: portfolio/Promptimprover/.github/workflows/ci.yml
- FOUND: portfolio/Promptimprover/.github/workflows/codeql.yml
- FOUND: portfolio/Promptimprover/.github/workflows/pages.yml
- FOUND: portfolio/Promptimprover/.github/workflows/pr-lint.yml
- FOUND: portfolio/Promptimprover/.github/workflows/stale.yml
- FOUND: portfolio/autogen/.github/workflows/ci.yml
- FOUND: portfolio/autogen/.github/workflows/codeql.yml
- FOUND: portfolio/autogen/.github/workflows/pages.yml
- FOUND: portfolio/autogen/.github/workflows/pr-lint.yml
- FOUND: portfolio/autogen/.github/workflows/stale.yml
- FOUND: portfolio/autopilot-core/.github/workflows/ci.yml (+ 8 more root workflow files)
- FOUND: portfolio/autopilot-core/templates/demo-repo/.github/workflows/autopilot-create-issue.yml
- FOUND: portfolio/autopilot-core/templates/demo-repo/.github/workflows/demo-ci.yml
- FOUND: commit f28dbe1 in Promptimprover repo (branch ci/sha-pin-and-least-privilege)
- FOUND: commit b35dd88 in autogen repo (branch ci/phase-31-workflow-hardening)
- FOUND: commit cbfbc04 in autopilot-core repo (branch ci/sha-pin-actions)
- FOUND: PR #28 open at https://github.com/Coding-Autopilot-System/Promptimprover/pull/28 (state=OPEN)
- FOUND: PR #13 open at https://github.com/Coding-Autopilot-System/autogen/pull/13 (state=OPEN)
- FOUND: PR #15 open at https://github.com/Coding-Autopilot-System/autopilot-core/pull/15 (state=OPEN)
- CONFIRMED: autopilot-demo `workflow-lint.ps1 -Path portfolio/autopilot-demo -Json` against origin/main tip ec62179 returns `workflow-lint: clean.`, no PR opened
- CONFIRMED: all 3 original repo working trees (Promptimprover@master, autogen@feat/phase-26-coverage-gates, autopilot-core@main) unchanged — same branch, same dirty files, before and after this plan

## User Setup Required

None — no external service configuration required. The 3 PRs are open and await human review/merge (out of scope for this plan and for Phase 30's merge-train equivalent, per the plan's stated "PR-only; never merge/approve/touch protection" instruction).

## Next Phase Readiness

- Promptimprover, autogen, and autopilot-core each have an open PR closing all `workflow-lint` findings on their respective repos.
- autopilot-demo is confirmed clean, no follow-up needed.
- autogen's PR explicitly documents the merge-order dependency with PRs #11 and #12 for whoever merges it.
- Phase 31 wave 3's re-verification sweep can include all 3 of this plan's PR branches as expected-clean, alongside 31-01/31-05's outputs.

---
*Phase: 31-org-ci-supply-chain-hardening*
*Completed: 2026-07-07*
