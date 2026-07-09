# Risk Register

Status date: 2026-07-09

Scoring:

- Likelihood: 1 to 5
- Impact: 1 to 5
- Score: likelihood × impact

## Active risks

| ID | Risk | Score | Owner | Due date | Residual risk | Linked control | Status |
|---|---|---:|---|---|---|---|---|
| CAS-R001 | Portfolio claims exceed actual control evidence, leading to failed audit or customer trust loss | 20 | Portfolio maintainer | 2026-07-31 | Medium | CAS-CF-006 | Open |
| CAS-R002 | Asset scope or ownership becomes incomplete during audit review | 12 | Portfolio maintainer | 2026-08-15 | Medium | CAS-CF-001 | Open |
| CAS-R003 | Continuity evidence remains too shallow for resilience review | 20 | Portfolio maintainer | 2026-08-15 | High | CAS-CF-004 | Open |
| CAS-R004 | Inconsistent supply-chain evidence across repos weakens release assurance | 12 | Portfolio maintainer | 2026-08-01 | Medium | CAS-CF-005 | Open |
| CAS-R005 | Incident response remains underexercised despite the new baseline | 12 | Portfolio maintainer | 2026-09-30 | Medium | CAS-CF-003 | Open |
| CAS-R006 | Protected repos may lag governance updates because changes require PR flow and explicit merge attention | 9 | Portfolio maintainer | 2026-08-31 | Medium | CAS-CF-008 | Open |

## Current evidence

- Machine-readable register: `evidence/compliance/risk-register.csv`
- Residual-review and overdue-escalation ledger: `evidence/compliance/risk-review-log.csv`
- Snapshot generator: `scripts/capture-risk-review-evidence.py`
- Exception evidence: `evidence/compliance/exception-register.csv`

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

## Current limitations

- Residual risk is now tracked explicitly, and a derived review ledger now
  records acceptance state and overdue-escalation state for every risk, but it
  is still not an independent second-owner acceptance trail.
- The register still reflects portfolio-maintainer ownership concentration rather than a broader operating model.
