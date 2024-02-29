/*
resource "random_string" "AVD_local_password" {
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}
*/
resource "azurerm_network_interface" "avd_vm_nic" {
    name                = "nic-vm-${var.tre_id}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_windows_virtual_machine" "avd_sessionhost" {
  name                = "ansuvm-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "Password@1234"
  provision_vm_agent = true

  network_interface_ids = [azurerm_network_interface.avd_vm_nic.*.id[count.index]]

  identity {
    type  = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

 source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }
}

/*
locals {
   shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  commandtorun         = "New-Item -Path HKLM:/SOFTWARE/Microsoft/RDInfraAgent/AADJPrivate"
  powershell_command   = "${local.commandtorun}; ${local.shutdown_command}; ${local.exit_code_hack}"
}
*/
resource "azurerm_virtual_machine_extension" "AVDModule" {
  name                 = "Microsoft.PowerShell.DSC"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_sessionhost.*.id[count.index]
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"
  settings = <<-SETTINGS
    {
        "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_11-22-2021.zip",
        "ConfigurationFunction": "Configuration.ps1\\AddSessionHost",
        "Properties" : {
          "hostPoolName" : "${azurerm_virtual_desktop_host_pool.hostpool.name}",
          "aadJoin": true
        }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

}
resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
  depends_on = [
      azurerm_windows_virtual_machine.avd_sessionhost,
        azurerm_virtual_machine_extension.AVDModule
  ]
  count = 1
  name                 = "AADLoginForWindows"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_sessionhost.*.id[count.index]
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true
}
resource "azurerm_virtual_machine_extension" "addaadjprivate" {
    depends_on = [
      azurerm_virtual_machine_extension.AADLoginForWindows
    ]
    count = 1
  name                 = "AADJPRIVATE"
  virtual_machine_id =    azurerm_windows_virtual_machine.avd_sessionhost.*.id[count.index]
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}

