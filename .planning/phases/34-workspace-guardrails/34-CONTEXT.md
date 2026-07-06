# Phase 34: Workspace Guardrails & Drift Prevention — Context

**Gathered:** 2026-07-06
**Status:** Ready for planning (`/gsd:plan-phase 34`) — depends on Phases 26 and 30
**Backlog refs:** W1/W2 recurrence prevention, H1 follow-through; REQ-1.4.8, REQ-1.4.12, REQ-1.4.13

## Why this phase exists

The 2026-07-06 survey found three silent failure classes that no tooling caught:
1. **Orphaned artifacts** — test suites existed only on disk (untracked in sub-repos, gitignored at root).
2. **Untruthful commits** — root commit b4e0868 claimed "add full coverage suites" but contained only planning docs.
3. **Unbounded drift** — 10 unpushed commits, canonical rules file (GLOBAL_AGENTS.md) untracked, policy files (engineering-os/) modified-uncommitted for days, stale worktrees accumulating.

## Scope

1. **Workspace-health sweep** — extend `doctor.ps1` (or new `scripts/workspace-health.ps1`) to check, across root + all portfolio repos + gemini-nano:
   - dirty working trees / untracked non-ignored files
   - unpushed commits (`origin/<branch>..HEAD` count)
   - checkouts not on the default branch
   - gitlinks without `.gitmodules` entries
   - worktrees older than 14 days
   - Exit non-zero on findings; emit a table. This is REQ-1.4.12's falsifier.
2. **Scheduling** — run the sweep via Windows Task Scheduler daily AND as a job in the root CI workflow (added 260706-h8b).
3. **Commit-integrity check** — a hook/CI step that flags commits whose message claims artifact types (`test:`, `feat:` with named paths) absent from the diff (the b4e0868 class). Start with a heuristic: `test:`-typed commits must touch at least one test-pattern path.
4. **Required checks** — make the root Pester CI a required status check on the root repo.
5. **Sweep extensions** (found 2026-07-06 during first sweep runs):
   - PR-age check per org repo (`gh pr list` age > 7 days → finding) — direct REQ-1.4.9 falsifier.
   - Detect worktrees registered with WSL `/mnt/` paths (already implemented) — add a prevention note to GLOBAL_AGENTS.md: never create worktrees from WSL sessions.
   - `.refiner/blackboard.json` re-dirties continuously at runtime — gitignore it (with a periodic snapshot commit job) or relocate refiner state out of the repo.
   - `git config credential.helper` in some repos points at WSL path `/mnt/c/Program Files/GitHub CLI/gh.exe` (warning on every push; falls back OK) — normalize to the Windows path.
   - Pester tests for `workspace-health.ps1` itself (synthetic red fixtures), and a non-ASCII guard for `.ps1` files (PS 5.1 ANSI parsing hazard, hit live 2026-07-06).
   - `stack.manifest.json` version assertions folded into the sweep or doctor.ps1.
   - Housekeeping review: `antigravity-export/`, `evidence/` dirs at root — classify keep/archive/scratch.

## Definition of done

- Sweep green on a healthy tree; correctly red when seeded with a synthetic orphaned file, an unpushed commit, and a lying commit message (test all three).
- Scheduled task registered; CI job wired.
