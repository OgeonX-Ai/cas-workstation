---
phase: 01-stable-workstation-and-recovery
status: passed
verified_at_utc: 2026-06-30T15:12:27Z
root_head: 6ffc21568c5afab595b3157a7bc29e75f97605e1
control_plane_head: 8442bb91329390921f5dfeabfe4b6f51c327a024
---

# Phase 1 Evidence

## Root workstation gate

Owning worktree: `C:\PersonalRepo\worktrees\loop-engineering`; branch: `codex/loop-engineering`.

| Command | Duration | Exit | Sanitized result |
|---|---:|---:|---|
| `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Workstation.Contract.Tests.ps1` | 2949 ms | 0 | Contract passed |
| Parse manifest and doctor schema with `ConvertFrom-Json` | <1 s | 0 | Manifest and MCP health schema present |
| Read-only `doctor.ps1` JSON smoke | <20 s | 0 | Report generated; MCP ready; overall not-ready because normalized-process tools were unavailable |
| Compare global MCP client timestamps before/after doctor | <20 s | 0 | No changes |

RED evidence: the contract initially reported the stale root and MCP paths, four missing repositories, and missing MCP health. The same test is now GREEN.

## Control-plane gate

Owning worktree: `C:\PersonalRepo\worktrees\gsd-loop-stability`; branch: `codex/loop-stability`.

| Command | Duration | Exit | Sanitized result |
|---|---:|---:|---|
| Focused `Resume` and checkpoint-schema tests | 14916 ms | 0 | 13 passed |
| Focused coordinator and watch-store tests | 9987 ms | 0 | 7 passed |
| `dotnet build GithubMCP.slnx --configuration Release --no-restore` | 9334 ms | 0 | Zero warnings/errors |
| Full Release xUnit suite | 9587 ms | 0 | 170 passed |

RED evidence: failed-state recovery initially lacked recoverable metadata; two-repository/failure-isolation tests initially lacked a finite coordinator; persistence tests initially lacked a watch store. All are GREEN.

## Final requirement and roadmap matrix

| Requirement | Roadmap criterion | Current evidence | Regression | Decision |
|---|---:|---|---|---|
| STAB-01 | 1 | Root contract exit 0; exact root/profile/repository paths parse | workstation contract | passed |
| STAB-02 | 2 | Doctor exit 0; Universal Refiner ready; global timestamps unchanged | missing-runtime fixture | passed |
| STAB-03 | 3 | 7 focused and 170 full tests passed | two-repo, first-failure, restart-store tests | passed |
| STAB-04 | 4 | 13 focused and 170 full tests passed | failed-state resume, retry, schema tests | passed |

## Decision

`passed` — every mandatory command was rerun from its owning isolated worktree and current HEAD. No setup, start, push, merge, deploy, external message, or global configuration mutation occurred.

## Residual conditions

- Doctor reports `not-ready` because several tool commands are not discoverable in its normalized PowerShell process. This is workstation readiness information, not a contract failure.
- Root and nested implementation branches remain separate pending an explicit integration/publish action.
