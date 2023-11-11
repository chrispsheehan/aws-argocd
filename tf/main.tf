resource "aws_vpc" "vpc" {
  cidr_block           = var.custom_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[0]
  cidr_block              = aws_vpc.vpc.cidr_block
  map_public_ip_on_launch = true
}

resource "aws_security_group" "sq" {
  name        = "EC2 Security Group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

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

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami                    = data.aws_ami.amazonlinux2.id
  instance_type          = "t2.nano"
  key_name               = data.aws_key_pair.work-mac.key_name
  availability_zone      = data.aws_availability_zones.azs.names[0]
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.sq.id]

  user_data = <<-EOF
#!/bin/bash
sudo yum update
EOF
}