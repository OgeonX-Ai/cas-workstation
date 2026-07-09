#!/usr/bin/env python3
from __future__ import annotations

import csv
import json
import os
import subprocess
import sys
import tempfile
import zipfile
from datetime import date, datetime
from io import BytesIO
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "evidence" / "compliance"
SNAPSHOTS = EVIDENCE / "snapshots"
COMPLIANCE_REPO = "OgeonX-Ai/cas-workstation"
COMPLIANCE_WORKFLOW = "compliance.yml"
COMPLIANCE_WORKFLOW_REF = f"{COMPLIANCE_REPO}/.github/workflows/compliance.yml"
COMPLIANCE_BUNDLE_ARTIFACT = "compliance-evidence-bundle"
COMPLIANCE_ATTESTATION_ARTIFACT = "compliance-attestation-bundle"
ATTESTATION_MAX_AGE_DAYS = 14

REQUIRED_FILES = [
    EVIDENCE / "asset-inventory.csv",
    EVIDENCE / "control-owners.csv",
    EVIDENCE / "risk-register.csv",
    EVIDENCE / "supplier-register.csv",
    EVIDENCE / "supply-chain-controls.csv",
    EVIDENCE / "release-evidence.csv",
    EVIDENCE / "sbom-evidence.csv",
    EVIDENCE / "change-management.csv",
    EVIDENCE / "control-crosswalk.csv",
    EVIDENCE / "evidence-retention.csv",
    EVIDENCE / "vulnerability-management.csv",
    EVIDENCE / "recovery-drills.csv",
    EVIDENCE / "access-review-log.csv",
    EVIDENCE / "exception-register.csv",
]


def run(cmd: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, text=True, capture_output=True, check=False)


def run_bytes(cmd: list[str]) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(cmd, capture_output=True, check=False)


def gh_local_path(path: Path) -> str:
    result = run(["wslpath", "-w", str(path)])
    if result.returncode == 0 and result.stdout.strip():
        return result.stdout.strip()
    return str(path)


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


def latest_successful_run(repo: str, workflow: str) -> dict | None:
    result = run(
        [
            "gh",
            "run",
            "list",
            "--repo",
            repo,
            "--workflow",
            workflow,
            "--limit",
            "20",
            "--json",
            "databaseId,headSha,status,conclusion,updatedAt,url",
        ]
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())

    for run_item in json.loads(result.stdout):
        if run_item.get("status") == "completed" and run_item.get("conclusion") == "success":
            return run_item
    return None


def run_artifacts(repo: str, run_id: int) -> list[dict]:
    result = run(["gh", "api", f"repos/{repo}/actions/runs/{run_id}/artifacts"])
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip())
    return json.loads(result.stdout).get("artifacts", [])


def workflow_has_attestation_baseline() -> tuple[bool, list[str]]:
    workflow_text = (ROOT / ".github" / "workflows" / "compliance.yml").read_text(encoding="utf-8")
    expected_tokens = [
        "actions/attest@f6bf1532d7d6793fce74eac584813a8eee607999",
        "gh attestation verify",
        "attestations: write",
        "id-token: write",
        "artifact-metadata: write",
        COMPLIANCE_BUNDLE_ARTIFACT,
        COMPLIANCE_ATTESTATION_ARTIFACT,
    ]
    missing = [token for token in expected_tokens if token not in workflow_text]
    return (len(missing) == 0, missing)


def verify_latest_attestation() -> tuple[bool, str]:
    latest_run = latest_successful_run(COMPLIANCE_REPO, COMPLIANCE_WORKFLOW)
    if not latest_run:
        return (False, "No successful compliance workflow run found for attestation verification")

    run_id = latest_run["databaseId"]
    updated_at = latest_run["updatedAt"]
    if days_old(updated_at[:10]) > ATTESTATION_MAX_AGE_DAYS:
        return (False, f"Latest successful compliance run is stale: {updated_at}")

    artifacts = run_artifacts(COMPLIANCE_REPO, run_id)
    artifacts_by_name = {artifact["name"]: artifact for artifact in artifacts}
    artifact_names = set(artifacts_by_name)
    missing_artifacts = sorted(
        {COMPLIANCE_BUNDLE_ARTIFACT, COMPLIANCE_ATTESTATION_ARTIFACT}.difference(artifact_names)
    )
    if missing_artifacts:
        return (False, f"Latest successful compliance run {run_id} is missing artifact(s): {', '.join(missing_artifacts)}")

    with tempfile.TemporaryDirectory(prefix="compliance-attestation-") as tmp_dir:
        bundle_artifact = artifacts_by_name[COMPLIANCE_BUNDLE_ARTIFACT]
        download = run_bytes(
            [
                "gh",
                "api",
                f"repos/{COMPLIANCE_REPO}/actions/artifacts/{bundle_artifact['id']}/zip",
            ]
        )
        if download.returncode != 0:
            details = (download.stderr or download.stdout).decode(errors="replace").strip()
            return (False, f"Unable to download compliance bundle from run {run_id}: {details}")

        with zipfile.ZipFile(BytesIO(download.stdout)) as archive:
            archive.extractall(tmp_dir)

        bundle_paths = sorted(Path(tmp_dir).rglob("compliance-evidence-*.tar.gz"))
        if not bundle_paths:
            return (False, f"Compliance bundle artifact from run {run_id} did not contain a .tar.gz file")

        verify = run(
            [
                "gh",
                "attestation",
                "verify",
                gh_local_path(bundle_paths[0]),
                "--repo",
                COMPLIANCE_REPO,
                "--signer-workflow",
                COMPLIANCE_WORKFLOW_REF,
                "--source-ref",
                "refs/heads/master",
                "--format",
                "json",
            ]
        )
        if verify.returncode != 0:
            details = (verify.stderr or verify.stdout).strip()
            return (False, f"Attestation verification failed for run {run_id}: {details}")

    return (True, f"Verified attested compliance bundle from run {run_id} for commit {latest_run['headSha']}")


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

    has_workflow_attestation, missing_tokens = workflow_has_attestation_baseline()
    if not has_workflow_attestation:
        errors.append(f"Compliance workflow attestation baseline missing token(s): {', '.join(missing_tokens)}")

    asset_rows = csv_rows(EVIDENCE / "asset-inventory.csv")
    supply_chain_rows = csv_rows(EVIDENCE / "supply-chain-controls.csv")
    release_rows = csv_rows(EVIDENCE / "release-evidence.csv")
    sbom_rows = csv_rows(EVIDENCE / "sbom-evidence.csv")
    change_rows = csv_rows(EVIDENCE / "change-management.csv")
    crosswalk_rows = csv_rows(EVIDENCE / "control-crosswalk.csv")
    retention_rows = csv_rows(EVIDENCE / "evidence-retention.csv")
    vulnerability_rows = csv_rows(EVIDENCE / "vulnerability-management.csv")
    if len(asset_rows) != 15:
        errors.append(f"Expected 15 asset inventory rows, found {len(asset_rows)}")
    if len(supply_chain_rows) != 15:
        errors.append(f"Expected 15 supply-chain rows, found {len(supply_chain_rows)}")
    if len(release_rows) != 15:
        errors.append(f"Expected 15 release-evidence rows, found {len(release_rows)}")
    if len(change_rows) != 15:
        errors.append(f"Expected 15 change-management rows, found {len(change_rows)}")
    if len(vulnerability_rows) != 15:
        errors.append(f"Expected 15 vulnerability-management rows, found {len(vulnerability_rows)}")
    if len(sbom_rows) == 0:
        errors.append("No SBOM evidence rows found")
    if len(crosswalk_rows) < 8:
        errors.append(f"Expected at least 8 control crosswalk rows, found {len(crosswalk_rows)}")
    if len(retention_rows) < 8:
        errors.append(f"Expected at least 8 evidence-retention rows, found {len(retention_rows)}")

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

    for row in release_rows:
        repo = row["repository"]
        repo_path = local_repo_paths[repo]
        if row["pages_workflow"] == "true" and not (repo_path / ".github" / "workflows" / "pages.yml").exists():
            errors.append(f"Pages workflow baseline missing for {repo}")
        if row["release_policy_source"] == "missing":
            errors.append(f"Release policy source missing for {repo}")

    generated_sboms = [row for row in sbom_rows if row["status"] == "generated" and row["sbom_path"]]
    if len(generated_sboms) < 5:
        errors.append(f"Expected at least 5 generated SBOM artifacts, found {len(generated_sboms)}")
    missing_sbom_files = [
        row["sbom_path"] for row in generated_sboms
        if not (ROOT / row["sbom_path"]).exists()
    ]
    if missing_sbom_files:
        errors.append(f"Missing generated SBOM artifact(s): {', '.join(missing_sbom_files[:5])}")
    allow_skipped_sboms = os.environ.get("ALLOW_SKIPPED_SBOM_TARGETS") == "1"
    failed_sboms = [row for row in sbom_rows if row["status"] not in {"generated"}]
    if allow_skipped_sboms:
        failed_sboms = [row for row in failed_sboms if row["status"] != "skipped"]
    if failed_sboms:
        errors.append(f"SBOM generation failed for {len(failed_sboms)} target(s)")

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
    missing_recovery_evidence = [
        row["evidence_ref"] for row in recovery_rows
        if row["status"] == "passed"
        and row["evidence_ref"].startswith("evidence/")
        and not (ROOT / row["evidence_ref"]).exists()
    ]
    if missing_recovery_evidence:
        errors.append(f"Missing recovery evidence reference(s): {', '.join(missing_recovery_evidence)}")

    access_rows = csv_rows(EVIDENCE / "access-review-log.csv")
    if any(row["result"] == "missing" for row in access_rows):
        warnings.append("Access review evidence is still missing")
    fresh_access = [
        row for row in access_rows
        if row["review_date"] and row["result"] == "passed" and days_old(row["review_date"]) <= 90
    ]
    if not fresh_access:
        errors.append("No passed access review within the last 90 days")

    fresh_change_rows = [
        row for row in change_rows
        if row["review_date"] and days_old(row["review_date"]) <= 90
    ]
    if len(fresh_change_rows) != 15:
        errors.append("Change-management evidence is missing a full fresh portfolio snapshot")

    fresh_vulnerability_rows = [
        row for row in vulnerability_rows
        if row["review_date"] and days_old(row["review_date"]) <= 90
    ]
    if len(fresh_vulnerability_rows) != 15:
        errors.append("Vulnerability-management evidence is missing a full fresh portfolio snapshot")
    if any(row["security_policy"] != "true" for row in vulnerability_rows):
        errors.append("At least one managed repository is missing SECURITY.md")
    if any(row["dependabot"] != "true" or row["codeql"] != "true" for row in vulnerability_rows):
        errors.append("At least one managed repository is missing vulnerability scanning baseline coverage")

    exception_rows = csv_rows(EVIDENCE / "exception-register.csv")
    open_exceptions = [row for row in exception_rows if row["status"] == "open"]
    if open_exceptions:
        warnings.append(f"{len(open_exceptions)} open exception(s) remain")

    if os.environ.get("SKIP_REMOTE_ATTESTATION_VERIFY") != "1":
        try:
            attestation_ok, attestation_note = verify_latest_attestation()
        except RuntimeError as exc:
            errors.append(f"Unable to inspect GitHub attestation state: {exc}")
        else:
            if not attestation_ok:
                errors.append(attestation_note)

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
