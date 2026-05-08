import argparse
import csv
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Tuple

import boto3


def build_iam_client(profile: str | None, region: str):
    if profile:
        session = boto3.Session(profile_name=profile, region_name=region)
    else:
        session = boto3.Session(region_name=region)
    return session.client("iam")


def fetch_role_state(iam_client, role_name: str) -> Dict[str, List[str]]:
    managed = []
    inline = []

    paginator = iam_client.get_paginator("list_attached_role_policies")
    for page in paginator.paginate(RoleName=role_name):
        for policy in page.get("AttachedPolicies", []):
            managed.append(policy["PolicyArn"])

    paginator = iam_client.get_paginator("list_role_policies")
    for page in paginator.paginate(RoleName=role_name):
        inline.extend(page.get("PolicyNames", []))

    managed.sort()
    inline.sort()

    return {
        "attached_managed_policies": managed,
        "inline_policy_names": inline,
    }


def export_baseline(iam_client, roles: List[str], output_path: Path) -> None:
    baseline = {"roles": {}}
    for role in roles:
        baseline["roles"][role] = fetch_role_state(iam_client, role)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(baseline, indent=2), encoding="utf-8")
    print(f"Baseline exported to {output_path}")


def compare_sets(expected: List[str], observed: List[str]) -> Tuple[List[str], List[str]]:
    expected_set = set(expected)
    observed_set = set(observed)
    missing = sorted(expected_set - observed_set)
    unexpected = sorted(observed_set - expected_set)
    return missing, unexpected


def detect_drift(iam_client, baseline: Dict) -> Dict:
    drifts = []
    roles = baseline.get("roles", {})

    for role_name, expected in roles.items():
        role_result = {
            "role": role_name,
            "status": "in-sync",
            "findings": [],
        }

        try:
            observed = fetch_role_state(iam_client, role_name)
        except Exception as exc:
            role_result["status"] = "error"
            role_result["findings"].append(
                {
                    "type": "role_access_error",
                    "severity": "high",
                    "message": str(exc),
                }
            )
            drifts.append(role_result)
            continue

        missing_managed, unexpected_managed = compare_sets(
            expected.get("attached_managed_policies", []),
            observed.get("attached_managed_policies", []),
        )

        missing_inline, unexpected_inline = compare_sets(
            expected.get("inline_policy_names", []),
            observed.get("inline_policy_names", []),
        )

        if missing_managed or unexpected_managed or missing_inline or unexpected_inline:
            role_result["status"] = "drift"

        for policy_arn in missing_managed:
            role_result["findings"].append(
                {
                    "type": "missing_managed_policy",
                    "severity": "medium",
                    "message": f"Expected managed policy missing: {policy_arn}",
                }
            )

        for policy_arn in unexpected_managed:
            role_result["findings"].append(
                {
                    "type": "unexpected_managed_policy",
                    "severity": "high",
                    "message": f"Unexpected managed policy attached: {policy_arn}",
                }
            )

        for policy_name in missing_inline:
            role_result["findings"].append(
                {
                    "type": "missing_inline_policy",
                    "severity": "medium",
                    "message": f"Expected inline policy missing: {policy_name}",
                }
            )

        for policy_name in unexpected_inline:
            role_result["findings"].append(
                {
                    "type": "unexpected_inline_policy",
                    "severity": "high",
                    "message": f"Unexpected inline policy found: {policy_name}",
                }
            )

        drifts.append(role_result)

    return {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "summary": {
            "roles_scanned": len(roles),
            "roles_with_drift": sum(1 for x in drifts if x["status"] == "drift"),
            "roles_in_sync": sum(1 for x in drifts if x["status"] == "in-sync"),
            "roles_with_error": sum(1 for x in drifts if x["status"] == "error"),
        },
        "results": drifts,
    }


def write_reports(report: Dict, report_dir: Path) -> Tuple[Path, Path]:
    report_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    json_path = report_dir / f"iam-drift-report-{timestamp}.json"
    csv_path = report_dir / f"iam-drift-report-{timestamp}.csv"

    json_path.write_text(json.dumps(report, indent=2), encoding="utf-8")

    with csv_path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=["role", "status", "finding_type", "severity", "message"],
        )
        writer.writeheader()

        for role_result in report["results"]:
            if not role_result["findings"]:
                writer.writerow(
                    {
                        "role": role_result["role"],
                        "status": role_result["status"],
                        "finding_type": "",
                        "severity": "",
                        "message": "",
                    }
                )
                continue

            for finding in role_result["findings"]:
                writer.writerow(
                    {
                        "role": role_result["role"],
                        "status": role_result["status"],
                        "finding_type": finding["type"],
                        "severity": finding["severity"],
                        "message": finding["message"],
                    }
                )

    return json_path, csv_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Detect IAM role policy drift against a baseline.")

    parser.add_argument("--profile", help="AWS profile name", default=None)
    parser.add_argument("--region", help="AWS region for session context", default="us-east-1")

    parser.add_argument("--baseline", help="Path to baseline JSON", default="config/baseline.sample.json")
    parser.add_argument("--report-dir", help="Directory for generated reports", default="reports")

    parser.add_argument("--export-baseline", action="store_true", help="Export baseline JSON for provided role names")
    parser.add_argument("--roles", nargs="*", default=[], help="Role names for baseline export")
    parser.add_argument("--output", default="config/baseline.generated.json", help="Output file when exporting baseline")

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    iam_client = build_iam_client(args.profile, args.region)

    if args.export_baseline:
        if not args.roles:
            raise ValueError("--roles is required when using --export-baseline")
        export_baseline(iam_client, args.roles, Path(args.output))
        return

    baseline_path = Path(args.baseline)
    if not baseline_path.exists():
        raise FileNotFoundError(f"Baseline file not found: {baseline_path}")

    baseline = json.loads(baseline_path.read_text(encoding="utf-8"))
    report = detect_drift(iam_client, baseline)

    json_report, csv_report = write_reports(report, Path(args.report_dir))

    summary = report["summary"]
    print("IAM drift scan complete")
    print(f"Roles scanned: {summary['roles_scanned']}")
    print(f"Roles in sync: {summary['roles_in_sync']}")
    print(f"Roles with drift: {summary['roles_with_drift']}")
    print(f"Roles with error: {summary['roles_with_error']}")
    print(f"JSON report: {json_report}")
    print(f"CSV report: {csv_report}")


if __name__ == "__main__":
    main()
