# Document Synthesis Summary

## Inputs

- Documents synthesized: 5
- ADR: 1
- SPEC: 1
- PRD: 1
- DOC: 2
- Precedence applied: numeric overrides `ADR (0) > SPEC (1) > PRD (2) > DOC (3)`
- Cross-reference graph: acyclic; the only classified edge is `README.md -> docs/support-matrix.md`

## Outputs

- Locked decisions: 1
  - `/mnt/c/PersonalRepo/worktrees/loop-engineering/docs/adr/ADR-0001-loop-engineering-ownership.md`
- Requirements: 28
  - `REQ-STAB-01` through `REQ-STAB-04`
  - `REQ-GOAL-01` through `REQ-GOAL-03`
  - `REQ-SCHED-01` through `REQ-SCHED-05`
  - `REQ-WORK-01` through `REQ-WORK-04`
  - `REQ-VER-01` through `REQ-VER-04`
  - `REQ-OPS-01` through `REQ-OPS-02`
  - `REQ-CLOUD-01` through `REQ-CLOUD-02`
  - `REQ-PILOT-01` through `REQ-PILOT-04`
- Constraints: 12
  - api-contract: 1
  - schema: 3
  - nfr: 4
  - protocol: 4
- Context topics: 8

## Conflict Result

- Blockers: 0
- Competing variants: 0
- Auto-resolved conflicts: 0

No low-confidence `UNKNOWN` classifications, reference cycles, locked-decision contradictions, divergent PRD acceptance variants, or cross-precedence contradictions were detected.

## Downstream Entry Points

- Decisions: `/mnt/c/PersonalRepo/worktrees/loop-engineering/.planning/intel/decisions.md`
- Requirements: `/mnt/c/PersonalRepo/worktrees/loop-engineering/.planning/intel/requirements.md`
- Constraints: `/mnt/c/PersonalRepo/worktrees/loop-engineering/.planning/intel/constraints.md`
- Context: `/mnt/c/PersonalRepo/worktrees/loop-engineering/.planning/intel/context.md`
- Conflict report: `/mnt/c/PersonalRepo/worktrees/loop-engineering/.planning/INGEST-CONFLICTS.md`

