# Synthesized Decisions

## ADR-0001: Loop Engineering Ownership Boundaries

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/adr/ADR-0001-loop-engineering-ownership.md
- status: locked
- scope: goal orchestration, task execution, verification, learning, lifecycle contracts, Foundry integration, Azure hosting, and production MCP
- decision:
  1. `gsd-orchestrator` is the authoritative goal-level control plane. It owns goals, work-item DAGs, leases, global budgets, retry classification, integration, stop decisions, and terminal state.
  2. `autogen` and Microsoft Agent Framework are the task-execution plane. A worker may fan out specialists and checkpoint one leased task attempt, but cannot declare the parent goal complete or independently consume global retries.
  3. `Promptimprover` owns prompt and goal governance plus review-gated learning. It does not execute repository changes and is not an authoritative run store.
  4. `cas-contracts` owns portable lifecycle records; `cas-evals` owns deterministic evaluation; `cas-reference-product` owns the reference Foundry Next Gen adapter; and `cas-platform` owns Azure infrastructure.
  5. One goal has one authoritative control-plane event stream. Worker checkpoints and Promptimprover learning records are projections, not competing sources of run truth.
  6. Local MCP may use `stdio`. Production MCP uses remote HTTP/SSE, OAuth 2.1 with PKCE or Azure managed identity, protocol-native tracing, and isolated execution.
  7. Azure reasoning uses Foundry Next Gen Agents through `WorkflowAgentService`; Classic Assistants APIs are prohibited.
  8. Azure workloads use system-assigned managed identities and least-privilege RBAC. Secrets, keys, and tokens are never embedded in code or prompts.
- consequences:
  - Extend the current CAS portfolio instead of introducing Ray, Prefect, Dagster, Celery, Redis, or another orchestration framework in the first milestone.
  - Generalize `gsd-orchestrator` beyond a single mutable issue workflow.
  - Add bounded fan-out/fan-in behind a worker contract to the existing MAF sequential chains.
  - Constrain Promptimprover execution/retry behavior to learning-only concerns.
  - Require deterministic verification evidence before completion.

