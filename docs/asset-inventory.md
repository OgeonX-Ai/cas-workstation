# Asset Inventory

Status date: 2026-07-09

This is the portfolio-level inventory for the current CAS repository set. It is
the minimum authoritative inventory needed before ISO 27001, DORA, NIS2, SOC 2,
or similar audits can be answered credibly.

## Classification scale

- **Critical**: failure materially affects portfolio governance, release safety, or core control assurance
- **High**: failure breaks a major platform, contract, or operational workflow
- **Medium**: failure degrades a supporting capability or research surface

## Repository inventory

| Asset | Owner | Purpose | Exposure | Criticality | Data sensitivity |
|---|---|---|---|---|---|
| `OgeonX-Ai/cas-workstation` | Portfolio maintainer | Public workstation bootstrap and governance surface | Public docs + repo | Critical | Low |
| `Coding-Autopilot-System/gemini-nano` | Portfolio maintainer | Research repo for local/browser AI experiments | Public docs + repo | Medium | Low |
| `Coding-Autopilot-System/Promptimprover` | Portfolio maintainer | Prompt middleware and refinement services | Public docs + repo | High | Moderate |
| `Coding-Autopilot-System/autogen` | Portfolio maintainer | Local multi-agent runtime and orchestration experiments | Public docs + repo | High | Moderate |
| `Coding-Autopilot-System/autopilot-core` | Portfolio maintainer | Issue intake and repair automation | Public docs + repo | High | Moderate |
| `Coding-Autopilot-System/autopilot-demo` | Portfolio maintainer | Demonstration surface for automation workflows | Public docs + repo | Medium | Low |
| `Coding-Autopilot-System/cas-contracts` | Portfolio maintainer | Shared goal, task, evidence, and event contracts | Public docs + repo | Critical | Low |
| `Coding-Autopilot-System/cas-evals` | Portfolio maintainer | Deterministic evaluation fixtures and evidence checks | Public docs + repo | High | Low |
| `Coding-Autopilot-System/cas-platform` | Portfolio maintainer | Shared platform and deployment boundaries | Public docs + repo | Critical | Moderate |
| `Coding-Autopilot-System/cas-reference-product` | Portfolio maintainer | Foundry Next Gen reference application | Public docs + repo | Critical | Moderate |
| `Coding-Autopilot-System/cas-workstation` | Portfolio maintainer | Portfolio-local workstation variant | Public docs + repo | High | Low |
| `Coding-Autopilot-System/ci-autopilot` | Portfolio maintainer | CI repair control plane | Public docs + repo | High | Moderate |
| `Coding-Autopilot-System/cloud-security-service-model` | Portfolio maintainer | Security operating model and control reference | Public docs + repo | High | Low |
| `Coding-Autopilot-System/gsd-orchestrator` | Portfolio maintainer | Autonomous issue-to-PR orchestration engine | Public docs + repo | Critical | Moderate |
| `Coding-Autopilot-System/.github` | Portfolio maintainer | Organization-level profile, policy, and shared docs | Public docs + repo | High | Low |

## Shared supporting assets

| Asset | Purpose | Current evidence status |
|---|---|---|
| GitHub Actions workflows | Build, verify, release, and Pages deployment | Evidenced in repo workflows |
| GitHub Pages sites | Public documentation and marketing surfaces | Evidenced live for all 15 repos |
| GitHub Wikis | Supplemental repo documentation | Enabled for all 15 repos |
| Local workstation runtime | Tooling, shells, MCP wiring, verification env | Evidenced by workstation docs and scripts |

## Inventory gaps

- No per-repo system owner or delegate owner list beyond the portfolio maintainer assumption
- No formal data classification matrix beyond the initial low/moderate estimates above
- No inventory of runtime environments, tenants, secrets stores, or deployment targets outside repo docs
- No authoritative mapping from assets to recovery objectives or retention obligations
