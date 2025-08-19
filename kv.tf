resource "azurerm_key_vault" "terraform_kv" {
  name                = "iisnginxterraformkv${var.stage_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name  = "standard"
  tenant_id = data.azurerm_client_config.current_client.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current_client.tenant_id
    object_id = data.azurerm_client_config.current_client.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "azurerm_key_vault_secret" "iis_password" {
  key_vault_id = azurerm_key_vault.terraform_kv.id
  name         = "iispwd"
  value        = random_password.password.result

  depends_on = [random_password.password]
}

resource "azurerm_key_vault_secret" "nginx_password" {
  key_vault_id = azurerm_key_vault.terraform_kv.id
  name         = "nginxpwd"
  value        = random_password.password.result

  depends_on = [random_password.password]
}


# data "azurerm_key_vault_secret" "iis_pwd" {
#   name         = "iispwd"
#   key_vault_id = azurerm_key_vault.terraform_kv.id
# }

# data "azurerm_key_vault_secret" "nginx_pwd" {
#   name         = "nginxpwd"
#   key_vault_id = azurerm_key_vault.terraform_kv.id
# }