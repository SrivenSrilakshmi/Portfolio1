# Kong API Security Framework

This project demonstrates API security controls with Kong and API gateway patterns:
- JWT authentication for protected APIs
- OAuth2 plugin policy definition for client-credential and authorization-code flows
- Rate limiting for traffic governance and abuse control

## Project structure

- `k8s/namespace.yaml`: demo namespace
- `k8s/echo-app.yaml`: sample backend API workload
- `k8s/plugins/rate-limit.yaml`: rate-limiting plugin
- `k8s/plugins/jwt-auth.yaml`: JWT auth plugin
- `k8s/plugins/oauth2.yaml`: OAuth2 plugin policy
- `k8s/consumer-and-jwt-secret.yaml`: Kong consumer and JWT credential
- `k8s/ingress.yaml`: secured ingress attaching plugins
- `scripts/deploy.ps1`: apply resources
- `scripts/validate.ps1`: verification checklist

## Prerequisites

- Kubernetes cluster
- Kong Ingress Controller installed and configured
- Kong CRDs available (`KongPlugin`, `KongConsumer`)
- kubectl access to cluster

## Deploy

```powershell
./scripts/deploy.ps1
```

## Validate

```powershell
./scripts/validate.ps1
```

## Security notes

- Replace demo JWT secret values before real deployment.
- For production OAuth2 usage, back Kong with durable storage and integrate an identity provider.
- Tune rate limits and plugin order based on threat model and API SLOs.
