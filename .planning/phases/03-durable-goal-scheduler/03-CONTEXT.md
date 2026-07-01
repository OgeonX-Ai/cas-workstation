---
phase: 03-durable-goal-scheduler
status: ready
---

# Phase 3 Context

- `gsd-orchestrator` is the sole authoritative goal scheduler.
- Domain records and scheduler policy remain independent of SQLite; `Microsoft.Data.Sqlite` is the local infrastructure adapter.
- One database transaction persists authoritative events and projections.
- Required projections: goals, work items, dependencies, attempts, leases, budget reservations, evidence, transitions, and idempotency keys.
- Lease acquisition must atomically enforce dependency readiness plus global, provider, and repository concurrency limits.
- Expired leases return work to ready state; durable idempotency keys prevent replay of external effects.
- Retry classes are transient, deterministic, policy, cancellation, and unrecoverable. Stop reasons are pass, exhaustion, cancellation, denial, approval wait, deadlock, unrecoverable fault, and no-progress.
- All work remains in `C:\PersonalRepo\worktrees\gsd-loop-stability`; original nested checkout is untouched.
