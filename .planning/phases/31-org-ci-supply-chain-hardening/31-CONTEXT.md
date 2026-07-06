# Phase 31: Org-wide CI & Supply-Chain Hardening — Context

**Gathered:** 2026-07-06
**Status:** Ready for planning (`/gsd:plan-phase 31`) — depends on Phase 30 (repos on main)
**Backlog refs:** S1, S2, S3, P3 (docs/improvement-backlog.md, all ✅/🔎 verified tiers)

## Scope

1. **S1 — Pin actions to SHAs** (Med, verified): nearly every repo uses `@v4`/`@v8` tags. Pin third-party actions to commit SHAs; enable Dependabot `github-actions` ecosystem org-wide (Dependabot PRs already open on autopilot-core — adopt that config everywhere).
2. **S2 — CodeQL language mismatches** (Med, verified): `cloud-security-service-model` runs `javascript` CodeQL on a Bicep repo; `cas-workstation` runs `python` on PowerShell. Set matrix to `actions` or drop CodeQL for docs-only repos. cas-platform + .github already fixed — copy that pattern.
3. **S3 — Least-privilege tokens** (Med, flagged): add `permissions:` blocks and `timeout-minutes` to all workflows. Do it once in `org-dotgithub` shared templates, then propagate.
4. **P3 — ci-autopilot** (Low/Med, flagged): add `--cov-fail-under` coverage threshold; review self-hosted-runner token scope on `fixer.yml` / `runner-health.yml`.

## Approach notes

- Write an org-wide workflow-lint script (PowerShell, lives in root `scripts/`) that asserts: SHA-pinned uses, permissions present, timeout present. This becomes the falsifier for REQ-1.4.10 and can run in the root Pester CI.
- One PR per repo, batched via a driver script; reuse Phase 30's merge-train runbook for landing them.

## Definition of done

- Workflow-lint script passes across all 13 repos.
- Dependabot actions updates enabled org-wide.
- CodeQL matrices match actual repo languages.
