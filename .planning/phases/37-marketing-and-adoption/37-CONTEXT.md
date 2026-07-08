# Phase 37: Marketing & Adoption Engine — Context

**Gathered:** 2026-07-08 (operator request: marketing material for each feature/phase/task so people start using this)
**Status:** Planned for after Phase 35 audit (marketing claims must reference an audited milestone)
**Backlog ref:** M1 (docs/improvement-backlog.md)

## Strategy (the careful thinking)

**Audience, in priority order:**
1. Engineering leaders wrestling with "AI speed vs governance" (the LinkedIn thesis audience) — they share and hire.
2. Senior engineers who evaluate by reading repos, not landing pages.
3. Potential collaborators/employers assessing Kim's portfolio.

**Core positioning:** *Governed autonomy, proven on itself.* CAS's differentiator is that every claim has machine-checkable evidence — so the marketing method is **marketing-as-code**: generate the material from the same `.planning/` artifacts (plans, summaries, verification reports) that govern the system. Nothing hand-waved; every feature page links to the commit/PR/test that proves it. This is both honest and unique — competitors show demos, CAS shows audit trails.

**Channel strategy (chosen, with rationale):**
| Channel | Role | Why this beats alternatives |
|---|---|---|
| GitHub org profile + repo wikis (Phase 36) | Front door + depth | Developers trust repos; already built and verified |
| **Showcase site** (mkdocs-material on GitHub Pages) | The "some page" — one aggregated, shareable site | mkdocs-material already proven in-portfolio (cas-contracts); Pages is free, versioned, PR-gated — the governance story applies to marketing itself |
| **Build-log story pages** (auto-generated per phase) | Content engine | The 36+ phase summaries ARE compelling build-in-public content; a generator keeps them synced (b4e0868 lesson applies to marketing prose) |
| LinkedIn post drafts (1 per phase, Mikhail-style: tension → what we built → real number) | Distribution | Where audience #1 lives; drafts stored in-repo so posting is a 2-minute human act |
| Demo assets (autopilot-demo GIFs, terminal recordings) | Proof of motion | Static claims + moving demo = conversion; placeholders until recorded |

**Explicitly NOT doing:** paid ads, a custom web app, separate CMS, X/Twitter automation — all add surface without evidence value.

**Content unit model (feature → phase → task granularity):** one Feature Card per capability (name, one-liner, the tension it resolves, evidence links, diagram, codex:generate-image placeholder); one Story Page per phase (problem found → what shipped → numbers → PRs); tasks/subtasks appear as the Story Page's "receipts" list, auto-extracted from SUMMARY.md files. Every page carries the freshness footer.

## Plan sketch (for /gsd:plan-phase 37)

- 37-01: Showcase-site skeleton + IA (mkdocs-material, org Pages), Feature Card + Story Page templates, CTA/quickstart page ("run the four pilot scenarios").
- 37-02: `scripts/generate-marketing-pages.ps1` — .planning SUMMARY/VERIFICATION → story pages; runs in root CI report-only; verifier gate on claims.
- 37-03: Content pass — Feature Cards for the three planes + guardrails suite; Story Pages for phases 26-36; 11 LinkedIn drafts in `docs/marketing/linkedin/`; codex:generate-image placeholders throughout.
- 37-04: Adoption loop — quickstart validation on a clean machine, GitHub traffic/stars baseline capture script, "how to cite/share" page.

## Definition of done

- Showcase site live on Pages, generated pages green under the claim-verifier, one command regenerates everything, LinkedIn drafts ready for 11 phases, quickstart proven on a clean clone.
