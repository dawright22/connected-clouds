#!/bin/bash
set -v

 cd app_stack/app_AKS/

 ./full_stack_deploy.sh

 sleep 1

 cd ../../

  sleep1

 cd app_stack/app_EKS/

./full_stack_deploy.sh

 sleep 1

 echo "mesh complete"

 cd ../../
