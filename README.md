# aws-argocd

What problem(s) are we looking to solve?
- Setting up argocd can be tricky.
- Off the shelf options (AWS EKS) can be expensive.

This repo leverages terraform, argoCD and EC2 in creating ephemeral environments.

## prerequisite

- Create AWS account [here](https://aws.amazon.com/resources/create-account/)
- Associate credentials as per [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Run one time terraform setup with `just init`

## deploy aws infrastructure

- run `just deploy`
  - note it will take a few minutes to spin up!
- access app via `app-url` output value.
- once finished ensure you run `just destroy`

## log into argocd

- run `just get-password` and obtain from terminal
  - in the below example the password is `slZ9tG0Sp2O8fjbH`
```bash
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
slZ9tG0Sp2O8fjbH
```
- username is `admin`
- access argocd UI via `argocd-url` output value.
  - note you may be (initially) blocked and have to bypass in the browser

## references

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [terraform](https://www.terraform.io/)
- [EC2](https://aws.amazon.com/pm/ec2/)
- [argocd](https://argo-cd.readthedocs.io/en/stable/)

### gotchas

- error (M1 / terraform)
```sh
╷
│ Error: Incompatible provider version
│ 
│ Provider registry.terraform.io/hashicorp/template v2.2.0 does not have a package available for your current platform, darwin_arm64.
```
- fix
```sh
brew install kreuzwerker/taps/m1-terraform-provider-helper
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```