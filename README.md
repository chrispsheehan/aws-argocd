# aws-argocd

What problem(s) are we looking to solve?

- AWS EKS is expensive and can be difficult to configure.
    - This repo leverages terraform, argoCD and EC2 in creating ephemeral environments.


## deploy aws infrastructure

- Create AWS account [here]9https://aws.amazon.com/resources/create-account/0
- Associate credentials as per [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

```sh
terraform init
terraform plan
terraform apply
```