$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

Write-Host "Applying namespace and app workload..." -ForegroundColor Cyan
kubectl apply -f "$root/k8s/namespace.yaml"
kubectl apply -f "$root/k8s/echo-app.yaml"

Write-Host "Applying Kong plugins and consumer credentials..." -ForegroundColor Cyan
kubectl apply -f "$root/k8s/plugins/rate-limit.yaml"
kubectl apply -f "$root/k8s/plugins/jwt-auth.yaml"
kubectl apply -f "$root/k8s/plugins/oauth2.yaml"
kubectl apply -f "$root/k8s/consumer-and-jwt-secret.yaml"

Write-Host "Applying secured ingress..." -ForegroundColor Cyan
kubectl apply -f "$root/k8s/ingress.yaml"

Write-Host "Deployment complete. Ensure Kong Ingress Controller is installed and reachable." -ForegroundColor Green
