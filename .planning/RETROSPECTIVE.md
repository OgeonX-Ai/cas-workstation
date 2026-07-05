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

## Milestone: v1.1 — Portfolio Hardening

**Shipped:** 2026-07-05

**Phases:** 4 | **Plans:** 8

### What Was Built

- Portfolio-wide workflow hardening and managed action update policy.
- Deterministic contract publication with immutable release and stable-line URLs.
- Live consumer drift gates for Autogen and GSD Orchestrator.
- Evidence-led robustness and infrastructure closure with cross-repository UAT.

### What Worked

- Independent review caught contract identity, telemetry leakage, digest portability, and timeout recovery issues before merge.
- Atomic repository ownership and default-branch CI kept cross-repo changes reviewable.
- Immutable release correction preserved evidence instead of rewriting history.

### What Was Inefficient

- Approval-only branch protection required a reversible administrative merge procedure for a single-maintainer organization.
- GitHub Pages deployment ordering required a corrective post-tag commit and transient retries.
- Initial summaries lacked frontmatter, reducing automatic milestone extraction quality.

### Patterns Established

- Separate schema identity from distribution location.
- Treat published tags as immutable; issue corrective patch releases.
- Verify live distribution and consumers after merge, not only local artifacts.
- Preserve security boundaries even when diagnostic exception chaining appears useful.

### Key Lessons

1. Release workflows need an explicit tag-to-Pages ordering contract.
2. Cross-platform digest checks must define canonical bytes.
3. Review findings must be adjudicated against security and public-contract invariants.

### Cost Observations

- Subscription/model telemetry was not captured consistently.
- Lower-tier parallel workers were effective for bounded fixes; parent adjudication remained necessary for contract and telemetry decisions.

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Phases | Plans | Key Change |
|-----------|--------|-------|------------|
| v1.0 | 8 | 22 | Established bounded cross-repository loop engineering and clean delivery branches |
| v1.1 | 4 | 8 | Added portfolio hardening, immutable release correction, and live consumer gates |

### Cumulative Quality

| Milestone | Requirements | Phase Verifications | Milestone Audit |
|-----------|--------------|---------------------|-----------------|
| v1.0 | 28/28 | 8/8 passed | Passed |
| v1.1 | 12/12 | 4/4 passed | Passed |

### Top Lessons (Verified Across Milestones)

1. Preserve user work through isolated worktrees and clean integration branches.
2. Use deterministic evidence and default-branch CI as terminal delivery gates.
