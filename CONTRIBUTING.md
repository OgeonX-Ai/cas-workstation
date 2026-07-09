# Contributing to CAS Workstation

Keep changes focused, reproducible, and safe for a Windows-first workstation
bootstrap repo.

## Local verification

Run the checks that match the change:

```powershell
pwsh -File scripts/workflow-lint.ps1 -Path .
python -m mkdocs build --strict
```

For script or bootstrap changes, also validate the affected entrypoint directly
instead of relying only on file diffs.

## Change standard

- Keep workstation automation deterministic and idempotent.
- Do not embed secrets, tokens, or machine-specific credentials.
- Prefer explicit Windows-native paths when integrating Windows tools.
- Update docs and runbooks when bootstrap or recovery behavior changes.
- Keep GitHub Actions pinned and least-privileged.

Pull requests should state the user-visible effect, exact verification commands,
and any deferred follow-up.
