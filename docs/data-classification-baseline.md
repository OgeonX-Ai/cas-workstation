# Data Classification Baseline

This is the portfolio-level classification baseline for CAS repositories and
their audit evidence.

## Classes

| Class | Meaning | Default handling |
|---|---|---|
| Low | Public documentation, open-source code, and low-sensitivity engineering metadata | May appear in public docs and repo artifacts, but still exclude secrets and personal data |
| Moderate | Internal engineering evidence, operational metadata, and control artifacts that should stay maintainer-controlled | Keep in controlled evidence paths; minimize identifiers and avoid public disclosure unless intentionally published |

## Evidence model

- Classification ledger: `evidence/compliance/data-classification.csv`
- Snapshot: `evidence/compliance/snapshots/data-classification-2026-07-09.json`
- Source inventory: `evidence/compliance/asset-inventory.csv`

## Rules

- Every managed asset has a declared class.
- Evidence handling follows the asset class, not the convenience of the storage path.
- Public Pages output should stay within `Low` classification unless a conscious publication decision exists.
- Moderate evidence should remain maintainer-controlled and avoid raw secrets, tokens, or unnecessary identifiers.

## Current limitations

- The model is still two-tier and portfolio-scoped rather than workload-specific.
- No automated secret or identifier classifier is attached to the ledger yet.
