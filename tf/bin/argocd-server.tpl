#!/bin/bash
ec2_user=${EC2_USER}
argocd_manifests_url=${ARGOCD_MANIFESTS_URL}

#!/bin/bash
# create argocd server
echo creating argocd server
sudo su -s /bin/bash -c "kubectl create namespace argocd" $ec2_user
sudo su -s /bin/bash -c "kubectl apply -n argocd -f $argocd_manifests_url" $ec2_user

#!/bin/bash
# required wait to prevent issues downstream in script
sleep 45
