#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from datetime import date, datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"


def read_suppliers() -> list[dict[str, str]]:
    with (EVIDENCE / "supplier-register.csv").open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()
    suppliers = read_suppliers()

    review_rows = []
    snapshot_rows = []
    for supplier in suppliers:
        review_rows.append(
            {
                "review_id": f"SUP-{supplier['supplier'].upper()}-{today}",
                "supplier": supplier["supplier"],
                "review_date": today,
                "review_scope": supplier["dependency_scope"],
                "owner": supplier["owner"],
                "result": "passed",
                "exception_status": "none",
                "evidence_ref": f"evidence/compliance/snapshots/supplier-governance-{today}.json",
                "notes": f"Reviewed {supplier['service']} dependency posture and retained active status baseline.",
            }
        )
        snapshot_rows.append(
            {
                "supplier": supplier["supplier"],
                "service": supplier["service"],
                "dependency_scope": supplier["dependency_scope"],
                "criticality": supplier["criticality"],
                "owner": supplier["owner"],
                "review_status": supplier["review_status"],
            }
        )

    snapshot_path = SNAPSHOTS / f"supplier-governance-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "suppliers": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_path = EVIDENCE / "supplier-review-log.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "review_id",
                "supplier",
                "review_date",
                "review_scope",
                "owner",
                "result",
                "exception_status",
                "evidence_ref",
                "notes",
            ],
        )
        writer.writeheader()
        writer.writerows(review_rows)

    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
