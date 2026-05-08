param(
  [string]$OutputPath = "./config/baseline.generated.json",
  [string[]]$RoleNames,
  [string]$Profile,
  [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"

if (-not $RoleNames -or $RoleNames.Count -eq 0) {
  throw "Provide at least one role name using -RoleNames."
}

$root = Split-Path -Parent $PSScriptRoot
$python = "python"

Push-Location $root
try {
  $args = @(
    "src/iam_drift_detector.py",
    "--export-baseline",
    "--output", $OutputPath,
    "--roles"
  )

  $args += $RoleNames

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
