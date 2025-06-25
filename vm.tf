# Create virtual machine
resource "azurerm_windows_virtual_machine" "main" {
  name                  = "vm-win-iis"
  admin_username        = "azureuser"
  admin_password        = "123Quack456"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.iis_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
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
}

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "wsi-terraform-iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.main.id
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