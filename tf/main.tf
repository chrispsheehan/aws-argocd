resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "this" {
  key_name   = "terraform-ssh-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.this.private_key_openssh
  filename = local.ssh_key_file
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.custom_vpc
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[0]
  cidr_block              = aws_vpc.vpc.cidr_block
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public_rt_association" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.subnet.id
}

resource "aws_security_group" "ec2-sq" {
  name   = "EC2 ArgoCD Security Group"
  vpc_id = aws_vpc.vpc.id

  egress = [
    {
      description      = "for all outgoing traffics"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  dynamic "ingress" {
    for_each = [
      local.argocd_server_port,
      local.argocd_app_port,
      22
    ]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["${local.ifconfig_co_json.ip}/32"]
    }
  }
}

# get logs via cat /var/log/cloud-init-output.log
resource "aws_instance" "server" {
  ami                    = data.aws_ami.amazonlinux2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  availability_zone      = data.aws_availability_zones.azs.names[0]
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.ec2-sq.id]

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    iops                  = 3000
    throughput            = 125
    volume_size           = 32
  }

  user_data = <<-EOF
    ${data.template_file.install-deps.rendered}
    ${data.template_file.argocd-server.rendered}
    ${data.template_file.kubectl-wait-argocd.rendered}
    ${data.template_file.argocd-app.rendered}
    ${data.template_file.kubectl-wait-app.rendered}
    ${data.template_file.argocd-app-expose.rendered}
  EOF
}
