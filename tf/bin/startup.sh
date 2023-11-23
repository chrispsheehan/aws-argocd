#!/bin/bash
# install docker service
echo installing docker
sudo yum update -y
sudo yum search docker
sudo yum info docker
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
id ec2-user
newgrp docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

# install minikube
echo installing minikube
sudo yum install conntrack-tools.x86_64 -y
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
sudo -i
curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.28.0/crictl-v1.28.0-linux-amd64.tar.gz --output crictl-linux-amd64.tar.gz
sudo tar zxvf crictl-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-linux-amd64.tar.gz
sudo su -s /bin/bash -c 'minikube start' ec2-user

# install argocd cli
echo installing argocd cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# create argocd server
echo creating argocd server
sudo su -s /bin/bash -c "kubectl create namespace argocd" ec2-user
sudo su -s /bin/bash -c "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml" ec2-user
sleep 120 # replace with wait for loop https://gist.github.com/chrispsheehan/cc9cca8e918b5e34deeca16ac7c428a6

# expose argocd
echo exposing argocd
sudo su -s /bin/bash -c "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'" ec2-user
sudo su -s /bin/bash -c "kubectl port-forward svc/argocd-server -n argocd 8999:443 &" ec2-user

# set admin secret
echo getting admin secret
export ADMIN_SECRET=$(sudo su -s /bin/bash -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo" ec2-user)
sudo su -s /bin/bash -c "echo secret:$ADMIN_SECRET" ec2-user
echo logging in
sudo su -s /bin/bash -c "argocd login --insecure localhost:8999 --username admin --password $ADMIN_SECRET" ec2-user

# create app
echo creating app
sudo su -s /bin/bash -c "kubectl create namespace test" ec2-user
sudo su -s /bin/bash -c "argocd app create test --server localhost:8999 --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://github.com/chrispsheehan/aws-argocd --path k8s/manifests --revision main --sync-policy automated" ec2-user
sudo su -s /bin/bash -c "argocd app sync test" ec2-user