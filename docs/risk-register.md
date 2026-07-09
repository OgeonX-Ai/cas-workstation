# Risk Register

Status date: 2026-07-09

Scoring:

- Likelihood: 1 to 5
- Impact: 1 to 5
- Score: likelihood × impact

## Active risks

| ID | Risk | Likelihood | Impact | Score | Owner | Treatment | Status |
|---|---|---:|---:|---:|---|---|---|
| CAS-R001 | Portfolio claims exceed actual control evidence, leading to failed audit or customer trust loss | 4 | 5 | 20 | Portfolio maintainer | Mitigate with control matrix, evidence ownership, and verified operating artifacts | Open |
| CAS-R002 | No unified asset inventory or classification leads to incomplete scope during security or resilience review | 4 | 4 | 16 | Portfolio maintainer | Mitigate with authoritative inventory and ownership model | Open |
| CAS-R003 | No portfolio-wide BCDR baseline causes weak DORA/NIS2 resilience posture | 4 | 5 | 20 | Portfolio maintainer | Mitigate with RTO/RPO, backup scope, and recovery test cadence | Open |
| CAS-R004 | Inconsistent supply-chain evidence across repos weakens release assurance and SLSA posture | 4 | 4 | 16 | Portfolio maintainer | Mitigate with SBOM/provenance baseline and verifier workflow | Open |
| CAS-R005 | Incident handling remains repo-specific instead of portfolio-wide, reducing coordinated response readiness | 3 | 5 | 15 | Portfolio maintainer | Mitigate with severity standard and evidence capture baseline | Open |
| CAS-R006 | Protected repos may lag governance updates because changes require PR flow and explicit merge attention | 3 | 3 | 9 | Portfolio maintainer | Mitigate with governance sweep cadence and tracked PR closure | Open |

## Review cadence

- Monthly: top open risks and remediation progress
- Quarterly: full register review and residual risk decisions
- Pre-release or audit milestone: validate whether evidence actually changed the risk state

## Exit rule

A risk is not closed by writing documentation alone. It closes only when:

1. a control exists,
2. the control has a named owner,
3. the control produces evidence,
4. the evidence is verifiable,
5. the residual risk is accepted or reduced.
