# Control Matrix

Status date: 2026-07-09

This matrix is the portfolio-level bridge between frameworks and evidence. It is
intentionally simple at first: auditors care more about clear ownership and real
evidence than about a decorative spreadsheet.

| Control family | Framework examples | Current evidence | Status |
|---|---|---|---|
| Asset inventory | ISO 27001, NIS2, CSF Identify | [Asset Inventory](asset-inventory.md) | Partial |
| Risk management | ISO 27001, DORA, NIS2, CSF Govern | [Risk Register](risk-register.md), `cloud-security-service-model/docs/09-risk-management.md` | Partial |
| Incident response | ISO 27001, DORA, NIS2, CSF Respond | [Incident Standard](incident-standard.md), `evidence/compliance/incident-management.csv`, `cloud-security-service-model/docs/11-incident-response.md` | Partial |
| Audit evidence handling | ISO 27001, DORA | `cloud-security-service-model/docs/10-audit-readiness.md` | Partial |
| BCDR and resilience | DORA, NIS2, ISO 27001, CSF Recover | [BCDR Baseline](bcdr-baseline.md), `evidence/compliance/recovery-drills.csv` | Partial |
| Supply-chain security | SSDF, SLSA, ISO 27001, CRA | [Supply-Chain Baseline](supply-chain-baseline.md), [SBOM Baseline](sbom-baseline.md), `evidence/compliance/supply-chain-controls.csv`, `evidence/compliance/sbom-evidence.csv` | Partial |
| Secure development lifecycle | NIST SSDF, CSF Protect | repo CI, workflow linting, code review patterns | Partial |
| Public governance posture | ISO 27001, SOC 2 trust expectations | root governance files, repo policies, live Pages sites | Partial |
| Access review baseline | ISO 27001, DORA, NIS2 | `evidence/compliance/access-review-log.csv`, `evidence/compliance/snapshots/` | Partial |
| Change management | ISO 27001, DORA, NIST SSDF | [Change Management Baseline](change-management-baseline.md), `evidence/compliance/change-management.csv` | Partial |
| Evidence retention | ISO 27001, DORA, SOC 2 | [Evidence Retention Baseline](evidence-retention-baseline.md), `evidence/compliance/evidence-retention.csv` | Partial |
| Vulnerability management | ISO 27001, NIST CSF Protect, SSDF | [Vulnerability Management Baseline](vulnerability-management-baseline.md), `evidence/compliance/vulnerability-management.csv` | Partial |

## Detailed crosswalk

For named control IDs, evidence references, and retention expectations, use
[Control Crosswalk](control-crosswalk.md) plus
`evidence/compliance/control-crosswalk.csv`.

## Interpretation

- **Gap**: no credible evidence baseline yet
- **Partial**: control intent exists, but evidence is incomplete or not yet enforced portfolio-wide
- **Ready**: implemented, evidenced, and periodically revalidated

## Current honest state

No major control family is yet at **Ready** across the whole portfolio.

The strongest current areas are:

- public documentation reachability,
- repository governance basics,
- secure workflow hygiene in several core repos,
- security operating-model content in `cloud-security-service-model`,
- machine-checked baseline evidence for repo inventory, Pages, wiki, supply-chain baseline, recovery drills, access review freshness, release evidence, and generated SBOM coverage.

The weakest current areas are:

- BCDR evidence,
- access-review evidence,
- supplier/dependency evidence enforcement,
- unified control ownership,
- portfolio-wide operational proof.
