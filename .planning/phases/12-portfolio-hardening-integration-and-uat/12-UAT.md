---
status: passed
phase: 12
updated: 2026-07-05
---

# Phase 12 UAT

## Passed automatically

- Repository-native builds, tests, linters, and contract checks.
- Offline registry generation, manifest digests, and consumer compatibility.
- Live drift workflows are installed in both v1.1 consumers.

## Release validation passed

1. All 13 v1.1 portfolio PRs were merged.
2. `v1.1.0` was published; review then identified an identity/hosting coupling
   defect without rewriting that immutable release.
3. Corrective `v1.1.1` was tagged and published with canonical schema IDs.
4. Pages serves `/registry/releases/v1.1.1/manifest.json`; stable `/registry/v1.1/`
   resolves to `1.1.1`.
5. Autogen live drift run `28734067301` passed.
6. GSD Orchestrator live drift run `28734067953` passed.

## Merge evidence

| Repository / PR | Merge SHA |
|---|---|
| autogen #9 | `24dcd0885b704b57c57d23e3edd386e84ae32913` |
| cas-contracts #14 | `f455d74cf63f2dd2a66aff23542be3337dbdc3a4` |
| cas-reference-product #9 | `2481c6ab70ab3de7680e3dda21966ba2602f991d` |
| cas-evals #7 | `801fe143c8a001ec36f185a167bca65134a90ac4` |
| gsd-orchestrator #14 | `126dab10dc8b659578e4b6c104e14ef10eebfc21` |
| autopilot-core #13 | `ec1cb12a09463266bd584faeadc3ad73545d7766` |
| autopilot-demo #7 | `d590fe12a3c8613ebaf22ab955f8eab933ccd221` |
| cas-platform #8 | `734d28253fd0c8ba1ed145b22009c25bc67370df` |
| cas-workstation #16 | `5d83bcdbdb992342ede7b13eb27f0298bd70b803` |
| ci-autopilot #2200 | `1716769f9c10f252a84395bed910c61958cb3e41` |
| cloud-security-service-model #11 | `c17f2adf8041202f0d23f64616215293438875e9` |
| .github #11 | `ef20c40cd73158f97a9723826e7d77b186c34c52` |
| Promptimprover #25 | `dd85f51566de48f928cdc3ed0259444b4c8fe42e` |
| cas-contracts corrective #15 | `0b35b98400a38089b99d14360f389fe3bd3b0bd6` |
| cas-contracts release-ordering #16 | `95daee95415afac15491fbabf30cd57ca8a2d0d3` |
