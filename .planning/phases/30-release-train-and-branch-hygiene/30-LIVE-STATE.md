# Phase 30 — Live GitHub State (captured 2026-07-06, post-260706-h8b)

Ground truth from `gh pr list` with statusCheckRollup. Supersedes the PR-count table in 30-CONTEXT.md where they differ.

## Open PRs: 16 total — 13 GREEN (merge), 3 RED (report only)

### GREEN — merge in the train
| PR | Head branch | Author | Checks |
|---|---|---|---|
| .github#10 | dependabot/github_actions/all-917ae20de1 | dependabot | SUCCESS |
| Promptimprover#26 | feat/swarm-dashboard | OgeonX-Ai (self) | SUCCESS |
| Promptimprover#24 | dependabot/github_actions/all-3b1b51a774 | dependabot | SUCCESS |
| autogen#8 | dependabot/github_actions/all-917ae20de1 | dependabot | SUCCESS |
| autopilot-core#11 | dependabot/github_actions/all-917ae20de1 | dependabot | SUCCESS |
| autopilot-demo#6 | dependabot/github_actions/all-2bc38483be | dependabot | SUCCESS |
| cas-evals#6 | dependabot/github_actions/all-917ae20de1 | dependabot | SUCCESS |
| cas-reference-product#8 | dependabot/github_actions/all-647601dc5e | dependabot | SUCCESS |
| cas-workstation#15 | dependabot/github_actions/all-08fce1d646 | dependabot | NEUTRAL+SUCCESS |
| cas-workstation#7 | ai-engineering-operating-system | OgeonX-Ai (self) | SUCCESS |
| ci-autopilot#2201 | dependabot/github_actions/all-3d49d62a9f | dependabot | SUCCESS |
| cloud-security-service-model#9 | dependabot/github_actions/github-actions-e687ec2065 | dependabot | NEUTRAL+SUCCESS |
| gsd-orchestrator#13 | dependabot/github_actions/all-e2466edea9 | dependabot | SUCCESS |

### RED — do NOT merge; report with failing-check names
| PR | Head branch | Why |
|---|---|---|
| autogen#6 | dependabot/pip/all-4ee7069966 | FAILURE in checks |
| cas-contracts#13 | dependabot/github_actions/all-39e064e4a3 | FAILURE in checks |
| gsd-orchestrator#10 | dependabot/nuget/.../all-743cde0268 | FAILURE in checks |

## Corrections to prior assumptions (VERIFIED via git diff origin/<default>...HEAD)

1. **EVERY parked local branch carries real unmerged content and has NO open PR.** The squash-merge theory is FALSE — measured divergence vs default branch:

| Repo (branch) | Ahead | Diff vs default |
|---|---|---|
| gsd-orchestrator (ci/dependabot-github-actions) | 9 | 31 files, +626/-37 (incl. today's test suite afa28ab) |
| autogen (ci/dependabot-github-actions) | 8 | 27 files, +483/-25 (incl. today's test suite db1c818, 43bbedc) |
| cas-reference-product (ci/phase-09-workflow-hardening) | 5 | 13 files, +16/-4 |
| autopilot-core (chore/governance-hardening) | 2 | 11 files, +32 |
| cas-evals (chore/governance-hardening) | 2 | 6 files, +39/-4 |
| autopilot-demo (chore/governance-hardening) | 1 | 2 files, +4 |
| cas-platform (chore/governance-hardening) | 1 | 4 files, +17 |
| cas-workstation (chore/governance-hardening) | 1 | 1 file, +1 |
| ci-autopilot (chore/governance-hardening) | 1 | 10 files, +28 |
| cloud-security-service-model (chore/governance-hardening) | 1 | 5 files, +18 |
| org-dotgithub (chore/governance-hardening) | 1 | 4 files, +17 |
| cas-contracts (fix/pages-release-ordering) | 1 | 1 file, +10 |
| Promptimprover (master, local) | 1 | 5 files, +179 (same content as PR #26 — do NOT open another PR; reset after #26 merges) |

**Implication for the plan:** the train has TWO streams per repo: (a) merge the existing green dependabot/self PRs, and (b) OPEN new PRs for each parked local branch above (except Promptimprover) and merge them through the train. Where a repo has both (gsd-orchestrator, autogen: dependabot PR + parked branch touching the same .github/workflows/ci.yml), merge the dependabot PR FIRST, then `gh pr update-branch` the parked-branch PR and resolve ci.yml keeping BOTH changes.
2. All parked branches are pushed to origin EXCEPT verify each with `git rev-list --count @{u}..HEAD` before opening PRs (push first if ahead of upstream).
3. Only after a repo's parked-branch PR merges: `git switch <default> && git pull --ff-only && git branch -d <branch>`.
