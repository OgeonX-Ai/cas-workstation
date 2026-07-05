# Requirements: Shared AI Engineering OS v1.2

**Defined:** 2026-07-05
**Completed:** 2026-07-05

## Compatibility Baseline

- [x] **COMP-01**: Live inventory records installed tools, versions, auth, config, and delegation evidence.
- [x] **COMP-02**: Compatibility distinguishes verified, unsupported, unavailable, and unverified behavior.
- [x] **COMP-03**: Adapters do not claim unsupported model-selection or delegation capabilities.

## Canonical Policy and SDLC

- [x] **POL-01**: `C:\PersonalRepo` contains one canonical engineering contract covering context, GSD, autonomy, delegation, collision safety, verification, evidence, retrospective, and escalation.
- [x] **POL-02**: Thin global adapters load the canonical contract while preserving precedence and safety.
- [x] **SDLC-01**: Quick, standard, and critical profiles define stages, gates, evidence, and failure return behavior.
- [x] **SDLC-02**: Overrides require reason, owner, skipped gate, risk, and compensating verification.
- [x] **GSD-01**: Work classes route to the correct GSD workflow and SDLC profile.
- [x] **GSD-02**: Planning metadata includes profile, risk, verifiers, evidence, and override state.

## Delegation and Model Tiering

- [x] **DEL-01**: Bounded delegation is standing-authorized while parent ownership remains explicit.
- [x] **DEL-02**: Concurrent writers require worktree isolation or disjoint ownership; recursive fan-out is bounded.
- [x] **DEL-03**: Task packets and returns are compact, artifact-oriented, and instruction-compliant.
- [x] **MOD-01**: `light`, `standard`, `strong`, and `adjudicator` map per tool and unavailable mappings are disabled.
- [x] **MOD-02**: Codex and Claude model separation is supported; Gemini is capability-gated; Antigravity uses top-level sessions pending proof.
- [x] **MOD-03**: Strong tiers are reserved for earned complexity and final adjudication.

## Routing, Evidence, and Rollout

- [x] **ROUT-01**: Deterministic routing emits the required structured fields and passes fixtures.
- [x] **ROUT-02**: Ollama is optional, benchmark-gated, disabled, and falls back deterministically.
- [x] **ROUT-03**: Ollama cannot adjudicate security, architecture, or completion.
- [x] **EVD-01**: Checkpoints, immutable artifacts, reviewed memory, and telemetry have separate rules.
- [x] **EVD-02**: Telemetry schema captures role, tier, time, retries, context, verifier, rework, and confidence.
- [x] **ROLL-01**: Verification detects missing references, invalid mappings, unsupported claims, and policy drift.
- [x] **ROLL-02**: Codex and Claude representative pilots produced evidence; Gemini and Antigravity used documented unavailable/manual fallbacks.
- [x] **ROLL-03**: Fresh sessions require no paid API key and Ollama absence/failure does not block work.

## Future Requirements

- Managed multi-machine scheduler or MAF runtime for cross-tool execution.
- Paid API-based routing or metering.
- Automatic tool subscription provisioning.

## Out of Scope

| Item | Reason |
|---|---|
| Paid model APIs | Explicit user constraint. |
| MAF runtime integration | Not needed for policy delivery and current use would require paid access. |
| Ollama coding or final adjudication | Local models are classification support only. |
| Unsupported Antigravity child overrides | No verified runtime contract. |
| Unbounded recursive delegation | Violates cost and collision controls. |

## Traceability

| Requirement | Phase | Status |
|---|---:|---|
| COMP-01..03 | 13 | Complete |
| POL-01..02 | 14 | Complete |
| SDLC-01..02, GSD-01..02 | 15 | Complete |
| DEL-01..03, MOD-01..03 | 16 | Complete |
| ROUT-01..03 | 17 | Complete |
| EVD-01..02 | 18 | Complete |
| ROLL-01 | 19 | Complete |
| ROLL-02..03 | 20 | Complete |
| All requirements | 21 | Complete |
