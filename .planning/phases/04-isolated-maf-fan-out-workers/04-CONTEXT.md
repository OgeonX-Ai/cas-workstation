---
phase: 04-isolated-maf-fan-out-workers
status: ready
---
# Phase 4 Context

- Use active `maf_starter`, never legacy AutoGen.
- MAF native workflow builder represents fan-out/fan-in; deterministic async harness proves runtime bounds without model calls.
- Required roles are research, architecture, security, and test; default peak concurrency is three.
- All specialists are read-only. One named implementation owner alone may mutate one distinct worktree.
- Push, deploy, delete, messages, and production mutation require deterministic approval.
- Work in `C:\PersonalRepo\worktrees\maf-workers` only.
