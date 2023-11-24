#!/bin/bash

POD_TARGET_COUNT=3
POD_NAMESPACE=nginx
TIMEOUT_SECONDS=5

counter=1
pod_count=0
 
while [ $counter -le $TIMEOUT_SECONDS ]
do
    pod_count=$(kubectl get pods -n $POD_NAMESPACE --field-selector status.phase=Running -o json | jq '.items' | jq length)
    echo "$pod_count running pods found"

    if [ $pod_count -ge $POD_TARGET_COUNT ]
    then
        echo "target reached"
        exit 0
    else
        sleep 1
        counter=$((counter + 1))
        continue
    fi
done

echo "$TIMEOUT_SECONDS secound timeout exceeded"
exit 1