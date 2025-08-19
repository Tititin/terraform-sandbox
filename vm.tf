# Create virtual machine
resource "azurerm_windows_virtual_machine" "iis" {
  name                  = "vm-win-iis-${var.stage_name}"
  admin_username        = "azureuser"
  admin_password        = azurerm_key_vault_secret.iis_password.value
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.iis_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "${var.stage_name}myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }


  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.iis_account.primary_blob_endpoint
  }

  depends_on = [azurerm_key_vault_secret.iis_password]
}

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "wsi-terraform-iis-${var.stage_name}"
  virtual_machine_id         = azurerm_windows_virtual_machine.iis.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
  SETTINGS
}

### NGINX ###

# Create virtual machine
resource "azurerm_linux_virtual_machine" "nginx" {
  name                            = "vm-linux-nginx-${var.stage_name}"
  admin_username                  = "azureuser"
  admin_password                  = azurerm_key_vault_secret.iis_password.value
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nginx_nic.id]
  size                            = "Standard_DS1_v2"
  disable_password_authentication = false

  os_disk {
    name                 = "${var.stage_name}myNginxDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              apt update
              apt install -y nginx
              systemctl enable nginx
              systemctl start nginx
            EOF
  )


  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.iis_account.primary_blob_endpoint
  }

  depends_on = [azurerm_key_vault_secret.nginx_password]
}