# Create storage account for boot diagnostics
resource "azurerm_storage_account" "iis_account" {
  name                     = "diagterraformiis${var.stage_name}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}