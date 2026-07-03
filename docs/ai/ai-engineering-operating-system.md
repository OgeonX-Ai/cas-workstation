# AI Engineering Operating System v3.0

This workspace follows a deterministic, verifier-led SDLC operating system.

Core rules:

- load context before implementation
- plan before editing
- work in small reversible increments
- verify before declaring success
- preserve user changes
- escalate before risky actions
- update docs and memory when behavior changes

State machine:

`BOOTSTRAP -> UNDERSTAND -> DISCOVER -> ANALYZE -> PLAN -> DESIGN -> RISK REVIEW -> IMPLEMENT -> SELF REVIEW -> VERIFY -> SECURITY REVIEW -> PERFORMANCE REVIEW -> DOCUMENT -> INTEGRATE -> UPDATE MEMORY -> RETROSPECTIVE -> DONE`

If a verifier fails, return to the earliest affected state and fix the smallest safe unit.

