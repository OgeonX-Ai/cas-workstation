---
phase: 1
slug: stable-workstation-and-recovery
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-06-30
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Self-contained PowerShell contract tests plus xUnit/NSubstitute |
| **Config file** | `tests/Workstation.Contract.Tests.ps1`; `portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj` |
| **Quick run command** | Run the owning worktree's focused PowerShell or filtered `dotnet test` command |
| **Full suite command** | Root contract/doctor gates plus `dotnet build` and full `dotnet test` in the GSD child worktree |
| **Estimated runtime** | 300 seconds maximum for the combined local gate |

## Sampling Rate

- **After every task commit:** Run the focused command declared by that task.
- **After every plan wave:** Run every full gate for repositories changed in that wave.
- **Before `$gsd-verify-work`:** Root contract tests, doctor smoke, GSD build, and GSD full tests must be green.
- **Max feedback latency:** 300 seconds.

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | STAB-01, STAB-02 | T-01-01 | Path inputs remain manifest-controlled and repo-contained | contract | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Workstation.Contract.Tests.ps1` | ✅ | ✅ green |
| 01-02-01 | 02 | 1 | STAB-04 | T-01-02 | Unsupported/tampered checkpoints fail closed; recovery is bounded | unit | `dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj --filter "FullyQualifiedName~Resume"` | ✅ | ✅ green |
| 01-03-01 | 03 | 2 | STAB-03 | T-01-03 | Deduplication prevents duplicate side effects without losing failures | unit | `dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj --filter "FullyQualifiedName~Watch"` | ✅ | ✅ green |
| 01-04-01 | 04 | 3 | STAB-01, STAB-02, STAB-03, STAB-04 | T-01-01, T-01-02, T-01-03 | All Phase 1 safety boundaries hold together | integration | Run the root contract/doctor gates and GSD build/full test gates | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

## Wave 0 Requirements

- [x] `tests/Workstation.Contract.Tests.ps1` — deterministic STAB-01/STAB-02 contract assertions with temporary paths and no external side effects.
- [x] `src/GsdOrchestrator.Tests/WatchCoordinatorTests.cs` — two-repository, failure-isolation, restart-deduplication, and success-only processing tests for STAB-03.
- [x] Extend `src/GsdOrchestrator.Tests/GsdStateMachineTests.cs` or add focused recovery tests that reproduce terminal-failed resume for STAB-04.

## Manual-Only Verifications

All Phase 1 behaviors have automated verification. Reviewing the sanitized evidence bundle is an operator sign-off, not a substitute for an automated gate.

## Failure Semantics

- A failing mandatory command blocks plan and phase completion.
- A missing required tool, project, or check is `inconclusive`, never `passed`.
- Deterministic test failures are not retried without a code or fixture change.
- A transient restore failure may be retried once after explicit `dotnet restore`.
- Timeouts: 60 seconds root contract tests, 120 seconds focused .NET tests, 300 seconds full build/test.
- Evidence records command, cwd, exit code, duration, and sanitized summary without secrets or raw external payloads.

## Validation Sign-Off

- [x] All planned task boundaries have an automated command or Wave 0 dependency.
- [x] Sampling continuity prevents three consecutive tasks without automated verification.
- [x] Wave 0 identifies every missing test artifact.
- [x] No validation command uses an unbounded watch-mode flag.
- [x] Maximum feedback latency is 300 seconds.
- [x] `nyquist_compliant: true` is set in frontmatter.

**Approval:** planning contract approved 2026-06-30; execution evidence pending.
