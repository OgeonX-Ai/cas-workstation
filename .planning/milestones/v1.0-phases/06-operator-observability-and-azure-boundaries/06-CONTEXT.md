---
phase: 06-operator-observability-and-azure-boundaries
status: planned
created: 2026-07-01
---
# Phase 6 Context

The operator surface is a deterministic read model over scheduler state, not a second control plane. Telemetry carries correlation identifiers and bounded metadata only; raw prompts and outputs are excluded. The reference cloud boundary uses Foundry Next Gen agent references, system-assigned managed identity, project-scoped RBAC, and a Linux Flex Consumption ingress that only validates and enqueues work. Azure deployment remains out of scope.
