# Supply-Chain Baseline

This portfolio baseline defines the minimum supply-chain controls expected for
CAS repositories that execute code, publish artifacts, or operate automation.

## Minimum controls

- Dependabot or equivalent automated dependency update coverage
- CodeQL enabled where GitHub supports the repository language set
- GitHub Actions pinned to immutable commit SHAs
- Package-manager lockfiles committed where an ecosystem supports them
- Release notes and rollback guidance for releasable repositories
- SBOM and provenance publication where practical for published artifacts

## Current direction

- Organization-level dependency and release policy source of truth lives in
  `portfolio/org-dotgithub/docs/DEPENDENCY_POLICY.md` and
  `portfolio/org-dotgithub/docs/RELEASE_POLICY.md`.
- Root `cas-workstation` and `gemini-nano` now include Dependabot and CodeQL
  baselines so they are no longer outliers relative to the portfolio repos.
- Root `cas-workstation` now publishes an attested `compliance-evidence` bundle
  from GitHub Actions so the portfolio has one cryptographically verifiable
  release-evidence path instead of only local CSV snapshots.

## Still not fully proven

- Portfolio-wide SBOM generation and retention
- Portfolio-wide provenance or signing outputs for every releasable asset
- Uniform lockfile coverage across every executable repo
- Evidence that dependency reviews are completed to a standard cadence
- SLA-backed vulnerability remediation history across every repository
