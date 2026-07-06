# Phase 33: Azure Infra Hardening — Context

**Gathered:** 2026-07-06
**Status:** Ready for planning (`/gsd:plan-phase 33`) — depends on Phase 30
**Backlog refs:** P1 (✅), P2 (🔎), P4 (🔎)

## Scope

1. **P1 — cas-platform `observability.bicep:30-46`** hardcodes `publicNetworkAccess: Enabled` with no per-env parameter. Auth is already AAD-only (`DisableLocalAuth`, resource-permissions) so this is defense-in-depth, not an open door — parameterize with secure-by-default (`Disabled` for prod).
2. **P2 — Bicep linting**: add `.bicepconfig.json` with lint rules to cas-platform and cloud-security-service-model; pin API versions consistently.
3. **P4 — cloud-security-service-model** policy assignment runs in `DoNotEnforce` audit mode — confirm intent; either flip to `Default` enforcement or document the decision with a tracking item.

## Standards to honor

- GLOBAL_AGENTS.md: managed identity only, no embedded secrets, Flex Consumption (Linux) for Functions.
- Use the `bicep-architect` agent for the design review before edits.

## Definition of done (REQ-1.4.14)

- `bicep lint` clean under `.bicepconfig.json` in both repos.
- `publicNetworkAccess` parameterized per environment; prod default `Disabled`.
- P4 decision recorded (enforce or documented exception).
