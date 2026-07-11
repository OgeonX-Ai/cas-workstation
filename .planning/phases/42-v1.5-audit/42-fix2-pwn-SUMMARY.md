# Phase 42 pre-verification blocker #2: review-bot pwn-request fix

## Repo / PR

- Repo: `Coding-Autopilot-System/.github` (local: `C:\PersonalRepo\portfolio\org-dotgithub`, working worktree: `C:\PersonalRepo\worktrees\org-dotgithub-merge-flow-review-bot`)
- Branch: `feat/merge-flow-review-bot` (existing, stacked on PR #17 as instructed — no new branch created)
- PR: [#17 "feat(38-01): review-bot auto-merge mechanism (classifier + workflow)"](https://github.com/Coding-Autopilot-System/.github/pull/17)

## Verification of the claim before acting

Before editing anything I independently verified the vulnerability via the GitHub API rather than trusting the task description at face value:

- `gh api repos/Coding-Autopilot-System/.github/code-scanning/alerts` initially showed only 2 alerts (both `actions/missing-workflow-permissions`, both already `fixed`) — no alert matching "checkout of untrusted code" existed at the *repo* level yet, because PR-only alerts surface via the PR's check-run, not the repo alert list, until merged.
- Pulling the actual **CodeQL check-run** for PR #17's head commit (`24b9832`) confirmed the real finding: `annotations` showed `"title":"Checkout of untrusted code in a privileged context"`, `path: .github/workflows/review-bot.yml`, `start_line: 59, end_line: 68`, trigger `pull_request_target` — this matched the task's technical claim exactly.
- Two secondary claims in the task did **not** hold up and were not acted on as stated:
  - PR #18 is `fix(release): resolve reusable workflow reference` (an unrelated Phase 39 release-engineering fix) — it has no merge-flow "policy doc threat table." I did not touch PR #18.
  - No reference to `T-38-SEC-PWN` existed anywhere in the repo or `.planning/` prior to this fix; it is a new label I'm introducing consistently in the code comment, note file, and PR comment for traceability, per the task's own instruction to "record" it.

## Root cause

`.github/workflows/review-bot.yml` runs on `pull_request_target` and mints a GitHub App installation token (`pull-requests: write`-capable) before the diff step. The original "Compute PR diff (base...head)" step ran:

```bash
git fetch origin "pull/${{ github.event.pull_request.number }}/head:pr-head" --depth=100
git diff "origin/${{ base }}...pr-head" > pr.diff
```

Fetching the attacker-controllable PR head ref into the runner's local git object database inside a privileged (`pull_request_target`) job is the canonical GitHub Actions "pwn request" pattern, independent of whether the fetched content was subsequently executed.

## Fix (commit `548d95f`, pushed to `feat/merge-flow-review-bot`)

- Removed the `git fetch`/`git diff` step entirely. No PR-head ref is ever fetched, checked out, or merged into the runner's git state.
- The diff is now obtained exclusively via the GitHub API: `gh pr diff <n> --repo <repo>` (HTTPS text response), piped directly into `critic_cli` over **stdin** (`--diff -`), which `critic_cli` already supported (verified against the pinned `autogen` commit `b0524b7`).
- The eligibility classifier (`.github/scripts/classify-automerge-eligibility.ps1`) already sourced its input exclusively from `gh pr view --json files,author` — no change needed there, it was already API-only.
- The only two `actions/checkout` calls remaining in the privileged job are:
  1. The job's own repository, no `ref:` override — under `pull_request_target` this resolves to the base branch, never the PR head.
  2. `Coding-Autopilot-System/autogen`, pinned to trusted commit `b0524b762024237d047fde25b50679da42e1a5e2`, for `critic_cli`.
- Added a deviation beyond the literal task scope (Rule 2 — missing critical functionality / fail-closed correctness): if `gh pr diff` itself fails, the job now hard-stops (`exit 1`) instead of silently treating an empty/failed diff as "zero findings" and proceeding toward approval. This closes a latent bypass that the original code (and a naive stdin rewrite) would have introduced.
- Least-privilege note: the diff-fetch step uses the ambient `github.token` (scoped read-only per the workflow's `permissions:` block), not the App installation token — the App token is reserved for the review/merge steps that actually need write access.

## Docs / traceability

- Added `docs/security/T-38-SEC-PWN-review-bot-pwn-request-mitigation.md` in the PR branch, documenting the finding, mitigation, and verification, and explicitly noting that PR #18 was not touched (no threat table exists there).
- Posted a PR comment on #17 recording the mitigation and the same PR #18 correction: https://github.com/Coding-Autopilot-System/.github/pull/17#issuecomment-4945025118

## Verification

- YAML validated (`python3 -c "import yaml; yaml.safe_load(...)"` — OK).
- Structural check: zero occurrences of `git fetch .*pull/`, `pr-head`, or `actions/checkout` with a PR-head `ref:` remain in `review-bot.yml`.
- Pushed `548d95f` to `feat/merge-flow-review-bot` (`origin/feat/merge-flow-review-bot`, PR #17).
- CodeQL re-ran automatically on the new commit. Check-run `86536956171` on commit `548d95f`: **conclusion `success`**, output title **"No new alerts in code changed by this pull request."** The prior annotation (lines 59-68, "Checkout of untrusted code in a privileged context") is gone.

## Out of scope / not touched

- `automerge-eligibility` check on PR #17 is failing (`OUT-OF-CLASS reason=unable to read PR files/author via gh (fail-closed)`), both before and after this fix. This is a pre-existing, unrelated failure (a separate workflow, `.github/workflows/auto-merge-eligibility.yml`, not `review-bot.yml`) and is out of scope for this pwn-request fix per the scope-boundary rule. Not fixed; flagged here for whoever owns that workflow.
- No merge/approve/label action was taken on PR #17 or #18, per the rules.

## Commits

- `548d95f` — `fix(security): eliminate pwn-request checkout in review-bot privileged job` (2 files changed: `.github/workflows/review-bot.yml`, `docs/security/T-38-SEC-PWN-review-bot-pwn-request-mitigation.md`)

## Self-Check

- FOUND: `C:\PersonalRepo\worktrees\org-dotgithub-merge-flow-review-bot\.github\workflows\review-bot.yml` (modified, YAML-valid)
- FOUND: `C:\PersonalRepo\worktrees\org-dotgithub-merge-flow-review-bot\docs\security\T-38-SEC-PWN-review-bot-pwn-request-mitigation.md`
- FOUND: commit `548d95f` in `git log --oneline --all` on `feat/merge-flow-review-bot`, pushed to `origin/feat/merge-flow-review-bot`
- FOUND: CodeQL check-run `86536956171` on commit `548d95f`, conclusion `success`, "No new alerts in code changed by this pull request"
- FOUND: PR comment https://github.com/Coding-Autopilot-System/.github/pull/17#issuecomment-4945025118

## Self-Check: PASSED
