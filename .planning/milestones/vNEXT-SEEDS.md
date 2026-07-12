# CAS — Next-Milestones Seed Plan v3 (v1.6 → v1.7)

**v1 authored:** 2026-07-08. **v2 amended:** 2026-07-11 by closed-loop round 1
(fact-check: `.planning/research/SEEDS-FACTCHECK-R1.md` — 10 holds / 9 stale / 3 wrong;
red-team: `.planning/research/ROADMAP-REDTEAM-R1.md` — 9 ADD / 3 CUT / 2 RESEQUENCE).
Round 2 critique (SEEDS-CRITIQUE-R2.md): NOT-CONVERGED, 4 material findings (M1-M4) — applied below in v3. Convergence loop continues until a full round yields no material findings.

## Amendments from round 1 (what changed and why)

1. **RESEQUENCED (R1/R2 + A4):** continuity (minimal bootstrap + non-git backup + incident runbook) moves to the FRONT of v1.6 — later phases must not keep shipping un-restorable state.
2. **RESCOPED 44 (fact-check):** GitHub secret-scanning + push protection are already enabled on all 12 org repos (live-verified) — the phase is now PAT inventory/rotation + signing + model-policy review.
3. **PRECONDITIONED 45 (fact-check WRONG#2):** traces.jsonl cannot feed a DORA/token dashboard (18 rows, no repo/PR/outcome/duration fields, 14/18 zero-token) — schema extension + instrumentation are now explicit first tasks.
4. **PRECONDITIONED 46 (fact-check new finding):** gsd-orchestrator `dotnet test` fails restore (NETSDK1064) and autogen full-suite pytest has 25 collection errors — a suite-health fix task gates mutation work; mutation scope narrowed to orchestrator core + cas-contracts property tests only (C2).
5. **CUT/DEFERRED (C1):** SLSA-lite/SBOM deferred until a trigger fires: first real external consumer of a CAS release. Kept as a named deferred item, not silent deletion.
6. **OPERATOR QUESTION (C3, unresolved):** is public brand/adoption an explicit goal? YES → Phase 37/49 marketing executes in v1.7; NO → marketing reduces to the existing org-profile/wiki layer and 49 is cut. *Blocking only for v1.7 planning.*
7. **NEW standing guardrails (A1/A2/A7 — schedule as the first v1.6 quick-batch, they are small):**
   - **A1 SHA-reachability gate** — extend workflow-lint + sweep: every `uses: <repo>@<sha>` must be reachable from the provider's default branch. This failure class hit three times; mechanize per the standing rule.
   - **A2 multi-AI coordination lease** — a lightweight lockfile/lease convention in GLOBAL_AGENTS.md + sweep check, so Claude/Codex/Gemini sessions declare working-tree ownership instead of colliding by luck.
   - **A7 model-policy review gate** — engineering-os/models/*.json changes require a PR (they are policy; today they drift as dirty files).

## v1.6 — Continuity & Self-Measurement (phases 43–47)

**Goal:** the system survives the loss of its one machine, measures itself by trend, and its tests prove their own quality — with continuity FIRST.

| Phase | Scope | Requirement seeds (falsifiable) |
|---|---|---|
| 43 Continuity First | Minimal clean-machine bootstrap (setup.ps1 hardened to restore workstation from remotes: clones, scheduled tasks, tool checks); non-git state backup job (scheduler defs, evidence/, secrets INVENTORY — pointers not values); incident-response runbook (who/what acts on a red sweep/pilot alert, escalation, break-glass procedures incl. the enforce_admins dance); gemini-nano adopt-or-quarantine decision executed (A6, operator choice recorded); **A1 SHA-reachability gate** built into workflow-lint + sweep (the thrice-hit failure class — M1 fix); **A2 multi-AI coordination lease** convention in GLOBAL_AGENTS.md + sweep check (M1 fix) | Timed restore rehearsal on a throwaway directory: remotes → green sweep + green root suite; backup job produces a dated artifact; runbook exercised against one synthetic alert; lint red-fixture proves an unreachable-SHA `uses:` is caught; lease check flags a second writer on a claimed tree |
| 44 Identity & Access | PAT/credential inventory with expiry + rotation runbook; SSH commit signing (lower friction than gitsign on Windows — fact-checked) for operator + agent identities, enforced advisory-first; model-policy PR gate (A7); verify-and-document the already-on secret scanning (evidence, not setup) | `git verify-commit HEAD` passes on new default-branch commits; inventory doc lists every credential with owner+expiry; canary secret blocked (live test) |
| 45 Self-Measurement | traces.jsonl schema v2 (repo, PR, phase, outcome, duration, tokens) + instrumentation at agent-spawn/close; THEN the DORA+token dashboard (local static, scheduled regen); spend caps with a hard stop per phase (A3); convergence metric (learning-loop opened-vs-closed) with named owner + weekly cadence (A8); retention policy for traces/evidence growth (A9) | Dashboard renders 4 DORA metrics + token spend from ≥2 weeks of v2-schema data that reconciles with gh spot checks; a synthetic over-budget phase triggers the cap stop |
| 46 Test Depth (narrowed) | FIRST: suite health — fix NETSDK1064 restore in gsd-orchestrator and the 25 pytest collection errors in autogen (these are real defects today); THEN mutation testing on gsd-orchestrator Loop/StateMachine core only (Stryker.NET 4.16 verified compatible) with kill-rate ratchet report-only; property-based tests targeting **FailureState + goal-admission contracts in gsd-orchestrator core** (C2 as specified — M2 fix); cas-contracts schema round-trips are an explicitly-marked stretch item, not the deliverable | Both suites healthy from clean clone; mutation baseline recorded + ratcheted; property tests exercise FailureState + goal-admission invariants |
| 47 v1.6 Audit | Full verifier stack + audit + archive; LEARNINGS hard-gate | audit `passed` |

## v1.7 — Product & Scale (phases 48–51, two gates)

| Phase | Scope | Gate |
|---|---|---|
| 48 Product Bundle | Full "CAS Workstation" release bundle on top of 43's bootstrap (versioned, documented, community files org-wide) | 43 complete |
| 49 Marketing Live | Phase 37 strategy executed (showcase site, story pages, LinkedIn drafts, demo assets) | **Operator answers the brand question (amendment 6) YES** |
| 50 Disaster Drill | Full restore drill from remotes only with measured RTO, building on 43+48 | 43 AND 48 complete (M3 fix) |
| 51 Cloud Readiness | Bicep deploy rehearsal, cost guardrails, identity plumbing | **Operator lifts the NO-AZURE deploy lock** |

## Deferred (named, with triggers)

- **SLSA-lite provenance + SBOM** — trigger: first external consumer of a CAS release artifact.
- **Kubernetes/liveness (old REQ-1.4.6)** — trigger: multi-machine milestone.
- **Cross-machine distributed scheduling** — trigger: operator adds a second machine.

## Standing rules (unchanged from v1, plus)

- Every failure class found in execution becomes a sweep/CI check the same week — **now including the three-times-hit SHA-reachability class (A1) as the proof case.**
- Convergence definition: all planned milestones audited `passed`, backlog above Low empty, learning loop closing ≥ opening per cycle — now with an owner and cadence (45/A8).
