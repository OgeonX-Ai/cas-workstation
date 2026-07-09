# Control Crosswalk

This crosswalk turns the high-level control matrix into a machine-readable
mapping between control objectives, evidence, owners, and retention rules.

Primary source: `evidence/compliance/control-crosswalk.csv`

## How to use it

- Start with a framework pressure area such as SSDF, SLSA, DORA, ISO 27001, or
  NIS2
- Locate the mapped portfolio control family
- Verify the named evidence source exists and is current
- Check the named owner and retention expectation before claiming readiness

## Honest state

The crosswalk materially improves audit traceability, but most controls remain
at `Partial` because the portfolio still lacks full fleet-wide enforcement and
operational history for every control objective.
