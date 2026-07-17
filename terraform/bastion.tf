data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  user_data_base64            = base64encode(file("./bastion-user-data.sh"))
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "${var.cluster_name}-bastion"
  }

  depends_on = [module.eks]
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}