#!/bin/bash
ec2_user=${EC2_USER}
argocd_app_namespace=${ARGOCD_APP_NAMESPACE}
argocd_app_port=${ARGOCD_APP_PORT}
argocd_app_svc_name=${ARGOCD_APP_SVC_NAME}

#!/bin/bash
# expose app
sudo su -s /bin/bash -c "kubectl port-forward svc/$argocd_app_svc_name -n $argocd_app_namespace $argocd_app_port:$argocd_app_port &" $ec2_user
