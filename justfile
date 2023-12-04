init:
    #!/usr/bin/env bash
    cd tf
    terraform init
    cd ..

plan:
    #!/usr/bin/env bash
    cd tf
    terraform plan
    cd ..

destroy:
    #!/usr/bin/env bash
    cd tf
    terraform destroy
    cd ..

deploy:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform apply
    cd ..

get-shell:
    #!/usr/bin/env bash
    cd tf
    terraform apply
    PEM_FILE=$(terraform output -raw pem-file)
    chmod 400 $PEM_FILE
    SSH_CMD=$(terraform output -raw ssh-cmd)
    $SSH_CMD

get-password:
    echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d; echo \n\n" | just get-shell