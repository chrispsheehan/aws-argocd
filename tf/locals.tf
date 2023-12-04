locals {
  ec2_user                  = "ec2-user"
  target_argocd_repo        = "https://github.com/chrispsheehan/aws-argocd"
  target_argocd_repo_branch = "main"
  argocd_manifests_url      = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  argocd_server_port        = 8999
  argocd_app_name           = "test-app"
  argocd_app_namespace      = "test"
  argocd_app_port           = 9376         # must match k8s/nginx-service.yaml
  argocd_app_svc_name       = "my-service" # must match k8s/nginx-service.yaml
  ssh_key_file              = "private_key.pem"
  ifconfig_co_json          = jsondecode(data.http.my_public_ip.response_body)
}
