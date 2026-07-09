#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from datetime import date, datetime, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"


def csv_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def main() -> int:
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)

    today = date.today()
    review_date = today.isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()

    risk_rows = csv_rows(EVIDENCE / "risk-register.csv")
    rows: list[dict[str, str]] = []
    snapshots: list[dict[str, str]] = []

    for risk in risk_rows:
        due_date = date.fromisoformat(risk["due_date"])
        is_closed = risk["status"].strip().lower() == "closed"
        is_overdue = not is_closed and due_date < today

        residual_decision = "accepted" if is_closed else "mitigate"
        acceptance_status = "accepted" if is_closed else "mitigation-in-flight"
        acceptance_owner = risk["owner"] if is_closed else ""
        acceptance_evidence_ref = ""

        if is_closed:
            escalation_status = "closed"
        elif is_overdue:
            escalation_status = "overdue-needs-escalation"
        else:
            escalation_status = "not-due"

        escalation_evidence_ref = ""
        notes = "Generated from risk register due dates and statuses"
        if is_overdue:
            notes = "Risk is overdue and requires explicit escalation evidence or exception approval"

        row = {
            "risk_id": risk["risk_id"],
            "review_date": review_date,
            "residual_decision": residual_decision,
            "acceptance_status": acceptance_status,
            "acceptance_owner": acceptance_owner,
            "acceptance_evidence_ref": acceptance_evidence_ref,
            "escalation_status": escalation_status,
            "escalation_evidence_ref": escalation_evidence_ref,
            "notes": notes,
        }
        rows.append(row)
        snapshots.append(row.copy())

    out_path = EVIDENCE / "risk-review-log.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "risk_id",
                "review_date",
                "residual_decision",
                "acceptance_status",
                "acceptance_owner",
                "acceptance_evidence_ref",
                "escalation_status",
                "escalation_evidence_ref",
                "notes",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    snapshot_path = SNAPSHOTS / f"risk-review-{review_date}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "reviews": snapshots}, indent=2) + "\n",
        encoding="utf-8",
    )

    print(out_path)
    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
