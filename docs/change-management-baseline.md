# Change Management Baseline

This baseline defines the minimum evidence expected for portfolio change
control, branch governance, and rollback-readiness.

## Current evidence

- Machine-readable ledger: `evidence/compliance/change-management.csv`
- Emergency change review ledger: `evidence/compliance/emergency-change-log.csv`
- Snapshot generator: `scripts/capture-change-management-evidence.py`
- Emergency review generator: `scripts/capture-emergency-change-evidence.py`
- Live provenance and release evidence: `.github/workflows/compliance.yml`
- Rollback-aware release guidance: `portfolio/org-dotgithub/docs/RELEASE_POLICY.md`

## What this currently proves

- Each managed repository has a captured default-branch governance snapshot
- Branch protection state is recorded with review date and core settings
- The managed repository set now meets the minimum baseline of protected default branches, one required approval, and admin enforcement
- A fleet-wide emergency review window now records whether any merged PRs were
  explicitly labeled `emergency-change`
- The root compliance workflow now produces an attested evidence bundle for
  repeatable review
- Change-management capture fails on branch-protection API errors instead of
  silently serializing them as unprotected state
- When the GitHub workflow token cannot read protection detail endpoints, the
  ledger records `result=limited` and preserves only the public branch
  `protected` state rather than fabricating full settings

## What this does not yet prove

- Formal CAB-style approval records outside GitHub PR and label history
- Runtime deployment approval trails outside repository automation
- That every team would consistently label an emergency PR correctly without
  additional workflow enforcement
