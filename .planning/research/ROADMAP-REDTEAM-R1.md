# CAS Forward-Plan Red-Team — Round 1

**Date:** 2026-07-12
**Target:** vNEXT-SEEDS.md (v1.5 in-flight, v1.6 Trust & Self-Measurement, v1.7 Product & Scale + phase 51 locked)
**Stance:** Devil's-advocate. Question — what makes a top-tier eng leader say "you're missing X" or "Y is theater"?
**Method:** Attack the seeds against (a) the portfolio's OWN recurring failure classes (phases 38–41 LEARNINGS, v1.4 incidents) and (b) elite-org expectations, weighted for a *solo-operator, single-Windows-box* reality — not a 50-engineer org that can afford ceremony.

**Grounding — the empirical spine.** Four failure classes recur across the last two milestones and are the strongest "missing X" evidence, because they are the plan's own execution telling you where it breaks:
1. **Squash-merge SHA stranding** — broke release-please *live in production for all 13 repos* (39-LEARNINGS), orphaned a reusable-workflow pin SHA (38-LEARNINGS), and is the same reachability class as v1.4's three stranded-work incidents. `[VERIFIED: git show origin/docs/phase-42-learnings]`
2. **Isolated-worktree state divergence** — STATE.md silently regressed under a stable schema; no single-writer discipline; parallel worktrees don't see each other (41-LEARNINGS). `[VERIFIED: 41-LEARNINGS.md]`
3. **PowerShell 5.1 / single-shell fragility** — quote marshalling corrupted issue dedupe, stderr promoted to terminating errors, encoding hazards (40-LEARNINGS + v1.4). `[VERIFIED: 40-LEARNINGS.md]`
4. **"Done ≠ requirement met, merged ≠ closed"** — a phase reported VERIFIED while its falsifier failed; 41-02 merged its deliverable with no SUMMARY.md (41-LEARNINGS). `[VERIFIED: 41-LEARNINGS.md]`

---

## ADD — missing, with proposed home

### A1 — Mechanize the SHA-reachability / squash-merge gate as an org-wide CI check `[CRITICAL]`
**Home:** v1.5 close (fold into 38/39 residuals) or first check of v1.6.
The pin rule from 39-LEARNINGS ("never pin to a PR branch-tip SHA; re-verify after every squash-merge") exists as *prose*, not as a *running check* — yet this exact class broke production twice and matches v1.4's stranded-work incidents. The plan's own standing rule says "every new failure class becomes a sweep/CI check the same week"; this is the one class that has earned that treatment three times and still hasn't gotten it. This is the single most defensible gap: the system keeps stepping on it.

### A2 — Multi-AI session lease/lock protocol (single-writer STATE discipline)
**Home:** v1.5, ahead of merge-flow scale-up (new phase 40.5, or fold into 38).
Three AI systems (Claude, Codex, Gemini) plus detached worktrees share one workspace on *conventions only* — and STATE.md already regressed silently because worktrees compute progress against stale baselines with no single writer (41-LEARNINGS). Today `parallelization: 1` in config masks this; the entire v1.6 thesis is to *increase* flow/concurrency, which will unmask it. A lightweight lease file + monotonicity check on STATE counters is cheap insurance the plan is about to need. The recurring "ecosystem-sync PR" pattern is drift this would bound.

### A3 — Spend CAPS, not just spend measurement
**Home:** v1.6 phase 45 (alongside token-economics), but the enforcing stop-rule belongs in the orchestrator.
Phase 45 *measures* token economics; nothing in the seeds *limits* it. A budget you can only observe after the fact is a dashboard, not a control — and PROJECT.md claims the orchestrator already owns "budgets and stop rules," so this is verify-and-enforce, not net-new architecture. An elite reviewer will ask "what stops a runaway agent from burning $X overnight before the dashboard is even looked at?" Right now: nothing. Add a per-goal/per-phase hard spend ceiling that halts.

### A4 — Non-git state backup policy BEFORE more state accumulates (partial pull-forward of Phase 50)
**Home:** v1.5 close as a minimal backup step; full drill stays at 50.
The disaster drill (50) is the *last* unlocked phase, but phases 38–49 each add irreplaceable non-git residue: review-bot App credentials, Task Scheduler defs, dashboards, evidence trees, scoped PATs. Deferring backup to the capstone means twelve phases of un-backed-up state on one box. Back up the residue *before* you build on it — a snapshot/export policy is a prerequisite, not a finale. (See RESEQUENCE R2.)

### A5 — Incident-response / triage runbook (guardrails detect; who responds?)
**Home:** v1.6, near 44/45; or extend phase 40 (already auto-files issues).
The sweep, commit-integrity check, canary-secret block, and scheduled-pilot regression all *detect* — but the responder is a solo operator with no documented triage path. "A guardrail fired at 2am" needs a severity-routed runbook (auto-issue label → action owner → escalation/mute rule), or detection just produces unread issues. Elite orgs pair every detector with a documented response; the seeds have all detectors and zero response design.

### A6 — Adopt or quarantine gemini-nano (ungoverned repo in a governed portfolio)
**Home:** decide in v1.5; execute in v1.6 or archive now.
gemini-nano sits in the portfolio ("experimental demos, no shared build system") but no milestone owns it and none of the v1.4 gates (coverage, SHA-pinning, wikis, sweep) apply to it. An ungoverned repo inside a system whose entire pitch is "every repo is governed" is a live credibility and drift hole. Either assign it to a milestone with the standard gates, or explicitly mark it quarantined/archived so its ungoverned status is a *decision*, not an omission.

### A7 — Change-review gate on model-policy files
**Home:** v1.6 phase 44 (identity/secrets) — cheap add.
`engineering-os/models/*.json` and `engineering-os/router/ollama-policy.json` are tiny, unversioned config that silently governs *which model is allowed to make security/architecture/completion-final calls* (`forbiddenDecisions`). A one-line loosening of that policy is currently an unreviewed, unaudited change to a security boundary. Add CODEOWNERS + a diff-review requirement on these paths — highest-leverage-per-effort item in the whole red-team.

### A8 — Give the convergence terminal-condition a measurement owner + cadence + dashboard tile
**Home:** v1.6 phase 45 (fed by phase 41's backlog-survey job).
The seeds' own "nothing left to improve" is defined as "learning loop closes more findings per cycle than it opens" — but nothing *owns*, *measures*, or *displays* that ratio. An unmeasured terminal condition is unfalsifiable, which for a truthfulness-first system is self-contradictory. Make the open/closed convergence ratio a first-class tile on the 45 dashboard, sourced from the 41 survey delta, with a named cadence (per-milestone). This directly answers Attack Surface #4.

### A9 — Data-retention / rotation policy for traces.jsonl and evidence trees
**Home:** v1.6 phase 45 (it already consumes traces).
traces.jsonl is git-tracked and append-only (~8k lines, currently dirty in git status). Unbounded growth in git means repo bloat, slower clones (which hurts the very bootstrap/restore drills of 48/50), and eventual PII/secret-leakage surface as content accumulates. Add rotation to dated archives (or move the stream out of git into an evidence store). Cheap now, painful later.

---

## CUT — over-engineered for a solo, single-consumer portfolio

### C1 — Defer SLSA-lite provenance + CycloneDX SBOM (Phase 43); KEEP only signed commits
**Justification:** SLSA provenance and per-release SBOMs exist to let *external consumers* verify a supply chain they don't control. This portfolio has one operator and no external release consumers yet — so it's trust machinery for a party that doesn't exist. Signed commits/tags (real, cheap integrity value) and gitleaks (A/44) earn their place; SLSA+SBOM is ceremony until phase 49 marketing or genuine adoption creates a consumer who demands it. Defer to "first external adopter," not a calendar phase.

### C2 — Narrow mutation + property-based testing scope (Phase 46)
**Justification:** Mutation testing is slow and high-maintenance; "property tests for *every* published schema" is breadth-theater. The value is concentrated: mutation-test *only* the orchestrator's lease/stop-rule/budget core (where a wrong judgment is catastrophic and un-caught by coverage), and property-test *only* FailureState + goal-admission schemas. Cutting the "every schema" breadth removes most of the maintenance cost while keeping ~all of the risk reduction. Kill-rate ratchet on a narrow, high-value target beats a broad, ignored one.

### C3 — Defer Marketing Live production (Phase 49) unless external adoption is an explicit goal
**Justification:** A showcase site, LinkedIn drafts, and demo recordings are effort spent broadcasting a system with one user; they compete directly with trust-depth work. Keep the evidence-linked-claim discipline (it's good hygiene), but the *production* of marketing is polish for an audience that isn't defined. **Operator judgment flag:** if the real goal is personal-brand / employer signal, this is a legitimate KEEP — but then it should say so, because as written it reads as reflexive completeness, not a decision.

---

## RESEQUENCE

### R1 — Pull a minimal clean-machine bootstrap validation forward, ahead of trust-depth (43–47)
**Reasoning:** Attack Surface #3 is correct. Bootstrap (48) is the integration test for the entire system — "does all of this actually reconstitute?" Running it *after* adding signing, SBOMs, dashboards, and scheduled tasks means each of those ships un-bootstrap-tested. Move a *minimal* "fresh-clone → green sweep → green suites" bootstrap check to v1.5 close and make it a standing gate every later phase must keep green. The full product-polish of 48 (hardened setup.ps1, community files, timed VM evidence) can stay in v1.7.

### R2 — Pull non-git backup forward (expression of A4)
**Reasoning:** Same logic as R1/A4 — backup of the single box's non-git residue is a *prerequisite* to accumulating twelve phases of it, not a capstone drill. The full restore drill stays at 50; a snapshot/export policy moves to v1.5 close.

---

## KEEP-AS-IS (defended, to prove this isn't reflexive negativity)

### K1 — Merge queue + auto-merge for docs/dependabot first (Phase 38)
**Reasoning:** Directly targets the plan's own measured bottleneck — 40 PRs queued on one human. Correctly sequenced first, with a real credentialed second-reviewer identity (review-bot App) rather than fake-green auto-merge. This is the highest-value flow move and it's already in flight. Keep.

### K2 — v1.5 (flow) before v1.6 (trust-depth) milestone order
**Reasoning:** The seeds' own thesis is right: governance that queues gets bypassed. Fixing flow before deepening artifact trust is the correct order — you harden the pipe after the water is moving, not before. The resequencing findings above are *within* milestones, not across them. Keep the milestone order.

---

## Scorecard

| Verdict | Count |
|---|---|
| ADD | 9 |
| CUT | 3 |
| RESEQUENCE | 2 |
| KEEP-AS-IS | 2 |
| **Total material findings** | **16** |

**Confidence:** HIGH on the four recurring failure classes and A1/A2/A7 (grounded in committed LEARNINGS + config inspection). MEDIUM on the CUT calls (they depend on the operator's unstated adoption/brand goals — flagged where relevant).

**Single most important finding:** **A1 — mechanize the squash-merge SHA-reachability gate.** It is the one failure class the system's own execution has hit three times (38 pin, 39 live 13-repo production break, v1.4 stranded work), it violates the plan's own "make it a check the same week" standing rule, and it is un-seeded. Every other finding is about becoming *more* elite; this one is about stopping a known, recurring, production-breaking regression — and elite is not maximal, it's *not repeating your own incidents*.
