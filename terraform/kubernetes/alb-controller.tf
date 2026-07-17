data "aws_vpc" "wardrobe_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.cluster_name}-vpc"]
  }
}

data "aws_eks_cluster" "wardrobe_eks" {
  name = var.cluster_name
}

# Service Account
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
  }
}

# AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"

  chart = "aws-load-balancer-controller"

  namespace = "kube-system"

  create_namespace = false

  version = "1.13.0"

  values = [

    yamlencode({

      clusterName = data.aws_eks_cluster.wardrobe_eks.endpoint

      region = var.region

      vpcId = data.aws_vpc.wardrobe_vpc.id

      serviceAccount = {

        create = false

        name = "aws-load-balancer-controller"

      }

    })

  ]
}