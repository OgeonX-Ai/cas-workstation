# Roadmap: CAS Loop Engineering

## Milestones

- **v1.0 Loop Engineering** — Phases 1–8 (shipped 2026-07-01). [Archive](milestones/v1.0-ROADMAP.md)
- **v1.1 Portfolio Hardening** — Phases 9–12 (shipped 2026-07-05). [Archive](milestones/v1.1-ROADMAP.md)
- **v1.2 Shared AI Engineering OS** — Phases 13–21 (shipped 2026-07-05). [Archive](milestones/v1.2-ROADMAP.md)
- **v1.3 Bootstrapping** — Phases 22–25 (shipped 2026-07-05). [Archive](milestones/v1.3-ROADMAP.md)

## Current Milestone: v1.4 Quality and Resilience Hardening

### Track A — Quality & Resilience (original scope)

- **Phase 26: Test Coverage Automation & Enforcement**
  Establish the 100% test coverage baseline CI gates. Generate missing unit, smoke, regression, and E2E tests for `gsd-orchestrator` and `autogen`.
  *Note (2026-07-06): the v1.3-era coverage suites were found orphaned (untracked in their sub-repos); quick task 260706-h8b committed them. Phase 26 must wire them into CI gates and close the coverage gap to 100% branch.*

  **Plans:** 3 plans (2 waves)
  - [ ] 26-01-PLAN.md — gsd-orchestrator: branch-coverage runsettings + ratcheted CI gate + new tests (wave 1)
  - [ ] 26-02-PLAN.md — autogen: pytest-cov + .coveragerc branch=true + ratcheted --cov-fail-under gate + new tests (wave 1)
  - [ ] 26-03-PLAN.md — cross-repo coverage report + PR verification + human checkpoint (wave 2)
- **Phase 27: Resilience First Error Typing**
  Refactor all agent boundaries and execution loops to use explicit typed failure states mapped to CAS Contracts.
  Includes verified backlog leads C3 (cas-reference-product `workflow.py:59` bare `except Exception` loses cause) and C4 (cas-evals `reference_product.py:49-52` collapses distinct network errors).
- **Phase 28: Fault-Injection & Recovery Auditing**
  Simulate catastrophic API and state failures to prove gracefully halted and retryable deterministic states.
  Includes backlog C5 (Promptimprover blackboard.json concurrent-write race, env-var defaults) and C6 (subprocess stdin / JSON parse size limits).
- **Phase 29: Automated Peer Critic Pattern**
  Implement the concurrent `critic` agent as a permanent SDLC security and resilience gate for all future implementations.

### Track B — Portfolio Governance & Workspace Integrity (added 2026-07-06 from docs/improvement-backlog.md)

- **Phase 30: Release Train & Branch Hygiene** *(depends on: none — do first; unblocks everything)*
  Merge the 15 open PRs across the 13 `Coding-Autopilot-System` repos (8× `chore/governance-hardening`, dependabot updates, `fix/pages-release-ordering`, `ci/phase-09-workflow-hardening`), using the documented enforce_admins temp-relax procedure where branch protection blocks self-authored merges. Return every sub-repo checkout to `main`. Remove remaining stale `worktrees/` entries per the 260706-h8b worktree audit report. Deliverable: all repos on `main`, zero open PRs older than 7 days, merge-train runbook committed to `docs/`.
- **Phase 31: Org-wide CI & Supply-Chain Hardening** *(depends on: 30; backlog S1, S2, S3, P3)*
  Pin all third-party GitHub Actions to commit SHAs and enable Dependabot actions updates org-wide (S1). Fix CodeQL language mismatches in `cloud-security-service-model` and `cas-workstation` (S2). Add least-privilege `permissions:` blocks and `timeout-minutes` to all workflows via shared templates in `org-dotgithub` (S3). Add coverage thresholds (`--cov-fail-under`) and review self-hosted-runner token scope in `ci-autopilot` (P3).
- **Phase 32: Contracts Registry Publishing** *(depends on: 30; backlog S4)*
  Resolve the cas-contracts dead registry: `pages.yml` already unifies docs+registry publishing (the earlier `publish-registry.yml` Pages conflict was resolved in prior PRs #12/#14/#15/#16) and the registry itself already resolves 200 on GitHub Pages, but every schema `$id` still points at the unconfigured `schemas.coding-autopilot.dev` (confirmed via `gh api .../pages`: `cname: null`), so `$id` values 404. Rewrite `$id` to the resolvable docs-subpath registry URL (Option 1) and enable consumer registry-fetch CI in cas-evals.

  **Plans:** 2 plans (2 waves)
  - [x] 32-01-PLAN.md — cas-contracts: rewrite all 22 schema $id values to the live Pages registry URL, flip the canonical-identity regression test, update docs/changelog, open PR (wave 1) — PR #18 open, 5/6 checks green, blocked on human `compatibility-reviewed` label
  - [x] 32-02-PLAN.md — cas-evals: update hardcoded vendored $id checks, add registry-fetch smoke check module + CI job, open PR (wave 2) — PR #9 open, all checks green
- **Phase 33: Azure Infra Hardening** *(depends on: 30; backlog P1, P2, P4)*
  ✔ **Constraint resolved (2026-07-06):** operator confirmed the NO-AZURE lock is a *deployment* lock only — "bicep-ready" authoring/linting is explicitly allowed. Phase 33 proceeds as scoped (lint/parameterize/pin, zero deployments). Any CI workflow that auto-deploys to Azure must be gated to manual dispatch until the lock lifts (folded into Phase 31 checks).
  Parameterize `publicNetworkAccess` per environment in cas-platform `observability.bicep` (P1). Add `.bicepconfig.json` linting and pin API versions in cas-platform and cloud-security-service-model (P2). Decide and document the `DoNotEnforce` policy-assignment mode in cloud-security-service-model (P4).
- **Phase 34: Workspace Guardrails & Drift Prevention** *(depends on: 26, 30)*
  Make the 2026-07-06 failure classes impossible to repeat silently: extend `doctor.ps1` into a workspace-health sweep (dirty/unpushed repos, untracked-file drift, gitlink integrity, worktree staleness, branch-vs-main divergence) runnable locally and on a schedule; add the root-repo Pester CI gate (added in 260706-h8b) to required checks; add a commit-integrity check that flags commits whose messages claim artifacts absent from the diff (the b4e0868 failure class); wire the sweep into the root CI workflow.

  **Plans:** 2 plans (2 waves)
  - [ ] 34-01-PLAN.md -- workspace-health.ps1 sweep extensions (PR-age, credential-helper, stack.manifest assertions, non-ASCII guard, blackboard.json gitignore) + Pester red-fixture tests (wave 1)
  - [ ] 34-02-PLAN.md -- commit-integrity check + CI wiring (report-only) + Task Scheduler registration + GLOBAL_AGENTS.md prevention notes (wave 2)
- **Phase 36: Portfolio Documentation Refresh** *(depends on: 26, 30-34 content landing; runs BEFORE Phase 35 audit — added 2026-07-06 by operator request)*
  Bring every repo's GitHub documentation up to the code's current reality and keep it there: READMEs (features, setup, usage, badges incl. new CI/coverage gates), CONTRIBUTING, architecture docs, org profile (org-dotgithub), and the root workstation README/docs. Verified-against-code via gsd-doc-writer + gsd-doc-verifier agents (no unverifiable claims — the b4e0868 lesson applied to prose). Deliverable includes a docs-freshness convention: each README carries a "verified against commit <sha>" footer, checked by the Phase 34 sweep as a staleness heuristic.
- **Phase 37: Marketing & Adoption Engine** *(depends on: 35, 36 — marketing claims must reference the audited milestone; added 2026-07-08 by operator request)*
  Marketing-as-code: a showcase site (mkdocs-material on Pages) whose Feature Cards and per-phase Story Pages are auto-generated from `.planning/` plans/summaries/verification evidence — every claim links to its commit/PR/test. Includes LinkedIn post drafts per phase (the governance-with-speed narrative), demo-asset placeholders, codex:generate-image placeholders, and a clean-machine quickstart as the adoption CTA. Strategy locked in `.planning/phases/37-marketing-and-adoption/37-CONTEXT.md`.
## Future Milestones (seeded 2026-07-08 — see [milestones/vNEXT-SEEDS.md](milestones/vNEXT-SEEDS.md))

- **v1.5 Delivery Flow & Release Engineering** — Phases 38–42: merge-queue flow + real two-party auto-merge policy, per-repo SemVer releases with generated notes, weekly pilot/fault-injection cadence, institutionalized learning loop, audit. *Kick off via `/gsd:new-milestone` after v1.4 archives.*
- **v1.6 Trust Depth & Self-Measurement** — Phases 43–47: signed commits/SLSA-lite/SBOM, secret-scanning + token rotation, DORA + token-economics dashboard from traces.jsonl, mutation + property-based testing, audit.
- **v1.7 Product & Scale** — Phases 48–51: clean-machine bootstrap product, marketing live (37 + M2/M3), disaster-restore drill, cloud readiness (**gated on operator lifting the NO-AZURE deploy lock**).

- **Phase 35: v1.4 Verification & Milestone Audit** *(depends on: 26-34, 36)*
  End-to-end verification of both tracks: coverage gates green, typed failure states fault-injected, all repos on `main` with pinned/permissioned workflows, registry resolvable, workspace-health sweep green. Run `/gsd:audit-milestone` and archive.
