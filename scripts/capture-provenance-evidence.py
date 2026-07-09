#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from datetime import date, datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"

REPOS = {
    "OgeonX-Ai/cas-workstation": ROOT,
    "Coding-Autopilot-System/gemini-nano": ROOT / "gemini-nano",
    "Coding-Autopilot-System/Promptimprover": ROOT / "portfolio" / "Promptimprover",
    "Coding-Autopilot-System/autogen": ROOT / "portfolio" / "autogen",
    "Coding-Autopilot-System/autopilot-core": ROOT / "portfolio" / "autopilot-core",
    "Coding-Autopilot-System/autopilot-demo": ROOT / "portfolio" / "autopilot-demo",
    "Coding-Autopilot-System/cas-contracts": ROOT / "portfolio" / "cas-contracts",
    "Coding-Autopilot-System/cas-evals": ROOT / "portfolio" / "cas-evals",
    "Coding-Autopilot-System/cas-platform": ROOT / "portfolio" / "cas-platform",
    "Coding-Autopilot-System/cas-reference-product": ROOT / "portfolio" / "cas-reference-product",
    "Coding-Autopilot-System/cas-workstation": ROOT / "portfolio" / "cas-workstation",
    "Coding-Autopilot-System/ci-autopilot": ROOT / "portfolio" / "ci-autopilot",
    "Coding-Autopilot-System/cloud-security-service-model": ROOT / "portfolio" / "cloud-security-service-model",
    "Coding-Autopilot-System/gsd-orchestrator": ROOT / "portfolio" / "gsd-orchestrator",
    "Coding-Autopilot-System/.github": ROOT / "portfolio" / "org-dotgithub",
}

PROVENANCE_MARKERS = [
    "actions/attest",
    "gh attestation verify",
    "sigstore",
    "cosign",
]


def repo_has_attestation(repo_path: Path) -> bool:
    workflows = list((repo_path / ".github" / "workflows").glob("*.yml")) + list((repo_path / ".github" / "workflows").glob("*.yaml"))
    for workflow in workflows:
        try:
            text = workflow.read_text(encoding="utf-8")
        except OSError:
            continue
        if any(marker in text for marker in PROVENANCE_MARKERS):
            return True
    return False


def repo_has_local_provenance(repo_path: Path) -> bool:
    candidates = [
        repo_path / "evidence",
        repo_path / "releases",
        repo_path / "vendor",
    ]
    for base in candidates:
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.is_file() and "provenance" in path.name.lower():
                return True
    return False


def sbom_repos() -> set[str]:
    with (EVIDENCE / "sbom-evidence.csv").open(newline="", encoding="utf-8") as handle:
        rows = list(csv.DictReader(handle))
    return {row["repository"] for row in rows if row["status"] == "generated"}


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()
    sbom_supported = sbom_repos()

    rows = []
    snapshot_rows = []
    for repo, repo_path in REPOS.items():
        attestation = repo_has_attestation(repo_path)
        local_provenance = repo_has_local_provenance(repo_path)
        sbom = repo in sbom_supported
        status = "attested" if attestation else "evidence-only" if local_provenance or sbom else "gap"
        rows.append(
            {
                "repository": repo,
                "review_date": today,
                "attestation_workflow": str(attestation).lower(),
                "local_provenance_artifact": str(local_provenance).lower(),
                "sbom_linked": str(sbom).lower(),
                "status": status,
            }
        )
        snapshot_rows.append(
            {
                "repository": repo,
                "attestation_workflow": attestation,
                "local_provenance_artifact": local_provenance,
                "sbom_linked": sbom,
                "status": status,
            }
        )

    snapshot_path = SNAPSHOTS / f"provenance-evidence-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "repositories": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_path = EVIDENCE / "provenance-evidence.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["repository", "review_date", "attestation_workflow", "local_provenance_artifact", "sbom_linked", "status"],
        )
        writer.writeheader()
        writer.writerows(rows)

    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
