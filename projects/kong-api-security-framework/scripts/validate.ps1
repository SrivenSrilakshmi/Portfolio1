$ErrorActionPreference = "Stop"

Write-Host "Validation checks for Kong API security" -ForegroundColor Cyan
Write-Host "1) Confirm ingress and plugins are attached" -ForegroundColor Cyan
kubectl -n api-security-demo get ingress echo-secured
kubectl -n api-security-demo get kongplugin

Write-Host "2) Confirm consumer and JWT credential exist" -ForegroundColor Cyan
kubectl -n api-security-demo get kongconsumer demo-consumer
kubectl -n api-security-demo get secret demo-consumer-jwt

Write-Host "3) Functional test" -ForegroundColor Cyan
Write-Host "Send one request without JWT token; expected 401/403 from Kong." -ForegroundColor Yellow
Write-Host "Then send a request with a valid JWT for key=demo-client to verify access." -ForegroundColor Yellow
