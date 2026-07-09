#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from datetime import date, datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"

TIER_OBJECTIVES = {
    "Tier-0": {"rto_target": "1 business day", "rpo_target": "4 hours"},
    "Tier-1": {"rto_target": "2 business days", "rpo_target": "1 business day"},
    "Tier-2": {"rto_target": "3 business days", "rpo_target": "2 business days"},
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
        objectives = TIER_OBJECTIVES[asset["recovery_tier"]]
        rows.append(
            {
                "asset_id": asset["asset_id"],
                "repository": asset["repository"],
                "recovery_tier": asset["recovery_tier"],
                "rto_target": objectives["rto_target"],
                "rpo_target": objectives["rpo_target"],
                "recovery_owner": asset["owner"],
                "delegate_owner": asset["delegate_owner"],
                "review_date": today,
                "status": "active",
            }
        )
        snapshot_rows.append(
            {
                "asset_id": asset["asset_id"],
                "repository": asset["repository"],
                "runtime_surface": asset["runtime_surface"],
                "recovery_tier": asset["recovery_tier"],
                "rto_target": objectives["rto_target"],
                "rpo_target": objectives["rpo_target"],
                "recovery_owner": asset["owner"],
                "delegate_owner": asset["delegate_owner"],
            }
        )

    snapshot_path = SNAPSHOTS / f"bcdr-objectives-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "assets": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_path = EVIDENCE / "bcdr-objectives.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "asset_id",
                "repository",
                "recovery_tier",
                "rto_target",
                "rpo_target",
                "recovery_owner",
                "delegate_owner",
                "review_date",
                "status",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
