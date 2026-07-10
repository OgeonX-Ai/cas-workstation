# Merge Flow Policy

Closes REQ-1.5.1 (org sub-repos) and REQ-1.5.2 (root repo). This document
states the chosen auto-merge mechanism, defines exactly which PRs qualify,
and is honest about what the mechanism does and does not verify.

## The problem

Two-party review is the CAS governance baseline (see
[Agent-Hierarchy rule 2](wiki/Agent-Hierarchy.md): "PR-only for sub-repos;
the agent never self-approves or merges"). Applied literally to every PR,
this makes low-risk changes — a dependabot version bump, a one-line docs
fix — wait on a human click even though nothing about the change carries
meaningful risk. The result observed pre-Phase-38: PRs aging past 7 days,
manual merge-train sweeps (`scripts/run-merge-queue.ps1`,
`docs/merge-train-runbook.md`) as the only path to landing anything.

REQ-1.5.1's falsifier requires median green-PR time-to-merge under 24h and
zero PRs older than 7 days. That is not achievable by adding more manual
sweeps; it requires a bounded class of PRs that merge without any human or
agent clicking merge, while every PR outside that class still gets a real
second-party review.

## The chosen mechanism: a dedicated review-bot GitHub App

A GitHub App identity, `cas-review-bot`, with its own credentials
(`REVIEW_BOT_APP_ID` / `REVIEW_BOT_PRIVATE_KEY`, installed org-wide), is the
second-party reviewer for the in-class category only. It is:

- **Not an authoring agent.** No CAS executor, planner, or orchestrator role
  holds the App's private key; the key exists only as an org Actions secret
  consumed by the `review-bot` workflow at runtime.
- **Not the operator's interactive session.** The operator never has to open
  the PR or click Approve for an in-class PR to land.
- **Gated on deterministic checks it cannot be talked out of.** The App
  approves and enables auto-merge for a PR only when all three hold:
  1. The fail-closed eligibility classifier (below) says IN-CLASS.
  2. The autogen `critic_cli` (pinned to `origin/main` commit `b0524b7`,
     merged via autogen PR #17 — never the abandoned
     `feat/phase-29-peer-critic` branch) reports 0 blocking findings against
     the PR diff.
  3. Required CI checks are green.

Any PR that fails any of those three gates is left alone: no approval, no
auto-merge, falls back to ordinary human review. The mechanism only ever
*adds* a fast path for the safe class; it never *removes* review for
anything else.

## The class boundary (fail-closed)

Implemented in
[`portfolio/org-dotgithub/.github/scripts/classify-automerge-eligibility.ps1`](../portfolio/org-dotgithub/.github/scripts/classify-automerge-eligibility.ps1)
and enforced as a required status check
(`.github/workflows/auto-merge-eligibility.yml`, context name
`automerge-eligibility`) on every PR.

**Decision inputs:** the changed-file paths from `gh pr view --json files`
and the PR author from `gh pr view --json author`. **Never** PR labels or
title — both are author-controllable and therefore untrusted for a decision
that grants merge authority (STRIDE T-38-02).

A PR is **IN-CLASS** iff EITHER:

- **(a) Dependabot manifest-only.** The author login is `dependabot[bot]`
  AND every changed path is a dependency-manifest file: `package*.json`,
  `requirements*.txt`, `*.csproj`, `Directory.Packages.props`, and common
  lockfiles (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`,
  `Gemfile.lock`, `poetry.lock`, `Cargo.lock`, `composer.lock`). OR
- **(b) Docs-only.** Every changed path matches the docs allowlist:
  `**/*.md`, `**/*.mdx`, `docs/**` (which covers `docs/wiki/assets/**` and
  `docs/wiki/diagrams/**` as subpaths).

**The denylist applies to every author, including dependabot, and is
checked first.** Any changed path under `.github/workflows/**`, or matching
`**/*.yml`, `**/*.yaml`, `**/*.ps1`, `**/*.py`, `**/*.cs`, `**/*.ts`,
`**/*.js`, `Dockerfile*`, or non-docs/non-manifest `**/*.json`, forces
**OUT-OF-CLASS** — no exceptions, regardless of what else is in the diff or
who authored it.

This closes a specific failure mode: dependabot's `github-actions` ecosystem
legitimately opens PRs that bump a pinned SHA inside
`.github/workflows/*.yml`. Those PRs touch a workflow file and MUST fall to
human review even though the author is `dependabot[bot]` and the intent
looks routine — a compromised or misconfigured workflow file is exactly the
kind of change automated merge must never wave through. The classifier's
self-test (`-SelfTest`) carries this exact case as a regression fixture
(`dependabot-with-workflow-file` -> `OUT-OF-CLASS`), alongside pure-docs,
docs-plus-workflow-file, dependabot-manifest-only, and mixed-docs-and-code.

## The trust model, stated honestly

The review-bot's "review" is **not** human judgment. It is deterministic
policy enforcement: a path-based classifier plus a rule-based static critic
plus a CI status check. That is adequate for the bounded in-class risk
surface (documentation and dependency-version text, nothing executable) —
it is explicitly **not** adequate for feature code, infrastructure, or
anything that changes behavior. All such changes stay on the human-review
path:

- Org sub-repos: any PR classified OUT-OF-CLASS gets ordinary
  operator/human review, same as before Phase 38.
- Root repo (`OgeonX-Ai/cas-workstation`): see the Root repo section below —
  every PR requires human review; the review-bot mechanism is not installed
  on the root org.

The App is scoped to the minimum permissions that make this work and
nothing more: Pull requests Read & Write, Contents Read & Write (to enable
squash-merge), Checks Read, Metadata Read. No Administration scope, no
Secrets scope (STRIDE T-38-06).

Agent self-approval remains categorically impossible: the App token is
secret-gated and never available to an authoring agent's session (STRIDE
T-38-03), and `Agent-Hierarchy.md` rule 2 is the standing permission-layer
enforcement this mechanism must not create a bypass for.

## Root repo (OgeonX-Ai/cas-workstation)

The root workspace repo previously accepted direct pushes to `master` — an
asymmetry with every sub-repo's PR-only posture, and a real backdoor around
the two-party-review story (REQ-1.5.2).

**Decision (checkpoint 38-03, operator standing choice): `pr-flow-review`
— PR flow with required review, matching the sub-repo posture, without
installing the review-bot App on the root org.** Rationale: root's PR
volume is low, so review-bot's operational value (auto-merge for a docs/
dependabot fast path) is marginal relative to the cost of a second App
install on a separate GitHub org (`OgeonX-Ai` vs. `Coding-Autopilot-System`).
Plain PR-flow-with-review already closes the actual gap (an unreviewed
direct-push path into root) with the mechanism already proven on the
sub-repos.

Applied via the same as-code mechanism as the sub-repos —
`scripts/apply-branch-protection.ps1 -Owner OgeonX-Ai -Repos cas-workstation`
— no bespoke root logic. `CODEOWNERS` at root assigns `*` to `@OgeonX-Ai`
(the operator identity, not an authoring agent), so required review always
resolves to a real non-agent reviewer.

**Status: this posture was already live before Plan 38-03 executed** —
`enforce_admins` and `required_approving_review_count = 1` landed via root
PR #7 ("Enforce branch approvals and track provenance across the
portfolio"). Plan 38-03 verified the live state via `gh api
repos/OgeonX-Ai/cas-workstation/branches/master/protection` and codified it
(CODEOWNERS + this section + the as-code script run) rather than
re-applying a decision that was already in effect — satisfied-by-live-state.

Break-glass for the solo admin who is also the sole reviewer: the
`enforce_admins` temp-relax/restore procedure already documented in
`docs/merge-train-runbook.md` (relax immediately before, restore
immediately after, verify with `--jq .enabled`). No new break-glass
mechanism was introduced for root.

## What this does not cover

- Release engineering, tagging, and changelog generation (REQ-1.5.3) —
  separate mechanism, separate plan.
- Pilot-cadence scheduled evidence runs (REQ-1.5.4) — unrelated to merge
  flow.
- The residual v1.4 hygiene backfill items (branches, worktree leftovers —
  REQ-1.5.2 non-root portions) — tracked in Plan 38-02.
