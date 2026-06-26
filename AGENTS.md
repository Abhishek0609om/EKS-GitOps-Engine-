# Phoenix DevOps Platform — Agent Guid
## Before you push, verify

```bash
git status                          # uncommitted changes?
git diff HEAD                      # inspect changes
```

Known uncommitted fixes exist in the working tree (ahead of `origin/main` by 1 commit). If they look clean, push them.

## AWS-Only Project

This project targets **EKS on AWS only** — no Kind/local clusters. `deployment.yaml` already uses the ECR URL with `imagePullPolicy: Always`, which is correct for EKS.

## Architecture

- **App**: `src/app.py` — Flask on `:5000`, Prometheus `/metrics` on `:8000` (via `start_http_server`, not a Flask route). Unused import claim in old docs was wrong — it uses `render_template_string`.
- **Docker**: Multi-stage `python:3.11-slim`, exposes 5000/8000. Missing `.dockerignore`.
- **K8s manifests**: `deployment.yaml` (2 replicas, resource limits), `service.yaml` (NodePort 80→5000, 8080→8000), `ingress.yaml` (ALB via AWS LB Controller, host-based routing, HTTP only).
- **Terraform** (apply from `infrastructure/`): VPC (3 AZs, 1 NAT gateway), EKS (t3.micro, v1.30 — EOL), ECR (`phoenix-app`). No Terraform backend configured. No ALB resource in Terraform — the ingress YAML handles it.

## CI Pipeline (`.github/workflows/ci.yaml`)

- Trigger: push to `main`
- Steps: Trivy scan (CRITICAL/HIGH → exit 1) → Docker build → push to ECR → update `deployment.yaml` image tag → commit + push back (message includes `[skip ci]`)
- **Does NOT deploy to EKS** — no `kubectl` step. The app is never updated on the cluster after CI runs. If using ArgoCD, it would sync from the updated YAML in the repo, but ArgoCD is not installed by this repo.
- Requires GitHub secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- ECR repo `phoenix-app` must exist in `ap-south-1`

## Cost

No AWS free tier. Roughly: VPC+NAT ~$32, EKS ~$73, 2x EC2 ~$8, ECR ~$0/mo.

## Git configs (from committed files)

- ArgoCD Application in `argocd/application.yml` points to a **different repo** (`EKS-GitOps-Engine-`). Verify intent.
- Monitoring Helm values: `monitoring/prometheus/values.yaml`, `monitoring/grafana/values.yaml`, `helm/argocd/values.yaml` — these are chart values, not install scripts. No code installs these tools.
- `.gitignore`: `*.exe`, `.terraform/`, `terraform.tfstate*`
