---
phase: 2
nyquist_compliant: true
wave_0_complete: true
---

# Phase 2 Validation

| Gate | Command | Expected |
|---|---|---|
| Goal negatives | `node --test tests/goal-contract.test.mjs` | Missing fields and unbounded limits rejected |
| Full contracts | `npm test` | v0.1 and v1.0 examples and negative tests pass |
| Registry | `npm run build:registry && npm run validate:registry` | Both contract lines discoverable and valid |

Missing tools, schemas, examples, or tests are inconclusive and block completion.
