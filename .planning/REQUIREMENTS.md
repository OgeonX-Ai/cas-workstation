# Requirements: Shared AI Engineering OS v1.2

**Defined:** 2026-07-05
**Core Value:** A Windows-first developer can trust every supported AI coding tool to follow one evidence-gated engineering lifecycle without paid API dependencies or wasteful model use.

## Compatibility Baseline

- [ ] **COMP-01**: The system records installed Codex, Claude Code, Gemini, Antigravity, Git, PowerShell, and Ollama versions, authentication mode, configuration path, and available delegation features from live probes.
- [ ] **COMP-02**: The compatibility matrix distinguishes verified, unsupported, unavailable, and unverified behavior for model overrides, context inheritance, nested delegation, permissions, worktrees, and background execution.
- [ ] **COMP-03**: No adapter claims a model-selection or delegation capability that the installed tool cannot demonstrate.

## Canonical Policy and SDLC

- [ ] **POL-01**: `C:\PersonalRepo` contains one version-controlled canonical engineering contract with mandatory context discovery, GSD routing, autonomous continuation, delegation, collision prevention, verification, evidence, retrospective, and escalation rules.
- [ ] **POL-02**: Tool-global instructions remain thin and load the canonical contract without weakening global safety, identity, or repository-local precedence.
- [ ] **SDLC-01**: Quick, standard, and critical profiles define proportionate required stages, gates, evidence, and return-to-stage behavior after verifier failure.
- [ ] **SDLC-02**: A documented override records reason, owner, skipped gate, risk, and compensating verification.
- [ ] **GSD-01**: Trivial, defect, substantial, AI, UI, and security-sensitive work route to the correct GSD workflow and SDLC profile.
- [ ] **GSD-02**: Phase artifacts carry risk class, SDLC profile, verifiers, evidence locations, and override state.

## Delegation and Model Tiering

- [ ] **DEL-01**: Agents have standing authorization to delegate bounded work when it improves latency, specialization, or context isolation while the parent retains goal ownership and adjudication.
- [ ] **DEL-02**: Concurrent writers require isolated worktrees or explicit non-overlapping file ownership; uncontrolled recursive fan-out is prohibited.
- [ ] **DEL-03**: Delegated task packets and returns are compact, artifact-oriented, and respect the same global and repository-local instructions.
- [ ] **MOD-01**: Stable `light`, `standard`, `strong`, and `adjudicator` aliases map only to models actually available in each installed tool/subscription.
- [ ] **MOD-02**: Codex and Claude prove per-subagent model separation where supported; Antigravity uses separate tiered top-level sessions unless a live probe proves child override support; Gemini behavior is capability-gated.
- [ ] **MOD-03**: Expensive tiers are reserved for architecture, ambiguity, security, synthesis, conflict resolution, and final acceptance; bounded read-heavy work defaults to lighter tiers.

## Routing, Evidence, and Rollout

- [ ] **ROUT-01**: A deterministic classifier emits task class, risk, complexity, parallelizability, SDLC profile, role alias, confidence, and escalation reason with schema validation and fixtures.
- [ ] **ROUT-02**: Ollama remains optional and disabled unless a laptop-suitable model meets reviewed accuracy, latency, and reliability thresholds; deterministic fallback never blocks work.
- [ ] **ROUT-03**: Ollama cannot make final security, architecture, or completion decisions.
- [ ] **EVD-01**: Active checkpoints, immutable artifacts, reviewed durable memory, and telemetry have distinct storage and verification rules.
- [ ] **EVD-02**: Telemetry records tool/agent role, selected tier, elapsed time, retries, context estimate, verifier result, rework, and routing confidence without API price assumptions.
- [ ] **ROLL-01**: A verification command detects missing canonical references, policy drift, invalid model mappings, unsupported capability claims, and unsafe writer overlap.
- [ ] **ROLL-02**: Representative exploration, diagnosis, implementation, security review, and documentation tasks run across available tools with evidence and rollback instructions.
- [ ] **ROLL-03**: Fresh sessions load the canonical policy, continue autonomously within scope, require no paid API key, and fall back safely when Ollama is absent.

## Future Requirements

- Managed multi-machine scheduler or MAF runtime for cross-tool execution.
- Paid API-based routing or metering.
- Automatic tool subscription provisioning.

## Out of Scope

| Item | Reason |
|---|---|
| Paid model APIs | Explicit user constraint; use authenticated subscriptions and local tooling only. |
| MAF runtime integration | Requires paid model access in the current environment and is not needed for policy delivery. |
| Ollama coding or final adjudication | Local models are optional classification support only. |
| Unsupported Antigravity child-model overrides | Normal child inheritance must not be misrepresented. |
| Unbounded recursive delegation | Conflicts with cost, collision, and completion control. |

## Traceability

| Requirement | Phase | Status |
|---|---:|---|
| COMP-01..03 | 13 | Pending |
| POL-01..02 | 14 | Pending |
| SDLC-01..02, GSD-01..02 | 15 | Pending |
| DEL-01..03, MOD-01..03 | 16 | Pending |
| ROUT-01..03 | 17 | Pending |
| EVD-01..02 | 18 | Pending |
| ROLL-01 | 19 | Pending |
| ROLL-02..03 | 20 | Pending |
| All requirements | 21 | Pending |
