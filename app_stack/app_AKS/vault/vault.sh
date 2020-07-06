#!/bin/bash
set -v

# Clone the repo
git clone https://github.com/hashicorp/vault-helm.git

helm install  vault -f ./values.yaml ./vault-helm

sleep 60s




