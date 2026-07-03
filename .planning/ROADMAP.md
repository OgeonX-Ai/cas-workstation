# Roadmap: CAS Explicit SDLC Execution Engine

## Milestones

- ✅ **v1.0 Loop Engineering** — Phases 1–8, 22 plans (shipped 2026-07-01). [Archive](milestones/v1.0-ROADMAP.md)
- 🚧 **v1.1 Explicit SDLC Execution Engine** — Phases 9–13 (in progress)

## Phases

- [ ] **Phase 9: Versioned SDLC Contracts and Profiles** — Publish strict v1.1 schemas, built-in profile, override validation, and compatibility tests.
- [ ] **Phase 10: Typed MAF Phase Runtime and Operator UI** — Execute and persist typed logical phases, retain compatibility fields, and expose phase state locally.
- [ ] **Phase 11: Prompt Governance and Review-Gated Memory** — Govern generated prompts and publish deduplicated evidence-backed memory candidates.
- [ ] **Phase 12: Durable Verified Phase Control Plane** — Compile prompts, persist phase state, enforce external verification, rollback dependencies, and bound escalation.
- [ ] **Phase 13: Integrated Pilots and Milestone Proof** — Connect all repositories and generate six restart-safe end-to-end proofs.

## Phase Details

### Phase 9: Versioned SDLC Contracts and Profiles
**Goal:** Every v1.1 run starts from one strict, portable, backward-compatible SDLC profile.
**Depends on:** Phase 8
**Requirements:** PROF-01, PROF-02, PROF-03, PROF-04
**Success Criteria:**
1. `cas-sdlc-v1` contains twelve mandatory phases grouped into five execution batches.
2. Repository overrides are bounded and invalid graphs, verifiers, and limits are rejected.
3. New phase lifecycle records validate while the complete v1.0 suite remains unchanged.

### Phase 10: Typed MAF Phase Runtime and Operator UI
**Goal:** Operators can execute, resume, and inspect typed logical phases through MAF.
**Depends on:** Phase 9
**Requirements:** EXEC-02, EXEC-03, EXEC-04, OPS-03, OPS-04
**Success Criteria:**
1. MAF accepts and returns v1.1 phase envelopes and rejects malformed input.
2. Specialists execute by batch with one Change mutation owner and run-scoped checkpoint artifacts.
3. The dashboard shows phases, verifiers, budgets, rollback, evidence, gates, and terminal state.
4. Existing five-stage API consumers continue to read legacy fields.

### Phase 11: Prompt Governance and Review-Gated Memory
**Goal:** Prompt and learning governance remains safe, terminal, deduplicated, and outside transition authority.
**Depends on:** Phase 9
**Requirements:** GOV-01, GOV-02, GOV-03
**Success Criteria:**
1. Generated phase prompts can be linted and redacted through a typed governance boundary.
2. Memory output is an evidence-backed candidate requiring approval.
3. Repeated terminal publication remains idempotent.

### Phase 12: Durable Verified Phase Control Plane
**Goal:** The .NET control plane becomes the sole durable authority for prompt-driven SDLC transitions.
**Depends on:** Phases 10 and 11
**Requirements:** EXEC-01, ROLL-01, ROLL-02, ROLL-03, ROLL-04, GOV-04
**Success Criteria:**
1. Deterministic phase prompts contain every required execution and safety field.
2. Only external verifier results advance phases.
3. Failed evidence rolls back to the earliest invalid dependency and invalidates downstream artifacts.
4. Restart, cancellation, human gates, and every budget stop reason remain deterministic.

### Phase 13: Integrated Pilots and Milestone Proof
**Goal:** Six generated pilots prove the complete v1.1 engine across repository boundaries.
**Depends on:** Phase 12
**Requirements:** PILOT-05
**Success Criteria:**
1. Success and early-phase rollback pilots prove all twelve phases and dependency recovery.
2. Repair and restart pilots prove bounded re-execution without duplicate effects.
3. Policy and terminal-learning pilots prove human gates and approved candidate boundaries.
4. Native Windows and Ubuntu gates pass in every changed repository.

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 9. Versioned SDLC Contracts and Profiles | 0/TBD | Not started | - |
| 10. Typed MAF Phase Runtime and Operator UI | 0/TBD | Not started | - |
| 11. Prompt Governance and Review-Gated Memory | 0/TBD | Not started | - |
| 12. Durable Verified Phase Control Plane | 0/TBD | Not started | - |
| 13. Integrated Pilots and Milestone Proof | 0/TBD | Not started | - |
