#!/bin/bash

export NAMESPACE=codewizard

# Create the ns
kubectl create ns ${NAMESPACE}

# Set the desired namepsace
kubectl config set-context $(kubectl config current-context) --namespace=${NAMESPACE}

# Install cert manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml

# Pack the Chart
helm package helm-util
helm package helm-01
helm package helm-02

# Debug
# helm template helm-01

# install the Chart
helm uninstall helm-util -n ${NAMESPACE} 
helm uninstall helm1     -n ${NAMESPACE} 
helm uninstall helm2     -n ${NAMESPACE} 

sleep 10

helm install helm-util  -n ${NAMESPACE} ${NAMESPACE}-helm-util-0.1.0.tgz
sleep 5
helm install helm1      -n ${NAMESPACE} ${NAMESPACE}-helm1-0.1.0.tgz
helm install helm2      -n ${NAMESPACE} ${NAMESPACE}-helm2-0.1.0.tgz

# Wait for the pods to run
kubectl wait --for=condition=ready pod -l app=${NAMESPACE}-helm1
kubectl wait --for=condition=ready pod -l app=${NAMESPACE}-helm2

# Get full list of resources
# kubectl api-resources --verbs=list --namespaced  -o name | xargs -n 1 kubectl get -n ${NAMESPACE} --ignore-not-found --show-kind 

kubectl exec $(kubectl get pod -o jsonpath='{.items[1].metadata.name}') -- ls /data