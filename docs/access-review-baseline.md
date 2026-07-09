# Access Review Baseline

This is the portfolio-level access governance baseline for the managed CAS
repositories.

## Scope

- Default branch and repository administration
- Workflow and release settings
- Pages and wiki configuration where enabled
- Emergency control-path escalation expectations

## Evidence model

- Governance ledger: `evidence/compliance/access-governance.csv`
- Review ledger: `evidence/compliance/access-review-log.csv`
- Snapshot: `evidence/compliance/snapshots/access-review-2026-07-09.json`

## Minimum control

- Every managed repository has a named owner and delegate owner
- Every managed repository declares the privileged control path being reviewed
- Review cadence is at least quarterly
- Emergency or break-glass handling is explicit and incident-linked

## Current limitations

- Ownership remains concentrated in one maintainer
- No external identity-platform export is captured in this portfolio ledger
- Break-glass handling is documented procedurally rather than integrated with a separate approval system
