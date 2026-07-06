# Azure Rollout Plan — CAS Portfolio (Horizon 3)

> **Status: DRAFT — no resources deployed.** This is the execution-ready plan to
> stand up one Azure environment and produce reproducible pilot evidence.
> Requires operator to supply: target subscription, region, and confirm the
> naming/tenant. No credentials are embedded anywhere; all runtime auth is
> system-assigned managed identity.

## 0. Goal & exit criteria

Prove the v1.0 loop engineering system runs in its **target cloud runtime**, not
just in-repo. Done when:

1. One environment is provisioned from `cas-platform` Bicep with zero manual portal edits.
2. `cas-reference-product` runs on Flex Consumption (Linux) with a Foundry Next Gen agent, authenticating via managed identity.
3. The **four v1 pilot scenarios** execute end-to-end and emit schema-valid evidence to `cas-evals`.
4. Cost and safety signals are visible in App Insights dashboards with alerts wired.

## 1. Assumptions to confirm before execution

| Item | Default | Needs operator confirm |
|---|---|---|
| Subscription | — | ✅ required |
| Region | `swedencentral` (Foundry Next Gen availability) | ✅ |
| Environment name | `cas-pilot` | ✅ |
| Foundry model | `claude-opus-4-8` / latest available | ✅ |
| Budget guardrail | $X/day hard cap | ✅ |

## 2. Rollout phases

### Phase A — Identity & platform baseline (`cas-platform`)
- Deploy the landing-zone Bicep: resource group, Log Analytics workspace, App Insights, Key Vault (RBAC mode, no access policies), managed identity, and diagnostic settings.
- **No secrets in Key Vault** for app auth — Key Vault holds only non-identity config if any. App→Azure auth is managed identity + RBAC role assignments (`Azure AI User`, `Monitoring Metrics Publisher`, etc.).
- Gate: `what-if` clean, then `az deployment ... --confirm-with-what-if`.

### Phase B — Foundry Next Gen agent
- Provision the Foundry project + Next Gen agent (`WorkflowAgentService`) per `cas-reference-product/.foundry/agent-metadata.yaml`. **Reject any Classic Assistant (`asst_*`).**
- Assign the app's managed identity the agent's data-plane role.
- Gate: agent responds to a smoke prompt via managed identity from a Flex Consumption context (not a local key).

### Phase C — Reference product on Flex Consumption
- Build the Linux AMD64 container (`Dockerfile`, port 8080) and deploy to a **Flex Consumption** Function/Container App per the CAS default.
- Wire OpenTelemetry → App Insights. Confirm liveness/readiness probes.
- Gate: `/api/v1/workflows` returns a valid `RunEvent` with a real trace in App Insights.

### Phase D — Pilot evidence (`cas-evals`)
- Run the four v1 pilot scenarios against the deployed environment.
- Capture schema-valid evidence artifacts; assert every mandatory verifier + acceptance criterion passes (no scenario reaches `Completed` otherwise).
- Gate: `cas-evals` produces a reproducible evidence bundle; re-run yields equivalent results.

### Phase E — Cost & safety observability
- App Insights workbook: token/cost per goal, per-scenario latency, verifier pass rate, worker fan-out concurrency.
- **Cost guardrail**: budget alert + hard stop tied to the loop's bounded stop condition.
- **Safety signals**: surface `Assert-SafeChangeSet`-class denials and approval-gated learning events as first-class telemetry.
- Gate: a deliberately over-budget run trips the alert and the loop stops on a bounded stop condition.

## 3. Sequencing & rollback
- Deploy order matches the v1.0 integration lesson: platform → identity → agent → app → evidence.
- Each phase is a separate `az deployment` with `what-if` preview; rollback = redeploy prior template revision (infra is declarative, stateless app).
- Everything scripted under `cas-platform/scripts` + `cas-reference-product/deployment` — no portal clicks, so the environment is reproducible and destroyable.

## 4. What this plan deliberately excludes (still deferred)
Multi-machine scheduling, Kubernetes delivery, and automatic production deploy
remain out of scope until this single-environment pilot produces real operator-need evidence.

## 5. Open follow-up surfaced during Horizon 2
Publish `cas-contracts` as a versioned package to a registry so consumer
contract-compatibility CI can diff against the pinned upstream **in CI** (today it
vendors per-consumer and only diffs upstream in local dev). This should land
before or alongside Phase D so pilot evidence validates against a published contract.
