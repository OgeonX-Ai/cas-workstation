# Phase 32: Contracts Registry Publishing — Context

**Gathered:** 2026-07-06
**Status:** Ready for planning (`/gsd:plan-phase 32`) — depends on Phase 30
**Backlog refs:** S4 (High, ✅ verified)

## Problem

cas-contracts' published registry is dead: `pages.yml` (docs) and `publish-registry.yml` (registry) fight over the single GitHub Pages site, and `schemas.coding-autopilot.dev` has no DNS/domain configuration — so every schema `$id` URL 404s. This blocks consumer registry-fetch CI in dependent repos (autopilot-core, gsd-orchestrator, cas-evals).

Related: the currently checked-out cas-contracts branch is `fix/pages-release-ordering` with an open PR — review/land it in Phase 30 first; it may partially address the Pages conflict.

## Options (decide during planning)

1. **Docs subpath** — serve the registry under the existing Pages site at `/registry/`; rewrite schema `$id`s to the github.io URL. Cheapest, no DNS.
2. **GitHub Packages npm** — publish schemas as an npm package; consumers pin versions. Best integrity story, changes the consumer fetch mechanism.
3. **Custom domain** — configure `schemas.coding-autopilot.dev` DNS + Pages custom domain. Keeps `$id`s as-is, requires DNS access.

Recommendation from survey: option 1 unless DNS access is trivial, since `$id` stability matters less than resolvability right now.

## Definition of done (REQ-1.4.11)

- Every published schema `$id` resolves HTTP 200.
- Consumer registry-fetch CI job enabled and green in at least one consumer repo.
