#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path


ROOT = Path("/mnt/c/personalrepo")
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"

REQUIRED_FILES = [
    EVIDENCE / "asset-inventory.csv",
    EVIDENCE / "control-owners.csv",
    EVIDENCE / "risk-register.csv",
    EVIDENCE / "supplier-register.csv",
    EVIDENCE / "supply-chain-controls.csv",
    EVIDENCE / "recovery-drills.csv",
    EVIDENCE / "access-review-log.csv",
    EVIDENCE / "exception-register.csv",
]


def run(cmd: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, capture_output=True, check=False)


def csv_rows(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def days_old(iso_date: str) -> int:
    return (date.today() - datetime.strptime(iso_date, "%Y-%m-%d").date()).days


def check_url(url: str) -> tuple[bool, str]:
    result = run(["curl", "-I", "-L", "--max-time", "20", url])
    first_line = result.stdout.splitlines()[0] if result.stdout else result.stderr.splitlines()[0]
    return ("HTTP/2 200" in first_line or "HTTP/1.1 200" in first_line), first_line


def repo_view(repo: str) -> dict:
    result = run(["gh", "repo", "view", repo, "--json", "hasWikiEnabled,url,defaultBranchRef"])
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return json.loads(result.stdout)


def pages_view(repo: str) -> dict | None:
    result = run(["gh", "api", f"repos/{repo}/pages"])
    if result.returncode != 0:
        return None
    return json.loads(result.stdout)


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    for path in REQUIRED_FILES:
        if not path.exists():
            errors.append(f"Missing evidence file: {path}")
        elif path.stat().st_size == 0:
            errors.append(f"Empty evidence file: {path}")
    if not SNAPSHOTS.exists():
        errors.append(f"Missing snapshots directory: {SNAPSHOTS}")

    asset_rows = csv_rows(EVIDENCE / "asset-inventory.csv")
    supply_chain_rows = csv_rows(EVIDENCE / "supply-chain-controls.csv")
    if len(asset_rows) != 15:
        errors.append(f"Expected 15 asset inventory rows, found {len(asset_rows)}")
    if len(supply_chain_rows) != 15:
        errors.append(f"Expected 15 supply-chain rows, found {len(supply_chain_rows)}")

    local_repo_paths = {
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

    for row in asset_rows:
        repo = row["repository"]
        url = row["pages_url"]
        ok, line = check_url(url)
        if not ok:
            errors.append(f"Pages URL not serving 200 for {repo}: {url} ({line})")

        try:
            repo_meta = repo_view(repo)
        except RuntimeError as exc:
            errors.append(f"Cannot inspect repo {repo}: {exc}")
            continue

        if not repo_meta.get("hasWikiEnabled"):
            errors.append(f"Wiki disabled for {repo}")

        pages = pages_view(repo)
        if not pages:
            errors.append(f"No GitHub Pages site configured for {repo}")

    for row in supply_chain_rows:
        repo = row["repository"]
        repo_path = local_repo_paths[repo]
        if row["dependabot"] == "true" and not (repo_path / ".github" / "dependabot.yml").exists():
            errors.append(f"Dependabot baseline missing for {repo}")
        if row["codeql"] == "true" and not (repo_path / ".github" / "workflows" / "codeql.yml").exists():
            errors.append(f"CodeQL baseline missing for {repo}")

    recovery_rows = csv_rows(EVIDENCE / "recovery-drills.csv")
    if not any(row["status"] == "passed" for row in recovery_rows):
        errors.append("No passed recovery drill recorded")
    if any(row["status"] == "planned" for row in recovery_rows):
        warnings.append("At least one recovery drill is still only planned")
    fresh_recovery = [
        row for row in recovery_rows
        if row["last_tested"] and row["status"] == "passed" and days_old(row["last_tested"]) <= 90
    ]
    if not fresh_recovery:
        errors.append("No passed recovery drill within the last 90 days")

    access_rows = csv_rows(EVIDENCE / "access-review-log.csv")
    if any(row["result"] == "missing" for row in access_rows):
        warnings.append("Access review evidence is still missing")
    fresh_access = [
        row for row in access_rows
        if row["review_date"] and row["result"] == "passed" and days_old(row["review_date"]) <= 90
    ]
    if not fresh_access:
        errors.append("No passed access review within the last 90 days")

    exception_rows = csv_rows(EVIDENCE / "exception-register.csv")
    open_exceptions = [row for row in exception_rows if row["status"] == "open"]
    if open_exceptions:
        warnings.append(f"{len(open_exceptions)} open exception(s) remain")

    report = {
        "errors": errors,
        "warnings": warnings,
        "summary": {
            "asset_count": len(asset_rows),
            "open_exceptions": len(open_exceptions),
        },
    }
    print(json.dumps(report, indent=2))

    return 1 if errors or warnings else 0


if __name__ == "__main__":
    sys.exit(main())
