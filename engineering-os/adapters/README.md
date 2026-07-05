# Tool adapters and rollback

Global adapter files contain only bootstrap and precedence text. Before rollout,
their prior contents are copied into this directory under `backups/`. Rollback
means restoring the matching backup and rerunning the verifier.

- Codex primary: `C:\codex-home\AGENTS.md`
- Codex legacy profile: `C:\Users\KimHarjamaki\.codex\AGENTS.md`
- Claude: `C:\Users\KimHarjamaki\.claude\CLAUDE.md`
- Gemini: `C:\Users\KimHarjamaki\.gemini\gemini.md`
- Antigravity: no verified global instruction path; use repository instructions
  and separate tiered top-level sessions until a live capability probe succeeds.
