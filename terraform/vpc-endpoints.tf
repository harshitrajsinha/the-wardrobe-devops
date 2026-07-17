locals {
  interface_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "sts",
    "eks",
    "eks-auth",
    "elasticloadbalancing",
    "ssm",
    "ssmmessages",
    "ec2messages",
  ]
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = toset(local.interface_endpoints)
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.cluster_name}-vpce-${each.key}"
  }
}

# S3 gateway endpoint for pulling ECR image layers (ECR stores layers in S3)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = {
    Name = "${var.cluster_name}-vpce-s3"
  }
}
