---
phase: 39-release-engineering
plan: 01
subsystem: infra
tags: [release-please, github-actions, ci, powershell, pester, workspace-health]

# Dependency graph
requires: []
provides:
  - "SHA-pinned reusable release-please workflow in org-dotgithub (portfolio/org-dotgithub/.github/workflows/release-please-reusable.yml), pin SHA f288e5e3b67b29a2c08880b76da7b852f4a132d0"
  - "org-dotgithub's own dogfooded caller workflow + release-please-config.json + .release-please-manifest.json proving the cross-repo call pattern"
  - "RELEASE_POLICY.md 'Release Automation (v1.5)' section documenting tool choice, uniform release-type, per-repo SemVer independence, and bootstrap baseline rules"
  - "workspace-health.ps1 release-stale finding (block 12) detecting repos whose last SemVer release is >30 days old with commits since, or never released"
affects: [39-02-release-please-repos-wave-a, 39-03-release-please-repos-wave-b]

# Tech tracking
tech-stack:
  added: ["googleapis/release-please-action@v5.0.0 (SHA-pinned)"]
  patterns:
    - "Reusable GitHub Actions workflow (workflow_call) hosted once in org-dotgithub, consumed by other repos via SHA pin"
    - "Isolated git worktree from freshly-fetched origin/<default> for repo tasks, leaving dirty/parked primary checkouts completely untouched"
    - "TDD gate sequence (test commit then feat commit) for a single tdd=\"true\" task within an otherwise non-TDD plan"

key-files:
  created:
    - portfolio/org-dotgithub/.github/workflows/release-please-reusable.yml
    - portfolio/org-dotgithub/.github/workflows/release-please.yml
    - portfolio/org-dotgithub/release-please-config.json
    - portfolio/org-dotgithub/.release-please-manifest.json
  modified:
    - portfolio/org-dotgithub/docs/RELEASE_POLICY.md
    - scripts/workspace-health.ps1
    - tests/Workspace.Health.Tests.ps1

key-decisions:
  - "Used isolated git worktrees (branched off freshly-fetched origin/main / origin/master) for both repo tasks instead of touching the primary checkouts, which were dirty and/or parked on unrelated branches per the plan's preflight_isolation block"
  - "Root repo change went through a PR (branch feat/phase-39-release-engineering) instead of a direct master commit, per the plan's corrected flow (master now has enforce_admins branch protection)"
  - "Split Task 2 into two commits (test then feat) to satisfy the TDD gate sequence for its tdd=\"true\" flag, and verified genuine RED by reverting the implementation file and confirming the 2 behavior-asserting tests fail before restoring and confirming GREEN"

patterns-established:
  - "Pattern: cross-repo release automation logic lives in exactly one place (org-dotgithub), consumed by SHA pin, never a floating branch ref"
  - "Pattern: workspace-health.ps1 new checks stay local-git-only (no gh/network dependency) unless explicitly gated like the existing stale-PR check"

requirements-completed: [REQ-1.5.5]
requirements-contributed: [REQ-1.5.3]  # not marked complete: falsifier requires "every portfolio repo" wired; 39-02/39-03 wire the remaining 12

# Metrics
duration: 45min
completed: 2026-07-10
---

# Phase 39 Plan 01: Release Engineering Foundation Summary

**SHA-pinned reusable release-please workflow in org-dotgithub (dogfooded by itself) plus a local-git-only release-staleness check added to workspace-health.ps1, both delivered as open PRs from isolated worktrees.**

## org-dotgithub reusable workflow pin SHA

```
f288e5e3b67b29a2c08880b76da7b852f4a132d0
```

This is the commit SHA of `portfolio/org-dotgithub/.github/workflows/release-please-reusable.yml`'s first commit on branch `ci/release-please-automation`. Wave-2/3 plans (39-02, 39-03) must reference this exact SHA in each caller repo's `uses:` line — do not re-derive it. It will need to be re-verified/updated once PR #16 merges (a merge commit or squash will produce a new SHA on `main`; the plan's own caller workflow in this PR already references this pre-merge SHA which is valid since both commits are on the same branch).

## Performance

- **Duration:** ~45 min
- **Tasks:** 2/2 complete
- **Files modified:** 7 (4 created + 3 modified across 2 repos)

## Accomplishments
- Created `.github/workflows/release-please-reusable.yml` in org-dotgithub: a `workflow_call` workflow wrapping `googleapis/release-please-action@45996ed1f6d02564a971a2fa1b5860e934307cf7` (v5.0.0), SHA-pinned, with job-level `contents/pull-requests/issues: write` permissions and an optional `release-type` input (default `simple`), no `target-branch` input.
- Dogfooded the pattern in org-dotgithub itself: `release-please-config.json`, `.release-please-manifest.json` (bootstrap `"0.0.0"`), and `.github/workflows/release-please.yml` calling the reusable workflow by the SHA above.
- Documented the release-automation approach in `docs/RELEASE_POLICY.md` under a new "Release Automation (v1.5)" section (tool choice, uniform `release-type: simple`, per-repo SemVer independence, bootstrap baseline rules, SHA-pin policy).
- Added a `release-stale` finding (block 12) to `scripts/workspace-health.ps1`: flags a repo whose latest SemVer tag is >30 days old with commits merged since it, or has no SemVer tag at all — local git only, no `gh`/network dependency.
- Added 4 new Pester `It` blocks to `tests/Workspace.Health.Tests.ps1` under a `Context 'Release staleness'`: a deterministic RED fixture (45-day-old tag faked via `GIT_COMMITTER_DATE`/`GIT_AUTHOR_DATE`), two no-false-positive cases, and a no-tag case.
- Both changes delivered as open PRs (org-dotgithub PR #16, root repo PR #17) from isolated git worktrees, leaving both dirty/parked primary checkouts completely untouched.

## Task Commits

Each task was committed atomically, in an isolated worktree per repo:

**Task 1 (org-dotgithub, worktree `C:\PersonalRepo\worktrees\org-dotgithub-release-please`, branch `ci/release-please-automation`):**
1. `f288e5e` — `ci: add reusable release-please workflow` (this is the pin SHA)
2. `eb491a9` — `ci(release): dogfood the reusable release-please workflow`

**Task 2 (root repo, worktree `C:\PersonalRepo\worktrees\phase-39-release-engineering`, branch `feat/phase-39-release-engineering`):**
3. `8c8fed2` — `test(39-01): add release-staleness Pester fixtures for workspace-health.ps1` (TDD RED gate)
4. `dbaab04` — `feat(39-01): add release-staleness finding to workspace-health.ps1` (TDD GREEN gate)

**Plan metadata:** committed separately on the root repo's primary checkout (current branch `docs/phase-38-plan-fixes`), staging only this SUMMARY.md and STATE.md/ROADMAP.md/REQUIREMENTS.md individually — no other dirty files on that checkout were touched.

_Note: both worktrees were removed after their branch was pushed and the PR opened; the primary checkouts (`portfolio/org-dotgithub` on `docs/phase-36-refresh`, root on `docs/phase-38-plan-fixes`) were verified unchanged before and after._

## TDD Gate Compliance

Task 2 (`tdd="true"`) followed the RED -> GREEN cycle correctly:
- RED gate: `test(39-01): ...` commit `8c8fed2` exists.
- GREEN gate: `feat(39-01): ...` commit `dbaab04` exists after it.
- Genuine RED was verified out-of-band (not just via commit ordering): the implementation file was reverted to its pre-change state, Pester was re-run and the 2 behavior-asserting tests failed with `Expected 1, but got 0`, then the implementation was restored and Pester was re-run to confirm all 11 tests pass (GREEN) before the `feat(...)` commit was made.
- No REFACTOR commit was needed — no cleanup required after GREEN.

## Pull Requests

| Repo | Branch | PR | Files |
|---|---|---|---|
| `Coding-Autopilot-System/.github` (org-dotgithub) | `ci/release-please-automation` | https://github.com/Coding-Autopilot-System/.github/pull/16 | release-please-reusable.yml, release-please.yml, release-please-config.json, .release-please-manifest.json, docs/RELEASE_POLICY.md |
| `OgeonX-Ai/cas-workstation` (root) | `feat/phase-39-release-engineering` | https://github.com/OgeonX-Ai/cas-workstation/pull/17 | scripts/workspace-health.ps1, tests/Workspace.Health.Tests.ps1 |

Both PRs are open, unmerged, per the PR-only / never-merge-or-approve convention. Neither repo's branch protection was bypassed.

## Files Created/Modified
- `portfolio/org-dotgithub/.github/workflows/release-please-reusable.yml` - workflow_call entry point wrapping googleapis/release-please-action, SHA-pinned
- `portfolio/org-dotgithub/.github/workflows/release-please.yml` - caller workflow, push-to-main trigger, calls the reusable workflow by pin SHA
- `portfolio/org-dotgithub/release-please-config.json` - release-type simple, package ".", changelog-path CHANGELOG.md
- `portfolio/org-dotgithub/.release-please-manifest.json` - bootstrap {".": "0.0.0"}
- `portfolio/org-dotgithub/docs/RELEASE_POLICY.md` - new "Release Automation (v1.5)" section
- `scripts/workspace-health.ps1` - new release-stale finding (block 12)
- `tests/Workspace.Health.Tests.ps1` - new "Release staleness" Context (4 It blocks)

## Decisions Made
- Isolated worktrees for both repo tasks (see key-decisions in frontmatter) rather than touching either dirty/parked primary checkout.
- Root repo work went through PR flow on branch `feat/phase-39-release-engineering` rather than a direct `master` commit, per the plan's corrected instructions (checker blocker #1: `enforce_admins` is now live on `master`).
- Split Task 2 into `test(...)` then `feat(...)` commits and verified genuine RED/GREEN by temporarily reverting the implementation file, to honor the task's `tdd="true"` flag with an honest (not merely cosmetic) TDD gate sequence.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed a Pester regex mismatch in the RED-fixture assertion**
- **Found during:** Task 2, first Pester run
- **Issue:** The RED-fixture test asserted `Detail` matched `'(\d+)d \(threshold 30d\)'`, but the implementation's Detail string reads `"'<tag>' is <N>d old (threshold 30d) with <M> commit(s) merged since"` — the literal word "old" between the day count and the threshold parenthetical wasn't in the regex, so the assertion never matched even though the finding itself was correct.
- **Fix:** Updated the regex to `'(\d+)d old \(threshold 30d\)'`.
- **Files modified:** tests/Workspace.Health.Tests.ps1
- **Verification:** Re-ran Pester; assertion passed.
- **Committed in:** `8c8fed2` (test commit, fixed before the RED-then-GREEN verification pass)

**2. [Rule 1 - Bug] Fixed `$Matches` scope loss across `Should -Match` calls in Pester**
- **Found during:** Task 2, second Pester run
- **Issue:** `Should -Match` is a Pester function call, not PowerShell's native `-match` operator, so it does not populate the caller's `$Matches` automatic variable. The test tried to read `$Matches[1]` immediately after a `Should -Match` call and got `RuntimeException: Cannot index into a null array`.
- **Fix:** Added an explicit native `-match` evaluation (`$stale[0].Detail -match '...'`) immediately before reading `$Matches[1]`, keeping the `Should -Match` call for the readable failure message.
- **Files modified:** tests/Workspace.Health.Tests.ps1
- **Verification:** Re-ran Pester; all 11 tests passed.
- **Committed in:** `8c8fed2` (test commit, fixed before the RED-then-GREEN verification pass)

---

**Total deviations:** 2 auto-fixed (both Rule 1 - test-file bugs found and fixed while authoring the TDD RED fixture, before any commit was made)
**Impact on plan:** Both fixes were to test assertions, not to production code. No scope creep; the implementation in `scripts/workspace-health.ps1` matched the plan's `<behavior>` spec on first write.

## Issues Encountered
- Running `workspace-health.ps1` from Bash with an explicit `-Root C:\PersonalRepo` argument produced silent empty output (git-bash mangled the Windows path). Resolved by omitting `-Root` and relying on the script's own `"C:\PersonalRepo"` default, which round-tripped correctly. This is a Bash/MSYS path-quoting artifact of the verification environment, not a script bug — confirmed by also running via `pwsh` with `-Json`, which parsed cleanly and returned 55 findings including `release-stale` entries.
- `git push` from the root worktree printed a benign warning (`"/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential store: line 1: ... No such file or directory`) from a misconfigured credential-helper path lookup (already documented as a known finding class — `credential-helper-wsl-path` — by this very script). The push itself succeeded.

## User Setup Required
None - no external service configuration required. Both PRs are informational until a human reviews and merges them (per org convention, this plan does not merge).

## Next Phase Readiness
- 39-02 and 39-03 can now wire the other 12 portfolio repos against pin SHA `f288e5e3b67b29a2c08880b76da7b852f4a132d0` for their own `release-please.yml` caller workflows.
- `workspace-health.ps1`'s live sweep (run during this plan) confirms `cas-contracts` and `gsd-orchestrator` — the two repos with real pre-existing tags (1.1.1 and 4.0.0) — do NOT trigger `release-stale`, validating the check against the exact repos the plan's bootstrap-rationale section calls out by name.
- Both PR #16 and PR #17 need human review/merge before their respective changes take effect; no blockers on this plan's own scope.

---
*Phase: 39-release-engineering*
*Completed: 2026-07-10*

## Self-Check: PASSED

- FOUND: `.planning/phases/39-release-engineering/39-01-SUMMARY.md`
- FOUND (portfolio/org-dotgithub, all refs): `f288e5e`, `eb491a9`
- FOUND (root repo, all refs): `8c8fed2`, `dbaab04`
- FOUND (open PRs, verified via `gh pr view --json state`): PR #16 (org-dotgithub, OPEN), PR #17 (root, OPEN)
- FOUND: both primary checkouts (`portfolio/org-dotgithub` on `docs/phase-36-refresh`, root on `docs/phase-38-plan-fixes`) confirmed unchanged before/after via `git status --short` and `git branch --show-current`
