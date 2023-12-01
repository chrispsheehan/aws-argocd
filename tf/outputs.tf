output "app-url" {
  value = "http://${aws_instance.server.public_dns}:${local.argocd_app_port}"
}

output "argocd-url" {
  value = "http://${aws_instance.server.public_dns}:${local.argocd_server_port}"
}
