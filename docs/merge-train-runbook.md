# CAS Polyrepo Merge-Train Runbook

Repeatable procedure for landing a batch of PRs across the 13 `Coding-Autopilot-System` repos. First drafted 2026-07-06 for Phase 30 (Release Train & Branch Hygiene); keep updated as the process evolves.

## Preconditions

- `gh auth status` OK with admin on the org repos.
- No dirty working trees in `portfolio/*` (run the workspace-health sweep first).
- Know which PRs are self-authored: branch protection requires 1 approving review and blocks self-authored merges even for admins while `enforce_admins` is on.

## Merge order

1. **`.github` (org-dotgithub)** — shared workflow templates land first so downstream CI reruns pick them up.
2. **Dependabot PRs** — low-risk version bumps; CI must be green.
3. **`chore/governance-hardening`** batch — the 8-repo sweep.
4. **Repo-specific branches** — `fix/pages-release-ordering` (cas-contracts), `ci/phase-09-workflow-hardening` (cas-reference-product).

## Per-repo procedure

```powershell
$repo = "Coding-Autopilot-System/<name>"
# 1. Verify CI green on the PR
gh pr checks <num> --repo $repo
# 2a. Reviewed PR (or dependabot): normal merge
gh pr merge <num> --repo $repo --squash --delete-branch
# 2b. Self-authored + blocked: temp-relax enforce_admins (re-enable IMMEDIATELY after)
gh api -X DELETE "repos/$repo/branches/main/protection/enforce_admins"
gh pr merge <num> --repo $repo --squash --delete-branch --admin
gh api -X POST "repos/$repo/branches/main/protection/enforce_admins"
# 3. Confirm protection restored
gh api "repos/$repo/branches/main/protection/enforce_admins" --jq .enabled   # must be true
```

## After the train

For every local checkout under `portfolio/`:

```powershell
git switch main   # Promptimprover: master
git pull --ff-only
git branch -d <merged-branch>
```

Then:
- `git worktree prune` in each repo that had worktrees on merged branches.
- Run the workspace-health sweep; expect 0 findings.
- Record the train (date, PRs landed, any protection relaxations) in `.planning/STATE.md`.

## Safety rules

- Never leave `enforce_admins` disabled — relax and restore in the same sitting, verify with the `--jq .enabled` check.
- Never merge a PR with red CI to "unblock" the train; fix or defer it.
- If two PRs on one repo conflict, land oldest first, rebase the second via `gh pr update-branch`.

## Reusable workflow pin rule

Pin reusable workflows to the **merged `main` commit SHA**, never a PR branch tip
— squash-merge deletes branches and strands the SHA.

Learned 2026-07-11 (Phase 42 pre-verification blocker #1): all 13 repos'
`.github/workflows/release-please.yml` pinned the reusable workflow call to
`f288e5e3b67b29a2c08880b76da7b852f4a132d0`, the tip commit of the source
branch for `.github` PR #16. When that PR squash-merged, the branch was
deleted and the pinned SHA became unreachable — every push-triggered
`release-please` run failed with "workflow was not found" from that point
on. Squash-merge rewrites history into a single new commit on `main`; the
original branch-tip commits (and any SHA pinned to one of them) are never
part of that history and become orphaned once the source branch is deleted.

Before pinning a `uses: <repo>/.github/workflows/<file>.yml@<sha>` reference:

1. Confirm the SHA is on the target repo's default branch, not just a PR
   branch: `gh api repos/<org>/<repo>/compare/<default>...<sha> --jq .status`
   must return `identical` or `behind` (never `diverged` or `ahead` only from
   an unmerged branch).
2. Confirm the referenced workflow file exists at that SHA.
3. Prefer pinning to the exact merge commit SHA on `main`, not the tip of a
   feature branch that is about to be squash-merged — the two are usually
   different commits and only the merge commit survives.
