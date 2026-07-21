# go-gin-app — Build Notes

## Status
- [x] Plan approved (Tier 1, EKS)
- [x] Scaffold: go/gin
- [x] Dockerfile: multi-stage, non-root, HEALTHCHECK
- [x] Architecture: architecture.d2 written
- [x] IaC: infra/main.tf, variables.tf, outputs.tf, versions.tf
- [x] K8s manifests: k8s/namespace.yaml, serviceaccount.yaml, deployment.yaml (Deployment + Service + Ingress)
- [x] Pipeline: .udap/pipeline.yaml (lint → build_push → provision → configure → verify)
- [x] README.md
- [ ] validate_project
- [ ] create_repo_and_push
- [ ] deploy

## Key Decisions
- **Target**: EKS (managed node group, t3.medium x2, k8s 1.33)
- **ALB**: aws-load-balancer-controller via Helm (IRSA) — avoids NodePort/classic ELB
- **Nodes in private subnets**: NAT gateways for egress; ALB in public subnets
- **ECR**: per-project repo, lifecycle policy (keep 10 images)
- **IRSA**: OIDC provider + IAM role for alb-controller ServiceAccount in kube-system
- **Image tag**: github.sha (immutable per-commit tag)
- **Namespace**: go-gin-app (project-scoped isolation)
- **Self-sufficient jobs**: configure reads TF outputs itself (re-runs terraform init); verify reads cluster name from secret (PROJECT_NAME), never from job outputs
- **No DB**: Tier 1, stateless app

## Gotchas
- ALB controller needs IRSA wired correctly — OIDC provider ARN in the assume-role condition matches the SA name/namespace exactly (kube-system / aws-load-balancer-controller)
- Verify stage polls for ingress hostname up to 20x15s=5 min before failing (ALB provisioning takes time)
- deployment.yaml uses REGISTRY_PLACEHOLDER/go-gin-app-app:latest as placeholder; configure stage replaces it with sed before kubectl apply
- configure stage must re-init terraform (self-sufficient job rule) to read cluster_name and ecr_url
- K8s version 1.33 is in STANDARD EKS support as of 2026-07

## Recovery Notes
(populated during deploy phase)
