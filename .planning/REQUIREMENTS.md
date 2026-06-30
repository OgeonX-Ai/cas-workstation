# Requirements: CAS Loop Engineering

## v1 Requirements

### Workstation Stability

- [x] **STAB-01** — The workstation uses `C:\PersonalRepo` as its root and `C:\Users\KimHarjamaki` as the concrete Windows profile.
  - Acceptance: runtime/configuration checks resolve both exact paths.
- [x] **STAB-02** — `doctor.ps1` verifies the installed Promptimprover entry point and every required loop-engineering repository.
  - Acceptance: an invalid MCP entry point or missing required repo makes the doctor report fail.
- [x] **STAB-03** — Multi-repository watch reaches every configured repository per polling interval and persists deduplication.
  - Acceptance: restart preserves deduplication and failed work is not permanently marked processed.
- [x] **STAB-04** — A failed workflow resumes the failed step, not a terminal `Failed` checkpoint.
  - Acceptance: a regression test reproduces the defect and proves recovery retains earlier evidence.

### Goal Contract

- [x] **GOAL-01** — No run starts without objective, target repositories, measurable criteria, constraints, risk, approval policy, and budget.
  - Acceptance: missing required fields prevent dispatch.
- [x] **GOAL-02** — Every lifecycle record carries correlation, prompt, run, schema, repo, actor, timestamp, and W3C trace metadata.
  - Acceptance: contract validation rejects incomplete records.
- [x] **GOAL-03** — Execution limits are configurable and bounded.
  - Acceptance: defaults are fan-out 3, iterations 3, attempts 3, runtime 1800 seconds, model calls 20, and no-progress limit 2.

### Durable Scheduling

- [ ] **SCHED-01** — Goals, work items, dependencies, attempts, leases, budgets, evidence, and transitions are durably persisted.
  - Acceptance: restart reconstructs equivalent authoritative state.
- [ ] **SCHED-02** — Only dependency-ready work is leased under atomic global, provider, and repository limits.
  - Acceptance: incomplete dependencies and exhausted concurrency prevent leasing.
- [ ] **SCHED-03** — Expired leases are recoverable without duplicate side effects.
  - Acceptance: idempotency prevents duplicate commits, comments, PRs, or external actions.
- [ ] **SCHED-04** — Retry decisions classify transient, deterministic, policy, cancellation, and unrecoverable failures.
  - Acceptance: every retry decision records its class and consumed budget.
- [ ] **SCHED-05** — Goal outcomes expose explicit stop reasons and supporting evidence.
  - Acceptance: pass, exhaustion, cancellation, denial, approval wait, deadlock, unrecoverable fault, and no-progress are distinct.

### Isolated Agent Execution

- [ ] **WORK-01** — Every mutating item runs in a distinct worktree or ephemeral sandbox.
  - Acceptance: it has an idempotency key, deadline, path allowlist, artifacts, and leaves the default branch unchanged before integration.
- [ ] **WORK-02** — MAF supports bounded parallel specialists and typed fan-in.
  - Acceptance: three specialists overlap and aggregation waits for all required terminal results.
- [ ] **WORK-03** — Repository mutation has exactly one implementation owner per worktree.
  - Acceptance: research, architecture, security, test, and review specialists remain read-only.
- [ ] **WORK-04** — Destructive and externally visible actions require deterministic approval.
  - Acceptance: push, deploy, delete, messages, and production mutation cannot run before approval.

### Verification and Learning

- [ ] **VER-01** — Each repository declares native build, test, lint, security, and evaluation checks.
  - Acceptance: a missing required check is `inconclusive`, never `passed`.
- [ ] **VER-02** — Mandatory failures block completion and create only policy- and budget-approved repair work.
  - Acceptance: no failed mandatory check can coexist with `Completed`.
- [ ] **VER-03** — Artifact, verification, and evaluation outputs are schema-valid and evidence-backed.
  - Acceptance: each result validates and includes evidence URIs.
- [ ] **VER-04** — Promptimprover learning is terminal, deduplicated, candidate-based, and approval-gated.
  - Acceptance: terminal output is recorded once and only approved lessons affect later goals.

### Operations and Cloud

- [ ] **OPS-01** — Operators can inspect goal state, DAG, leases, attempts, budget, evidence, and stop reason.
  - Acceptance: the operator surface exposes every listed item for one run.
- [ ] **OPS-02** — OpenTelemetry correlates control plane, worker, tool, verifier, and Foundry without content capture by default.
  - Acceptance: traces share context and omit raw prompts/outputs.
- [ ] **CLOUD-01** — Azure reasoning uses Foundry Next Gen agent references and system-assigned managed identity.
  - Acceptance: authentication has no application secret and RBAC is project-scoped.
- [ ] **CLOUD-02** — Event-driven Functions use Flex Consumption Linux and delegate long-running/sandboxed execution.
  - Acceptance: ingress never performs long-running repo execution in-process.

### Pilot Evidence

- [ ] **PILOT-01** — A feature pilot proves parallel analysis, isolated implementation, deterministic verification, and completion.
- [ ] **PILOT-02** — A failing-test pilot proves bounded repair and re-verification.
- [ ] **PILOT-03** — A restart pilot proves lease recovery without duplicate commit, comment, or PR.
- [ ] **PILOT-04** — A policy pilot proves `.env` denial and approval waits for push/deploy.

## Deferred Requirements

- Distributed multi-machine scheduling
- Kubernetes deployment
- Automatic production deployment or merge

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| STAB-01 | Phase 1 | Complete |
| STAB-02 | Phase 1 | Complete |
| STAB-03 | Phase 1 | Complete |
| STAB-04 | Phase 1 | Complete |
| GOAL-01 | Phase 2 | Complete |
| GOAL-02 | Phase 2 | Complete |
| GOAL-03 | Phase 2 | Complete |
| SCHED-01 | Phase 3 | Pending |
| SCHED-02 | Phase 3 | Pending |
| SCHED-03 | Phase 3 | Pending |
| SCHED-04 | Phase 3 | Pending |
| SCHED-05 | Phase 3 | Pending |
| WORK-01 | Phase 4 | Pending |
| WORK-02 | Phase 4 | Pending |
| WORK-03 | Phase 4 | Pending |
| WORK-04 | Phase 4 | Pending |
| VER-01 | Phase 5 | Pending |
| VER-02 | Phase 5 | Pending |
| VER-03 | Phase 5 | Pending |
| VER-04 | Phase 5 | Pending |
| OPS-01 | Phase 6 | Pending |
| OPS-02 | Phase 6 | Pending |
| CLOUD-01 | Phase 6 | Pending |
| CLOUD-02 | Phase 6 | Pending |
| PILOT-01 | Phase 7 | Pending |
| PILOT-02 | Phase 7 | Pending |
| PILOT-03 | Phase 7 | Pending |
| PILOT-04 | Phase 7 | Pending |

**Coverage:** 28/28 requirements mapped exactly once.

