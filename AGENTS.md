# CAS Workstation — PersonalRepo

This is the root workspace for the **Coding-Autopilot-System (CAS)** portfolio and workstation bundle. It is a Windows-first, AI-native development environment managed under `C:\PersonalRepo`.

Please load and follow C:\PersonalRepo\GLOBAL_AGENTS.md for all global rules, workspace layouts, and AI operating mechanics.

## Context Chain

Each sub-project has its own `AGENTS.md` (or `context.md`). Always read the nearest context file before making changes in a directory. Walk up to this root file for workspace-level rules.

**Cascading Context & Inheritance Protocol:**
All sub-projects automatically inherit the global rules defined in `C:\PersonalRepo\engineering-os\OPERATING-CONTRACT.md`. Global Elite Personas and Immutable Coding Standards *strictly override* any conflicting local rules found in sub-project `AGENTS.md` or `context.md` files. Orchestrators must dynamically compile context ensuring the Elite Persona remains unpolluted.

| Project | Context file |
|---|---|
| gsd-orchestrator | `portfolio/gsd-orchestrator/AGENTS.md` |
| Promptimprover | `portfolio/Promptimprover/AGENTS.md` → `context.md` tree |
| autogen | `portfolio/autogen/AGENTS.md` |
| cas-reference-product | `portfolio/cas-reference-product/AGENTS.md` |
| gemini-nano | `gemini-nano/AGENTS.md` |
