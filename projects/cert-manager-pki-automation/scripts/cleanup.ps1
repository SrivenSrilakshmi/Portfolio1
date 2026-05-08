$ErrorActionPreference = "Continue"
$root = Split-Path -Parent $PSScriptRoot

Write-Host "Deleting workload certificate..." -ForegroundColor Yellow
kubectl delete -f "$root/cert-manager/workload-certificate.yaml" --ignore-not-found

Write-Host "Deleting CA issuer and root CA..." -ForegroundColor Yellow
kubectl delete -f "$root/cert-manager/ca-clusterissuer.yaml" --ignore-not-found
kubectl delete -f "$root/cert-manager/root-ca-certificate.yaml" --ignore-not-found
kubectl delete -f "$root/cert-manager/bootstrap-selfsigned-issuer.yaml" --ignore-not-found

Write-Host "Deleting demo namespace..." -ForegroundColor Yellow
kubectl delete -f "$root/k8s/namespace.yaml" --ignore-not-found

Write-Host "Cleanup complete." -ForegroundColor Green
