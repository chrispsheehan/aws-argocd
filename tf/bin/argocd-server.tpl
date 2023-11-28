#!/bin/bash
export ec2_user=ec2-user

# create argocd server
echo creating argocd server
sudo su -s /bin/bash -c "kubectl create namespace argocd" $ec2_user
sudo su -s /bin/bash -c "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml" $ec2_user

# required wait to prevent issues downstream in script
sleep 45
