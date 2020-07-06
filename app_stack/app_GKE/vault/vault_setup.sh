#!/bin/bash
set -v

FILE=init.json

if [ -f "$FILE" ]; then
    echo "$FILE exists"

else 
    kubectl exec -it vault-0 -- vault operator init -key-shares=1  -key-threshold=1 -format "json"| cat >> init.json
fi

sleep 2

ROOT_TOKEN=$(jq -r '.root_token'  init.json)
UNSEAL_KEY=$(jq -r '.unseal_keys_b64[0]' init.json)


sleep 1
#Raft storage

kubectl exec -it vault-0 -- vault operator unseal $UNSEAL_KEY
sleep 10

kubectl exec -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
sleep 10

kubectl exec -ti vault-1 -- vault operator unseal $UNSEAL_KEY
sleep 10

kubectl exec -ti vault-2 -- vault operator raft join http://vault-0.vault-internal:8200
sleep 10

kubectl exec -ti vault-2 -- vault operator unseal $UNSEAL_KEY

sleep 1

kubectl exec -it vault-0 -- vault login $ROOT_TOKEN

kubectl exec -ti vault-0 -- vault operator raft list-peers

#################################
# Transit-app-example Vault setup
#################################

# Enable our secret engine
kubectl exec -it vault-0 -- vault secrets enable -path=lob_a/workshop/database database
kubectl exec -it vault-0 -- vault secrets enable -path=lob_a/workshop/kv kv
kubectl exec -it vault-0 -- vault write lob_a/workshop/kv/transit-app-example username=vaultadmin password=vaultadminpassword

kubectl exec -it vault-0 -- vault write lob_a/workshop/database/config/ws-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(mariadb:3306)/" \
    allowed_roles="workshop-app" \
    username="root" \
    password="vaultadminpassword"

# Create our role
kubectl exec -it vault-0 -- vault write lob_a/workshop/database/roles/workshop-app-long \
    db_name=ws-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON *.* TO '{{name}}'@'%';" \
    default_ttl="12h" \
    max_ttl="24h"

kubectl exec -it vault-0 -- vault write lob_a/workshop/database/roles/workshop-app \
    db_name=ws-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON *.* TO '{{name}}'@'%';" \
    default_ttl="12h" \
    max_ttl="24h"

kubectl exec -it vault-0 -- vault secrets enable -path=lob_a/workshop/transit transit
kubectl exec -it vault-0 -- vault write -f lob_a/workshop/transit/keys/customer-key
kubectl exec -it vault-0 -- vault write -f lob_a/workshop/transit/keys/archive-key

#Create Vault policy used by Nomad job
echo '
path "lob_a/workshop/database/creds/workshop-app" {
    capabilities = ["read", "list", "create", "update", "delete"]
}
path "lob_a/workshop/database/creds/workshop-app-long" {
    capabilities = ["read", "list", "create", "update", "delete"]
}
path "lob_a/workshop/transit/*" {
    capabilities = ["read", "list", "create", "update", "delete"]
}
path "lob_a/workshop/kv/*" {
    capabilities = ["read", "list", "create", "update", "delete"]
}
path "*" {
    capabilities = ["read", "list", "create", "update", "delete"]
}'| kubectl exec -it vault-0 -- vault policy write transit-app-example - 

### Kube intergation
kubectl create serviceaccount vault-auth

kubectl apply --filename vault-auth-service-account.yaml

# Set VAULT_SA_NAME to the service account you created earlier
export VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")

# Set SA_JWT_TOKEN value to the service account JWT used to access the TokenReview API
export SA_JWT_TOKEN=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)

# Set SA_CA_CRT to the PEM encoded CA cert used to talk to Kubernetes API
export SA_CA_CRT=$(kubectl get secret $VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)

export K8S_HOST="https://kubernetes.default.svc:443"
kubectl exec -it vault-0 -- vault auth enable kubernetes

kubectl exec -it vault-0 -- vault write auth/kubernetes/config \
        token_reviewer_jwt="$SA_JWT_TOKEN" \
        kubernetes_host="$K8S_HOST" \
        kubernetes_ca_cert="$SA_CA_CRT"

kubectl exec -it vault-0 -- vault write auth/kubernetes/role/example \
        bound_service_account_names=vault-auth \
        bound_service_account_namespaces=default \
        policies=transit-app-example \
        ttl=24h
