# Phase 24 Context: Tooling & Fallback Routing

**Goal:** Integrate automatic tool provisioning and paid API-based routing (Requirements: DX-01, DX-02).

## Current Implementations
1. **Model Routing:** Handled primarily in `C:\PersonalRepo\scripts\classify-engineering-task.ps1`, which reads `C:\PersonalRepo\engineering-os\router\ollama-policy.json`. Currently, it tries a local Ollama model and falls back to deterministic regex rules.
2. **Tool Provisioning:** Orchestrated by `C:\PersonalRepo\setup.ps1` using functions (`Install-CasTool`, `Get-CasProfileToolDefinitions`) defined in `C:\PersonalRepo\scripts\Cas.Workstation.psm1`.

## Implementation Decisions

### 1. Paid API Fallback Routing (DX-02)
- Modify `scripts\classify-engineering-task.ps1` to insert a paid API fallback step between the local Ollama attempt and the final regex fallback.
- Create or update a policy file (e.g., `engineering-os\router\paid-policy.json` or extend `ollama-policy.json`) to store enablement flags and candidate models for paid APIs.
- The router should execute an `Invoke-RestMethod` to the designated paid API endpoint if Ollama fails or is disabled, provided the paid policy is enabled.

### 2. Automatic Tool Provisioning (DX-01)
- Extend `scripts\Cas.Workstation.psm1` (specifically `Install-CasTool` or by adding an `Ensure-CasTool` function) to automatically detect and provision missing MCP servers and tools dynamically.
- Update runtime bootstrapping logic to call this auto-provisioning step seamlessly without requiring manual user execution of `setup.ps1`.

## Constraints
- **Fallback safety:** Paid API routing must degrade gracefully to regex if keys are missing or requests fail.
- **Idempotency:** Automatic provisioning must be strictly idempotent and not slow down the boot process unnecessarily.
