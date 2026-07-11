<!-- Canonical template referenced by /gsd:extract-learnings and by
     engineering-os/OPERATING-CONTRACT.md's Phase-Close Learning Extraction checklist. -->

---
phase: 38
phase_name: "Merge Flow & Hygiene Backfill"
project: "cas-workstation (PersonalRepo)"
generated: "2026-07-11"
counts:
  decisions: 5
  lessons: 4
  patterns: 3
  surprises: 2
missing_artifacts:
  - "38-01-SUMMARY.md at time of writing lived only on branch feat/phase-38-merge-flow (PR .github#17 / cas-workstation#18), not yet merged to origin/master"
  - "38-03-SUMMARY.md at time of writing lived only on branch feat/phase-38-merge-flow, not yet merged to origin/master"
---

# Phase 38 Learnings: Merge Flow & Hygiene Backfill

## Decisions

### review-bot GitHub App as the second-party reviewer, not GitHub's native merge queue
Chose a dedicated `cas-review-bot` GitHub App gated on a fail-closed diff classifier plus the
pinned `autogen` `critic_cli`, rather than GitHub's native merge-queue feature, because native
merge-queue has no equivalent to a policy-driven second-reviewer identity — the App gives a real,
credentialed, non-agent second party that can satisfy branch-protection review requirements.

**Rationale:** The mechanism needed a genuine reviewer identity distinct from the PR author (often
an agent) to satisfy required-review branch protection honestly, not just green CI.
**Source:** 38-01-SUMMARY.md ("Decisions Made")

### Denylist checked before manifest/docs allowlist in the eligibility classifier
The classifier's denylist (workflow/executable/non-docs files) is evaluated before the
manifest-only/docs-only allowlist match, and applies to **all** authors including dependabot —
closing a gap where a dependabot `github-actions` PR touching `.github/workflows/**` could
otherwise slip through as "manifest-only."

**Rationale:** Classification decisions must derive strictly from changed-paths + author, and the
denylist must be author-independent or a trusted-looking author identity becomes a bypass vector.
**Source:** 38-01-SUMMARY.md (key-decisions, "denylist ... applies to ALL authors")

### Root repo gets plain PR-flow-with-review, not the review-bot App
The root repo (`OgeonX-Ai/cas-workstation`) deliberately does **not** get the review-bot App
installed. Its PR volume is low, so the App's auto-merge value is marginal relative to the cost of
installing a second GitHub App on a separate org; CODEOWNERS + existing `enforce_admins` branch
protection already closes the real gap (the unreviewed direct-push path).

**Rationale:** checkpoint:decision auto-selected `pr-flow-review` as the operator's standing
recommended choice; the plan's own option analysis favored it for root's traffic profile.
**Source:** 38-03-SUMMARY.md ("Decisions Made")

### Two-dot direct tree compare instead of three-dot merge-base diff for squash-merge hygiene
`squash-aware-branch-gate.ps1` uses `git diff origin/<default> <branch>` (two-dot) rather than the
usual three-dot merge-base diff, because a squash-merged branch's commit history never rejoins
`origin/<default>` — three-dot diff would report it as permanently diverged even when its tree
content is fully absorbed.

**Rationale:** The gate must correctly recognize squash-merged content parity, and only delete on
a genuinely empty two-dot diff (fail-closed).
**Source:** 38-02-SUMMARY.md (key-decisions, tech-stack patterns)

### Move, don't delete, an unregistered stray worktree lookalike even after a clean content probe
`pr-maf-workers` (a directory mirroring a real repo's structure but with no `.git`) was moved to
`scratch/orphaned-worktrees/` rather than deleted outright, even though a full 66-file
content-uniqueness probe against `autogen`'s history found nothing unique.

**Rationale:** Preserves a human's ability to double-check before permanent, irreversible deletion
of a full directory tree with unclear provenance.
**Source:** 38-02-SUMMARY.md ("Decisions Made")

---

## Lessons

### `apply-branch-protection.ps1`'s default payload can permanently lock out a repo without the classifier workflow
The script's original default payload always required the `automerge-eligibility` status check
context. A repo that never runs that workflow (root) would have a required check that never
reports, permanently blocking every PR on that repo.

**Context:** Discovered while dogfooding the script for its second consumer (38-03, the root repo)
via `-DryRun`, immediately after building it for the org sub-repos in 38-01.
**Source:** 38-01-SUMMARY.md ("Deviations from Plan" — Rule 1 auto-fix #1)

### CODEOWNERS being present does not mean review is enforced
Adding a `CODEOWNERS` file to the root repo did not, by itself, flip `require_code_owner_reviews`
to `true` in the live GitHub branch-protection payload — that flag stayed `false` because applying
protection for real was explicitly out of scope for 38-03 (only `-DryRun` evidence was captured).

**Context:** A reviewer verifying REQ-1.5.2 via `gh api` could easily assume CODEOWNERS is
load-bearing once the file exists; it is not, until the protection payload is actually applied.
**Source:** 38-03-SUMMARY.md ("Issues Encountered")

### `pull_request_target` + fetching the PR head ref is a pwn-request even if the fetched content is never executed
The original `review-bot.yml` "Compute PR diff" step ran `git fetch origin pull/<N>/head:pr-head`
inside a `pull_request_target`-triggered job — after the App's write-scoped installation token had
already been minted. This is GitHub's canonical "pwn request" anti-pattern: fetching
attacker-controlled ref content into a privileged job's local git object database, independent of
whether that content is subsequently executed. CodeQL correctly flagged it as CRITICAL
("Checkout of untrusted code in a privileged context").

**Context:** Surfaced live by Phase 42's pre-verification pass (`gh api .../code-scanning/alerts`
+ the PR's own CodeQL check-run annotations) — not caught by the plan's own STRIDE threat table in
`docs/merge-flow-policy.md`, which covered SHA-pinned actions (T-38-SC) but not this specific
untrusted-checkout pattern.
**Source:** 42-PREVERIFICATION.md ("Second finding"); 42-fix2-pwn-SUMMARY.md ("Root cause")

### The fix for a pwn-request pattern is to stop fetching the ref at all, not to sandbox the fetch
The mitigation removed the `git fetch`/`git diff` step entirely and replaced it with
`gh pr diff <n> --repo <repo>` (an HTTPS API text response) piped directly into `critic_cli` over
stdin — no PR-head ref is ever fetched, checked out, or merged into the runner's git state at any
point. The job's own `actions/checkout` (no `ref:` override) resolves to the base branch under
`pull_request_target`, never the PR head.

**Context:** The fix also added a fail-closed guard: if `gh pr diff` itself fails, the job now
hard-stops (`exit 1`) instead of silently treating an empty/failed diff as "zero findings" and
proceeding toward approval — closing a latent bypass a naive stdin rewrite would otherwise
introduce.
**Source:** 42-fix2-pwn-SUMMARY.md ("Fix", "Docs / traceability")

---

## Patterns

### Fail-closed classification from changed-paths + author only, never labels/title
Classification decisions (in-class vs. out-of-class for auto-merge eligibility) derive strictly
from `gh pr view` changed-paths and author identity — never from PR labels or title, since both
are author-controllable and therefore untrustworthy classification inputs.

**When to use:** Any policy-gate that decides trust/eligibility from PR metadata; always prefer
the metadata a PR author cannot freely edit (files changed, author identity) over metadata they
can (labels, title, description).
**Source:** 38-01-SUMMARY.md (patterns-established)

### As-code branch protection parameterized by opt-in/opt-out switches, not forked logic
`apply-branch-protection.ps1` is parameterized by `-Owner`/`-Repos` so the identical script and
payload shape apply to both org sub-repos and the root repo, with `-SkipEligibilityCheck` /
`-RequireCodeOwnerReviews` as explicit per-repo opt-outs/opt-ins rather than a forked or
repo-special-cased script.

**When to use:** Reusable infra-as-code scripts serving multiple, structurally-different consumers
(org repo vs. root repo) — prefer explicit flags over branching the script itself per consumer.
**Source:** 38-01-SUMMARY.md (patterns-established)

### Content-uniqueness probing before dispositioning an unregistered worktree lookalike
When a directory mirrors a real repo's file structure but has no `.git` (so normal `git worktree`
guards are a no-op), use blob-hash content-uniqueness probing (`git hash-object` +
`git log --all --find-object`) against the real repo's history before deciding to move or delete
it.

**When to use:** Any hygiene sweep encountering an unregistered directory that looks like it might
be a stray copy of a real, tracked repository.
**Source:** 38-02-SUMMARY.md (patterns-established)

---

## Surprises

### A squash-merged reusable-workflow PR orphans its own pin SHA
This is the Phase 39 root cause (see `39-LEARNINGS.md`), but it directly threatens Phase 38's own
mechanism too: `apply-branch-protection.ps1` and the review-bot App both depend on org-dotgithub
workflow files that are subject to the same squash-merge-orphans-branch-tip-SHA hazard if ever
referenced by commit SHA instead of by path within the same repo. Phase 38's own artifacts were
not bitten by this (the App workflow lives directly in `.github`, not consumed cross-repo by pin),
but the class of hazard is directly adjacent to this phase's mechanism design.

**Impact:** Reinforces the pin-verification rule recorded in Phase 39's learnings as a
portfolio-wide policy, not a one-off Phase 39 fix.
**Source:** 42-fix1-pin-SUMMARY.md ("Root cause")

### An unresolved CRITICAL CodeQL alert survived to "done, PR open" status without being caught by the plan's own threat model
`docs/merge-flow-policy.md`'s STRIDE table (T-38-SC) covers "actions pinned by SHA" but does not
address the specific untrusted-checkout-in-privileged-job pattern that CodeQL caught. The gap was
only surfaced by Phase 42's live pre-verification pass re-running CodeQL's own check-run
annotations against the still-open PR — not by any SUMMARY.md claim.

**Impact:** A phase's own threat-model document is not a substitute for actually reading the
CI/CodeQL check-run status before calling a security-relevant PR "done." Phase 42's audit
methodology (live `gh api` re-verification of every claim, not narrative-only trust of SUMMARY.md)
is what caught this, and should be standard practice for any phase touching privileged workflow
triggers (`pull_request_target`, `workflow_run` with elevated permissions, etc.).
**Source:** 42-PREVERIFICATION.md ("Second finding", "Per-Phase Verdicts" table)
