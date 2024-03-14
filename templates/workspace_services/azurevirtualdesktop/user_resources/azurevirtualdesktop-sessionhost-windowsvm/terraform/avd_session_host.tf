resource "random_password" "avd_sessionhost_local_password" {
  length           = 16
  lower            = true
  min_lower        = 1
  upper            = true
  min_upper        = 1
  numeric          = true
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "_%@"
}

resource "azurerm_network_interface" "avd_vm_nic" {
  name                = "avd_vm_nic-nic"
  resource_group_name = data.azurerm_resource_group.ws.name
  location            = data.azurerm_resource_group.ws.location

  ip_configuration {
    name                          = "nic_config_01"
    subnet_id                     = data.azurerm_subnet.services.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    data.azurerm_resource_group.ws
  ]
}

resource "azurerm_windows_virtual_machine" "avd_sessionhost" {
  name                       = local.avd_sessionhost_name
  resource_group_name        = data.azurerm_resource_group.ws.name
  location                   = data.azurerm_resource_group.ws.location
  size                       = local.avd_sessionhost_sizes[var.avd_sessionhost_size]
  allow_extension_operations = true
  admin_username             = "avdadminuser"
  admin_password             = random_password.avd_sessionhost_local_password.result
  provision_vm_agent         = true

  network_interface_ids = [azurerm_network_interface.avd_vm_nic.id]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${local.avd_sessionhost_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # set source_image_id/reference depending on the config for the selected image
  source_image_id = local.selected_image_source_id
  dynamic "source_image_reference" {
    for_each = local.selected_image_source_refs
    content {
      publisher = source_image_reference.value["publisher"]
      offer     = source_image_reference.value["offer"]
      sku       = source_image_reference.value["sku"]
      version   = source_image_reference.value["version"]
    }
  }
}

resource "azurerm_key_vault_secret" "avd_sessionhost_password" {
  name         = "${azurerm_windows_virtual_machine.avd_sessionhost.name}-session-host-password"
  value        = random_password.avd_sessionhost_local_password.result
  key_vault_id = data.azurerm_key_vault.ws.id
  tags         = local.tre_workspace_service_tags

  lifecycle { ignore_changes = [tags] }
}

/*
locals {
  shutdown_command   = "shutdown -r -t 10"
  exit_code_hack     = "exit 0"
  commandtorun       = "New-Item -Path HKLM:/SOFTWARE/Microsoft/RDInfraAgent/AADJPrivate"
  powershell_command = "${local.commandtorun}; ${local.shutdown_command}; ${local.exit_code_hack}"
}
*/
resource "azurerm_virtual_machine_extension" "aad_login" {
  name                 = "${azurerm_windows_virtual_machine.avd_sessionhost.name}-aad-login"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_sessionhost.id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "2.1"

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_virtual_machine_extension" "avd-dsc" {
  name                       = "${azurerm_windows_virtual_machine.avd_sessionhost.name}-avd-dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_sessionhost.id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "ModulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip",
        "ConfigurationFunction" : "Configuration.ps1\\AddSessionHost",
        "Properties": {
            "hostPoolName": "${data.azurerm_virtual_desktop_host_pool.avdhostpool.name}"
        }
    }
    SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
    {
      "properties" : {
            "registrationInfoToken" : "${azurerm_virtual_desktop_host_pool_registration_info.avd_token.token}"
        }
    }
    PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings, tags]
  }
}
