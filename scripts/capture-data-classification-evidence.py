#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from datetime import date, datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"

HANDLING = {
    "Low": {
        "handling_rule": "Public or low-sensitivity engineering metadata only; avoid secrets and personal data in docs and logs.",
        "evidence_access": "portfolio-public-or-maintainer",
    },
    "Moderate": {
        "handling_rule": "Internal engineering evidence only; minimize identifiers and keep operational evidence under maintainer-controlled access.",
        "evidence_access": "maintainer-controlled",
    },
}


def read_assets() -> list[dict[str, str]]:
    with (EVIDENCE / "asset-inventory.csv").open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()
    assets = read_assets()

    rows = []
    snapshot_rows = []
    for asset in assets:
        policy = HANDLING[asset["data_sensitivity"]]
        rows.append(
            {
                "asset_id": asset["asset_id"],
                "repository": asset["repository"],
                "data_class": asset["data_sensitivity"],
                "handling_rule": policy["handling_rule"],
                "evidence_access": policy["evidence_access"],
                "review_date": today,
                "status": "active",
            }
        )
        snapshot_rows.append(
            {
                "asset_id": asset["asset_id"],
                "repository": asset["repository"],
                "data_class": asset["data_sensitivity"],
                "handling_rule": policy["handling_rule"],
                "evidence_access": policy["evidence_access"],
            }
        )

    snapshot_path = SNAPSHOTS / f"data-classification-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "assets": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_path = EVIDENCE / "data-classification.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["asset_id", "repository", "data_class", "handling_rule", "evidence_access", "review_date", "status"],
        )
        writer.writeheader()
        writer.writerows(rows)

    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
