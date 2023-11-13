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
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }
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
  vpc_security_group_ids = [aws_security_group.ec2-sq.id]

  user_data = <<-EOF
#!/bin/bash
sudo yum update
sudo yum install httpd -y
sudo dnf update -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo ufw allow http
sudo ufw allow https
sudo bash -c 'echo "<!DOCTYPE html><html><head> <title>ChrisPSheehan.com</title></head><body> <h1>ChrisPSheehan.com</h1> <p>badgers $(hostname -f)</p></body></html>" > /var/www/html/index.html'
EOF
}