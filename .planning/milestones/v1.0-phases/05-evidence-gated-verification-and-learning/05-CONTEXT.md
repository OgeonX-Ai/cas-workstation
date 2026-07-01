---
phase: 05-evidence-gated-verification-and-learning
status: ready
---
# Phase 5 Context

- Native repository profiles declare build, test, lint, security, and evaluation checks with mandatory flags and timeouts.
- Missing mandatory tools/checks and timeouts are inconclusive; only all-mandatory-pass may complete.
- Failed mandatory checks create a repair item only when deterministic policy and remaining attempts/iterations/model-call budgets permit.
- v1 artifact, verification, and evaluation records require evidence URIs and validate in `cas-contracts`.
- Promptimprover stores one terminal projection per goal and creates pending lesson candidates; only explicit approval makes them available to future refinement.
- Work stays in isolated `gsd-loop-stability`, `cas-goal-contract`, and `loop-learning` worktrees.
