#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

REPOS = {
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


def run(cmd: list[str]) -> None:
    subprocess.run(cmd, check=True)


def is_git_checkout(path: Path) -> bool:
    return (path / ".git").exists()


def main() -> int:
    for repo, destination in REPOS.items():
        if is_git_checkout(destination):
            continue

        destination.parent.mkdir(parents=True, exist_ok=True)
        run(["git", "clone", "--depth", "1", f"https://github.com/{repo}.git", str(destination)])
        print(f"hydrated {repo} -> {destination}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
