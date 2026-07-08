# Phase 36 Task 2: Wiki Trees for Autopilot/Platform/Support Repos — Summary

**Scope:** 36-03-PLAN.md Task 2, plus the applicable 36-01/36-02 README-refresh tasks for the
three repos in this batch that had one (cas-platform, cas-reference-product,
cloud-security-service-model), combined onto a single `docs/phase-36-refresh` branch/PR per repo
per the orchestrator's scope instructions.

**Repos covered:** autopilot-core, autopilot-demo, ci-autopilot, cas-platform,
cas-reference-product, cloud-security-service-model, cas-workstation.

## Method

- Created one detached worktree per repo under `.worktrees-phase36/<repo>` (Windows paths),
  branched `docs/phase-36-refresh` from `origin/main`, so the seven existing checkouts under
  `portfolio/<repo>` (some of which had uncommitted local changes or were parked on unrelated
  feature branches) were never touched.
- All seven repos have `main` as the default branch.
- For each repo: read README, CI workflows, `docs/architecture.md`/`operations.md` where
  present, `.planning/` phase summaries, and `docs/adr/` before writing anything, per the
  verify-before-claim rule.
- Added `docs/wiki/{Home,Architecture,Operations,Decisions}.md` to every repo. Every
  Architecture.md has a repo-specific Mermaid diagram (GitHub-renderable flowchart subset) plus
  one `codex:generate-image` placeholder in the exact `docs/VISION.md` format. Every page ends
  with `<!-- docs-verified: <sha> <date> -->`.
- For the three repos with an applicable 36-01/36-02 README task, applied that task's edits on
  the same branch/PR (see per-repo notes below).
- Pushed each branch and opened one PR per repo via `gh pr create` (PR-only, never merged or
  approved). Removed all seven worktrees after PR creation; verified original checkouts were
  undisturbed (`git status --short` unchanged before/after).

## Per-repo notes

### autopilot-core (wiki only — no README task in 36-01/02)
- Architecture.md: intake -> issue -> operator -> Codex -> PR flow (reused/adapted from README).
- Operations.md: `pwsh ./tests/run-tests.ps1`, CI steps (workflow-YAML validation, contract
  tests, Pester); explicitly notes no coverage-percentage gate exists in `ci.yml`.
- Decisions.md: indexes `.planning/phases/01-enterprise-audit/` and the (empty) ADR convention.
- HEAD SHA verified: `cd76345f0837ce2f710ad8bad7bbc9e3de9d5ff0`.

### autopilot-demo (wiki only — no README task in 36-01/02)
- Architecture.md: demo-trigger -> intake -> operator -> PR flow.
- Operations.md: demo runbook, CI workflow table, `python -m unittest discover -s tests -v`.
- Decisions.md: indexes `01-enterprise-hardening` phase summary and a quick-fix summary.
- HEAD SHA verified: `ec62179aa2c20bc731542de4ac3fec9cc94a831d`.

### ci-autopilot (wiki only — no README task in 36-01/02)
- Architecture.md: self-hosted-runner fixer/poll-loop (`agent/poll_once.py`), stated explicitly
  as read-only (no autonomous dispatch yet).
- Operations.md: `py_compile` / import check / `unittest discover` CI steps, runner
  service-control commands. **Deviation from orchestrator's stated fact:** the scope brief said
  "ci-autopilot has [a coverage gate] at 90%" — I grepped `ci.yml` and the full `.github/workflows`
  tree and found no `--cov-fail-under`, `pytest-cov`, or coverage-threshold configuration on
  `origin/main`; the only "cov" match was the substring inside `unittest discover`. Per decision 2
  (verify against the live tree, no aspirational claims), I did **not** add a coverage badge or
  claim a 90% gate exists — Operations.md states plainly that no coverage-percentage gate is
  configured. Flagging this discrepancy for the orchestrator/audit in case the 90% gate was
  intended for a different repo or is still unmerged elsewhere.
- Decisions.md: indexes the 2026-06-10 audit-fix report's findings table, including the open
  F-11 (guarded dispatcher absent) and F-12 (runner hardening not codified) gaps that explain
  why the agent is read-only today.
- HEAD SHA verified: `4590462b38e0a835385c3a7c4a4b35d761bed5dc`.

### cas-platform (wiki + 36-02 Task 1 README work)
- README: added a "Validation and Linting" section describing `bicepconfig.json`'s core
  analyzer ruleset and the `use-recent-api-versions` rule's current `off` state on `main`
  (verified directly in the file), framed as pending open PR #11 (`gh pr view 11` confirmed
  `state: OPEN`, `mergedAt: null`). Added an explicit "Deployment lock" section connecting to
  the workspace NO-AZURE hard lock.
- Architecture.md: module-graph Mermaid diagram + an explicit deploy-lock statement (bicep-ready,
  not deployed, per GLOBAL_AGENTS.md hard-lock language).
- Operations.md: verified `validate.ps1` / `what-if.ps1` commands; notes `what-if.ps1` only
  invokes `az deployment sub what-if`, never a create/deploy command.
- Decisions.md: indexes the two phase summaries and flags PR #11 as the open decision.
- HEAD SHA verified: `c1585ee195b72c5282f278c98da28c60da75667c`.

### cas-reference-product (wiki + 36-01 Task 2 README work)
- README: inserted the NO-AZURE-deploy-lock connecting paragraph immediately after the existing
  "does not deploy Azure resources" sentence, naming the workspace hard lock and cas-platform's
  bicep-ready-but-not-deployed status (Phase 33). Did not alter Foundry Next Gen Mode or
  Container sections, per the 36-01 instruction.
- Architecture.md: reused/adapted the request-flow Mermaid diagram from `docs/architecture.md`;
  added an explicit "Deployment lock (NO-AZURE posture)" section.
- Operations.md: verified `ruff`/`mypy`/`pytest`/`evidence` CI steps from `ci.yml`, Foundry-mode
  env vars, and the non-deploying `az deployment group what-if` platform-handoff command.
- Decisions.md: this repo has no phase SUMMARY files yet, so it points at
  `.planning/{PROJECT,ROADMAP,REQUIREMENTS}.md` and `docs/case-study-evidence.md` instead.
- HEAD SHA verified: `57c21b03a48332728105b72a90e8e89deda409af`.

### cloud-security-service-model (wiki + 36-02 Task 2 README work)
- Grepped the whole tree for `DoNotEnforce` and `docs/adr/` before writing anything, per the
  36-02 instruction. Found `enforcementMode: 'DoNotEnforce'` already present on `main` in
  `impl/azure/landing-zone/bicep/modules/policy-assignments.bicep` (the actual policy setting),
  but **no ADR file** recording the decision — `docs/adr/` on `main` holds only the governance
  README. The formal ADR-001 commit exists only on the local branch
  `fix/bicep-lint-api-version-pinning`, which corresponds to the still-open PR #13 (`gh pr view 13`
  confirmed `state: OPEN`, `mergedAt: null`).
- README: added a one-line "Quick navigation" pointer to the real `policy-assignments.bicep`
  setting, explicitly stating the formal ADR is in progress in PR #13 rather than linking to a
  nonexistent `docs/adr/00X-*.md` path.
- Architecture.md: reused the service-lifecycle Mermaid diagram; added an explicit deploy-lock
  section for the `impl/` Bicep/policy-as-code stubs and a dedicated "Policy enforcement mode:
  DoNotEnforce (in progress)" section with the verified PR #13 state.
- Operations.md: docs-only-repo navigation/validation commands (`markdownlint`,
  `scripts/validate-repository.sh`); confirms no fake coverage badge added (repo has no
  application code).
- Decisions.md: records the in-progress DoNotEnforce decision with the exact `gh pr view`
  evidence and indexes `.planning/phases/01-enterprise-audit/`, `.planning/audits/`,
  `.planning/debug/`.
- HEAD SHA verified: `ca23302fb25134bdd086455c91019ffea272a8b1`.

### cas-workstation (wiki only — no README task in 36-01/02)
- Architecture.md: manifest -> resolve -> preview -> apply -> journal flow (`stack.manifest.json`,
  `Resolve-CasDesiredState`, `.cas/state`/`.cas/logs`, `managed-state.json`). Explicitly
  distinguishes this repo's `doctor.ps1` readiness sweep from the root PersonalRepo workspace's
  separate `scripts/workspace-health.ps1` control-plane sweep (Phase 34) — grepped this repo for
  `workspace-health` first and found no match, so the two were not conflated.
- Operations.md: verified `Invoke-Quality.ps1` gate, CI steps (`quality.yml`, Pester 5.7.1+,
  PSScriptAnalyzer 1.24+, `jsonschema` 4.26.0), setup/upgrade/repair/uninstall command surface.
- Decisions.md: indexes all four phase directories (with plan counts) and the ADR convention.
- HEAD SHA verified: `4c70f86190c6cd2333fb6357a5928fbb904776ef`.

## Deviations from plan

1. **[Rule 1/Rule 2 — accuracy correction] ci-autopilot coverage-gate claim.** The task brief
   asserted "ci-autopilot has [a coverage gate] at 90%." Live-tree verification found no such
   gate on `origin/main`. Wrote Operations.md to state the true CI gate (syntax/import/unittest
   pass-fail) instead of fabricating a coverage badge, per decision 2 (no aspirational claims).
   No badge was added anywhere for ci-autopilot.
2. **[Rule 2 — scope addition] README refresh combined with wiki work.** The orchestrator's
   scope note directed applying the 36-01/36-02 README tasks covering these seven repos onto the
   same branch/PR. Neither 36-01-SUMMARY.md nor 36-02-SUMMARY.md existed at execution time (no
   evidence those plans had run yet, and none of the seven repos had a pre-existing
   `docs/phase-36-refresh` branch), so I performed the README-refresh work directly for
   cas-platform, cas-reference-product, and cloud-security-service-model inside this task,
   combining it with the wiki-tree commit history on the shared branch, as instructed.
3. No architectural changes were needed; no Rule 4 escalations occurred; no auth gates were hit
   (`gh` was already authenticated as `OgeonX-Ai` with `repo`/`workflow` scopes).

## Self-check

All seven `docs/wiki/` trees, the three README edits, and all seven PR URLs below were verified
directly against the pushed branches (`git log --oneline`, `gh pr view --json state,mergeable`)
before this summary was written.

## PR URLs

| Repo | PR |
|---|---|
| autopilot-core | https://github.com/Coding-Autopilot-System/autopilot-core/pull/16 |
| autopilot-demo | https://github.com/Coding-Autopilot-System/autopilot-demo/pull/9 |
| ci-autopilot | https://github.com/Coding-Autopilot-System/ci-autopilot/pull/2244 |
| cas-platform | https://github.com/Coding-Autopilot-System/cas-platform/pull/13 |
| cas-reference-product | https://github.com/Coding-Autopilot-System/cas-reference-product/pull/13 |
| cloud-security-service-model | https://github.com/Coding-Autopilot-System/cloud-security-service-model/pull/15 |
| cas-workstation | https://github.com/Coding-Autopilot-System/cas-workstation/pull/20 |

All PRs report `state: OPEN`, `mergeable: MERGEABLE` as of verification. None were merged or
approved by this agent.
