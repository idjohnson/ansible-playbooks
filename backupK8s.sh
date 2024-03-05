#!/bin/bash

rm -rf ./tmp || true
mkdir ./tmp
cd ./tmp

# Get all namespaces
NAMESPACE_LIST=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Loop through each namespace
for NAMESPACE in $NAMESPACE_LIST; do

    # Get all Helm releases in the specified namespace
    HELM_RELEASES=$(helm list --namespace "$NAMESPACE" --output json | jq -r '.[].name')
    helm list --namespace "$NAMESPACE" > "${NAMESPACE}_helmlist.txt"

    # Loop through each Helm release
    for RELEASE in $HELM_RELEASES; do
        # Get all values for the release
        helm get values "$RELEASE" --namespace "$NAMESPACE" > "${NAMESPACE}_${RELEASE}_all_values.yaml"
        echo "Saved all values for Helm release '$RELEASE' to ${NAMESPACE}_${RELEASE}_all_values.yaml"

        # Get only user-set values for the release
        helm get values "$RELEASE" --namespace "$NAMESPACE" --output json | jq 'del(.release)' > "${NAMESPACE}_${RELEASE}_user_values.yaml"
        echo "Saved user-set values for Helm release '$RELEASE' to ${NAMESPACE}_${RELEASE}_user_values.yaml"
    done

    APILIST=$(kubectl api-resources --verbs=list --no-headers | awk '{print $1}')
    for APINAME in $APILIST; do
        RESOURCE_NAMES=$(kubectl get "$APINAME" --namespace "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')

        # Loop through each issuer and save it to a YAML file
        for RESOURCE_NAME in $RESOURCE_NAMES; do
            kubectl get "$APINAME" "$RESOURCE_NAME" --namespace "$NAMESPACE" -o yaml > "${NAMESPACE}_${RESOURCE_NAME}_${APINAME}.yaml"
            echo "Saved $APINAME $RESOURCE_NAME from namespace '$NAMESPACE' to ${NAMESPACE}_${RESOURCE_NAME}_${APINAME}.yaml"
        done
    done
done

cd ..
rm -f ./backup_k8s.tgz || true
tar czf "backup_k8s.tgz" ./tmp/
#tar -czvf k8s_backup.tgz *.yaml