---
phase: 02-typed-goal-and-lifecycle-contract
status: ready
---

# Phase 2 Context

## Locked decisions

- `cas-contracts` remains the portable contract owner; runtime orchestration stays outside it.
- Required goal fields are breaking relative to v0.1, so publish them under `schemas/v1.0` and `examples/v1.0`; preserve v0.1 unchanged.
- A v1 `WorkRequest` requires objective, target repositories, measurable success criteria, constraints, risk, approval policy, verification profile, capabilities, bounded budget, and stop policy.
- Default bounded limits are fan-out 3, iterations 3, attempts 3, runtime 1800 seconds, model calls 20, and no-progress 2.
- Every v1 lifecycle record reuses one strict common metadata definition with correlation, prompt, run, repository, actor, UTC timestamp, schema version, and W3C trace context.
- Tests begin with invalid/incomplete goal fixtures and prove rejection before any dispatch integration exists.
- Work only in `C:\PersonalRepo\worktrees\cas-goal-contract` on `codex/goal-contract`; preserve the dirty source checkout.

## Deferred

- Scheduler persistence, leases, worker dispatch, and provider cost accounting belong to later phases.
