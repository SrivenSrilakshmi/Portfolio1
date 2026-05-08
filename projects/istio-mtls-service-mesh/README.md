# Istio Service Mesh Security Model (mTLS + AuthorizationPolicy)

This project demonstrates a secure service-to-service setup in Kubernetes using Istio with:
- Strict mutual TLS (mTLS)
- Workload-to-workload access control via AuthorizationPolicy
- A simple validation flow to prove allowed and denied traffic

## Project structure

- `k8s/namespace.yaml`: namespace with sidecar auto-injection enabled
- `k8s/workloads.yaml`: demo frontend and backend workloads
- `istio/peer-authentication.yaml`: enforces STRICT mTLS
- `istio/destination-rule.yaml`: client-side ISTIO_MUTUAL configuration for backend
- `istio/authorization-policy.yaml`: allows backend access only when policy criteria are met
- `scripts/deploy.ps1`: applies all manifests in deployment order
- `scripts/validate.ps1`: runs positive and negative connectivity checks

## Prerequisites

- Kubernetes cluster (kind, minikube, AKS, EKS, GKE, or similar)
- Istio installed in the cluster
- kubectl configured to target the cluster
- PowerShell 5+ (for scripts)

## Deploy

From this directory:

```powershell
./scripts/deploy.ps1
```

## Validate

```powershell
./scripts/validate.ps1
```

Expected behavior:
- Request with header `x-client-app: frontend` returns `backend-ok`
- Request without required policy context returns `403`

## Cleanup

```powershell
kubectl delete namespace mesh-demo
```

## Notes

- The demo policy uses a header-based condition to make ALLOW vs DENY behavior easy to test.
- In production, prefer stronger identity boundaries with dedicated service accounts and stricter principal matching.
