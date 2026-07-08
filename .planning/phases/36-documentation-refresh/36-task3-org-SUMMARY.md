# Phase 36 Task 3 (org-dotgithub portion): Org Profile Vision Hub — Summary

One-liner: Published `profile/VISION.md` (org-audience adaptation of the root governed-autonomy
thesis with links to all 13 portfolio repos) and rewrote `profile/README.md` as a concise
front door with a single three-plane Mermaid diagram and a repo map table.

## What was done

**Repo:** `portfolio/org-dotgithub` (remote `Coding-Autopilot-System/.github`)
**Branch:** `docs/phase-36-refresh` (new branch, cut from `origin/main` @ `46b4bcf4e334ce9aec4e00dcf7c9fb1c40db837a`)
**PR:** https://github.com/Coding-Autopilot-System/.github/pull/14
**Commit:** `ce5b3e8` — `docs(profile): publish org vision hub with 13-repo link map`

1. **`profile/VISION.md` (new file, 133 lines)** — org-audience adaptation of the root
   `docs/VISION.md`. Kept the thesis quote, problem framing, all three Mermaid diagrams
   (three-plane architecture, SDLC loop, modular-agent hierarchy) and every
   `codex:generate-image` placeholder verbatim from the source, per plan instruction. Adapted
   the "Plane / Owner" table to link each owner to its GitHub repo, and added a new "Explore
   the 13 repositories" section — a full repo map (repo / role / plane-category) with working
   links to all 12 portfolio repos plus a self-link to `.github`. Closing line was corrected to
   avoid an unverifiable claim (initially linked "docs/VISION.md" to the wrong repo URL —
   caught and fixed before commit; see Deviations).
2. **`profile/README.md` (rewritten)** — replaced the previous long-form narrative README with
   a concise front door: thesis one-liner, single three-plane Mermaid (trimmed to just that one
   diagram per plan instruction — SDLC loop and agent-hierarchy diagrams live only in VISION.md),
   prominent link to `VISION.md`, a repo map table (repo → plane/category → one-liner) covering
   all 13 repos, a trimmed review path, and the existing "What this portfolio demonstrates" /
   "Organization standards" sections retained.
3. Both files carry a freshness footer `<!-- docs-verified: 46b4bcf4e334ce9aec4e00dcf7c9fb1c40db837a 2026-07-08 -->` per Phase 36 decision 3.

## Verification performed

- **Repo list resolved via API, not assumed.** `gh api orgs/Coding-Autopilot-System/repos` was
  used to enumerate the org's actual repos (15 total, including `.github`). Cross-referenced
  against the local `portfolio/` directory (13 entries, matching the "13 repos" claim in root
  `docs/VISION.md`) to exclude two org-level repos that are **not** part of the canonical 13:
  `ai-engineering-operating-system` (exists on GitHub, not in local portfolio/CLAUDE.md project
  table) and `gemini-nano` (lives at repo root, marked experimental per 36-CONTEXT, not part of
  the `portfolio/` set). The 13 = the 12 portfolio repos other than `org-dotgithub` + `org-dotgithub`
  itself.
- **Every one of the 13 repo links verified to resolve** via `gh api repos/Coding-Autopilot-System/<repo>`
  (all returned 200 / correct `full_name`) before being written into either file.
- **Deep links verified**: `cas-reference-product/docs/case-study-evidence.md` and
  `cas-reference-product/evidence/verified-local-golden-path-v0.1` both resolved via
  `gh api .../contents/...`.
- **Default branches checked** for all linked repos (all `main` except `Promptimprover` =
  `master`; no deep links into `Promptimprover` were added, so this had no effect on the URLs
  used).
- **PR #13 conflict check**: `gh pr view 13` shows it touches only
  `.github/workflows/{codeql,pages,pr-lint,stale}.yml` (SHA-pin hardening, REQ-1.4.10) — no
  overlap with `profile/*`. Confirmed independence: `gh pr view 14 --json mergeable` returned
  `"mergeable": "MERGEABLE"` (`mergeStateStatus: BLOCKED` is branch-protection/required-checks,
  not a merge conflict).
- **Mermaid diagrams**: no local `mmdc` CLI available in this environment; all three diagrams in
  `VISION.md` and the one diagram in `README.md` are reused verbatim (same flowchart-only syntax)
  from the already-authored root `docs/VISION.md`, which is the plan's designated canonical
  source for Mermaid house style. Visual confirmation in the PR's rendered preview is flagged as
  an open checkbox in the PR body for human/verifier follow-up (GitHub renders Mermaid
  client-side; this cannot be confirmed via `gh api`).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed unverifiable link in VISION.md footer**
- **Found during:** drafting `profile/VISION.md`
- **Issue:** First draft of the closing attribution line linked "docs/VISION.md" to
  `https://github.com/Coding-Autopilot-System/gsd-orchestrator`, an incorrect and unverified
  target (root `docs/VISION.md` lives in the local workstation workspace, whose `origin` remote
  resolves to `OgeonX-Ai/cas-workstation`, not `Coding-Autopilot-System/gsd-orchestrator`, and it
  is unclear whether/where that file is published under the `Coding-Autopilot-System` org at
  time of writing).
- **Fix:** Changed the attribution to plain (non-linked) text describing the root file's
  location, avoiding an unverified/incorrect hyperlink.
- **Files modified:** `profile/VISION.md`
- **Commit:** `ce5b3e8` (fixed before initial commit — not a separate commit)

No other deviations.

## Self-Check

- `profile/VISION.md` exists at `C:\PersonalRepo\portfolio\org-dotgithub\profile\VISION.md` — FOUND
- `profile/README.md` modified at `C:\PersonalRepo\portfolio\org-dotgithub\profile\README.md` — FOUND
- Commit `ce5b3e8` on branch `docs/phase-36-refresh` — FOUND (`git log --oneline` on that branch)
- PR https://github.com/Coding-Autopilot-System/.github/pull/14 — FOUND (open, mergeable)

## Self-Check: PASSED

## Scope note

This summary covers only the **org-dotgithub portion** of Phase 36 Task 3
(`profile/README.md` + `profile/VISION.md`). The root-repo portion of Task 3
(`docs/wiki/Agent-Hierarchy.md`, direct commit) is out of scope for this execution and is not
covered here.
