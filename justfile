plan:
    #!/usr/bin/env bash
    cd tf
    terraform init
    terraform apply
    cd ..

apply:
    #!/usr/bin/env bash
    cd tf
    terraform apply
    PEM_FILE=$(terraform output -raw pem-file)
    chmod 400 $PEM_FILE
    SSH_CMD=$(terraform output -raw ssh-cmd)
    echo "ls -l; echo 'Hello World'" | $SSH_CMD