#!/bin/bash
export ec2_user=ec2-user

counter=1
pod_count=0
pod_namespace=${POD_NAMESPACE}
pod_target_count=${POD_TARGET_COUNT}
timeout_seconds=${TIMEOUT_SECONDS}

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
