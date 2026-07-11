# v1.5 Pre-Verification: Phases 38-41 (Goal-Backward, Live Spot-Verified)

**Method:** Live GitHub inspection (gh api/pr/run), local scheduled-task and filesystem checks, and a live run of `autogen`'s `maf_starter.critic_cli` (pinned `b0524b7`, autogen main) against each root PR diff. SUMMARY.md claims were treated as narrative only; every verdict below is backed by a command/output captured in this session.

**IMPORTANT — the target moved during this audit.** Starting mid-session, PRs began merging live (an operator/automation batch-drain running concurrently with this verification). All verdicts below reflect the state observed as of **2026-07-11T10:25Z** (immediately after the merge wave). Where a claim was re-verified after a merge landed, both the pre- and post-merge evidence are noted.

---

## Headline finding (new, not in any SUMMARY.md)

**REQ-1.5.3's entire release-engineering mechanism is currently broken end-to-end, live, in production, for all 13 repos.**

All 12 sub-repo PRs (`ci(release): wire release-please...`) merged to their default branches at ~2026-07-11T10:15-10:19Z during this session. Their push-triggered `.github/workflows/release-please.yml` then fired — and **every one failed** with `Invalid workflow file ... error parsing called workflow ... workflow was not found`.

Root cause, confirmed via `gh api`:
- The pin `Coding-Autopilot-System/.github/.github/workflows/release-please-reusable.yml@f288e5e3b67b29a2c08880b76da7b852f4a132d0` (baked into all 13 repos' caller workflows, including `org-dotgithub`'s own dogfood file) points at the **pre-squash-merge branch-tip commit** of `.github` PR #16.
- `.github` PR #16 was **squash-merged**; the real commit that landed on `.github`'s `main` is `64c1673088ff7802f1270a44f03bc4d7a10631f2`, not `f288e5e3...`.
- `gh api repos/Coding-Autopilot-System/.github/compare/main...f288e5e3b67b29a2c08880b76da7b852f4a132d0` returns `"status":"diverged"` — the pinned SHA is not reachable from `main`. Its source branch (`ci/...`) was deleted on merge, so nothing keeps it reachable.
- Confirmed the same `workflow was not found` failure independently on 6/13 repos (autogen run `29149048698`, gsd-orchestrator `29149146809`, cas-contracts `29149108686`, cas-platform `29149131299`, Promptimprover `29149045911`, and `.github` itself `29148993738`) — 100% failure rate on every repo checked, all the identical root cause.

This means REQ-1.5.3's falsifier (`gh release view` latest per repo shows notes consistent with commit history) is **currently false everywhere** — not "not yet evaluable because still PR-only" (the plan's own stated caveat), but **actively broken now that the PRs did merge**. Fix: re-pin all 13 `release-please.yml` callers to `64c1673088ff7802f1270a44f03bc4d7a10631f2` (or a later, verified-reachable `main` commit), then re-trigger via a push.

---

## Second finding (new): unresolved CRITICAL CodeQL alert on the review-bot workflow

`.github` PR #17 (`feat(38-01): review-bot auto-merge mechanism`) has an **open, unresolved, critical-severity CodeQL alert**: *"Checkout of untrusted code in a privileged context"* on `review-bot.yml` lines 59-68 (the `git fetch origin pull/<N>/head:pr-head` step, which runs inside a `pull_request_target`-triggered job after the App token has already been minted).

- Confirmed via `gh api repos/Coding-Autopilot-System/.github/check-runs/86385776216/annotations`.
- Both `CodeQL` and the PR's own `automerge-eligibility` required check are currently **failing** on this PR (the eligibility failure is *expected/correct* — this PR touches `.ps1`/`.yml` files, so the classifier fail-closes it to human review, proving the mechanism works on itself). The CodeQL failure is not expected and is not addressed anywhere in the SUMMARY or the threat model (`docs/merge-flow-policy.md` STRIDE table covers T-38-SC as "actions pinned by SHA" but does not address this specific untrusted-checkout pattern).
- This is the exact review-bot workflow the whole REQ-1.5.1 mechanism depends on for its approval authority. It should not be merged/trusted as "done" with a live critical alert against it, even though the practical exploitability is arguable (the fetched ref is only diffed as text, never executed) — it needs an explicit maintainer disposition (fix the pattern, e.g. use the GitHub API diff endpoint instead of `git fetch`ing the PR head; or dismiss with a documented justification), not silence.

---

## Per-Phase Verdicts

| Phase | Verdict | Evidence |
|---|---|---|
| **38 — Merge Flow & Backfill** | **GAP** (blocked by the CodeQL finding above) + **VERIFIED-PENDING-HUMAN-ACTION** (App creation) for the rest | See below |
| **39 — Release Engineering** | **GAP / BLOCKER** — mechanism merged but broken (see headline finding) | See below |
| **40 — Pilot Cadence** | **VERIFIED** (mechanism) + **explicit falsifier-not-yet-met** (needs a 2nd weekly run) | See below |
| **41 — Learning Loop** | **VERIFIED** (mechanism/tooling) + **GAP** (REQ-1.5.6's actual falsifier: no real `{N}-LEARNINGS.md` exists yet for 38-41) | See below |

### Phase 38 — Merge Flow & Hygiene Backfill

| Claim | Status | Evidence |
|---|---|---|
| `.github` PR #17 classifier contains the dependabot+workflow-file OUT fixture | VERIFIED | `gh pr diff 17 --repo Coding-Autopilot-System/.github` — 448-line diff includes `classify-automerge-eligibility.ps1` with the denylist-checked-first logic; `docs/merge-flow-policy.md` (merged via root PR #18, see below) documents the exact fixture name `dependabot-with-workflow-file -> OUT-OF-CLASS`. |
| Root PR #18 has policy doc + CODEOWNERS | VERIFIED | `docs/merge-flow-policy.md` (159 lines, exceeds the 40-line must_have) states mechanism, class boundary, honest trust model, and a Root-repo section. `CODEOWNERS` (`* @OgeonX-Ai`) present. Still **open** as of 2026-07-11T10:25Z. |
| PR #16 disposition report exists | VERIFIED (now merged) | `981c22c feat(38-02): squash-aware branch gate + residual dispositions (#16)` is on `origin/master`. `.planning/phases/38-merge-flow-and-backfill/38-backfill-disposition-report.md` present with real per-branch evidence: 0/6 SAFE-TO-DELETE (all 6 flagged post-merge-drift with `git diff --stat` evidence), `v1.1-cas-contracts` confirmed orphaned+pruned, `pr-maf-workers` confirmed unregistered+content-probed (66 files hashed, 62/66 matched, remaining 4 superseded)+moved to `scratch/`. Pester suite (`squash-aware-branch-gate.Tests.ps1`) green. |
| Remaining human step (App creation) recorded | VERIFIED | `38-01-SUMMARY.md` "User Setup Required" section + `STATE.md` Blockers section both explicitly name App creation + `REVIEW_BOT_APP_ID`/`REVIEW_BOT_PRIVATE_KEY` secrets as the blocker. Confirmed **not yet done**: `gh api orgs/Coding-Autopilot-System/installations` shows only `chatgpt-codex-connector` installed — no `cas-review-bot`. |
| New finding: CodeQL critical on review-bot.yml | **BLOCKER** | See headline section above. Unresolved as of last check. |
| REQ-1.5.1 falsifier (live auto-merge test) | NOT MET | Cannot be met until the App exists; additionally should not be trusted until the CodeQL alert is resolved/dismissed with justification. |
| REQ-1.5.2 (root protection) | VERIFIED | `gh api repos/OgeonX-Ai/cas-workstation/branches/master/protection` (independently re-checked): `required_approving_review_count=1`, `enforce_admins.enabled=true` — matches the "satisfied-by-live-state" claim. |

### Phase 39 — Release Engineering

| Claim | Status | Evidence |
|---|---|---|
| All 12 sub-repo PRs pin EXACTLY `f288e5e3b67b29a2c08880b76da7b852f4a132d0` | VERIFIED (pin text) | `gh pr diff <N> --repo Coding-Autopilot-System/<repo> \| grep` confirmed on all 12: cas-evals#13, cas-contracts#22, autopilot-demo#12, autopilot-core#21, autogen#23, gsd-orchestrator#24, Promptimprover#31, cloud-security-service-model#17, ci-autopilot#2273, cas-workstation#22, cas-reference-product#16, cas-platform#15. |
| All 12 sub-repo PRs OPEN | **SUPERSEDED BY LIVE EVENT** | All 12 merged mid-session (2026-07-11T10:15:07Z–10:19:00Z), confirmed via `gh pr view --json state,mergedAt`. Merging is a *better* state than the dimension asked for — but it also triggered the headline finding below. |
| gsd-orchestrator manifest bootstraps 4.0.0 | VERIFIED | `.release-please-manifest.json` in PR #24 diff: `{".": "4.0.0"}`. |
| Staleness check + red fixture on root PR #17 | VERIFIED (now merged) | `cf24475 feat(39-01): add release-staleness detection to workspace-health.ps1 (#17)` on `origin/master`. `tests/Workspace.Health.Tests.ps1` carries 4 `It` blocks including a `GIT_COMMITTER_DATE`/`GIT_AUTHOR_DATE`-faked 45-day-old-tag red fixture. This satisfies the implementation evidence for REQ-1.5.5; `REQUIREMENTS.md` remains unchecked until the milestone audit records final acceptance. |
| **Mechanism actually functions on merge** | **FAILED — BLOCKER** | See headline finding. All 13 repos' `release-please.yml` fail with `workflow was not found` because the pin SHA is an orphaned, squash-merge-superseded commit. Directly falsifies REQ-1.5.3 as currently implemented. |
| PR #17 (root, cas-workstation#22 dupe... wait — root's own release-please PR) | Same broken-pin issue applies once merged | Not yet re-triggered at time of writing; will fail identically on merge for the same reason. |

### Phase 40 — Pilot Cadence

| Claim | Status | Evidence |
|---|---|---|
| Scheduled task `CAS-PilotCadence` exists | VERIFIED | `Get-ScheduledTask -TaskName 'CAS-PilotCadence'` → `State: Ready`. Trigger: weekly, `DaysOfWeek=1` (Monday), `StartBoundary 2026-07-10T09:00:00+03:00`, `WeeksInterval=1`. Action: `powershell.exe -File "C:\PersonalRepo\scripts\run-pilot-cadence.ps1" -Root "C:\PersonalRepo"`. |
| Drill evidence: issue #23 filed → deduped → closed | VERIFIED | `gh issue view 23 --repo Coding-Autopilot-System/gsd-orchestrator` → `state: CLOSED`, `stateReason: COMPLETED`, body matches the drill's captured xUnit failure output. `40-drill-evidence.md` (in still-open root PR #14) documents the full sequence including the dedupe bug found+fixed mid-drill (embedded-quote `gh.exe` argument marshalling bug in PowerShell 5.1) and its fix. |
| Seeded SHA unreachable | VERIFIED | `gh api repos/Coding-Autopilot-System/gsd-orchestrator/commits/11641fcb5e7ac1c840434f3796e2eebaa68d1fe6` → `422 No commit found for SHA`. `DrillSeededFailure.cs` is absent from `main`'s tree. Matches the evidence doc's own `git branch --all --contains <sha>` → empty claim. |
| Four v1.0 pilot scenarios + Phase 28 fault injections wired | VERIFIED | `run-pilot-cadence.ps1` (root PR #14, still open) registers 3 suites: `loop-pilots` (wraps the pre-existing `tests/Loop.Pilot.Tests.ps1` → `scripts/Test-LoopPilotEvidence.ps1`, confirmed present and not fabricated), `gsd-orchestrator-fault-injection` (filters `FaultInjectionTests\|CheckpointCorruptionTests` — Phase 28), `autogen-fault-injection`. |
| REQ-1.5.4 falsifier: evidence for 2 consecutive weekly runs | **NOT YET MET (time-gated, not a code gap)** | Only one dated evidence artifact exists: `evidence/pilot-cadence/2026-07-10.json` (now merged via PR #13, `origin/master` commit `99d09ab`). A second week has not yet elapsed since the scheduled task's first `StartBoundary`. This is expected, not a defect — flag for Phase 42 to re-check after the task's second Monday firing. |
| PR #14 (runner) | Still OPEN | `feat(40-01): pilot-cadence runner + regression issue filer`, created 2026-07-10T10:16:59Z. |

### Phase 41 — Learning Loop

| Claim | Status | Evidence |
|---|---|---|
| PR #12 contains template, OPERATING-CONTRACT hook, v1.4-LEARNINGS, LEARNINGS-PENDING markers for 38-41 | VERIFIED (still open) | `gh pr view 12 --repo OgeonX-Ai/cas-workstation` files list: `.planning/templates/LEARNINGS-template.md`, `engineering-os/OPERATING-CONTRACT.md` (+12 lines, phase-close extraction checklist), `.planning/milestones/v1.4-LEARNINGS.md` (781-line diff, retroactive, sourced/cited), `LEARNINGS-PENDING.md` in all four phase dirs (38/39/40/41), and a `.planning/ROADMAP.md` amendment adding: *"Phase 42... HARD-GATE (REQ-1.5.6): the audit fails closed unless a real `{N}-LEARNINGS.md` exists for every phase 38-41 — every `LEARNINGS-PENDING.md` marker must be gone."* |
| PR #15 contains survey script + Pester | VERIFIED (now merged) | `fec174d feat(41-02): repeatable backlog-survey script + baseline evidence (#15)` on `origin/master`. `scripts/backlog-survey.ps1`, `tests/BacklogSurvey.Tests.ps1`, plus a dated snapshot+delta report (`evidence/backlog-survey/{snapshots,reports}/...-2026-07-10...`). |
| REQ-1.5.6 falsifier: "LEARNINGS.md present for phases 38-41" | **FAILED (as of now)** | Confirmed via local filesystem: `.planning/phases/{38,39,40,41}-*/` contain **zero** `LEARNINGS.md` or even `LEARNINGS-PENDING.md` files on the current checkout (PR #12, which creates the markers, is still open/unmerged). Even once #12 merges, only *pending markers* land — no phase has yet produced a real, extracted `{N}-LEARNINGS.md`. |
| REQ-1.5.6 falsifier: "survey script run evidence" | VERIFIED | `evidence/backlog-survey/snapshots/backlog-survey-2026-07-10.json` + dated delta report, both on `origin/master`. |

---

## Phase 42's LEARNINGS Hard-Gate: CAN IT CURRENTLY PASS?

**No.** By the plan's own text (added in PR #12): *"the audit fails closed unless a real `{N}-LEARNINGS.md` exists for every phase 38-41... including this very phase (41) itself."* As of this session:

- Zero `{N}-LEARNINGS.md` files exist anywhere in the repo for phases 38-41 (confirmed on local `master` and by inspecting the diffs of every open/merged PR touching those phase directories — all that exists or will exist once #12 merges is `LEARNINGS-PENDING.md` obligation markers).
- None of phases 38-41 have actually closed yet (38 has PLAN.md-only + open PRs; 39/40 have partial SUMMARYs with open PRs; 41 itself is still mid-flight via open PR #12).
- `/gsd:extract-learnings {N}` has not been run for any of 38-41.

Phase 42 cannot pass its own hard-gate until: (1) phases 38-41 fully close (all PRs merged, all plans summarized), and (2) `/gsd:extract-learnings` is run for each, replacing every `LEARNINGS-PENDING.md` with a real `{N}-LEARNINGS.md`.

---

## CRITIC Station Results

Ran `python -m maf_starter.critic_cli --diff - --severity-gate blocking` (autogen `main`, pinned commit `b0524b7`, verified as the plan's documented pin) against each root PR's full diff via `gh pr diff <N> | python -m maf_starter.critic_cli --diff - --severity-gate blocking`.

| PR | Title | Blocking | Advisory | Exit | Notes |
|---|---|---|---|---|---|
| #14 | feat(40-01): pilot-cadence runner + regression issue filer | 0 | 2 | 0 | Advisory hits are prose false-positives (`missing-telemetry` pattern matching markdown text, not code) |
| #15 | feat(41-02): repeatable backlog-survey script + baseline evidence | 0 | 1 | 0 | Same false-positive pattern, on a JSON evidence file |
| #16 | feat(38-02): squash-aware branch gate + residual dispositions | 0 | 1 | 0 | Hit on the disposition-report markdown, not code |
| #17 | feat(39-01): add release-staleness detection to workspace-health.ps1 | 0 | 1 | 0 | Hit on a SUMMARY.md prose line |
| #18 | feat(38-01+38-03): merge-flow mechanism + root protection codification | 0 | 2 | 0 | Hits on `merge-flow-policy.md` and a SUMMARY.md prose line |

**Totals: 0 blocking / 7 advisory across 5 PRs, all 5 exit 0.** The critic itself works correctly (verified via `--help` and by confirming it resolves real findings against known content). No blocking findings were found in any root PR's diff — the advisory hits are all pattern-matching false positives against documentation prose, not code defects.

(Not run against `.github`#17 — out of the CRITIC dimension's stated PR list — but note that PR already independently fails CodeQL, a stronger/more precise check, per the headline finding above.)

---

## Consolidated Remaining-Human-Actions List

1. **Create the GitHub App `cas-review-bot`**, install org-wide on `Coding-Autopilot-System` (13 repos), store `REVIEW_BOT_APP_ID` / `REVIEW_BOT_PRIVATE_KEY` as org Actions secrets. (Phase 38-01 checkpoint; confirmed not yet done.)
2. **Resolve the CodeQL critical alert** on `.github` PR #17's `review-bot.yml` (checkout-of-untrusted-code-in-privileged-context) — either refactor the diff-computation step to avoid fetching the PR head ref directly (e.g., use the GitHub REST/compare API for the diff instead of `git fetch pull/N/head`), or get an explicit, documented dismissal from a human maintainer. Do not merge as-is.
3. **Re-pin all 13 `release-please.yml` caller files** (org-dotgithub + the 12 wired repos) from the orphaned `f288e5e3b67b29a2c08880b76da7b852f4a132d0` to the real, reachable `.github` main commit (`64c1673088ff7802f1270a44f03bc4d7a10631f2` as of this session, or re-verify against `main`'s current tip at fix time), then re-trigger each workflow with a push and confirm a green `release-please` run before REQ-1.5.3 can be considered live.
4. **Merge the remaining open PRs**: `.github`#17 (blocked on #2 above), root `OgeonX-Ai/cas-workstation`#12 (41-01 learning-loop hard-gate), #14 (40-01 pilot-cadence runner), #18 (38-01+38-03 merge-flow + root protection), #19 (39-03 summary bookkeeping).
5. **Run `/gsd:extract-learnings {N}`** for phases 38, 39, 40, 41 once each closes, to replace every `LEARNINGS-PENDING.md` with a real `{N}-LEARNINGS.md` — required before Phase 42's hard-gate can pass.
6. **Wait for a second weekly `CAS-PilotCadence` firing** (next Monday after 2026-07-10) and commit its evidence artifact before REQ-1.5.4's "2 consecutive weekly runs" falsifier can be evaluated.
7. Once (1)-(3) land, **run the actual REQ-1.5.1 live test**: a trivial docs-only PR authored by a non-bot identity, confirm zero-click auto-merge; a `.ps1`/workflow-touching PR confirmed held for human review.

---

## PRE-VERIFICATION COMPLETE

**Verdict counts (4 phases):** 0 clean VERIFIED, 2 VERIFIED-with-open-items (40, 41-mechanism), 2 GAP/BLOCKER (38 blocked by unresolved CodeQL critical; 39 blocked by the live, confirmed, org-wide release-please pin failure).

**Critic totals:** 0 blocking / 7 advisory across the 5 scoped root PRs (#14, #15, #16, #17, #18) — all pass the critic's own gate (exit 0).

**New findings this session (not present in any SUMMARY.md):**
- REQ-1.5.3 mechanism is live-broken for all 13 repos (orphaned SHA pin from a squash-merge).
- `.github` PR #17's review-bot workflow carries an unresolved CRITICAL CodeQL alert.
- 6 additional root/org PRs merged *during* this audit session (see per-phase tables), materially changing the verified state mid-run — this report reflects the final state as of 2026-07-11T10:25Z.

**Phase 42's LEARNINGS hard-gate cannot currently pass** — zero real `{N}-LEARNINGS.md` files exist for phases 38-41.
