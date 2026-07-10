---
phase: 39-release-engineering
plan: 03
subsystem: infra
tags: [release-please, github-actions, ci, semver]

# Dependency graph
requires:
  - phase: 39-release-engineering (plan 01)
    provides: "SHA-pinned reusable release-please workflow in org-dotgithub, pin SHA f288e5e3b67b29a2c08880b76da7b852f4a132d0"
provides:
  - "release-please wired (config, manifest, SHA-pinned caller workflow) and PR-opened for cas-platform, cas-reference-product, cas-workstation (portfolio/), ci-autopilot, cloud-security-service-model, and gsd-orchestrator"
  - "gsd-orchestrator bootstrap manifest at 4.0.0, continuing its real existing v1.0.0/v3.0.0/v4.0.0 tag line instead of restarting from zero"
affects: [phase-42-milestone-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Isolated git worktree from freshly-fetched origin/main per repo, leaving dirty/parked primary checkouts completely untouched (same pattern as 39-01/39-02)"
    - "Per-repo bootstrap baseline chosen from real GitHub tag state (gh api .../tags), not local clone tags or milestone-numbering guesses"

key-files:
  created:
    - portfolio/cas-platform/release-please-config.json
    - portfolio/cas-platform/.release-please-manifest.json
    - portfolio/cas-platform/.github/workflows/release-please.yml
    - portfolio/cas-reference-product/release-please-config.json
    - portfolio/cas-reference-product/.release-please-manifest.json
    - portfolio/cas-reference-product/.github/workflows/release-please.yml
    - portfolio/cas-workstation/release-please-config.json
    - portfolio/cas-workstation/.release-please-manifest.json
    - portfolio/cas-workstation/.github/workflows/release-please.yml
    - portfolio/ci-autopilot/release-please-config.json
    - portfolio/ci-autopilot/.release-please-manifest.json
    - portfolio/ci-autopilot/.github/workflows/release-please.yml
    - portfolio/cloud-security-service-model/release-please-config.json
    - portfolio/cloud-security-service-model/.release-please-manifest.json
    - portfolio/cloud-security-service-model/.github/workflows/release-please.yml
    - portfolio/gsd-orchestrator/release-please-config.json
    - portfolio/gsd-orchestrator/.release-please-manifest.json
    - portfolio/gsd-orchestrator/.github/workflows/release-please.yml
  modified: []

key-decisions:
  - "Used isolated git worktrees (branched off freshly-fetched origin/main) for all 6 repo tasks instead of touching any primary checkout, all of which were dirty and/or parked on unrelated branches (cas-platform: fix/bicep-lint-api-version-pinning; ci-autopilot: codex/runner-bootstrap-self-hosted; gsd-orchestrator: feat/phase-26-coverage-gates, explicitly called out as untouchable)"
  - "gsd-orchestrator's .release-please-manifest.json bootstraps at 4.0.0 (its real, GitHub-confirmed latest tag), not 0.0.0 — documented explicitly in that repo's PR body so the deliberate choice isn't mistaken for an oversight"
  - "cas-reference-product bootstraps at 0.0.0 despite a local-only v0.1 git tag, because that tag was never pushed to GitHub (confirmed absent via gh api .../tags) and is not valid three-part SemVer anyway"
  - "Split each repo's changes into two commits (Task 1: config+manifest, Task 2: workflow caller) matching the plan's task structure, mirroring the two-commit style used in 39-01/39-02"

patterns-established:
  - "Pattern: per-repo release-please bootstrap value is always sourced from gh api repos/<org>/<repo>/tags (GitHub's real state), never from local git tags or assumed milestone numbering"

requirements-completed: []  # REQ-1.5.3 not marked complete here: falsifier requires "every portfolio repo" wired and PRs merged; this plan (39-03) plus 39-02 complete the wiring for all 13, but merge + live falsifier check is a human-gated step tracked for Phase 42

# Metrics
duration: 25min
completed: 2026-07-10
---

# Phase 39 Plan 03: Release Engineering — Group B Repos (Wave 2) Summary

**Six PRs wiring release-please into cas-platform, cas-reference-product, cas-workstation, ci-autopilot, cloud-security-service-model, and gsd-orchestrator via the SHA-pinned org-dotgithub reusable workflow, with gsd-orchestrator's manifest deliberately bootstrapped from its real v4.0.0 tag instead of zero.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-07-10T14:14:00Z (approx)
- **Completed:** 2026-07-10T14:38:57Z
- **Tasks:** 2/2 complete
- **Files modified:** 18 (3 new files x 6 repos)

## Accomplishments
- Created isolated worktrees for all 6 group-B repos, each branched `ci/release-please-automation` off a freshly-fetched `origin/main`, without touching any primary checkout.
- Added `release-please-config.json` (release-type `simple`, package `.`, `changelog-path: CHANGELOG.md`) — identical content across all 6 repos.
- Added `.release-please-manifest.json` bootstrapped at `{".": "4.0.0"}` for gsd-orchestrator (its real GitHub-confirmed latest tag) and `{".": "0.0.0"}` for the other five (all confirmed zero-tag on GitHub, including cas-reference-product whose local-only, non-SemVer `v0.1` tag was explicitly excluded as a baseline).
- Added `.github/workflows/release-please.yml` in all 6 repos: triggers on `push: branches: [main]`, job-level `permissions: {contents: write, pull-requests: write, issues: write}`, calling `Coding-Autopilot-System/.github/.github/workflows/release-please-reusable.yml@f288e5e3b67b29a2c08880b76da7b852f4a132d0` — the exact pin SHA recorded in 39-01-SUMMARY.md, re-used verbatim (not re-derived).
- Opened 6 PRs, one per repo, all title `ci(release): wire release-please via org-dotgithub reusable workflow`. gsd-orchestrator's PR body includes an explicit note that its 4.0.0 bootstrap continues its own existing tag line and is a deliberate decision, not an oversight.
- Verified all 6 PRs are `OPEN` via `gh pr view --json state` after creation; none merged or approved, per org PR-only convention.
- Removed all 6 worktrees after push; confirmed all 6 primary checkouts remained on their original (untouched) branches before and after — notably gsd-orchestrator's primary stayed on `feat/phase-26-coverage-gates` throughout.

## Task Commits

Each repo received two atomic commits in its own isolated worktree, on branch `ci/release-please-automation`:

| Repo | Task 1 (config+manifest) | Task 2 (workflow) | PR |
|---|---|---|---|
| cas-platform | `8579a53` | `6ef69e7` | https://github.com/Coding-Autopilot-System/cas-platform/pull/15 |
| cas-reference-product | `267481d` | `a25c510` | https://github.com/Coding-Autopilot-System/cas-reference-product/pull/16 |
| cas-workstation | `bd27d95` | `436fbac` | https://github.com/Coding-Autopilot-System/cas-workstation/pull/22 |
| ci-autopilot | `fd462a7` | `71fa90d` | https://github.com/Coding-Autopilot-System/ci-autopilot/pull/2273 |
| cloud-security-service-model | `f8410fc` | `71cab07` | https://github.com/Coding-Autopilot-System/cloud-security-service-model/pull/17 |
| gsd-orchestrator | `224362c` | `69ea272` | https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/24 |

**Plan metadata:** committed separately on the root repo's primary checkout, on a dedicated branch `docs/phase-39-03-summary` (kept isolated from the parallel 39-02 agent's own branch), staging only this SUMMARY.md and STATE.md/ROADMAP.md/REQUIREMENTS.md — no other dirty files on the root checkout (`docs/phase-38-plan-fixes` working tree) were touched.

_Note: all 6 worktrees (`C:\PersonalRepo\worktrees\<repo>-release-please`) were removed after their branch was pushed and PR opened; each primary checkout was verified unchanged (branch name and dirty-file set identical before/after)._

## Files Created/Modified
- `portfolio/cas-platform/release-please-config.json` / `.release-please-manifest.json` (0.0.0) / `.github/workflows/release-please.yml`
- `portfolio/cas-reference-product/release-please-config.json` / `.release-please-manifest.json` (0.0.0) / `.github/workflows/release-please.yml`
- `portfolio/cas-workstation/release-please-config.json` / `.release-please-manifest.json` (0.0.0) / `.github/workflows/release-please.yml`
- `portfolio/ci-autopilot/release-please-config.json` / `.release-please-manifest.json` (0.0.0) / `.github/workflows/release-please.yml`
- `portfolio/cloud-security-service-model/release-please-config.json` / `.release-please-manifest.json` (0.0.0) / `.github/workflows/release-please.yml`
- `portfolio/gsd-orchestrator/release-please-config.json` / `.release-please-manifest.json` (4.0.0) / `.github/workflows/release-please.yml`

## Decisions Made
- Isolated worktrees off freshly-fetched `origin/main` for all 6 repos rather than touching any dirty/parked primary checkout (see key-decisions in frontmatter).
- gsd-orchestrator manifest bootstrapped at 4.0.0 (not 0.0.0), matching its real GitHub tag history; documented in-PR to avoid the change being mistaken for a mistake during review.
- cas-reference-product bootstrapped at 0.0.0, explicitly ignoring its local-only, non-pushed, non-SemVer `v0.1` git tag.
- Used the pin SHA `f288e5e3b67b29a2c08880b76da7b852f4a132d0` from 39-01-SUMMARY.md verbatim across all 6 repos, matching the SHA used in 39-02's group.

## Deviations from Plan

None - plan executed exactly as written. Both tasks (bootstrap config/manifest, then SHA-pinned caller workflow + PRs) completed with no bugs, missing functionality, blockers, or architectural changes encountered.

## Issues Encountered
- Local PyYAML parsed the workflow's `on:` key as boolean `True` (a known PyYAML 1.1-spec quirk with the bareword `on`) rather than string `"on"`, causing the first verification pass's dict lookup to raise `KeyError: 'branches'`. This was a verification-script issue, not a file-content issue — resolved by reading `d.get('on', d.get(True))` in the check. The workflow YAML itself is unaffected (GitHub Actions parses `on:` correctly).

## User Setup Required
None - no external service configuration required. All 6 PRs are informational until a human reviews and merges them (per org convention, this plan does not merge).

## Next Phase Readiness
- Combined with 39-01 (org-dotgithub) and 39-02 (group A, 6 repos), all 13 portfolio repos now have release-please wired and PR-opened.
- All 6 of this plan's PRs, plus 39-01's and 39-02's, need human review/merge before release-please's own release PRs can begin appearing — the live falsifier (`gh release view` showing notes consistent with history) is tracked for the Phase 42 milestone audit per this plan's `<success_criteria>`.
- No blockers on this plan's own scope.

---
*Phase: 39-release-engineering*
*Completed: 2026-07-10*

## Self-Check: PASSED

- FOUND (cas-platform): `8579a53`, `6ef69e7`
- FOUND (cas-reference-product): `267481d`, `a25c510`
- FOUND (cas-workstation): `bd27d95`, `436fbac`
- FOUND (ci-autopilot): `fd462a7`, `71fa90d`
- FOUND (cloud-security-service-model): `f8410fc`, `71cab07`
- FOUND (gsd-orchestrator): `224362c`, `69ea272`
- FOUND (open PRs, verified via `gh pr view --json state`): cas-platform#15, cas-reference-product#16, cas-workstation#22, ci-autopilot#2273, cloud-security-service-model#17, gsd-orchestrator#24 — all OPEN
- FOUND: all 6 primary checkouts confirmed on their original branches before/after (cas-platform: fix/bicep-lint-api-version-pinning; cas-reference-product: main; cas-workstation: main; ci-autopilot: codex/runner-bootstrap-self-hosted; cloud-security-service-model: fix/bicep-lint-api-version-pinning; gsd-orchestrator: feat/phase-26-coverage-gates)
