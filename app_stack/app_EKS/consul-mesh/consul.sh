#!/bin/bash
set -v


helm3 repo add hashicorp https://helm.releases.hashicorp.com

echo "applying secret for federation CA and mesh gateway address..."
kubectl apply -f ../../app_GKE/consul-mesh/consul-federation-secret.yaml

echo "Installing consul using latest helm chart "
helm install consul hashicorp/consul -f values.yaml #--debug

sleep 10s

kubectl apply -f stubDomain.yaml

sleep 2

# kubectl delete pod --namespace kube-system -l k8s-app=kube-dns