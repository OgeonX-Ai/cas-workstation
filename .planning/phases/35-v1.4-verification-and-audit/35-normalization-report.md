# Normalization Report -- Post-Merge-Train

**Date:** 2026-07-09 06:06:07 UTC
**Org Merge Queue:** Fully drained (verified)

## Summary

- **Total Repos:** 13
- **Repos on Default Branch:** 6/13
- **Branches Deleted:** 5
- **Branches Kept:** 6

---

## Promptimprover

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** master
[WARN] 22 dirty files - NOT staging/committing/discarding

### Already on master
[FAIL] Pull failed: hint: Diverging branches can't be fast-forwarded, you need to either: hint: hint: 	git merge --no-ff hint: hint: or: hint: hint: 	git rebase hint: hint: Disable this message with "git config set advice.diverging false" fatal: Not possible to fast-forward, aborting.

### Leftover Branch Cleanup
[OK] No fully-merged branches to delete

**Final branch:** master
**Dirty files:** 22
[OK] STATUS: ON DEFAULT BRANCH

## autogen

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** feat/phase-26-coverage-gates
[WARN] 38 dirty files - NOT staging/committing/discarding

### Branch Processing: feat/phase-26-coverage-gates
[KEEP] Branch has unique commits (NOT empty diff):
``
 .coveragerc                  |   18 +
 .github/workflows/ci.yml     |  142 +++---
 .gitignore                   |    3 +
 requirements.txt             |   27 +-
 tests/test_maf_setup.py      | 1065 ++++++++++++++++++++++++------------------
 tests/test_phase3_routing.py |  336 ++++++++-----
 6 files changed, 963 insertions(+), 628 deletions(-)
``
[OK] Keeping branch: feat/phase-26-coverage-gates (has unique work)

### Leftover Branch Cleanup
[OK] No fully-merged branches to delete

**Final branch:** feat/phase-26-coverage-gates
**Dirty files:** 38
[WARN] STATUS: ON FEATURE BRANCH

## autopilot-core

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** main
[WARN] 4 dirty files - NOT staging/committing/discarding

### Already on main
[OK] Pulled --ff-only

### Leftover Branch Cleanup
[DELETE] Deleted fully-merged: hardening/enterprise-audit-20260610

**Final branch:** main
**Dirty files:** 4
[OK] STATUS: ON DEFAULT BRANCH

## autopilot-demo

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** main
### Already on main
[OK] Pulled --ff-only

### Leftover Branch Cleanup
[OK] No fully-merged branches to delete

**Final branch:** main
**Dirty files:** 0
[OK] STATUS: ON DEFAULT BRANCH

## cas-contracts

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** feat/phase-27-failure-state
[WARN] 7 dirty files - NOT staging/committing/discarding

### Branch Processing: feat/phase-27-failure-state
[OK] Empty diff - branch is fully merged
[OK] Switched to main
[FAIL] Pull failed: There is no tracking information for the current branch. Please specify which branch you want to merge with. See git-pull(1) for details. System.Management.Automation.RemoteException     git pull <remote> <branch> System.Management.Automation.RemoteException If you wish to set tracking information for this branch you can do so with: System.Management.Automation.RemoteException     git branch --set-upstream-to=origin/<branch> main System.Management.Automation.RemoteException

## cas-evals

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** feat/registry-fetch-smoke-check
### Branch Processing: feat/registry-fetch-smoke-check
[KEEP] Branch has unique commits (NOT empty diff):
``
 .github/workflows/ci.yml                           | 22 +++++
 releases/v0.2.0/manifest.json                      |  2 +-
 src/cas_evals/contracts.py                         |  4 +-
 src/cas_evals/registry_check.py                    | 80 ++++++++++++++++++
 tests/test_registry_check.py                       | 95 ++++++++++++++++++++++
 vendor/cas-contracts/v0.1.0/common.schema.json     |  2 +-
 .../v0.1.0/evaluation-result.schema.json           |  2 +-
 vendor/cas-contracts/v0.1.0/provenance.json        |  4 +-
 8 files changed, 204 insertions(+), 7 deletions(-)
``
[OK] Keeping branch: feat/registry-fetch-smoke-check (has unique work)

### Leftover Branch Cleanup
[OK] No fully-merged branches to delete

**Final branch:** feat/registry-fetch-smoke-check
**Dirty files:** 0
[WARN] STATUS: ON FEATURE BRANCH

## cas-platform

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** fix/bicep-lint-api-version-pinning
[WARN] 6 dirty files - NOT staging/committing/discarding

### Branch Processing: fix/bicep-lint-api-version-pinning
[KEEP] Branch has unique commits (NOT empty diff):
``
 .gitignore       | 1 +
 bicepconfig.json | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)
``
[OK] Keeping branch: fix/bicep-lint-api-version-pinning (has unique work)

### Leftover Branch Cleanup
[OK] No fully-merged branches to delete

**Final branch:** fix/bicep-lint-api-version-pinning
**Dirty files:** 6
[WARN] STATUS: ON FEATURE BRANCH

## cas-reference-product

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** main
[WARN] 2 dirty files - NOT staging/committing/discarding

### Already on main
[FAIL] Pull failed: hint: Diverging branches can't be fast-forwarded, you need to either: hint: hint: 	git merge --no-ff hint: hint: or: hint: hint: 	git rebase hint: hint: Disable this message with "git config set advice.diverging false" fatal: Not possible to fast-forward, aborting.

### Leftover Branch Cleanup
[OK] No fully-merged branches to delete

**Final branch:** main
**Dirty files:** 2
[OK] STATUS: ON DEFAULT BRANCH

## cas-workstation

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** main
[WARN] 4 dirty files - NOT staging/committing/discarding

### Already on main
[FAIL] Pull failed: hint: Diverging branches can't be fast-forwarded, you need to either: hint: hint: 	git merge --no-ff hint: hint: or: hint: hint: 	git rebase hint: hint: Disable this message with "git config set advice.diverging false" fatal: Not possible to fast-forward, aborting.

### Leftover Branch Cleanup
[DELETE] Deleted fully-merged: fix/audit-sweep

**Final branch:** main
**Dirty files:** 4
[OK] STATUS: ON DEFAULT BRANCH

## ci-autopilot

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** main
[WARN] 1 dirty files - NOT staging/committing/discarding

### Already on main
[OK] Pulled --ff-only

### Leftover Branch Cleanup
[DELETE] Deleted fully-merged: docs/portfolio-hardening-20260610

**Final branch:** main
**Dirty files:** 0
[OK] STATUS: ON DEFAULT BRANCH

## cloud-security-service-model

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** fix/bicep-lint-api-version-pinning
### Branch Processing: fix/bicep-lint-api-version-pinning
[KEEP] Branch has unique commits (NOT empty diff):
``
 bicepconfig.json                                   |  2 +-
 docs/adr/001-policy-assignment-enforcement-mode.md | 49 ++++++++++++++++++++++
 .../landing-zone/bicep/modules/identity.bicep      |  2 +-
 .../landing-zone/bicep/modules/logging-siem.bicep  |  2 +-
 .../bicep/modules/network-hubspoke.bicep           |  4 +-
 .../bicep/modules/policy-assignments.bicep         |  2 +-
 6 files changed, 55 insertions(+), 6 deletions(-)
``
[OK] Keeping branch: fix/bicep-lint-api-version-pinning (has unique work)

### Leftover Branch Cleanup
[OK] No fully-merged branches to delete

**Final branch:** fix/bicep-lint-api-version-pinning
**Dirty files:** 0
[WARN] STATUS: ON FEATURE BRANCH

## gsd-orchestrator

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** feat/phase-26-coverage-gates
[WARN] 6 dirty files - NOT staging/committing/discarding

### Branch Processing: feat/phase-26-coverage-gates
[KEEP] Branch has unique commits (NOT empty diff):
``
 .github/workflows/ci.yml                           |  31 ++-
 .gitignore                                         |   3 +
 coverlet.runsettings                               |  21 ++
 .../CoverageGapClosingTests.cs                     | 275 +++++++++++++++++++++
 .../Checkpointing/FileCheckpointStore.cs           |   6 +-
 5 files changed, 334 insertions(+), 2 deletions(-)
``
[OK] Keeping branch: feat/phase-26-coverage-gates (has unique work)

### Leftover Branch Cleanup
[DELETE] Deleted fully-merged: ci/dependabot-github-actions

**Final branch:** feat/phase-26-coverage-gates
**Dirty files:** 6
[WARN] STATUS: ON FEATURE BRANCH

## org-dotgithub

### Fetch & Prune
[OK] Fetch successful

**Current branch before:** docs/phase-36-refresh
[WARN] 2 dirty files - NOT staging/committing/discarding

### Branch Processing: docs/phase-36-refresh
[KEEP] Branch has unique commits (NOT empty diff):
``
 profile/README.md | 213 +++++++++++++++++-------------------------------------
 profile/VISION.md | 133 ++++++++++++++++++++++++++++++++++
 2 files changed, 199 insertions(+), 147 deletions(-)
``
[OK] Keeping branch: docs/phase-36-refresh (has unique work)

### Leftover Branch Cleanup
[DELETE] Deleted fully-merged: enterprise-governance

**Final branch:** docs/phase-36-refresh
**Dirty files:** 2
[WARN] STATUS: ON FEATURE BRANCH


---

## Completion Status

**NORMALIZATION COMPLETE**
- All 13 repos processed
- Repos on default: 6/13
- Branches deleted: 5
- Branches kept: 6
