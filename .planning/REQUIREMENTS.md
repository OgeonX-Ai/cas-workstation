# Milestone v1.5 Requirements: Delivery Flow & Release Engineering

**Created:** 2026-07-08 from `.planning/milestones/vNEXT-SEEDS.md` (operator-approved seed plan).
**Format:** checkbox traceability (machine-markable via `requirements.mark-complete`).

## Goals
Changes flow from agent to `main` in hours without weakening two-party review, and every repo ships versioned, documented releases. Close the v1.4 lesson: governance that queues is governance that gets bypassed.

## Must Have

- [ ] **REQ-1.5.1** [Falsifiable] Merge flow live: GitHub auto-merge/merge-queue enabled for dependabot and docs-only PRs on green checks with a real second-reviewer mechanism (operator identity or review-bot with own credentials — never agent self-approval). Falsifier: a test dependabot-class PR merges without agent or ad-hoc operator action; median green-PR time-to-merge < 24h over a 2-week observation window; 0 open PRs older than 7 days.
- [ ] **REQ-1.5.2** [Falsifiable] v1.4 residual hygiene backfill complete: conservative-kept local branches resolved with a squash-aware content gate, worktree leftovers (`pr-maf-workers`, `v1.1-cas-contracts`) dispositioned, root-repo branch-protection decision executed and documented. Falsifier: workspace-health sweep clean on those categories.
- [ ] **REQ-1.5.3** [Falsifiable] Release engineering live: every portfolio repo has a SemVer tag whose generated release notes match `git log` since the prior tag (release-please or equivalent), wired to run on merge. Falsifier: `gh release view` latest per repo shows notes consistent with commit history.
- [x] **REQ-1.5.4** [Falsifiable] Pilot cadence: the four v1.0 pilot scenarios + Phase 28 fault injections run on a weekly local schedule producing committed evidence artifacts; a seeded regression auto-files an issue within one cycle. Falsifier: evidence artifacts for 2 consecutive weekly runs; seeded-regression issue exists.

## Should Have

- [ ] **REQ-1.5.5** [Falsifiable] Release staleness detection: workspace-health sweep flags any repo >30 days since last release that has merged changes. Falsifier: red fixture test.
- [ ] **REQ-1.5.6** [Falsifiable] Learning loop institutionalized: every phase closed in v1.5 has LEARNINGS.md extracted at close; the 2026-07-03-style backlog survey is a repeatable script producing a dated delta report. Falsifier: LEARNINGS.md present for phases 38-41; survey script run evidence.

## Won't Have (this milestone)

- **REQ-1.5.7**: Artifact signing/SBOM/secret-rotation (v1.6 scope). Cloud deployment (locked). Marketing site (v1.7/Phase 37 scope).
