#!/bin/bash

kubectl delete -f ./application_deploy_sidecar
helm uninstall consul
helm uninstall vault
helm uninstall mariadb

