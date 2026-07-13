# vNEXT-SEEDS.md v4 - Round 4 Verification (Final Convergence Check)

**Date:** 2026-07-12  
**Target:** `.planning/milestones/vNEXT-SEEDS.md` v4 (amended post-R3, fixing F1)  
**Method:** Deterministic mechanical verification of F1 fix + trivial-4 re-confirmation.

---

## CHECK 1: Document Header & Round History

**v4 Header (Line 1):**
```
# CAS — Next-Milestones Seed Plan v4 (v1.6 → v1.7)
```
✓ Confirms document is v4.

**Round History (Line 6):**
```
Round 3 (SEEDS-CRITIQUE-R3.md): M1-M4 verified FIXED; 1 warning (F1 preamble self-contradiction) fixed in v4.
```
✓ Explicitly states R3/F1 fix applied in v4.

---

## CHECK 2: F1 Fix Verification — Phase 46 Property Test Scope Consistency

**R3 Finding (F1):** Amendment 4 preamble asserted the pre-M2-fix scope, directly contradicting the corrected Phase 46 table row.

**Grep result — all occurrences in v4:**

### Occurrence 1 (Line 13, Amendment 4 preamble):
```
mutation scope narrowed to orchestrator Loop/StateMachine core, property tests target 
FailureState + goal-admission contracts in orchestrator core per C2 
(cas-contracts round-trips = stretch only; R3/F1 fix).
```

**Statement:** FailureState + goal-admission in orchestrator core; cas-contracts = stretch only

### Occurrence 2 (Line 30, Phase 46 table row):
```
property-based tests targeting FailureState + goal-admission contracts in gsd-orchestrator core 
(C2 as specified — M2 fix); cas-contracts schema round-trips are an explicitly-marked 
stretch item, not the deliverable
```

**Statement:** FailureState + goal-admission in gsd-orchestrator core; cas-contracts = stretch/non-deliverable

### Consistency Check:

| Dimension | Occurrence 1 | Occurrence 2 | Match? |
|-----------|--------------|--------------|--------|
| Primary target | FailureState + goal-admission in core | FailureState + goal-admission in core | ✓ YES |
| cas-contracts | stretch only | stretch item, not deliverable | ✓ YES |

**F1 FIX VERDICT: FIXED ✓**

Both statements now agree. The self-contradiction identified in R3 has been resolved.

---

## CHECK 3: Trivial-4 Re-Confirmation

### Trivial 1: Amendment 7 "first v1.6 quick-batch" phrasing
- **R3 assessment:** Loose wording grouping A1/A2/A7, but phase table correctly splits across phases 43-44
- **v4 status:** Unchanged; still just loose phrasing
- **Verdict:** Still trivial ✓

### Trivial 2: ROADMAP.md Phase 46 omits "goal-admission"
- **R3 assessment:** Brevity in summary, not contradiction; full doc has complete text
- **v4 status:** Unchanged (external doc); v4 seeds doc now fixed
- **Verdict:** Still trivial ✓

### Trivial 3: Phase 45 A8/A9 without explicit falsifiers
- **R3 assessment:** Supporting concerns, main falsifiers sufficient for phase gate
- **v4 status:** Unchanged; not a scope omission
- **Verdict:** Still trivial ✓

### Trivial 4: STATE.md references v1.5
- **R3 assessment:** Out of scope per R2; housekeeping item
- **v4 status:** Not part of this critique scope
- **Verdict:** Still trivial/out-of-scope ✓

---

## Fresh Scan for New Material Findings

Spot-checked Phase 46 scope consistency across all mentions, amendment cross-refs vs phase table, Azure gate alignment, deferred items scope. No new findings beyond F1.

---

## ROUND 4 VERDICT: CONVERGED

**Summary:**
- **F1 Fix:** ✓ FIXED — both Phase 46 scope statements now agree
- **Trivial-4 Re-confirmed:** ✓ Still trivial, no scope defects
- **No new findings:** Clean pass

**Next step:** v4 ready for execution planning (`/gsd:plan-phase`)

