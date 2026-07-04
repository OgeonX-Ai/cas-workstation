# Phase 9: Systemic CI and Security Hardening - Context

**Gathered:** 2026-07-04
**Status:** Ready for planning
**Mode:** Approved milestone plan

## Phase Boundary

Verify and close CI-01 through CI-03 across active portfolio workflows. Preserve
existing feature-branch commits and change only evidence-backed gaps.

## Locked Decisions

- Use least-privilege workflow and job permissions.
- Add proportionate job timeouts.
- Pin third-party actions or prove Dependabot manages the update path.
- Correct CodeQL languages only where repository content supports scanning.
- Validate each repository with its native workflow/static checks.

## Constraints

- Repositories are independent Git histories; commits remain atomic per repo.
- Do not rewrite or discard existing feature branches.
- No paid APIs, deployment, or unrelated refactoring.
