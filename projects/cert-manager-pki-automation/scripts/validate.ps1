$ErrorActionPreference = "Stop"

Write-Host "Checking root CA certificate status..." -ForegroundColor Cyan
kubectl -n cert-manager get certificate root-ca

Write-Host "Checking workload certificate status..." -ForegroundColor Cyan
kubectl -n pki-demo get certificate app-server-tls

Write-Host "Inspecting issued TLS secret metadata..." -ForegroundColor Cyan
kubectl -n pki-demo get secret app-server-tls -o jsonpath='{.type}{"`n"}'

Write-Host "Describing certificate for renewal details..." -ForegroundColor Cyan
kubectl -n pki-demo describe certificate app-server-tls
