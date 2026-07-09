# Evidence Retention Baseline

This baseline defines how long the portfolio should retain core audit evidence
artifacts before rotation or regeneration.

## Current implementation

- Machine-readable retention ledger: `evidence/compliance/evidence-retention.csv`
- Evidence directory index: `evidence/compliance/README.md`
- Attested bundle retention: GitHub Actions artifact retention policy on the
  compliance workflow outputs

## Operating rule

- Evidence should either be regenerated on a defined cadence or retained for a
  clearly named period
- Evidence with no owner or retention rule should be treated as a control gap
- Retention settings should match the practical audit window for the artifact

## Honest limitation

This is a portfolio baseline, not a platform-enforced records-management
system. It improves evidence clarity, but it does not yet guarantee immutable
long-term archival outside GitHub and the repository itself.
