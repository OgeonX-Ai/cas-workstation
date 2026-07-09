# CAS Workstation

CAS Workstation is the Windows-first bootstrap and operating surface for the
Coding-Autopilot-System ecosystem. It gives the portfolio one reproducible
developer baseline: tools, repos, MCP wiring, workstation health checks, and
the canonical planning and governance documents behind the CAS loops.

## Who this site is for

- **Operators** who need the bootstrap, doctor, and start flows for a real CAS workstation
- **Reviewers** who want the architecture, proof points, and governance model without cloning first
- **Contributors** who need the support matrix, runbooks, and phase backlog in one place

## Start here

| Need | Read |
|---|---|
| Understand the thesis behind the system | [Vision](VISION.md) |
| Understand the bootstrap and runtime structure | [Architecture](architecture.md) |
| Check supported platforms and managed repos | [Support Matrix](support-matrix.md) |
| Understand merge operations and release-train handling | [Merge Train Runbook](merge-train-runbook.md) |
| See the current improvement queue and next elite-state gaps | [Improvement Backlog](improvement-backlog.md) |

## Core commands

```powershell
.\cas.ps1 setup
.\cas.ps1 doctor
.\cas.ps1 start
.\cas.ps1 upgrade
.\cas.ps1 uninstall
```

## What this repo manages

- Core developer tooling: Git, GitHub CLI, Node.js, Python, uv, .NET, Docker, Azure CLI, WSL
- AI coder CLIs: Codex, Claude Code, Gemini CLI
- Portfolio repositories under `C:\PersonalRepo\portfolio`
- Shared workstation runtime under `C:\PersonalRepo\.cas`
- Generated MCP client configuration fragments and workstation health surfaces

## Why this repo matters in CAS

The rest of CAS proves governed autonomy across planning, execution, contracts,
evaluation, and CI remediation. This repo is the machine that makes those loops
runnable and reproducible on a real Windows-first workstation.

- The **control story** depends on a predictable local orchestration environment.
- The **execution story** depends on the right local model clients, runtimes, and repo layout.
- The **governance story** depends on stable contracts, health checks, and recoverable state.

Without the workstation layer, the portfolio is an architecture thesis. With it,
the portfolio becomes an executable system.
