# Phase 1: Stable Workstation and Recovery - Context

**Gathered:** 2026-06-30
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the existing workstation contract, multi-repository polling, persistent
deduplication, and failed-step recovery truthful and regression-protected.
This phase does not introduce the generalized goal scheduler, SQLite goal event
store, MAF fan-out, verifier repair loop, operator UI, or Azure hosting planned
in later phases.

</domain>

<decisions>
## Implementation Decisions

### Workstation source of truth

- **D-01:** `stack.manifest.json` remains the authoritative workstation contract. Its defaults must use `C:\PersonalRepo`, the `portfolio` repository root, and `C:\Users\KimHarjamaki` for the concrete profile/config path.
- **D-02:** Runtime MCP configuration must derive the Promptimprover entry point from `sharedMcpServer.args`; `Cas.Workstation.psm1` must not reconstruct a divergent hard-coded `Promptimprover\dist\index.js` path.
- **D-03:** The full workstation profile and doctor report must include all components needed by the accepted loop architecture, including `cas-contracts`, `cas-evals`, `cas-reference-product`, and `cas-platform` in addition to the existing control-plane and worker repositories.

### Multi-repository watch behavior

- **D-04:** One polling interval performs a finite pass over every configured repository. Phase 1 keeps repository polling sequential and failure-isolated; goal-level concurrency belongs to Phase 3.
- **D-05:** A failure in one repository is recorded and does not prevent later configured repositories from being polled during the same interval.
- **D-06:** Deduplication is represented behind a dedicated interface and persisted using the existing atomic file/checkpoint pattern. Failed or cancelled items are not marked successfully processed. Migration to the Phase 3 goal event store remains possible without changing watch semantics.

### Failed-step recovery

- **D-07:** The last executable state and its attempt/failure metadata must remain recoverable independently of the terminal outcome reported to operators.
- **D-08:** `ResumeAsync` re-enters the failed executable state with prior evidence and a bounded retry count. It never treats a terminal `Failed` marker as a successful no-op resume.
- **D-09:** Checkpoint schema evolution is explicit and backward-compatible or fails with a clear unsupported-version error; silent reinterpretation is prohibited.

### Test-first verification

- **D-10:** Each known defect begins with a focused failing regression test: exact workstation/MCP paths, two-repository polling, restart-safe deduplication, and failed-state resume.
- **D-11:** Root workstation tests and `gsd-orchestrator` xUnit tests are separate plan boundaries with separate repository worktrees. A later integration plan validates the combined operator path.
- **D-12:** Phase completion requires real manifest/doctor checks and real `dotnet test`; string/attribute heuristics cannot substitute for compilation or tests.

### the agent's Discretion

- Exact names and serialization shape for the Phase 1 watch-state interface, provided it uses atomic writes and remains migration-friendly.
- Exact test fixture/helper names and structured log event names.
- Whether the finite repository pass is extracted from `Program.cs` into one or two injected services, provided CLI behavior remains backward-compatible and testable.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Architecture and requirements

- `docs/adr/ADR-0001-loop-engineering-ownership.md` - Locked component ownership and prohibition on an additional v1 scheduler.
- `docs/specs/SPEC-loop-engineering.md` - Runtime topology, state, retry, isolation, verification, security, and test-first defect constraints.
- `docs/prd/PRD-loop-engineering.md` - Product requirements and acceptance criteria.
- `.planning/REQUIREMENTS.md` - Canonical Phase 1 requirement IDs STAB-01 through STAB-04.
- `.planning/ROADMAP.md` - Fixed Phase 1 boundary and observable success criteria.

### Workstation implementation

- `stack.manifest.json` - Current committed workstation paths, repository inventory, and shared MCP contract.
- `scripts/Cas.Workstation.psm1` - Manifest loading, repo setup, doctor report, MCP generation, and runtime startup.
- `doctor.ps1` - Concrete Windows profile normalization and doctor entry point.
- `schemas/doctor.schema.json` - Machine-readable health report contract.

### Control-plane implementation

- `portfolio/gsd-orchestrator/src/GsdOrchestrator/Program.cs` - Current watch loop and multi-repository dispatch.
- `portfolio/gsd-orchestrator/src/GsdOrchestrator/Workflows/GsdStateMachine.cs` - Checkpoint, failure transition, finalization, and resume loop.
- `portfolio/gsd-orchestrator/src/GsdOrchestrator/Workflows/Models/WorkflowModels.cs` - Workflow state, retry count, history, and repository configuration records.
- `portfolio/gsd-orchestrator/src/GsdOrchestrator/Checkpointing/FileCheckpointStore.cs` - Atomic checkpoint and schema-version patterns.
- `portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests/GsdStateMachineTests.cs` - Current resume test coverage.
- `portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests/MultiRepoConfigTests.cs` - Current multi-repository/checkpoint test coverage.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- `scripts/Cas.Workstation.psm1`: already centralizes manifest-driven setup, runtime configuration, and doctor output; fix drift here instead of creating a second bootstrap path.
- `FileCheckpointStore`: already performs atomic temp-file replacement and schema checks; reuse its boundary patterns for persisted watch state.
- `GsdStateMachine` transition history: retains from/to state and timestamps and can carry recoverable failure metadata.
- xUnit/NSubstitute test suites: provide existing patterns for state-machine, checkpoint, and multi-repository regression tests.

### Established Patterns

- Root behavior is manifest-driven and PowerShell-first.
- State classes use dependency injection and services rather than direct external API calls.
- Checkpoints are namespaced by repository/workflow and written atomically.
- Tests use substitutes rather than live GitHub or model calls.

### Integration Points

- `Get-CasRootPath`, repository initialization, MCP generation, and doctor report construction in `Cas.Workstation.psm1`.
- Watch-mode dispatch in `Program.cs` around the configured repository loop.
- Failure catch/final checkpoint behavior and `ResumeAsync` in `GsdStateMachine.cs`.
- `IWorkflowCheckpointStore`/`FileCheckpointStore` for durable recovery and the new watch-state boundary.

</code_context>

<specifics>
## Specific Ideas

- Preserve the familiar `cas.ps1 setup|doctor|start` operator surface while making its generated paths exact.
- The Phase 1 recovery tests should terminate or inject failure at a deterministic state and prove the same state is re-entered once without replaying prior completed states.
- The multi-repository test should configure at least two repositories and prove both are visited even when the first fails.

</specifics>

<deferred>
## Deferred Ideas

- SQLite WAL goal event stream, leases, and atomic global/provider/repository budgets - Phase 3.
- MAF specialist fan-out/fan-in and isolated mutating work items - Phase 4.
- Repository-native verifier profiles and bounded repair - Phase 5.
- Operator dashboard changes, Foundry managed identity, and Flex Consumption ingress - Phase 6.

</deferred>

---

*Phase: 01-stable-workstation-and-recovery*
*Context gathered: 2026-06-30*

