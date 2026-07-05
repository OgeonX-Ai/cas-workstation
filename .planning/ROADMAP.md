# Roadmap: CAS Loop Engineering

## Milestones

- **v1.0 Loop Engineering** — Phases 1–8 (shipped 2026-07-01). [Archive](milestones/v1.0-ROADMAP.md)
- **v1.1 Portfolio Hardening** — Phases 9–12 (shipped 2026-07-05). [Archive](milestones/v1.1-ROADMAP.md)
- **v1.2 Shared AI Engineering OS** — Phases 13–21 (shipped 2026-07-05). [Archive](milestones/v1.2-ROADMAP.md)
- **v1.3 Bootstrapping** — Phases 22–25 (shipped 2026-07-05). [Archive](milestones/v1.3-ROADMAP.md)

## Current Milestone: v1.4 Quality and Resilience Hardening

- **Phase 26: Test Coverage Automation & Enforcement**
  Establish the 100% test coverage baseline CI gates. Generate missing unit, smoke, regression, and E2E tests for `gsd-orchestrator` and `autogen`.
- **Phase 27: Resilience First Error Typing**
  Refactor all agent boundaries and execution loops to use explicit typed failure states mapped to CAS Contracts.
- **Phase 28: Fault-Injection & Recovery Auditing**
  Simulate catastrophic API and state failures to prove gracefully halted and retryable deterministic states.
- **Phase 29: Automated Peer Critic Pattern**
  Implement the concurrent `critic` agent as a permanent SDLC security and resilience gate for all future implementations.
