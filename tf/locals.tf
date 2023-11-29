locals {
  ec2_user             = "ec2-user"
  target_argo_repo     = "https://github.com/chrispsheehan/aws-argocd"
  argocd_manifests_url = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
}
