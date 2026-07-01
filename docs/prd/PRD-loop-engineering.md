# Product Requirements: CAS Loop Engineering v1

## Product Goal

Given a repository-scoped engineering goal, CAS produces a typed plan, fans
out independent work safely, fans results into an isolated integration path,
iterates only on verified failures, and stops only when measurable acceptance
criteria pass or a bounded stop rule fires.

## Primary User

A single Windows-first developer operating the CAS workstation under
`C:\PersonalRepo` through Codex, Claude Code, Gemini CLI, or the CAS operator
surface.

## User Stories

- As an operator, I can submit a measurable engineering goal and know the
  exact success, budget, risk, and stop conditions before execution begins.
- As an operator, I can see which tasks and agents run concurrently, which are
  blocked, and why the system retried or stopped.
- As an operator, I can terminate and resume a run without duplicate commits,
  comments, pull requests, or external actions.
- As an operator, I receive deterministic test and evaluation evidence before
  a goal can be marked complete.
- As an operator, I retain approval control over destructive, externally
  visible, secret-bearing, or deployment actions.

## v1 Requirements

### Workstation Stability

- **STAB-01:** The workstation uses `C:\PersonalRepo` as its root and
  `C:\Users\KimHarjamaki` as the concrete Windows profile.
- **STAB-02:** `doctor.ps1` verifies the exact installed Promptimprover entry
  point and all required loop-engineering component repositories.
- **STAB-03:** Multi-repository watch processes every configured repository in
  one polling interval and persists deduplication state.
- **STAB-04:** A failed workflow resumes the failed step rather than resuming a
  terminal `Failed` checkpoint.

### Goal Contract

- **GOAL-01:** No run starts without an objective, target repositories,
  machine-verifiable success criteria, constraints, risk classification,
  approval policy, and bounded budget.
- **GOAL-02:** Every lifecycle record carries one `correlationId`, `promptId`,
  `runId`, schema version, repository identity, actor, timestamp, and W3C trace
  context.
- **GOAL-03:** Proposed MVP defaults are configurable: maximum fan-out 3,
  maximum loop iterations 3, maximum work-item attempts 3, maximum runtime 30
  minutes, maximum model calls 20, and no-progress limit 2 identical verifier
  failure signatures.

### Durable Scheduling

- **SCHED-01:** The control plane persists goals, work items, dependencies,
  attempts, leases, budgets, evidence references, and state transitions.
- **SCHED-02:** Only dependency-ready work may be leased, and global,
  provider, and repository concurrency limits are enforced atomically.
- **SCHED-03:** Restart reconciliation reclaims expired leases without
  duplicating side effects.
- **SCHED-04:** Retry policy distinguishes transient failures, deterministic
  verification failures, policy denials, cancellations, and unrecoverable
  faults.
- **SCHED-05:** Terminal stop reasons include verifier pass, budget exhausted,
  cancellation, policy denial, approval wait, dependency deadlock,
  unrecoverable fault, and repeated no progress.

### Isolated Agent Execution

- **WORK-01:** Every mutating work item runs in a distinct Git worktree or
  ephemeral sandbox with an idempotency key, deadline, path allowlist, and
  captured artifact manifest.
- **WORK-02:** MAF can fan out at least three independent specialists and fan
  them into a typed aggregator; aggregation cannot start until all required
  branches are terminal.
- **WORK-03:** Repository writes have one implementation owner. Research,
  architecture, security, testing, and review specialists remain read-only.
- **WORK-04:** External actions such as push, deployment, deletion, messages,
  and production mutation require deterministic policy approval.

### Verification and Learning

- **VER-01:** Each repository declares native build, test, lint, security, and
  evaluation commands. Missing required checks produce `inconclusive`, never
  success.
- **VER-02:** Any failed mandatory check blocks completion and may create a
  bounded repair item when policy and budget permit.
- **VER-03:** The system emits schema-valid `ArtifactManifest`,
  `VerificationResult`, and `EvaluationResult` records with evidence URIs.
- **VER-04:** Promptimprover records terminal output once, creates only
  candidate lessons from failures, and injects a lesson only after explicit
  approval.

### Operations and Cloud

- **OPS-01:** Operators can inspect goal state, task DAG, active leases,
  attempts, budget consumption, verifier evidence, and stop reason.
- **OPS-02:** OpenTelemetry spans and metrics correlate control-plane,
  worker, tool, verifier, and Foundry boundaries without recording prompt or
  output content by default.
- **CLOUD-01:** Azure reasoning uses Foundry Next Gen agent references and a
  system-assigned managed identity with minimum project-scoped RBAC.
- **CLOUD-02:** Event-driven Azure Functions use Flex Consumption Linux;
  long-running or sandboxed execution remains behind an explicit isolated
  worker boundary.

### Pilot Evidence

- **PILOT-01:** A feature scenario demonstrates parallel analysis, isolated
  implementation, deterministic verification, and successful completion.
- **PILOT-02:** A failing-test scenario demonstrates bounded repair and
  re-verification.
- **PILOT-03:** A restart scenario demonstrates lease recovery and no duplicate
  commit, comment, or pull request.
- **PILOT-04:** A policy scenario proves `.env` is blocked and push/deploy waits
  for approval.

## Non-Goals for v1

- Multi-machine distributed scheduling.
- Kubernetes deployment.
- Automatic production deployment or merge.
- Unbounded autonomous retries.
- Replacing GSD, Microsoft Agent Framework, CAS contracts, or CAS Evals.

## Release Gate

v1 is complete only when all requirements map to exactly one roadmap phase and
the four pilot scenarios produce reproducible machine-readable evidence on a
Windows-first local workstation. Cloud deployment remains separately approved.

