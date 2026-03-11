data "azurerm_client_config" "current" {}
# 1. Create a Resource Group (the container for everything)
resource "azurerm_resource_group" "rg" {
  name     = "aks-mission-rg"
  location = "westus2" # You can change this to your preferred region
}
resource "random_string" "suffix" {
  length = 5
  special = false
  upper = false
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

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  oidc_issuer_enabled = true
  workload_identity_enabled = true
  


  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "DevOps-Mission"
  }
}
resource "azurerm_container_registry" "acr" {
  name = "weatherappregistry2026"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location 
  sku = "Standard"
  admin_enabled = true

}

resource "azurerm_key_vault" "vault" {
  name                = "kv-weather-gitops-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enable_rbac_authorization = true 
}

# 1. Create a User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "weather_identity" {
  name                = "id-weather-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
# 2. Give the Identity permission to read secrets from the Vault
resource "azurerm_role_assignment" "vault_access" {
  scope                = azurerm_keyvault.vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.weather_identity.principal_id
}
# 3. Create the Federated Credential (The "Bridge")
resource "azurerm_federated_identity_credential" "weather_fed" {
  name                = "fed-weather-app"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.weather_identity.id
  subject             = "system:serviceaccount:dev-environment:weather-sa"
}
output "acr_login_server"{
  value = azurerm_container_registry.acr.login_server
} 