module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = "1.36"

  subnet_ids                    = module.vpc.private_subnets
  vpc_id                        = module.vpc.vpc_id
  additional_security_group_ids = [aws_security_group.cluster.id]

  endpoint_private_access = true
  endpoint_public_access  = false

  # OIDC provider
  enable_irsa = true

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {

    default = {

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.eks_instance_type]


      desired_size = 2
      min_size     = 2
      max_size     = 6

      capacity_type = "ON_DEMAND"
    }

  }
}