# Compliance Gap Register

Status date: 2026-07-09

This register tracks the highest-signal gaps preventing the CAS portfolio from
being credibly described as audit-ready against ISO 27001, DORA, NIS2, NIST
CSF, NIST SSDF, and SLSA-style scrutiny.

## High priority gaps

| Gap | Framework pressure | Current state | Needed evidence |
|---|---|---|---|
| Portfolio asset inventory | ISO 27001, NIS2, CSF | Authoritative repo inventory now includes delegate ownership, runtime surface, and recovery tier, but non-GitHub infrastructure inventory remains partial | Repo/system inventory with owner, criticality, data sensitivity, runtime surface |
| Risk register | ISO 27001, DORA, NIS2, CSF | Unified register now tracks due dates, residual risk, linked controls, and a freshness-checked derived review ledger, but independent residual-risk acceptance evidence and explicit overdue escalation proof remain partial | Central risk log with owner, treatment, due date, residual risk |
| Continuity and recovery | DORA, NIS2, ISO 27001 | Portfolio BCDR baseline now includes per-asset objectives and drill evidence, but restore cadence and dependency coverage remain partial | RTO/RPO, backup scope, recovery owners, test cadence |
| Incident management baseline | DORA, NIS2, ISO 27001 | Portfolio baseline and tabletop evidence now exist, but live incident history is still thin | Severity matrix, escalation path, evidence template, post-incident loop, repeated exercises |
| Supplier and dependency governance | ISO 27001, DORA, NIS2, SLSA | Baseline and supplier review ledger now exist, but cadence history and exception usage remain partial | Dependency review policy, supplier register, exception records |
| SBOM and provenance publication | SLSA, SSDF, DORA | Portfolio provenance ledger now exists, but most repos still stop at SBOM or local evidence rather than attested workflows | Artifact SBOMs, provenance/signing outputs, verifier workflow results |
| Access review and privileged control evidence | ISO 27001, DORA, NIS2 | Governance ledger and review evidence now exist, but identity-platform export and multi-owner approval evidence remain partial | Access owner list, review cadence, privileged-path audit evidence |
| Change management evidence | ISO 27001, DORA | Baseline, live fleet-wide minimum approval enforcement, and evidence capture now exist, but emergency-change approval trails remain partial | Change classes, approval model, emergency path, rollback evidence |

## Medium priority gaps

| Gap | Current state | Needed evidence |
|---|---|---|
| Portfolio-wide data classification | Baseline ledger and handling rules now exist, but the model is still coarse and workload-level mapping is incomplete | Data classes, handling rules, examples |
| Logging and retention baseline | Present in some repos only | Cross-portfolio retention and evidence handling standard |
| Vulnerability-management cadence | Baseline evidence now exists, but SLA-driven remediation history is still incomplete | Scan cadence, SLA targets, exception path |
| Incident exercise cadence | First tabletop evidence now exists, but repeated drills and postmortem history are still incomplete | Quarterly exercise ledger, follow-up actions, closure evidence |
| Supplier review cadence | First supplier governance review cycle now exists, but repeat reviews and exception trails are still incomplete | Quarterly review history, exception records, owner sign-off |
| Provenance rollout coverage | Root repo is attested and a fleet ledger now exists, but most repositories still lack attestation workflows | More `attested` rows and repo-level verifier coverage |
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
