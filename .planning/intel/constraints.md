# Synthesized Technical Constraints

## Runtime Topology

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: protocol
- content: Requests flow through Promptimprover governance and CAS lifecycle contracts into the `gsd-orchestrator` goal control plane. Dependency-ready leases execute through `autogen`/MAF workers using Foundry Next Gen or an approved local provider in an isolated worktree or sandbox. Integration is serialized, native verification and `cas-evals` determine the outcome, and all lifecycle events, artifacts, evidence, traces, and learning remain correlated.

## Authoritative Local State Store

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: schema
- content: The local MVP uses an append-only event stream plus transactional projections in SQLite WAL. Required projections are `Goal`, `WorkItem`, `Dependency`, `Attempt`, `Lease`, `BudgetReservation`, and `EvidenceReference`. Worker checkpoints are attempt-local and Promptimprover records are learning projections; neither may override control-plane goal state.

## Goal State Model

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: schema
- content: The main progression is `Draft -> Refined -> Planned -> Running -> Integrating -> Verifying -> Completed`. Supported side and terminal states are `WaitingApproval`, `RetryScheduled`, `Paused`, `Cancelled`, `Blocked`, `Failed`, and `BudgetExhausted`.

## CAS Lifecycle Contract

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: api-contract
- content: The lifecycle sequence remains `PromptEnvelope -> PolicyDecision -> WorkRequest -> RunEvent[] -> ArtifactManifest -> VerificationResult -> EvaluationResult`. Contract evolution is additive and versioned.

## WorkRequest and WorkItem Records

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: schema
- content: The next `WorkRequest` version adds success criteria, constraints, fan-out/iteration/attempt/runtime/model-call budgets, optional provider cost limit and currency, no-progress policy, verification profile, approval policy, and required capabilities. Internal `WorkItem` records include dependency IDs, repository/path ownership, capability, risk, idempotency key, lease owner/expiry, attempt limit, inputs, and artifact references.

## Fan-Out and Fan-In

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: protocol
- content: The control plane transactionally leases only dependency-ready work within global, provider, and repository concurrency limits. A MAF worker may fan out read-only research, architecture, security, and test specialists into a typed aggregator. A single implementation owner performs mutation, native checks and model review produce evidence, and cross-work-item integration is serialized by the control plane.

## Retry and Stop Semantics

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: protocol
- content: Transient faults use bounded full-jitter backoff and honor `Retry-After`. Deterministic test failures create a repair item rather than replaying the same attempt. Policy denial, invalid goals, unsafe scope expansion, and unsupported schemas fail closed. Cancellation revokes leases, terminates child processes, and prevents new side effects. Repeated normalized verifier signatures count toward the no-progress limit. Completion requires every mandatory criterion and verifier check to pass.

## Isolation and Idempotency

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: nfr
- content: Each mutating item receives a branch and worktree under `C:\PersonalRepo\worktrees\<goal-id>\<work-item-id>`. Side-effect idempotency keys are persisted before dispatch. Integration validates the base SHA and converts conflicts to `WaitingApproval` or a replan item without silent overwrite. The default branch remains unchanged until an approved integration boundary. Production workers use ephemeral sandboxed containers when practical.

## Verification Evidence

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: nfr
- content: Repository profiles declare mandatory commands and timeouts for applicable build, test, lint/static analysis, security, and evaluation checks. Evidence records command, working directory, exit code, duration, sanitized summary, and evidence URI. No checks, missing tools, unapproved timeout, or unverifiable output is `inconclusive`; only `passed` satisfies a success criterion.

## Security and Identity

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: nfr
- content: File access is constrained to repository roots and blocks secret-bearing paths. Deterministic policy is authoritative. Production MCP uses remote HTTP/SSE with OAuth 2.1 PKCE or managed identity. Foundry calls use project Responses with a Next Gen `agent_reference`. Azure uses system-assigned managed identity and minimum project-scoped RBAC. Logs and traces exclude raw prompts, outputs, secrets, and tokens by default.

## Observability

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: nfr
- content: Every boundary propagates W3C trace context. Minimum metrics cover active goals, ready work items, lease age, attempt count, retry reason, verifier outcome, remaining budget, model calls, available token/cost values, runtime, and terminal stop reason.

## Test-First Defect Gate

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/specs/SPEC-loop-engineering.md
- type: protocol
- content: Before fixing the first-phase stability defects, reproduce each with a failing regression test: blocked multi-repository polling, terminal failed-checkpoint resume, memory-only or premature watch deduplication, validation that skips real repository gates, and stale workstation root/MCP/repository manifest entries.

