# CAS Workstation — PersonalRepo Global Standards

This is the root workspace for the **Coding-Autopilot-System (CAS)** portfolio and workstation bundle. It is a Windows-first, AI-native development environment managed under `C:\PersonalRepo`.

## Workspace Layout

```
C:\PersonalRepo\
├── portfolio\
│   ├── gsd-orchestrator\       # C#/.NET 10 — autonomous GitHub workflow engine
│   ├── Promptimprover\         # TypeScript — MCP server for prompt governance
│   ├── autogen\                # Python — Microsoft Agent Framework multi-agent runtime
│   ├── cas-reference-product\  # Python — Foundry Next Gen reference app (FastAPI)
│   ├── cloud-security-service-model\  # Architecture / docs
│   ├── cas-evals\              # Evaluation harness for CAS agent outputs
│   ├── cas-contracts\          # Shared schemas / contracts registry
│   ├── cas-platform\           # Azure infra (Bicep) for CAS platform services
│   ├── autopilot-core\         # Core autopilot engine library
│   ├── autopilot-demo\         # Autopilot demo/reference consumer
│   ├── ci-autopilot\           # CI automation and self-hosted runner tooling
│   ├── cas-workstation\        # Coding-Autopilot-System/cas-workstation (see note below)
│   └── org-dotgithub\          # Org-wide .github profile and shared workflow templates
├── gemini-nano\                # Experimental Gemini Nano integration demos
├── stack.manifest.json         # CAS Workstation versioned contract (tools, repos, services)
├── setup.ps1 / doctor.ps1      # Workstation bootstrap and health check scripts
└── docs\
```

**Note — two `cas-workstation` repos, two orgs:** This ROOT repo
(`C:\PersonalRepo`) pushes to `OgeonX-Ai/cas-workstation`.
`portfolio/cas-workstation` is a separate, independent repo pushing to
`Coding-Autopilot-System/cas-workstation`. Same repo name, different GitHub
orgs — verify the remote (`git remote -v`) before pushing from either checkout
to avoid mis-targeting.

## Global Standards

- **Identity**: Managed identity only for Azure. No embedded secrets, keys, or tokens.
- **Azure Functions**: Flex Consumption (Linux). Stateless, short-lived, retry-friendly.
- **Foundry**: Always use Foundry Next Gen Agents (`WorkflowAgentService`). Never Classic Assistants (`asst_*`).
- **Paths**: Windows-first. Always use explicit Windows paths (`C:\`). Never use or resolve Unix-style paths (`/mnt/c/`) to avoid sandbox ACL lock failures.
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

For all SDLC logic, verification loops, and global constraints, follow the Canonical AI Engineering Operating Contract:
- `C:\PersonalRepo\engineering-os\OPERATING-CONTRACT.md`
