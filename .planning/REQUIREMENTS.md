# Milestone v1.4 Requirements: Quality and Resilience Hardening

<ambiguity_scoring>
- **100% test coverage:** Is this branch or line coverage? *Resolution required:* We will enforce 100% branch coverage on all orchestration and agent execution layers, requiring all edge cases to be verifiable.
- **Resilience First:** What specifically defines a typed failure state? *Resolution required:* All system errors must map to a defined JSON schema in CAS Contracts, and orchestration must gracefully retry or halt. What happens on distributed node partition? (Deferred to multi-machine phase if out of scope).
- **Concurrency & Scaling:** If we run workers in parallel, do failure states overlap? *Resolution required:* Each worker must own its mutation scope exclusively and emit isolated telemetry context.
</ambiguity_scoring>

## Goals
Ensure all CAS Loop Engineering code deliveries meet the Priority 0 Immutable Coding Standards defined in the canonical operating contract: 100% test coverage (unit, smoke, regression, E2E) and Resilience First architecture with robust error handling and typed failure states.

## MoSCoW Prioritization

### Must Have
- **REQ-1.4.1 [Falsifiable]:** All new and modified codebase files must pass a CI gate enforcing 100% branch test coverage across unit, smoke, regression, and E2E layers.
- **REQ-1.4.2 [Falsifiable]:** The `gsd-orchestrator` must implement explicit typed failure states for all unhandled exceptions, verified by a fault-injection E2E test.
- **REQ-1.4.3 [Falsifiable]:** All Microsoft Agent Framework workers must include `try/catch` blocks that emit structured JSON telemetry on failure, proven by log output during a simulated API outage.

### Should Have
- **REQ-1.4.4 [Falsifiable]:** Retroactive test generation for all v1.0-v1.3 core modules that currently sit below 100% coverage, verified by Codecov or similar.
- **REQ-1.4.5 [Falsifiable]:** Implementation of a standalone `critic` agent during the `SECURITY REVIEW` phase to automatically verify Resilience First patterns before merge.

### Could Have
- **REQ-1.4.6 [Falsifiable]:** Kubernetes deployment manifests with built-in liveness and readiness probes that assert the newly introduced typed failure states.

### Must Have (Track B — Portfolio Governance, added 2026-07-06)
- **REQ-1.4.8 [Falsifiable]:** No source or test artifact may exist only on-disk: every sub-repo working tree is clean or its untracked files are deliberately gitignored, verified by the workspace-health sweep exiting 0.
- **REQ-1.4.9 [Falsifiable]:** All 13 portfolio repos sit on `main` with zero open PRs older than 7 days after the Phase 30 release train, verified by `gh pr list` across the org.
- **REQ-1.4.10 [Falsifiable]:** Every GitHub Actions workflow in the org pins third-party actions to commit SHAs and declares least-privilege `permissions:` + `timeout-minutes`, verified by an org-wide workflow-lint script.
- **REQ-1.4.11 [Falsifiable]:** Every published cas-contracts schema `$id` URL resolves with HTTP 200, verified by the consumer registry-fetch CI job.

### Should Have (Track B)
- **REQ-1.4.12 [Falsifiable]:** `doctor.ps1` workspace-health sweep detects and reports: dirty repos, unpushed commits, gitlink-without-.gitmodules, stale worktrees (>14 days), and non-default-branch checkouts.
- **REQ-1.4.13 [Falsifiable]:** Root-repo CI runs the Pester contract tests (`tests/*.Tests.ps1`) on every push, and a commit-integrity check flags commits whose messages claim artifacts absent from the diff.
- **REQ-1.4.14 [Falsifiable]:** cas-platform Bicep passes `.bicepconfig.json` linting with `publicNetworkAccess` parameterized per environment.

### Won't Have
- **REQ-1.4.7:** Full cross-cluster automatic production deployments and destructive merges (remains explicitly out of scope for v1 constraints).
