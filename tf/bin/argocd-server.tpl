echo creating argocd server
sudo su -s /bin/bash -c "kubectl create namespace argocd" ec2-user
sudo su -s /bin/bash -c "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml" ec2-user
