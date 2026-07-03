# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 — Loop Engineering

**Shipped:** 2026-07-01

**Phases:** 8 | **Plans:** 22 | **Tasks:** 37

### What Was Built

- A Windows-first workstation contract with reliable health, watch, and resume behavior.
- Typed goal and lifecycle contracts backed by durable dependency-aware scheduling.
- Bounded MAF specialist fan-out with isolated, single-owner mutation workspaces.
- Evidence-gated verification, bounded repair, approval-gated learning, and operator telemetry.
- Identity-first Foundry Next Gen and Flex Consumption boundaries plus four executable pilot scenarios.

### What Worked

- Repository ownership remained explicit, preventing competing sources of execution truth.
- Isolated worktrees preserved substantial unrelated changes in the original checkouts.
- Deterministic contracts, native tests, generated pilot evidence, and post-merge CI provided layered verification.

### What Was Inefficient

- Cross-repository delivery required separate clean PR branches because several original development branches contained unrelated history.
- Early milestone summaries were inconsistent, which caused automatic task and accomplishment extraction to undercount later phases.

### Patterns Established

- Keep `gsd-orchestrator` authoritative for goal state while MAF owns bounded task execution.
- Require one mutation owner per isolated worktree and keep specialists read-only by default.
- Treat terminal verification evidence, not model confidence, as the only completion authority.
- Integrate contracts before workers, workers before orchestration, and workstation evidence last.

### Key Lessons

1. Create clean delivery branches from the remote default branch before publishing cross-repository work.
2. Keep summary frontmatter complete so milestone automation can calculate accurate accomplishments and task counts.
3. Validate both PR checks and post-merge default-branch workflows before declaring delivery complete.

### Cost Observations

- Model mix and session token accounting were not captured consistently in v1.0.
- The dominant coordination cost was repository isolation and cross-repository CI convergence.

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 8 | 22 | Established bounded cross-repository loop engineering and clean delivery branches |

### Cumulative Quality

| Milestone | Requirements | Phase Verifications | Milestone Audit |
|-----------|--------------|---------------------|-----------------|
| v1.0 | 28/28 | 8/8 passed | Passed |

### Top Lessons (Verified Across Milestones)

1. Preserve user work through isolated worktrees and clean integration branches.
2. Use deterministic evidence and default-branch CI as terminal delivery gates.
