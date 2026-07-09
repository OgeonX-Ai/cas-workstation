# Provenance Baseline

This baseline defines how the root CAS workstation repository proves that its
compliance evidence bundle was produced by the repository's own GitHub Actions
workflow and can be verified independently.

## Current implementation

- Workflow: `.github/workflows/compliance.yml`
- Subject artifact: `compliance-evidence-<git-sha>.tar.gz`
- Attestation action: `actions/attest@v4` pinned to an immutable commit SHA
- In-workflow verification: `gh attestation verify` against the current run's bundle before artifact publication
- Workstation verification: `scripts/verify-portfolio-compliance.py` downloads the latest successful bundle artifact and verifies it with `gh attestation verify`
- Portfolio ledger: `evidence/compliance/provenance-evidence.csv`

## What this proves

- The compliance bundle digest is bound to a signed GitHub Actions attestation
- The attestation can be validated against the repository and signer workflow
- The bundle can be downloaded from a completed workflow run and verified
  independently from the local workstation

## What this does not yet prove

- Provenance for every publishable artifact in every CAS repository
- Dedicated SBOM attestations for every generated SBOM file
- Commit signing or release tag signing across the portfolio

## Portfolio status model

- `attested`: repository has an attestation workflow marker
- `evidence-only`: repository has SBOM or local provenance evidence, but no attestation workflow yet
- `gap`: repository has neither attestation workflow nor linked provenance evidence in the current ledger
