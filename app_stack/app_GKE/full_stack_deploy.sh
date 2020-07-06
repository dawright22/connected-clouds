#!/bin/bash
# set -v

helm repo add hashicorp https://helm.releases.hashicorp.com

 cd consul-mesh

./consul.sh

kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=consul -o name)
sleep 1s

 cd ..

cd mariadb
./mariadb.sh
cd ..

kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=mariadb -o name)
sleep 1s

cd vault
./vault.sh
sleep 5
./vault_setup.sh
cd ..

kubectl apply -f ./application_deploy_sidecar

kubectl get svc k8s-transit-app

echo ""
echo "use the following command to get your demo IP, port is 5000"
echo "$ kubectl get svc k8s-transit-app"
