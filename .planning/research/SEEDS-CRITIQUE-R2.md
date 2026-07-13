# vNEXT-SEEDS.md v2 - Closed-Loop Round 2 Critique

Date: 2026-07-12
Target: .planning/milestones/vNEXT-SEEDS.md v2 (amended 2026-07-11 by round 1)
Method: (1) R1-incorporation audit - every ADD/CUT/RESEQUENCE (16) and every fact-check
STALE/WRONG row (12) checked for presence in v2, with live grounding for anything in doubt.
(2) Internal consistency pass on v2 own gates/falsifiers. (3) Bounded fresh-holes search,
grounded only where a live file check confirms it. (4) ROADMAP.md drift check.

Verdict: NOT-CONVERGED - 4 material findings.


## Material findings

### M1 - A1 and A2 (the two highest-priority ADD items) are declared but never seated in a phase-table row [BLOCKER-equivalent]

v2's section "NEW standing guardrails (A1/A2/A7)" says all three "schedule as the first v1.6
quick-batch, they are small." Checking the actual phase table (43-47) scope columns:

- A7 (model-policy PR gate) - explicitly present in Phase 44's scope: "model-policy PR
  gate (A7)". Seated.
- A1 (SHA-reachability gate - R1's own "single most important finding," hit 3 times
  in production, [CRITICAL]) - absent from every phase row (43/44/45/46/47). Only
  exists as prose in the preamble.
- A2 (multi-AI coordination lease) - also absent from every phase row.

This is the exact failure mode A7's own rationale warns about ("today they drift as dirty
files" for unreviewed policy) - a prose intention with no phase-table anchor is precisely
what gets lost when /gsd:plan-phase reads phase scope columns to decide what to build.
Two of nine ADD items - including the one R1 called the single most defensible, most
critical gap in the whole red-team - have no phase assigned. This changes what gets built:
as written, nothing currently commits A1/A2 to being executed in v1.6 at all.

Fix: add explicit phase-table cells for A1 and A2 (e.g., fold into Phase 43 or 44's
scope column, or add a stated "Phase 43.5 quick-batch" line item with a falsifier), not just
the amendments preamble.

### M2 - Phase 46's property-based-testing scope silently reverted C2's narrowing, citing C2 while doing something different [BLOCKER-equivalent]

Red-team C2 (cited inline in v2 Phase 46 row) explicitly narrowed property-based testing to
"only FailureState + goal-admission schemas" in gsd-orchestrator, specifically to avoid
"breadth-theater" of testing every published schema.

v2 Phase 46 instead reads: "property-based tests for cas-contracts schemas only" with
falsifier "property tests round-trip every published schema."

Live-checked cas-contracts/schemas/v1.1/ (latest version): 6 published JSON schemas -
common, phase-execution-request, phase-execution-result, phase-verification-result,
sdlc-lifecycle-event, sdlc-profile. None is named FailureState or goal-admission.
Those are gsd-orchestrator's own internal C# types (src/GsdOrchestrator/Loop/FailureState.cs
confirmed to exist; no GoalAdmission class exists - the closest analog is
Scheduling/GoalDecisionPolicy.cs / GoalControlPlane.cs, also internal to gsd-orchestrator,
not cas-contracts).

So v2 did not just relabel C2's scope - it relocated the entire testing target from
gsd-orchestrator's internal domain-invariant logic (2 specific modules) to cas-contracts's
externally-published wire-format schemas (6+ schemas, "every published schema" being the
exact breadth-theater phrase C2 rejected), in a different repo, on a different artifact type,
using presumably different tooling. This is a scope reduction dressed as compliance: the
"(C2)" citation implies C2's narrowing was honored; it was not. This changes what gets built
and its falsifier.

Fix: either restore C2's literal scope (property-test FailureState + goal-admission
decision logic inside gsd-orchestrator) and separately decide whether cas-contracts schema
round-trip tests are a different, additional, explicitly-scoped item - or explicitly amend
C2 with a stated reason for the relocation (not currently present anywhere in v2).

### M3 - Phase 50's gate omits its own stated dependency on Phase 48 [WARNING, borderline BLOCKER]

Phase 50 row: scope = "Full restore drill from remotes only with measured RTO, building on
43+48"; Gate = "43 complete" only. The gate silently drops the 48 dependency the scope
text itself asserts. If phase gating is later encoded literally (as depends_on in a
ROADMAP/plan the way v1.5's phases were), Phase 50 could be sequenced/started once only 43 is
done, before the product bundle it is meant to drill-restore (48) exists - an order-changing
defect exactly of the kind this check is scoped to catch.

Fix: Gate should read "43 + 48 complete."

### M4 - ROADMAP.md's v1.6/v1.7 summary lines still describe the pre-round-1 (v1) seed scope, contradicting v2's amendments [WARNING]

.planning/ROADMAP.md lines 28-29 (last touched 2026-07-09, before both R1 passes):

  "v1.6 Trust Depth & Self-Measurement - Phases 43-47: signed commits/SLSA-lite/SBOM,
  secret-scanning + token rotation, DORA + token-economics dashboard from traces.jsonl,
  mutation + property-based testing, audit."

This directly contradicts v2 amendment 5 (C1: SLSA-lite/SBOM explicitly CUT/DEFERRED,
not shipped in v1.6) and omits the single biggest structural change from round 1 - Continuity
First (bootstrap/backup/runbook) now resequenced to the front of v1.6 as Phase 43, ahead
of signing/secrets. A reader or planner using ROADMAP.md's one-line summary instead of the
full seeds doc would scope Phase 43 as signing/SLSA/SBOM work, not continuity - the opposite
of what round 1 decided. .planning/STATE.md's "Operator Next Steps" is independently
confirmed stale in the same way (still says "/gsd:new-milestone - v1.5..." despite v1.5 being
audited through Phase 42 with a gaps_found verdict and a 6-step operator checklist) -
consistent with a pattern of root tracking docs not being refreshed after planning docs
change underneath them.

Fix: sync ROADMAP.md's future-milestones bullet to v2's actual phase scopes (Continuity
First / Identity & Access / Self-Measurement / Test Depth-narrowed / Audit), and flag
STATE.md's Operator Next Steps for a similar refresh (out of this document's direct scope but
adjacent).

## R1-incorporation audit (dimension 1) - summary

Of fact-check R1's 3 WRONG + 9 STALE rows and the red-team's 16 material findings:

- Correctly incorporated (14/16 red-team items): A3, A4, A5, A6, A7, A8, A9, C1, C3, R1,
  R2, and fact-check rows 2/3 (signing), 4 (secrets rescope), 5 (DORA precondition), 7 (suite
  health precondition) - all traced to explicit v2 phase-table text or the amendments list.
- Declared but not seated (A1, A2) - see M1.
- Cited but not delivered as specified (C2) - see M2.
- Out of v2's scope, correctly not required here: fact-check rows about v1.5-specific
  status (1, 8, 9, 10, 14, 16, 17, 18) and Phase-37-sequencing (11) - these belong to v1.5
  closeout / a phase that predates the v1.6 numbering, not to the v1.6-v1.7 seed content.
  Not flagged as drops.

No other silent drops found.

## Checked and cleared (no issue found - listed to show the loop is not being rubber-stamped)

- 45's spend-cap vs instrumentation ordering: initially looked like a hidden precondition
  gap (spend-cap hard-stop falsifier needs real-time spend data, same as the traces.jsonl
  instrumentation work). Live-checked Scheduling/GoalControlPlane.cs: a BudgetReservations
  field already exists, confirming A3's own premise ("verify-and-enforce, not net-new
  architecture") - spend caps can plausibly build on existing control-plane state independent
  of the traces.jsonl schema work. No material ordering defect.
- 46's "Loop/StateMachine core" mutation-testing scope vs C2's "lease/stop-rule/budget
  core": different names, same target - grep-confirmed budget/spend/cap references
  live in both Loop/FailureState.cs and Workflows/GsdStateMachine.cs. Defensible rename,
  not a scope reduction (unlike the property-test side, M2).
- Phase 51 Azure gate ("Operator lifts the NO-AZURE deploy lock") is consistent with the
  standing HARD LOCK on Azure deploy/provisioning. No drift.
- Falsifiers for 43/44 are concretely testable (timed rehearsal, git verify-commit,
  canary secret). No issue.

## Trivial (non-material, not blocking)

- Phase 45's scope column lists A8 (convergence-metric owner+cadence) and A9 (retention
  policy) without a paired falsifier in the same cell (only DORA-dashboard and spend-cap are
  covered by the stated falsifier). Likely fine to leave for PLAN.md-time must_haves - flagged
  only for completeness, not blocking.

## Recommendation

Fix M1-M3 in the seeds text (concrete, cheap edits - no new research needed); sync M4 into
ROADMAP.md. Re-run round 2 verification after the edit; if these four are the only findings
and the fixes are mechanical, round 3 should converge.
