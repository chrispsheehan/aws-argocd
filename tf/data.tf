data "http" "my_public_ip" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

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

data "template_file" "kubectl-wait-app" {
  template = file("${path.module}/bin/kubectl-pods-wait.tpl")

  vars = {
    EC2_USER         = local.ec2_user
    POD_NAMESPACE    = "test"
    POD_TARGET_COUNT = 3
    TIMEOUT_SECONDS  = 120
  }
}

data "template_file" "kubectl-wait-argocd" {
  template = file("${path.module}/bin/kubectl-pods-wait.tpl")

  vars = {
    EC2_USER         = local.ec2_user
    POD_NAMESPACE    = "argocd"
    POD_TARGET_COUNT = 7
    TIMEOUT_SECONDS  = 120
  }
}

data "template_file" "install-deps" {
  template = file("${path.module}/bin/install-deps.tpl")

  vars = {
    EC2_USER = local.ec2_user
  }
}

data "template_file" "argocd-server" {
  template = file("${path.module}/bin/argocd-server.tpl")

  vars = {
    EC2_USER             = local.ec2_user
    ARGOCD_MANIFESTS_URL = local.argocd_manifests_url
  }
}

data "template_file" "argocd-app" {
  template = file("${path.module}/bin/argocd-app.tpl")

  vars = {
    EC2_USER             = local.ec2_user
    ARGOCD_REPO          = local.target_argocd_repo
    ARGOCD_REPO_BRANCH   = local.target_argocd_repo_branch
    ARGOCD_SERVER_PORT   = local.argocd_server_port
    ARGOCD_APP_NAME      = local.argocd_app_name
    ARGOCD_APP_NAMESPACE = local.argocd_app_namespace
    ARGOCD_APP_PORT      = local.argocd_app_port
  }
}

data "template_file" "argocd-app-expose" {
  template = file("${path.module}/bin/argocd-app-expose.tpl")

  vars = {
    EC2_USER             = local.ec2_user
    ARGOCD_REPO          = local.target_argocd_repo
    ARGOCD_REPO_BRANCH   = local.target_argocd_repo_branch
    ARGOCD_SERVER_PORT   = local.argocd_server_port
    ARGOCD_APP_NAME      = local.argocd_app_name
    ARGOCD_APP_NAMESPACE = local.argocd_app_namespace
    ARGOCD_APP_PORT      = local.argocd_app_port
    ARGOCD_APP_SVC_NAME  = local.argocd_app_svc_name
  }
}

