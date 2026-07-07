---
phase: 31-org-ci-supply-chain-hardening
plan: 05
subsystem: infra
tags: [github-actions, supply-chain, sha-pinning, pytest-cov, self-hosted-runner, ci-autopilot]

requires:
  - phase: 31-org-ci-supply-chain-hardening
    provides: "scripts/workflow-lint.ps1 falsifier and org-wide violation inventory (31-01)"
provides:
  - "ci-autopilot fully SHA-pinned across all 10 workflow files"
  - "ci-autopilot CI enforces a 90% coverage floor via pytest-cov (--cov-fail-under=90)"
  - "Documented token-scope review of fixer.yml and runner-health.yml (self-hosted-runner risk)"
  - "Open PR #2233 against ci-autopilot main (not merged)"
affects: [31-06, phase-31-wave-3-reverify]

tech-stack:
  added: [pytest-cov]
  patterns: ["SHA-pin third-party GitHub Actions with trailing # vX.Y.Z comment", "coverage-regression gate via --cov-fail-under set as a safety margin below verified baseline"]

key-files:
  created: []
  modified:
    - portfolio/ci-autopilot/.github/workflows/codeql.yml
    - portfolio/ci-autopilot/.github/workflows/pages.yml
    - portfolio/ci-autopilot/.github/workflows/pr-lint.yml
    - portfolio/ci-autopilot/.github/workflows/stale.yml
    - portfolio/ci-autopilot/.github/workflows/ci.yml
    - portfolio/ci-autopilot/requirements.txt
    - portfolio/ci-autopilot/.gitignore

key-decisions:
  - "Plan's interfaces-block SHA table (resolved 2026-07-06 against @v4/@v5/@v3/@v8 tags) was stale — the repo's workflow files had already moved to newer tags (checkout@v7, codeql-action@v4, setup-python@v6, upload-pages-artifact@v5, deploy-pages@v5, action-semantic-pull-request@v6, stale@v10) by execution time. Re-resolved fresh SHAs via `gh api repos/<owner>/<action>/commits/<tag>` against the tags actually present in each file rather than using the plan's table verbatim."
  - "Followed the plan's explicit single-branch/single-commit/single-PR instruction for Tasks 1-3 combined (rather than the generic per-task-commit norm) since Task 3's action block explicitly specifies one commit message covering all three tasks, one branch, one PR."
  - "fixer.yml's issues: read scope confirmed already-minimal after reading agent/poll_once.py end-to-end: it issues only a single GET /repos/{owner}/{repo}/issues call, no gh issue/pr write calls anywhere. No escalation applied."
  - "runner-health.yml's issues: write confirmed already correctly scoped (used for its stated purpose: creating/commenting on a runner-offline issue). No change applied."
  - "NO-AZURE deploy-lock operator rule does not apply to this repo — ci-autopilot has no Azure-deploy workflow (pages.yml deploys to GitHub Pages only). Noted explicitly in the PR body."

patterns-established:
  - "Before applying a plan's pre-resolved SHA table, re-verify the tags in the interfaces block still match the tags currently in the target files — dependabot/other agents may have moved tags between plan authoring and execution."

requirements-completed: [REQ-1.4.10]

duration: 25min
completed: 2026-07-07
---

# Phase 31 Plan 05: ci-autopilot Supply-Chain Hardening + Coverage Gate Summary

**Full SHA-pinning of ci-autopilot's last 4 unpinned workflows, a 90%-floor pytest-cov gate replacing `unittest discover`, and a documented self-hosted-runner token-scope review — all on one PR branch, not merged.**

## Performance

- **Duration:** 25 min
- **Started:** 2026-07-07T15:11:00Z
- **Completed:** 2026-07-07T15:36:26Z
- **Tasks:** 3 (all completed)
- **Files modified:** 7

## Accomplishments
- All 10 of ci-autopilot's workflow files are now fully SHA-pinned (codeql.yml, pages.yml, pr-lint.yml, stale.yml newly pinned this plan; the other 6 were already pinned).
- ci.yml's CI job now runs `pytest --cov=agent --cov-report=term-missing --cov-fail-under=90 tests/` instead of `python -m unittest discover -v`, with a new `pip install -r requirements.txt` step (none existed previously). Verified locally: 48 tests pass, 98.20% coverage.
- Token-scope review of fixer.yml (self-hosted Windows runner) and runner-health.yml completed and documented — both confirmed already-minimal, no changes needed.
- PR #2233 opened against `main`, not merged.

## Task Commits

All three tasks were combined into a single branch/commit/PR per the plan's explicit Task 3 instruction (not the generic per-task-commit pattern):

1. **Tasks 1-3 combined: SHA-pin remaining workflows, coverage gate, token-scope review** - `8da3abc` (ci) — on branch `ci/sha-pin-and-coverage-gate`, pushed to `origin/ci/sha-pin-and-coverage-gate`

**Plan metadata:** committed to `.planning/` in this repo (PersonalRepo), separate from the ci-autopilot repo commit above.

## Files Created/Modified
- `portfolio/ci-autopilot/.github/workflows/codeql.yml` - SHA-pinned checkout@v7.0.0, codeql-action/{init,autobuild,analyze}@v4.36.3
- `portfolio/ci-autopilot/.github/workflows/pages.yml` - SHA-pinned checkout@v7.0.0, setup-python@v6.3.0, upload-pages-artifact@v5.0.0, deploy-pages@v5.0.0
- `portfolio/ci-autopilot/.github/workflows/pr-lint.yml` - SHA-pinned action-semantic-pull-request@v6.1.1
- `portfolio/ci-autopilot/.github/workflows/stale.yml` - SHA-pinned actions/stale@v10.3.0
- `portfolio/ci-autopilot/.github/workflows/ci.yml` - Unit tests step switched to pytest --cov-fail-under=90; added pip install step
- `portfolio/ci-autopilot/requirements.txt` - Added pytest-cov
- `portfolio/ci-autopilot/.gitignore` - Added .coverage (new local artifact from coverage-enabled test runs)

## Decisions Made
- Re-resolved SHA pins against the tags actually present in the files (checkout@v7, codeql-action@v4, setup-python@v6, upload-pages-artifact@v5, deploy-pages@v5, action-semantic-pull-request@v6, stale@v10) rather than the plan's interfaces-block table, which had been resolved against older tags (@v4/@v5/@v3/@v8) on 2026-07-06 and no longer matched current file content. All 7 fresh SHAs were independently verified against the exact tag string in each file before applying.
- Followed the plan's explicit Task 3 instruction to batch Tasks 1-3 into a single branch, single commit, single PR rather than committing per-task, since the plan's action block specifies one commit message spanning all three tasks.
- Confirmed fixer.yml's `issues: read` and runner-health.yml's `issues: write` are both already correctly minimal after reading `agent/poll_once.py` end-to-end (single read-only GET call, no write-scoped `gh` calls) — no permission escalation or tightening applied to either file.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Plan's pre-resolved SHA table was stale against current file content**
- **Found during:** Task 1 (pinning codeql.yml, pages.yml, pr-lint.yml, stale.yml)
- **Issue:** The plan's interfaces block provided SHAs resolved on 2026-07-06 for `actions/checkout@v4`, `setup-python@v5`, `upload-pages-artifact@v3`, `deploy-pages@v4`, `codeql-action/*@v3`, `action-semantic-pull-request@v5`, `stale@v8` — but the actual files in the repo at execution time referenced `@v7`, `@v6`, `@v5`, `@v5`, `@v4`, `@v6`, `@v10` respectively. Using the plan's table verbatim would have pinned the files to the wrong (older) action versions, silently downgrading them.
- **Fix:** Re-resolved fresh SHAs via `gh api repos/<owner>/<action>/commits/<tag>` for each tag actually present in the files, cross-verified each SHA against `gh api repos/<owner>/<action>/commits/<exact-patch-tag>` to confirm the resolved commit matches a real, current release tag (not a moving/mutable ref at time of resolution).
- **Files modified:** portfolio/ci-autopilot/.github/workflows/codeql.yml, pages.yml, pr-lint.yml, stale.yml
- **Verification:** `grep -c "uses: [a-z/-]*@v[0-9]"` returns 0 for all 4 files; `workflow-lint.ps1` reports clean.
- **Committed in:** 8da3abc

**2. [Rule 3 - Blocking] .coverage artifact generated by local verification run**
- **Found during:** Task 2 (running pytest --cov locally for verification)
- **Issue:** Running the verification command locally produced an untracked `.coverage` SQLite artifact in the repo root, which would recur on every future coverage-enabled CI/local run and pollute `git status`.
- **Fix:** Added `.coverage` to `.gitignore`. The artifact itself was left untracked/uncommitted (correct — it's a run-time output, not source).
- **Files modified:** portfolio/ci-autopilot/.gitignore
- **Verification:** `git status --short` on `main` after the fact shows `.coverage` as untracked and gitignored, not staged.
- **Committed in:** 8da3abc

---

**Total deviations:** 2 auto-fixed (1 bug-class correction to plan-provided data, 1 blocking/cleanliness fix)
**Impact on plan:** Both fixes were necessary for correctness (pinning the right versions) and repo hygiene (not leaving a runtime artifact untracked and unignored). No scope creep — no files outside the plan's declared `files_modified` list were touched beyond the incidental `.gitignore` addition, which is a direct consequence of Task 2's coverage-gate work.

## Issues Encountered
- `pwsh` is not on PATH in the Bash tool's Git Bash environment; fell back to `powershell.exe -File scripts/workflow-lint.ps1 ...` which is functionally equivalent on this Windows host and produced `workflow-lint: clean.`

## Self-Hosted-Runner Token-Scope Review (Task 3 deliverable)

**fixer.yml** (runs on `[self-hosted, Windows]`) — declares `contents: read`, `issues: read`.
Read `agent/poll_once.py` (the script this workflow executes) end-to-end: its only GitHub API
interaction is a single `GET /repos/{owner}/{repo}/issues?state=open&labels=queued` call (via
either direct HTTPS request with the token or a `gh api ... -X GET` fallback). There is no
`gh issue create`, `gh issue comment`, `gh pr` call, or any other write-scoped API usage
anywhere in the script.
**Determination: already minimal.** No change applied.

**runner-health.yml** (runs on `ubuntu-latest`, a GitHub-hosted runner that only queries the
self-hosted runner's status via the GitHub API — it does not execute on the self-hosted runner
itself) — declares `actions: read`, `issues: write`, `contents: read`. Its steps call
`gh label create`, `gh issue list`, `gh issue comment`, and `gh issue create` to raise/update a
"runner offline" issue when the self-hosted runner is not reporting online.
**Determination: already correctly scoped** for its actual purpose. No change applied.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- ci-autopilot is now fully SHA-pinned (10/10 workflow files) and has an active coverage-regression gate — both close out the plan's stated success criteria.
- PR #2233 is open against `main` and awaits human review/merge (out of scope for this plan and for Phase 30's merge-train equivalent, per the plan's threat-model disposition T-31-16).
- Phase 31 wave 3's re-verification sweep (re-run `workflow-lint.ps1 -Path portfolio` across all repos) can now include ci-autopilot's PR branch content as expected-clean.

---
*Phase: 31-org-ci-supply-chain-hardening*
*Completed: 2026-07-07*

## Self-Check: PASSED

- FOUND: portfolio/ci-autopilot/.github/workflows/codeql.yml
- FOUND: portfolio/ci-autopilot/.github/workflows/pages.yml
- FOUND: portfolio/ci-autopilot/.github/workflows/pr-lint.yml
- FOUND: portfolio/ci-autopilot/.github/workflows/stale.yml
- FOUND: portfolio/ci-autopilot/.github/workflows/ci.yml
- FOUND: portfolio/ci-autopilot/requirements.txt
- FOUND: commit 8da3abc in ci-autopilot repo (branch ci/sha-pin-and-coverage-gate)
- FOUND: PR #2233 open at https://github.com/Coding-Autopilot-System/ci-autopilot/pull/2233 (state=OPEN)
