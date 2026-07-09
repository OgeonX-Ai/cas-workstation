# Compliance Gap Register

Status date: 2026-07-09

This register tracks the highest-signal gaps preventing the CAS portfolio from
being credibly described as audit-ready against ISO 27001, DORA, NIS2, NIST
CSF, NIST SSDF, and SLSA-style scrutiny.

## High priority gaps

| Gap | Framework pressure | Current state | Needed evidence |
|---|---|---|---|
| Portfolio asset inventory | ISO 27001, NIS2, CSF | Authoritative repo inventory exists, but owner delegation and runtime-asset coverage remain partial | Repo/system inventory with owner, criticality, data sensitivity, runtime surface |
| Risk register | ISO 27001, DORA, NIS2, CSF | Unified register exists, but residual-risk decisions and due-date tracking remain partial | Central risk log with owner, treatment, due date, residual risk |
| Continuity and recovery | DORA, NIS2, ISO 27001 | Portfolio BCDR baseline and drill evidence exist, but restore cadence and dependency coverage remain partial | RTO/RPO, backup scope, recovery owners, test cadence |
| Incident management baseline | DORA, NIS2, ISO 27001 | Strong material exists in `cloud-security-service-model`, not yet adopted portfolio-wide | Severity matrix, escalation path, evidence template, post-incident loop |
| Supplier and dependency governance | ISO 27001, DORA, NIS2, SLSA | Policy fragments exist, not uniformly evidenced | Dependency review policy, supplier register, exception records |
| SBOM and provenance publication | SLSA, SSDF, DORA | Some release policy language exists, no portfolio-wide enforcement evidence | Artifact SBOMs, provenance/signing outputs, verifier workflow results |
| Access review and privileged control evidence | ISO 27001, DORA, NIS2 | Governance intent exists, no portfolio evidence pack | Access owner list, review cadence, privileged-path audit evidence |
| Change management evidence | ISO 27001, DORA | Baseline and evidence capture now exist, but fleet-wide approval enforcement is still uneven | Change classes, approval model, emergency path, rollback evidence |

## Medium priority gaps

| Gap | Current state | Needed evidence |
|---|---|---|
| Portfolio-wide data classification | Implicit only | Data classes, handling rules, examples |
| Logging and retention baseline | Present in some repos only | Cross-portfolio retention and evidence handling standard |
| Vulnerability-management cadence | Baseline evidence now exists, but SLA-driven remediation history is still incomplete | Scan cadence, SLA targets, exception path |
| Secure configuration baseline | Repo-local patterns vary | Baseline hardening checklist and drift checks |
| Audit evidence ownership | Control ownership is improving, but retention and crosswalk maturity are still partial | Owner map for each control family |

## Current strengths

- All 15 repository Pages sites are live and reachable.
- All 15 repositories have wiki enabled.
- Root governance files now exist for the workstation repo.
- `gemini-nano` now has a verified Pages/docs surface.
- `cas-reference-product` conduct-policy gap is closed on `main`.
- A portfolio verifier now checks inventory, Pages reachability, wiki state, recovery evidence, access-review freshness, and supply-chain baselines.

## Exit criteria for “audit-ready enough to claim”

- Every required control has an owner, evidence source, and retention rule.
- Every critical repo has a mapped control/evidence sheet.
- Every public policy/risk/incident/control document matches real implementation behavior.
- Releaseable repos publish or retain supply-chain evidence where practical.
- Exceptions are explicit, time-bounded, and approved by a named owner.
