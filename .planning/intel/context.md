# Synthesized Context

## CAS Workstation Purpose

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/README.md

CAS Workstation is the opinionated Windows-first bootstrap bundle for the Coding-Autopilot-System ecosystem. It provides one install surface for a fully configured AI-native coding workstation.

## Workstation Commands

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/README.md

```powershell
.\setup.ps1
.\doctor.ps1
.\start.ps1
.\upgrade.ps1
.\uninstall.ps1
```

## Managed Workstation Capabilities

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/README.md

- Core developer tooling: Git, GitHub CLI, Node.js, Python, uv, .NET, Docker, Azure CLI, WSL
- AI coder CLIs: Codex, Claude Code, Gemini CLI
- Coding-Autopilot-System component repos
- Shared runtime paths under `C:\Users\KimHarjamaki\.cas\`
- Generated MCP client configuration fragments

## Workstation Contract Files

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/README.md

- `stack.manifest.json` - versioned workstation contract
- `schemas/doctor.schema.json` - machine-readable readiness report schema
- `scripts/Cas.Workstation.psm1` - shared implementation module
- `docs/support-matrix.md` - supported platform and component matrix

## Typical Workstation Flow

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/README.md

```powershell
.\setup.ps1 -NonInteractive
.\doctor.ps1
.\start.ps1
```

## Supported Platforms

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/support-matrix.md

| Target | Status | Notes |
|---|---|---|
| Windows 11 + PowerShell 5.1+ | Supported | Primary platform for v1 |
| Windows 11 + WSL2 Ubuntu | Supported | Recommended for Linux-style workflows |
| Windows Server | Limited | Use only for controlled automation hosts |
| macOS | Planned | Not a first-class target yet |
| Linux | Planned | Not a first-class target yet |

## Required Toolchain

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/support-matrix.md

| Component | Requirement | Status |
|---|---|---|
| Git | 2.53.0+ | Required |
| GitHub CLI | 2.86.0+ | Required |
| Node.js | 22.x | Required |
| Python | 3.12+ | Required |
| uv | 0.4+ | Required |
| .NET SDK | 10.x | Required |
| Docker Desktop | 29.x | Required for container workflows |
| Azure CLI | 2.80+ | Required for Azure-enabled workflows |
| WSL2 | Ubuntu default distro | Required |
| Codex CLI | 0.125+ | Required |
| Claude Code | 2.0+ | Required |
| Gemini CLI | 0.45+ | Required |

## CAS Component Profiles

- source: /mnt/c/PersonalRepo/worktrees/loop-engineering/docs/support-matrix.md

| Repo | Purpose | Profile |
|---|---|---|
| Promptimprover | Prompt middleware and MCP server | core, full |
| autogen | Local multi-agent runtime | core, full |
| gsd-orchestrator | Autonomous GitHub issue-to-PR engine | core, full |
| autopilot-core | Org-level issue intake and repair automation | full |
| ci-autopilot | CI repair control plane | full |

