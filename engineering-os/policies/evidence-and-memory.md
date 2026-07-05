# Evidence, Context, Memory, and Telemetry

## Storage classes

- Active checkpoint: mutable resumable state for current work; never completion evidence alone.
- Immutable artifact: commit, release, test report, signed manifest, or captured live run.
- Durable memory: reviewed reusable lesson written only after verification and explicit user authorization.
- Telemetry: operational measurements; useful for routing, never a substitute for acceptance.

Pass compact task packets and paths instead of transcripts. A child returns
conclusion, confidence, changed files, verification, unresolved risk, and artifact
references. Verify before promoting any claim to durable memory.

Record tool, parent/child role, model alias, concrete model when observable,
elapsed time, retries, context estimate, verifier result, rework, routing
confidence, and fallback reason. Optimize for subscription capacity, latency,
quality, and rework—not API token price.
