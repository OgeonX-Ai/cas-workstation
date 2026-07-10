# Pilot-cadence evidence

Dated evidence artifacts produced by `scripts\run-pilot-cadence.ps1`
(REQ-1.5.4, Phase 40-01). Each run re-executes the four v1.0 loop pilot
scenarios plus the Phase 28 fault-injection suites in `portfolio\gsd-orchestrator`
and `portfolio\autogen`, from isolated worktrees pinned to `origin/main`, and
records the outcome here.

## Storage split

- **Dated summary JSON (this directory, git-committed):** small, structured
  pass/fail summary per run, mirroring the `evidence\compliance\snapshots\`
  precedent. Committed via a dedicated evidence worktree, a
  `evidence/pilot-cadence-{date}` branch, and a PR against `master` -- the
  runner never pushes directly to `master` and never touches the primary
  `C:\PersonalRepo` working tree's currently checked-out branch.
- **Full raw suite output (`scratch\pilot-cadence-logs\{date}\`, gitignored):**
  the complete, untruncated `dotnet test` / `pytest -v` / pilot-test output
  per suite, kept local-only to avoid bloating the tracked repo with verbose
  test-runner logs. One `{suite-id}.log` file per suite per run date.

## Schema (schemaVersion 1.0.0)

Each `{date}.json` file has the shape:

```json
{
  "schemaVersion": "1.0.0",
  "runDate": "2026-07-10",
  "startedAt": "2026-07-10T08:00:00Z",
  "finishedAt": "2026-07-10T08:04:12Z",
  "overallStatus": "passed",
  "suites": [
    {
      "id": "loop-pilots",
      "owningRepo": "OgeonX-Ai/cas-workstation",
      "status": "passed",
      "durationSeconds": 3.21,
      "commitSha": "abcdef1234..."
    }
  ],
  "issuesFiled": [
    {
      "suiteId": "gsd-orchestrator-fault-injection",
      "issueUrl": "https://github.com/Coding-Autopilot-System/gsd-orchestrator/issues/123",
      "deduped": false
    }
  ]
}
```

Field notes:

- `overallStatus` is `"passed"` only if every selected suite's `status` is
  `"passed"`; otherwise `"failed"`.
- Any suite entry with `status` not `"passed"` also carries a
  `failureExcerpt` field: the last 40 lines of that suite's captured output,
  with every literal occurrence of the local `-Root` path (e.g.
  `C:\PersonalRepo`) replaced with the literal string `<repo-root>` before
  storage, so no local filesystem path ever leaves the machine.
- `issuesFiled` is populated by `scripts\file-pilot-regression-issue.ps1`
  (invoked automatically for every non-green suite unless `-NoIssueFile` is
  passed) and records exactly what issue-filing action was taken for that
  run: a new issue (`deduped: false`) or a comment on an existing open issue
  with the same stable title (`deduped: true`). Absent or empty when every
  suite in the run passed.

## Suites

| Suite id | Owning repo |
|---|---|
| `loop-pilots` | `OgeonX-Ai/cas-workstation` |
| `gsd-orchestrator-fault-injection` | `Coding-Autopilot-System/gsd-orchestrator` |
| `autogen-fault-injection` | `Coding-Autopilot-System/autogen` |
