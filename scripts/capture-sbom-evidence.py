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
SBOM_DIR = EVIDENCE / "sbom"

PYTHON_TOOL = Path("/tmp/cdx-venv/bin/cyclonedx-py")
DOTNET_TOOL = Path("/tmp/dotnet-tools/dotnet-CycloneDX")

TARGETS = [
    {
        "target_id": "root-python",
        "repository": "OgeonX-Ai/cas-workstation",
        "ecosystem": "python-requirements",
        "source": ROOT / "requirements.txt",
    },
    {
        "target_id": "gemini-api-server",
        "repository": "Coding-Autopilot-System/gemini-nano",
        "ecosystem": "python-requirements",
        "source": ROOT / "gemini-nano" / "api-server" / "requirements.txt",
    },
    {
        "target_id": "gemini-python-mediapipe",
        "repository": "Coding-Autopilot-System/gemini-nano",
        "ecosystem": "python-requirements",
        "source": ROOT / "gemini-nano" / "python-mediapipe" / "requirements.txt",
    },
    {
        "target_id": "gemini-chrome-bridge",
        "repository": "Coding-Autopilot-System/gemini-nano",
        "ecosystem": "npm-lockfile",
        "source": ROOT / "gemini-nano" / "chrome-bridge",
    },
    {
        "target_id": "autogen-python",
        "repository": "Coding-Autopilot-System/autogen",
        "ecosystem": "python-requirements",
        "source": ROOT / "portfolio" / "autogen" / "requirements.txt",
    },
    {
        "target_id": "ci-autopilot-python",
        "repository": "Coding-Autopilot-System/ci-autopilot",
        "ecosystem": "python-requirements",
        "source": ROOT / "portfolio" / "ci-autopilot" / "requirements.txt",
    },
    {
        "target_id": "cas-contracts-npm",
        "repository": "Coding-Autopilot-System/cas-contracts",
        "ecosystem": "npm-lockfile",
        "source": ROOT / "portfolio" / "cas-contracts",
    },
    {
        "target_id": "promptimprover-universal-refiner",
        "repository": "Coding-Autopilot-System/Promptimprover",
        "ecosystem": "npm-lockfile",
        "source": ROOT / "portfolio" / "Promptimprover" / "universal-refiner",
    },
    {
        "target_id": "promptimprover-mcp-server",
        "repository": "Coding-Autopilot-System/Promptimprover",
        "ecosystem": "npm-lockfile",
        "source": ROOT / "portfolio" / "Promptimprover" / "mcp-server",
    },
    {
        "target_id": "promptimprover-gemini-extension",
        "repository": "Coding-Autopilot-System/Promptimprover",
        "ecosystem": "npm-lockfile",
        "source": ROOT / "portfolio" / "Promptimprover" / "gemini-extension",
    },
    {
        "target_id": "cas-platform-graphical-console",
        "repository": "Coding-Autopilot-System/cas-platform",
        "ecosystem": "npm-lockfile",
        "source": ROOT / "portfolio" / "cas-platform" / "src" / "graphical-console",
    },
    {
        "target_id": "cas-evals-ui",
        "repository": "Coding-Autopilot-System/cas-evals",
        "ecosystem": "npm-lockfile",
        "source": ROOT / "portfolio" / "cas-evals" / "tests" / "ui",
    },
    {
        "target_id": "gsd-orchestrator-dotnet",
        "repository": "Coding-Autopilot-System/gsd-orchestrator",
        "ecosystem": "dotnet-csproj",
        "source": ROOT / "portfolio" / "gsd-orchestrator" / "src" / "GsdOrchestrator" / "GsdOrchestrator.csproj",
    },
]


def run(cmd: list[str], cwd: Path | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, cwd=str(cwd) if cwd else None, text=True, capture_output=True, check=False)


def ensure_tools() -> None:
    if not PYTHON_TOOL.exists():
        subprocess.run(["python3", "-m", "venv", "/tmp/cdx-venv"], check=True)
        subprocess.run(
            ["/tmp/cdx-venv/bin/python", "-m", "pip", "install", "cyclonedx-bom"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    if not DOTNET_TOOL.exists():
        subprocess.run(
            ["dotnet", "tool", "install", "--tool-path", "/tmp/dotnet-tools", "cyclonedx", "--version", "6.2.0"],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def main() -> int:
    ensure_tools()
    SBOM_DIR.mkdir(parents=True, exist_ok=True)
    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    today = date.today().isoformat()
    captured_at = datetime.now(timezone.utc).isoformat()

    rows: list[dict[str, str]] = []
    snapshot_rows: list[dict[str, str]] = []

    for target in TARGETS:
        out_path = SBOM_DIR / f"{target['target_id']}.cdx.json"
        status = "generated"
        notes = ""
        source_path = Path(target["source"])

        if not source_path.exists():
            rows.append(
                {
                    "target_id": target["target_id"],
                    "repository": target["repository"],
                    "ecosystem": target["ecosystem"],
                    "source_path": str(source_path.relative_to(ROOT)),
                    "generated_at": today,
                    "sbom_path": "",
                    "status": "skipped",
                    "notes": "source path missing in current workspace",
                }
            )
            snapshot_rows.append(
                {
                    "target_id": target["target_id"],
                    "repository": target["repository"],
                    "ecosystem": target["ecosystem"],
                    "source_path": str(source_path),
                    "status": "skipped",
                    "sbom_path": "",
                    "notes": "source path missing in current workspace",
                }
            )
            continue

        if target["ecosystem"] == "python-requirements":
            result = run([str(PYTHON_TOOL), "requirements", str(source_path), "-o", str(out_path)])
        elif target["ecosystem"] == "npm-lockfile":
            result = run(
                ["npx", "-y", "@cyclonedx/cyclonedx-npm", "--ignore-npm-errors", "--package-lock-only", "--output-file", str(out_path)],
                cwd=source_path,
            )
        elif target["ecosystem"] == "dotnet-csproj":
            result = run([str(DOTNET_TOOL), str(source_path), "-o", str(SBOM_DIR), "-F", "Json", "--filename", f"{target['target_id']}.cdx.json"])
        else:
            result = subprocess.CompletedProcess([], 1, "", f"Unsupported ecosystem {target['ecosystem']}")

        if not out_path.exists():
            status = "failed"
            notes = (result.stderr or result.stdout).strip().splitlines()[-1] if (result.stderr or result.stdout).strip() else "generation failed"
        elif result.returncode != 0:
            notes = (result.stderr or result.stdout).strip().splitlines()[-1] if (result.stderr or result.stdout).strip() else ""

        rows.append(
            {
                "target_id": target["target_id"],
                "repository": target["repository"],
                "ecosystem": target["ecosystem"],
                "source_path": str(source_path.relative_to(ROOT)),
                "generated_at": today,
                "sbom_path": str(out_path.relative_to(ROOT)) if out_path.exists() else "",
                "status": status,
                "notes": notes,
            }
        )
        snapshot_rows.append(
            {
                "target_id": target["target_id"],
                "repository": target["repository"],
                "ecosystem": target["ecosystem"],
                "source_path": str(source_path),
                "status": status,
                "sbom_path": str(out_path) if out_path.exists() else "",
                "notes": notes,
            }
        )

    snapshot_path = SNAPSHOTS / f"sbom-evidence-{today}.json"
    snapshot_path.write_text(
        json.dumps({"captured_at": captured_at, "targets": snapshot_rows}, indent=2) + "\n",
        encoding="utf-8",
    )

    out_csv = EVIDENCE / "sbom-evidence.csv"
    with out_csv.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["target_id", "repository", "ecosystem", "source_path", "generated_at", "sbom_path", "status", "notes"],
        )
        writer.writeheader()
        writer.writerows(rows)

    print(snapshot_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
