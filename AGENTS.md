# Phoenix DevOps Platform — Agent Guide

## Local Development (Kind — no AWS costs)

This project runs **completely locally** via Kind. The Terraform in `infrastructure/` provisions real AWS resources and **will cost money** if applied.

```powershell
kind create cluster --name phoenix --config kind-config.yaml
docker build -t phoenix-app:local .
kind load docker-image phoenix-app:local --name phoenix
kubectl apply -f k8s-manifests/
kubectl port-forward deployment/phoenix-deployment 5000:5000
kubectl port-forward svc/phoenix-app-service 8080:8080
```

`k8s-manifests/deployment.yml` currently references an **AWS ECR URL** (for EKS deployment). For local Kind dev, change `image` back to `phoenix-app:local` and `imagePullPolicy` to `IfNotPresent`.

## Architecture

- **App**: `src/app.py` — Flask on `:5000`, Prometheus metrics on `:8000`. Unused import: `jsonify` on line 1.
- **Docker**: Multi-stage build (`python:3.11-slim`), exposes 5000/8000
- **K8s manifests**: `deployment.yml` (2 replicas, ECR image, `Always` pull), `service.yml` (type LoadBalancer — creates real AWS LB on EKS)
- **Kind cluster**: 1 control-plane + 1 worker (defined in `kind-config.yaml`)

## AWS / CI Workflow (separate from local)

The CI pipeline at `.github/workflows/ci.yml` pushes to **AWS ECR** (`phoenix-app` repo). It requires GitHub secrets `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` and an existing ECR repo.

**CI does NOT auto-deploy to EKS** — it only pushes to ECR. After CI passes, manually run `kubectl apply -f k8s-manifests/` or restart pods to pull the new image.

CI will **fail** if:
- AWS secrets are not set in GitHub
- ECR repo `phoenix-app` doesn't exist in `ap-south-1`
- Trivy finds CRITICAL/HIGH vulnerabilities (`exit-code: '1'`, filesystem scan mode)

## Terraform (`infrastructure/`)

Currently configured with `t3.medium` instance type. Creates: VPC + NAT gateway ($~32/mo), EKS cluster ($~73/mo), 2x t3.medium EC2 ($~8/mo), ECR repo. No resources are AWS free tier eligible.

`enable_nat_gateway = true` with `single_nat_gateway = true` in `vpc.tf` — NAT is required for private subnets but is the second-largest cost after EKS.

## `.gitignore` quirks

`*.exe` is gitignored, so `kind.exe`/`kubectl.exe` won't commit. `.terraform.lock.hcl`, `terraform.tfstate`, `terraform.tfstate.backup` are also gitignored but exist locally (leftover from a prior run).
