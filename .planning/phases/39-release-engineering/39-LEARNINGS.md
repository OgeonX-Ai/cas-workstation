<!-- Canonical template referenced by /gsd:extract-learnings and by
     engineering-os/OPERATING-CONTRACT.md's Phase-Close Learning Extraction checklist. -->

---
phase: 39
phase_name: "Release Engineering"
project: "cas-workstation (PersonalRepo)"
generated: "2026-07-11"
counts:
  decisions: 4
  lessons: 5
  patterns: 3
  surprises: 2
missing_artifacts:
  - "39-01-SUMMARY.md at time of writing existed only at commit 96e75e9 on branch docs/phase-38-plan-fixes, not yet merged to origin/master"
---

# Phase 39 Learnings: Release Engineering

## Decisions

### Reusable workflow hosted once in org-dotgithub, consumed by SHA pin everywhere
Cross-repo release automation logic (`release-please-reusable.yml`, a `workflow_call` wrapper
around `googleapis/release-please-action`) lives in exactly one place (`org-dotgithub`), consumed
by all 13 portfolio repos via a SHA-pinned `uses:` reference — never a floating branch ref.

**Rationale:** A single source of truth for the release mechanism, with SHA pinning as the
supply-chain integrity control (matches the org's existing SHA-pin-everything convention from
Phase 31).
**Source:** 39-01-SUMMARY.md (patterns-established)

### Per-repo bootstrap baseline always sourced from GitHub's real tag state, never local clone tags
Each repo's `.release-please-manifest.json` bootstrap value was chosen from
`gh api repos/<org>/<repo>/tags` (GitHub's real, authoritative state) — not local git tags and not
an assumed milestone-numbering guess. `cas-contracts` bootstrapped at `1.1.1` and
`gsd-orchestrator` at `4.0.0` (both real existing tags); `cas-reference-product` bootstrapped at
`0.0.0` despite having a local-only `v0.1` tag, because that tag was never pushed to GitHub and is
not valid three-part SemVer anyway.

**Rationale:** A local clone's tags can be stale, unpushed, or non-canonical; only the GitHub API
reflects the state release-please itself will observe.
**Source:** 39-03-SUMMARY.md (key-decisions, patterns-established); 39-02-SUMMARY.md ("Decisions Made")

### Delivered as N independent single-repo PRs from N independent worktrees, never a cross-repo commit
Release-please wiring for a repo group (39-02's 6 repos, 39-03's 6 repos) is delivered as 12
separate PRs, each from its own isolated `git worktree` branched off a freshly-fetched
`origin/<default>`, leaving every dirty/parked primary checkout completely untouched.

**Rationale:** Primary checkouts across the portfolio were dirty and/or parked on unrelated
branches; isolated worktrees let the plan proceed without risking foreign in-progress work, and
per-repo PRs respect each repo's own review/merge boundary.
**Source:** 39-02-SUMMARY.md (patterns-established); 39-03-SUMMARY.md (tech-stack patterns)

### Root-repo work goes through PR flow, not a direct master commit
39-01's root-repo change (the `workspace-health.ps1` release-staleness finding) went through PR
flow on branch `feat/phase-39-release-engineering` instead of a direct `master` commit, because
`master` now has live `enforce_admins` branch protection (landed in an earlier phase).

**Rationale:** The plan's own instructions were corrected mid-flight to honor the now-live branch
protection rather than attempting (and failing, or requiring a break-glass) a direct push.
**Source:** 39-01-SUMMARY.md ("Decisions Made")

---

## Lessons

### A squash-merged PR's branch-tip commit SHA becomes unreachable garbage the moment it merges — this broke release-please for all 13 repos, live, in production
The pin `f288e5e3b67b29a2c08880b76da7b852f4a132d0`, baked into all 13 repos' caller workflows
(including org-dotgithub's own dogfood file), pointed at the **pre-squash-merge branch-tip
commit** of `.github` PR #16. When PR #16 squash-merged, the real commit that landed on
`.github`'s `main` was a *different* SHA (`64c1673088ff7802f1270a44f03bc4d7a10631f2`) — a fresh
commit synthesized by the squash, not identical to the branch tip. The pinned SHA became
unreachable from `main` the moment the source branch was deleted post-merge
(`gh api .../compare/main...f288e5e3...` returned `"status":"diverged"`). Every push-triggered
`release-please.yml` run since then failed with `"Invalid workflow file ... workflow was not
found"` — confirmed independently on 6+ of the 13 repos, 100% failure rate, all the identical root
cause.

**Context:** This is the headline finding of Phase 42's live pre-verification pass — not present
in any SUMMARY.md, because at the time 39-01/39-02/39-03 were written, none of the 13 PRs had
merged yet (the pin was valid *while the source branch still existed*, which is exactly why the
bug is insidious — it looks correct at authoring time and only breaks at merge time, later, and
silently until the next push).
**Source:** 42-PREVERIFICATION.md ("Headline finding"); 42-fix1-pin-SUMMARY.md ("Root cause")

### THE PIN RULE: never pin a reusable workflow to a PR branch-tip SHA — pin only to a SHA already confirmed reachable from the target's default branch, and re-verify the pin after every squash-merge
The verified fix re-pinned all 13 callers to `64c1673088ff7802f1270a44f03bc4d7a10631f2`, confirmed
via three independent checks before use: (1) `gh api .../commits/<sha> --jq .sha` resolves to
itself, (2) `gh api .../compare/main...<sha> --jq .status` returns `identical` (the SHA **is**
current `main` HEAD), (3) the target file exists at that ref. This three-step verification — not
just "the SHA exists somewhere" — is the durable rule going forward: a SHA pin is only safe once
it is confirmed to be an ancestor of (or identical to) the branch that will actually be pulled at
workflow-run time, and that confirmation must be re-run after any squash-merge event that could
have superseded it.

**Context:** Squash-merge is exactly the merge strategy that breaks the naive assumption "the
branch tip commit becomes part of history" — a rebase-merge or true merge-commit would have kept
the original SHA reachable; squash-merge, by design, synthesizes a new commit and discards the
branch's own commit objects from `main`'s ancestry.
**Source:** 42-fix1-pin-SUMMARY.md ("Verified replacement SHA", "Method")

### `gh pr diff` output can carry benign credential-helper warnings that look like failures but aren't
`git push` from isolated worktrees repeatedly printed
`"/mnt/c/Program Files/GitHub CLI/gh.exe" auth git-credential store: line 1: ... No such file or
directory` — a known MSYS/WSL path-quoting artifact of the verification environment, already
tracked as its own `workspace-health.ps1` finding class (`credential-helper-wsl-path`). All
pushes succeeded despite the warning.

**Context:** Recurred identically across 39-01, 39-02, and 39-03 — worth remembering as noise, not
signal, when scanning worktree-repo push output for real failures.
**Source:** 39-01-SUMMARY.md ("Issues Encountered"); 39-02-SUMMARY.md ("Issues Encountered")

### PyYAML's bareword `on:` parses as boolean `True`, not the string `"on"` — a footgun for any verification script reading workflow YAML
A verification script's dict lookup on the `on:` key raised `KeyError: 'branches'` because PyYAML
(1.1-spec-compliant) parses the bareword `on` as the YAML 1.1 boolean `True`. GitHub Actions
itself parses `on:` correctly (it does not use PyYAML's 1.1 boolean coercion), so the workflow
files were never actually broken — only the ad hoc verification script reading them was.

**Context:** Resolved by reading `d.get('on', d.get(True))` rather than assuming the string key.
Any future tooling that parses `.github/workflows/*.yml` with PyYAML must account for this.
**Source:** 39-03-SUMMARY.md ("Issues Encountered")

### A Claude Code safety-classifier outage on `gh` mid-session blocked opening one PR, but did not affect the plan's actual deliverable
After all 6 target-repo PRs for 39-03 were opened and verified, the `gh` CLI became unavailable
through the Bash tool for the rest of the session (git commands continued to work; only `gh`
invocations were blocked). This prevented opening the root-repo PR for that plan's own
SUMMARY/STATE/REQUIREMENTS commit — the commit and branch were pushed and ready, just the PR
itself was left as a mechanical one-command follow-up.

**Context:** A useful reminder that "PR opened" and "commit pushed" are separable outcomes; a
tooling outage on the PR-open step does not retroactively invalidate work that was already
committed and pushed.
**Source:** 39-03-SUMMARY.md ("Issues Encountered")

---

## Patterns

### Reusable-workflow pin verification is a three-step live check, not a one-time note
See "THE PIN RULE" above (Lessons) — codify this as a standing pre-merge and post-merge-event
check for any repo consuming a cross-repo reusable workflow by SHA.

**When to use:** Any time a reusable GitHub Actions workflow is referenced by commit SHA across
repo boundaries, both at initial wiring time and again immediately after the source PR merges
(especially under a squash-merge strategy).
**Source:** 42-fix1-pin-SUMMARY.md

### Isolated worktree per repo-task, never touching a dirty/parked primary checkout
Recurs across all three plans in this phase (39-01, 39-02, 39-03) and across Phase 38/40/41 as
well — established as the standard execution pattern for this project whenever a task must modify
a sub-repo whose primary checkout may be dirty or on an unrelated branch.

**When to use:** Any automated task touching a portfolio sub-repo's files, when the primary
checkout's state cannot be assumed clean.
**Source:** 39-02-SUMMARY.md, 39-03-SUMMARY.md (tech-stack patterns)

### Split TDD-flagged tasks into `test(...)` then `feat(...)` commits with an out-of-band genuine-RED verification
39-01's Task 2 (`tdd="true"`) split into a `test(39-01): ...` commit then a `feat(39-01): ...`
commit, and verified genuine RED by temporarily reverting the implementation file, re-running
Pester, and confirming the 2 behavior-asserting tests failed with the expected message — before
restoring the implementation and confirming GREEN.

**When to use:** Any TDD-flagged task, to avoid a merely cosmetic RED/GREEN commit pair where the
"RED" commit's tests would have passed anyway.
**Source:** 39-01-SUMMARY.md ("TDD Gate Compliance", key-decisions)

---

## Surprises

### The stranded pin SHA (headline finding)
See Lessons above — a plan that was executed correctly, verified correctly at the time (the SHA
was real and valid while its source branch existed), and documented honestly (`39-01-SUMMARY.md`
explicitly warned "It will need to be re-verified/updated once PR #16 merges... a merge commit or
squash will produce a new SHA") still resulted in a live, org-wide, 100%-failure-rate production
outage the moment the PRs actually merged. The plan's own SUMMARY.md correctly predicted the exact
failure mode in advance — but the merge event and the re-verification step were separated in time
across three different plans (39-01 wrote the warning, 39-02/39-03 consumed the SHA verbatim per
instruction, and no plan owned the "re-verify after merge" step), so the warning was never acted
on until Phase 42's live audit caught it after the fact.

**Impact:** A correct-at-write-time warning in a SUMMARY.md is not equivalent to a tracked,
owned, scheduled follow-up action. The pin rule (Lessons, above) closes the immediate bug; the
deeper process lesson is that "this will need re-verification later" statements need an explicit
owner and trigger condition (e.g., "re-verify on every squash-merge to org-dotgithub"), not just a
narrative caveat.
**Source:** 39-01-SUMMARY.md (pin-SHA note); 42-PREVERIFICATION.md ("Headline finding")

### Merging is normally a *better* state than "still open" — except when it triggers a live bug
Mid-session during Phase 42's pre-verification, all 12 sub-repo PRs merged (an operator/automation
batch-drain running concurrently with the audit). Ordinarily this would simply upgrade the verdict
from "PR open, unverified" to "merged, verified." Here it instead flipped the verdict from
"PR-only, not yet evaluable" to "actively broken now that the PRs did merge" — the exact opposite
of the expected direction, because the merge event itself was the trigger condition for the
stranded-pin bug.

**Impact:** A verification methodology that treats "merged" as strictly safer than "open" can miss
merge-triggered regressions. Phase 42's live, re-run-the-actual-check approach (rather than
trusting SUMMARY.md narrative) is what caught this — reinforcing the "live re-verification, not
narrative trust" pattern as load-bearing, not optional.
**Source:** 42-PREVERIFICATION.md ("IMPORTANT — the target moved during this audit")
