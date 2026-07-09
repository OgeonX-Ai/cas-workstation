# Compliance Baseline

This portfolio is not certified against formal regimes, but it can be made
audit-ready by mapping repo evidence and operating controls to the primary
frameworks that matter for modern software delivery and regulated technology
operations.

## Target frameworks

### NIST CSF 2.0

Use as the top-level organizing model for governance, asset inventory, risk,
protection, detection, response, and recovery.

### NIST SSDF (SP 800-218)

Use as the software delivery control model for secure development practices,
verification, change integrity, review, and release hygiene.

### SLSA

Use as the software supply-chain integrity model for build provenance,
dependency control, and tamper resistance.

### ISO/IEC 27001

Use as the information security management baseline for policy, access control,
logging, incident response, supplier governance, asset management, and
continuous improvement.

### DORA

Use as the financial-sector operational resilience model for ICT risk
management, incident handling, resilience testing, third-party oversight, and
business continuity.

### NIS2

Use as the EU cybersecurity governance baseline for management accountability,
incident reporting readiness, supply-chain security, continuity, and secure use
of network and information systems.

## What is already evidenced in CAS

- Portfolio-wide public documentation and repository Pages surfaces
- Repository-level `SECURITY.md`, `CONTRIBUTING.md`, and wiki surfaces across the portfolio
- Pinned-action and workflow linting in multiple repositories
- CodeQL and CI coverage in the major platform repos
- Threat-model, incident-response, audit-readiness, and control-owner style documentation in `cloud-security-service-model`
- Threat-model and operations documentation in `cas-platform`
- Safety and ownership controls in workstation automation and tests

## What is not yet proven portfolio-wide

- Central asset inventory with owners, criticality, and data classification
- Portfolio-wide risk register and exception register
- Incident severity model, escalation matrix, and evidence retention policy applied across all repos
- Business continuity and disaster recovery objectives with owners and test cadence
- Formal supplier and dependency governance records across every repo
- SBOM and provenance publication for all releaseable artifacts
- Access-review, change-approval, and evidence-retention operating records
- Portfolio-level audit control mapping with pass/fail evidence per control

## New baseline evidence added

- Change-management ledger: `evidence/compliance/change-management.csv`
- Evidence-retention ledger: `evidence/compliance/evidence-retention.csv`
- Control crosswalk: `evidence/compliance/control-crosswalk.csv`
- Vulnerability-management ledger: `evidence/compliance/vulnerability-management.csv`
- Data-classification ledger: `evidence/compliance/data-classification.csv`

## Readiness principle

“Enterprise-ready” for this portfolio should mean:

1. A control exists.
2. The control has an owner.
3. The control produces evidence.
4. The evidence has a retention rule.
5. The evidence is actually verifiable from repo or runtime state.

Without those five properties, the portfolio may look mature but will still fail
serious audit testing.
