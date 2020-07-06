#!/bin/bash
set -v

kubectl config use-context $(grep gke KCONFIG.txt)


 cd app_stack/app_GKE/

./cleanup.sh

 
 sleep 1s

 cd ../../

 kubectl config use-context $(grep 'aks$' KCONFIG.txt)

 sleep 1

 cd app_stack/app_AKS/

./cleanup.sh


 sleep 1

 cd ../../

  kubectl config use-context $(grep arn KCONFIG.txt)

  sleep 1

 cd app_stack/app_EKS/

 ./cleanup.sh


 sleep 1

 echo "all destroyed"

 cd ../../

rm "KCONFIG.txt" 

find . -type f -name "init.json" -exec rm -i {} \;

