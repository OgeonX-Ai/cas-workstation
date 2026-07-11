<!-- Canonical template referenced by /gsd:extract-learnings and by
     engineering-os/OPERATING-CONTRACT.md's Phase-Close Learning Extraction checklist. -->

---
phase: 41
phase_name: "Learning Loop"
project: "cas-workstation (PersonalRepo)"
generated: "2026-07-11"
counts:
  decisions: 4
  lessons: 4
  patterns: 2
  surprises: 2
missing_artifacts:
  - "41-01-SUMMARY.md at time of writing lived only on branch origin/docs/phase-41-learning-loop (PR cas-workstation#12), not yet merged to origin/master"
  - "41-02-SUMMARY.md does not exist anywhere in git history as of this writing, despite 41-02's own PR (#15, feat/phase-41-backlog-survey) having merged to origin/master (commit fec174d) — see Surprises"
---

# Phase 41 Learnings: Learning Loop

## Decisions

### The learning-loop hard-gate is deliberately self-referential
Phase 41 institutionalized the phase-close learning-extraction requirement (REQ-1.5.6, plus a new
"Phase-Close Learning Extraction" checklist in `engineering-os/OPERATING-CONTRACT.md`) and, per its
own new rule, is subject to that same rule at its own close — `41-01-SUMMARY.md` explicitly states
"Phase 42's audit will need every LEARNINGS-PENDING.md marker (38, 39, 40, 41) replaced by a real
{N}-LEARNINGS.md ... including this very phase (41) once 41-02-SUMMARY.md also exists."

**Rationale:** A learning-extraction mandate that exempted the phase which introduced it would be
self-undermining; making Phase 41 the hardest test case of its own policy was intentional.
**Source:** 41-01-SUMMARY.md ("Next Phase Readiness"); LEARNINGS-PENDING.md (41-learning-loop copy)

### Retroactive v1.4-LEARNINGS.md items were extracted with mandatory Source: attribution, verified by an automated grep-based existence check
Every one of the ~40 items in the retroactively-written `v1.4-LEARNINGS.md` carries a `**Source:**`
line to a real artifact, and the file was verified via an automated grep-based check confirming
every cited source path actually exists — zero missing paths returned.

**Rationale:** A learnings file with fabricated or unverifiable source citations would be worse
than no learnings file at all (false confidence). This same discipline is why this document (the
41-LEARNINGS.md you are reading) also cites a `Source:` line for every item.
**Source:** 41-01-SUMMARY.md ("Accomplishments", "Decisions Made")

### Cross-Phase Patterns narrowed strictly to the milestone's own explicit "recurring" statements, not synthesized from phase-local observations
When writing `v1.4-LEARNINGS.md`, a genuinely recurring pattern noticed across multiple individual
phases' own summaries (e.g., the SHA-pin-staleness pattern recurring across Phase 31's own
31-02/31-03/31-04/31-05 plans) was deliberately **not** promoted to the milestone-level
"Cross-Phase Patterns" section, because `v1.4-ROADMAP.md`'s own "Milestone Summary" did not itself
name it as a cross-phase recurring theme — it was recorded within Phase 31's own local Patterns
subsection instead.

**Rationale:** Avoids the learnings author inflating their own pattern-recognition into
milestone-level claims the source material doesn't actually assert at that level — keeps
"Cross-Phase Patterns" strictly traceable to the roadmap's own stated summary, not editorial
synthesis.
**Source:** 41-01-SUMMARY.md ("Decisions Made")

### Promptimprover pattern-ingestion (Task 3, stretch) deliberately deferred rather than hastily wired
Investigated Promptimprover's `ingest_pattern` MCP tool (a genuine write-path, distinct from the
read-only `obsidian` MCP) as a candidate to auto-ingest `v1.4-LEARNINGS.md`'s ~40 items, but
declined to wire it: `ingest_pattern`'s schema accepts exactly one pattern per call, so faithful
ingestion would require a batch-transformation script, a collision-free ID-namespacing scheme, and
partial-failure error handling — real design work exceeding the plan's explicit "small script or
hook, no architectural change" bound.

**Rationale:** Wiring it hastily risked writing malformed or duplicate entries into
Promptimprover's persistent memory store — a worse outcome than deferring to a dedicated future
plan with its own review.
**Source:** 41-01-SUMMARY.md ("Deferred: Promptimprover ingestion")

---

## Lessons

### A merged PR is not the same as a closed plan — 41-02 merged its deliverable but never produced a SUMMARY.md
`feat(41-02): repeatable backlog-survey script + baseline evidence (#15)` (commit `fec174d`)
merged `scripts/backlog-survey.ps1`, `tests/BacklogSurvey.Tests.ps1`, and the baseline evidence
snapshot/report to `origin/master` — the plan's actual deliverable is real, tested, and live. But
no `41-02-SUMMARY.md` was ever committed anywhere (confirmed absent via
`git log --all --diff-filter=A -- "*41-02-SUMMARY*"` returning nothing, and absent from every
branch's tree). Per `extract-learnings.md`'s own `critical_rules`, learnings extraction requires
both PLAN.md and SUMMARY.md to exist — so 41-02's own learnings could not be extracted from a
SUMMARY.md the normal way; this document's 41-02-derived content instead had to be reconstructed
directly from the merged commit's message body and the delta-report artifact itself.

**Context:** This is the exact failure mode Phase 41's own hard-gate exists to catch — a plan can
"complete" (code merged, tests green, evidence committed) while skipping the SUMMARY.md write-up
step, silently degrading the traceability that later phases (and this very learnings-extraction
task) depend on.
**Source:** git history (`fec174d`, `be1e539`, `4d3cf2c` on origin/master); absence confirmed via `git log --all` search; 41-01-SUMMARY.md's own explicit warning that 41's hard-gate requires "41-02-SUMMARY.md also exists"

### STATE.md's progress counters can regress when isolated-worktree plans compute progress against a stale fetched baseline
Comparing `.planning/STATE.md`'s `progress:` block across commits shows a real regression: an
earlier state showed `total_phases: 25, completed_phases: 20` (80%), and a later v1.5-era commit
(`96e75e9`, 39-01's completion) shows the same fields as `total_phases: 30, completed_phases: 18`
(60%) — both phase-completion counters and the overall milestone framing (`stopped_at` text)
regressed rather than monotonically advancing, because different isolated-worktree plans each
recomputed `state.update-progress` against whatever `origin/master` baseline they had fetched at
worktree-creation time, and those baselines diverged across parallel agents working the same
session.

**Context:** This is a structural side effect of the isolated-worktree-per-plan execution pattern
this whole v1.5 milestone relies on (see Patterns, all four phases): each worktree's `state
update-progress` call is only as fresh as its own fetch, and concurrent agents on different
worktrees do not see each other's STATE.md writes until a rebase/merge reconciles them. No single
plan's SUMMARY.md flags this by name — it is only visible by diffing STATE.md across commits.
**Source:** `git show 96e75e9 -- .planning/STATE.md` (diff observed directly in this session); `.planning/STATE.md` current content (gsd_state_version: 1.0, stale phase-25/20-era progress numbers still present in the working tree at the time of this writing)

### A phase can be "VERIFIED (mechanism/tooling)" and still fail its own requirement's falsifier
Phase 42's pre-verification rated Phase 41 as "VERIFIED (mechanism/tooling) + GAP (REQ-1.5.6's
actual falsifier: no real `{N}-LEARNINGS.md` exists yet for 38-41)" — the template, the
OPERATING-CONTRACT.md hook, and the retroactive v1.4-LEARNINGS.md were all real and correct, but
the requirement's own falsifier (a real LEARNINGS.md per phase 38-41) was not yet met by anything
built in Phase 41 itself, precisely because that requires phases 38-41 to actually close first —
a dependency Phase 41 could institutionalize but not itself satisfy.

**Context:** Building the mechanism that enforces a requirement is necessary but not sufficient
for satisfying that requirement — the mechanism still has to actually run and produce its real
output (which is what this very task, and this very file, is doing).
**Source:** 42-PREVERIFICATION.md ("Per-Phase Verdicts" table, "Phase 41 — Learning Loop" section)

### Extracting learnings for a still-open-PR phase means citing branch/PR locations honestly, not pretending the artifact lives on `master`
41-01's own SUMMARY.md (PR #12) was still unmerged at the time this document was written, as were
38's, 39's (partially), and 40's SUMMARY.md files — each living on a different feature/docs
branch. Writing accurate `Source:` citations required tracking not just "which SUMMARY.md" but
"on which branch / PR," since `git show <branch>:<path>` was required to read several of them at
all (they do not exist on `origin/master`'s tree).

**Context:** A learnings-extraction task spanning multiple still-open, still-diverged branches
must be explicit in its `missing_artifacts` frontmatter about exactly this — which is why this
file (and its three siblings) each declare their source branches in `missing_artifacts`.
**Source:** Direct observation during this task's own execution (git ls-tree comparisons across origin/master and each feature/docs branch)

---

## Patterns

### Isolated worktree from freshly-fetched origin/master, branch + PR flow — never touch the foreign primary checkout
41-01 worked entirely from `worktrees/phase-41-learning-loop` branched off a freshly-fetched
`origin/master`, since the primary checkout was on an unrelated foreign branch
(`docs/phase-38-plan-fixes`) with foreign dirty files that must never be touched. This is the same
pattern used by every plan across Phases 38, 39, and 40.

**When to use:** Any autonomous plan execution in this repo where the primary checkout's current
branch/dirty-state cannot be assumed to match the plan's needs — which, empirically, has been
every single phase-38-through-41 plan in this milestone.
**Source:** 41-01-SUMMARY.md (key-decisions, tech-stack patterns)

### Retroactive learnings extraction requires reading the actual source artifact, never paraphrasing from memory or a summary-of-a-summary
Before writing any `v1.4-LEARNINGS.md` item, all 21 SUMMARY/VERIFICATION/TRAIN-REPORT artifacts
across the 11 v1.4 phases were read directly, and every extracted claim was traced back to the
specific artifact it came from — no item paraphrases a claim not actually present in a source
file, enforced by the automated grep-based existence check on every `Source:` citation.

**When to use:** Any learnings-extraction task (including this one, and any future
`/gsd:extract-learnings` run) — the discipline is directly reusable as the standing methodology
for this command.
**Source:** 41-01-SUMMARY.md ("Decisions Made")

---

## Surprises

### The self-referential hard-gate meant Phase 41 could not close itself — and 41-02 quietly never got a SUMMARY.md at all
Phase 41 wrote the rule that a phase isn't closed/auditable until its LEARNINGS.md exists, then
immediately became the phase most exposed to that rule's teeth: not because its mechanism was
wrong, but because its own second plan (41-02) shipped real, merged, tested code and evidence
while skipping the SUMMARY.md write-up entirely — a gap that would have gone unnoticed
indefinitely if Phase 42's hard-gate hadn't forced an explicit search for `41-02-SUMMARY.md` and
come up empty. The rule Phase 41 introduced is precisely what caught Phase 41's own process gap.

**Impact:** This is the single clearest piece of evidence in this entire audit that the
learning-extraction hard-gate does real work rather than being ceremonial — it surfaced a genuine,
previously-invisible process gap in the very phase that created it.
**Source:** git history search for `41-02-SUMMARY.md` (absent everywhere); 41-01-SUMMARY.md's own anticipation of this exact requirement

### STATE.md's format stayed schema-valid (`gsd_state_version: 1.0` never changed) while its content quietly regressed underneath that stable schema
The state file's YAML frontmatter shape and version tag remained constant across the session, but
the *values* within that stable schema (phase/plan progress counters, `stopped_at` narrative)
diverged and regressed across parallel isolated-worktree writes (see Lessons, above) — a subtler
and more dangerous class of inconsistency than an outright schema/format break, because nothing
in the file's own structure signals that anything is wrong; only a cross-commit diff reveals it.

**Impact:** Schema validation alone (confirming `gsd_state_version` parses and required fields are
present) is insufficient to catch this class of drift. Detecting it requires either a monotonicity
check on progress counters across commits, or a single-writer discipline for STATE.md updates
(neither of which existed as of this session) — a candidate follow-up for a future phase's
tooling backlog.
**Source:** `git show 96e75e9 -- .planning/STATE.md` (diff observed directly in this session)
