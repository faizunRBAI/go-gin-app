output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker push/pull"
  value       = aws_ecr_repository.app.repository_url
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for aws-load-balancer-controller (IRSA)"
  value       = aws_iam_role.alb_controller.arn
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}
