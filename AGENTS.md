# Phoenix DevOps Platform — Agent Guide

## Project scope

This repo provisions AWS infra via Terraform and deploys a Flask app to it. **There is no code that installs ArgoCD, Prometheus, or Grafana** — those are architectural concepts in the README only. The only Prometheus code is the Python client (`prometheus-client` in `requirements.txt`, imported in `src/app.py:2`) for exporting app metrics. No Helm charts, no install scripts, no Terraform resources exist for them.

## Local Development (Kind — no AWS costs)

```powershell
kind create cluster --name phoenix --config kind-config.yaml
docker build -t phoenix-app:local .
kind load docker-image phoenix-app:local --name phoenix
kubectl apply -f k8s-manifests/
kubectl port-forward deployment/phoenix-deployment 5000:5000
kubectl port-forward svc/phoenix-app-service 8080:8080
```

`k8s-manifests/deployment.yml` currently uses `image: phoenix-app:local` with `imagePullPolicy: IfNotPresent` — already set up for local Kind dev. For EKS deployment, change these to the ECR URL and `Always`.

## Architecture

- **App**: `src/app.py` — Flask on `:5000`, Prometheus `/metrics` endpoint on `:8000`. Unused import: `jsonify` on line 1.
- **Docker**: Multi-stage build (`python:3.11-slim`), exposes 5000/8000
- **K8s manifests**: `deployment.yml` (2 replicas), `service.yml` (type NodePort on 80→5000, metrics 8080→8000)
- **Kind cluster**: 1 control-plane + 1 worker (`kind-config.yaml`)
- **No other services** (no ingress, no HPA, no load balancer controller)

## Terraform (`infrastructure/`)

| Resource | Config |
|----------|--------|
| VPC | `vpc.tf` — `enable_nat_gateway = true`, `single_nat_gateway = true` (NAT is second-largest cost after EKS) |
| EKS | `eks.tf` — `instance_types = ["t3."]` (incomplete value, fix before apply; e.g. `"t3.medium"` or `"t3.micro"`) |
| ECR | `ecr.tf` — repo name `phoenix-app` |

**Cost warning**: No resources are AWS free tier eligible. Rough monthly: VPC+NAT ~$32, EKS ~$73, 2x EC2 ~$8, ECR ~$0.

## CI Pipeline (`.github/workflows/ci.yml`)

- Trigger: push to `main`
- Steps: Trivy scan (CRITICAL/HIGH → exit 1 on failure) → Docker build → push to ECR
- **Deploys to EKS** — after push to ECR, runs `kubectl set image` to update the deployment and waits for rollout.
- Requires GitHub secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- ECR repo `phoenix-app` must exist in `ap-south-1`

## `.gitignore` notes

`*.exe` is gitignored — `kind.exe`/`kubectl.exe` won't commit. `.terraform.lock.hcl`, `terraform.tfstate`, `terraform.tfstate.backup` are gitignored but may exist locally as leftovers.
