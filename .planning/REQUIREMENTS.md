# Milestone v1.4 Requirements: Quality and Resilience Hardening

<ambiguity_scoring>
- **100% test coverage:** Is this branch or line coverage? *Resolution required:* We will enforce 100% branch coverage on all orchestration and agent execution layers, requiring all edge cases to be verifiable. *(Amended in execution: ratchet-to-measured-baseline-no-regression; delta recorded as deferred items — see 26-COVERAGE-REPORT.md.)*
- **Resilience First:** What specifically defines a typed failure state? *Resolution required:* All system errors must map to a defined JSON schema in CAS Contracts, and orchestration must gracefully retry or halt. What happens on distributed node partition? (Deferred to multi-machine phase if out of scope).
- **Concurrency & Scaling:** If we run workers in parallel, do failure states overlap? *Resolution required:* Each worker must own its mutation scope exclusively and emit isolated telemetry context.
</ambiguity_scoring>

## Goals
Ensure all CAS Loop Engineering code deliveries meet the Priority 0 Immutable Coding Standards defined in the canonical operating contract: 100% test coverage (unit, smoke, regression, E2E) and Resilience First architecture with robust error handling and typed failure states.

> Format note (2026-07-08): converted from MoSCoW prose to the checkbox traceability format
> required by `requirements.mark-complete` (backlog E11). Content unchanged; statuses reflect
> the Phase 35 audit + same-session remediations. "pending-merges" = implemented and CI-green
> on an open PR branch; check the box when the PR lands.

## Must Have

- [ ] **REQ-1.4.1** [Falsifiable] All new and modified codebase files must pass a CI gate enforcing 100% branch test coverage across unit, smoke, regression, and E2E layers. *(PARTIAL by amended definition: ratcheted branch-coverage gates shipped, baselines gsd-orchestrator 67.3%→raised, autogen 53.5%; 100% delta deferred — phases 26-01/02, PRs gsd-orchestrator#16, autogen#11)*
- [ ] **REQ-1.4.2** [Falsifiable] The `gsd-orchestrator` must implement explicit typed failure states for all unhandled exceptions, verified by a fault-injection E2E test. *(pending-merges: PRs #20, #21)*
- [ ] **REQ-1.4.3** [Falsifiable] All Microsoft Agent Framework workers must include `try/catch` blocks that emit structured JSON telemetry on failure, proven by log output during a simulated API outage. *(pending-merges: autogen#12 after #16)*

## Should Have

- [ ] **REQ-1.4.4** [Falsifiable] Retroactive test generation for all v1.0-v1.3 core modules that currently sit below 100% coverage, verified by Codecov or similar. *(pending-merges: coverage PRs; see 26-COVERAGE-REPORT.md)*
- [ ] **REQ-1.4.5** [Falsifiable] Implementation of a standalone `critic` agent during the `SECURITY REVIEW` phase to automatically verify Resilience First patterns before merge. *(pending-merges: autogen#14)*

## Could Have

- [ ] **REQ-1.4.6** [Falsifiable] Kubernetes deployment manifests with built-in liveness and readiness probes that assert the newly introduced typed failure states. *(deliberately deferred — Could-Have, not started)*

## Must Have (Track B — Portfolio Governance, added 2026-07-06)

- [ ] **REQ-1.4.8** [Falsifiable] No source or test artifact may exist only on-disk: every sub-repo working tree is clean or its untracked files are deliberately gitignored, verified by the workspace-health sweep exiting 0. *(mechanism shipped and working — sweep correctly reports live in-flight state; final zero-finding run gates milestone close)*
- [ ] **REQ-1.4.9** [Falsifiable] All 13 portfolio repos sit on `main` with zero open PRs older than 7 days after the Phase 30 release train, verified by `gh pr list` across the org. *(train complete; round-3 queue open, none >7d as of 2026-07-08; several cross threshold ~2026-07-13 if unmerged)*
- [ ] **REQ-1.4.10** [Falsifiable] Every GitHub Actions workflow in the org pins third-party actions to commit SHAs and declares least-privilege `permissions:` + `timeout-minutes`, verified by an org-wide workflow-lint script. *(pending-merges: 12 hardening PRs, verified clean per 31-06-VERIFICATION.md)*
- [ ] **REQ-1.4.11** [Falsifiable] Every published cas-contracts schema `$id` URL resolves with HTTP 200, verified by the consumer registry-fetch CI job. *(pending-merges: cas-contracts#18 [human label required] + cas-evals#9; live smoke check already 200 on all paths)*

## Should Have (Track B)

- [x] **REQ-1.4.12** [Falsifiable] `doctor.ps1` workspace-health sweep detects and reports: dirty repos, unpushed commits, gitlink-without-.gitmodules, stale worktrees (>14 days), and non-default-branch checkouts. *(VERIFIED by Phase 35 audit — 11 checks, red-fixture Pester suite green)*
- [ ] **REQ-1.4.13** [Falsifiable] Root-repo CI runs the Pester contract tests (`tests/*.Tests.ps1`) on every push, and a commit-integrity check flags commits whose messages claim artifacts absent from the diff. *(CI + checks shipped and green 11/11 after same-session fix; residual: root branch-protection/required-check decision — note root repo has moved to PR flow 2026-07-08)*
- [ ] **REQ-1.4.14** [Falsifiable] cas-platform Bicep passes `.bicepconfig.json` linting with `publicNetworkAccess` parameterized per environment. *(pending-merges: cas-platform#11; lint evidence in 33-01-SUMMARY.md)*

## Won't Have

- **REQ-1.4.7**: Full cross-cluster automatic production deployments and destructive merges (remains explicitly out of scope for v1 constraints).
