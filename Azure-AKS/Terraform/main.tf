# 1. Create a Resource Group (the container for everything)
resource "azurerm_resource_group" "rg" {
  name     = "aks-mission-rg"
  location = "westus2" # You can change this to your preferred region
}

# 2. Create the AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "mission-cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "missionk8s"

  default_node_pool {
    name       = "default"
    node_count = 1            # Starting small to save costs
    vm_size    = "Standard_B2s_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "DevOps-Mission"
  }
}