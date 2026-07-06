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

## Definition of done

- Sweep green on a healthy tree; correctly red when seeded with a synthetic orphaned file, an unpushed commit, and a lying commit message (test all three).
- Scheduled task registered; CI job wired.
