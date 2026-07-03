# Requirements: CAS Explicit SDLC Execution Engine

**Defined:** 2026-07-03
**Core Value:** A Windows-first developer can trust CAS to pursue repository goals in parallel without losing control of state, cost, safety, evidence, or completion.

## v1.1 Requirements

### Contracts and Profiles

- [ ] **PROF-01**: A repository can select the strict versioned `cas-sdlc-v1` profile containing all twelve mandatory logical phases in five execution batches.
- [ ] **PROF-02**: A repository can override only prompt fragments, verifier commands, required artifacts, and phase limits within the parent goal budget.
- [ ] **PROF-03**: Invalid profiles are rejected for missing phases, cycles, unknown verifiers, unsafe transitions, unbounded retries, or excessive limits.
- [ ] **PROF-04**: v1.1 work requests and phase request, result, verification, and lifecycle records validate without changing any v1.0 contract.

### Phase Execution

- [ ] **EXEC-01**: The control plane compiles a deterministic phase prompt containing goal, constraints, phase, batch, evidence, outputs, success criteria, verifier, rollback, memory, stop, and escalation instructions.
- [ ] **EXEC-02**: MAF executes a typed phase request with the mapped specialists and returns schema-valid artifacts while retaining one mutation owner for Change.
- [ ] **EXEC-03**: All twelve logical phases execute in dependency order through Discovery, Design, Change, Assurance, and Closure batches.
- [ ] **EXEC-04**: Phase prompts and artifacts are persisted under the run-scoped checkpoint boundary and can resume after interruption.

### Verification and Rollback

- [ ] **ROLL-01**: A phase advances only when its declared external verifier passes; model assertions never authorize a transition.
- [ ] **ROLL-02**: A failed verifier identifies invalidated phases and the control plane resumes from the earliest affected dependency.
- [ ] **ROLL-03**: Rollback invalidates downstream artifacts and records attempts, evidence, origin, reason, and consumed budget.
- [ ] **ROLL-04**: Retries stop deterministically on attempts, iterations, runtime, model-call, or no-progress exhaustion.

### Governance and Memory

- [ ] **GOV-01**: Generated prompts pass governance and redaction before dispatch without granting Promptimprover transition authority.
- [ ] **GOV-02**: Closure emits a versioned evidence-backed memory candidate that cannot affect future goals until approved.
- [ ] **GOV-03**: Exactly one deduplicated terminal outcome is published for each run.
- [ ] **GOV-04**: The engine pauses only for unresolved ambiguity, policy-required external actions, destructive changes, or exhausted authority and budget.

### Operator Experience and Proof

- [ ] **OPS-03**: The local dashboard displays five batches, twelve phases, current attempt, verifier, budget, evidence, rollback, waiting, and terminal states.
- [ ] **OPS-04**: Authorized human gates can be approved or denied locally while legacy five-stage API fields remain readable.
- [ ] **PILOT-05**: Six executable pilots prove success, early rollback, implementation repair, restart recovery, policy approval, and terminal learning.

## Future Requirements

- Distributed multi-machine execution.
- Production remote HTTP execution API.
- Automatic production deployment or merge.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Azure resource deployment | Requires separate explicit authorization |
| Kubernetes delivery | Not required for the Windows-first local milestone |
| Freeform phase graphs | Would bypass bounded schema and transition safety |
| Model-authorized completion | Conflicts with deterministic verifier authority |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| PROF-01 | Phase 9 | Pending |
| PROF-02 | Phase 9 | Pending |
| PROF-03 | Phase 9 | Pending |
| PROF-04 | Phase 9 | Pending |
| EXEC-02 | Phase 10 | Pending |
| EXEC-03 | Phase 10 | Pending |
| EXEC-04 | Phase 10 | Pending |
| OPS-03 | Phase 10 | Pending |
| OPS-04 | Phase 10 | Pending |
| GOV-01 | Phase 11 | Pending |
| GOV-02 | Phase 11 | Pending |
| GOV-03 | Phase 11 | Pending |
| EXEC-01 | Phase 12 | Pending |
| ROLL-01 | Phase 12 | Pending |
| ROLL-02 | Phase 12 | Pending |
| ROLL-03 | Phase 12 | Pending |
| ROLL-04 | Phase 12 | Pending |
| GOV-04 | Phase 12 | Pending |
| PILOT-05 | Phase 13 | Pending |

**Coverage:** 19/19 requirements mapped exactly once.

---
*Requirements defined: 2026-07-03*
*Last updated: 2026-07-03 after v1.1 roadmap creation*
