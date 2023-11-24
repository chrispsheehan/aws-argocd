#!/bin/bash

echo getting admin secret
ADMIN_SECRET=$(sudo su -s /bin/bash -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo" ec2-user)
echo logging in
sudo su -s /bin/bash -c "argocd login --insecure localhost:8999 --username admin --password $ADMIN_SECRET" ec2-user

echo creating app
sudo su -s /bin/bash -c "kubectl create namespace test" ec2-user
sudo su -s /bin/bash -c "argocd app create test --server localhost:8999 --dest-namespace argocd --dest-server https://kubernetes.default.svc --repo https://github.com/chrispsheehan/aws-argocd --path k8s/manifests --revision main --sync-policy automated" ec2-user
sudo su -s /bin/bash -c "argocd app sync test" ec2-user