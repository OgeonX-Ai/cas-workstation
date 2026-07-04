---
status: human_needed
phase: 12
updated: 2026-07-04
---

# Phase 12 UAT

## Passed automatically

- Repository-native builds, tests, linters, and contract checks.
- Offline registry generation, manifest digests, and consumer compatibility.
- Live drift workflows are installed in both v1.1 consumers.

## Human release validation

1. Review and merge the owning `cas-contracts` registry branch.
2. Create and push the intended `v1.1.0` release tag.
3. Confirm Pages serves `/registry/releases/v1.1.0/manifest.json` and `/registry/v1.1/manifest.json`.
4. Run the Autogen and GSD Orchestrator `Contract registry live drift` workflows.
5. Record successful workflow URLs or run identifiers in this file.
