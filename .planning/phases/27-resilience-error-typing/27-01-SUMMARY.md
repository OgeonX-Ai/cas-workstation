# Phase 27-01 Summary

## Outcome

Published the shared `FailureState` contract in `cas-contracts` so `gsd-orchestrator` and `autogen` can converge on the same typed failure-state field names.

## Delivered

- Added `portfolio/cas-contracts/schemas/v1.1/failure-state.schema.json`
- Added `failureClass` to `portfolio/cas-contracts/schemas/v1.1/common.schema.json`
- Added `portfolio/cas-contracts/examples/v1.1/failure-state.json`
- Added AJV tests for the valid example and the missing-`failureClass` negative case
- Added additive-versioning notes in:
  - `portfolio/cas-contracts/docs/VERSIONING.md`
  - `portfolio/cas-contracts/CHANGELOG.md`
- Updated the v1.1 registry-count assertion in `tests/registry.test.mjs` from `6` to `7`

## Verification Evidence

- `npm test` in `portfolio/cas-contracts`
  - `38` tests passed
  - includes:
    - published example validation
    - `FailureState` valid example test
    - `FailureState` missing-`failureClass` rejection test
    - registry all-mode publication test

## Important Deviation

The `27-01` plan text assumed the v1.1 line had already moved to the GitHub Pages registry base for authoritative schema IDs. The live `cas-contracts` repo does not match that assumption yet:

- existing v1.1 schemas still use `https://schemas.coding-autopilot.dev/...`
- `scripts/lib.mjs` and the validator/test harness still resolve schema IDs through that canonical base

To keep `27-01` aligned with the current repository contract line instead of silently performing a broader registry migration, `failure-state.schema.json` was authored with the same canonical host the repo already uses. The future host migration remains separate work.

## Output Contract

Wave-2 consumers can now target these exact fields:

- `failureClass`
- `component`
- `message`
- `retryable`
- `exceptionType`
- `causeChain`
- `retryAfterSeconds`
- `evidence`
