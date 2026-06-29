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

- **App**: `src/app.py` — Flask on `:5000`, Prometheus `/metrics` on `:8000` (via `start_http_server`, not a Flask route). Uses `render_template_string`.
- **Docker**: Multi-stage `python:3.11-slim`, exposes 5000/8000. Missing `.dockerignore`.
- **K8s manifests**: `deployment.yaml` (2 replicas, resource limits), `service.yaml` (NodePort 80→5000, 8080→8000), `ingress.yaml` (ALB via AWS LB Controller, host-based routing, HTTP only).
- **Terraform** (apply from `infrastructure/`): VPC (3 AZs, 1 NAT gateway), EKS (t3.small, v1.31), ECR (`phoenix-app`). No Terraform backend configured. No ALB resource in Terraform — the ingress YAML handles it.
- **Two-repo GitOps**: App repo (`EKS-GitOps-Engine-`) + manifests repo (`phoenix-manifests-`). CI pushes to manifests repo. ArgoCD watches manifests repo. See `argocd/application.yml`.

## CI Pipeline (`.github/workflows/ci.yaml`)

- Trigger: push to `main`
- Steps: Trivy scan (CRITICAL/HIGH → exit 1) → Docker build → push to ECR → update `deployment.yaml` image tag → push to manifests repo (via `GH_PAT` secret)
- **Deploys via GitOps**: CI pushes to `phoenix-manifests-` repo → ArgoCD auto-syncs to cluster. No `kubectl` step needed.
- Requires GitHub secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `GH_PAT` (PAT with repo scope for pushing to manifests repo)
- ECR repo `phoenix-app` must exist in `ap-south-1`

## Cost

No AWS free tier. Roughly: VPC+NAT ~$32, EKS ~$73, 2x t3.small EC2 ~$12, ECR ~$0/mo. Total ~$117/mo.

## Git configs (from committed files)

- ArgoCD Application in `argocd/application.yml` points to `phoenix-manifests-` repo (two-repo GitOps model).
- Monitoring Helm values: `monitoring/prometheus/values.yaml`, `monitoring/grafana/values.yaml`, `helm/argocd/values.yaml` — these are chart values, not install scripts. No code installs these tools.
- `.gitignore`: `*.exe`, `.terraform/`, `terraform.tfstate*`

## Obsidian Study Guide

The project study guide (architecture, commands, 65+ interview Q&A, session logs) lives at:
`G:\My Drive\Obsidian Vault\lean to cloud\eks.md`

Keep this updated whenever we make changes or discover new concepts.
