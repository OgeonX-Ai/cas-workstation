# MERGE QUEUE — Round 3 (2026-07-08)

**Status:** 39 open PRs | 33 GREEN (mergeable) | 6 RED (do not merge until fixed)

> Last queued: 2026-07-08 by GSD merge-queue rebuild. Copy any group commands to execute sequentially.
> **IMPORTANT:** After Group 3 (phase-31), run `gh pr update-branch` on same-repo CI workflow PRs before proceeding.

---

## GROUP 1 — Rescue/Fix PRs (8 total | 7 GREEN, 1 RED)

High-priority fixes and corrections. Merge in this order.

### Merge Commands — Group 1

```bash
# Promptimprover#27: Dashboard security fix
gh pr merge 27 --repo Coding-Autopilot-System/Promptimprover --squash --delete-branch --admin

# autogen#16: Framework compatibility restore
gh pr merge 16 --repo Coding-Autopilot-System/autogen --squash --delete-branch --admin

# cas-platform#11: Bicep API version pinning
gh pr merge 11 --repo Coding-Autopilot-System/cas-platform --squash --delete-branch --admin

# cas-reference-product#11: Azure Flex Consumption migration
gh pr merge 11 --repo Coding-Autopilot-System/cas-reference-product --squash --delete-branch --admin

# cas-workstation#18: Tree digest fix
gh pr merge 18 --repo Coding-Autopilot-System/cas-workstation --squash --delete-branch --admin

# cloud-security-service-model#13: Bicep DoNotEnforce ADR + API versions (Phase 33 P2/P4)
gh pr merge 13 --repo Coding-Autopilot-System/cloud-security-service-model --squash --delete-branch --admin

# gsd-orchestrator#17: Checkpoint corruption fix
gh pr merge 17 --repo Coding-Autopilot-System/gsd-orchestrator --squash --delete-branch --admin
```

### DO NOT MERGE (RED)

- **cas-contracts#18** — fix: rewrite schema $id to resolvable Pages registry URL
  - **Failing check:** Classify schema compatibility
  - **Reason:** Schema compatibility validation failed; needs manual review before merge

---

## GROUP 2 — Phase 26/28/29 Feature Development (5 total | 2 GREEN, 3 RED)

Feature PRs for deterministic coverage gates, fault injection, and peer critic patterns.

### Merge Commands — Group 2

```bash
# autogen#11: Coverage gate ratchet (Phase 26)
gh pr merge 11 --repo Coding-Autopilot-System/autogen --squash --delete-branch --admin

# gsd-orchestrator#16: coverage gate ratchet (Phase 26) — re-verified GREEN 2026-07-08 (stale RED in snapshot)
gh pr merge 16 --repo Coding-Autopilot-System/gsd-orchestrator --squash --delete-branch --admin

# gsd-orchestrator#20: MCP recovery state preservation (Phase 28-01) — merge AFTER #16
gh pr merge 20 --repo Coding-Autopilot-System/gsd-orchestrator --squash --delete-branch --admin

# gsd-orchestrator#21: typed FailureState records (Phase 27-02, audit-rescued 2026-07-08) — merge AFTER #20
gh pr merge 21 --repo Coding-Autopilot-System/gsd-orchestrator --squash --delete-branch --admin
```

### DO NOT MERGE (RED)

- **autogen#12** — feat(28-02): structured JSON failure telemetry + CLI fallback size guards
  - **Failing checks:** Python 3.12 / ubuntu-latest, Python 3.12 / windows-latest
  - **ROOT CAUSE IDENTIFIED (2026-07-08):** autogen `main`'s dependency set is internally
    inconsistent; PR **autogen#16** (Group 1, GREEN) carries the verified compatibility fix.
    **Merge #16 FIRST, then `gh pr update-branch` #11/#12/#13/#14 and let CI rerun** — no
    code changes expected in these PRs.

- **autogen#14** — feat(29-01): deterministic peer critic pattern-scan engine
  - **Failing checks:** Python 3.12 / ubuntu-latest, Python 3.12 / windows-latest
  - **Same root cause as #12** — resolves after #16 merges + update-branch.

- ~~gsd-orchestrator#16~~ — RE-VERIFIED GREEN 2026-07-08 (all 5 checks pass; snapshot was stale). Moved to merge commands above.

---

## GROUP 3 — Phase 31 CI/CD Hardening (12 total | 11 GREEN, 1 RED)

GitHub Actions SHA pinning and least-privilege permissions hardening. **Important:** After merging, you MUST run `gh pr update-branch` on same-repo CI workflow PRs before proceeding to Group 4.

### Merge Commands — Group 3

```bash
# .github#13: Org-wide action pinning (Phase 31)
gh pr merge 13 --repo Coding-Autopilot-System/.github --squash --delete-branch --admin

# Promptimprover#28: Action pinning + least-privilege (Phase 31)
gh pr merge 28 --repo Coding-Autopilot-System/Promptimprover --squash --delete-branch --admin

# autopilot-core#15: Action pinning (Phase 31)
gh pr merge 15 --repo Coding-Autopilot-System/autopilot-core --squash --delete-branch --admin

# cas-contracts#19: Action pinning + least-privilege (Phase 31)
gh pr merge 19 --repo Coding-Autopilot-System/cas-contracts --squash --delete-branch --admin

# cas-evals#10: Action pinning (Phase 31)
gh pr merge 10 --repo Coding-Autopilot-System/cas-evals --squash --delete-branch --admin

# cas-platform#12: Action pinning (Phase 31)
gh pr merge 12 --repo Coding-Autopilot-System/cas-platform --squash --delete-branch --admin

# cas-reference-product#12: Action pinning (Phase 31)
gh pr merge 12 --repo Coding-Autopilot-System/cas-reference-product --squash --delete-branch --admin

# cas-workstation#19: Action pinning + least-privilege (Phase 31)
gh pr merge 19 --repo Coding-Autopilot-System/cas-workstation --squash --delete-branch --admin

# ci-autopilot#2233: Action pinning + coverage regression gate (Phase 31)
gh pr merge 2233 --repo Coding-Autopilot-System/ci-autopilot --squash --delete-branch --admin

# cloud-security-service-model#14: Action pinning (Phase 31)
gh pr merge 14 --repo Coding-Autopilot-System/cloud-security-service-model --squash --delete-branch --admin

# gsd-orchestrator#18: Action pinning + least-privilege (Phase 31)
gh pr merge 18 --repo Coding-Autopilot-System/gsd-orchestrator --squash --delete-branch --admin
```

### DO NOT MERGE (RED)

- **autogen#13** — ci: pin third-party actions to commit SHAs and least-privilege permissions
  - **Failing checks:** Python 3.12 / ubuntu-latest, Python 3.12 / windows-latest
  - **Reason:** Build failures; likely same root cause as autogen#12 and #14

### Update-Branch Requirement (same-repo CI conflicts)

After merging Group 3, you MUST update branch state for same-repo CI workflow PRs before proceeding:

```bash
# Synchronize any PRs in the same repo that have CI workflow changes
gh pr update-branch --repo Coding-Autopilot-System/Promptimprover 27
gh pr update-branch --repo Coding-Autopilot-System/cas-platform 11
gh pr update-branch --repo Coding-Autopilot-System/cas-reference-product 11
```

---

## GROUP 4 — Phase 32 Schema Compatibility (2 total | 1 GREEN, 1 RED)

Registry schema updates and contract compatibility verification.

### Merge Commands — Group 4

```bash
# cas-evals#9: Registry smoke check + schema URL update
gh pr merge 9 --repo Coding-Autopilot-System/cas-evals --squash --delete-branch --admin
```

### DO NOT MERGE (Requires Label Review)

- **cas-contracts#18** — fix: rewrite schema $id to resolvable Pages registry URL
  - **Status:** RED (Classify schema compatibility check failed)
  - **Action required:** Apply `compatibility-reviewed` label MANUALLY before merge
  - **Rationale:** Schema compatibility must be reviewed by contract owner; label gates merge

---

## GROUP 5 — Phase 33 Bicep & DoNotEnforce (1 merged in Group 1)

The Phase 33 Bicep API version pinning and DoNotEnforce ADR was merged as part of Group 1:

- Merged: cloud-security-service-model#13

No additional Phase 33 PRs pending.

---

## GROUP 6 — Phase 36 Documentation Refresh (13 total | 12 GREEN, 1 RED)

Docs-as-code wiki trees, README updates, and context refresh. Merge these last; afterward, re-verify documentation footer freshness.

### Merge Commands — Group 6

```bash
# .github#14: Org profile vision hub + link map
gh pr merge 14 --repo Coding-Autopilot-System/.github --squash --delete-branch --admin

# Promptimprover#29: Phase 36 README + docs/wiki refresh
gh pr merge 29 --repo Coding-Autopilot-System/Promptimprover --squash --delete-branch --admin

# autopilot-core#16: Docs-as-code wiki tree
gh pr merge 16 --repo Coding-Autopilot-System/autopilot-core --squash --delete-branch --admin

# autopilot-demo#9: Docs-as-code wiki tree
gh pr merge 9 --repo Coding-Autopilot-System/autopilot-demo --squash --delete-branch --admin

# cas-contracts#20: Phase 36 README + docs/wiki refresh
gh pr merge 20 --repo Coding-Autopilot-System/cas-contracts --squash --delete-branch --admin

# cas-evals#11: Phase 36 README + docs/wiki refresh
gh pr merge 11 --repo Coding-Autopilot-System/cas-evals --squash --delete-branch --admin

# cas-platform#13: Bicep-lint README + docs-as-code wiki tree
gh pr merge 13 --repo Coding-Autopilot-System/cas-platform --squash --delete-branch --admin

# cas-reference-product#13: NO-AZURE context + docs-as-code wiki tree
gh pr merge 13 --repo Coding-Autopilot-System/cas-reference-product --squash --delete-branch --admin

# cas-workstation#20: Docs-as-code wiki tree
gh pr merge 20 --repo Coding-Autopilot-System/cas-workstation --squash --delete-branch --admin

# ci-autopilot#2244: Docs-as-code wiki tree
gh pr merge 2244 --repo Coding-Autopilot-System/ci-autopilot --squash --delete-branch --admin

# cloud-security-service-model#15: DoNotEnforce policy pointer + docs-as-code wiki tree
gh pr merge 15 --repo Coding-Autopilot-System/cloud-security-service-model --squash --delete-branch --admin

# gsd-orchestrator#19: Phase 36 README + docs/wiki refresh
gh pr merge 19 --repo Coding-Autopilot-System/gsd-orchestrator --squash --delete-branch --admin
```

### DO NOT MERGE (RED)

- **autogen#15** — docs: Phase 36 README + docs/wiki refresh
  - **Failing checks:** Python 3.12 / ubuntu-latest, Python 3.12 / windows-latest
  - **Reason:** Build failures in CI; same autogen Python environment issue as #12 and #14

---

## Post-Merge Local Normalization

After merging all groups, run the following to clean up your local environment:

```bash
# Fetch latest from all 13 CAS repos
for repo in Promptimprover autogen autopilot-core autopilot-demo cas-contracts cas-evals cas-platform cas-reference-product cas-workstation ci-autopilot cloud-security-service-model gsd-orchestrator .github; do
  git -C ../Coding-Autopilot-System/$repo fetch origin master
done

# Verify documentation freshness (re-check footer timestamps)
echo "Verify README footer timestamps in:"
echo "  - docs/README.md (all repos)"
echo "  - VISION.md (.github)"
echo "  - docs-as-code/*.md (all repos)"
```

---

## Summary

| Group | Type                    | Total | Mergeable | Blocked |
|-------|-------------------------|-------|-----------|---------|
| 1     | Rescue/Fix              | 8     | 7         | 1       |
| 2     | Phase 26/28/29 Features | 5     | 2         | 3       |
| 3     | Phase 31 Hardening      | 12    | 11        | 1       |
| 4     | Phase 32 Compatibility  | 2     | 1         | 1       |
| 5     | Phase 33 Bicep          | —     | —         | —       |
| 6     | Phase 36 Docs           | 13    | 12        | 1       |
| —     | **TOTAL**               | **39**| **33**    | **6**   |
