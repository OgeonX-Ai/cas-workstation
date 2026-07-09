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

LOCKFILES = [
    "package-lock.json",
    "pnpm-lock.yaml",
    "yarn.lock",
    "poetry.lock",
    "Pipfile.lock",
    "uv.lock",
    "packages.lock.json",
]


def has_lockfile(repo_path: Path) -> bool:
    args = ["rg", "--files", str(repo_path)]
    for candidate in LOCKFILES:
        args.extend(["-g", candidate])
    args.extend(
        [
            "-g",
            "!**/node_modules/**",
            "-g",
            "!**/.git/**",
            "-g",
            "!**/site/**",
            "-g",
            "!**/.venv/**",
        ]
    )
    result = subprocess.run(args, text=True, capture_output=True, check=False)
    return result.returncode == 0 and bool(result.stdout.strip())


def main() -> int:
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()

    rows = []
    snapshot_rows = []
    for repo, repo_path in REPOS.items():
        pages_workflow = (repo_path / ".github" / "workflows" / "pages.yml").exists()
        codeql = (repo_path / ".github" / "workflows" / "codeql.yml").exists()
        dependabot = (repo_path / ".github" / "dependabot.yml").exists()
        local_release_policy = (repo_path / "docs" / "RELEASE_POLICY.md").exists()
        central_release_policy = (ROOT / "portfolio" / "org-dotgithub" / "docs" / "RELEASE_POLICY.md").exists()
        lockfile_present = has_lockfile(repo_path)
        rows.append(
            {
                "repository": repo,
                "release_policy_source": "local" if local_release_policy else "org" if central_release_policy else "missing",
                "lockfile_present": str(lockfile_present).lower(),
                "pages_workflow": str(pages_workflow).lower(),
                "codeql": str(codeql).lower(),
                "dependabot": str(dependabot).lower(),
                "status": "active" if pages_workflow and codeql and dependabot else "gap",
            }
        )
        snapshot_rows.append(
            {
                "repository": repo,
                "lockfile_present": lockfile_present,
                "pages_workflow": pages_workflow,
                "codeql": codeql,
                "dependabot": dependabot,
                "release_policy_source": "local" if local_release_policy else "org" if central_release_policy else "missing",
            }
        )

    snapshot_path = SNAPSHOTS / f"release-evidence-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "repositories": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_path = EVIDENCE / "release-evidence.csv"
    with out_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["repository", "release_policy_source", "lockfile_present", "pages_workflow", "codeql", "dependabot", "status"],
        )
        writer.writeheader()
        writer.writerows(rows)
    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
