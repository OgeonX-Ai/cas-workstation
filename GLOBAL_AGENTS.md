> [!CAUTION]
> ## 🚫 HARD LOCK: NO AZURE — LOCAL MACHINE ONLY
>
> **Do NOT** provision, deploy, configure, suggest, or reference **any Azure service or resource** in any project under this workspace.
>
> This includes: Azure Functions, Azure Storage, Azure OpenAI Service, Azure DevOps, Azure Container Apps, Azure Key Vault, `az`/`azd` CLI, Bicep, ARM templates, or any GitHub Actions that deploy to Azure.
>
> **Everything runs locally on this Windows machine.** Free cloud API *keys* (OpenRouter, Groq, Google AI Studio, Cerebras) are allowed — cloud *deployments* are not.
>
> Cloud hosting will be revisited in a future milestone. Until then this is an **immutable constraint** that overrides any sub-project instruction.

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

## Workspace Hygiene Locks

- **No WSL-created worktrees.** Never register a git worktree from inside WSL
  against a repo under `C:\PersonalRepo`. WSL registers worktree paths in
  Unix `/mnt/c/...` form, which breaks git on native Windows and is flagged by
  `scripts/workspace-health.ps1` (`worktree-unix-path` finding). Create and
  manage worktrees from Windows PowerShell only.
- **`.ps1` files must be ASCII-only, or explicitly UTF-8 with a BOM.**
  BOM-less `.ps1` files are read as the legacy ANSI/OEM codepage by
  PowerShell 5.1, silently corrupting any non-ASCII character (em-dashes,
  curly quotes, accented characters) and causing parse or runtime failures.
  `scripts/workspace-health.ps1` flags plain non-ASCII `.ps1` files
  (`non-ascii-ps1` finding). Keep script source ASCII-only unless a BOM is
  present.

## Working-Tree Lease Protocol

Multiple AI sessions (Claude, Codex, Gemini, ...) can run against this
workstation concurrently. A primary checkout (the root repo or any
`portfolio/*` repo's non-worktree working tree) has exactly one writer at a
time; collisions between two sessions editing the same primary checkout are
resolved by luck without a coordination signal. The lease convention below
makes ownership explicit instead.

- **Before mutating a repo's primary checkout**, a session writes a
  `.cas-lease.json` file at that repo's root:
  ```json
  {
    "agent": "claude",
    "session": "260711-a1a2-guardrails",
    "since": "2026-07-11T12:00:00Z",
    "ttl_hours": 4
  }
  ```
  `agent` identifies the AI tool (`claude`, `codex`, `gemini`, ...); `session`
  is a short human-readable identifier for the task/branch; `since` is the
  UTC timestamp the lease was written (ISO 8601); `ttl_hours` is how long the
  lease is presumed valid (default `4`).
- **While a live (non-stale) lease exists**, other sessions must not mutate
  that primary checkout directly — use an isolated `git worktree` instead
  (see `docs/merge-train-runbook.md` and existing `worktrees/*` precedent).
- **Stale leases** (current time past `since + ttl_hours`) may be replaced by
  a new session without asking — the original session is presumed to have
  ended (crashed, timed out, or forgot to clean up). Overwrite the file with
  a fresh lease rather than deleting-then-recreating, so a concurrent reader
  never observes a "no lease" gap.
- **Release the lease** by deleting `.cas-lease.json` when the mutating
  session's work is committed/pushed and the checkout is clean again.
- **Lease files are gitignored** (see `.gitignore`) — they are local
  coordination state, not tracked history. The root repo's `.gitignore`
  covers this; sub-repos under `portfolio/*` should adopt the same
  `.cas-lease.json` gitignore entry in their next hygiene pass (not yet
  backfilled across all 13 repos as of this writing).
- **Sweep enforcement**: `scripts/workspace-health.ps1` flags a lease past
  its TTL (`stale-lease`) and a dirty working tree with no lease file at all
  (`unleased-dirty`, advisory — it does not block, since not every git user
  in this workspace is an AI session honoring the convention yet).

## AI Operating Manual

For all SDLC logic, verification loops, and global constraints, follow the Canonical AI Engineering Operating Contract:
- `C:\PersonalRepo\engineering-os\OPERATING-CONTRACT.md`
