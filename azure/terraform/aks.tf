resource "azurerm_kubernetes_cluster" "phoenix" {
  name                = "phoenix-aks"
  location            = azurerm_resource_group.phoenix.location
  resource_group_name = azurerm_resource_group.phoenix.name
  dns_prefix          = "phoenix"

  oidc_issuer_enabled = true

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B4s_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.phoenix.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.phoenix.id
}