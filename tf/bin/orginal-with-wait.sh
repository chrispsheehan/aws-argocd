#!/bin/bash
# install docker service
echo installing docker
sudo yum update -y
sudo yum search docker
sudo yum info docker
sudo yum install docker -y
export ec2_user=ec2-user
sudo usermod -a -G docker $ec2_user
id $ec2_user
newgrp docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

#!/bin/bash
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
sudo su -s /bin/bash -c 'minikube start' $ec2_user

#!/bin/bash
# install argocd cli
echo installing argocd cli
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

#!/bin/bash
# create argocd server
echo creating argocd server
sudo su -s /bin/bash -c "kubectl create namespace argocd" $ec2_user
sudo su -s /bin/bash -c "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml" $ec2_user

# required wait to prevent issues downstream in script
sleep 45

#!/bin/bash
argocd_counter=1
argocd_pod_count=0
argocd_pod_namespace=argocd
argocd_pod_target_count=7
argocd_timeout_seconds=120

echo "waiting for running pods.."
echo "argocd_pod_namespace=$argocd_pod_namespace"
echo "argocd_pod_target_count=$argocd_pod_target_count"
echo "argocd_timeout_seconds=$argocd_timeout_seconds"

while [ $argocd_counter -le $argocd_timeout_seconds ] && [ $argocd_pod_count -lt $argocd_pod_target_count ]
do
    argocd_pod_count=$(sudo su -s /bin/bash -c "kubectl get pods -n $argocd_pod_namespace --field-selector status.phase=Running -o json | jq '.items' | jq length" $ec2_user)
    echo "$argocd_pod_namespace has $argocd_pod_count running pods"
    ((argocd_counter++))
    if [ $argocd_counter -ge $argocd_timeout_seconds ]
    then
        echo "$argocd_timeout_seconds secound timeout exceeded"
        exit 1
    else
        sleep 1
    fi
done

#!/bin/bash
# expose argocd
echo exposing argocd
sudo su -s /bin/bash -c "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'" $ec2_user
sudo su -s /bin/bash -c "kubectl port-forward svc/argocd-server -n argocd 8999:443 &" $ec2_user

#!/bin/bash
# set admin secret
echo getting admin secret
export ADMIN_SECRET=$(sudo su -s /bin/bash -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo" $ec2_user)
sudo su -s /bin/bash -c "echo secret:$ADMIN_SECRET" $ec2_user
echo logging in
sudo su -s /bin/bash -c "argocd login --insecure localhost:8999 --username admin --password $ADMIN_SECRET" $ec2_user

#!/bin/bash
# create app
echo creating app
sudo su -s /bin/bash -c "kubectl create namespace test" $ec2_user
sudo su -s /bin/bash -c "argocd app create test --server localhost:8999 --dest-namespace test --dest-server https://kubernetes.default.svc --repo https://github.com/chrispsheehan/aws-argocd --path k8s --revision main --sync-policy automated" $ec2_user
sudo su -s /bin/bash -c "argocd app sync test" $ec2_user

#!/bin/bash
counter=1
pod_count=0
pod_namespace=test
pod_target_count=3
timeout_seconds=120

echo "waiting for running pods.."
echo "pod_namespace=$pod_namespace"
echo "pod_target_count=$pod_target_count"
echo "timeout_seconds=$timeout_seconds"
 
while [ $counter -le $timeout_seconds ] && [ $pod_count -lt $pod_target_count ]
do
    pod_count=$(sudo su -s /bin/bash -c "kubectl get pods -n $pod_namespace --field-selector status.phase=Running -o json | jq '.items' | jq length" $ec2_user)
    echo "$pod_namespace has $pod_count running pods"
    ((counter++))
    if [ $counter -ge $timeout_seconds ]
    then
        echo "$timeout_seconds secound timeout exceeded"
        exit 1
    else
        sleep 1
    fi
done