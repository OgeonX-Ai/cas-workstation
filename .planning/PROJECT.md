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

## Current State

**v1.1 Portfolio Hardening shipped 2026-07-05.** The workstation, contracts,
durable scheduler, bounded MAF fan-out, deterministic verification, operator
telemetry, identity-first Azure boundary, and four executable pilot scenarios
are implemented and verified across their owning repositories. Portfolio
workflows are bounded and least-privilege, contract release v1.1.1 preserves
canonical schema identity, and live consumer drift gates pass on merged `main`.

Across v1.0 and v1.1, 12 phases are complete. The next milestone establishes a
shared cross-tool engineering operating contract without paid API dependency.

## Current Milestone: v1.2 Shared AI Engineering OS

**Goal:** Combine GSD lifecycle management with proportionate loop-engineering
SDLC controls, model-role tiering, safe delegation, and cross-tool verification.

**Target features:** canonical policy, quick/standard/critical SDLC profiles,
tool compatibility matrix, deterministic routing, safe fan-out, role-based model
tiering, optional benchmark-gated Ollama classification, and fresh-session pilots.

## Target Runtime

- Windows 11 and PowerShell under `C:\PersonalRepo`
- .NET 10 `gsd-orchestrator` goal control plane
- Python 3.12 Microsoft Agent Framework workers
- Node.js 22 Promptimprover governance and approved learning
- Foundry Next Gen agent references with system-assigned managed identity in Azure

## Requirements

### Validated

- ✓ Stable Windows workstation paths, health checks, multi-repository watch, and failed-step recovery — v1.0
- ✓ Typed, measurable, bounded goal admission and lifecycle contracts — v1.0
- ✓ Durable dependency-aware scheduling, leases, budgets, retries, and stop rules — v1.0
- ✓ Bounded MAF specialist fan-out/fan-in with isolated mutation ownership — v1.0
- ✓ Deterministic evidence-gated verification, bounded repair, and approved learning — v1.0
- ✓ Operator state, correlated telemetry, Foundry Next Gen identity, and Flex Consumption boundaries — v1.0
- ✓ Reproducible feature, repair, restart, and policy pilot evidence — v1.0

Additional validated outcomes from v1.1:

- Bounded least-privilege portfolio workflows.
- Canonical contract identity with immutable v1.1.1 publication and live consumer drift gates.
- Evidence-led robustness closure and cross-repository UAT.

### Active

- Shared AI Engineering OS requirements and implementation

### Out of Scope

- Multi-machine distributed scheduling in v1
- Kubernetes deployment
- Automatic production deployment, merge, or destructive action
- Unbounded retries or autonomous policy overrides
- Replacing GSD, Microsoft Agent Framework, CAS contracts, or CAS Evals
- Azure resource deployment without separate explicit authorization

## Context

The portfolio now has explicit ownership boundaries and an executable local
coordination loop. `gsd-orchestrator` owns authoritative goal state and durable
scheduling; `autogen` owns bounded task-attempt execution; Promptimprover owns
governance and review-gated learning; CAS Contracts owns portable schemas; and
the reference product demonstrates identity-first ingress, telemetry, and
Foundry Next Gen boundaries. Remaining scale and delivery work is deferred
until a new milestone establishes measurable demand.

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
| `gsd-orchestrator` owns goal DAGs, leases, budgets, integration, stop rules, and terminal state | Cross-repository work requires one durable completion authority | ✓ Validated in v1.0 |
| `autogen`/MAF owns one leased task attempt and task-local specialist fan-out/fan-in | Reuses existing agent execution and worker capabilities without duplicating global scheduling | ✓ Validated in v1.0 |
| Promptimprover owns governance and review-gated learning only | Prompt heuristics and self-heal output are not execution evidence | ✓ Validated in v1.0 |
| CAS Contracts, CAS Evals, reference product, and platform retain their existing boundaries | Keeps contracts, verification, Foundry adapter, and infrastructure modular | ✓ Validated in v1.0 |
| Do not add Ray, Prefect, Dagster, Celery, Redis, or another scheduler in v1 | The local MVP does not need a second scheduler or distributed queue | ✓ Validated in v1.0 |
| Completion requires deterministic verification evidence | Model confidence cannot satisfy machine-verifiable criteria | ✓ Validated in v1.0 |

## Evolution

After each phase, move verified requirements to Validated, record new decisions,
and update STATE.md with the exact evidence and remaining blockers. Architectural
ownership changes require a superseding ADR.

---
*Last updated: 2026-07-05 after v1.1 Portfolio Hardening*
