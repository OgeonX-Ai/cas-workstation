---
phase: 42-v1.5-audit
verified: 2026-07-11T14:00:00Z
status: gaps_found
score: 2/6 must+should-haves fully PASSED live; 4/6 PASSED-PENDING/PARTIAL (mechanisms verified, activation blocked on operator action); 1 NEW blocking finding
overrides_applied: 0
gaps:
  - truth: "REQ-1.5.3: every portfolio repo has a live SemVer tag with generated release notes matching git log, wired to run on merge"
    status: failed
    reason: >
      Live `workspace-health.ps1` sweep run in this session shows "no SemVer release tag
      exists" for all 13 portfolio repos (root included) — zero releases exist anywhere.
      The 13 pin-fix PRs correctly repoint the dead SHA but are all unmerged. NEW finding
      this session: `Coding-Autopilot-System/.github` has two open, mutually-exclusive PRs
      touching the same file (`release-please.yml`) — PR #18 (`fix(release): resolve
      reusable workflow reference`, author OgeonX-Ai, converts the call to a relative path
      `./.github/workflows/release-please-reusable.yml` and drops the `release-type` input)
      and PR #19 (the pin-fix, keeps the SHA-pin pattern, repoints it to `64c1673...`).
      Both are individually MERGEABLE against current main but represent competing fix
      strategies — merging both, or merging the wrong one first, will re-break or
      double-break the mechanism for all 12 dependent repos (their pin-fix PRs assume the
      SHA-pin pattern survives in `.github`). This requires an operator decision, not just
      a merge click.
    artifacts:
      - path: ".github/workflows/release-please.yml (Coding-Autopilot-System/.github)"
        issue: "Two open PRs (#18, #19) both modify this file with incompatible approaches"
      - path: ".github/workflows/release-please.yml (13 dependent repos' pin-fix PRs)"
        issue: "All 13 verified-correct but unmerged; zero effect until merged"
    missing:
      - "Operator decision: keep SHA-pin pattern (merge #19, close #18) or switch to relative-path pattern (merge #18, and re-derive/re-verify whether the 12 dependent repos' pin-fix PRs still apply cleanly against a relative-path caller — they were built against the SHA-pin assumption)"
      - "Merge the winning .github fix first, then all 12 dependent-repo pin-fix PRs, then re-trigger each release-please.yml via a push and confirm a green run"
  - truth: "REQ-1.5.1: real second-reviewer mechanism live (GitHub App or review-bot with own credentials), auto-merge functioning"
    status: partial
    reason: >
      Mechanism code is complete and now clean (CodeQL critical resolved, check-run
      86536956171 conclusion=success on commit 548d95f, confirmed live). But
      `gh api orgs/Coding-Autopilot-System/installations` still shows only
      `chatgpt-codex-connector` — the `cas-review-bot` App does not exist. Without it there
      is no live second-reviewer credential, so the falsifier (a real dependabot-class PR
      merging without agent/operator action) cannot be tested, and the "median green-PR
      time-to-merge <24h over a 2-week window" falsifier has no observation window yet
      (oldest open PR in the org is <2 days old as of this audit).
    artifacts:
      - path: "Coding-Autopilot-System/.github PR #17 (review-bot.yml + classifier)"
        issue: "Code-complete and CodeQL-clean; blocked on human App creation, not code"
    missing:
      - "Create GitHub App cas-review-bot, install org-wide (13 repos), store REVIEW_BOT_APP_ID/REVIEW_BOT_PRIVATE_KEY as org Actions secrets"
      - "Merge .github PR #17 (currently held by its own automerge-eligibility check, correctly fail-closed since it touches .yml/.ps1 files)"
      - "Run the live falsifier test after App activation: one docs-only PR auto-merges hands-off; one .ps1/workflow PR is held for human review"
      - "Let a 2-week observation window elapse before evaluating the median-time-to-merge falsifier"
deferred:
  - truth: "REQ-1.5.4: evidence artifacts for 2 consecutive weekly CAS-PilotCadence runs"
    addressed_in: "Same phase, next calendar week"
    evidence: >
      Scheduled task CAS-PilotCadence confirmed live (State=Ready, weekly trigger,
      DaysOfWeek=Monday, StartBoundary 2026-07-10T09:00+03:00). Only one weekly firing has
      occurred (2026-07-10); the second is due 2026-07-17. This is a calendar-time gate,
      not a code or merge gap — mechanism, evidence format, and drill (issue #23, closed,
      stateReason COMPLETED) are all independently live-verified. No further engineering
      action is needed; re-check after 2026-07-17.
---

# Phase 42: v1.5 Milestone Audit Verification Report

**Phase Goal:** Goal-backward, live-spot-verified audit of milestone v1.5 against REQ-1.5.1
through REQ-1.5.6, producing an honest PASSED / PASSED-PENDING-MERGES / PARTIAL / FAILED
verdict per requirement plus a consolidated operator checklist. REQ-1.5.6 is a hard gate:
the audit fails closed unless a real `{N}-LEARNINGS.md` exists for every phase 38-41.

**Verified:** 2026-07-11T14:00Z (live `gh`/`git`/`Get-ScheduledTask` commands run in this
session; SUMMARY.md and PRE-VERIFICATION.md content treated as narrative, re-checked
against live GitHub/filesystem state — see command evidence below).

**Status:** gaps_found (one NEW operator-decision-requiring conflict discovered; several
Must-Haves are code-complete but not yet live/activated).

## Hard Gate: REQ-1.5.6 LEARNINGS.md for phases 38-41

```
git fetch origin docs/phase-42-learnings
git ls-tree -r --name-only origin/docs/phase-42-learnings -- .planning/phases/ | grep -i LEARNINGS
```
Result: all four files present —
`38-merge-flow-and-backfill/38-LEARNINGS.md` (182 lines, 14 `**Source:**` citations),
`39-release-engineering/39-LEARNINGS.md` (201 lines, 14 citations),
`40-pilot-cadence/40-LEARNINGS.md` (183 lines, 13 citations),
`41-learning-loop/41-LEARNINGS.md` (189 lines, 11 citations).
No `LEARNINGS-PENDING.md` markers remain on that branch (`grep -i PENDING` → empty).

**Caveat:** this content lives only on root PR #23 (`docs(42): extract real LEARNINGS.md
for phases 38-41`, still OPEN). `git ls-tree origin/master` confirms **zero**
`LEARNINGS.md`/`LEARNINGS-PENDING.md` files exist on `master` today. The gate is
**content-satisfied** (real, substantive, sourced material exists and is pushed) but
**not yet authoritative** until PR #23 merges. Hard gate: **PASSED (content-verified),
PASSED-PENDING-MERGE (authority)**.

## REQ Verdict Table

| REQ | Requirement (abridged) | Verdict | Live Evidence |
|---|---|---|---|
| **REQ-1.5.1** | Merge flow live: App-backed second reviewer, auto-merge functioning, <24h median, 0 PRs >7d old | **PARTIAL** | Mechanism code clean: `gh api .../check-runs/86536956171` → CodeQL `conclusion:"success"` on commit `548d95f` (pwn-request fix confirmed live-green, was CRITICAL-failing at pre-verification time). `gh api orgs/Coding-Autopilot-System/installations` → only `chatgpt-codex-connector`, no `cas-review-bot`. Falsifier untestable without the App. All 27 currently-open org+root PRs are <2 days old (0 >7d — trivially true, no 2-week window has elapsed). |
| **REQ-1.5.2** | v1.4 hygiene backfill: worktree leftovers dispositioned, root branch protection live | **PASSED** | `pr-maf-workers`: present at `scratch/orphaned-worktrees/pr-maf-workers/`, absent from `git worktree list` (confirmed not a registered worktree). `v1.1-cas-contracts`: absent from `git branch -a` (pruned). `gh api repos/OgeonX-Ai/cas-workstation/branches/master/protection` → `required_approving_review_count:1, enforce_admins.enabled:true` (live, independent of PR #18's still-open documentation-only status). Live `workspace-health.ps1` sweep run in this session emits 55 findings — **none** reference `pr-maf-workers` or `v1.1-cas-contracts`. 6 conservatively-kept branches remain RETAIN per 38-02's squash-aware content gate (documented, not silently ignored). |
| **REQ-1.5.3** | Release engineering live: SemVer tag + notes matching git log per repo, wired on merge | **FAILED (live, org-wide)** | Live `workspace-health.ps1` run: `release-stale ... no SemVer release tag exists` for **all 13** portfolio repos, right now. 13/13 pin-fix PRs verified correct (`gh pr diff 25 --repo .../gsd-orchestrator` shows exact swap `f288e5e3...`→`64c1673088ff7802f1270a44f03bc4d7a10631f2`; same pattern confirmed present in all 12 others), **0/13 merged**. **NEW finding:** `.github` carries two competing open PRs on the same file (`#18` relative-path rewrite by `OgeonX-Ai`, `#19` SHA re-pin) — both `mergeable:"MERGEABLE"` individually but incompatible; merging the wrong one (or both) will not fix, or will re-break, all 12 dependent repos. Requires operator decision before any merge in this group. |
| **REQ-1.5.4** | Pilot cadence: 4 v1.0 scenarios + Phase 28 fault injection, weekly, seeded regression auto-files issue | **PARTIAL (time-gated, mechanism VERIFIED)** | `Get-ScheduledTask -TaskName CAS-PilotCadence` → `State: Ready`, weekly trigger, `DaysOfWeek:1` (Monday), `StartBoundary 2026-07-10T09:00:00+03:00`. `gh issue view 23 --repo .../gsd-orchestrator` → `state:CLOSED, stateReason:COMPLETED` (drill regression, deduped, closed). `gh api .../commits/11641fcb...` → `422 No commit found` (seeded SHA confirmed unreachable, live re-check). Evidence artifact for week 1 merged (`evidence/pilot-cadence/2026-07-10.json`, on `master`). Falsifier needs 2 consecutive weekly runs; only 1 has fired as of 2026-07-11 (today). Second fires 2026-07-17 — not a defect, a clock. |
| **REQ-1.5.5** | Staleness detection: sweep flags >30d-stale repos, red fixture test | **PASSED** | `git log origin/master --oneline -1 -- scripts/workspace-health.ps1` → `cf24475 feat(39-01): add release-staleness detection ... (#17)`, on `master`. Source inspected live: correctly flags both "no tag at all" and ">30d old with commits since" (lines 263-276 of `workspace-health.ps1`). Live sweep run in this session actually exercises this code path and produces 13 real `release-stale` findings. Minor doc lag: `REQUIREMENTS.md` checkbox for REQ-1.5.5 still shows `[ ]` despite the functionality being live — cosmetic, not a functional gap. |
| **REQ-1.5.6** | Learning loop: LEARNINGS.md for phases 38-41, repeatable survey script | **PASSED (content) / PASSED-PENDING-MERGE (authority)** | See Hard Gate section above. Survey script merged to `master`: `fec174d feat(41-02): repeatable backlog-survey script + baseline evidence (#15)` — `scripts/backlog-survey.ps1`, `tests/BacklogSurvey.Tests.ps1`, dated snapshot+delta report under `evidence/backlog-survey/`, all live on `master`. |

## Remediation Verification (post-preverification fixes)

| Fix | Claim | Live Verification |
|---|---|---|
| **42-fix1-pin** | 13 PRs opened, all repoint to verified reachable SHA `64c1673...` | Confirmed live on `gsd-orchestrator#25`: `gh pr diff 25` shows exact `-f288e5e3...`/`+64c1673088ff7802f1270a44f03bc4d7a10631f2` diff. All 13 PRs confirmed OPEN, unmerged, green on their own CI (`state:OPEN, mergedAt:null`, checks all SUCCESS) via `gh pr view --json state,mergedAt,statusCheckRollup` across all 13 repos. **Not previously flagged by the fix author:** `.github` now has a second, competing PR (#18) for the same fix surface — see REQ-1.5.3 gap above. |
| **42-fix2-pwn** | CodeQL critical resolved on `.github` PR #17 (`review-bot.yml`) via API-diff instead of `git fetch pull/N/head` | Confirmed live: `gh api repos/Coding-Autopilot-System/.github/check-runs/86536956171` → `{"conclusion":"success","head_sha":"548d95f...","status":"completed"}`. `automerge-eligibility` still `FAILURE` on PR #17 — this is the pre-existing, correct fail-closed behavior for a `.yml`-touching PR (own workflow correctly holding itself for human review), not a regression from the pwn fix. |

## Consolidated Operator Checklist (merge groups, in order)

0. **DECIDE (new, blocking):** `Coding-Autopilot-System/.github` PR **#18** vs **#19** — both touch
   `release-please.yml`. Recommend keeping **#19** (the audited, SHA-pin-consistent fix that the
   other 12 repos' pin-fix PRs were built against) and closing #18, unless the relative-path
   approach in #18 is preferred going forward — in which case all 12 dependent pin-fix PRs need
   re-derivation, since they assume the SHA-pin call pattern survives in `.github`.
1. **Merge the 13 pin-fix PRs** (only after step 0 resolves the `.github` half):
   `gsd-orchestrator#25`, `Promptimprover#32`, `autogen#24`, `cas-reference-product#17`,
   `cloud-security-service-model#18`, `cas-evals#14`, `cas-contracts#23`, `cas-platform#16`,
   `autopilot-core#22`, `autopilot-demo#13`, `ci-autopilot#2274`,
   `Coding-Autopilot-System/cas-workstation#23`, `Coding-Autopilot-System/.github#19` (or #18,
   per step 0). Re-trigger each via a push after merge; confirm one green `release-please` run
   before declaring REQ-1.5.3 live.
2. **Root repo (`OgeonX-Ai/cas-workstation`) open PRs**, in dependency order:
   `#18` (feat 38-01+38-03 merge-flow mechanism + root protection codification),
   `#20` (feat 38 rebase), `#14` (feat 40-01 pilot-cadence runner),
   `#12` (docs 41-01 learning-loop hard-gate — creates the ROADMAP amendment and PENDING markers),
   `#19` (docs 39-03 bookkeeping), `#21` (docs 42 pre-verification report),
   `#22` (docs pin-rule-learning), `#23` (docs 42 real LEARNINGS.md — **required before REQ-1.5.6
   is authoritative on master**).
3. **Org `.github` PR #17** (`feat(38-01): review-bot auto-merge mechanism`) — merge once its own
   `automerge-eligibility` is dispositioned by a human (expected fail-closed behavior for a
   `.yml`/`.ps1`-touching PR; requires manual approval per the mechanism's own design, not a bug).
4. **App activation** (out-of-band, not a PR): create GitHub App `cas-review-bot`, install
   org-wide across all 13 repos, set `REVIEW_BOT_APP_ID` / `REVIEW_BOT_PRIVATE_KEY` as org Actions
   secrets. Required before REQ-1.5.1's falsifier can be tested at all.
5. **Wait for calendar time:** second `CAS-PilotCadence` Monday firing (2026-07-17) for
   REQ-1.5.4's "2 consecutive weekly runs" falsifier; a 2-week PR-age observation window from
   whenever step 4 completes, for REQ-1.5.1's median-time-to-merge falsifier.

## v1.5 Velocity/Quality Trend vs v1.4

**v1.4 pattern (from `v1.4-LEARNINGS.md`, retroactively distilled):** gaps were predominantly
caught during **verification/execution**, after work was already done — e.g. "Locally-measured
coverage figures superseded by authoritative remote CI" (26-02), and line 453's explicit note
that dirty/uncommitted worktree state "were not flagged in any SUMMARY.md and were only
surfaced by spot-verifying live" — i.e., the audit stage was the primary catch point, not
planning.

**v1.5 pattern (from git history + phase LEARNINGS):** a dedicated plan-checker pass ran
*before* execution on every phase this milestone —
`2875b38`/`f309e8b`/`1e94cf3 docs(38): plan-checker blocker fixes for merge-flow plans` (fixed
critic_cli pin, dependabot-denylist-bypass fixture, `pr-maf-workers` disposition, cross-org
`-Owner` param pinning — all **before** 38's execution began) and
`da50712 docs(v1.5): apply consolidated checker fixes to phases 39-41` (root PR-flow
correction + isolated-worktree preflight for 39, completed a truncated 40-02 plan, added
REQ-1.5.6 LEARNINGS coverage to 41 — again, all pre-execution). This is a measurable shift:
v1.4's catch point was the phase-close audit; v1.5's catch point moved to plan-time, before any
execution token was spent on the flawed approach.

**Where this audit (Phase 42) itself continued the v1.4 pattern of catching things late:** the
pre-verification found two genuinely new execution-time defects that plan-checking couldn't
have caught (the squash-merge orphaned-SHA pin, and the CodeQL pwn-request pattern) — both are
inherently only detectable once real GitHub state exists (a squash-merge event; a security
scanner run), not at plan-review time. This verification pass found one more of the same
character: the `.github` #18/#19 duplicate-fix collision, only detectable once two independent
fix attempts actually existed as live PRs. **Net assessment:** plan-time defect catching is
real and improved substantially in v1.5, but a class of defects (races between concurrent
fixes, squash-merge SHA drift, live security-scan results) remains irreducibly
execution/audit-time — the correct response demonstrated this session is fast, live
re-verification rather than assuming plan-time review alone is sufficient.

## Anti-Patterns / Notable Items

| Item | Severity | Note |
|---|---|---|
| `.github` PR #18 vs #19 duplicate fix | Blocker | New, not previously flagged anywhere. See REQ-1.5.3 gap. |
| REQUIREMENTS.md checkbox `[ ]` for REQ-1.5.2/1.5.5/1.5.6 despite live-verified functionality | Info | Documentation lag only; recommend a bookkeeping pass once the corresponding PRs merge to master, using `requirements.mark-complete`. |
| `automerge-eligibility` FAILURE on `.github`#17 | Info (expected) | Correct fail-closed behavior on a `.yml`-touching PR — proves the classifier works on itself, not a defect. |

## Human Verification Required

None beyond the operator checklist above (all items are either mechanical merges, one
documented decision, an out-of-band App-creation action, or waiting for calendar time — none
require subjective UX/visual judgment).

## Gaps Summary

v1.5's engineering is substantively complete and live-spot-verified: every mechanism (merge
classifier, review-bot, release-please wiring, staleness detection, pilot cadence, learning
extraction, backlog survey) exists, is code-correct, and — where merged — functions as
designed on live GitHub/Windows-scheduler state. Nothing is faked or stubbed. The gap between
"engineering complete" and "milestone live" is entirely operator-side: one new decision
(`.github` #18 vs #19), ~21 merges across 14 repos, one GitHub App creation, and the passage of
calendar time for two time-gated falsifiers (REQ-1.5.1's 2-week window, REQ-1.5.4's second
weekly run). REQ-1.5.3 is marked FAILED rather than PASSED-PENDING-MERGES specifically because
the newly discovered PR conflict means "just merge everything" is not a safe instruction as
written — an operator decision must precede the merge wave for that requirement group only.

---

_Verified: 2026-07-11T14:00Z_
_Verifier: Claude (gsd-verifier / phase-42 audit)_

---

## Orchestrator resolution of the PR #18 vs #19 conflict (2026-07-11)

Both PRs fix ONLY the `.github` repo's own self-caller. Diff comparison:
- **#18** switches to a local relative reference (`uses: ./.github/workflows/release-please-reusable.yml`) — canonical for same-repo reusable-workflow callers; immune to the stranded-SHA class permanently.
- **#19** re-pins to the reachable SHA — correct today, but re-strands on any future edit of the reusable workflow.

**Recommendation: merge #18, close #19 as superseded (self-caller only).** The 12 cross-repo pin-fix PRs are unaffected and remain required — cross-repo callers cannot use relative paths and MUST pin (per the rule now in docs/merge-train-runbook.md).

## Final ordered operator checklist

1. `.github`: merge **#18**, close #19 (superseded).
2. Merge the 12 remaining pin-fix PRs (restores release flow org-wide; release-please will open its first release PRs on next push).
3. Merge root PRs #17-#19, #21-#23 (staleness check, merge-flow policy, bookkeeping, pre-verification, pin rule, LEARNINGS — the last one satisfies REQ-1.5.6's authority on master).
4. Merge org #17 (review-bot, CodeQL green) — then create + install the `cas-review-bot` App and store its two secrets (38-01 checklist) → activates REQ-1.5.1's falsifier test.
5. Let the week turn: second pilot-cadence run fires 2026-07-17 (REQ-1.5.4's second falsifier); the REQ-1.5.1 24h-median window starts once auto-merge is live.
6. Then `/gsd:complete-milestone v1.5`.
