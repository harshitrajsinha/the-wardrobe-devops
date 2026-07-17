variable "region" {
  description = "AWS region in which this infrastructure is provisioned"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "wardrobe-cluster"
}

variable "alb_controller_role_arn" {
  description = "ALB controller role arn"
  type        = string
}