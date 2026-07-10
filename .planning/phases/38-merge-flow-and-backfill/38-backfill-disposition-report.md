# v1.4 Residual Branch/Worktree Hygiene Backfill -- Disposition Report

**Plan:** 38-02 (REQ-1.5.2, branch + worktree portions)
**Date:** 2026-07-10
**Gate script:** `scripts/squash-aware-branch-gate.ps1` (see Task 1 -- squash-aware, two-dot direct tree compare, fail-closed)
**Predecessor:** `.planning/phases/35-v1.4-verification-and-audit/35-normalization-report.md` (the 6 branches below were "conservatively kept" there because their commit history diverged from default -- a three-dot signal that a squash-merge makes permanently non-empty even after full merge)

---

## Part 1: The 6 Conservatively-Kept Branches

Each branch was evaluated with:

```
pwsh -File scripts/squash-aware-branch-gate.ps1 -RepoPath <portfolio/repo> -Branch <branch> -DeleteSafe -Json
```

`-DeleteSafe` was passed in every run; the gate is fail-closed and only deletes on an empty two-dot diff, so passing it is safe even when the outcome turns out to be RETAIN.

| # | Repo | Branch | Default | Disposition | Corresponding PR | PR State | Deleted? |
|---|------|--------|---------|--------------|-------------------|----------|----------|
| 1 | portfolio/autogen | feat/phase-26-coverage-gates | main | RETAIN | autogen#11 | MERGED | No |
| 2 | portfolio/cas-evals | feat/registry-fetch-smoke-check | main | RETAIN | cas-evals#9 | MERGED | No |
| 3 | portfolio/cas-platform | fix/bicep-lint-api-version-pinning | main | RETAIN | cas-platform#11 | MERGED | No |
| 4 | portfolio/cloud-security-service-model | fix/bicep-lint-api-version-pinning | main | RETAIN | csm#13 | MERGED | No |
| 5 | portfolio/gsd-orchestrator | feat/phase-26-coverage-gates | main | RETAIN | gsd-orchestrator#16 | MERGED | No |
| 6 | portfolio/org-dotgithub | docs/phase-36-refresh | main | RETAIN | .github#14 | MERGED | No |

**Result: 0/6 SAFE-TO-DELETE, 6/6 RETAIN.** No branch was deleted (no empty two-dot diff was found for any of the six). Every RETAIN branch's corresponding PR is MERGED, so every one of the six is flagged below for operator attention as **possible post-merge drift**, per the plan's disposition rule ("if the PR is already MERGED but the tree diff is non-empty, flag it for operator attention").

### Per-branch rationale and tree-diff evidence

**1. portfolio/autogen -> feat/phase-26-coverage-gates (autogen#11, MERGED)**
`git diff origin/main feat/phase-26-coverage-gates --stat` is non-empty (19 files, 100 insertions, 968 deletions), dominated by `.github/workflows/*.yml`, `docs/wiki/*.md` (full deletions of Architecture/Decisions/Home/Operations wiki pages), and `README.md`. This shape -- wiki-doc and workflow-file churn shared verbatim across all six branches below -- is not this feature's own content; it is `main` having moved on since the squash-merge landed (docs/wiki restructuring and CI workflow updates in later phases). **FLAG: post-merge drift.** RETAIN is correct (fail-closed); no unique unmerged work identified, but the branch is left in place rather than deleted on an inference, per the gate's non-empty-diff contract.

**2. portfolio/cas-evals -> feat/registry-fetch-smoke-check (cas-evals#9, MERGED)**
`git diff origin/main feat/registry-fetch-smoke-check --stat` is non-empty (9 files, 10 insertions, 169 deletions), same `.github/workflows/*.yml` + `docs/wiki/*.md` + `README.md` shape as above. **FLAG: post-merge drift.**

**3. portfolio/cas-platform -> fix/bicep-lint-api-version-pinning (cas-platform#11, MERGED)**
`git diff origin/main fix/bicep-lint-api-version-pinning --stat` is non-empty (9 files, 11 insertions, 208 deletions), same shared shape. **FLAG: post-merge drift.**

**4. portfolio/cloud-security-service-model -> fix/bicep-lint-api-version-pinning (csm#13, MERGED)**
`git diff origin/main fix/bicep-lint-api-version-pinning --stat` is non-empty (10 files, 11 insertions, 199 deletions), same shared shape plus a `.github/workflows/ci.yml` line. **FLAG: post-merge drift.**

**5. portfolio/gsd-orchestrator -> feat/phase-26-coverage-gates (gsd-orchestrator#16, MERGED)**
`git diff origin/main feat/phase-26-coverage-gates --stat` is non-empty (18 files, 55 insertions, 801 deletions). In addition to the shared workflow/wiki/README shape, this one also shows `src/GsdOrchestrator*` files (e.g. `LoopCoordinator.cs`, `FailureState.cs`, `CheckpointCorruptionTests.cs`) -- consistent with `main` having continued to evolve the loop-coordinator code in later phases (27/28) after this branch's PR merged; the local branch never rebased onto that later work. **FLAG: post-merge drift.**

**6. portfolio/org-dotgithub -> docs/phase-36-refresh (.github#14, MERGED)**
`git diff origin/main docs/phase-36-refresh --stat` is non-empty (4 files, 10 insertions, 10 deletions), limited to the same shared `.github/workflows/*.yml` churn. **FLAG: post-merge drift.**

### Operator note

All six flags share the same root cause: `main` in each sub-repo has advanced (workflow-file and docs/wiki updates, and in gsd-orchestrator's case further loop-coordinator work) since each branch's PR was squash-merged, and none of the six local branches were ever rebased or deleted afterward. The squash-aware gate correctly refuses to delete any of them because their trees are no longer identical to current `main` -- but the non-identity is `main` drifting away, not the branch carrying unmerged work. Recommended operator follow-up (out of scope for this plan, which is dispositioning-only per its own instruction not to force-merge/push): once confirmed no branch has locally-only work beyond its already-merged PR, delete these six local branches directly (`git branch -D <branch>` on each, since content is already merged upstream), or re-run this gate after each corresponding primary checkout is fast-forwarded/rebased onto current `main`.

No branch was deleted on a non-empty tree diff (fail-closed proven in Task 1's Pester suite and reproduced here operationally: `Deleted: false` in every one of the six live runs above).

---

## Part 2: The 2 Worktree Leftovers

### 2a. `C:/PersonalRepo/worktrees/v1.1-cas-contracts` -- orphaned/broken worktree

**Disposition: REMOVED + PRUNED.**

- `git -C C:/PersonalRepo/portfolio/cas-contracts worktree list --porcelain` showed only the primary checkout (`C:/PersonalRepo/portfolio/cas-contracts`, branch `main`) -- no `v1.1-cas-contracts` entry.
- The stray `.git` file inside the directory pointed to `gitdir: /mnt/c/PersonalRepo/portfolio/cas-contracts/.git/worktrees/v1.1-cas-contracts` -- a WSL-style path that does not resolve on Windows, and `cas-contracts/.git/worktrees/` did not even exist (0 entries), confirming the registration had already been torn down on the cas-contracts side, leaving pure orphaned directory residue.
- `git status` inside the directory failed with `fatal: not a git repository: /mnt/c/PersonalRepo/portfolio/cas-contracts/.git/worktrees/v1.1-cas-contracts` -- no readable HEAD, so no unpushed work could exist to lose.
- Ran `git -C portfolio/cas-contracts worktree prune -v` (no output -- nothing to prune, confirming no dangling registration).
- Removed the stale directory directly (`Remove-Item`/`rm -rf` on the single named orphaned path -- not `git clean`).
- Re-ran `git worktree prune -v` on both `portfolio/cas-contracts` and the root repo -- both clean, no dangling registration.
- Confirmed: `C:/PersonalRepo/worktrees/v1.1-cas-contracts` no longer exists.

### 2b. `C:/PersonalRepo/worktrees/pr-maf-workers` -- NOT a registered worktree (stray execution-sandbox copy)

**Disposition: MOVED to `C:/PersonalRepo/scratch/orphaned-worktrees/pr-maf-workers/`.**

**Step 1 -- registration verified absent:** No `.git` file or directory inside `pr-maf-workers`. `git -C C:/PersonalRepo worktree list --porcelain` (root) and `git -C portfolio/autogen worktree list --porcelain` both list only their own real worktrees (the four Claude Code phase worktrees on the root side; only the primary checkout on the autogen side) -- `pr-maf-workers` appears in neither. Confirmed NOT a registered git worktree; the `git worktree remove` guard/unpushed-commit-count path from `<key_links>` is a no-op here by design, per the plan's Task 3 correction.

**Step 2 -- content-uniqueness probe:** Directory contents mirror `portfolio/autogen`'s structure (`maf_starter/`, `autogen_dashboard/`, `autogen_starter/`, `entities/`, `tests/`, plus `.venv/`). Probed all 66 non-`.venv`, non-`__pycache__` tracked-shape files (every file under the directory except the venv and bytecode cache) with:

```
git hash-object <file>
git -C portfolio/autogen log --all --format=%H -1 --find-object=<hash>
```

Result: **62/66 files matched an existing blob somewhere in `portfolio/autogen`'s full history** (`--all`), including every one of the largest/newest files (`autogen_dashboard/static/app.js`, `autogen_dashboard/session_runner.py`, `maf_starter/orchestration.py`, `maf_starter/provider_fallback.py`, `maf_starter/loop_worker_cli.py`, `maf_starter/approval_policy.py`, etc.) -- proving this directory is a stray snapshot taken from `autogen` at an earlier point, not novel work.

The remaining 4 files (`AGENTS.md`, `entities/context.md`, `autogen_dashboard/context.md`, `maf_starter/context.md`) returned no `--find-object` match. Deeper check: all 4 paths exist in `portfolio/autogen`'s CURRENT working tree today (`entities/context.md`, `autogen_dashboard/context.md`, `maf_starter/context.md` are byte-identical; `AGENTS.md` differs only because the live copy in `autogen` is STRICTLY NEWER -- it contains everything the sandbox copy has plus an added "NO AZURE" hard-lock section and one extra context-directory line, i.e. the sandbox copy is a subset/older revision, not unique content). These 4 files were never committed to autogen's git history (hence no `--find-object` hit), but their content already lives, uncommitted, in the real `portfolio/autogen` checkout right now.

A recursive diff (`diff -rq`, scoped to the mirrored top-level directories `maf_starter/`, `tests/`, `entities/`, `autogen_dashboard/`, `autogen_starter/`) shows most files "differ" from autogen's CURRENT tree -- but that is expected: autogen has continued development since this snapshot was taken (new files such as `maf_starter/cli.py`, `tests/smoke_test.py`, `autogen_dashboard/blueprints.py` exist only in the live repo). Divergence from the current tip is not the uniqueness test; the `--all`-history `--find-object` probe above is, and it found no unique blob.

**Conclusion: no unique content found.** Per the plan's move-not-delete path:

```
Move-Item C:/PersonalRepo/worktrees/pr-maf-workers -> C:/PersonalRepo/scratch/orphaned-worktrees/pr-maf-workers
```

The move (including the `.venv/` subdirectory) completed in a single operation with no unlinkable-file failure this time; nothing was left behind at the source, and the full directory (all 172 entries, including `.venv/lib64` and `pyvenv.cfg`) landed intact at the destination. Verified: source path gone, destination path present with contents. The directory was never `git worktree remove`d (correctly, since it was never registered) and was never deleted outright.

### Workspace-health sweep (post-disposition)

```
pwsh -File scripts/workspace-health.ps1 -Json
```

No `stale-worktree`, `worktree-missing`, or `worktree-unix-path` findings for `root` or `portfolio/cas-contracts` (the two categories/repos this task's dispositions affect). Remaining findings across other repos (dirty/off-default-branch/credential-helper/non-ascii-ps1/unpushed on unrelated repos such as Promptimprover, ci-autopilot, gsd-orchestrator, gemini-nano, etc.) are pre-existing and out of scope for this plan -- foreign dirty files and unrelated repo state are untouchable per the Agent-Hierarchy concurrency rule.
