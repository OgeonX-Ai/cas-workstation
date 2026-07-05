# Roadmap: CAS Loop Engineering

## Milestones

- **v1.0 Loop Engineering** — Phases 1–8 (shipped 2026-07-01). [Archive](milestones/v1.0-ROADMAP.md)
- **v1.1 Portfolio Hardening** — Phases 9–12 (shipped 2026-07-05). [Archive](milestones/v1.1-ROADMAP.md)
- **v1.2 Shared AI Engineering OS** — Phases 13–21 (shipped 2026-07-05). [Archive](milestones/v1.2-ROADMAP.md)

## Current Milestone: v1.3 Bootstrapping

**4 phases** | **6 requirements mapped** | All covered ✓

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 22 | Ollama Latency Mitigation | Resolve Ollama latency bottlenecks with caching and async optimizations | PERF-01, PERF-02 | 2 |
| 23 | Multi-Machine Orchestration Core | Implement distributed scheduling architecture across nodes | SCALE-01 | 2 |
| 24 | Tooling & Fallback Routing | Integrate automatic tool provisioning and paid API-based routing | DX-01, DX-02 | 2 |
| 25 | v1.3 Verification and Pilots | Verify multi-machine execution and latency improvements via End-to-End pilots | SCALE-02 | 2 |

### Phase Details

**Phase 22: Ollama Latency Mitigation**
Goal: Resolve Ollama latency bottlenecks with caching and async optimizations
Requirements: PERF-01, PERF-02
Success criteria:
1. Ollama latency overhead reduced to acceptable limits.
2. Parallel request handling successfully prevents request queue blocking.

**Phase 23: Multi-Machine Orchestration Core**
Goal: Implement distributed scheduling architecture across nodes
Requirements: SCALE-01
Success criteria:
1. Orchestrator connects to multiple worker nodes.
2. Task distribution logic successfully dispatches tasks to remote agents.

**Phase 24: Tooling & Fallback Routing**
Goal: Integrate automatic tool provisioning and paid API-based routing
Requirements: DX-01, DX-02
Success criteria:
1. Bootstrapping successfully auto-provisions missing dependencies.
2. Paid API fallback routes correctly when local models fail.

**Phase 25: v1.3 Verification and Pilots**
Goal: Verify multi-machine execution and latency improvements via End-to-End pilots
Requirements: SCALE-02
Success criteria:
1. The engineering loop executes successfully across two distinct nodes.
2. All v1.3 goals are verifiable and recorded in the audit trace.
