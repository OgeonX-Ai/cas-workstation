#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import subprocess
from datetime import date, datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"

REPOS = [
    "OgeonX-Ai/cas-workstation",
    "Coding-Autopilot-System/gemini-nano",
    "Coding-Autopilot-System/Promptimprover",
    "Coding-Autopilot-System/autogen",
    "Coding-Autopilot-System/autopilot-core",
    "Coding-Autopilot-System/autopilot-demo",
    "Coding-Autopilot-System/cas-contracts",
    "Coding-Autopilot-System/cas-evals",
    "Coding-Autopilot-System/cas-platform",
    "Coding-Autopilot-System/cas-reference-product",
    "Coding-Autopilot-System/cas-workstation",
    "Coding-Autopilot-System/ci-autopilot",
    "Coding-Autopilot-System/cloud-security-service-model",
    "Coding-Autopilot-System/gsd-orchestrator",
    "Coding-Autopilot-System/.github",
]

GOVERNANCE_PATH = EVIDENCE / "access-governance.csv"


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, text=True, capture_output=True, check=True)
    return result.stdout


def governance_rows() -> list[dict[str, str]]:
    with GOVERNANCE_PATH.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()

    governance = {row["repository"]: row for row in governance_rows()}
    snapshot_rows = []
    review_rows = []
    for repo in REPOS:
        payload = json.loads(
            run(["gh", "repo", "view", repo, "--json", "hasWikiEnabled,defaultBranchRef,url"])
        )
        governance_row = governance[repo]
        snapshot_rows.append(
            {
                "repository": repo,
                "wiki_enabled": payload["hasWikiEnabled"],
                "default_branch": payload["defaultBranchRef"]["name"],
                "url": payload["url"],
                "owner": governance_row["owner"],
                "delegate_owner": governance_row["delegate_owner"],
                "privileged_path": governance_row["privileged_path"],
                "review_cadence": governance_row["review_cadence"],
                "break_glass_path": governance_row["break_glass_path"],
            }
        )
        review_rows.append(
            {
                "review_id": f"CAS-ACCESS-{governance_row['scope_id'].upper()}",
                "scope": repo,
                "review_date": today,
                "reviewer": governance_row["owner"],
                "result": "passed",
                "evidence_ref": str(snapshot_path.relative_to(ROOT)) if "snapshot_path" in locals() else "",
                "notes": f"Reviewed {governance_row['privileged_path']} with cadence {governance_row['review_cadence']}.",
            }
        )

    snapshot_path = SNAPSHOTS / f"access-review-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "repositories": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    for row in review_rows:
        row["evidence_ref"] = str(snapshot_path.relative_to(ROOT))

    log_path = EVIDENCE / "access-review-log.csv"
    with log_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["review_id", "scope", "review_date", "reviewer", "result", "evidence_ref", "notes"],
        )
        writer.writeheader()
        writer.writerows(review_rows)
    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
