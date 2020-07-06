#!/bin/bash
set -v

echo "hello"

helm3 repo add hashicorp https://helm.releases.hashicorp.com

echo "Creating gossip encryption key..."
kubectl create secret generic consul-gossip-encryption-key --from-literal=key="$(consul keygen)"

echo "Installing consul using latest helm chart "
helm install consul hashicorp/consul -f values.yaml #--debug

echo "As this is the primary datacenter for federation, fetch the federation secret and store in local file.."
kubectl get secret consul-federation -o yaml > consul-federation-secret.yaml


echo "Configuring Kube to forward consul DNS to consul..."

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kube-dns
  namespace: kube-system
data:
  stubDomains: |
    {"consul": ["$(kubectl get svc consul-dns -o jsonpath='{.spec.clusterIP}')"]}
EOF

sleep 10

# kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm nslookup  consul.service.consul
