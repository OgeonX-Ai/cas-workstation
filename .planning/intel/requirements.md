# Synthesized Requirements

## Workstation Stability

### REQ-STAB-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: The workstation uses `C:\PersonalRepo` as its root and `C:\Users\KimHarjamaki` as the concrete Windows profile.
- acceptance criteria:
  - Runtime and configuration checks resolve the workstation root to `C:\PersonalRepo`.
  - Tools requiring a concrete Windows profile resolve it to `C:\Users\KimHarjamaki`.
- scope: workstation configuration

### REQ-STAB-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: `doctor.ps1` verifies the exact installed Promptimprover entry point and all required loop-engineering component repositories.
- acceptance criteria:
  - The doctor report validates the installed Promptimprover executable or script path actually used by clients.
  - The doctor report checks every repository required by the loop-engineering architecture.
- scope: workstation health checks

### REQ-STAB-03

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Multi-repository watch processes every configured repository in one polling interval and persists deduplication state.
- acceptance criteria:
  - One polling interval reaches every configured repository.
  - Deduplication state survives process restart.
  - Failed work is not permanently marked processed.
- scope: multi-repository watch

### REQ-STAB-04

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: A failed workflow resumes the failed step rather than resuming a terminal `Failed` checkpoint.
- acceptance criteria:
  - A regression test reproduces the current failed-checkpoint behavior.
  - Resume re-enters the failed step with its required inputs while retaining prior evidence.
- scope: workflow recovery

## Goal Contract

### REQ-GOAL-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: No run starts without a complete, measurable, bounded goal contract.
- acceptance criteria:
  - The contract contains an objective, target repositories, machine-verifiable success criteria, constraints, risk classification, approval policy, and bounded budget.
  - Missing required fields prevent dispatch.
- scope: goal admission

### REQ-GOAL-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Every lifecycle record contains the required correlation and provenance fields.
- acceptance criteria:
  - Every record carries one `correlationId`, `promptId`, `runId`, schema version, repository identity, actor, timestamp, and W3C trace context.
  - Schema validation rejects incomplete records.
- scope: lifecycle contracts

### REQ-GOAL-03

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: MVP execution limits are configurable and bounded.
- acceptance criteria:
  - Defaults are maximum fan-out 3, loop iterations 3, attempts per work item 3, runtime 30 minutes, model calls 20, and no-progress limit 2 identical verifier failure signatures.
  - Each default can be overridden through a validated goal contract within policy limits.
- scope: operational budgets

## Durable Scheduling

### REQ-SCHED-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: The control plane durably persists all state needed to recover and audit a goal.
- acceptance criteria:
  - Persisted data covers goals, work items, dependencies, attempts, leases, budgets, evidence references, and state transitions.
  - Restart reconstructs an equivalent authoritative state from persisted records.
- scope: control-plane persistence

### REQ-SCHED-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Leasing respects dependency readiness and atomic concurrency limits.
- acceptance criteria:
  - Work with incomplete dependencies cannot be leased.
  - Global, provider, and repository limits are checked and reserved atomically.
- scope: scheduling and concurrency

### REQ-SCHED-03

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Restart reconciliation reclaims expired leases without duplicating side effects.
- acceptance criteria:
  - Expired leases become eligible for bounded recovery.
  - Persisted idempotency records prevent duplicate commits, comments, pull requests, or external actions.
- scope: lease recovery and idempotency

### REQ-SCHED-04

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Retry policy classifies failures before deciding whether and how to retry.
- acceptance criteria:
  - Policy distinguishes transient failures, deterministic verification failures, policy denials, cancellations, and unrecoverable faults.
  - Retry behavior and consumed budget are recorded for every retry decision.
- scope: retry classification

### REQ-SCHED-05

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Terminal and waiting outcomes use explicit stop reasons.
- acceptance criteria:
  - Supported reasons include verifier pass, budget exhausted, cancellation, policy denial, approval wait, dependency deadlock, unrecoverable fault, and repeated no progress.
  - Goal status exposes the reason and supporting evidence.
- scope: terminal state

## Isolated Agent Execution

### REQ-WORK-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Every mutating work item executes in an isolated, bounded workspace.
- acceptance criteria:
  - Each mutating item has a distinct Git worktree or ephemeral sandbox, idempotency key, deadline, path allowlist, and captured artifact manifest.
  - The default branch remains unchanged before the approved integration boundary.
- scope: worker isolation

### REQ-WORK-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: MAF supports bounded specialist fan-out and typed fan-in.
- acceptance criteria:
  - At least three independent specialists can execute concurrently.
  - The typed aggregator waits until all required branches are terminal.
- scope: MAF task execution

### REQ-WORK-03

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Repository mutation has exactly one implementation owner per worktree.
- acceptance criteria:
  - Research, architecture, security, testing, and review specialists are read-only.
  - Concurrent specialists cannot mutate the same repository workspace.
- scope: write ownership

### REQ-WORK-04

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Externally visible or destructive actions require deterministic policy approval.
- acceptance criteria:
  - Push, deployment, deletion, messages, and production mutation cannot execute before the required approval is recorded.
  - Model-requested approval cannot override deterministic policy.
- scope: external side effects

## Verification and Learning

### REQ-VER-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Each repository declares native verification commands, and missing required checks are inconclusive.
- acceptance criteria:
  - Profiles declare applicable build, test, lint, security, and evaluation commands.
  - A missing required check yields `inconclusive`, never `passed`.
- scope: verification profiles

### REQ-VER-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Mandatory check failures block completion and can create only bounded repair work.
- acceptance criteria:
  - Any failed mandatory check prevents `Completed`.
  - A repair item is created only when policy and remaining budget allow it.
- scope: verifier loop

### REQ-VER-03

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Verification and evaluation outputs are schema-valid and evidence-backed.
- acceptance criteria:
  - The system emits valid `ArtifactManifest`, `VerificationResult`, and `EvaluationResult` records.
  - Each emitted result links to evidence through evidence URIs.
- scope: evidence contracts

### REQ-VER-04

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Promptimprover learning is terminal, deduplicated, candidate-based, and approval-gated.
- acceptance criteria:
  - Terminal output is recorded once.
  - Failures create candidate lessons rather than automatically active lessons.
  - A lesson is injected only after explicit approval.
- scope: learning governance

## Operations and Cloud

### REQ-OPS-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Operators can inspect the complete operational state of a goal.
- acceptance criteria:
  - Inspection exposes goal state, task DAG, active leases, attempts, budget consumption, verifier evidence, and stop reason.
- scope: operator visibility

### REQ-OPS-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: OpenTelemetry correlates all runtime boundaries without capturing content by default.
- acceptance criteria:
  - Spans and metrics correlate control-plane, worker, tool, verifier, and Foundry boundaries.
  - Raw prompt and output content is excluded by default.
- scope: observability

### REQ-CLOUD-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Azure reasoning uses Foundry Next Gen agent references and managed identity.
- acceptance criteria:
  - Runtime calls use Next Gen `agent_reference` through the approved Foundry interface.
  - Authentication uses a system-assigned managed identity with minimum project-scoped RBAC.
- scope: Foundry integration

### REQ-CLOUD-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: Event-driven Functions use Flex Consumption Linux and delegate long-running or sandboxed execution.
- acceptance criteria:
  - Azure Functions are deployed on Flex Consumption Linux.
  - Long-running or sandboxed work crosses an explicit isolated-worker boundary.
- scope: Azure hosting

## Pilot Evidence

### REQ-PILOT-01

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: A feature pilot proves parallel analysis, isolated implementation, deterministic verification, and successful completion.
- acceptance criteria:
  - Reproducible machine-readable evidence demonstrates every listed stage.
- scope: feature pilot

### REQ-PILOT-02

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: A failing-test pilot proves bounded repair and re-verification.
- acceptance criteria:
  - Evidence shows the initial deterministic failure, creation of a bounded repair item, and the subsequent verifier result.
- scope: repair pilot

### REQ-PILOT-03

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: A restart pilot proves lease recovery and side-effect deduplication.
- acceptance criteria:
  - Terminating and resuming the run reclaims the lease without duplicating a commit, comment, or pull request.
- scope: recovery pilot

### REQ-PILOT-04

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/prd/PRD-loop-engineering.md
- description: A policy pilot proves secret-path blocking and approval waits for external actions.
- acceptance criteria:
  - Access to `.env` is denied by deterministic policy.
  - Push and deployment remain waiting until approval is explicitly recorded.
- scope: policy pilot

## Release Gate

CAS Loop Engineering v1 is complete only when every requirement above maps to exactly one roadmap phase and all four pilot requirements produce reproducible machine-readable evidence on a Windows-first local workstation. Cloud deployment requires separate approval and is not part of the local v1 completion decision.

