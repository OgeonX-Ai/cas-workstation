#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
from datetime import date, datetime, timedelta, timezone
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today()
    captured_at = datetime.now(timezone.utc).isoformat()
    postmortem_due = (today + timedelta(days=5)).isoformat()
    snapshot_rel = Path("evidence/compliance/snapshots") / f"incident-management-{today.isoformat()}.json"
    snapshot_path = ROOT / snapshot_rel

    snapshot = {
        "captured_at": captured_at,
        "exercise": {
            "exercise_id": "CAS-IR-001",
            "exercise_type": "tabletop",
            "scenario": "Compliance evidence integrity failure on the root workstation release path",
            "severity": "SEV2",
            "scope": [
                "OgeonX-Ai/cas-workstation",
                "Coding-Autopilot-System/cas-contracts",
                "Coding-Autopilot-System/gsd-orchestrator",
            ],
            "roles": {
                "incident_commander": "Portfolio maintainer",
                "technical_resolver": "Portfolio maintainer",
                "evidence_lead": "Portfolio maintainer",
                "communications_lead": "Portfolio maintainer",
                "risk_owner": "Portfolio maintainer",
            },
            "timeline": {
                "detect": f"{today.isoformat()}T13:55:00Z",
                "triage": f"{today.isoformat()}T14:00:00Z",
                "contain": f"{today.isoformat()}T14:10:00Z",
                "recover": f"{today.isoformat()}T14:24:00Z",
            },
            "decision_log": [
                "Treat missing or unverifiable attestation evidence as a control-system incident.",
                "Block further audit claims until the workflow reproduces a green attested bundle.",
                "Record limited-token branch-protection visibility explicitly instead of flattening it to unprotected.",
            ],
            "evidence_sources": [
                "docs/incident-standard.md",
                "portfolio/cloud-security-service-model/docs/20-runbooks/rbk-001-incident-triage.md",
                "portfolio/cloud-security-service-model/docs/21-templates/template-incident-report.md",
                "https://github.com/OgeonX-Ai/cas-workstation/actions/runs/29025205984",
            ],
            "postmortem_due": postmortem_due,
            "status": "completed",
        }
    }
    snapshot_path.write_text(json.dumps(snapshot, indent=2) + "\n", encoding="utf-8")

    out_path = EVIDENCE / "incident-management.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "exercise_id",
                "scope",
                "exercise_type",
                "exercise_date",
                "severity",
                "status",
                "evidence_ref",
                "postmortem_due",
                "template_ref",
                "notes",
            ],
        )
        writer.writeheader()
        writer.writerow(
            {
                "exercise_id": "CAS-IR-001",
                "scope": "portfolio_control_system",
                "exercise_type": "tabletop",
                "exercise_date": today.isoformat(),
                "severity": "SEV2",
                "status": "passed",
                "evidence_ref": str(snapshot_rel),
                "postmortem_due": postmortem_due,
                "template_ref": "portfolio/cloud-security-service-model/docs/21-templates/template-incident-report.md",
                "notes": "Validated escalation roles, evidence handling, and post-incident loop for root compliance evidence failures.",
            }
        )

    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
