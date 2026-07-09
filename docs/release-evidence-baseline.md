# Release Evidence Baseline

This baseline defines the minimum evidence expected for repos that publish
artifacts, expose public install surfaces, or operate automation that changes
production-relevant state.

## Minimum release evidence

- release policy source is defined
- dependency update path is active
- code scanning path is active
- Pages or equivalent public-doc workflow is present where the repo has a public doc surface
- lockfiles exist where the ecosystem uses them practically

## Current implementation

- Central release policy source of truth: `portfolio/org-dotgithub/docs/RELEASE_POLICY.md`
- Machine-readable ledger: `evidence/compliance/release-evidence.csv`
- Snapshot generator: `scripts/capture-release-evidence.py`

## Honest limitation

This is still release-readiness evidence, not full artifact provenance. It does
not yet prove SBOM generation, signing, attestation, or immutable release
verification for every releasable asset.
