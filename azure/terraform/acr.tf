resource "azurerm_resource_group" "phoenix" {
  name     = "phoenix-rg"
  location = "Central India"
}

resource "azurerm_container_registry" "phoenix" {
  name                = "phoenixacr095055159123"
  resource_group_name = azurerm_resource_group.phoenix.name
  location            = azurerm_resource_group.phoenix.location
  sku                 = "Basic"
  admin_enabled       = false
}