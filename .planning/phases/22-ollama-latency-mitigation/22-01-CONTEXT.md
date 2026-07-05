# Phase 22 Context: Ollama Latency Mitigation

## Overview
Phase 22 aims to resolve Ollama latency bottlenecks with caching and async optimizations, addressing PERF-01 and PERF-02. This will allow the system to use Ollama for local routing/classification without exceeding the required latency thresholds (e.g., 2.5s p95).

## Current State & Discovery
Based on the codebase analysis:
- Ollama is primarily targeted for the engineering-os router (`C:\PersonalRepo\scripts\classify-engineering-task.ps1`).
- The benchmark script (`C:\PersonalRepo\scripts\benchmark-ollama-router.ps1`) currently tests Ollama using synchronous CLI invocations (`& ollama run $Model $prompt`). This CLI approach is the primary bottleneck because it does not keep the model cached in memory effectively across calls and is strictly synchronous.
- The policy enforcement in `C:\PersonalRepo\scripts\verify-engineering-os.ps1` ensures Ollama remains disabled until it meets the p95 latency threshold of 2.5s.

## Implementation Decisions (Auto-Selected)

1. **API Integration over CLI**: 
   - Shift from using `& ollama run` CLI commands to the Ollama REST API (`http://localhost:11434/api/generate`).
   - The REST API avoids the overhead of spawning new CLI processes for every request.

2. **Model Caching (Keep-Alive)**:
   - Implement the `keep_alive` parameter in REST API requests (e.g., `"keep_alive": "5m"`).
   - This ensures the model stays loaded in memory (VRAM/RAM) across multiple classification requests, significantly reducing latency after the cold start.

3. **Asynchronous Processing**:
   - For `benchmark-ollama-router.ps1`, implement concurrent HTTP requests using `Start-ThreadJob` or runspaces so that multiple fixtures can be evaluated simultaneously, reducing total benchmark duration.
   - For `classify-engineering-task.ps1`, ensure that any network calls to the Ollama API are made asynchronously where applicable, or at least leverage the fast HTTP interface instead of blocking on the CLI.

4. **Deterministic Fallback Maintenance**:
   - The deterministic regex-based rules currently in `classify-engineering-task.ps1` must remain fully intact.
   - If the Ollama API times out or fails, the system must instantly fall back to these deterministic rules.

## Downstream Guidance for Implementation Agent
The Implementation Agent should:
- Refactor `benchmark-ollama-router.ps1` to use `Invoke-RestMethod` against the Ollama API and include `keep_alive`.
- Integrate the optimized Ollama API call into `classify-engineering-task.ps1`, gated behind the `ollama-policy.json` enabled flag.
- Validate that `verify-engineering-os.ps1` passes and latency is reduced to meet the `< 2.5s` p95 threshold.
