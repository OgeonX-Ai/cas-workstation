# vNEXT-SEEDS.md v3 - Closed-Loop Round 3 Critique

Date: 2026-07-12
Target: .planning/milestones/vNEXT-SEEDS.md v3 (amended 2026-07-11/12, closed-loop round 2 fixes)
Method: (1) Per-finding fix verification for M1-M4 against SEEDS-CRITIQUE-R2.md fix_hints,
with live file/grep checks where a fix's grounding could be independently confirmed.
(2) Fresh full re-read of v3 end-to-end with adversarial stance (assume flawed until proven
otherwise) looking for internal self-contradictions the M1-M4 edits may have introduced.
(3) ROADMAP.md re-sync check. (4) Live grep confirmation of gsd-orchestrator source files
cited by M2's fix.

Verdict: NOT-CONVERGED - 1 material finding (F1), carried forward from the M2 fix leaving
stale narrative text elsewhere in the same document.

---

## Per-M fix verdicts

### M1 - A1/A2 seated in phase table -> FIXED

Phase 43 row (v3 line 27) now explicitly contains both items with falsifiers:
- A1 SHA-reachability gate built into workflow-lint + sweep (the thrice-hit failure
  class - M1 fix)
- A2 multi-AI coordination lease convention in GLOBAL_AGENTS.md + sweep check (M1 fix)

Falsifier column matches: "lint red-fixture proves an unreachable-SHA uses: is caught;
lease check flags a second writer on a claimed tree." This is a genuine phase-table anchor
with a testable falsifier, not a relabeled prose mention. Real fix, not cosmetic.

Minor observation (not counted as material - see Trivial section): the preamble
(amendment 7) still frames A1/A2/A7 as "the first v1.6 quick-batch" as one group, but A7
lives in Phase 44 while A1/A2 live in Phase 43. Loose phrasing, not a scope error - Phase 43
still precedes 44, so "early" is still true.

### M2 - Phase 46 property-test scope restored to C2's literal target -> FIXED (table),
### but see F1 (fresh finding) for a residual internal contradiction

Phase 46 row (v3 line 30) now reads: "property-based tests targeting FailureState +
goal-admission contracts in gsd-orchestrator core (C2 as specified - M2 fix); cas-contracts
schema round-trips are an explicitly-marked stretch item, not the deliverable." Falsifier:
"property tests exercise FailureState + goal-admission invariants" (cas-contracts is
correctly absent from the falsifier, consistent with "stretch item, not deliverable").

Live-verified: portfolio/gsd-orchestrator/src/GsdOrchestrator/Loop/FailureState.cs and
portfolio/gsd-orchestrator/src/GsdOrchestrator/Scheduling/GoalDecisionPolicy.cs /
GoalControlPlane.cs all exist (confirmed via filesystem search). No literal "Admission"
class/method exists (grep on GoalDecisionPolicy.cs for "admission" returned no matches) -
"goal-admission" remains a descriptive paraphrase of GoalDecisionPolicy/GoalControlPlane,
exactly as R2's own fix_hint anticipated ("goal-admission decision logic"). This is the same
level of grounding R2 accepted when writing the fix_hint, so not a new gap.

The phase-table row itself is a real fix: it restores gsd-orchestrator as the target,
demotes cas-contracts to an explicit non-deliverable stretch item, and gives a falsifier that
matches. However, the fix was only applied to the Phase 46 table row - the "Amendments
from round 1" preamble (amendment 4, line 13) was not updated and still asserts the pre-fix,
M2-defective scope. See F1 below; this is why M2's fix is real but incomplete at the
document level.

### M3 - Phase 50 gate includes 48 -> FIXED

Line 39: "50 Disaster Drill | ... building on 43+48 | 43 AND 48 complete (M3 fix)". Gate now
matches the scope text's stated dependency verbatim. Real fix.

### M4 - ROADMAP.md synced to v3 phase scopes -> FIXED

ROADMAP.md line 28 (re-read live) now leads with Continuity First and correctly drops the
pre-R1 "signed commits/SLSA-lite/SBOM first" framing M4 flagged: "v1.6 Continuity &
Self-Measurement - Phases 43-47 (reseeded v3, 2026-07-11): Continuity First
(bootstrap+backup+incident runbook+SHA-gate+AI-lease), Identity & Access (PAT rotation, SSH
signing, model-policy gate; secret scanning verified already-on), Self-Measurement (traces
schema v2 THEN DORA/token dashboard + spend caps), Test Depth (suite-health fix THEN narrowed
mutation + FailureState property tests), audit. SLSA/SBOM deferred with trigger." Line 29
(v1.7) is likewise phase-accurate (product bundle/marketing live/disaster drill/cloud
readiness gates all match the v3 phase table). Real fix.

Minor completeness gap (not counted as material - see Trivial): ROADMAP's one-liner for
Phase 46 says "FailureState property tests," dropping "goal-admission" from the full v3
phrase "FailureState + goal-admission contracts." Since ROADMAP is explicitly a compressed
summary that links to the full seeds doc for detail (and every other phase entry on that
line is similarly compressed, e.g. "narrowed mutation"), this reads as brevity rather than a
scope contradiction - no false statement is made, just an incomplete one. Flagged as trivial,
not material, per the instruction not to manufacture findings from ordinary summarization.
STATE.md's "Operator Next Steps" staleness (still referencing v1.5's new-milestone step) was
explicitly scoped out by R2 as "adjacent, not required for M4" and remains unchanged in v3 -
consistent with R2's own scoping, not a new drop.

---

## Fresh findings (Round 3)

### F1 - Amendments preamble (amendment 4) still states the pre-M2-fix, defective Phase 46
### scope, contradicting the now-corrected Phase 46 table row [WARNING]

Grepped v3 for every occurrence of the C2/cas-contracts/goal-admission scope description:
exactly two hits.

1. Preamble, "Amendments from round 1" section, item 4 (line 13): "...a suite-health fix
   task gates mutation work; mutation scope narrowed to orchestrator core + cas-contracts
   property tests only (C2)."
2. Phase 46 table row (line 30): "...property-based tests targeting FailureState +
   goal-admission contracts in gsd-orchestrator core (C2 as specified - M2 fix); cas-contracts
   schema round-trips are an explicitly-marked stretch item, not the deliverable."

These two statements directly disagree about what C2 requires and what Phase 46 delivers:
the preamble says cas-contracts property tests ARE the target ("only"); the table row says
they are explicitly NOT the deliverable, and the real target is FailureState +
goal-admission in gsd-orchestrator. This is the exact scope dispute M2 was raised to resolve
- it has been fixed in the operative phase-table cell but the document's own "what changed
and why" narrative was left asserting the opposite. Since the preamble is titled "what
changed and why" and presented as the authoritative changelog for the phase-table content, a
reader relying on it (rather than drilling into the table row's inline correction) would
reconstruct the same wrong Phase 46 scope M2 identified in v2 - i.e. this is a live path back
to the original defect, just relocated.

This is scored WARNING rather than BLOCKER because the phase table - the section headed
"Phase | Scope | Requirement seeds (falsifiable)" that is the actual planning input - is
correct and carries an explicit "(M2 fix)" marker disambiguating it from the stale preamble.
A planner reading the full document, not just the preamble, gets the right scope. But the
self-contradiction is real, grounded in two directly-quotable lines of the same file, and
should be closed before this converges cleanly - an unresolved internal contradiction is
exactly the kind of drift this loop exists to catch, even when the load-bearing cell is
correct.

issue:
  dimension: internal_consistency
  severity: warning
  file: .planning/milestones/vNEXT-SEEDS.md
  description: Amendment 4 (preamble, line 13) still says Phase 46 property tests target
    "cas-contracts property tests only (C2)", directly contradicting the corrected Phase 46
    table row (line 30) which restores FailureState + goal-admission in gsd-orchestrator and
    demotes cas-contracts to a non-deliverable stretch item.
  fix_hint: Edit amendment 4 to read - mutation scope narrowed to orchestrator core
    (Loop/StateMachine); property-based tests target FailureState + goal-admission contracts
    in gsd-orchestrator core, with cas-contracts schema round-trips as an explicitly-marked
    stretch item, not the deliverable (C2, corrected per M2/R2 - see Phase 46 row).

No other fresh material findings were found. Specifically checked and cleared with fresh
eyes:
- Phase 51 Azure gate vs CLAUDE.md's standing NO-AZURE HARD LOCK: consistent, no drift.
- Phase 48/49/50 gate chain (43 / operator-brand-question / 43+48): internally consistent,
  no cross-phase ordering defect beyond the now-fixed M3.
- Amendments 1, 2, 3, 5, 6 each individually cross-checked against their corresponding
  phase-table cells: all match (Continuity First -> Phase 43; secret-scanning rescope ->
  Phase 44; traces-schema precondition -> Phase 45; SLSA/SBOM cut -> Deferred section;
  operator brand question -> Phase 49 gate). No further preamble/table mismatches found
  beyond F1.
- Phase 43's now-larger scope (bootstrap + backup + runbook + A6 gemini-nano decision + A1 +
  A2) was considered for a scope-sanity flag, but vNEXT-SEEDS.md is a pre-planning seed
  document, not a PLAN.md - /gsd:plan-phase will decompose this into multiple plans at
  execution time. Seed-level scope density does not itself change what gets built or its
  order, so this is not flagged as material.

---

## Trivial (non-material, not blocking)

- Amendment 7's "schedule as the first v1.6 quick-batch" phrasing groups A1/A2/A7 as one
  batch, but the phase table splits them across Phase 43 (A1/A2) and Phase 44 (A7). Loose
  wording, not a scope defect - Phase 43 still precedes 44. Optional cleanup: reword to
  "schedule early in v1.6, split across Phases 43-44."
- ROADMAP.md's Phase 46 one-liner ("FailureState property tests") omits "goal-admission"
  present in the full v3 phrase. Brevity, not contradiction - the linked seeds doc has the
  complete, correct text. Optional cleanup for completeness.
- Phase 45's scope column still lists A8/A9 without a paired falsifier in the same cell
  (carried over from R2's Trivial list, unchanged in v3 - not re-raised as material,
  consistent with R2's own scoping).
- STATE.md's "Operator Next Steps" still references the v1.5 /gsd:new-milestone step;
  R2 explicitly scoped this out of M4 as "adjacent," and it remains unchanged in v3.
  Carried forward as a standing housekeeping item, not new.

## Recommendation

Fix F1 with a one-line edit to amendment 4 (no new research needed - the correction is
already fully specified in the Phase 46 table row itself, just needs to be echoed into the
preamble). Given the fix is mechanical and localized to a single paragraph, round 4 should
converge on a clean pass.
