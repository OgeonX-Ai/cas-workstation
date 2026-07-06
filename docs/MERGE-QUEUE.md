# Merge Queue — round 2 (2026-07-06 evening)

Round 1 (Phase 30 train: 25 PRs) is fully merged — thank you. This is the live queue for
phase-work PRs the agents are producing. Same rule applies: the agent session cannot
self-approve+merge; these need you.

## Ready now (rescued stranded commits — small, reviewed diffs)
```powershell
gh pr merge 18 --repo Coding-Autopilot-System/cas-workstation --squash --delete-branch --admin
gh pr merge 11 --repo Coding-Autopilot-System/cas-reference-product --squash --delete-branch --admin
gh pr merge 27 --repo Coding-Autopilot-System/Promptimprover --squash --delete-branch --admin
```

## Incoming (agents executing now — check with the command below)
- Phase 26: `feat/phase-26-coverage-gates` PRs in gsd-orchestrator and autogen (coverage gates + tests)
- Phase 32: `feat/phase-32-registry-publishing` PR in cas-contracts (+ consumer job in cas-evals)
- Phase 33: bicep hardening PRs in cas-platform (may reuse Gemini's `fix/bicep-lint-api-version-pinning`) and cloud-security-service-model
- Phase 31: per-repo workflow-hardening PRs (SHA pins, permissions, CodeQL) — dispatched after 26/32/33 land to avoid ci.yml collisions

```powershell
gh search prs --owner Coding-Autopilot-System --state open --json repository,number,title
```

## After merging a batch
Local checkouts: `git switch <default> && git pull --ff-only` per repo, or ask the agent to normalize.
Post-merge: local `main` in gsd-orchestrator / cas-workstation / cas-reference-product and `master`
in Promptimprover still carry the pre-rescue stranded commits — safe to `git reset --hard origin/<default>`
AFTER the rescue PRs merge (content verified identical).
