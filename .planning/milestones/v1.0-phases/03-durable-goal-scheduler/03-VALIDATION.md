---
phase: 3
nyquist_compliant: true
wave_0_complete: true
---

# Phase 3 Validation

| Gate | Command | Expected |
|---|---|---|
| Persistence | filtered `SqliteGoalStore` tests | Restart equivalence for every projection |
| Leasing | filtered `GoalScheduler` tests | Dependencies and three concurrency limits enforced atomically |
| Recovery | filtered lease/idempotency tests | Expiry recovers; duplicate side effect denied |
| Full | Release build and full xUnit | Zero failures |

Any missing projection, nondeterministic result, timeout, or skipped mandatory test blocks completion.
