# Phase 42 Pre-Verification Blocker #1: release-please Reusable Workflow Pin Fix

## Root cause

`.github/workflows/release-please.yml` in all 13 `Coding-Autopilot-System`
repos pinned the reusable workflow call to
`f288e5e3b67b29a2c08880b76da7b852f4a132d0` — the tip commit of the source
branch for `.github` PR #16. When PR #16 squash-merged, the source branch
was deleted and that commit became unreachable (it was never part of
`main`'s history). Every push-triggered `release-please` run since has
failed with "workflow was not found".

## Verified replacement SHA

`64c1673088ff7802f1270a44f03bc4d7a10631f2`

Verification performed:

- `gh api repos/Coding-Autopilot-System/.github/commits/64c1673088ff7802f1270a44f03bc4d7a10631f2 --jq .sha` -> resolves to itself
- `gh api repos/Coding-Autopilot-System/.github/compare/main...64c1673088ff7802f1270a44f03bc4d7a10631f2 --jq .status` -> `identical` (this SHA **is** `.github`'s current `main` HEAD, so no newer SHA needed to be preferred)
- `gh api repos/Coding-Autopilot-System/.github/contents/.github/workflows/release-please-reusable.yml?ref=64c1673088ff7802f1270a44f03bc4d7a10631f2` -> file exists (blob `552f080c3babc9a043afc3d830c08f969f0852a3`)
- Confirmed old SHA `f288e5e3b67b29a2c08880b76da7b852f4a132d0` is not on `.github`'s `main` (branch-tip orphan from the squashed/deleted PR #16 branch)

## Method

For each of the 13 repos: isolated `git worktree` from a freshly-fetched
`origin/<default>` (`Promptimprover` uses `master`; all others use `main`),
branch `ci/fix-release-please-pin`, replaced the dead SHA with the verified
one in `.github/workflows/release-please.yml`, pushed, opened a PR. No `# vX`
version comment existed next to the pin in any repo, so none needed
preserving. Primary checkouts under `portfolio/*` were left untouched;
worktrees were removed after pushing.

All 13 fix PRs are workflow-file changes and therefore out-of-class for
auto-merge by design — each PR body notes "operator merge required."

## PRs opened (13/13)

| # | Repo | PR |
|---|------|----|
| 1 | gsd-orchestrator | https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/25 |
| 2 | Promptimprover | https://github.com/Coding-Autopilot-System/Promptimprover/pull/32 |
| 3 | autogen | https://github.com/Coding-Autopilot-System/autogen/pull/24 |
| 4 | cas-reference-product | https://github.com/Coding-Autopilot-System/cas-reference-product/pull/17 |
| 5 | cloud-security-service-model | https://github.com/Coding-Autopilot-System/cloud-security-service-model/pull/18 |
| 6 | cas-evals | https://github.com/Coding-Autopilot-System/cas-evals/pull/14 |
| 7 | cas-contracts | https://github.com/Coding-Autopilot-System/cas-contracts/pull/23 |
| 8 | cas-platform | https://github.com/Coding-Autopilot-System/cas-platform/pull/16 |
| 9 | autopilot-core | https://github.com/Coding-Autopilot-System/autopilot-core/pull/22 |
| 10 | autopilot-demo | https://github.com/Coding-Autopilot-System/autopilot-demo/pull/13 |
| 11 | ci-autopilot | https://github.com/Coding-Autopilot-System/ci-autopilot/pull/2274 |
| 12 | cas-workstation (org) | https://github.com/Coding-Autopilot-System/cas-workstation/pull/23 |
| 13 | org-dotgithub (`.github`, self-caller) | https://github.com/Coding-Autopilot-System/.github/pull/19 |

All 13 branches (`ci/fix-release-please-pin`) pushed and PRs opened
successfully. None require merge/approve action from this agent per rules.

## Pin-rule learning doc (root repo) — BLOCKED, stop item

Task step 4 asked to record the pin rule in the root repo
(`C:\PersonalRepo`) on a `docs/pin-rule-learning` branch. This repo's
`docs/merge-flow-policy.md` is not reachable on `master` (it only exists on
the unmerged `feat/phase-38-merge-flow` branch), so per the task's fallback
instruction the learning was appended to `docs/merge-train-runbook.md`
instead, under a new "Reusable workflow pin rule" section.

The commit was made and the branch **was pushed successfully** to
`origin` (`https://github.com/OgeonX-Ai/cas-workstation.git`,
branch `docs/pin-rule-learning`, commit `bac1d95`). Opening the PR was
**denied by the Claude Code auto-mode permission classifier**:

> [Create Public Surface] The PR targets `OgeonX-Ai/cas-workstation`, an
> external org the user never named — the task's root-repo PR was for
> C:/PersonalRepo, not this unverified destination.

Per the task rules ("denial → stop item, record"), no workaround was
attempted (e.g. via `gh api` directly). The branch and commit exist and are
ready — a PR can be opened manually, or re-attempted after the user
confirms `OgeonX-Ai/cas-workstation` is the correct/expected destination
for this repo's PRs (it is the `origin` remote configured in the existing
checkout, but was not a named destination in the task).

**Action needed from user:** confirm whether
`https://github.com/OgeonX-Ai/cas-workstation` is the intended PR
destination for `C:\PersonalRepo`, then either open the PR manually from
branch `docs/pin-rule-learning` (commit `bac1d95`) or grant permission to
retry.

## Cleanup

- Stray debris file `C:\PersonalRepo\resolves` (accidentally created by an
  early shell-quoting misfire while drafting a PR body with backticks) was
  detected and deleted before it could be committed anywhere.
- All scratch `git worktree`s used for the 13 repo fixes and the root-repo
  doc change were removed after pushing; primary checkouts under
  `portfolio/*` and `C:\PersonalRepo` itself were never modified directly.

## Denials / stop items

1. `gh pr create --repo OgeonX-Ai/cas-workstation ...` — denied by auto-mode
   classifier as an unverified/unnamed public-surface destination. See
   "Pin-rule learning doc" section above. Branch pushed, PR not opened.
