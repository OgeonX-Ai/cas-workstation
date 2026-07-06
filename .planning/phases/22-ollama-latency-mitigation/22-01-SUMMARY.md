# Phase 22 Summary: Ollama Latency Mitigation

## Objective
Implement asynchronous API interactions and keep-alive caching for Ollama local models to reduce router latency, addressing PERF-01 and PERF-02.

## Work Completed
1. **API Integration over CLI**: 
   - Refactored `classify-engineering-task.ps1` and `benchmark-ollama-router.ps1` to use the Ollama REST API (`Invoke-RestMethod`) instead of spawning CLI processes.
   - Integrated Ollama's native `format` parameter via JSON Schema to forcefully constrain the model to output accurate keys (`taskClass`, `risk`, `sdlcProfile`, `roleAlias`).
2. **Model Caching**:
   - Added `keep_alive = "5m"` to all API payloads to keep the model loaded in VRAM between requests, drastically reducing subsequent inference time.
3. **Benchmark Refactoring**:
   - Switched benchmark requests to execute sequentially through `RunspacePool` to avoid local queue latency starvation, providing an accurate measure of model throughput.
4. **Verification**:
   - Executed the benchmark suite. Latency dropped significantly from ~10+ seconds to ~3.4 seconds p95.
   - However, the current target model (`gemma3:1b`) on local hardware still exceeded the required 2.5s p95 threshold and failed the >90% accuracy threshold even with JSON Schema guidance (the values generated inside the keys were hallucinated).
   - As dictated by the security contract, the `ollama-policy.json` remains `enabled: false`, ensuring the deterministic fallback rules continue to protect the workspace routing.

## Conclusion
The infrastructure for latency mitigation (REST API + caching + schema) is successfully implemented. The bottleneck is now purely hardware/model size constraints. The system remains secure and performant by correctly utilizing the deterministic fallback path.
