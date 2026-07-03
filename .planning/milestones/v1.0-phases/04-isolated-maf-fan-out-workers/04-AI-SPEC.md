---
phase: 04-isolated-maf-fan-out-workers
system_type: multi-agent task worker
framework: Microsoft Agent Framework 1.0.0rc5
alternative: custom asyncio-only orchestration rejected
---

# Phase 4 AI Design Contract

## 1. System and domain context

Task-attempt workers execute one control-plane lease. Good behavior is bounded concurrent read-only specialist analysis, typed terminal fan-in, and exactly one mutation owner in an isolated worktree. Bad behavior is competing writers, incomplete fan-in, unbounded agents, path escape, or side effects before approval. Stakes include repository corruption, duplicate external actions, secret disclosure, and false completion.

## 2. Framework selection

Microsoft Agent Framework is required because the repository already runs it and `WorkflowBuilder` exposes native `add_fan_out_edges` and `add_fan_in_edges`. The control plane remains in `gsd-orchestrator`; MAF owns only one leased attempt. A custom scheduler or AutoGen legacy path is prohibited.

## 3. Entry pattern

```python
workflow = (
    WorkflowBuilder(start_executor=dispatcher, max_iterations=bounded_iterations)
    .add_fan_out_edges(dispatcher, read_only_specialists)
    .add_fan_in_edges(read_only_specialists, typed_aggregator)
    .build()
)
```

The runtime also exposes a provider-independent async harness for deterministic overlap, timeout, cancellation, and fan-in tests.

## 4. Implementation guidance

- Specialists receive immutable request context and read-only capabilities.
- A semaphore enforces `max_fan_out`; every task has a deadline and cancellation path.
- Aggregation requires one terminal typed result per required role and rejects duplicates/missing results.
- Repository mutation is outside specialist functions and occurs only through one implementation-owner sandbox contract.
- Mutating worktrees use deterministic goal/work IDs, base SHA, allowlisted paths, idempotency key, artifact manifest, and cleanup state.

### 4b. Typed boundary example

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class SpecialistResult:
    role: str
    status: str
    summary: str
    artifacts: tuple[str, ...]
```

Dataclasses are used because the active runtime already uses typed dataclass boundaries; transport adapters may map them to Pydantic later.

## 5. Evaluation dimensions

| Dimension | Automated evidence |
|---|---|
| Concurrency bound | observed peak equals three and never exceeds configured limit |
| Fan-in completeness | aggregator waits for every required terminal result |
| Read-only roles | specialist capability set has no mutation operation |
| Isolation | real git test creates distinct worktree and preserves default branch SHA |
| Approval | push, deploy, delete, message, and production mutation are denied before approval |

## 6. Guardrails

- Online deterministic guardrails: path containment, owner uniqueness, deadline, idempotency, approval class, default-branch SHA.
- No model judgment can grant write or external-action authority.
- Timeouts and missing specialist results are failures, never partial success.

## 7. Evaluation and tracing

Code-based tests are authoritative. Emit role, work-item ID, elapsed time, terminal status, and trace context; never log prompts, tokens, or secrets. Arize Phoenix is the future tracing visualization default, but no new telemetry dependency is introduced until Phase 6.

## Checklist

- [x] Framework and ownership selected
- [x] Typed fan-out/fan-in boundary defined
- [x] Isolation and approval guardrails defined
- [x] Deterministic evaluation matrix defined
