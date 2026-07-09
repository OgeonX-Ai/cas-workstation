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


def run_json(cmd: list[str]) -> dict:
    result = subprocess.run(cmd, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return json.loads(result.stdout)


def branch_protection(repo: str, branch: str) -> dict | None:
    result = subprocess.run(
        ["gh", "api", f"repos/{repo}/branches/{branch}/protection"],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        details = (result.stderr or result.stdout).strip()
        if "404" in details or "Branch not protected" in details:
            return None
        raise RuntimeError(f"Unable to inspect branch protection for {repo}@{branch}: {details}")
    return json.loads(result.stdout)


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()

    rows = []
    snapshot_rows = []

    for repo in REPOS:
        repo_view = run_json(["gh", "repo", "view", repo, "--json", "defaultBranchRef"])
        default_branch = repo_view["defaultBranchRef"]["name"]
        protection = branch_protection(repo, default_branch)

        protection_enabled = protection is not None
        required_reviews = 0
        enforce_admins = False
        linear_history = False
        force_pushes_blocked = False

        if protection:
            reviews = protection.get("required_pull_request_reviews") or {}
            required_reviews = reviews.get("required_approving_review_count", 0) or 0
            enforce_admins = bool((protection.get("enforce_admins") or {}).get("enabled"))
            linear_history = bool((protection.get("required_linear_history") or {}).get("enabled"))
            force_pushes_blocked = not bool((protection.get("allow_force_pushes") or {}).get("enabled"))

        rows.append(
            {
                "review_id": f"CAS-CHANGE-{repo.split('/')[-1]}",
                "repository": repo,
                "default_branch": default_branch,
                "review_date": today,
                "protection_enabled": str(protection_enabled).lower(),
                "required_approvals": str(required_reviews),
                "enforce_admins": str(enforce_admins).lower(),
                "linear_history": str(linear_history).lower(),
                "force_pushes_blocked": str(force_pushes_blocked).lower(),
                "result": "captured",
                "notes": "GitHub branch protection snapshot",
            }
        )
        snapshot_rows.append(
            {
                "repository": repo,
                "default_branch": default_branch,
                "protection_enabled": protection_enabled,
                "required_approvals": required_reviews,
                "enforce_admins": enforce_admins,
                "linear_history": linear_history,
                "force_pushes_blocked": force_pushes_blocked,
            }
        )

    snapshot_path = SNAPSHOTS / f"change-management-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "repositories": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_path = EVIDENCE / "change-management.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=[
                "review_id",
                "repository",
                "default_branch",
                "review_date",
                "protection_enabled",
                "required_approvals",
                "enforce_admins",
                "linear_history",
                "force_pushes_blocked",
                "result",
                "notes",
            ],
        )
        writer.writeheader()
        writer.writerows(rows)

    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
