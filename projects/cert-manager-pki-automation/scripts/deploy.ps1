$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

Write-Host "Applying namespace..." -ForegroundColor Cyan
kubectl apply -f "$root/k8s/namespace.yaml"

Write-Host "Applying cert-manager bootstrap issuer..." -ForegroundColor Cyan
kubectl apply -f "$root/cert-manager/bootstrap-selfsigned-issuer.yaml"

Write-Host "Creating root CA certificate..." -ForegroundColor Cyan
kubectl apply -f "$root/cert-manager/root-ca-certificate.yaml"

Write-Host "Waiting for root CA to become Ready..." -ForegroundColor Cyan
kubectl -n cert-manager wait --for=condition=Ready certificate/root-ca --timeout=120s

Write-Host "Applying CA ClusterIssuer..." -ForegroundColor Cyan
kubectl apply -f "$root/cert-manager/ca-clusterissuer.yaml"

Write-Host "Issuing workload certificate..." -ForegroundColor Cyan
kubectl apply -f "$root/cert-manager/workload-certificate.yaml"

Write-Host "Waiting for workload certificate to become Ready..." -ForegroundColor Cyan
kubectl -n pki-demo wait --for=condition=Ready certificate/app-server-tls --timeout=120s

Write-Host "PKI automation deployment complete." -ForegroundColor Green
