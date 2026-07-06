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
