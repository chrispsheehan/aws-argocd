# expose argocd
echo exposing argocd
sudo su -s /bin/bash -c "kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'" ec2-user
sudo su -s /bin/bash -c "kubectl port-forward svc/argocd-server -n argocd 8999:443 &" ec2-user

# set admin secret
echo getting admin secret
export ADMIN_SECRET=$(sudo su -s /bin/bash -c "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo" ec2-user)
sudo su -s /bin/bash -c "echo secret:$ADMIN_SECRET" ec2-user
echo logging in
argocd login --insecure localhost:8999 --username admin --password $ADMIN_SECRET

# create app
echo creating app
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-namespace default --dest-server https://kubernetes.default.svc --directory-recurse --insecure-ignore-host-key
argocd app sync test