
output "Kube_contexts" {
  value = "All clusters have been authenticated to. Use the following command to see the context you want to use: kubectl config get-contexts. To switch contect use: kubectl config use-context <conetxt-name>"
}

# // Auth to k8s cluster 
# output "gcloud_connect_command" {
#   value = "gcloud container clusters get-credentials ${module.GKE.cluster_name} --zone ${module.GKE.gcp_zone} --project ${module.GKE.gcp_project}"
# }
