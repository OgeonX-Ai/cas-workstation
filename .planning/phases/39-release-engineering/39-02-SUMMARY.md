---
phase: 39-release-engineering
plan: 02
subsystem: infra
tags: [release-please, github-actions, ci, semver, changelog]

# Dependency graph
requires:
  - phase: 39-release-engineering (plan 01)
    provides: "SHA-pinned reusable release-please workflow in org-dotgithub (release-please-reusable.yml), pin SHA f288e5e3b67b29a2c08880b76da7b852f4a132d0"
provides:
  - "Group A (Promptimprover, autogen, autopilot-core, autopilot-demo, cas-contracts, cas-evals) each have an open PR wiring release-please via the org-dotgithub reusable workflow, SHA-pinned"
  - "cas-contracts's release-please manifest correctly bootstraps from its real v1.1.1 tag instead of 0.0.0"
  - "Promptimprover's caller workflow correctly triggers on push to master (its actual default branch)"
affects: [39-03-release-please-repos-wave-b, phase-42-milestone-audit]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Per-repo release-please-config.json + .release-please-manifest.json + SHA-pinned caller .github/workflows/release-please.yml, identical config content across repos except manifest bootstrap value and branch trigger"
    - "Isolated git worktree per repo, branched off freshly-fetched origin/<default>, for repo tasks that must not touch dirty/parked primary checkouts"

key-files:
  created:
    - portfolio/Promptimprover/release-please-config.json
    - portfolio/Promptimprover/.release-please-manifest.json
    - portfolio/Promptimprover/.github/workflows/release-please.yml
    - portfolio/autogen/release-please-config.json
    - portfolio/autogen/.release-please-manifest.json
    - portfolio/autogen/.github/workflows/release-please.yml
    - portfolio/autopilot-core/release-please-config.json
    - portfolio/autopilot-core/.release-please-manifest.json
    - portfolio/autopilot-core/.github/workflows/release-please.yml
    - portfolio/autopilot-demo/release-please-config.json
    - portfolio/autopilot-demo/.release-please-manifest.json
    - portfolio/autopilot-demo/.github/workflows/release-please.yml
    - portfolio/cas-contracts/release-please-config.json
    - portfolio/cas-contracts/.release-please-manifest.json
    - portfolio/cas-contracts/.github/workflows/release-please.yml
    - portfolio/cas-evals/release-please-config.json
    - portfolio/cas-evals/.release-please-manifest.json
    - portfolio/cas-evals/.github/workflows/release-please.yml
  modified: []

key-decisions:
  - "Used isolated git worktrees (one per repo, branched off freshly-fetched origin/<default>) for all 6 repos, since every primary checkout was dirty and/or parked on an unrelated branch per the plan's preflight_isolation block"
  - "cas-contracts's manifest bootstraps from its real GitHub-confirmed v1.1.1 tag (not 0.0.0), and its existing hand-maintained CHANGELOG.md was left untouched per the interfaces table"
  - "Promptimprover's caller workflow triggers on push to master (its real default branch); the other five trigger on main"
  - "Stacked this plan's SUMMARY.md commit on the existing open root PR #17 (feat/phase-39-release-engineering) rather than opening a new root branch, since that branch was already open and phase-39-scoped"

patterns-established:
  - "Pattern: release-please bootstrap and caller wiring for a repo group is delivered as N independent single-repo PRs from N independent worktrees, never a single cross-repo commit"

requirements-completed: []  # REQ-1.5.3 not fully complete: this plan wires 6 of 12 remaining repos (group A); 39-03 wires the other 6 (group B)

# Metrics
duration: 25min
completed: 2026-07-10
---

# Phase 39 Plan 02: Release Engineering Group A Summary

**Six SHA-pinned release-please caller workflows opened as PRs (Promptimprover, autogen, autopilot-core, autopilot-demo, cas-contracts, cas-evals), each with a repo-correct config/manifest bootstrap, delivered from isolated worktrees without touching any dirty primary checkout.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2/2 complete
- **Files modified:** 18 (3 new files x 6 repos)

## Accomplishments
- Created `release-please-config.json` (release-type `simple`, package `.`, changelog-path `CHANGELOG.md`) identically across all 6 group-A repos.
- Created `.release-please-manifest.json` per repo: `{".": "1.1.1"}` for cas-contracts (its real, GitHub-confirmed latest tag), `{".": "0.0.0"}` for the other five (each confirmed zero-tag on GitHub).
- Created `.github/workflows/release-please.yml` per repo, SHA-pinned to `f288e5e3b67b29a2c08880b76da7b852f4a132d0` (the exact pin recorded in 39-01-SUMMARY.md, verified with no re-derivation), triggering on `push: branches: [master]` for Promptimprover and `push: branches: [main]` for the other five.
- Opened 6 independent PRs (one per repo), each from its own isolated worktree branched off a freshly-fetched `origin/<default>`, leaving all 6 dirty/parked primary checkouts completely untouched (verified before and after via `git status --short` and `git branch --show-current`).
- Left cas-contracts's existing hand-maintained `CHANGELOG.md` untouched, per the plan's interfaces guidance — release-please reads/writes it on its own on first run.

## Task Commits

Each task was committed atomically, in an isolated worktree per repo (branch `ci/release-please-automation` in every case):

**Task 1 (bootstrap config + manifest):**
1. Promptimprover — `7f570e8` — `chore(release): bootstrap release-please config and manifest`
2. autogen — `f9bac2d` — `chore(release): bootstrap release-please config and manifest`
3. autopilot-core — `36ca2bf` — `chore(release): bootstrap release-please config and manifest`
4. autopilot-demo — `29bcea4` — `chore(release): bootstrap release-please config and manifest`
5. cas-contracts — `e334510` — `chore(release): bootstrap release-please config and manifest`
6. cas-evals — `2f77154` — `chore(release): bootstrap release-please config and manifest`

**Task 2 (SHA-pinned caller workflow + PR):**
7. Promptimprover — `2451b64` — `ci(release): wire release-please via org-dotgithub reusable workflow`
8. autogen — `3f3df4b` — `ci(release): wire release-please via org-dotgithub reusable workflow`
9. autopilot-core — `b3e6003` — `ci(release): wire release-please via org-dotgithub reusable workflow`
10. autopilot-demo — `495fb55` — `ci(release): wire release-please via org-dotgithub reusable workflow`
11. cas-contracts — `725d427` — `ci(release): wire release-please via org-dotgithub reusable workflow`
12. cas-evals — `676091b` — `ci(release): wire release-please via org-dotgithub reusable workflow`

**Plan metadata:** committed on the root repo's existing open PR branch `feat/phase-39-release-engineering` (PR #17), via an isolated worktree — the root primary checkout (`docs/phase-38-plan-fixes`) was not touched.

_Note: all 6 repo worktrees were removed after their branch was pushed and the PR opened; every primary checkout was verified byte-for-byte unchanged (same branch, same dirty files) before and after this plan's execution._

## Files Created/Modified
- `portfolio/Promptimprover/release-please-config.json` - release-type simple, package "."
- `portfolio/Promptimprover/.release-please-manifest.json` - bootstrap {".": "0.0.0"}
- `portfolio/Promptimprover/.github/workflows/release-please.yml` - SHA-pinned caller, triggers on push to master
- `portfolio/autogen/release-please-config.json` - release-type simple, package "."
- `portfolio/autogen/.release-please-manifest.json` - bootstrap {".": "0.0.0"}
- `portfolio/autogen/.github/workflows/release-please.yml` - SHA-pinned caller, triggers on push to main
- `portfolio/autopilot-core/release-please-config.json` - release-type simple, package "."
- `portfolio/autopilot-core/.release-please-manifest.json` - bootstrap {".": "0.0.0"}
- `portfolio/autopilot-core/.github/workflows/release-please.yml` - SHA-pinned caller, triggers on push to main
- `portfolio/autopilot-demo/release-please-config.json` - release-type simple, package "."
- `portfolio/autopilot-demo/.release-please-manifest.json` - bootstrap {".": "0.0.0"}
- `portfolio/autopilot-demo/.github/workflows/release-please.yml` - SHA-pinned caller, triggers on push to main
- `portfolio/cas-contracts/release-please-config.json` - release-type simple, package "."
- `portfolio/cas-contracts/.release-please-manifest.json` - bootstrap {".": "1.1.1"} (real existing tag)
- `portfolio/cas-contracts/.github/workflows/release-please.yml` - SHA-pinned caller, triggers on push to main
- `portfolio/cas-evals/release-please-config.json` - release-type simple, package "."
- `portfolio/cas-evals/.release-please-manifest.json` - bootstrap {".": "0.0.0"}
- `portfolio/cas-evals/.github/workflows/release-please.yml` - SHA-pinned caller, triggers on push to main

## Decisions Made
- Isolated worktrees for all 6 repo tasks (see key-decisions in frontmatter) rather than touching any dirty/parked primary checkout.
- Reused the SHA `f288e5e3b67b29a2c08880b76da7b852f4a132d0` verbatim from 39-01-SUMMARY.md without re-deriving it via `git log`, per the plan's explicit instruction (org PR #16 is unmerged but the SHA is valid regardless, since it's a real commit on that branch).
- Stacked this SUMMARY.md commit on the existing open root PR #17 (`feat/phase-39-release-engineering`) instead of opening a new `docs/phase-39-summaries` branch, since an open phase-39-scoped root branch already existed per the output instructions' fallback clause.

## Deviations from Plan

None - plan executed exactly as written. All bootstrap values, branch triggers, and the SHA pin matched the plan's interfaces table and 39-01-SUMMARY.md exactly.

## Issues Encountered
- `git push` from each worktree printed the same benign credential-helper warning already documented in 39-01-SUMMARY.md (`"/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential store: line 1: ... No such file or directory`) — a known MSYS/WSL path-quoting artifact of the verification environment (already tracked as finding class `credential-helper-wsl-path` by `workspace-health.ps1`), not a script or plan bug. All 6 pushes succeeded.

## User Setup Required
None - no external service configuration required. All 6 PRs are informational until a human reviews and merges them (per org convention, this plan does not merge).

## Pull Requests

| Repo | Branch | PR | Bootstrap |
|---|---|---|---|
| `Coding-Autopilot-System/Promptimprover` | `ci/release-please-automation` | https://github.com/Coding-Autopilot-System/Promptimprover/pull/31 | 0.0.0, trigger: master |
| `Coding-Autopilot-System/autogen` | `ci/release-please-automation` | https://github.com/Coding-Autopilot-System/autogen/pull/23 | 0.0.0, trigger: main |
| `Coding-Autopilot-System/autopilot-core` | `ci/release-please-automation` | https://github.com/Coding-Autopilot-System/autopilot-core/pull/21 | 0.0.0, trigger: main |
| `Coding-Autopilot-System/autopilot-demo` | `ci/release-please-automation` | https://github.com/Coding-Autopilot-System/autopilot-demo/pull/12 | 0.0.0, trigger: main |
| `Coding-Autopilot-System/cas-contracts` | `ci/release-please-automation` | https://github.com/Coding-Autopilot-System/cas-contracts/pull/22 | 1.1.1, trigger: main |
| `Coding-Autopilot-System/cas-evals` | `ci/release-please-automation` | https://github.com/Coding-Autopilot-System/cas-evals/pull/13 | 0.0.0, trigger: main |

All 6 PRs are open, unmerged, per the PR-only / never-merge-or-approve convention. No repo's branch protection was bypassed.

## Next Phase Readiness
- 39-03 can now wire the remaining group-B repos (6 of 12) against the same pin SHA `f288e5e3b67b29a2c08880b76da7b852f4a132d0`.
- All 6 group-A PRs need human review/merge before their respective changes take effect; no blockers on this plan's own scope.
- REQ-1.5.3's "every portfolio repo" falsifier remains incomplete until 39-03 also completes and all 12 PRs across both waves (plus 39-01's org-dotgithub dogfood) are merged.

---
*Phase: 39-release-engineering*
*Completed: 2026-07-10*
