---
phase: 02-typed-goal-and-lifecycle-contract
status: complete
---

# Phase 2 Research

- The repository uses JSON Schema Draft 2020-12 with AJV and executable examples.
- `common.schema.json` already centralizes strict lifecycle metadata and W3C trace context for v0.1.
- `docs/VERSIONING.md` classifies adding required properties as a major-version change; v0.1 payloads must remain valid.
- Validation helpers currently hard-code v0.1 directories and schema IDs, so parallel-version discovery must replace those constants without weakening strict validation.
- The safest design is a complete v1.0 lifecycle schema/example set using a v1 common definition, plus negative goal-contract tests and cross-record trace tests.
