output "ec2-dns" {
  value = aws_instance.server.public_dns
}
