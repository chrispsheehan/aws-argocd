#!/bin/bash
export ec2_user=ec2-user

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
