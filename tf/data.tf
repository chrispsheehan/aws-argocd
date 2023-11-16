data "aws_ami" "amazonlinux2" {
  filter {
    name   = "name"
    values = ["al202*-ami-202*.2.*.0-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  most_recent = true
  owners      = ["amazon"]
}

data "aws_availability_zones" "azs" {
  state = "available"
}
