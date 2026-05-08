param(
  [string]$BaselinePath = "./config/baseline.sample.json",
  [string]$Profile,
  [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$python = "python"

Push-Location $root
try {
  $args = @(
    "src/iam_drift_detector.py",
    "--baseline", $BaselinePath,
    "--report-dir", "reports"
  )

  if ($Profile) {
    $args += @("--profile", $Profile)
  }

  if ($Region) {
    $args += @("--region", $Region)
  }

  & $python @args
}
finally {
  Pop-Location
}
