# Phase 28-01 Summary

## Outcome

Added fault-injection coverage for `gsd-orchestrator` checkpoint recovery and hardened the state machine so transient MCP failures persist the actual failed state for deterministic single-state retry.

## Delivered

- Added `src/GsdOrchestrator.Tests/FaultInjectionTests.cs`
  - mid-goal MCP failure produces a typed failed checkpoint
  - failed-state resume retries once, then halts on the retry ceiling
  - failure reasons are truncated to 1024 chars
  - budget-flavored failure messages map to `TerminalStopReason.BudgetExhausted`
- Added `src/GsdOrchestrator.Tests/CheckpointCorruptionTests.cs`
  - corrupted final checkpoint raises `JsonException`
  - orphaned `.tmp` sibling leaves the last good checkpoint loadable
  - unsupported schema version raises `InvalidDataException`
  - legacy `1.0` checkpoints upgrade to `1.1`
- Updated `src/GsdOrchestrator/Workflows/GsdStateMachine.cs`
  - transient `McpException` failures now bypass the SDLC rollback cascade and persist the actual failed state for `ResumeAsync`

## Verification Evidence

- Targeted fault-injection tests:
  - `dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj --no-build --filter FullyQualifiedName~FaultInjectionTests`
  - passed `4/4`
- Targeted checkpoint-corruption tests:
  - `dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj --no-build --filter FullyQualifiedName~CheckpointCorruptionTests`
  - passed `4/4`
- Full suite:
  - `dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj`
  - passed `239/239`

## Important Execution Detail

The original test-only plan exposed a real runtime defect: MCP exceptions thrown from a workflow state were being rolled back through the SDLC state map until the failed checkpoint settled on `Idle`, which broke the intended "retry the failed state once, then halt" contract. `28-01` therefore included one production-code deviation in `GsdStateMachine.cs` to preserve the actual failed state for transient MCP failures.

The checkpoint corruption tests were also aligned to the real `FileCheckpointStore` serializer by rewriting the on-disk `schemaVersion` field after `SaveAsync`, instead of generating synthetic JSON with enum-string formatting that production does not use.

## Next Phase Readiness

Phase `28-01` is complete and verified. The next planned slice is `28-02`, which moves Phase 28 fault-injection coverage into `autogen` for structured JSON telemetry and CLI fallback size limits.
