# Phase 23: Multi-Machine Orchestration Core - Context

## Objective
Implement distributed scheduling architecture across nodes to satisfy SCALE-01. Currently, scheduling is bounded by single-machine SQLite (`SqliteGoalStore.cs`) and memory limits. This phase will extend `gsd-orchestrator` to support multi-node scheduling.

## Context Gathered
- **Current Scheduling Path**: Handled in `portfolio/gsd-orchestrator` (specifically `GoalScheduler.cs`, `SqliteGoalStore.cs`, and `GoalControlPlane.cs`).
- **Single-Machine Bounds**:
  - `SqliteGoalStore.cs` provides persistent storage but runs only locally (SQLite is not suited for highly concurrent cross-node access).
  - Leases (`LeaseRecord`, `TryAcquireLeaseAsync`) use `Owner` string but there is no mechanism for nodes to register themselves or for external nodes to discover work.
  - Concurrency is bounded by local settings (`GlobalLimit`, `ProviderLimit`, `RepositoryLimit`), and leases are pulled directly by the single `GoalScheduler`.

## Decisions (Auto-Selected defaults)
1. **Shared State / Storage**: Abstract the storage layer further to support a centralized database (e.g., PostgreSQL or Redis) for the `IGoalStore` backend, allowing multiple nodes to read/write without file locks.
2. **Node Registry**: Introduce a `NodeRegistry` or heartbeat mechanism to keep track of active worker nodes and gracefully handle node failures.
3. **Queue / Execution Mechanism**: Implement a pull-based shared queue where worker nodes poll `IGoalStore` for `WorkItemStatus.Ready` items and acquire leases using their unique Node ID.
4. **Leasing Updates**: Ensure `TryAcquireLeaseAsync` is transaction-safe across nodes to avoid race conditions when multiple nodes compete for the same work item.

## Execution Guidance
- Create a new DB provider for `IGoalStore` or introduce an RPC/messaging layer over SQLite.
- Update `GoalScheduler` to accept a `NodeId` from configuration to identify itself as the `Owner` when acquiring leases.
