# Roadmap: CAS Loop Engineering

## Milestones

- **v1.0 Loop Engineering** — Phases 1–8 (shipped 2026-07-01). [Archive](milestones/v1.0-ROADMAP.md)
- **v1.1 Portfolio Hardening** — Phases 9–12 (shipped 2026-07-05). [Archive](milestones/v1.1-ROADMAP.md)
- **v1.2 Shared AI Engineering OS** — Phases 13–21 (shipped 2026-07-05). [Archive](milestones/v1.2-ROADMAP.md)
- **v1.3 Bootstrapping** — Phases 22–25 (shipped 2026-07-05). [Archive](milestones/v1.3-ROADMAP.md)
- **v1.4 Quality and Resilience Hardening** — Phases 26–36, two tracks (shipped 2026-07-08). [Archive](milestones/v1.4-ROADMAP.md) · [Audit](../v1.4-MILESTONE-AUDIT.md)

## Current Milestone: v1.5 Delivery Flow & Release Engineering (started 2026-07-08)

**Goal:** changes flow from agent to `main` in hours without weakening two-party review; every repo ships versioned releases. Requirements: `.planning/REQUIREMENTS.md` (REQ-1.5.1-6). Seeds: [milestones/vNEXT-SEEDS.md](milestones/vNEXT-SEEDS.md).

- **Phase 38: Merge Flow & Hygiene Backfill** — auto-merge/merge-queue policy with a real second reviewer; drain-residuals backfill (kept branches, worktree leftovers, root protection decision). *(REQ-1.5.1, 1.5.2)* — **3 plans**
  - [ ] 38-01-PLAN.md — Merge-flow policy & review-bot mechanism (eligibility classifier + critic_cli-gated review-bot App + branch-protection-as-code)
  - [ ] 38-02-PLAN.md — Residual branch/worktree backfill (squash-aware content gate applied to 6 kept branches; disposition 2 worktree leftovers)
  - [ ] 38-03-PLAN.md — Root-repo branch-protection decision & codification (root moves to PR flow)
- **Phase 39: Release Engineering** — per-repo SemVer + generated release notes on merge; staleness detection in the sweep. *(REQ-1.5.3, 1.5.5)*
- **Phase 40: Pilot Cadence** — weekly scheduled pilots + fault injections with committed evidence; regression auto-issues. *(REQ-1.5.4)*
- **Phase 41: Learning Loop** — LEARNINGS.md extraction at phase close; repeatable backlog survey script. *(REQ-1.5.6)*
- **Phase 42: v1.5 Verification & Milestone Audit** — full verifier stack + audit + archive. *(depends on 38-41)*

## Future Milestones (seeded 2026-07-08 — see [milestones/vNEXT-SEEDS.md](milestones/vNEXT-SEEDS.md))

- **v1.6 Trust Depth & Self-Measurement** — Phases 43–47: signed commits/SLSA-lite/SBOM, secret-scanning + token rotation, DORA + token-economics dashboard from traces.jsonl, mutation + property-based testing, audit.
- **v1.7 Product & Scale** — Phases 48–51: clean-machine bootstrap product, marketing-as-code showcase live (Phase 37 strategy: [37-CONTEXT](phases/37-marketing-and-adoption/37-CONTEXT.md), backlog M1–M3), disaster-restore drill, cloud readiness (**gated on operator lifting the NO-AZURE deploy lock**).
