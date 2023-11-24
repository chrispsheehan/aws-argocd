#!/bin/bash

echo creating argocd server
sudo su -s /bin/bash -c "kubectl create namespace argocd" ec2-user
sudo su -s /bin/bash -c "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml" ec2-user

echo exposing argocd
sudo su -s /bin/bash -c "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'" ec2-user
sudo su -s /bin/bash -c "kubectl port-forward svc/argocd-server -n argocd 8999:443 &" ec2-user