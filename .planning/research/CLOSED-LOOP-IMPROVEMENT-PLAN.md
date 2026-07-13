# Closed-Loop System Improvement Plan

**Date:** 2026-07-13  
**Status:** Converged after four bounded independent review rounds  
**Scope:** `C:\PersonalRepo` local workstation and portfolio  
**Terminal claim:** No known material improvements remain within the declared inventory, evidence window, and acceptance thresholds.

## 1. Why the Current Convergence Claim Is Reopened

Round 4 proved that `vNEXT-SEEDS.md` v4 is internally consistent. It did not prove that
the system or the improvement process is complete. Fresh independent review found these
material gaps:

1. Active Priority-0 instructions simultaneously impose a local-only NO-AZURE lock and
   Azure/Foundry/Flex mandates.
2. `STATE.md` is semantically stale relative to the roadmap and completed artifacts.
3. Backlog convergence is based on added versus removed IDs and can be gamed by deletion,
   rename, formatting drift, or parser failure.
4. The telemetry expansion lacks a canonical schema, privacy boundary, redaction tests,
   migration rules, and safe storage policy.
5. DORA deployment and recovery metrics are undefined for the local-only runtime.
6. The existing auto-improver can report false health and has no immutable baseline,
   rollback, independent post-change verifier, or bounded escalation.
7. Collision leases are future work while the live workspace is already dirty from
   parallel activity.
8. Recorded coverage remains below the current immutable 100% multi-layer contract.

Therefore `PLAN_CONSISTENT` may be true for the seed document, but `ACCEPTED` is false.

## 2. Improvement Loop State Machine

`ADMIT -> BOOTSTRAP_CONTRACTS -> BOOTSTRAP -> BASELINE -> DISCOVER -> TRIAGE -> PRIORITIZE -> SPECIFY -> CHECKPOINTED -> IMPLEMENT -> SELF_REVIEW -> VERIFY -> RED_TEAM -> INTEGRATE -> OBSERVE -> LEARN -> CONVERGENCE_AUDIT -> ACCEPTED | BLOCKED_EXTERNAL | EXHAUSTED_INCOMPLETE | FAILED_VERIFICATION | ROLLBACK_PENDING -> ROLLBACK_VERIFICATION -> ROLLED_BACK | ROLLBACK_FAILED`

Rules:

- Return to the earliest causal state after a failed gate.
- Allow at most three repair attempts for the same verifier failure.
- Allow at most four convergence rounds per approved phase.
- Budget exhaustion is `EXHAUSTED_INCOMPLETE`, never success.
- New evidence, incidents, dependency changes, scheduled surveys, or guardrail regression
  reopen an accepted loop.
- Any post-mutation gate failure stops new mutation and enters `ROLLBACK_PENDING`.
- Rollback is attempted once from the pinned checkpoint. Failure to restore or verify the
  complete subject fingerprint terminates as `ROLLBACK_FAILED`.
- `ROLLBACK_VERIFICATION --pass--> ROLLED_BACK`; it emits an immutable recovery verdict,
  reopens the originating finding, invalidates the consumed checkpoint and all downstream
  evidence, charges the failed attempt against the three-attempt budget, releases the old
  lease, and returns through a new run/lease/baseline to the earliest causal non-mutating
  state. `ROLLBACK_VERIFICATION --fail--> ROLLBACK_FAILED`; no mutation resumes.

## 2.1 Normative Decisions for Unattended Execution

These defaults remove policy questions from execution:

1. The active workspace profile is **LOCAL_ONLY**. The root NO-AZURE lock governs current
   execution; Azure/Foundry/Flex statements are dormant conditional constraints until the
   operator explicitly activates a future cloud profile. No cloud, credential, deployment,
   or GitHub App action is in autonomous scope.
2. The current 100% unit/smoke/regression/E2E coverage standard remains authoritative. It
   is not waived or replaced by this plan. Any gap is an open implementation candidate.
   Non-executable policy/docs artifacts use schema, lint, mutation, and scenario coverage
   instead of fabricated code coverage.
3. Human acceptance is `NOT_APPLICABLE` unless the selected SDLC profile or a named
   requirement explicitly marks it `REQUIRED`. Missing required external evidence yields
   `BLOCKED_EXTERNAL`; it is never inferred or silently skipped.
4. Current unrelated dirty changes are preserved. No mutation begins until its exact paths
   are leased and its verifier subject fingerprint excludes or explicitly includes those
   changes.
5. The only lease exception is Phase -2/0A bootstrap: one root orchestrator, no delegated
   writers, and one fixed schema directory may create the lease authority itself under an
   OS-exclusive bootstrap lock. After the first valid fenced lease is issued, the exception
   permanently expires for that run.

## 3. Independent Agent Roles

| Role | Authority | Forbidden action |
|---|---|---|
| Orchestrator / architect | Scope, profile, budgets, dependency graph, synthesis, state transitions | Terminal self-certification |
| Systems analyst | Read-only evidence discovery and requirements derivation | Mutation |
| Mutation owner | One writer for one declared repo/path/worktree scope | Verifying own terminal acceptance |
| QA verifier | Reproduction, regression, negative, recovery, and evidence checks | Editing while issuing verdict |
| Strict critic | Falsification, security, Goodhart, omission, and unsafe-default attacks | Waiving blocking evidence |
| Integration owner | Branch, remote, clean integration, and release validation | Integrating an unverified moving target |
| Adjudicator | Resolve verifier/worker/critic disagreement from evidence | Waive immutable or failed terminal gates |
| Operator | External credentials, destructive actions, policy exceptions, human acceptance | Waiving immutable safety, identity, secret-handling, evidence-integrity, or terminal-verifier gates |

Verifier and critic prompts must be fresh-context and pinned to immutable commit/evidence
identifiers. Critical scope requires two heterogeneous critics using different attack
inventories before adjudication.

## 4. Required Contracts and Evidence

Create versioned, schema-validated records under
`C:\PersonalRepo\.planning\improvement-loop\`:

- `RUN-<id>.json`: scope, profile, budget, owners, branches, base SHAs, paths, and TTLs.
- `BASELINE-<timestamp>.json`: probes, raw results, provenance, freshness, blind spots.
- `CANDIDATES-<timestamp>.json`: stable ID, severity, evidence, falsifier, owner, status.
- `SCORECARD-<id>.json`: raw dimensions, eligibility, rank, sensitivity result.
- `VERIFICATION-<id>.json`: pinned subject, commands, results, hashes, skipped gates.
- `REDTEAM-<id>.json`: attack inventory, findings, reproduction, disposition.
- `CONVERGENCE-<id>.json`: coverage inventory, round deltas, remaining risks, verdict.
- `ADJUDICATION-<id>.json`: immutable decision over disagreements, severity changes,
  exclusions, recovery, and acceptance, including competing evidence and authority basis.

The canonical schemas live under
`C:\PersonalRepo\engineering-os\schemas\improvement-loop\`. Every record contains
`schema_version`, `run_id`, `record_id`, `created_at`, `actor_id`, `actor_session_id`,
`parent_actor_id`, `ancestry_digest`, `provider`, `model_version`, `role`, `parent_run_id`,
`context_digest`, `isolation_digest`, `subject_digest`, `tool_scope`, and
`mutation_capability`.

Actor identity fields are not caller assertions. A trusted local launcher outside the
worker-controlled evidence tree issues an `AUTHORITY-ATTESTATION` binding identity, role,
process/session ancestry, capability, run, and subject. It is authenticated with an
OS-protected signing key. Validation rejects unknown/revoked issuers, replay, lineage
overlap, capability escalation, post-verdict signatures, and self-issued attestations.
The signer runs outside worker trust under a distinct restricted Windows SID, or uses a
TPM/CNG-backed non-exportable key whose private operation is inaccessible to workers.
Worker SIDs are explicitly denied key access. A narrow authenticated signing API accepts
only canonical authority/verdict records and binds exact schema version, run, subject,
role, capability, nonce, issued/expiry times, and caller attestation; arbitrary payload
signing is forbidden. Key custody includes least-privilege ACLs, rotation, revocation, and
a compromise-recovery procedure that invalidates affected verdicts. Negative tests prove
workers cannot read/export the key, impersonate the signer, replay a signature, or obtain a
signature outside their attested capability/confused-deputy boundary.

`RUN`, `CANDIDATES`, and `SCORECARD` are mutable checkpoints updated through atomic
compare-and-swap. Terminal `VERIFICATION`, `REDTEAM`, and `CONVERGENCE` records are
content-addressed, hash-linked to their parents, commit-pinned, and append-only after
issuance. A changed artifact hash or broken parent chain invalidates acceptance.
`ADJUDICATION` and recovery verdicts use the same terminal immutability rules.

The subject fingerprint includes repository SHA, target branch, dirty-state digest,
allowlisted untracked-input hashes, nested repository/submodule SHAs, lockfile hashes,
relevant tool versions, active policy/profile digest, configuration hashes, verifier
version, and evidence-schema version.

JSON is canonicalized before hashing: UTF-8, normalized field names, deterministic ordering,
and an explicit numeric representation. Duplicate keys, unknown fields, implicit coercion,
unsupported versions, non-canonical encodings, and downgrade are rejected. A signed schema
registry dispatches validators by exact version. Terminal evidence is never migrated in
place; a `MIGRATION` record links old bytes/validator digest, transformation digest, new
bytes/validator digest, and an independent compatibility verdict. Pinned validators remain
runnable for every accepted terminal version.

`RUN` also freezes outcome target IDs, baseline source, direction, minimum delta, tolerance,
sample/window, and paired guardrail thresholds before `BASELINE`. Missing or changed targets
make the run `INVALID`.

Telemetry is never acceptance evidence. Raw prompts, reasoning, secrets, tokens, and unsafe
tool arguments must not be stored. Producers validate an allowlisted telemetry schema and
fail closed on invalid events.

## 5. Candidate Admission and Priority

A candidate is eligible only when it has a reproducible symptom, reliable source, or
explicitly labeled falsifiable hypothesis. Hard safety, authority, dependency, freshness,
and collision gates run before scoring.

For eligible items:

`priority = .25 outcome value + .20 risk reduction + .15 evidence confidence + .15 dependency leverage + .10 urgency + .10 reversibility + .05 learning value - .15 effort - .10 blast radius`

All inputs are normalized to 0..100 and retained beside the score. The score cannot
override safety, an external blocker, or current-milestone dependencies. Select the
smallest dependency-complete batch and reserve capacity for one unplanned high-severity
defect.

Severity is schema-derived from impact, likelihood/exploitability, blast radius,
recoverability, recurrence, and authority-boundary violation:

| Severity | Deterministic rule |
|---|---|
| Critical | Safety/secret/identity compromise, destructive loss, forged acceptance, or irreversible cross-portfolio impact |
| High | Terminal-state, collision, rollback, or evidence-integrity failure affecting one or more managed repositories |
| Medium | Reproducible outcome or guardrail regression with bounded recovery and no authority breach |
| Low | Localized maintainability/usability issue with no current outcome or guardrail breach |

Critical/High/Medium classifications require independent verifier confirmation. Any
downgrade requires an append-only adjudicator decision with old/new severity, evidence,
rationale, risk owner, and expiry.

The score range is `-25..100`. Missing dimensions make the score `INVALID`; ties resolve by
severity, dependency leverage, recurrence, then stable candidate ID. Eligible execution
threshold is 40, except all Critical/High items remain eligible regardless of score. Rank
must remain stable under +/-5 points on any single estimated dimension or the item requires
adjudication.

## 6. Execution Plan

### Phase -2 - Read-Only Pre-Admission

1. Enumerate managed surfaces and current SHAs entirely in memory; do not create planning
   artifacts or modify the workspace.
2. Acquire one OS-exclusive bootstrap lock for
   `C:\PersonalRepo\engineering-os\schemas\improvement-loop`. Record launcher process,
   Windows identity SID, boot/session ID, fixed path scope, start time, and expiry in the
   tracer. No child writer is allowed.
3. Create and test the Phase 0A minimal schemas and fenced lease authority as the first and
   only bootstrap mutation. If the directory or lock is already owned, stop with
   `BLOCKED_EXTERNAL`; never guess ownership.

**Exit gate:** first schema-valid fenced lease exists; bootstrap lock is released; bootstrap
exception is disabled; all later mutation requires the lease.

### Phase -1 - GSD Admission and Frozen Inventory

1. Reconcile the current v1.5 lifecycle read-only, then register this initiative as the
   next available milestone/phase sequence without rewriting incomplete v1.5 truth.
2. Add stable requirements `CLI-001` through `CLI-012` to the new milestone requirements,
   add roadmap phases, select the `critical` SDLC profile for contracts/controller/pilot
   and `standard` for read-only baseline tooling, and generate requirement-linked PLAN files.
3. Generate `INVENTORY-v1.json` from `stack.manifest.json`, root and nested Git repositories,
   engineering-os policies/schemas/personas, `.planning` truth, Windows scheduled tasks,
   runtime controllers, telemetry/evidence stores, and declared external dependencies.
4. Pin the inventory hash. Every exclusion requires surface, reason, risk owner, expiry,
   and adjudicator approval. Removing a managed surface invalidates acceptance.

**Exit gate:** GSD health passes; every `CLI-*` requirement maps to a roadmap phase and
plan; inventory enumeration matches managed surfaces and exclusion schema; inventory hash
is recorded in the run manifest.

### Phase 0A - Bootstrap Contracts (executed inside Phase -2 bootstrap scope)

1. Define and schema-test minimal `RUN`, `LEASE`, `POLICY-DECISION`, `VERDICT`, `BLOCKER`,
   and `SUBJECT-FINGERPRINT` contracts before any enforcement mutation.
2. Implement a validator CLI that fails closed on unknown schema versions, missing fields,
   broken hash chains, actor-lineage conflicts, malformed timestamps, or incomplete subjects.
3. Implement a single-writer bootstrap lease using atomic create/compare-and-swap, including
   repo, worktree, branch, base SHA, paths, TTL, mutation owner, verifier, integration owner,
   and crash-recovery owner.
4. Add `AUTHORITY-ATTESTATION`, `EXECUTION-SPEC`, and signed schema-registry contracts.
5. Leases use a monotonically increasing fencing token, launcher boot/session ID, monotonic
   acquisition/deadline values, wall-clock audit values, and explicit suspend/restart rules.
   Every write/CAS presents the current token; stale tokens are rejected. Reboot invalidates
   all leases and requires recovery adjudication.

**Exit gate:** schema fixtures, collision fixtures, expired-lease fixtures, lineage fixtures,
and artifact-tampering fixtures all fail closed.

### Phase 0B - Fail-Closed Preconditions

1. Record current dirty files, worktrees, branches, remotes, base SHAs, and mutation owners.
2. Reject writer fan-out until the lease contract is enforced; verifiers reject dirty or
   drifted subjects.
3. Reconcile the NO-AZURE lock with active canonical/project Azure mandates. Move future
   cloud requirements to a dormant profile activated only by explicit operator authority.
4. Derive and repair `STATE.md` from roadmap plus immutable artifacts; add monotonicity and
   single-writer/CAS verification.
5. Preserve the 100% coverage contract and inventory every current coverage gap as an open
   finding. Do not authorize a ratchet or waiver in unattended execution.
6. Emit an authenticated, nonce-bearing, single-use `POLICY-DECISION` for `LOCAL_ONLY` with
   exact scope/profile digests, issuer, reason, issued/not-before/expiry times, and approvals.
   Default-deny missing, expired, replayed, ambiguous, or broader authority. Activation uses
   a distinct command followed by policy lint; protected gates cannot be waived.

**Exit gate:** instruction contradiction lint passes; planning-state verifier passes;
collision ownership is active; coverage policy has one enforceable meaning.

### Phase 1 - Improvement Ledger and Evidence Integrity

1. Define schemas for findings, ownership leases, verifier verdicts, critic verdicts,
   typed blockers, budgets, and convergence.
2. Replace ID-count convergence with lifecycle-aware closure evidence.
3. Fail closed on malformed, missing, renamed, split, merged, downgraded, or silently
   removed findings.
4. Add provenance fields: source, repo, branch/SHA, captured time, TTL, verifier identity,
   closure evidence, reopen history, risk owner, and deferral trigger.
5. Define record state transitions, stable ID generation, referential integrity, schema
   migration, retention, and atomic write/CAS rules.
6. Model mutable records as projections over an append-only event log. Every CAS appends old
   digest, new digest, fencing token, authenticated actor, reason, and timestamp. Replay must
   reproduce the projection exactly.

**Exit gate:** deletion/rename/parser-error fixtures cannot manufacture convergence.

### Phase 2 - Safe Baseline and Discovery

1. Build a Windows-first read-only baseline runner composing workspace health, planning
   consistency, tests, contracts, docs/code drift, dependencies, security, performance,
   release/pilot evidence, and telemetry validation.
2. Define the bounded search inventory and coverage matrix before discovery starts.
3. Seed known defects across reliability, security, performance, usability, documentation,
   cost, and collision domains; enforce a predeclared discovery-recall threshold.
4. Distinguish `UNKNOWN` from healthy whenever a probe is unavailable or malformed.

The mandatory discovery inventory cannot shrink below: governance/instructions, planning
truth, source and tests for every managed repository, dependency/supply chain, security and
privacy, reliability/recovery, performance/resource bounds, usability/operator flow,
documentation drift, automation/schedulers, telemetry/evidence integrity, cost, and
collision/integration safety.

Discovery acceptance is 100% recall for hidden Critical/High seeds, at least 90% overall
seed recall, and no more than 10% false positives. QA owns a hidden versioned seed manifest;
discovery actors receive only the domain inventory. Seeds rotate after each accepted run.
Active seeds live outside actor-readable workspace scope under separate ACLs, are injected
by an independent harness, and are revealed only after the actor result is immutable. A
pre-run seed-manifest hash proves custody; exposure makes the run `INVALID`.

**Exit gate:** the runner detects seeded defects, invalidates stale evidence, and never
converts a probe error into health.

### Phase 3 - Bounded Auto-Improvement Controller

1. Refactor `C:\PersonalRepo\portfolio\autogen\scripts\auto_improver_loop.py` into a typed bounded state machine with immutable before/after
   artifacts, fixed evaluations, rollback, idempotency, budgets, and audit trail.
2. Require a failing reproduction before defect repair.
3. Enforce one mutation owner and an independent pinned verifier.
4. Trigger the circuit breaker after three failures and emit a typed blocker.
5. Execute every verifier through `EXECUTION-SPEC`: absolute executable path and opened-image
   hash/signature, script/module hashes, structured argv, allowlisted environment, Windows
   cwd, timeout/resource limits, expected outputs, and prohibited shell mode. Disallow PATH
   lookup, command-string concatenation, `cmd /c`, `powershell -Command`, unvalidated response
   files, and inherited secret-bearing environment variables.

**Exit gate:** mutation tests kill false-health, verifier-bypass, stale-SHA, lease-bypass,
and budget-as-success mutations.

### Phase 4 - Metrics That Cannot Lie

1. Define the local delivery unit and failure/recovery lifecycle before using DORA labels.
2. If deployment semantics do not exist, label the measures engineering-flow proxies.
3. Version telemetry schema v2 with allowlisted fields, producer validation, redaction,
   migration, retention, and sanitized/non-git storage boundaries.
4. Pair speed/cost measures with safety, quality, reliability, rollback, reopen, and escaped
   defect guardrails.

**Exit gate:** exact calculation fixtures pass; secrets/raw reasoning are rejected; metric
definition changes are audited; improving a score cannot hide a guardrail regression.

### Phase 5 - Pilot, Red Team, and Convergence

1. Pilot on one deterministic local issue, preferably planning-state drift or false-health
   behavior; exclude operator-blocked credentials and GitHub App creation.
2. Run: independent fact-check -> implementation -> QA verification -> strict red team ->
   adjudication -> scheduled stability observation.
3. Repeat discovery with fresh-context heterogeneous critics across the frozen inventory.
4. Publish blind spots, freshness, raw results, finding lifecycle, and disagreement outcomes.

Observation uses two isolated immediate reruns plus **two** real scheduled invocations. Each
scheduled invocation occurs 24 to 48 hours after the preceding accepted run when the
requirement is time-dependent. Each run has a distinct ID,
fresh subject fingerprint, process restart, dependency refresh, and monotonic deadline.
A missed deadline yields `EXHAUSTED_INCOMPLETE`; it never waits indefinitely or reuses the
last green result.

**Exit gate:** pilot closure survives clean-clone/reproduction/regression/rollback checks;
both scheduled observation invocations remain green; a seeded regression reopens the loop within
one cycle.

## 7. Anti-Gaming Tests

- Delete or rename ten open findings: verdict must be `INVALID`.
- Insert one malformed High finding: verdict must be `UNKNOWN` and fail closed.
- Downgrade, defer, split, merge, or duplicate findings: score cannot improve without an
  audited disposition.
- Change the evaluated branch SHA or expire TTL: prior acceptance invalidates.
- Let worker and verifier share mutable context: independence gate fails.
- Exhaust time, token, or cost budget: result is `EXHAUSTED_INCOMPLETE`.
- Make a workspace dirty after baseline: pinned verification refuses the moving target.
- Disable a verifier: acceptance remains blocked rather than skipped.
- Shrink the inventory to one file or remove a managed repository: acceptance invalidates.
- Rewrite a failed terminal evidence record to passed: its hash chain fails.
- Label an authority/evidence breach Low: severity validation fails.
- Use a worker descendant as verifier or identical critic lineages: independence fails.
- Follow a junction from the restricted evidence root into Git: containment fails.
- Forge or replay an actor/policy attestation: authentication fails.
- Use duplicate JSON keys, coercion, an old schema, or parser-differential input: validation fails.
- Hijack PATH, script content, environment, response files, or shell arguments: execution fails before launch.
- Roll back the clock, reboot, or resume a stale lease owner: fencing rejects every write.
- Crash between two repository integrations: recovery journal deterministically completes or compensates.

## 7.1 Gate Applicability Matrix

Before implementation, every requirement/risk maps to a gate with status `REQUIRED` or
`NOT_APPLICABLE`. An N/A entry must cite the profile rule, evidence, risk owner,
compensating verifier, and expiry; a skipped required gate needs a schema-valid override
and cannot waive safety, identity, secrets, terminal verification, or critical acceptance.

| Change class | Minimum required gates |
|---|---|
| Policy/schema | schema, lint, backward/forward compatibility, mutation, scenario, security |
| Script/controller | unit, integration, smoke, regression, E2E, security, recovery, rollback, coverage |
| Telemetry/evidence | schema, privacy/redaction, tamper, retention, migration, recovery |
| Cross-repo/integration | native suites, contract, clean snapshot, compare-and-swap integration, post-integration rerun |
| Documentation only | link/schema/lint, claim-to-evidence validation, rendered smoke where applicable |

## 7.2 Evidence Freshness and Storage

| Evidence class | Maximum age |
|---|---|
| Local deterministic test at pinned subject | 24 hours |
| Dirty/worktree/inventory snapshot | 15 minutes |
| Remote branch/PR/protection state | 30 minutes |
| Dependency/security scan | 24 hours |
| Scheduled stability observation | Its declared 24-48 hour window |

Any subject, schema, verifier, profile, dependency-lock, or inventory change invalidates the
related evidence immediately. Missing/untrusted timestamps produce `UNKNOWN`.

Sanitized summaries and hashes may be committed. Restricted raw artifacts live outside Git
under `C:\Users\KimHarjamaki\AppData\Local\CAS\evidence\<run-id>`, use atomic writes,
least-privilege ACLs, canonical-path containment with junction/symlink rejection, encryption
at rest, and a 30-day retention verifier. Redaction occurs before any persistence, including
temporary files; only command templates and redacted argument classes are retained.

Windows containment is handle-based, not string-based: open ancestors and destination with
no-follow semantics, reject every reparse tag and non-regular stream, resolve the final path
from the opened handle, verify volume/file identity and root ancestry immediately before
commit, prohibit hard links/ADS/device paths/8.3 aliases, create exclusively with restrictive
ACLs, and rename atomically only within the same verified directory handle.

The evidence data-flow inventory enumerates stdout/stderr, traces, terminal transcripts,
exceptions, crash dumps, test snapshots, temp directories, scheduler history, child logs,
indexing/AV exposure, and rollback paths. Child output passes through bounded in-memory
redaction; transcript/debug/dump sinks are disabled or sanitized; private per-run temp uses
the same containment policy. Canary scans cover success, failure, timeout, crash, schedule,
and rollback. DPAPI keys never coexist beside ciphertext.

## 7.3 Checkpoint, Rollback, and Integration Contract

Every mutating phase declares reversibility class, pre-change checkpoint, rollback or
forward-recovery command, destructive-boundary approval, and post-recovery verifier before
mutation. A checkpoint covers tracked files, permitted untracked inputs, generated state,
branch/SHA, nested repositories, and external-state manifest. User-owned dirty files are
never overwritten or rolled back.

The rollback transition table is exhaustive: restore failure or fingerprint mismatch enters
`ROLLBACK_FAILED`; verified restoration enters `ROLLED_BACK` and requires a new run, lease,
baseline, and checkpoint before any retry. Tests delete or invert each transition and must
detect stranded, resumed-without-baseline, reused-checkpoint, and uncharged-attempt states.

Integration pins the candidate SHA and target SHA, uses compare-and-swap, reruns terminal
verification on the integrated SHA, and invalidates prior evidence if the target advances.
A later stability regression triggers a revert plan and reopens the finding; irreversible
external changes remain out of autonomous scope.

Cross-repository integration uses an append-only `INTEGRATION-TRANSACTION` journal with
transaction ID, ordered participants, before/candidate/target SHAs, generated/external state,
prepare/commit status, compensating action, recovery owner, fencing token, and idempotency
key. Use prepare-then-commit where possible and a tested saga otherwise. Restart detects an
incomplete transaction, blocks mutation, and deterministically completes or compensates.
Terminal verification covers the aggregate portfolio fingerprint after integration and
recovery; crash injection exercises every transition and compensation failure.

## 7.4 Phase Dependency and Ownership Matrix

| Phase | Requires | Produces | Mutation scope | Entry/exit authority |
|---|---|---|---|---|
| -2/0A | Read-only enumeration and OS-exclusive bootstrap lock | Minimal schemas, isolated-signer launcher attestations, fenced lease | `engineering-os/schemas/improvement-loop`, validator tests | Root orchestrator only / QA verifier after lease issuance |
| -1 | Valid fenced lease and pre-admission enumeration | GSD requirements/roadmap/plans, frozen inventory | `.planning` new-milestone artifacts only | Orchestrator / planning verifier |
| 0B | Valid 0A contracts and lease | Active policy decision, truthful state, coverage findings | Root governance and `.planning/STATE.md` declared paths | Policy owner / independent critic |
| 1 | 0B green | Full ledger/evidence contracts | Schema and validator paths only | Contract owner / QA verifier |
| 2 | Phase 1 schemas | Baseline runner, seed corpus, coverage report | Root scripts/tests and restricted QA fixtures | Script owner / QA verifier |
| 3 | Phases 1-2 green | Bounded controller and tests | `portfolio/autogen` isolated Windows worktree | Python owner / separate QA verifier |
| 4 | Canonical evidence events | Metrics definitions, telemetry v2, privacy tests | Declared telemetry producers/consumers sequentially | Per-repo owners / privacy critic |
| 5 | All prior exits green | Pilot evidence, red-team verdicts, convergence record | One leased pilot scope, then append-only evidence | Pilot owner / two critics / adjudicator |

No phase starts until every required input artifact validates. A changed input hash reopens
the earliest producing phase.

## 8. Terminal Acceptance Contract

`ACCEPTED` requires all of the following:

1. Declared bounded search inventory, risk profile, budgets, and evidence horizon.
2. Schema-valid finding ledger with zero unresolved Critical, High, or Medium items.
3. Every Low/deferred item completed, evidence-rejected, or owned with trigger and expiry.
4. Independent QA verifier passes all applicable functional, integration, smoke,
   regression, E2E, security, performance, recovery, rollback, and UAT gates.
5. Two heterogeneous fresh-context critics and the adjudicator report no unresolved
   material disagreement.
6. Evidence is fresh, provenance-bearing, commit-pinned, clean, and collision-safe.
7. Required human/external acceptance is recorded, not inferred.
8. Two scheduled stability cycles pass and seeded-regression detection is proven.
9. Immutable pre-baseline `RUN` target IDs meet their minimum delta/tolerance over the
   declared sample/window without any paired guardrail threshold regression.
10. The frozen inventory has not shrunk and every exclusion remains valid.
11. Terminal evidence hash chains, actor independence, and subject fingerprints validate.

The system must never claim global perfection. The only defensible completion statement is:

> No known material improvements remain within the declared inventory, evidence window,
> and acceptance thresholds.

## 9. Immediate Ordered Backlog

1. Governance contradiction lint and active-profile normalization.
2. Generated/validated planning state with monotonicity and ownership.
3. Collision lease enforcement before further writer fan-out.
4. Schema-backed finding ledger and fail-closed convergence calculation.
5. Auto-improver false-health regression and bounded controller contract.
6. Telemetry privacy/schema boundary and local delivery metric definitions.
7. Coverage-contract decision and enforcement.
8. One bounded pilot followed by independent verification and two-cycle observation.

## 10. Requirement and Verifier Map

| Requirement | Deliverable | Primary falsifier |
|---|---|---|
| CLI-001 | GSD admission and frozen inventory | Removing a managed surface invalidates acceptance |
| CLI-002 | Minimal bootstrap schemas and validator | Malformed/tampered record is accepted |
| CLI-003 | Collision lease and subject fingerprint | Second writer or drifted verifier subject passes |
| CLI-004 | Single active local-only policy | Contradictory active constraint survives lint |
| CLI-005 | Truthful generated planning state | State regresses or disagrees with artifacts |
| CLI-006 | Lifecycle-aware finding ledger | Delete/rename/downgrade manufactures closure |
| CLI-007 | Safe discovery baseline | Hidden Critical/High seed is missed or probe error is healthy |
| CLI-008 | Bounded auto-improver controller | False health, bypass, or rollback failure is accepted |
| CLI-009 | Privacy-safe evidence and telemetry | Canary secret reaches any persisted artifact |
| CLI-010 | Honest outcome/guardrail metrics | Score improves while a guardrail regresses |
| CLI-011 | Independent verification and red team | Same lineage self-certifies or identical critics pass |
| CLI-012 | Bounded convergence and observation | Missing deadline, stale evidence, or inventory shrink yields ACCEPTED |

Each PLAN file must include exact command, Windows cwd, prerequisites, timeout, expected exit
code/output schema, evidence path, applicability rule, rollback command, and post-rollback
verification. Commands are finalized only after the owning module and its nearest context
chain are loaded; placeholder commands cannot satisfy plan readiness.

Operator-created credentials, GitHub App installation, elapsed calendar windows, and any
Azure/cloud action remain explicit external blockers and cannot be optimized away.

## 11. Plan Convergence Record

| Round | Result | Material findings closed |
|---|---|---|
| 1 | Rejected | Policy contradiction, stale state, gameable convergence, telemetry/privacy, local metrics, false-health controller, collisions, coverage contradiction |
| 2 | Rejected | Inventory shrinkage, severity gaming, mutable evidence, GSD admission, gate applicability, dependency/ownership/rollback gaps |
| 3 | Rejected | Bootstrap cycle, observation count, Critical threshold, target freezing, authenticated lineage, schema downgrade, Windows containment, command integrity, secret sinks, cross-repo recovery, lease fencing |
| 4 | Passed after repair | Isolated signer trust boundary, successful rollback transition, immutable adjudication record |

Final independent results:

- Plan adjudicator: `PASS`; executable without material user questions.
- Strict verifier: all Round 3 items closed; final rollback/adjudication repair `PASS`.
- Security critic: all eight Round 3 attack classes covered; isolated-signer repair `PASS`.
- Mechanical validation: Markdown whitespace check passes.

This is plan convergence, not implementation completion. Execution must still create and
verify the `CLI-001` through `CLI-012` GSD artifacts and may only claim system acceptance
under Section 8.
