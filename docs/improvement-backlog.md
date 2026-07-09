# CAS Portfolio — Continuous-Improvement Backlog

> Consolidated from two parallel read-only surveys (2026-07-03) + spot-verification.
> **Confidence tags:** ✅ verified-real · 🔎 flagged (not yet verified) · ❌ verified false-positive.
> Severities are re-rated after verification, not taken from the survey as-is.

## How to read this
The infra/CI survey proved **well-grounded**; the core-code survey was a **noisy lead-list**
— its two "immediate/blocking" HIGHs were both false positives on verification. Treat 🔎
core-code items as leads to confirm before spending effort.

---

## Tier 1 — Systemic (highest leverage, fix once, applies org-wide)

| # | Item | Sev | Conf | Action |
|---|---|---|---|---|
| S1 | **Unpinned GitHub Actions** (`@v4`/`@v8` tags, not SHAs) across nearly every repo | Med | ✅ | Pin third-party actions to commit SHAs; enable Dependabot actions updates. Dependabot PRs already open on autopilot-core — adopt org-wide. |
| S2 | **CodeQL language mismatches** — `cloud-security-service-model` runs `javascript` on Bicep; `cas-workstation` runs `python` on PowerShell | Med | ✅ | Set matrix to `actions` (both have workflows) or drop CodeQL for docs-only. cas-platform + `.github` already fixed. |
| S3 | **Over-broad `GITHUB_TOKEN` / missing `permissions:` + `timeout-minutes`** on many workflows | Med | 🔎 | Add least-privilege `permissions:` blocks and job timeouts to shared workflow templates. |
| S4 | **cas-contracts published registry is dead** — `pages.yml` (docs) and `publish-registry.yml` (registry) fight over one Pages site; `schemas.coding-autopilot.dev` unconfigured, so every schema `$id` 404s | High | ✅ | (Task #13) Serve registry under a docs subpath OR publish as GitHub Packages npm OR configure the custom domain + DNS. Unblocks consumer registry-fetch CI (#10). |

## Tier 2 — Real, repo-specific

| # | Repo | Item | Sev | Conf |
|---|---|---|---|---|
| P1 | cas-platform | `observability.bicep:30-46` hardcodes `publicNetworkAccess: Enabled` (no per-env param). Auth is already AAD-only (`DisableLocalAuth`, resource-permissions), so defense-in-depth, not open door | Med | ✅ |
| P2 | cas-platform / cloud-security | No `.bicepconfig.json` linting; API versions not consistently pinned | Med | 🔎 |
| P3 | ci-autopilot | No coverage threshold in CI (`--cov-fail-under`); self-hosted-runner token scope on `fixer.yml`/`runner-health.yml` | Low/Med | 🔎 |
| P4 | cloud-security | Policy assignment in `DoNotEnforce` audit mode — confirm intent / add tracking ticket | Low | 🔎 |

## Tier 3 — Core-code leads (confirm before acting — survey was noisy)

| # | Repo | Lead | Verified? |
|---|---|---|---|
| C1 | gsd-orchestrator | "Process deadlock in NativeVerifier" | ❌ **False positive** — async reads start before `WaitForExitAsync`; correct pattern. |
| C2 | autogen | "Shell injection in cli_clients.py" | ❌ **False positive** — `subprocess.run(list)` with no `shell=True`; no shell interprets input. |
| C3 | cas-reference-product | `workflow.py:59` bare `except Exception` loses original cause (no `from`/traceback) | 🔎 plausible, low sev |
| C4 | cas-evals | `reference_product.py:49-52` collapses HTTPError/URLError/Timeout/OSError to one "unavailable" message, hiding root cause | 🔎 plausible, low sev |
| C5 | Promptimprover | Concurrent-write race on blackboard.json; env-var access without defaults | 🔎 plausible, low sev |
| C6 | multiple | Missing size limits on subprocess stdin / JSON parse (defensive) | 🔎 low sev |
| — | cas-contracts (code) | No critical issues found | ✅ clean |

---

## Suggested milestone: **Portfolio Hardening v1.1**

**Phase 1 — Systemic CI/security hardening (highest leverage):** S1, S2, S3.
**Phase 2 — Contract registry:** S4 (fix publishing) → then #10 (consumer registry-fetch CI).
**Phase 3 — Infra hardening:** P1, P2 (Bicep public-access params + `.bicepconfig.json`).
**Phase 4 — Code robustness (confirm-first):** verify + fix C3–C6; skip C1/C2 (false positives).

**Already delivered in this pass (not part of v1.1):** 13-repo docs, gitignore hygiene,
autopilot-core +24 tests +refactor, ci-autopilot +47 tests, contract-compat CI, CodeQL fix
(cas-platform/.github), Promptimprover protection hardening, full audit-sweep release (12 repos merged).

---

## Workspace-integrity survey (2026-07-06)

New findings from a root-workspace sweep. These are about durability and truthfulness of the
workspace state, not code quality — several rank above everything in Tier 1.

### Tier 0 — Data-loss / integrity risks

| # | Item | Sev | Evidence |
|---|---|---|---|
| W1 | **Test suites exist nowhere in git.** Root commit `b4e0868` says "test: add full coverage suites for gsd-orchestrator and autogen" but contains only `.planning/` + OPERATING-CONTRACT changes. The actual files (`portfolio/gsd-orchestrator/tests/`, `portfolio/autogen/tests/test_autogen.py`) are untracked in their sub-repos, and `portfolio/` is gitignored at root. One disk failure loses both suites. | **High** | ✅ verified |
| W2 | **Root repo has 10 unpushed commits + large untracked working set** including `GLOBAL_AGENTS.md` (canonical rules referenced by CLAUDE.md), `requirements.txt`, `docs/improvement-backlog.md`, `docs/azure-rollout-plan.md`, all v1.3 `.planning/` records, `engineering-os/personas/`+`scripts/`, and 5 new `scripts/*.ps1`. Entire v1.3 milestone record exists only on this machine. | **High** | ✅ verified |
| W3 | **`gemini-nano` is a gitlink with no `.gitmodules`** — fresh clones get an empty directory with no URL to restore it from. Add `.gitmodules` or untrack + gitignore. | Med | ✅ verified |

### Tier 0.5 — State divergence

| # | Item | Sev |
|---|---|---|
| W4 | **15 open PRs across the 13 org repos; every sub-repo is parked on an unmerged feature branch** (`chore/governance-hardening` ×8, dependabot ×2, others). Local reality diverges from what `main` claims everywhere. Run the merge train (see release-process notes), then return checkouts to `main`. | High |
| W5 | **Uncommitted engineering-os policy drift**: `OPERATING-CONTRACT.md`, `router/ollama-policy.json`, `ollama-benchmark.json`, `tool-matrix.json`, `models/codex.json` modified but uncommitted — every agent session loads unversioned policy. | Med |

### Tier 4 — Hygiene (batch in one cleanup pass)

| # | Item |
|---|---|
| H1 | No CI on the root repo (no `.github/workflows/`): `tests/*.Tests.ps1` (workstation contract tests) never run automatically. Add a minimal Pester workflow. |
| H2 | Sub-repo ignore gaps: `TestResults/` not ignored in gsd-orchestrator; `.coverage` not ignored in autogen. Promptimprover has untracked `package.json`, `dashboard/`, `run-dashboard.ps1` — commit or discard deliberately. |
| H3 | 14 worktrees under `worktrees/` — several stale (e.g. `cas-workstation-audit` last commit 2026-06-11, `pr-*` copies of merged PRs). Audit + `git worktree prune`/delete. |
| H4 | Root clutter: `scripts/*.ps1.bak` ×2, `rollback_phase26.ps1`, `rules.json` (branch-protection payload left over from an admin-merge), `test-*.js` ×3, `deep-research-report (4).md`, `ChatGPT Image *.png`, `scratch/`. Delete or move transient artifacts into an ignored `scratch/`. |
| H5 | No `.gitattributes` at root → CRLF/LF churn warnings on every JSON/md diff. Add `* text=auto eol=lf` (or explicit per-type rules). |
| H6 | Doc drift: GLOBAL_AGENTS.md "Workspace Layout" lists 5 portfolio repos; CLAUDE.md context chain lists 14. Root repo pushes to `OgeonX-Ai/cas-workstation` while `portfolio/cas-workstation` is `Coding-Autopilot-System/cas-workstation` — same name, two orgs; document or rename to avoid mis-targeting. |

## Marketing & Adoption (added 2026-07-08, operator request)

| # | Item | Phase |
|---|---|---|
| M1 | **Marketing-as-code showcase site**: Feature Cards + per-phase Story Pages auto-generated from `.planning/` evidence; LinkedIn drafts per phase; demo GIF placeholders; clean-machine quickstart CTA. Strategy: `.planning/phases/37-marketing-and-adoption/37-CONTEXT.md` | 37 |
| M2 | Record real demo assets (autopilot-demo run GIF, terminal recording of a full goal loop) to replace placeholders | 37 follow-up |
| M3 | Replace codex:generate-image placeholders across VISION/wikis/marketing with generated visuals (Codex image pipeline) | in progress - started 2026-07-08 with `docs/wiki/Agent-Hierarchy.md` and `docs/VISION.md` |

## Elite-enterprise gap analysis (2026-07-08 → milestones v1.5–v1.7, see .planning/milestones/vNEXT-SEEDS.md)

| # | Gap | Milestone |
|---|---|---|
| E1 | Merge flow: human-merge bottleneck (40-PR queue); need merge queue + safe auto-merge + real second reviewer | v1.5/38 |
| E2 | No per-repo releases/changelogs/SemVer discipline | v1.5/39 |
| E3 | Pilots + fault injections not on a schedule (regression risk) | v1.5/40 |
| E4 | Learnings extraction not institutionalized per phase | v1.5/41 |
| E5 | No commit/tag signing, provenance, or SBOMs | v1.6/43 |
| E6 | Secret-scanning gates unverified; token inventory/rotation undefined | v1.6/44 |
| E7 | No self-measurement: DORA metrics, token spend, health trends | v1.6/45 |
| E8 | Test quality unmeasured (mutation testing, property-based contract tests) | v1.6/46 |
| E9 | Clean-machine bootstrap unproven; community files incomplete | v1.7/48 |
| E10 | No disaster-restore drill / documented RTO | v1.7/50 |
| E11 | REQUIREMENTS.md format blocks `requirements.mark-complete` tooling (hit by 3 agents) | v1.5/38 (quick fix eligible) |

### Suggested sequencing

1. **Today**: W1 (commit tests in their own repos), W2 (commit + push root, incl. GLOBAL_AGENTS.md).
2. **This week**: W4 merge train → all repos back on `main`; W5 commit policy drift; W3.
3. **One cleanup phase**: H1–H6 batched, then re-run this survey to confirm a clean baseline.
