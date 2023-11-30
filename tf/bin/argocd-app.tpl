#!/bin/bash
ec2_user=${EC2_USER}
argocd_repo=${ARGOCD_REPO}
argocd_repo_branch=${ARGOCD_REPO_BRANCH}
argocd_server_port=${ARGOCD_SERVER_PORT}
argocd_app_name=${ARGOCD_APP_NAME}
argocd_app_namespace=${ARGOCD_APP_NAMESPACE}
argocd_app_port=${ARGOCD_APP_PORT}

#!/bin/bash
# expose argocd
echo exposing argocd
sudo su -s /bin/bash -c "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'" $ec2_user
sudo su -s /bin/bash -c "kubectl port-forward svc/argocd-server -n argocd $argocd_server_port:443 &" $ec2_user

#!/bin/bash
# log into argocd
echo logging in
ADMIN_SECRET=$(sudo su -s /bin/bash -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo" $ec2_user)
sudo su -s /bin/bash -c "argocd login --insecure localhost:$argocd_server_port --username admin --password $ADMIN_SECRET" $ec2_user

#!/bin/bash
# create app
echo creating app
sudo su -s /bin/bash -c "kubectl create namespace $argocd_app_namespace" $ec2_user
sudo su -s /bin/bash -c "argocd app create $argocd_app_name --server localhost:$argocd_server_port --dest-namespace $argocd_app_namespace --dest-server https://kubernetes.default.svc --repo $argocd_repo --path k8s --revision $argocd_repo_branch --sync-policy automated" $ec2_user
sudo su -s /bin/bash -c "argocd app sync $argocd_app_name" $ec2_user
