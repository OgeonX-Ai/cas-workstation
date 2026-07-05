# Roadmap: CAS Loop Engineering

## Milestones

- ✅ **v1.0 Loop Engineering** — Phases 1–8, 22 plans (shipped 2026-07-01). [Roadmap archive](milestones/v1.0-ROADMAP.md)

## Phases

<details>
<summary>✅ v1.0 Loop Engineering (Phases 1–8) — SHIPPED 2026-07-01</summary>

- [x] Phase 1: Stable Workstation and Recovery (4/4 plans) — completed 2026-06-30
- [x] Phase 2: Typed Goal and Lifecycle Contract (2/2 plans) — completed 2026-06-30
- [x] Phase 3: Durable Goal Scheduler (3/3 plans) — completed 2026-06-30
- [x] Phase 4: Isolated MAF Fan-Out Workers (2/2 plans) — completed 2026-06-30
- [x] Phase 5: Evidence-Gated Verification and Learning (3/3 plans) — completed 2026-07-01
- [x] Phase 6: Operator Observability and Azure Boundaries (3/3 plans) — completed 2026-07-01
- [x] Phase 7: Reproducible Pilot Evidence (2/2 plans) — completed 2026-07-01
- [x] Phase 8: Executable Loop Integration (3/3 plans) — completed 2026-07-01

</details>

## Next Milestone

### 🚧 v1.1 Portfolio Hardening (in progress — started 2026-07-03)

Cross-repository hardening driven by verified findings in
[`docs/improvement-backlog.md`](../docs/improvement-backlog.md).

#### Phase 9: Systemic CI and Security Hardening

- [x] Phase 9: Systemic CI and Security Hardening (completed 2026-07-04)

**Goal:** Every active workflow uses bounded execution, least privilege, correct
analysis configuration, and maintainable action-update policy.
**Requirements:** CI-01, CI-02, CI-03
**Success criteria:**
1. No evidence-backed CodeQL language mismatch remains.
2. Active workflows declare minimum permissions and bounded job runtimes.
3. GitHub Actions dependencies are pinned or managed by an explicit update policy.

#### Phase 10: Contract Registry Consumer Protection

- [x] Phase 10: Contract Registry Consumer Protection (completed 2026-07-05)

**Goal:** Published CAS contracts are reproducible and consumers detect registry
or compatibility drift before merge.
**Requirements:** REG-01, REG-02, REG-03
**Success criteria:**
1. Registry artifacts build and validate deterministically.
2. Every genuine schema consumer validates the expected registry contract in CI.
3. Registry unavailability or digest drift fails with actionable evidence.

#### Phase 11: Infrastructure and Code Robustness Closure

- [x] Phase 11: Infrastructure and Code Robustness Closure (completed 2026-07-04)

**Goal:** Close only reproduced infrastructure and runtime robustness findings,
while recording false positives without speculative refactors.
**Requirements:** ROB-01, ROB-02, ROB-03
**Success criteria:**
1. Bicep security defaults and lint configuration pass repository validation.
2. Each C3–C6 lead is reproduced and fixed with regression coverage or dismissed with evidence.
3. No broad exception or input-limit change is introduced without a concrete failing boundary.

#### Phase 12: Portfolio Hardening Integration and UAT

- [x] Phase 12: Portfolio Hardening Integration and UAT (completed 2026-07-05)

**Goal:** Prove v1.1 works across repository boundaries and is ready to archive.
**Requirements:** VER-01, VER-02, VER-03
**Success criteria:**
1. Repository-native tests and security checks pass for every changed repository.
2. Cross-repository registry and workflow flows pass end to end.
3. Milestone audit and UAT contain no unresolved blocking item.
