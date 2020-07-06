#!/bin/bash
set -v

 kubectl config use-context $(grep 'aks$' KCONFIG.txt)

 cd app_stack/app_AKS/

 ./full_stack_deploy.sh

 sleep 1

 cd ../../

  sleep1
  
 kubectl config use-context $(grep arn KCONFIG.txt)

 cd app_stack/app_EKS/

./full_stack_deploy.sh

 sleep 1

 echo "app migrated"

 cd ../../
