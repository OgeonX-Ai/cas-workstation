# Shared AI Engineering OS

This directory is the authoritative, version-controlled operating contract for
AI-assisted engineering on this workstation. Tool-global files are adapters;
they must reference this directory rather than duplicate its policy.

Start with [OPERATING-CONTRACT.md](OPERATING-CONTRACT.md). Run
`powershell -NoProfile -File scripts/verify-engineering-os.ps1` after changes.
Use `scripts/classify-engineering-task.ps1` for deterministic routing and
`scripts/test-engineering-router.ps1` for its fixture gate.

No workflow in this directory requires a paid API key. Authenticated desktop or
CLI subscriptions may be used. Ollama is optional classification support only.
