# CAS Workstation — PersonalRepo

This is the root workspace for the **Coding-Autopilot-System (CAS)** portfolio and workstation bundle. It is a Windows-first, AI-native development environment managed under `C:\PersonalRepo`.

## Workspace Layout

```
C:\PersonalRepo\
├── portfolio\
│   ├── gsd-orchestrator\       # C#/.NET 10 — autonomous GitHub workflow engine
│   ├── Promptimprover\         # TypeScript — MCP server for prompt governance
│   ├── autogen\                # Python — Microsoft Agent Framework multi-agent runtime
│   ├── cas-reference-product\  # Python — Foundry Next Gen reference app (FastAPI)
│   └── cloud-security-service-model\  # Architecture / docs
├── gemini-nano\                # Experimental Gemini Nano integration demos
├── stack.manifest.json         # CAS Workstation versioned contract (tools, repos, services)
├── setup.ps1 / doctor.ps1      # Workstation bootstrap and health check scripts
└── docs\
```

## Context Chain

Each sub-project has its own `AGENTS.md` (or `context.md`). Always read the nearest context file before making changes in a directory. Walk up to this root file for workspace-level rules.

| Project | Context file |
|---|---|
| gsd-orchestrator | `portfolio/gsd-orchestrator/AGENTS.md` |
| Promptimprover | `portfolio/Promptimprover/AGENTS.md` → `context.md` tree |
| autogen | `portfolio/autogen/AGENTS.md` |
| cas-reference-product | `portfolio/cas-reference-product/AGENTS.md` |
| gemini-nano | `gemini-nano/AGENTS.md` |

## Global Standards (from GLOBAL_AGENTS.md)

- **Identity**: Managed identity only for Azure. No embedded secrets, keys, or tokens.
- **Azure Functions**: Flex Consumption (Linux). Stateless, short-lived, retry-friendly.
- **Foundry**: Always use Foundry Next Gen Agents (`WorkflowAgentService`). Never Classic Assistants (`asst_*`).
- **Design**: Composition over inheritance, DI over hard-coding, guard clauses and early returns.
- **Workflow**: Research → Strategy → Execution. Reproduce bugs with a test before fixing.

## Stack Defaults

| Tool | Required version |
|---|---|
| .NET SDK | ≥ 10.0 |
| Node.js | ≥ 22.0 |
| Python | ≥ 3.12 |
| Azure CLI | ≥ 2.80 |
| GitHub CLI | ≥ 2.86 |

## GSD Workflow Enforcement

Use GSD entry points before direct file edits:
- `/gsd:quick` — small fixes, docs, ad-hoc tasks
- `/gsd:debug` — investigation and bug fixing
- `/gsd:plan-phase` + `/gsd:execute-phase` — planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly bypasses it.

## AI Operating Manual

For local agent behavior in this workspace, follow:
- `docs/ai/ai-engineering-operating-system.md`
- `docs/ai/loop-catalog.md`
- `docs/ai/verifier-catalog.md`
- `codex.md`
