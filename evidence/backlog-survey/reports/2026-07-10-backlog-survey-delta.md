# Backlog Survey Delta Report - 2026-07-10

Source backlog: C:\PersonalRepo\worktrees\phase-41-backlog-survey\docs\improvement-backlog.md

## New Findings

| Id | Section | Excerpt |
|---|---|---|
| S1 | Tier 1 — Systemic (highest leverage, fix once, applies org-wide) | **Unpinned GitHub Actions** (`@v4`/`@v8` tags, not SHAs) across nearly every ... |
| S2 | Tier 1 — Systemic (highest leverage, fix once, applies org-wide) | **CodeQL language mismatches** — `cloud-security-service-model` runs `javascr... |
| S3 | Tier 1 — Systemic (highest leverage, fix once, applies org-wide) | **Over-broad `GITHUB_TOKEN` / missing `permissions:` + `timeout-minutes`** on... |
| S4 | Tier 1 — Systemic (highest leverage, fix once, applies org-wide) | **cas-contracts published registry is dead** — `pages.yml` (docs) and `publis... |
| P1 | Tier 2 — Real, repo-specific | cas-platform |
| P2 | Tier 2 — Real, repo-specific | cas-platform / cloud-security |
| P3 | Tier 2 — Real, repo-specific | ci-autopilot |
| P4 | Tier 2 — Real, repo-specific | cloud-security |
| C1 | Tier 3 — Core-code leads (confirm before acting — survey was noisy) | gsd-orchestrator |
| C2 | Tier 3 — Core-code leads (confirm before acting — survey was noisy) | autogen |
| C3 | Tier 3 — Core-code leads (confirm before acting — survey was noisy) | cas-reference-product |
| C4 | Tier 3 — Core-code leads (confirm before acting — survey was noisy) | cas-evals |
| C5 | Tier 3 — Core-code leads (confirm before acting — survey was noisy) | Promptimprover |
| C6 | Tier 3 — Core-code leads (confirm before acting — survey was noisy) | multiple |
| W1 | Tier 0 — Data-loss / integrity risks | **Test suites exist nowhere in git.** Root commit `b4e0868` says "test: add f... |
| W2 | Tier 0 — Data-loss / integrity risks | **Root repo has 10 unpushed commits + large untracked working set** including... |
| W3 | Tier 0 — Data-loss / integrity risks | **`gemini-nano` is a gitlink with no `.gitmodules`** — fresh clones get an em... |
| W4 | Tier 0.5 — State divergence | **15 open PRs across the 13 org repos; every sub-repo is parked on an unmerge... |
| W5 | Tier 0.5 — State divergence | **Uncommitted engineering-os policy drift**: `OPERATING-CONTRACT.md`, `router... |
| H1 | Tier 4 — Hygiene (batch in one cleanup pass) | No CI on the root repo (no `.github/workflows/`): `tests/*.Tests.ps1` (workst... |
| H2 | Tier 4 — Hygiene (batch in one cleanup pass) | Sub-repo ignore gaps: `TestResults/` not ignored in gsd-orchestrator; `.cover... |
| H3 | Tier 4 — Hygiene (batch in one cleanup pass) | 14 worktrees under `worktrees/` — several stale (e.g. `cas-workstation-audit`... |
| H4 | Tier 4 — Hygiene (batch in one cleanup pass) | Root clutter: `scripts/*.ps1.bak` ×2, `rollback_phase26.ps1`, `rules.json` (b... |
| H5 | Tier 4 — Hygiene (batch in one cleanup pass) | No `.gitattributes` at root → CRLF/LF churn warnings on every JSON/md diff. A... |
| H6 | Tier 4 — Hygiene (batch in one cleanup pass) | Doc drift: GLOBAL_AGENTS.md "Workspace Layout" lists 5 portfolio repos; CLAUD... |
| M1 | Marketing & Adoption (added 2026-07-08, operator request) | **Marketing-as-code showcase site**: Feature Cards + per-phase Story Pages au... |
| M2 | Marketing & Adoption (added 2026-07-08, operator request) | Record real demo assets (autopilot-demo run GIF, terminal recording of a full... |
| M3 | Marketing & Adoption (added 2026-07-08, operator request) | Replace codex:generate-image placeholders across VISION/wikis/marketing with ... |
| E1 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | Merge flow: human-merge bottleneck (40-PR queue); need merge queue + safe aut... |
| E2 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | No per-repo releases/changelogs/SemVer discipline |
| E3 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | Pilots + fault injections not on a schedule (regression risk) |
| E4 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | Learnings extraction not institutionalized per phase |
| E5 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | No commit/tag signing, provenance, or SBOMs |
| E6 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | Secret-scanning gates unverified; token inventory/rotation undefined |
| E7 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | No self-measurement: DORA metrics, token spend, health trends |
| E8 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | Test quality unmeasured (mutation testing, property-based contract tests) |
| E9 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | Clean-machine bootstrap unproven; community files incomplete |
| E10 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | No disaster-restore drill / documented RTO |
| E11 | Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md) | REQUIREMENTS.md format blocks `requirements.mark-complete` tooling (hit by 3 ... |

## Closed Items

None.

## Trend Counts

- Total current items: 39
- New findings: 39
- Closed items: 0
- Unchanged items: 0
- Convergence: BASELINE

This is the first-ever survey run (REQ-1.5.6); there is no prior snapshot to diff against, so every parsed item is reported as a new finding and convergence is BASELINE.
