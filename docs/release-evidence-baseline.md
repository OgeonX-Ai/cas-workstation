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
- GitHub Actions workflow: `.github/workflows/compliance.yml`
- Attested artifact: `compliance-evidence-<git-sha>.tar.gz`
- Verifier paths:
  - CI verifies the current run attestation before artifact publication
  - `scripts/verify-portfolio-compliance.py` verifies the latest successful attested bundle from GitHub

## Current limitation

The root workstation repo now produces an attested compliance evidence bundle,
but this still does not prove artifact provenance for every releasable asset in
every portfolio repository. It materially closes the root audit trail gap
without yet giving full fleet-wide release signing coverage.
