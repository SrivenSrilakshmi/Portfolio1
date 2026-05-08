# Python IAM Drift Detection

This project provides a Python-based IAM drift detection workflow for AWS IAM roles.
It compares expected policy state (baseline) against live IAM role configuration and generates audit-ready reports.

## What it checks

- Managed policies attached to each role
- Inline role policies per role
- Missing expected policies
- Unexpected policy additions (high-risk drift indicators)

## Project structure

- `src/iam_drift_detector.py`: baseline export + drift detection engine
- `config/baseline.sample.json`: sample baseline model
- `scripts/export-baseline.ps1`: generate baseline from live IAM roles
- `scripts/run.ps1`: run drift detection against a baseline
- `reports/`: generated JSON and CSV drift reports
- `requirements.txt`: Python dependencies

## Prerequisites

- Python 3.10+
- AWS credentials configured (environment variables or named profile)
- IAM permissions:
  - `iam:ListAttachedRolePolicies`
  - `iam:ListRolePolicies`

## Install

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Export a baseline

```powershell
./scripts/export-baseline.ps1 -RoleNames ExampleAppRole,ExampleReadOnlyRole -OutputPath ./config/baseline.generated.json -Profile default
```

## Run drift detection

```powershell
./scripts/run.ps1 -BaselinePath ./config/baseline.generated.json -Profile default
```

Outputs:
- JSON report in `reports/`
- CSV report in `reports/`

## Interpreting severity

- `high`: unexpected policy attached, or access/read errors on tracked roles
- `medium`: expected policy missing from tracked role

## Security notes

- Do not commit real account identifiers or sensitive role names if repository is public.
- Store production baselines in a restricted repository or encrypted secret store.
