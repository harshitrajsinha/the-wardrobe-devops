# ---------- Cluster role ----------
data "aws_iam_policy_document" "eks_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"] #EKS
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------- Node group role ----------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] #EC2
    }
  }
}

resource "aws_iam_role" "node" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# For worker nodes SSM agent (if want to directly access)
# resource "aws_iam_role_policy_attachment" "node_ssm" {
#   role       = aws_iam_role.node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# ---------- Bastion role (SSM only, no SSH) ----------
resource "aws_iam_role" "bastion" {
  name               = "${var.cluster_name}-bastion-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Let the bastion call kubectl against the private EKS API
resource "aws_iam_role_policy" "bastion_eks_describe" {
  name = "${var.cluster_name}-bastion-eks-describe"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["eks:DescribeCluster", "eks:ListClusters", "eks:AccessKubernetesApi", "sts:GetCallerIdentity"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.cluster_name}-bastion-profile"
  role = aws_iam_role.bastion.name
}


resource "aws_eks_access_entry" "bastion" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.bastion.arn
}

resource "aws_eks_access_policy_association" "bastion_view" {
  cluster_name  = "wardrobe-cluster"
  principal_arn = aws_iam_role.bastion.arn
  policy_arn    = "arn:aws:iam::aws:policy/eks/policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}


# IAM service account

resource "aws_iam_policy" "albp" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("./iam_policy_alb_controller.json")

}

// https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/5.0.0/submodules/iam-role-for-service-accounts-eks
module "lb_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "alb-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {

    eks = {

      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller"
      ]
    }
  }
}