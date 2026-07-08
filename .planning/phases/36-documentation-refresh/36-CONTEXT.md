# Phase 36: Portfolio Documentation Refresh — Context

**Gathered:** 2026-07-06 (operator request: "update the github documentation all of to be the best it can be, so documentation keeps up with the code")
**Status:** Ready for planning
**Runs before:** Phase 35 audit (35 depends on 36)

## Locked decisions

1. **Scope = all GitHub-facing docs across the org**: 13 repo READMEs + CONTRIBUTING + docs/ trees, the org profile (org-dotgithub `profile/README.md`), and the root workstation repo (README.md, docs/).
2. **Docs must be verified against code** — the b4e0868 lesson applied to prose. Every factual claim (commands, paths, features, badges, coverage numbers, architecture) is checked by gsd-doc-verifier against the live tree before commit. No aspirational claims.
3. **Freshness convention**: each refreshed README gets a footer line `<!-- docs-verified: <repo-head-sha> <date> -->`; Phase 34's sweep gains a staleness heuristic (footer sha vs HEAD distance) — advisory, not blocking.
4. **Reflect the v1.4 reality**: new coverage gates (Phase 26), workflow-lint + pinned actions (31), registry URLs (32), bicep-ready + NO-AZURE-deploy lock (33 — document that deployments are locked until a future milestone), workspace guardrails (34), merge-train runbook (30).
5. **PR-only for sub-repos**, direct commits for root. Branch: `docs/phase-36-refresh`.
6. Badges: CI status per repo; coverage badge only where a real gate exists (26 repos); no fake badges.

## Environment facts

- Repos may still be receiving phase 26/31/32/33 PRs — docs executors must read the repo's *current default branch* and note pending PRs rather than describing unmerged work as landed. Where a phase PR is open, docs may reference it as "in progress (PR #N)".
- org-dotgithub is the org profile repo; its README is the portfolio's front door — highest polish priority.
- gemini-nano has its own CLAUDE.md/README (experimental repo — mark experimental status honestly).

## Definition of done

- Every repo README accurately describes: purpose, architecture (1 diagram or section), setup, test/coverage commands, CI gates, and its role in the CAS portfolio (link map).
- gsd-doc-verifier passes on every refreshed doc (all claims verified).
- Freshness footers present; Phase 34 sweep heuristic implemented or ticketed.
