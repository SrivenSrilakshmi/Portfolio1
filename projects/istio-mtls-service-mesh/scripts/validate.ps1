$ErrorActionPreference = "Stop"

$frontendPod = kubectl -n mesh-demo get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}'

Write-Host "Testing allowed request from frontend to backend..." -ForegroundColor Cyan
kubectl -n mesh-demo exec $frontendPod -- curl -s -H "x-client-app: frontend" http://backend:8080

Write-Host "Testing blocked request (missing header policy match)..." -ForegroundColor Cyan
kubectl -n mesh-demo exec $frontendPod -- curl -s -o /dev/null -w "%{http_code}" http://backend:8080
Write-Host "If AuthorizationPolicy is working, this should print 403." -ForegroundColor Yellow
