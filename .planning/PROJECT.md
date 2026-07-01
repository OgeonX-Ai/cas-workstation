# CAS Loop Engineering

## What This Is

CAS Loop Engineering turns the PersonalRepo portfolio into one bounded,
evidence-driven engineering system. A developer submits a measurable goal; a
durable control plane plans dependency-aware work, delegates isolated task
attempts to Microsoft Agent Framework workers, verifies results using native
repository gates and CAS Evals, and stops only on proven success or an explicit
bounded stop condition.

## Core Value

A Windows-first developer can trust CAS to pursue repository goals in parallel
without losing control of state, cost, safety, evidence, or completion.

## Developer-Facing Success Metric

A developer can run the four v1 pilot scenarios and receive reproducible,
schema-valid evidence. No goal reaches `Completed` unless every mandatory
verifier and acceptance criterion passes.

## Target Runtime

- Windows 11 and PowerShell under `C:\PersonalRepo`
- .NET 10 `gsd-orchestrator` goal control plane
- Python 3.12 Microsoft Agent Framework workers
- Node.js 22 Promptimprover governance and approved learning
- Foundry Next Gen agent references with system-assigned managed identity in Azure

## Requirements

### Validated

None yet. This milestone begins with stabilization and regression proof.

### Active

- [ ] Stabilize workstation paths, health checks, multi-repo watch, and failed-step recovery.
- [ ] Admit only typed, measurable, bounded engineering goals.
- [ ] Persist goal state, dependencies, attempts, leases, budgets, and evidence durably.
- [ ] Run bounded MAF specialist fan-out/fan-in in isolated workspaces.
- [ ] Make deterministic verification the only completion authority.
- [ ] Expose safe operational state, traces, Foundry identity, and Azure worker boundaries.
- [ ] Publish reproducible evidence for feature, repair, recovery, and policy pilots.

### Out of Scope

- Multi-machine distributed scheduling in v1
- Kubernetes deployment
- Automatic production deployment, merge, or destructive action
- Unbounded retries or autonomous policy overrides
- Replacing GSD, Microsoft Agent Framework, CAS contracts, or CAS Evals
- Azure resource deployment without separate explicit authorization

## Context

The portfolio already contains the necessary building blocks, but ownership is
fragmented. `gsd-orchestrator` has a durable state machine but no goal DAG or
fan-out scheduler. `autogen` has manager-led execution, approvals, validation,
and a worker boundary but its specialist workflow is sequential.
Promptimprover has governance, event history, and learning but must not become a
second executor. CAS Contracts and CAS Evals provide the portable evidence
boundary, while the reference product and platform already establish Foundry
Next Gen, managed identity, and OpenTelemetry patterns.

## Constraints

- Use `C:\Users\KimHarjamaki` whenever a concrete Windows profile is required.
- Use composition, dependency injection, guard clauses, and testable core logic.
- Reproduce every Phase 1 defect with a failing regression test before fixing it.
- Keep one authoritative goal-level event stream and terminal status.
- Treat worker checkpoints and Promptimprover history as projections, not competing run truth.
- Preserve W3C trace context across every lifecycle boundary.
- Never embed secrets, keys, tokens, or raw sensitive prompt/output content.
- Use Foundry Next Gen `WorkflowAgentService`; never use Classic Assistants APIs.
- Use system-assigned managed identity and minimum project-scoped RBAC in Azure.
- Use Flex Consumption Linux for event-driven Azure Functions.
- Keep production MCP remote and secured; local `stdio` remains acceptable.

## Key Decisions

| Decision | Rationale | Status |
|----------|-----------|--------|
| `gsd-orchestrator` owns goal DAGs, leases, budgets, integration, stop rules, and terminal state | Cross-repository work requires one durable completion authority | Locked by ADR-0001 |
| `autogen`/MAF owns one leased task attempt and task-local specialist fan-out/fan-in | Reuses existing agent execution and worker capabilities without duplicating global scheduling | Locked by ADR-0001 |
| Promptimprover owns governance and review-gated learning only | Prompt heuristics and self-heal output are not execution evidence | Locked by ADR-0001 |
| CAS Contracts, CAS Evals, reference product, and platform retain their existing boundaries | Keeps contracts, verification, Foundry adapter, and infrastructure modular | Locked by ADR-0001 |
| Do not add Ray, Prefect, Dagster, Celery, Redis, or another scheduler in v1 | The local MVP does not need a second scheduler or distributed queue | Locked by ADR-0001 |
| Completion requires deterministic verification evidence | Model confidence cannot satisfy machine-verifiable criteria | Locked by ADR-0001 |

## Evolution

After each phase, move verified requirements to Validated, record new decisions,
and update STATE.md with the exact evidence and remaining blockers. Architectural
ownership changes require a superseding ADR.

---
*Initialized: 2026-06-30 via GSD document ingest*

