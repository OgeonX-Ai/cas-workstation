# Task F Summary: root repo — gitattributes, gitmodules, CI, doc drift, clutter, atomic commits

**Repo:** C:\PersonalRepo
**Branch:** master (unchanged, no branch switch/create)
**Remote:** https://github.com/OgeonX-Ai/cas-workstation.git

## Actions Taken

### STEP 1 — .gitattributes (H5)
Created `.gitattributes`: `* text=auto` baseline; `eol=lf` for
`*.json *.md *.yml *.yaml *.js *.ts`; `eol=crlf` for `*.ps1 *.psm1`; `binary`
for `*.png *.pdb *.dll *.exe`.

### STEP 2 — .gitmodules + gitlink (W3, root side)
Created `.gitmodules` with `[submodule "gemini-nano"]`, `path = gemini-nano`,
`url = https://github.com/Coding-Autopilot-System/gemini-nano.git`. Confirmed
the working-tree gitlink already pointed at `8e8b838535fadede178fb52d5dfb395a8b37d6f1`
(Task D's pushed SHA, verified against `Coding-Autopilot-System/gemini-nano`
origin/master) — staged it as-is via `git add gemini-nano`.

### STEP 3 — Root Pester CI (H1)
Created `.github/workflows/ci.yml`: `on: [push, pull_request]`,
`windows-latest`, `permissions: contents: read`, `timeout-minutes: 15`,
installs Pester and runs `Invoke-Pester -Path tests/*.Tests.ps1 -CI`
(covers `Loop.Pilot.Tests.ps1`, `Workstation.Contract.Tests.ps1`). Verified
ASCII-only (0 non-ASCII bytes).

### STEP 4 — Clutter relocation (H4)
Moved into `scratch/` (gitignored): `scripts/Cas.Workstation.psm1.bak`,
`scripts/classify-engineering-task.ps1.bak`, `rollback_phase26.ps1`,
`test-local-llm.js`, `test-mcp.js`, `test-tool.js`,
`deep-research-report (4).md`, `ChatGPT Image Jun 30, 2026, 12_32_59 PM.png`,
`rules.json`. Added `scratch/` to root `.gitignore`.

**Discovery during verification:** five of these files (`ChatGPT Image...png`,
`deep-research-report (4).md`, `test-local-llm.js`, `test-mcp.js`,
`test-tool.js`) were **already tracked in git** (committed previously in
`130dc55 chore(sync): snapshot local changes`), contrary to the plan's
"untracked clutter" framing. Moving them to gitignored `scratch/` therefore
left them as tracked-but-deleted in the working tree. I committed the
deletions explicitly (see commit `784eb2f` below) so master no longer carries
them — this is a Rule 1/Rule 3 auto-fix (leaving tracked-deleted files
uncommitted would have left the repo dirty and violated the plan's "no
untracked/modified leftovers" done-criterion). The other four clutter items
(`.bak` files, `rollback_phase26.ps1`, `rules.json`) were never tracked, so
their relocation required no commit action.

### STEP 5 — GLOBAL_AGENTS.md drift (H6)
Updated the Workspace Layout section to list all 12 `portfolio/*` sub-repos
(verified against actual `ls portfolio/` output): added `cas-evals`,
`cas-contracts`, `cas-platform`, `autopilot-core`, `autopilot-demo`,
`ci-autopilot`, `cas-workstation`, `org-dotgithub`. Added a note documenting
that the ROOT repo pushes to `OgeonX-Ai/cas-workstation` while
`portfolio/cas-workstation` pushes to `Coding-Autopilot-System/cas-workstation`
(same name, two orgs).

### STEP 6 — Atomic commits

All `.ps1` files touched (new and pre-existing) were verified byte-for-byte
ASCII-only before commit, per the task's PowerShell 5.1 BOM-less-ANSI warning.
Two files in the `feat(scripts)` group — `scripts/pilot-setup.ps1` and
`scripts/run-v1.3-pilot.ps1` — contained non-ASCII em-dashes (U+2013) and
non-breaking hyphens (U+2011) plus one smart quote; these were normalized to
plain ASCII hyphens before staging (documented as a deviation below).
`scripts/workspace-health.ps1` was confirmed clean (0 non-ASCII bytes) as
stated in the task.

| # | Commit | Message | Files changed |
|---|--------|---------|----------------|
| 1 | `52758b6` | chore(git): add .gitattributes and .gitmodules; ignore scratch/ | 4 (+23/-1) |
| 2 | `46eeacb` | ci(workstation): add Pester CI workflow | 1 (+24) |
| 3 | `8dcf48f` | docs(agents): correct GLOBAL_AGENTS workspace layout and repo targets | 1 (+67) |
| 4 | `748e01c` | chore(engineering-os): commit policy drift | 20 (+807/-33) |
| 5 | `e15db16` | docs(planning): commit v1.3 milestone records | 12 (+294) |
| 6 | `7bab3d1` | docs: add improvement-backlog, azure-rollout-plan, requirements.txt | 4 (+220) |
| 7 | `5a17ab7` | feat(scripts): add pilot, gsd-progress, ci runner, and workspace-health scripts | 5 (+277) |
| 8 | `c11f44c` | chore(refiner): update blackboard state | 1 (+487/-487) |
| 9 | `e3b5bca` | docs(planning): extend v1.4 roadmap with portfolio-governance track | 7 (+189) |
| 10 | `784eb2f` | chore(git): remove clutter files relocated to scratch/ | 5 (-350) |

Full SHAs:
- `52758b6b2ed41345b0e003e3e85bcfe311378384`
- `46eeacb802388fa853c22706ee0128ef456470c3`
- `8dcf48fd9d430292321300b8852c419614c54c41`
- `748e01c792f4adae71810f77992774a9fdc0bcd9`
- `e15db169973f0672ac6fe9fe32cb0554a9b30725`
- `7bab3d1f82234de192b7f7c403ce036045ce68c1`
- `5a17ab771191de57bfdf28f2f96098a6019688b7`
- `c11f44c6e04e3b50732dc74cccb30be5f602d369`
- `e3b5bca68aa5470e88ff2f77498f2c7f7b178996`
- `784eb2f8e86fbb32c39a295f4e88d63bd9bd0bf8`

Before every commit: staged diff was scanned for token/key/password/secret
literals and known credential-format patterns (`sk-`, `ghp_`, `gho_`,
`github_pat_`, AWS `AKIA...`, Slack `xox[baprs]-`, Google `AIza...`,
`-----BEGIN`). All hits were benign (policy statements about *not* hardcoding
secrets, `tokens_prompt`/`tokens_completion`/`CancellationToken` code
identifiers, and task-id strings in `.refiner/blackboard.json` that
superficially matched the AWS-key regex substring but are not credentials).
No actual secret material was found or committed.

`.planning/quick/` was deliberately excluded from every commit per the task's
explicit instruction (superseding the plan's suggested grouping, which had
proposed folding `worktrees-audit.md` into the v1.3 milestone commit).

### STEP 7 — PUSH: SKIPPED (deviation, see below)

## Deviations from Plan

1. **[Rule 3 — blocking issue] Non-ASCII characters in `.ps1` files staged for
   commit.** `scripts/pilot-setup.ps1` and `scripts/run-v1.3-pilot.ps1`
   contained em-dashes/non-breaking-hyphens/smart-quotes that would have hit
   the same PowerShell 5.1 BOM-less-ANSI bug called out in the task. Fixed
   inline (replaced with plain ASCII hyphens) before staging into the
   `feat(scripts)` commit. No test suite exists for these scripts to
   re-run; verified via byte-level scan (0 non-ASCII bytes remaining).

2. **[Rule 1 — bug / truthfulness] Five "clutter" files were already tracked
   in git, not untracked as the plan's facts block stated.** Relocating them
   to gitignored `scratch/` without committing the resulting deletions would
   have left `git status` non-clean and (once master gets pushed) left the
   files' historical tracked state ambiguous. Committed the deletions
   explicitly in a dedicated `chore(git): remove clutter files relocated to
   scratch/` commit (`784eb2f`) so the truthfulness gate holds — the commit
   message accurately describes what happened (removal of previously-tracked
   clutter, not addition of new content).

3. **STEP 7 (push) SKIPPED per explicit orchestrator instruction** in this
   task's brief: "the orchestrator makes one final docs commit after you and
   performs the single push." Root repo is currently 20 commits ahead of
   `origin/master` (10 pre-existing + 10 from this task). No push was
   attempted; `git rev-list --count origin/master..HEAD` = 20 at hand-off.

## Verification

Automated verify command from plan:
```
cd "C:/PersonalRepo" && test -f .gitattributes && test -f .gitmodules && grep -q "path = gemini-nano" .gitmodules && test -f .github/workflows/ci.yml && grep -q "scratch/" .gitignore && (git ls-files --error-unmatch rules.json 2>/dev/null && echo FAIL || echo OK)
```
**Output:** `OK`

Final `git status --short`:
```
?? .planning/quick/
```
Only the orchestrator-owned `.planning/quick/` directory remains untracked.
No other untracked or modified files remain anywhere in the root repo.

## Leftovers

None outside `.planning/quick/` (expected — reserved for the orchestrator's
final docs commit, per this task's explicit scope boundary).

## For the Orchestrator

- Gemini-nano gitlink pointer committed at `8e8b838535fadede178fb52d5dfb395a8b37d6f1`
  (confirmed pushed to `Coding-Autopilot-System/gemini-nano.git` per Task D).
- `git rev-list --count origin/master..HEAD` = 20 (unpushed) at hand-off from
  Task F. The orchestrator's final docs commit (adding `.planning/quick/*`)
  plus the single `git push origin master` remain outstanding.
- Recommend re-running `scripts/workspace-health.ps1` after the final push to
  confirm the `unpushed` and `gitlink-no-gitmodules` findings clear.
