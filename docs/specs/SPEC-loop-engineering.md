# Technical Specification: CAS Loop Engineering v1

## Scope

This specification defines the goal-level control plane, task-attempt worker
boundary, verifier loop, lifecycle contracts, and operational limits required
to turn the current CAS portfolio into one bounded engineering loop.

## Runtime Topology

```text
Prompt or issue
  -> Promptimprover governance
  -> CAS PromptEnvelope + WorkRequest
  -> gsd-orchestrator goal control plane
     -> dependency-ready work-item leases
     -> autogen/MAF task workers
        -> Foundry Next Gen or approved local provider
        -> isolated worktree/sandbox
     -> serial fan-in integration
     -> native verifier + cas-evals
        -> pass: complete
        -> repairable fail and budget remains: create repair work item
        -> hard stop: wait, block, cancel, fail, or exhaust budget
  -> RunEvents, artifacts, verification, evaluation, traces, and learning
```

## Authoritative State

The goal control plane stores an append-only event stream and transactional
projections in SQLite WAL for the local MVP. Required projections are `Goal`,
`WorkItem`, `Dependency`, `Attempt`, `Lease`, `BudgetReservation`, and
`EvidenceReference`.

Goal states:

```text
Draft -> Refined -> Planned -> Running -> Integrating -> Verifying -> Completed
```

Side and terminal states:

```text
WaitingApproval | RetryScheduled | Paused | Cancelled | Blocked |
Failed | BudgetExhausted
```

Worker checkpoints are attempt-local. Promptimprover event storage is a
learning projection. Neither may override control-plane goal state.

## Contracts

CAS lifecycle remains:

```text
PromptEnvelope -> PolicyDecision -> WorkRequest -> RunEvent[] ->
ArtifactManifest -> VerificationResult -> EvaluationResult
```

The next additive contract version extends `WorkRequest` with:

- `successCriteria[]`
- `constraints[]`
- `budget.maxFanOut`
- `budget.maxIterations`
- `budget.maxAttemptsPerWorkItem`
- `budget.maxRuntimeSeconds`
- `budget.maxModelCalls`
- optional provider cost limit and currency
- `stopPolicy.noProgressLimit`
- `verificationProfile`
- `approvalPolicy`
- required capability list

Internal `WorkItem` records include dependency IDs, repository and path
ownership, capability, risk, idempotency key, lease owner/expiry, attempt
limit, inputs, and artifact references.

## Fan-Out and Fan-In

The control plane leases dependency-ready work under transactional global,
provider, and repository concurrency limits. A MAF worker may use
`WorkflowBuilder` fan-out/fan-in primitives for task-local specialists.

The initial specialist graph is:

```text
dispatcher
  -> research specialist
  -> architecture specialist
  -> security specialist
  -> test specialist
  -> typed aggregator
  -> single implementation owner
  -> model review + deterministic native checks
  -> verifier verdict
```

Read-only branches may execute concurrently. Repository mutation has one owner
per worktree. Cross-work-item integration is serialized by the control plane.

## Retry and Stop Semantics

- Transient provider, transport, throttling, and temporary filesystem faults
  use bounded full-jitter backoff and honor `Retry-After`.
- Deterministic test failures do not replay the same attempt. They generate a
  repair item with the failing evidence when budget permits.
- Policy denial, invalid goal, unsafe scope expansion, and unsupported schema
  fail closed.
- Cancellation revokes leases, terminates child processes, and prevents new
  side effects.
- A repeated normalized verifier failure signature increments no-progress
  count. Reaching the configured limit stops the goal.
- Completion requires every mandatory criterion and verifier check to pass.

## Isolation and Idempotency

- Each mutating item receives a branch and worktree under
  `C:\PersonalRepo\worktrees\<goal-id>\<work-item-id>`.
- Side effects require deterministic idempotency keys persisted before
  dispatch.
- Integrating patches checks the base SHA and detects conflicts. Conflicts
  become `WaitingApproval` or a replan item; they never overwrite silently.
- The default branch remains unchanged until an approved integration boundary.
- Production worker execution uses ephemeral sandboxed containers when
  practical.

## Verification

A repository verification profile declares mandatory commands and timeouts.
The verifier records command, working directory, exit code, duration, sanitized
output summary, and evidence URI. Required check categories are build, tests,
lint/static analysis, security, and evaluation where applicable.

`no checks`, missing tools, timeout without policy, or unverifiable output is
`inconclusive`. Only `passed` can satisfy a success criterion.

## Security and Identity

- File operations are repo-root constrained and block secret-bearing paths.
- Deterministic policy is authoritative; model-requested approval is advisory.
- Production MCP uses remote HTTP/SSE with OAuth 2.1 PKCE or managed identity.
- Foundry calls use project Responses with a Next Gen `agent_reference`.
- Azure uses system-assigned managed identity and minimum project-scoped RBAC.
- Logs and traces store identifiers and classifications, not raw prompts,
  outputs, secrets, or tokens by default.

## Observability

Every boundary propagates W3C trace context. Minimum metrics are active goals,
ready work items, lease age, attempt count, retry reason, verifier outcome,
budget remaining, model calls, token/cost values when available, runtime, and
terminal stop reason.

## First-Phase Defects to Reproduce Before Fixing

1. Multi-repository watch awaits the first repository loop indefinitely and
   does not reach later configured repositories.
2. A failed state is checkpointed as terminal `Failed`; resume does not replay
   the failed step.
3. Watch deduplication is memory-only and may mark failed items processed.
4. Existing validation can warn and continue without executing the repository's
   real build/test gate.
5. The committed workstation manifest still uses stale root and MCP entry-point
   paths and does not list all loop-engineering repositories.

Each defect requires a failing regression test before its implementation fix.

