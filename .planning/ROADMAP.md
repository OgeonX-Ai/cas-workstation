# Roadmap: CAS Loop Engineering

## Overview

The milestone first makes the existing workstation and control plane truthful
and recoverable. It then adds typed goals, durable dependency-aware scheduling,
isolated MAF fan-out workers, evidence-gated verification, operational/cloud
boundaries, and finally four reproducible end-to-end pilot proofs.

## Phases

**Phase Numbering:**
- Integer phases are planned milestone work.
- Decimal phases are urgent insertions created after planning.

- [x] **Phase 1: Stable Workstation and Recovery** - Existing CAS paths, health checks, watch mode, and resume behavior become reliable. (completed 2026-06-30)
- [x] **Phase 2: Typed Goal and Lifecycle Contract** - Every run starts from one measurable, bounded, traceable contract. (completed 2026-06-30)
- [ ] **Phase 3: Durable Goal Scheduler** - Goals execute through dependency-aware leases, budgets, retries, and stop rules.
- [ ] **Phase 4: Isolated MAF Fan-Out Workers** - Bounded specialists execute in isolated workspaces with one mutation owner.
- [ ] **Phase 5: Evidence-Gated Verification and Learning** - Native checks and CAS Evals become the only completion authority.
- [ ] **Phase 6: Operator Observability and Azure Boundaries** - Operators can inspect runs, and Foundry/Azure boundaries are identity-first and traceable.
- [ ] **Phase 7: Reproducible Pilot Evidence** - Feature, repair, restart, and policy scenarios prove the complete loop.

## Phase Details

### Phase 1: Stable Workstation and Recovery
**Goal**: The developer can trust the existing workstation and control-plane baseline before new concurrency is introduced.
**Depends on**: Nothing (first phase)
**Requirements**: STAB-01, STAB-02, STAB-03, STAB-04
**Success Criteria** (what must be TRUE):
  1. The workstation and doctor report resolve `C:\PersonalRepo`, `C:\Users\KimHarjamaki`, the real Promptimprover entry point, and all required repositories.
  2. One watch interval processes two configured repositories and retains restart-safe deduplication without losing failed work.
  3. A reproduced state failure resumes the failed state with earlier evidence instead of stopping at terminal `Failed`.
  4. Every baseline defect has a failing regression test before its fix and a passing result afterward.
**Plans**: TBD

### Phase 2: Typed Goal and Lifecycle Contract
**Goal**: The developer can submit a goal whose measurable completion, budgets, policy, and traceability are validated before dispatch.
**Depends on**: Phase 1
**Requirements**: GOAL-01, GOAL-02, GOAL-03
**Success Criteria** (what must be TRUE):
  1. Incomplete or unbounded goals are rejected before any model, tool, or worker action.
  2. Accepted goals expose validated success criteria, approval policy, verification profile, and configurable execution limits.
  3. Every emitted lifecycle record validates with consistent IDs, schema version, repository, actor, timestamp, and W3C trace context.
**Plans**: TBD

### Phase 3: Durable Goal Scheduler
**Goal**: The developer can start, inspect, cancel, and resume dependency-aware goals without duplicate work or unbounded retries.
**Depends on**: Phase 2
**Requirements**: SCHED-01, SCHED-02, SCHED-03, SCHED-04, SCHED-05
**Success Criteria** (what must be TRUE):
  1. Restart reconstructs goals, work items, dependencies, attempts, leases, budgets, evidence, and transition history.
  2. Only dependency-ready work receives a lease, and configured concurrency cannot be exceeded.
  3. Expired leases recover without duplicating commits, comments, PRs, or external actions.
  4. Retry and stop outcomes expose a deterministic classification, consumed budget, reason, and evidence.
**Plans**: TBD

### Phase 4: Isolated MAF Fan-Out Workers
**Goal**: The developer can observe bounded specialist parallelism while all repository mutation remains isolated and single-owner.
**Depends on**: Phase 3
**Requirements**: WORK-01, WORK-02, WORK-03, WORK-04
**Success Criteria** (what must be TRUE):
  1. Three read-only specialists overlap in time and a typed aggregator waits for every required terminal result.
  2. Each mutating item has a distinct worktree or sandbox, deadline, path allowlist, idempotency key, and artifact manifest.
  3. Exactly one implementation owner mutates each worktree, and the default branch remains unchanged before integration.
  4. Push, deployment, deletion, messages, and production mutation wait for deterministic approval.
**Plans**: TBD

### Phase 5: Evidence-Gated Verification and Learning
**Goal**: The developer receives deterministic evidence, bounded repair, and approved learning; model confidence alone can never complete a goal.
**Depends on**: Phase 4
**Requirements**: VER-01, VER-02, VER-03, VER-04
**Success Criteria** (what must be TRUE):
  1. Each target repository executes its declared native verification profile, and missing mandatory checks are inconclusive.
  2. A failed mandatory check blocks completion and creates repair work only when policy and budget permit.
  3. Artifact, verification, and evaluation records validate against CAS contracts and link to durable evidence.
  4. Promptimprover records one terminal outcome and only approved candidate lessons influence later goals.
**Plans**: TBD

### Phase 6: Operator Observability and Azure Boundaries
**Goal**: The developer can inspect the complete loop, while Azure reasoning and execution boundaries remain identity-first, traceable, and non-blocking.
**Depends on**: Phase 5
**Requirements**: OPS-01, OPS-02, CLOUD-01, CLOUD-02
**Success Criteria** (what must be TRUE):
  1. The operator view exposes goal state, DAG, leases, attempts, remaining budget, verifier evidence, and stop reason.
  2. One trace correlates control plane, worker, tool, verifier, and Foundry spans without raw prompt/output capture.
  3. Foundry Next Gen calls use an agent reference and system-assigned managed identity with project-scoped RBAC.
  4. Flex Consumption Linux ingress delegates long-running or sandboxed work across an explicit worker boundary.
**Plans**: TBD
**UI hint**: yes

### Phase 7: Reproducible Pilot Evidence
**Goal**: The developer can reproduce four machine-readable scenarios that prove the complete bounded loop.
**Depends on**: Phase 6
**Requirements**: PILOT-01, PILOT-02, PILOT-03, PILOT-04
**Success Criteria** (what must be TRUE):
  1. The feature pilot proves parallel analysis, isolated implementation, deterministic verification, and successful completion.
  2. The repair pilot records the initial failure, bounded repair item, and subsequent verifier result.
  3. The restart pilot reclaims an interrupted lease without duplicate commit, comment, or PR.
  4. The policy pilot denies `.env` access and holds push/deploy until approval.
**Plans**: TBD

## Progress

**Execution Order:** Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6 -> Phase 7

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Stable Workstation and Recovery | 4/4 | Complete    | 2026-06-30 |
| 2. Typed Goal and Lifecycle Contract | 2/2 | Complete    | 2026-06-30 |
| 3. Durable Goal Scheduler | 0/TBD | Not started | - |
| 4. Isolated MAF Fan-Out Workers | 0/TBD | Not started | - |
| 5. Evidence-Gated Verification and Learning | 0/TBD | Not started | - |
| 6. Operator Observability and Azure Boundaries | 0/TBD | Not started | - |
| 7. Reproducible Pilot Evidence | 0/TBD | Not started | - |

