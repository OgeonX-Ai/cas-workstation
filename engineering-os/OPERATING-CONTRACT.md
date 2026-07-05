# Canonical AI Engineering Operating Contract

**Authority:** `C:\PersonalRepo\engineering-os`  
**Version:** 1.0.0  
**Applies to:** Codex, Claude Code, Gemini CLI, Antigravity, and delegated agents

## Precedence and bootstrap

1. Direct user instruction.
2. Safety, security, identity, and platform policy.
3. Nearest repository `context.md`/`CONTEXT.md`, then parent context files.
4. Repository `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`.
5. This canonical contract.
6. Tool adapter defaults.

Before repository work, discover the context chain and current Git state. Load
only enough context to make the next action decision-complete.

## Lifecycle

Use GSD for durable goals, requirements, roadmaps, phase plans, execution state,
verification, UAT, audit, and retrospective. Apply one SDLC profile from
`policies/sdlc-profiles.json` inside every task or phase.

- Tiny deterministic work: GSD fast/quick plus the quick profile.
- Defects: reproduce first, then GSD debug and the risk-appropriate profile.
- Substantial work: requirements → roadmap → spec/discuss → plan → execute →
  verify → UAT → audit.
- AI, UI, security, or critical infrastructure work: invoke the corresponding
  specialist GSD contracts and required critical gates.

A failed verifier invalidates completion and returns work to the earliest stage
whose output could have caused the failure. Model confidence is never evidence.

## Autonomous continuation

Within approved scope, continue through safe implementation, verification,
review, documentation, and atomic commits without repeated “continue” prompts.
Stop only for a material scope expansion, missing authority, destructive action,
unavailable external prerequisite, or a decision whose alternatives materially
change the result. Tool failure or Ollama absence must use deterministic fallback.

## Delegation

Delegation is standing-authorized when it materially improves latency,
specialization, or context isolation. The parent retains goal ownership,
decomposition, synthesis, conflict resolution, verification, and completion.

- Prefer parallel, read-heavy, independent work.
- Writers require isolated Git worktrees or explicit disjoint file ownership.
- Never allow uncontrolled recursive delegation. A child may not fan out unless
  the tool supports it and the task packet explicitly grants a bounded depth.
- Every child receives the same precedence rules, relevant context paths,
  write scope, verifier, and completion criteria.
- Return conclusions and artifact references, not raw logs or full transcripts.

## Model role aliases

Canonical roles are `light`, `standard`, `strong`, and `adjudicator`; concrete
models are tool-specific in `models/`. Use the lowest role likely to succeed.

- `light`: discovery, extraction, file reading, routine research, logs, and
  deterministic test execution.
- `standard`: bounded implementation and ordinary review.
- `strong`: architecture, ambiguous debugging, security-sensitive reasoning,
  and synthesis.
- `adjudicator`: conflict resolution and final acceptance for critical work.

Unsupported per-child model selection must not be claimed. Use separate
top-level sessions when required by the compatibility matrix.

## Collision and evidence rules

One mutation owner per file scope. Before concurrent writes, record worktree,
branch, owned paths, and integration owner. Completion requires direct evidence:
tests, static analysis, runtime behavior, logs, live probes, or explicit UAT.

Keep active checkpoints, immutable artifacts, reviewed durable memory, and
telemetry separate as defined in `policies/evidence-and-memory.md`. Durable
memory writes require verified, reusable learning and explicit user authority.

## Escalation and overrides

An SDLC override must validate against `schemas/sdlc-override.schema.json` and
record reason, owner, skipped gate, risk, and compensating verification. Never
override safety, identity, secret handling, required critical acceptance, or a
failed terminal verifier.

Escalate model role when confidence is low, requirements conflict, risk rises,
retries repeat, or verification contradicts the plan. Escalation changes
reasoning capacity, not completion authority.

## Security invariants

Never embed secrets or tokens. Prefer managed identity and minimum RBAC for
Azure. Use Foundry Next Gen `WorkflowAgentService`, not Classic Assistants.
Production MCP uses authenticated remote transport; local stdio is development
only. Azure Functions default to Flex Consumption Linux unless the repository
requires otherwise.
