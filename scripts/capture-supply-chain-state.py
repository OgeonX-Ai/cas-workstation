#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from datetime import date, datetime, timezone
from pathlib import Path


ROOT = Path("/mnt/c/personalrepo")
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


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()
    rows = []
    snapshot_rows = []

    for repo, repo_path in REPOS.items():
        dependabot = (repo_path / ".github" / "dependabot.yml").exists()
        codeql = (repo_path / ".github" / "workflows" / "codeql.yml").exists()
        pages = (repo_path / ".github" / "workflows" / "pages.yml").exists()
        rows.append(
            {
                "repository": repo,
                "dependabot": str(dependabot).lower(),
                "codeql": str(codeql).lower(),
                "actions_pinned_baseline": str(pages or codeql).lower(),
                "status": "active" if dependabot and codeql else "gap",
            }
        )
        snapshot_rows.append(
            {
                "repository": repo,
                "path": str(repo_path),
                "dependabot": dependabot,
                "codeql": codeql,
                "pages_workflow": pages,
            }
        )

    snapshot_path = SNAPSHOTS / f"supply-chain-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "repositories": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_path = EVIDENCE / "supply-chain-controls.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["repository", "dependabot", "codeql", "actions_pinned_baseline", "status"],
        )
        writer.writeheader()
        writer.writerows(rows)
    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
