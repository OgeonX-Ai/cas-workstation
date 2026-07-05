# Cross-tool pilot evidence

Captured 2026-07-05. The milestone commit provides immutable provenance.

## Codex

Fresh `codex exec` used `gpt-5.4-mini`, read-only mode, no approvals, and
`C:\PersonalRepo`. Result:

```json
{"tool":"codex","loaded":true,"canonical_policy_version":"1.0.0"}
```

Thread `019f31b2-3bb7-7383-bf1a-1b81e30517e1` exposed malformed custom-agent
paths under `/mnt/c/codex-home`; all paths were corrected to existing Windows
files and startup was rechecked.

## Claude Code

Normal user settings timed out. A bounded fallback used project-only settings,
empty MCP config, explicit global adapter bootstrap, and plan mode. Session
`86eb400e-bd09-4d2c-8007-70bd5c047e0e` returned the canonical path. Session
`a809835b-979e-4396-aa33-0ede00a2ac8a` completed exploration, diagnosis,
implementation, security, and documentation review. Telemetry reported both
Haiku and Sonnet despite requesting Haiku, so concrete cost savings are not
assumed from the top-level selector.

## Gemini CLI

Gemini CLI 0.47.0 returned `IneligibleTierError`: its individual Code Assist
client is unsupported and directs migration to Antigravity. It is disabled.

## Antigravity

Antigravity 2.1.4 and Antigravity IDE 2.0.4 are installed. No verified CLI,
global instruction path, or child-model override exists. Use repository-local
rules and separate tiered top-level sessions.

## Local controls

- Deterministic fixtures: 5/5 passed.
- Ollama `gemma3:1b`: 0/5, p95 16,953 ms; disabled.
- Engineering JSON examples: 4/4 passed.
- Writer collision fixture: rejected.
- Atomic rollback isolated fixture: 5/5 files.
- Global adapter and policy verifier: passed.
- Paid API key required: no.
