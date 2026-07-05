---
requirements-completed: [REG-01, REG-02]
---

# Plan 10-01 Summary

Vendored immutable releases were synchronized for autogen v1.1.0,
gsd-orchestrator v1.1.0, and reference product v0.1.0.

Release review found that v1.1.0 coupled schema identity to the GitHub Pages
hosting URL. The immutable release was retained as historical evidence and the
canonical namespace was restored in corrective release v1.1.1. Autogen and
gsd-orchestrator now pin the immutable v1.1.1 artifacts.

**Evidence:** autogen 7/7 compatibility tests; reference product 5/5 registry
tests; orchestrator 5/5 compatibility tests; cas-contracts 35/35 tests.

**Commits:** autogen `4dc270e`, reference product `176281a`, orchestrator `de1353c`.

**Corrective commits:** cas-contracts `0b35b98`, autogen `dc07127`,
gsd-orchestrator `12dcd6c` and `41c1950`.
