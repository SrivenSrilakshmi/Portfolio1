$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

Write-Host "Applying namespace and workloads..." -ForegroundColor Cyan
kubectl apply -f "$root/k8s/namespace.yaml"
kubectl apply -f "$root/k8s/workloads.yaml"

Write-Host "Waiting for workloads to be ready..." -ForegroundColor Cyan
kubectl -n mesh-demo rollout status deployment/backend
kubectl -n mesh-demo rollout status deployment/frontend

Write-Host "Applying Istio security policies..." -ForegroundColor Cyan
kubectl apply -f "$root/istio/peer-authentication.yaml"
kubectl apply -f "$root/istio/destination-rule.yaml"
kubectl apply -f "$root/istio/authorization-policy.yaml"

Write-Host "Deployment complete." -ForegroundColor Green
