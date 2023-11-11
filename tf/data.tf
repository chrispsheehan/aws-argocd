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

data "aws_key_pair" "work-mac" {
  key_name           = "work-mac"
  include_public_key = true
}
