#!/bin/bash
set -v

 cd app_stack/app_AKS/

 kubectl config use-context $(grep 'aks$' KCONFIG.txt)

 ./full_stack_deploy.sh

 sleep 1

 cd ../../

  sleep1
  
 kubectl config use-context $(grep arn KCONFIG.txt)

 cd app_stack/app_EKS/

./full_stack_deploy.sh

 sleep 1

 echo "mesh complete"

 cd ../../
