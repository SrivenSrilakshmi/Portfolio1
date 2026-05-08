# cert-manager PKI Automation

This project automates certificate lifecycle management in Kubernetes using cert-manager.

It includes:
- Bootstrap of an internal root CA
- CA-backed ClusterIssuer for workload certificate issuance
- Automated issuance of a workload TLS certificate
- Validation and cleanup scripts

## Project structure

- `k8s/namespace.yaml`: demo namespace
- `cert-manager/bootstrap-selfsigned-issuer.yaml`: temporary self-signed bootstrap issuer
- `cert-manager/root-ca-certificate.yaml`: root CA certificate and keypair secret
- `cert-manager/ca-clusterissuer.yaml`: CA-backed ClusterIssuer
- `cert-manager/workload-certificate.yaml`: workload TLS certificate with renewal settings
- `scripts/deploy.ps1`: deploy all resources in correct order
- `scripts/validate.ps1`: verify certificates and secrets
- `scripts/cleanup.ps1`: remove demo resources

## Prerequisites

- Kubernetes cluster
- cert-manager installed and healthy in namespace `cert-manager`
- kubectl configured for the target cluster
- PowerShell 5+

## Deploy

```powershell
./scripts/deploy.ps1
```

## Validate

```powershell
./scripts/validate.ps1
```

## Cleanup

```powershell
./scripts/cleanup.ps1
```

## Rotation and revocation notes

- Rotation is configured with `duration` and `renewBefore` in `workload-certificate.yaml`.
- Revocation strategy in this sample is operational: re-issuing certs by replacing the certificate secret and updating trust distribution.
- For production, integrate an external CA and centralized trust distribution policy.
