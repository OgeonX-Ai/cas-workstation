---
phase: 38-merge-flow-and-backfill
plan: 01
subsystem: infra
tags: [github-actions, github-app, powershell, branch-protection, autogen-critic]

requires:
  - phase: 31-org-hardening
    provides: SHA-pinned org workflows, org-dotgithub baseline
provides:
  - Fail-closed auto-merge eligibility classifier (dependabot-manifest-only OR docs-only, denylist applies to all authors)
  - review-bot.yml org workflow (App-gated approval on critic_cli + classifier + CI green)
  - apply-branch-protection.ps1 as-code branch-protection script (shared by 38-01 and 38-03)
  - docs/merge-flow-policy.md (mechanism design + class boundary + honest trust model)
affects: [38-03-root-protection, REQ-1.5.1]

tech-stack:
  added: [actions/create-github-app-token@v3.2.0 (pinned SHA), autogen critic_cli (pinned commit b0524b7)]
  patterns: ["fail-closed classification from changed-paths only, never labels/title", "as-code branch protection reused across owners"]

key-files:
  created:
    - portfolio/org-dotgithub/.github/scripts/classify-automerge-eligibility.ps1
    - portfolio/org-dotgithub/.github/workflows/auto-merge-eligibility.yml
    - portfolio/org-dotgithub/.github/workflows/review-bot.yml
    - scripts/apply-branch-protection.ps1
    - docs/merge-flow-policy.md
  modified:
    - docs/merge-train-runbook.md

key-decisions:
  - "review-bot GitHub App is the second-party reviewer for the in-class category only; deterministic policy enforcement (classifier + critic_cli + CI), not human judgment -- documented honestly rather than oversold"
  - "critic_cli pinned to autogen origin/main commit b0524b7 (merged PR #17); the abandoned feat/phase-29-peer-critic branch (closed PR #14) is never referenced"
  - "denylist (workflow/executable/non-docs files) applies to ALL authors including dependabot, checked before the manifest/docs match -- closes the blocker-#2 gap where a dependabot github-actions PR touching .github/workflows/** could otherwise slip through as 'manifest-only'"

patterns-established:
  - "Classification decisions derive strictly from gh pr view changed-paths + author, never from labels/title (both are author-controllable)"
  - "apply-branch-protection.ps1 is parameterized by -Owner/-Repos so the exact same script and payload shape apply to org sub-repos and the root repo, with -SkipEligibilityCheck / -RequireCodeOwnerReviews as explicit per-repo opt-outs/opt-ins rather than forked logic"

requirements-completed: [REQ-1.5.1]

duration: 55min
completed: 2026-07-10
---

# Phase 38 Plan 01: Merge-flow mechanism (review-bot App + classifier + branch-protection-as-code) Summary

**Fail-closed diff classifier + a dedicated cas-review-bot GitHub App gated on the pinned autogen critic_cli, wired as the second-party reviewer for dependabot/docs-only PRs, with the same branch-protection-as-code script reused unmodified for the root repo in Plan 38-03.**

## Performance

- **Duration:** ~55 min
- **Started:** 2026-07-10T13:30:00Z (approx)
- **Completed:** 2026-07-10T14:27:00Z
- **Tasks:** 2 of 3 (Task 3 is the App-dependent human-verify checkpoint, see below)
- **Files modified:** 6 (5 created, 1 modified) across two repos

## Accomplishments
- `classify-automerge-eligibility.ps1`: fail-closed classifier with 5 table-driven `-SelfTest` fixtures, including the checker-blocker-#2 regression fixture (`dependabot-with-workflow-file` -> OUT-OF-CLASS). All 5 pass.
- `review-bot.yml`: three sequential fail-closed gates (classifier, pinned critic_cli, green CI) before the App ever approves; App token is the sole approving identity.
- `apply-branch-protection.ps1`: as-code branch protection, verified via `-DryRun` against `autogen` (real `gh api` call resolving `main` as default branch, correct payload).
- `docs/merge-flow-policy.md`: states the mechanism, the exact class boundary, and the trust model honestly (deterministic policy enforcement, not human judgment; bounded to docs/dependency risk surface).

## Task Commits

Each task was committed atomically, per-repo (root repo `OgeonX-Ai/cas-workstation` and org repo `Coding-Autopilot-System/.github`, both on isolated worktrees/branches):

**org-dotgithub (branch `feat/merge-flow-review-bot`, PR Coding-Autopilot-System/.github#17):**
1. **Task 1: classifier + eligibility workflow** - `cca76e2` (feat)
2. **Task 2: review-bot workflow** - `24b9832` (feat)

**root repo (branch `feat/phase-38-merge-flow`, PR OgeonX-Ai/cas-workstation#18):**
1. **Task 1: merge-flow-policy.md** - `dc0fdd9` (docs)
2. **Task 2: apply-branch-protection.ps1 + runbook update** - `e44d786` (feat)
3. **Deviation fix: -SkipEligibilityCheck** - `9f658b5` (fix, Rule 1)

## Files Created/Modified
- `portfolio/org-dotgithub/.github/scripts/classify-automerge-eligibility.ps1` - fail-closed classifier, 5-fixture self-test
- `portfolio/org-dotgithub/.github/workflows/auto-merge-eligibility.yml` - required status check wiring the classifier
- `portfolio/org-dotgithub/.github/workflows/review-bot.yml` - App-gated approval workflow (classifier + critic_cli + CI green)
- `scripts/apply-branch-protection.ps1` - as-code branch protection, shared by 38-01 and 38-03
- `docs/merge-flow-policy.md` - mechanism design, class boundary, trust model, root-repo section
- `docs/merge-train-runbook.md` - points the in-class category at the new auto-merge flow; manual train remains for out-of-class/bulk/root

## Decisions Made
- Chose the review-bot GitHub App mechanism over GitHub's native merge-queue (native merge-queue has no equivalent to a policy-driven second reviewer identity; the App gives a real, credentialed, non-agent second party).
- critic_cli pinned to a verified `origin/main` commit (`b0524b7`, PR #17) rather than any branch reference, per plan-checker blocker #1.
- Denylist checked before manifest/docs match in the classifier, so it cannot be bypassed by author identity (blocker #2 fix), with an explicit regression fixture.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] apply-branch-protection.ps1 would permanently block a repo without the classifier workflow**
- **Found during:** Task 2, while preparing to reuse the script for the root repo (38-03) via `-DryRun`
- **Issue:** The default payload always required the `automerge-eligibility` status check context. A repo that never runs that workflow (root) would have a required check that never reports, permanently blocking every PR.
- **Fix:** Added `-SkipEligibilityCheck` (and, while there, `-RequireCodeOwnerReviews` for CODEOWNERS enforcement) as explicit opt-in/opt-out switches; default behavior for org sub-repos unchanged.
- **Files modified:** scripts/apply-branch-protection.ps1
- **Verification:** Re-ran `-DryRun` for both `autogen` (default: automerge-eligibility included) and `cas-workstation` (`-SkipEligibilityCheck`: excluded) -- both payloads correct.
- **Committed in:** `9f658b5`

---

**Total deviations:** 1 auto-fixed (Rule 1 - bug)
**Impact on plan:** Necessary correctness fix discovered by dogfooding the script against its second consumer (38-03); no scope creep, script's public surface only grew by two optional switches.

## Issues Encountered
None beyond the deviation above.

## User Setup Required

**External service requires manual configuration -- this is the explicit remaining human step, and it blocks Task 3 (the App-dependent human-verify checkpoint):**

1. Create the GitHub App `cas-review-bot`:
   - Permissions: Pull requests Read & Write, Contents Read & Write, Checks Read, Metadata Read.
   - Install it on the `Coding-Autopilot-System` org (all 13 repos).
2. Store `REVIEW_BOT_APP_ID` and `REVIEW_BOT_PRIVATE_KEY` as org Actions secrets.
3. Apply branch protection to one repo first: `pwsh -File scripts/apply-branch-protection.ps1 -Repos org-dotgithub` (NOT run for real by this plan -- only `-DryRun` evidence was captured, per the explicit instruction that protection application is operator-gated).
4. Open a trivial docs-only PR (author != review bot) in that repo and confirm: `automerge-eligibility` goes green, `review-bot` approves via the App after `critic_cli` passes, auto-merge lands it with zero manual click. Then confirm a PR touching a `.ps1`/workflow file is held (OUT-OF-CLASS).
5. Type "approved" (per the plan's checkpoint resume-signal) once both are confirmed, or describe what misfired.

This is documented, not executed, because App creation is an org-owner action outside agent tooling scope.

## Next Phase Readiness
- Everything except the App itself and the live verification is implemented, self-tested, and committed on both repos, each with an open PR.
- 38-03 (root repo protection) is unblocked and was executed in the same session -- it reuses `apply-branch-protection.ps1` unmodified aside from the two new opt-in/opt-out switches added here.
- Blocker for full REQ-1.5.1 closure: the GitHub App creation + live test-PR verification (Task 3 checkpoint), which requires operator action.

---
*Phase: 38-merge-flow-and-backfill*
*Completed: 2026-07-10*
