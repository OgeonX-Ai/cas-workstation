#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import subprocess
from datetime import date, datetime, timedelta, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"
REVIEW_WINDOW_DAYS = 365

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


def run_json(cmd: list[str]) -> list[dict]:
    result = subprocess.run(cmd, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return json.loads(result.stdout)


def main() -> int:
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)

    today = date.today()
    review_date = today.isoformat()
    window_start = (today - timedelta(days=REVIEW_WINDOW_DAYS)).isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()

    rows: list[dict[str, str]] = []
    snapshots: list[dict[str, object]] = []

    for repo in REPOS:
        prs = run_json(
            [
                "gh",
                "pr",
                "list",
                "--repo",
                repo,
                "--state",
                "merged",
                "--search",
                f"label:emergency-change merged:>={window_start}",
                "--limit",
                "100",
                "--json",
                "number,title,mergedAt,url,labels",
            ]
        )

        emergency_count = len(prs)
        latest_date = ""
        latest_ref = ""
        status = "none-recorded"
        notes = f"No merged PRs labeled emergency-change in the last {REVIEW_WINDOW_DAYS} days"

        if prs:
            prs = sorted(prs, key=lambda item: item["mergedAt"], reverse=True)
            latest = prs[0]
            latest_date = latest["mergedAt"][:10]
            latest_ref = latest["url"]
            status = "recorded"
            notes = f"{emergency_count} merged PR(s) labeled emergency-change in the last {REVIEW_WINDOW_DAYS} days"

        rows.append(
            {
                "review_id": f"CAS-EMERGENCY-{repo.split('/')[-1]}",
                "repository": repo,
                "review_date": review_date,
                "review_window_days": str(REVIEW_WINDOW_DAYS),
                "emergency_path_documented": "true",
                "emergency_change_count": str(emergency_count),
                "latest_emergency_change_date": latest_date,
                "latest_emergency_change_ref": latest_ref,
                "status": status,
                "notes": notes,
            }
        )
        snapshots.append(
            {
                "repository": repo,
                "review_date": review_date,
                "review_window_days": REVIEW_WINDOW_DAYS,
                "emergency_change_count": emergency_count,
                "latest_emergency_change_date": latest_date or None,
                "latest_emergency_change_ref": latest_ref or None,
                "status": status,
                "pull_requests": prs,
            }
        )

    out_path = EVIDENCE / "emergency-change-log.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "review_id",
                "repository",
                "review_date",
                "review_window_days",
                "emergency_path_documented",
                "emergency_change_count",
                "latest_emergency_change_date",
                "latest_emergency_change_ref",
                "status",
                "notes",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    snapshot_path = SNAPSHOTS / f"emergency-change-{review_date}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "repositories": snapshots}, indent=2) + "\n",
        encoding="utf-8",
    )

    print(out_path)
    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
