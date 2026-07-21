# go-gin-app

A Go/Gin web application deployed to AWS EKS via GitHub Actions and Terraform.

## Architecture

```
Internet User → ALB → EKS (Go/Gin pods x2) ← ECR (Docker images)
```

- **Runtime**: Go 1.22 / Gin
- **Container Registry**: Amazon ECR
- **Orchestration**: Amazon EKS (Kubernetes 1.33)
- **Load Balancer**: AWS ALB via aws-load-balancer-controller
- **IaC**: Terraform (S3 backend, platform-managed)
- **CI/CD**: GitHub Actions (5 stages: lint → build_push → provision → configure → verify)

## Endpoints

| Path | Description |
|---|---|
| `/` | Landing page (HTML) |
| `/health` | Health check (`{"status":"ok","uptime":"..."}`) |
| `/api/info` | App info JSON |

## Local Development

**Prerequisites**: Go 1.22+

```bash
# Install dependencies
go mod download

# Run locally
PORT=3000 go run .

# Open in browser
open http://localhost:3000
```

## Docker

```bash
# Build
docker build -t go-gin-app:dev .

# Run
docker run -p 3000:3000 go-gin-app:dev
```

## Deployment

The pipeline runs automatically on push to `main`:

| Stage | What it does |
|---|---|
| `lint` | `go vet` + `gofmt` check |
| `build_push` | Builds binary, Docker image, pushes to ECR |
| `provision` | Terraform: VPC, EKS cluster, node group, ECR, IAM roles |
| `configure` | Installs aws-load-balancer-controller (Helm), deploys k8s manifests |
| `verify` | Waits for ALB, health-checks `/health` with retries |

## Configuration

| Variable | Where | Description |
|---|---|---|
| `PORT` | env | App listen port (default: `3000`) |
| `GIN_MODE` | env | Gin mode (`release` in production) |
| `AWS_ACCESS_KEY_ID` | CI secret | AWS credentials (set by platform) |
| `AWS_SECRET_ACCESS_KEY` | CI secret | AWS credentials (set by platform) |
| `TF_STATE_BUCKET` | CI secret | Terraform state bucket (set by platform) |
| `PROJECT_NAME` | CI secret | Project/resource prefix (set by platform) |

## Operations

```bash
# Get cluster credentials
aws eks update-kubeconfig --region us-east-1 --name <PROJECT_NAME>-eks

# Check pods
kubectl get pods -n go-gin-app

# View logs
kubectl logs -n go-gin-app -l app=go-gin-app --tail=100

# Restart deployment
kubectl rollout restart deployment/go-gin-app -n go-gin-app

# Get ALB endpoint
kubectl get ingress go-gin-app -n go-gin-app
```

## Destroy

Use the **Destroy** action in the UDAP platform to tear down all AWS resources.
Terraform will destroy: EKS cluster, node group, VPC, subnets, NAT gateways, ECR, IAM roles.
