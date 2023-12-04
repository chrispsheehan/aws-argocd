# aws-argocd

What problem(s) are we looking to solve?

- AWS EKS is expensive and can be difficult to configure.
    - This repo leverages terraform, argoCD and EC2 in creating ephemeral environments.


## deploy aws infrastructure

- Create AWS account [here](https://aws.amazon.com/resources/create-account/)
- Associate credentials as per [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

```sh
cd tf
terraform init
terraform plan
terraform apply
```

- access app via `app-url` output value.

## local setup

- Install [minikube](https://minikube.sigs.k8s.io/docs/start/)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

```sh
minikube start
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## local test

```sh
minikube start
kubectl port-forward svc/argocd-server -n argocd 8999:443 &
export ADMIN_SECRET=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo)
argocd login --insecure localhost:8999 --username admin --password $ADMIN_SECRET
kubectl create namespace local-test
argocd app create test --server localhost:8999 --dest-namespace local-test --dest-server https://kubernetes.default.svc --repo https://github.com/chrispsheehan/aws-argocd --path k8s/manifests --revision main --sync-policy automated

kubectl get pods -n nginx --field-selector status.phase=Running -o json | jq '.items' | jq length
```

Gotchas

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