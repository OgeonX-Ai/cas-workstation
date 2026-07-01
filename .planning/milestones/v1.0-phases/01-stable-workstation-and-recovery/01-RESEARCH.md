# Phase 1 Research: Stable Workstation and Recovery

**Phase:** 1  
**Requirements:** STAB-01, STAB-02, STAB-03, STAB-04  
**Research question:** What must be known to plan the stabilization phase without amplifying current defects?

## Executive Finding

Phase 1 must be implemented as two repository-owned workstreams plus one
evidence gate. The root `cas-workstation` workstream corrects the manifest,
Promptimprover runtime contract, repository inventory, and doctor validation.
The `gsd-orchestrator` workstream first repairs resumability and then extracts a
finite polling pass with durable deduplication. The current dirty source
checkouts must not be edited directly; execution creates dedicated child
worktrees after plan approval.

No additional orchestration framework or distributed store is needed. Existing
manifest-driven PowerShell, atomic checkpoint files, DI, xUnit, NSubstitute,
Polly, and structured logging are sufficient for this phase.

## Current Workstation Facts

### Root and repository paths

- `stack.manifest.json` still declares `C:\CodingAutopilotSystem` and
  `repos`, while the approved workspace is `C:\PersonalRepo` and `portfolio`.
- `doctor.ps1` already normalizes `USERPROFILE`, `HOME`, and
  `AZURE_CONFIG_DIR` to `C:\Users\KimHarjamaki`; the manifest and generated
  runtime paths must use the same concrete profile.
- `scripts/Cas.Workstation.psm1` derives most paths from the manifest, which is
  the correct reusable pattern. The MCP generator is an exception: it rebuilds
  `Promptimprover\dist\index.js` instead of consuming
  `sharedMcpServer.args`.
- Promptimprover's active implementation is the Universal Refiner package. The
  runtime target is
  `portfolio\Promptimprover\universal-refiner\dist\src\index.js`, not the
  legacy root or standalone MCP-server output.
- The committed full profile omits loop dependencies already present in the
  portfolio: `cas-contracts`, `cas-evals`, `cas-reference-product`, and
  `cas-platform`.

### Test seam

`Cas.Workstation.psm1` already centralizes manifest loading, repository path
construction, runtime generation, and doctor-report construction. Contract
tests should import the module, supply a temporary root/manifest, and assert
machine-readable report values without installing tools or contacting external
services. A self-contained PowerShell test script is safer for the first gate
than assuming Pester is installed; Pester adoption can be a later explicit
tooling decision.

## Current Control-Plane Defects

### Multi-repository watch starvation

`Program.cs` loops through configured repositories and awaits
`RunWatchModeAsync` for each. `RunWatchModeAsync` contains the infinite polling
loop, so the first repository prevents later repositories from starting.

The repair should separate:

1. a finite `PollRepositoryOnceAsync` operation;
2. a coordinator that iterates every configured repository once per interval;
3. an outer delay/cancellation loop.

Phase 1 should keep the per-interval repository pass sequential to preserve
rate-limit behavior and avoid adding concurrency before durable goal budgets
exist. Per-repository errors must be isolated and recorded.

### Volatile or premature deduplication

Watch-mode issue keys are process-local. Restart can replay side effects, and a
failure can be treated as processed. Introduce an `IWatchStateStore` boundary
using the same atomic temp-file/replace and namespacing patterns as
`FileCheckpointStore`. Record success only after the workflow reaches its
successful terminal condition. Failed, cancelled, and retryable items remain
eligible under explicit policy.

SQLite belongs to Phase 3. The Phase 1 store should be migration-friendly but
must not pull the generalized goal event store into stabilization scope.

### Failed-state resume no-op

`GsdStateMachine` saves the pre-state checkpoint, catches failure, transitions
the context to terminal `WorkflowState.Failed`, and saves that terminal context.
`ResumeAsync` loads it, but the execution loop excludes `Failed`, so no failed
step is replayed. Existing resume coverage injects a nonterminal checkpoint and
does not prove failed-step recovery.

The model needs explicit recoverable failure metadata, including the failed
executable state, attempt/retry count, sanitized reason, and evidence. Resume
must re-enter that state while retaining already-completed history. Checkpoint
schema versioning must reject unsupported data rather than silently reinterpret
it.

## Reusable Patterns

- `FileCheckpointStore`: atomic writes, repository/workflow namespacing,
  schema-version checks, and archive behavior.
- `GsdWorkflowContext.History`: durable transition evidence.
- State DI conventions: states receive services and do not call GitHub or HTTP
  clients directly.
- Existing xUnit/NSubstitute suites: deterministic state and checkpoint tests
  with no live provider calls.
- Root manifest/module boundary: one versioned contract drives setup, doctor,
  runtime configuration, and repository paths.

## Recommended Plan Boundaries

### Plan 01-01 - Root workstation contract

Own only the `cas-workstation` worktree. Add failing path/MCP/repository
contract tests, then correct the manifest/module/doctor behavior. Covers
STAB-01 and STAB-02.

### Plan 01-02 - Failed-state recovery

Own only a clean `gsd-orchestrator` child worktree. Add failing recovery and
schema tests, then implement recoverable failed-state metadata and bounded
resume. Covers STAB-04.

### Plan 01-03 - Finite watch and durable deduplication

Continue in the same `gsd-orchestrator` child worktree after 01-02. Extract a
finite poll operation, isolate repository failures, and persist success-only
deduplication. Covers STAB-03.

### Plan 01-04 - Cross-workstream evidence gate

Run the root contract tests, root doctor smoke test, full
`gsd-orchestrator` build/tests, and focused two-repository/recovery tests.
Validate the exact STAB outcomes and record evidence; do not deploy or push.

## Risks and Controls

- **Dirty source checkouts:** never implement in the current root or nested
  checkout. Create dedicated `codex/` child worktrees at execution time.
- **Cross-repository atomicity:** plans 01-01 and 01-02 may run in parallel,
  but 01-03 follows 01-02 in the same child worktree and 01-04 follows both.
- **Checkpoint compatibility:** new failure fields require explicit schema
  migration or backward-compatible defaults plus rejection tests.
- **False green verification:** do not substitute source inspection for actual
  PowerShell contract tests, `dotnet build`, or `dotnet test`.
- **Runtime side effects:** doctor and tests must use temporary directories and
  fakes; they must not alter global MCP client configuration or GitHub state.

## Validation Architecture

### Validation levels

| Level | Purpose | Command/behavior | Expected evidence |
|-------|---------|------------------|-------------------|
| Root fast | Prove manifest/module contract after each root task | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Workstation.Contract.Tests.ps1` | Exit 0; assertions for exact root, profile, repo inventory, and Promptimprover args |
| Root smoke | Prove operator doctor remains machine-readable without applying setup | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\doctor.ps1` with temporary/config-safe inputs where supported | Exit code and report conform to `schemas/doctor.schema.json`; no global config mutation |
| GSD focused | Prove each regression during RED/GREEN work | `dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj --filter "FullyQualifiedName~Resume|FullyQualifiedName~Watch"` | TRX/console evidence for failed-step resume, two-repo polling, and dedupe |
| GSD full | Detect state-machine/checkpoint regressions | `dotnet build src/GsdOrchestrator.sln` then `dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj` | Both exit 0; no skipped mandatory recovery/watch tests |
| Integration | Prove Phase 1 success criteria | Run root fast/smoke gates and GSD full gate from their owning worktrees, then capture exact command, cwd, exit code, duration, and sanitized summary | One evidence bundle linked from phase verification |

### Failure semantics

- Any failing mandatory command blocks plan completion.
- Missing PowerShell, .NET SDK, restored packages, test project, or schema tool
  is `inconclusive`, not `passed`.
- A transient package-restore failure may be retried once after a clean
  `dotnet restore`; deterministic test failures are not retried unchanged.
- Timeouts: 60 seconds for root contract tests, 120 seconds for focused .NET
  tests, and 300 seconds for full build/test unless the plan records a justified
  override.
- Evidence must omit tokens, environment values, prompt content, and full
  external payloads.

## Planning Conclusion

Phase 1 is implementable as four plans across three waves. It must finish with
real cross-workstream evidence before Phase 2 introduces new lifecycle
contracts or scheduling state.
