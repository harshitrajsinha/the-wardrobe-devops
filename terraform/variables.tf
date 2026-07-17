variable "region" {
  description = "AWS region in which this infrastructure is provisioned"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR range for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs_list" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1c", "us-east-1d"]
}

variable "pub_sub_list" {
  description = "List of public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "prv_sub_list" {
  description = "List of private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "wardrobe-cluster"
}

variable "bastion_instance_type" {
  description = "Bastion host instance type"
  type        = string
  default     = "t3a.small"
}

variable "eks_instance_type" {
  description = "EKS ec2 instance type"
  type        = string
  default     = "t3a.medium" # c7i-flex.large
}