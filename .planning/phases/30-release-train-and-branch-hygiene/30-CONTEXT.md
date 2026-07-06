# Phase 30: Release Train & Branch Hygiene — Context

**Gathered:** 2026-07-06 (workspace-integrity survey)
**Status:** Ready for planning (`/gsd:plan-phase 30`)
**Backlog refs:** W4, H3 residue

## Verified starting state (2026-07-06)

15 open PRs across the 13 `Coding-Autopilot-System` repos; every sub-repo checkout is parked on an unmerged feature branch:

| Repo | Checked-out branch | Open PRs |
|---|---|---|
| Promptimprover | master (1 ahead; commit also on PR #26 `feat/swarm-dashboard`) | 2 |
| autogen | ci/dependabot-github-actions | 2 |
| autopilot-core | chore/governance-hardening | 1 |
| autopilot-demo | chore/governance-hardening | 1 |
| cas-contracts | fix/pages-release-ordering | 1 |
| cas-evals | chore/governance-hardening | 1 |
| cas-platform | chore/governance-hardening | 0 |
| cas-reference-product | ci/phase-09-workflow-hardening | 1 |
| cas-workstation | chore/governance-hardening | 2 |
| ci-autopilot | chore/governance-hardening | 1 |
| cloud-security-service-model | chore/governance-hardening | 1 |
| gsd-orchestrator | ci/dependabot-github-actions | 2 |
| .github (org-dotgithub) | chore/governance-hardening | 1 |

Note: quick task 260706-h8b (2026-07-06) added commits to the gsd-orchestrator and autogen branches (orphaned test suites) — those ride the existing PRs. Promptimprover's dashboard commit is on PR #26 (`feat/swarm-dashboard`); after merging it, local `master` (1 ahead with the same change) should be reset to `origin/master`.

Also from the 260706-h8b worktree audit: 10 kept worktrees hold **unmerged, unpushed local `codex/*` branches** — decide merge/push/discard for each during this phase; and all 14 worktrees are registered with WSL `/mnt/c/` paths (broken for Windows git) — `git worktree repair` or remove during cleanup. 3 orphaned dirs (`archive-loop-engineering`, `loop-engineering`, `v1.1-sdlc-engine`) have no git backing at all — inspect and delete manually.

## Locked decisions

- Branch protection blocks self-authored admin-merge; use the documented temp-relax `enforce_admins` procedure (see memory/release-process notes): relax → merge → immediately re-enable, per repo.
- Merge order: org-dotgithub (.github) first (shared workflow templates), then dependabot PRs, then governance-hardening, then repo-specific fix branches.
- After each merge: `git switch main && git pull`, delete the merged local branch.
- Deliverable includes a committed `docs/merge-train-runbook.md` so this is repeatable.

## Codex Code Review Blockers (Must address before merge)
- **gsd-orchestrator PR #15**: Fix the 100% coverage gate failure (coverage is 93.7%).
- **autogen PR #10**: Ensure `pytest-cov` is installed before `--cov`, fix DevUI HTML `Content-Length`.
- **autopilot-core PR #14**: Increase `timeout-minutes: 60` and 15-minute installer timeout.
- **Promptimprover PR #26**: Bind dashboard to loopback only, return JSON when trace file is missing, avoid `innerHTML` XSS.
- **cas-contracts PR #15**: Fix the `$id` vs `$ref` canonical URL resolution issue.
- **gsd-orchestrator PR #14**: Fix Linux LF/CRLF manifest hash validation.
- **autogen PR #9**: Fix vendored CAS schema `$id` URLs.
- **cas-reference-product PR #9**: Stop chaining raw provider exceptions (leaks details).

## Definition of done

- `gh pr list` shows 0 open PRs older than 7 days across all 13 repos.
- Every sub-repo checkout on `main` (Promptimprover: `master`), clean, up to date.
- Remaining `worktrees/` entries flagged MANUAL in the 260706-h8b worktrees-audit resolved or ticketed.
