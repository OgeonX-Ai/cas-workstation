---
phase: 03-durable-goal-scheduler
status: complete
---

# Phase 3 Research

- The .NET Worker currently has no durable goal abstraction or database dependency.
- `Microsoft.Data.Sqlite` provides a narrow embedded adapter and explicit transactions without introducing another scheduler.
- WAL, foreign keys, busy timeout, and transaction-scoped conditional updates are required for reliable local concurrency.
- Scheduler policy should depend on `IGoalStore`; SQL owns atomic lease/concurrency checks while deterministic retry/stop classification remains pure and unit-testable.
- Tests require temporary databases, restart through a new store instance, competing lease calls, expired lease recovery, and idempotency replay checks.
