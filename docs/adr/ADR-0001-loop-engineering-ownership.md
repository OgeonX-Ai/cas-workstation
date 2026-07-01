# ADR-0001: Loop Engineering Ownership Boundaries

**Status:** Accepted  
**Date:** 2026-06-30

## Context

CAS already contains durable workflow, agent-runtime, prompt-governance,
evaluation, Foundry, and Azure platform capabilities. Adding Ray, Prefect,
Dagster, Celery, or another scheduler for the first loop-engineering milestone
would duplicate state ownership and make retries, budgets, and completion
authority ambiguous.

The system needs one authoritative goal-level control plane and explicit
boundaries for task execution, verification, learning, contracts, and hosting.

## Decision

1. `gsd-orchestrator` is the authoritative goal-level control plane. It owns
   goals, work-item DAGs, leases, global budgets, retry classification,
   integration, stop decisions, and terminal state.
2. `autogen` and Microsoft Agent Framework are the task-execution plane. A
   worker may fan out specialists and checkpoint one leased task attempt, but
   it cannot declare the parent goal complete or independently consume global
   retries.
3. `Promptimprover` owns prompt/goal governance and review-gated learning. It
   does not execute repository changes and is not an authoritative run store.
4. `cas-contracts` owns portable lifecycle records. `cas-evals` owns
   deterministic evaluation. `cas-reference-product` owns the reference
   Foundry Next Gen adapter. `cas-platform` owns Azure infrastructure.
5. One goal has one authoritative event stream in the control plane. Worker
   checkpoints and Promptimprover learning records are projections with clear
   lifecycle boundaries, not competing sources of run truth.
6. Local MCP may use `stdio`. Production MCP endpoints use remote HTTP/SSE,
   OAuth 2.1 with PKCE or Azure managed identity, protocol-native tracing, and
   isolated execution.
7. Azure reasoning uses Foundry Next Gen Agents through
   `WorkflowAgentService`. Classic Assistants APIs are prohibited.
8. Azure workloads use system-assigned managed identities and least-privilege
   RBAC. No application secret, key, or token is embedded in code or prompts.

## Consequences

- The first milestone extends existing code rather than introducing a new
  orchestration framework.
- `gsd-orchestrator` must be generalized beyond one mutable issue workflow.
- Existing MAF sequential chains must gain bounded fan-out/fan-in behind a
  worker contract.
- Existing execution/retry overlap in Promptimprover becomes learning-only.
- Completion is impossible without deterministic verification evidence.

## Rejected Alternatives

- Add Ray, Prefect, Dagster, Celery, or Redis immediately: rejected because the
  local MVP does not require a second scheduler or distributed queue.
- Make Promptimprover the executor: rejected because prompt quality heuristics
  are not execution evidence.
- Let every repository own its own terminal run status: rejected because
  cross-repository goals require one completion authority.

