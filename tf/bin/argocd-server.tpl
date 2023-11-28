#!/bin/bash
export ec2_user=ec2-user

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
