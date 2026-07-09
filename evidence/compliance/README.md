# Compliance Evidence

This directory holds portfolio-level evidence artifacts that support the control
baseline documented under `docs/`.

The goal is not to create static paperwork. Each file here should either:

- record real current-state evidence,
- define the expected schema for future evidence,
- or be directly checked by a verifier.

## Files

- `asset-inventory.csv` - authoritative repo inventory with ownership and classification
- `control-owners.csv` - named control owners and evidence responsibilities
- `risk-register.csv` - machine-readable version of the top portfolio risks
- `supplier-register.csv` - external suppliers and dependency surfaces
- `supply-chain-controls.csv` - repo-by-repo Dependabot, CodeQL, and workflow pinning baseline
- `release-evidence.csv` - release-readiness and lockfile evidence baseline
- `sbom-evidence.csv` - generated SBOM evidence summary across supported ecosystems
- `change-management.csv` - default-branch governance and protection evidence
- `control-crosswalk.csv` - machine-readable control-to-evidence mapping
- `evidence-retention.csv` - retention rules for core audit artifacts
- `vulnerability-management.csv` - disclosure-policy and scanning baseline evidence
- `recovery-drills.csv` - continuity and restore exercise evidence
- `access-review-log.csv` - access review evidence ledger
- `exception-register.csv` - approved exceptions and expiries
- `snapshots/*.json` - timestamped GitHub and repo-state captures used to support the CSV ledgers

## Operating rule

Missing, stale, or malformed evidence should be treated as a control gap. The
verifier should fail loudly instead of silently accepting partial assurance.
