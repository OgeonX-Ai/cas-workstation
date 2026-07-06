# Worktrees Audit — C:\PersonalRepo\worktrees\

Generated: 2026-07-06T09:32:50Z (Task E of quick task 260706-h8b)

Scope: 14 directories under `C:\PersonalRepo\worktrees\`. Each is a registered
git worktree of a DIFFERENT owning repo (gitdir points into
`portfolio/<repo>/.git/worktrees/...` or root `.git/worktrees/...`). Every
worktree was queried against its OWNING repo, not root.

**Environment note:** All 14 worktrees were originally registered from a WSL
session (gitdir/worktree pointers stored as `/mnt/c/PersonalRepo/...` paths),
except `cas-workstation-audit` which used native Windows paths. This executor
session runs plain Git-for-Windows Bash with no `/mnt/` mount, so the stored
paths do not resolve directly (`git -C <worktree> ...` fails with
"not a git repository", and `git worktree list` from the owning repo marks
10 of them `prunable` purely because of this path-format mismatch — NOT
because the directories are actually missing). All 11 worktrees whose admin
metadata still exists on disk were queried successfully using
`git --git-dir=<owner>/.git/worktrees/<name> --work-tree=<actual-windows-path>`
to bypass the broken internal path pointer. This is a read-only diagnostic
technique — no metadata was rewritten.

## Findings Table

| Worktree | Owning repo | Branch | Dirty | Last commit | Merged? | Recommendation |
|---|---|---|---|---|---|---|
| archive-loop-engineering | root (C:\PersonalRepo) | unknown (no admin metadata) | unknown | dir mtime 2026-07-02 | unknown | **MANUAL** — root repo has NO `.git/worktrees/` admin directory at all; this worktree is not present in `git -C C:\PersonalRepo worktree list`. It is an orphaned directory with no git backing to query safely. |
| cas-goal-contract | portfolio/cas-contracts | codex/goal-contract | clean | 2026-06-30 18:58:52 +0300 (8eb1270) | No — not an ancestor of origin/main; branch does not exist on origin (local-only, never pushed) | KEEP — clean but unmerged and unpushed. Deleting would lose unpushed work. |
| cas-operator-cloud | portfolio/cas-reference-product | codex/operator-cloud-boundaries | clean | 2026-07-01 03:21:35 +0300 (d1ede61) | No — not an ancestor of origin/main; branch not on origin | KEEP — clean but unmerged and unpushed. |
| cas-workstation-audit | portfolio/cas-workstation | audit/enterprise-hardening-20260611 | clean | 2026-06-11 00:35:47 +0300 (0f0d999) — stale, 25 days old | No — not an ancestor of origin/main; branch not on origin | KEEP — clean but unmerged and unpushed, despite being stale. Flag for manual review/close-out given age. |
| gsd-loop-stability | portfolio/gsd-orchestrator | codex/loop-stability | clean | 2026-07-01 03:45:49 +0300 (5cef5ef) | No — not an ancestor of origin/main; branch not on origin | KEEP — clean but unmerged and unpushed. |
| loop-engineering | root (C:\PersonalRepo) | unknown (no admin metadata) | unknown | dir mtime 2026-07-01 | unknown | **MANUAL** — same as archive-loop-engineering: root has no worktrees admin dir; orphaned directory, no git backing to safely audit or prune. |
| loop-learning | portfolio/Promptimprover | codex/loop-learning | clean | 2026-07-01 03:45:13 +0300 (e24a328) | No — not an ancestor of origin/master; branch not on origin | KEEP — clean but unmerged and unpushed. |
| maf-workers | portfolio/autogen | codex/maf-workers | clean | 2026-07-01 03:45:10 +0300 (9f57bac) | No — not an ancestor of origin/main; branch not on origin | KEEP — clean but unmerged and unpushed. |
| pr-gsd-loop | portfolio/gsd-orchestrator | codex/loop-stability-pr | clean | 2026-07-03 04:46:02 +0300 (e168e05) | No — not an ancestor of origin/main; branch not on origin | KEEP — clean but unmerged and unpushed (this is the "PR-copy" variant of gsd-loop-stability; still not merged upstream). |
| pr-loop-learning | portfolio/Promptimprover | codex/loop-learning-pr | clean | 2026-07-01 15:28:06 +0300 (7327e9f) | No — not an ancestor of origin/master; branch not on origin | KEEP — clean but unmerged and unpushed. |
| pr-maf-workers | portfolio/autogen | codex/maf-workers-pr | clean | 2026-07-03 04:46:00 +0300 (25c2021) | No — not an ancestor of origin/main; branch not on origin | KEEP — clean but unmerged and unpushed. |
| pr-operator-cloud | portfolio/cas-reference-product | codex/operator-cloud-boundaries-pr | clean | 2026-07-01 15:22:52 +0300 (a665e97) | No — not an ancestor of origin/main; branch not on origin | KEEP — clean but unmerged and unpushed. |
| v1.1-cas-contracts | portfolio/cas-contracts | codex/v1.1-sdlc-contracts | **yes** — 3 modified (CHANGELOG.md, docs/VERSIONING.md, tests/contracts.test.mjs) + 3 untracked (examples/v1.1/, schemas/v1.1/, scripts/sdlc-profile.mjs, tests/sdlc-profile.test.mjs) | 2026-07-01 23:10:27 +0300 (3f38259, "Publish bounded v1 goal and lifecycle contracts (#9)") | **Committed HEAD is merged** — `3f38259` is an ancestor of origin/main (landed via PR #9) | KEEP (dirty overrides merged) — the worktree's last COMMIT is fully merged/pushed, but the working tree currently holds ~6 files of uncommitted WIP beyond that commit. Never force-remove a dirty tree per plan rule. Recommend the owner either commit/push the WIP or explicitly discard it before this becomes prunable. |
| v1.1-sdlc-engine | root (C:\PersonalRepo) | unknown (no admin metadata) | unknown | dir mtime 2026-07-03 | unknown | **MANUAL** — same as the other two root-owned entries: no `.git/worktrees/` admin dir exists under C:\PersonalRepo\.git, and `git worktree list` does not list it. Orphaned directory. |

## Summary

- **Total worktrees audited:** 14
- **PRUNE (actually removed this run):** 0
- **KEEP:** 11 (all clean-but-unmerged-and-unpushed, plus 1 merged-but-dirty)
- **MANUAL:** 3 (root-owned entries with no git worktree admin metadata — `archive-loop-engineering`, `loop-engineering`, `v1.1-sdlc-engine`)

**Zero worktrees met the PRUNE bar** (clean AND fully merged into the owning
repo's default branch AND pushed). Every branch that has actual commits is
either (a) not yet merged upstream, (b) not pushed to origin at all (purely
local `codex/*` branches), or (c) merged but currently dirty with uncommitted
work. No `git worktree remove` or `git worktree prune` commands were run
against any owning repo, because no worktree qualified.

## Root-cause note on the 3 MANUAL entries

`C:\PersonalRepo\.git` has no `worktrees/` subdirectory at all — the root
repo's own `git worktree list` returns only the primary checkout
(`C:/PersonalRepo b4e0868 [master]`) with zero linked worktrees. This means
the git metadata for `archive-loop-engineering`, `loop-engineering`, and
`v1.1-sdlc-engine` was lost or never survived a migration (most likely the
WSL→Windows path switch broke these registrations irrecoverably, whereas the
sub-repo-owned worktrees still retain valid — if WSL-path-formatted —
metadata under their respective `portfolio/*/.git/worktrees/`). Because there
is no admin directory to run `git worktree remove` against, and the plan
explicitly forbids force-removing anything not provably safe, these three are
classified MANUAL rather than PRUNE or KEEP. A human should inspect the
`.planning/` contents of each directory (all three contain PROJECT.md,
REQUIREMENTS.md, and related planning docs suggesting they were feature
working directories) to decide whether their file contents are still needed
before manually deleting the plain directories (`rm -rf`, no git operation
possible) or re-registering them as proper worktrees.

## Verification

Automated verify command from the plan (Task E):

```
test -f .planning/quick/260706-h8b-workspace-integrity-hardening-batch/worktrees-audit.md && grep -qi "recommendation" .planning/quick/260706-h8b-workspace-integrity-hardening-batch/worktrees-audit.md && echo OK || echo FAIL
```

Output:

```
OK
```
