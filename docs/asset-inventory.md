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

| Asset | Owner | Delegate | Purpose | Runtime surface | Recovery tier | Criticality | Data sensitivity |
|---|---|---|---|---|---|---|---|
| `OgeonX-Ai/cas-workstation` | Portfolio maintainer | Portfolio maintainer | Public workstation bootstrap and governance surface | GitHub Pages + Actions | Tier-0 | Critical | Low |
| `Coding-Autopilot-System/gemini-nano` | Portfolio maintainer | Portfolio maintainer | Research repo for local/browser AI experiments | GitHub Pages + Actions | Tier-2 | Medium | Low |
| `Coding-Autopilot-System/Promptimprover` | Portfolio maintainer | Portfolio maintainer | Prompt middleware and refinement services | GitHub Pages + Actions | Tier-1 | High | Moderate |
| `Coding-Autopilot-System/autogen` | Portfolio maintainer | Portfolio maintainer | Local multi-agent runtime and orchestration experiments | GitHub Pages + Actions | Tier-1 | High | Moderate |
| `Coding-Autopilot-System/autopilot-core` | Portfolio maintainer | Portfolio maintainer | Issue intake and repair automation | GitHub Pages + Actions | Tier-1 | High | Moderate |
| `Coding-Autopilot-System/autopilot-demo` | Portfolio maintainer | Portfolio maintainer | Demonstration surface for automation workflows | GitHub Pages + Actions | Tier-2 | Medium | Low |
| `Coding-Autopilot-System/cas-contracts` | Portfolio maintainer | Portfolio maintainer | Shared goal, task, evidence, and event contracts | GitHub Pages + Actions | Tier-0 | Critical | Low |
| `Coding-Autopilot-System/cas-evals` | Portfolio maintainer | Portfolio maintainer | Deterministic evaluation fixtures and evidence checks | GitHub Pages + Actions | Tier-1 | High | Low |
| `Coding-Autopilot-System/cas-platform` | Portfolio maintainer | Portfolio maintainer | Shared platform and deployment boundaries | GitHub Pages + Actions | Tier-0 | Critical | Moderate |
| `Coding-Autopilot-System/cas-reference-product` | Portfolio maintainer | Portfolio maintainer | Foundry Next Gen reference application | GitHub Pages + Actions | Tier-0 | Critical | Moderate |
| `Coding-Autopilot-System/cas-workstation` | Portfolio maintainer | Portfolio maintainer | Portfolio-local workstation variant | GitHub Pages + Actions | Tier-1 | High | Low |
| `Coding-Autopilot-System/ci-autopilot` | Portfolio maintainer | Portfolio maintainer | CI repair control plane | GitHub Pages + Actions | Tier-1 | High | Moderate |
| `Coding-Autopilot-System/cloud-security-service-model` | Portfolio maintainer | Portfolio maintainer | Security operating model and control reference | GitHub Pages + Actions | Tier-1 | High | Low |
| `Coding-Autopilot-System/gsd-orchestrator` | Portfolio maintainer | Portfolio maintainer | Autonomous issue-to-PR orchestration engine | GitHub Pages + Actions | Tier-0 | Critical | Moderate |
| `Coding-Autopilot-System/.github` | Portfolio maintainer | Portfolio maintainer | Organization-level profile, policy, and shared docs | GitHub Pages + Actions | Tier-1 | High | Low |

## Shared supporting assets

| Asset | Purpose | Current evidence status |
|---|---|---|
| GitHub Actions workflows | Build, verify, release, and Pages deployment | Evidenced in repo workflows |
| GitHub Pages sites | Public documentation and marketing surfaces | Evidenced live for all 15 repos |
| GitHub Wikis | Supplemental repo documentation | Enabled for all 15 repos |
| Local workstation runtime | Tooling, shells, MCP wiring, verification env | Evidenced by workstation docs and scripts |

## Inventory gaps

- Delegate ownership is still concentrated in one maintainer instead of a multi-person operating model
- No formal data classification matrix beyond the initial low/moderate estimates above
- Runtime surfaces are captured at the GitHub layer, but cloud tenants, secret stores, and deployment targets are not yet inventoried here
- Recovery tiers are defined, but they are not yet tied to explicit RTO/RPO values per asset
