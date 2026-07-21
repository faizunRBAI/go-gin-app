variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name (used as resource prefix and tag)"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS managed node group"
  type        = string
  default     = "t3.medium"
}

variable "node_desired" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 2
}

variable "node_min" {
  description = "Minimum number of nodes in the managed node group"
  type        = number
  default     = 1
}

variable "node_max" {
  description = "Maximum number of nodes in the managed node group"
  type        = number
  default     = 3
}
