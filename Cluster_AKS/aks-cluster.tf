provider "azurerm" {
features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${var.cluster-name}-rg"
  location = var.location

  tags = {
    environment = "terraform-multi-cloud-k8-demo"
  }
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${var.cluster-name}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${var.cluster-name}-k8s"

 default_node_pool {
    name            = "default"
    node_count           = 3
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "terraform-multi-cloud-k8-demo"
  }
}


