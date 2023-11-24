counter=1
pod_count=0

pod_namespace=${POD_NAMESPACE}
pod_target_count=${POD_TARGET_COUNT}
timeout_seconds=${TIMEOUT_SECONDS}

echo "waiting for running pods.."
echo "pod_namespace=$pod_namespace"
echo "pod_target_count=$pod_target_count"
echo "timeout_seconds=$timeout_seconds"
 
while [ $counter -le $timeout_seconds ]
do
    pod_count=$(sudo su -s /bin/bash -c "kubectl get pods -n $pod_namespace --field-selector status.phase=Running -o json | jq '.items' | jq length" ec2-user)
    echo "$pod_namespace has $pod_count running pods"

    if [ $pod_count -ge $pod_target_count ]
    then
        echo "$pod_namespace pod target reached"
        break
    else
        counter=$((counter + 1))
        if [ $counter -ge $timeout_seconds ]
        then
            echo "$timeout_seconds secound timeout exceeded"
            exit 1
        else
            sleep 1
            continue
        fi
    fi
done
