# SBOM Baseline

This baseline covers generated software bill of materials evidence for supported
ecosystems in the current local CAS workspace.

## Current capture scope

- Python `requirements.txt` targets through `cyclonedx-py`
- npm lockfile targets through `@cyclonedx/cyclonedx-npm`
- .NET project targets through `CycloneDX` for .NET

## Evidence locations

- Summary ledger: `evidence/compliance/sbom-evidence.csv`
- Generated artifacts: `evidence/compliance/sbom/`
- Snapshot metadata: `evidence/compliance/snapshots/sbom-evidence-*.json`

## Current limitation

This is generated local evidence. The root compliance bundle is now attested,
but individual SBOM files are not yet all published with their own dedicated
SBOM attestations across every repository. It improves audit posture materially,
but it does not close the full SLSA / CRA / DORA-style artifact integrity
requirement by itself.
