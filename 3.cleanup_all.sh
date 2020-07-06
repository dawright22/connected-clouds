#!/bin/bash
set -v
kubectl config view -o json | jq -r '.contexts[].name'  >> KCONFIG.txt

kubectl config use-context $(grep gke KCONFIG.txt)


 cd app_stack/app_GKE/

./cleanup.sh

  kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=k8s-tranist-app -o name)
 
 sleep 1s

 cd ../../

 kubectl config use-context $(grep 'aks$' KCONFIG.txt)

 sleep 1

 cd app_stack/app_AKS/consul-mesh/

./cleanup.sh

 kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=consul -o name)

 sleep 1

 cd ../../../

  kubectl config use-context $(grep arn KCONFIG.txt)

  sleep1

 cd app_stack/app_EKS/

 ./cleanup.sh

 kubectl wait --timeout=120s --for=condition=Ready $(kubectl get pod --selector=app=consul -o name)

 sleep 1

 echo "mesh destroyed"

 cd ../../../

find . -type f -name "init.json" -exec rm -i {} \;

