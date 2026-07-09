# BCDR Baseline

This is the current business continuity and disaster recovery baseline for the
CAS portfolio. It is a planning and audit-readiness artifact, not proof that all
recovery objectives have been tested in production.

## Recovery intent by asset class

| Asset class | Example assets | RTO target | RPO target | Current state |
|---|---|---|---|---|
| Critical contract and orchestration repos | `cas-contracts`, `gsd-orchestrator`, `cas-platform`, `cas-reference-product` | 1 business day | 4 hours | Not yet formally tested portfolio-wide |
| High-value automation and control repos | `Promptimprover`, `autogen`, `autopilot-core`, `ci-autopilot`, `cas-evals` | 2 business days | 1 business day | Not yet formally tested portfolio-wide |
| Public docs and governance repos | root `cas-workstation`, org `.github`, repo Pages sites | 1 business day | 1 business day | Pages recoverability indirectly evidenced through Git-backed source |
| Research/demo repos | `gemini-nano`, `autopilot-demo` | 3 business days | 2 business days | Best-effort baseline only |

## Minimum recovery dependencies

- GitHub repository availability
- Git history integrity on protected default branches
- Reproducible local bootstrap instructions
- Workflow definitions stored in-repo
- Dependency lockfiles where applicable
- Pages sources and docs definitions stored in-repo

## Current gaps

- No portfolio-wide documented backup ownership or restore drill cadence
- No cross-repo restore exercise evidence
- No formal dependency on external SaaS availability mapped by asset
- No explicit continuity plan for maintainer unavailability

## Required next evidence

1. Repo restore drill from clean checkout for critical repos
2. Workflow recovery drill for at least one critical repo
3. Pages redeploy drill for the public documentation layer
4. Documented maintainer/delegate ownership for recovery approvals
