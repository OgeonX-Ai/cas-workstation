# Provenance Baseline

This baseline defines how the root CAS workstation repository proves that its
compliance evidence bundle was produced by the repository's own GitHub Actions
workflow and can be verified independently.

## Current implementation

- Workflow: `.github/workflows/compliance.yml`
- Subject artifact: `compliance-evidence-<git-sha>.tar.gz`
- Attestation action: `actions/attest@v4` pinned to an immutable commit SHA
- Verification path: `gh attestation verify <bundle> --repo OgeonX-Ai/cas-workstation`

## What this proves

- The compliance bundle digest is bound to a signed GitHub Actions attestation
- The attestation can be validated against the repository and signer workflow
- The bundle can be downloaded from a completed workflow run and verified
  independently from the local workstation

## What this does not yet prove

- Provenance for every publishable artifact in every CAS repository
- Dedicated SBOM attestations for every generated SBOM file
- Commit signing or release tag signing across the portfolio
