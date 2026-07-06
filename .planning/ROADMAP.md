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
  Resolve the cas-contracts dead registry: `pages.yml` and `publish-registry.yml` fight over one Pages site and `schemas.coding-autopilot.dev` is unconfigured so every schema `$id` 404s. Choose: docs-subpath registry, GitHub Packages npm, or custom domain + DNS. Then enable consumer registry-fetch CI in dependent repos.
- **Phase 33: Azure Infra Hardening** *(depends on: 30; backlog P1, P2, P4)*
  Parameterize `publicNetworkAccess` per environment in cas-platform `observability.bicep` (P1). Add `.bicepconfig.json` linting and pin API versions in cas-platform and cloud-security-service-model (P2). Decide and document the `DoNotEnforce` policy-assignment mode in cloud-security-service-model (P4).
- **Phase 34: Workspace Guardrails & Drift Prevention** *(depends on: 26, 30)*
  Make the 2026-07-06 failure classes impossible to repeat silently: extend `doctor.ps1` into a workspace-health sweep (dirty/unpushed repos, untracked-file drift, gitlink integrity, worktree staleness, branch-vs-main divergence) runnable locally and on a schedule; add the root-repo Pester CI gate (added in 260706-h8b) to required checks; add a commit-integrity check that flags commits whose messages claim artifacts absent from the diff (the b4e0868 failure class); wire the sweep into the root CI workflow.
- **Phase 35: v1.4 Verification & Milestone Audit** *(depends on: 26-34)*
  End-to-end verification of both tracks: coverage gates green, typed failure states fault-injected, all repos on `main` with pinned/permissioned workflows, registry resolvable, workspace-health sweep green. Run `/gsd:audit-milestone` and archive.
