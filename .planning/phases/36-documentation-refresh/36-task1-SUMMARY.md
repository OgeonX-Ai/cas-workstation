# Phase 36 Task 1: README Refresh + Wiki Trees for Core Repos — Summary

**Scope:** 36-03-PLAN.md Task 1 (docs/wiki trees), plus the applicable 36-01/36-02
README-refresh tasks, for the five control/execution/governance core repos: gsd-orchestrator,
autogen, Promptimprover, cas-contracts, cas-evals.

## Method

- Created one detached worktree per repo under `.worktrees-phase36-task1/<repo>` (Windows
  paths), branched `docs/phase-36-refresh` from `origin/<default>` (`main` for four repos,
  `master` for Promptimprover), so the five existing checkouts under `portfolio/<repo>`
  (several of which had pre-existing uncommitted local changes on unrelated branches) were
  never touched. Verified via `git status --short` on each original checkout before and after
  — unchanged.
- Enumerated every repo's open PRs via `gh pr list` before writing anything, and re-verified
  the specific PRs referenced in each plan's `<repo_facts>` via `gh pr view --json
  state,mergedAt` at execution time (all confirmed `OPEN`, `mergedAt: null`).
- Read each repo's README, CI workflows, `docs/architecture.md`, `docs/adr/`, and
  `.planning/phases/` before writing any claim, per the verify-before-claim rule.
- Applied the applicable 36-01/36-02 README task on the same branch/PR as the wiki work
  (36-01 Task 1 for gsd-orchestrator + autogen; 36-01 Task 2's Promptimprover half; 36-02
  Task 1's cas-contracts half; 36-02 Task 2's cas-evals half). cas-reference-product and
  cas-platform (also in 36-01 Task 2 / 36-02 Task 1) and cloud-security-service-model (36-02
  Task 2) were already covered by a separate prior execution (`36-task2-SUMMARY.md`) — not
  duplicated here.
- Added `docs/wiki/{Home,Architecture,Operations,Decisions}.md` to every repo. Every
  Architecture.md has the repo-specific Mermaid diagram called for in 36-03-PLAN.md plus one
  `codex:generate-image` placeholder in the exact `docs/VISION.md` format. Every wiki page and
  README ends with `<!-- docs-verified: <sha> <date> -->`.
- Pushed each branch and opened one PR per repo via `gh pr create` (PR-only, never merged or
  approved — confirmed `state: OPEN`, `mergeable: MERGEABLE` on all five after creation).
  Removed all five worktrees after PR creation.

## Per-repo notes

### gsd-orchestrator (README + wiki)
- README: removed the stale static "35 tests passing" badge (grep found 218 `[Fact]`/
  `[Theory]` attributes across 36 test files — the badge was unverifiable and clearly stale;
  removed per the plan's "replace or remove if stale" instruction rather than asserting an
  unverified new count). Added a "Test Coverage" section stating accurately that `main`
  collects and uploads coverage but does not enforce a threshold, and that a ratcheted
  `branch-rate` gate is in progress (PR #16) — corrected from an initial draft that wrongly
  assumed `main` already had a permanently-red line-rate enforce step (see Deviations).
- Architecture.md: goal state-machine Mermaid, with an explicit section contrasting current
  `main` failure handling (SDLC-rollback-then-`Failed`) against the Phase 28-01 typed-failure
  retry/halt design — which is **not on `main` and not in any open PR**; it exists only on a
  local, unpushed branch (`feat/phase-28-fault-injection`) in the operator's workstation
  checkout. Flagged explicitly rather than described as "in progress (PR #N)" since no PR
  exists (see Deviations).
- Operations.md: verified `dotnet restore/build/test` commands and the seven-step `ci.yml`
  sequence directly from the workflow file.
- Decisions.md: indexes the repo's own 19-phase `.planning/phases/` history and the three open
  PRs (#16, #17, #18).
- HEAD SHA verified: `a01b130c98cb7833d45cc7406f6002009f33557a`.
- PR: https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/19

### autogen (README + wiki)
- README: added a "Test Coverage" section under "Evidence And Evaluation Posture" — verified
  no `.coveragerc` or `--cov-fail-under` exists on `main` (PR #11 open, adds both), phrased
  as in-progress with the PR body's own recorded validation numbers (~73.3% total, ~54.6%
  branch coverage).
- Architecture.md: worker fan-out + telemetry boundary + critic gate Mermaid. Verified
  `WorkerBoundary` (worker fan-out) is landed on `main`; verified `maf_starter/telemetry.py`
  does not exist on `main` (PR #12, "in progress") and no critic module exists on `main`
  (PR #14, "in progress").
- Operations.md: verified setup/run/test commands and the eight-step `ci.yml` matrix job.
- Decisions.md: indexes the repo's 7-phase `.planning/phases/` history and four open PRs
  (#11, #12, #13, #14).
- HEAD SHA verified: `e52e6aa9383a11722bbf92f95c21ff39feb3dd65`.
- PR: https://github.com/Coding-Autopilot-System/autogen/pull/15

### Promptimprover (README + wiki)
- README: unchanged except for the appended freshness footer, per 36-01 Task 2's instruction
  to preserve the already-strong existing content.
- Architecture.md: governance/blackboard flow Mermaid, documenting `AgenticBlackboard`
  (`src/core/blackboard.ts`) — real code read directly, not inferred: `AgentIntent`/
  `SystemLog`/last-refinement records, project-scoped storage under `.refiner/`, a serialized
  write queue guarding concurrent-write corruption.
- Operations.md: verified installer scripts, `release:verify` script chain (read directly from
  `universal-refiner/package.json`), and the two-job `ci.yml` (`build-and-test` +
  `acceptance` matrix).
- Decisions.md: indexes the repo's single-phase (`01-fs-watcher`) `.planning/` history plus
  the two open PRs (#27, #28).
- HEAD SHA verified: `101f63d702e5c0ab8052c8e0c67a104d8edfbddb`.
- PR: https://github.com/Coding-Autopilot-System/Promptimprover/pull/29

### cas-contracts (README + wiki) — highest-risk item in this batch
- README: rewrote the two-sentence "Adoption" claim that previously stated the dead
  `schemas.coding-autopilot.dev` domain was "authoritative" as unqualified fact while PR #18
  actively rewrites that exact claim. New text states the Pages registry is authoritative
  *today*, names the specific unresolvable domain and the 22 affected schemas (grepped
  directly), and frames the `$id` rewrite as in-progress (PR #18, confirmed `OPEN` via
  `gh pr view`).
- Architecture.md: schema-versioning + Pages registry publishing pipeline Mermaid, built from
  a direct read of `.github/workflows/pages.yml` and `docs/DISTRIBUTION.md` (which already
  carried more accurate, qualified language than the old README — used as the accuracy
  reference for the README fix).
- Operations.md: verified `npm test`, `npm run validate`, `build:registry`/`validate:registry`
  commands, and the pages/ci/compatibility/codeql workflow set.
- Decisions.md: indexes the repo's `02-compatibility-automation-and-distribution` phase and
  flags PR #18 as the highest-risk open item, PR #19 (SHA-pinning) as the other.
- HEAD SHA verified: `991c3606b148ab42134e505f4cf110afb8cb8e6b`.
- PR: https://github.com/Coding-Autopilot-System/cas-contracts/pull/20

### cas-evals (README + wiki)
- README: unchanged except for the appended freshness footer. Confirmed no fake coverage
  badge exists (only CI/CodeQL badges) and confirmed the registry-fetch smoke check
  (`tests/test_registry_check.py`, PR #9) is not present on `main` and not mentioned anywhere
  in the current README — no new section needed, footer only.
- Architecture.md: evidence-gate flow Mermaid (offline + opt-in live reference-product modes),
  reused/adapted from the repo's own `docs/architecture.md`. Added an explicit
  "Registry-fetch smoke check — in progress (PR #9)" section using the actual PR body's own
  verification notes (companion to `cas-contracts` PR #18; independently verified to exit 0
  against the live registry pre-merge).
- Operations.md: verified the eight-step `ci.yml` matrix job (Python 3.11 + 3.13, ubuntu +
  windows) directly from the workflow file, noting `checkout`/`setup-python` are already
  SHA-pinned on `main` (relevant caveat for PR #10's remaining scope, flagged in Decisions.md).
- Decisions.md: indexes the repo's `02-shared-contracts-and-corpus` phase and two open PRs
  (#9, #10).
- HEAD SHA verified: `4fe936cc83ffdc4fd6ad825c373e949b1edbe0eb`.
- PR: https://github.com/Coding-Autopilot-System/cas-evals/pull/11

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected a false claim before it was committed (gsd-orchestrator)**
- **Found during:** drafting the gsd-orchestrator README "Test Coverage" section
- **Issue:** First draft stated `main`'s CI runs a "permanently-red `line-rate < 1.0`" enforce
  step (language borrowed from the plan's `<repo_facts>`, which described PR #16's *before*
  state relative to itself, not necessarily main's current reality). Direct `grep` of
  `.github/workflows/ci.yml` on `origin/main` showed **no** "Enforce"/coverage-threshold step
  exists at all today — only collect-and-upload.
- **Fix:** Rewrote the section to state accurately that `main` collects and publishes coverage
  as an artifact without enforcing a threshold, and that PR #16 adds the *first* enforcement
  step (a ratcheted branch-rate gate), not a *replacement* of an existing one.
- **Files modified:** `portfolio/gsd-orchestrator/README.md` (in the worktree, before the
  first commit — not a separate corrective commit)
- **Commit:** `4fbc5df`

**2. [Rule 2 - accuracy/scope] Flagged an undocumented stranded branch instead of silently
   describing Phase 28-01 as "in progress (PR #N)" (gsd-orchestrator)**
- **Found during:** researching the Phase 28 typed-failure retry/halt path for Architecture.md
- **Issue:** The plan brief and `28-01-SUMMARY.md` describe this work as delivered, and the
  natural phrasing (matching autogen's Phase 28-02 treatment) would have been "in progress
  (PR #N)". Direct verification (`git log --all`, `git branch -a`) found no PR exists for this
  work at all — it lives only on a local, unpushed branch `feat/phase-28-fault-injection` in
  the operator's own workstation checkout, never pushed to `origin`.
- **Fix:** Architecture.md explicitly states the work exists only on an unpushed local branch
  with no open PR, rather than implying a PR-tracked in-progress state that doesn't exist.
  Per the destructive-git-prohibition and worktree-isolation rules, this branch was not
  touched, pushed, or merged — purely a documentation-accuracy correction.
- **Files modified:** `portfolio/gsd-orchestrator/docs/wiki/Architecture.md`,
  `docs/wiki/Decisions.md`
- **Commit:** `aaa2c76`

No architectural changes were needed; no Rule 4 escalations occurred; no auth gates were hit
(`gh` was already authenticated as `OgeonX-Ai` with `repo`/`workflow` scopes). One harmless
non-blocking warning appeared on every `git push` (`"gh.exe" auth git-credential store: ... No
such file or directory`) — pushes succeeded regardless (confirmed via `git ls-remote` /
successful branch creation on each remote), so no action was needed.

## Known Stubs

None. No hardcoded empty/placeholder values were introduced; every wiki page and README
section describes either verified-landed behavior or explicitly-labeled in-progress/unpushed
work.

## Threat Flags

None. This task only added documentation files (README prose, `docs/wiki/*.md`) — no new
network endpoints, auth paths, file-access patterns, or schema changes were introduced.

## Self-Check

- All five `docs/wiki/` trees (20 files total) and the five README diffs were verified
  directly against the pushed branches (`git log --oneline`) before worktree removal.
- All five PR URLs verified via `gh pr view --json state,mergeable,url,title` after creation —
  all report `state: OPEN`, `mergeable: MERGEABLE`. None merged or approved by this agent.
- All five original `portfolio/<repo>` checkouts verified unchanged (`git status --short`
  before/after matched, modulo their own pre-existing local edits which this task never
  touched).
- `grep -c "docs-verified:"` returned exactly `1` for every README and every wiki page across
  all five repos (25 files, 25 matches).

## Self-Check: PASSED

## PR URLs

| Repo | PR |
|---|---|
| gsd-orchestrator | https://github.com/Coding-Autopilot-System/gsd-orchestrator/pull/19 |
| autogen | https://github.com/Coding-Autopilot-System/autogen/pull/15 |
| Promptimprover | https://github.com/Coding-Autopilot-System/Promptimprover/pull/29 |
| cas-contracts | https://github.com/Coding-Autopilot-System/cas-contracts/pull/20 |
| cas-evals | https://github.com/Coding-Autopilot-System/cas-evals/pull/11 |

All PRs report `state: OPEN`, `mergeable: MERGEABLE` as of verification. None were merged or
approved by this agent.
