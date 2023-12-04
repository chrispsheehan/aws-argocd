output "app-url" {
  value = "http://${aws_instance.server.public_dns}:${local.argocd_app_port}"
}

output "argocd-url" {
  value = "http://${aws_instance.server.public_dns}:${local.argocd_server_port}"
}

output "pem-file" {
  value = "${local.ssh_key_file}"
}

output "ssh-cmd" {
  value = "ssh -o StrictHostKeychecking=no -i ${local.ssh_key_file} ${local.ec2_user}@${aws_instance.server.public_dns}"
}
