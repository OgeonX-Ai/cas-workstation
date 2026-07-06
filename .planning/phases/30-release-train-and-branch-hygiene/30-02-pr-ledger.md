# Phase 30 Wave 2 — PR Creation Ledger

Scope: create PRs for the 12 parked local branches identified in `30-LIVE-STATE.md`
(all repos except Promptimprover, whose content is already covered by PR #26).
This is PR-CREATION ONLY — no merges, no approvals, no branch-protection changes
were performed, per session policy (merging is blocked).

Captured: 2026-07-06

## Pre-flight finding: stale remote-tracking refs

Local `git rev-list --count <branch>@{u}..<branch>` reported `0` (fully pushed) for
all 12 branches, but `git ls-remote origin` proved that **10 of the 12 branches did
not actually exist on `origin`** — the local `origin/<branch>` remote-tracking refs
were stale leftovers from a prior session. Confirmed via `gh api repos/.../branches/<name>`
returning `404 Branch not found` for `cas-reference-product` and `cas-contracts` before
push. Each affected branch was pushed with `git push -u origin <branch>` before PR
creation. Only `gsd-orchestrator` and `autogen`'s `ci/dependabot-github-actions`
branches were genuinely already present on origin.

## PR Ledger

| # | Repo | Branch | PR | Status | Notes |
|---|------|--------|----|--------|-------|
| 1 | gsd-orchestrator | `ci/dependabot-github-actions` | [gsd-orchestrator#15](https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/15) | Created (OPEN) | Already pushed. Touches `.github/workflows/ci.yml` — overlaps dependabot PR #13. Body instructs: merge #13 first, then `gh pr update-branch` this PR, keep both changes. |
| 2 | autogen | `ci/dependabot-github-actions` | [autogen#10](https://github.com/Coding-Autopilot-System/autogen/pull/10) | Created (OPEN) | Already pushed. Touches `.github/workflows/ci.yml` — overlaps dependabot PR #8. Body instructs: merge #8 first, then `gh pr update-branch` this PR, keep both changes. |
| 3 | cas-reference-product | `ci/phase-09-workflow-hardening` | [cas-reference-product#10](https://github.com/Coding-Autopilot-System/cas-reference-product/pull/10) | Created (OPEN) | Branch was NOT on origin — pushed via `git push -u origin ci/phase-09-workflow-hardening` before PR creation. |
| 4 | cas-contracts | `fix/pages-release-ordering` | [cas-contracts#17](https://github.com/Coding-Autopilot-System/cas-contracts/pull/17) | Created (OPEN) | Branch was NOT on origin — pushed via `git push -u origin fix/pages-release-ordering` before PR creation. |
| 5 | autopilot-core | `chore/governance-hardening` | [autopilot-core#14](https://github.com/Coding-Autopilot-System/autopilot-core/pull/14) | Created (OPEN) | Branch was NOT on origin — pushed before PR creation. |
| 6 | autopilot-demo | `chore/governance-hardening` | [autopilot-demo#8](https://github.com/Coding-Autopilot-System/autopilot-demo/pull/8) | Created (OPEN) | Branch was NOT on origin — pushed before PR creation. |
| 7 | cas-evals | `chore/governance-hardening` | [cas-evals#8](https://github.com/Coding-Autopilot-System/cas-evals/pull/8) | Created (OPEN) | Branch was NOT on origin — pushed before PR creation. |
| 8 | cas-platform | `chore/governance-hardening` | [cas-platform#10](https://github.com/Coding-Autopilot-System/cas-platform/pull/10) | Created (OPEN) | Branch was NOT on origin — pushed before PR creation. |
| 9 | cas-workstation | `chore/governance-hardening` | [cas-workstation#17](https://github.com/Coding-Autopilot-System/cas-workstation/pull/17) | Created (OPEN) | Branch was NOT on origin — pushed before PR creation. Targeted `Coding-Autopilot-System/cas-workstation` explicitly (not the root `OgeonX-Ai/cas-workstation`). |
| 10 | ci-autopilot | `chore/governance-hardening` | [ci-autopilot#2222](https://github.com/Coding-Autopilot-System/ci-autopilot/pull/2222) | Created (OPEN) | Branch was NOT on origin — pushed before PR creation. |
| 11 | cloud-security-service-model | `chore/governance-hardening` | [cloud-security-service-model#12](https://github.com/Coding-Autopilot-System/cloud-security-service-model/pull/12) | Created (OPEN) | Branch was NOT on origin — pushed before PR creation. |
| 12 | org-dotgithub | `chore/governance-hardening` | [.github#12](https://github.com/Coding-Autopilot-System/.github/pull/12) | Created (OPEN) | Local folder `org-dotgithub` maps to GitHub repo `Coding-Autopilot-System/.github` (confirmed via `gh repo view`). Branch was NOT on origin — pushed before PR creation. |

**Result: 12/12 created, 0 blocked.**

## Excluded

- **Promptimprover** (`master`, local) — content already covered by open PR
  [Promptimprover#26](https://github.com/Coding-Autopilot-System/Promptimprover/pull/26)
  (`feat/swarm-dashboard`). Per instructions, no additional PR opened for this repo.

## Actions explicitly NOT taken (per session policy)

- No `gh pr merge` was run on any PR.
- No `gh pr update-branch` was run (deferred to the merge stage per each PR body's notes).
- No branch protection / `enforce_admins` API calls were made.
- No approvals or reviews were issued.

## PR title/body derivation

Each PR title was derived from `git log origin/main..<branch> --oneline` (actual
commit subjects on the branch) and each body summarizes `git diff origin/main...<branch> --stat`
(actual file-level diff), plus a note that the PR is part of the Phase 30 release
train. The two dependabot-overlap repos (gsd-orchestrator, autogen) additionally note
the required merge-order and ci.yml conflict-resolution rule from `30-LIVE-STATE.md`.
All bodies end with the Claude Code attribution footer.
