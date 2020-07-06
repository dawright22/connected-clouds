#!/bin/bash
set -v

helm repo add hashicorp https://helm.releases.hashicorp.com

kubectl config view -o json | jq -r '.contexts[].name'  >> KCONFIG.txt

kubectl config use-context $(grep gke KCONFIG.txt)

sleep 1

 cd app_stack/app_GKE/

./full_stack_deploy.sh

  kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=k8s-tranist-app -o name)
 
 sleep 1s

 cd ../../

 kubectl config use-context $(grep 'aks$' KCONFIG.txt)

 sleep 1

 cd app_stack/app_AKS/consul-mesh/

 ./consul.sh

 kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=consul -o name)

 sleep 1

 cd ../../../

  kubectl config use-context $(grep arn KCONFIG.txt)

  sleep1

 cd app_stack/app_EKS/consul-mesh/

 ./consul.sh

 kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=consul -o name)

 sleep 1

 echo "mesh complete"

 cd ../../../

 rm "KCONFIG.txt" 
