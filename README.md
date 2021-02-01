# Multi-cloud-connected
A terraform module to create a basic MariaDB SQL service and the Transit APP that is configured to use Dynamic Secrets and Transit Encryption using Vault. To conect these service Consul is configuread as a service registory.

## Usage
If you clone the repo and run an apply without changing anything a random pet name will be created with the TFE prefix and used in each cluster

```hcl
terraform {
  required_version = ">= 0.12"
}

resource "random_pet" "name" {
  prefix = "TFE"
  length = 1
}

#AWS
module "Cluster_EKS" {
  source       = "./Cluster_EKS"
  cluster-name = "${random_pet.name.id}"

}
#MSFT
module "Cluster_AKS" {
  source       = "./Cluster_AKS"
  cluster-name = "${random_pet.name.id}"

}
#Google
module "Cluster_GKE" {
  source       = "./Cluster_GKE"
  cluster_name = "${random_pet.name.id}"
}
```
## Pre-requirements 
Before you run this you will need to:

1.You will need to auth to GCP,Azure and AWS

2.Install helm 3

3.Install aswcli v2 https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html 

4.Install GKE SDK https://cloud.google.com/sdk/docs/downloads-interactive 

5.Insall Azure Cli https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest 

6.Clone this repo

7.The consul client install on the machine deploying the app_stack

8.Run terraform init

9.Run ./mesh_deploy.sh

10.Run ./app_migrate.sh

11.Run ./cleanup.sh


## Inputs
### AKS
You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "appId" 
  default = "41111111111111111111111"

variable "password" 
  default = "c3444444444444444444444444444444"

variable "location" 
  default = "Australia East"
```
### EKS
You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "aws_region" 
```
### GKS
You will need to set the following variables to be relevant to your envrioment:
```hcl
variable "gcp_region" 

  description = "GCP region, e.g. us-east1"
  
  default     = "australia-southeast1"

variable "gcp_zone" 

  description = "GCP zone, e.g. us-east1-b (which must be in gcp_region)"
  
  default     = "australia-southeast1-c"

variable "gcp_project" 

  description = "GCP project name"
  
  default     = "your-project-name"
```

### Main.tf
Here you can name the clusters by altering the following:

```hcl
cluster_name = "your-name"
```

## Outputs
The Terraform will locally install the user creds into your kubectl config file so that you can switch between the clusters use the kubectl config get-contexts command to see cluster names


### Mesh deployment

Run the below script to deploy the stack decribe beow in GKE and a full consul mesh with EKS and AKS.

./1.mesh_deploy.sh


### What you get!
A connect cloud that has a primary deploymnet in GCP if you then want to migrate your app to AWS and Azure run script 2.app_migrate. This keep the DB in GCP but deploys vault and the app in the other clouds and allows you to write to the DB but only read the data you commited from that cloud app.

### Consul

You can connect to the consul UI and see the services registerd using http://<EXTERNAL-IP>

it should look like this:

![](/images/consul-all.png)

### Vault
You can connect to the Vault UI and see the secrets engines enabled using http://<EXTERNAL_IP:8200>

You will need to login in using the ROOT TOKEN from the init.json file located in app_stack/app_<cloud>/vault/init.json to authenticate

it should look like this:

![](/images/vault.png)

### Transit-app

Execute kubectl get svc transit-app to see the ip address to connect too

You can connect to the app UI and add or change record using http://<EXTERNAL_IP:5000>

![](/images/tranist-app.png)

## Test the Mesh
kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm nslookup  consul.service.consul

kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm nslookup  consul.service.dc-aws.consul

kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm nslookup  consul.service.dc-azure.consul

If the mesh is functioning you will get resolution of the clusters in the differnt envrioments.

### App Migration.
To now deploy the Transit app in EKS and AKS and use the existing DB in GKE run the below script

./2.app_migrate.sh

## Clean up

To delete your enviroments you need to run

./3.clean.sh in the main directory

then run terraform destroy

To clean up you will want to remove the user profile from your kubeconfig


