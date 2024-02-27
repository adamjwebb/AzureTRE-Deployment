locals {
  registration_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkY5NTVDQTVDNTAyMDJGMEY3NTc0RUE2M0Q3NkM4NUNFNjZBNzI3ODkiLCJ0eXAiOiJKV1QifQ.eyJSZWdpc3RyYXRpb25JZCI6ImQxOWNjMTMxLTNmNzAtNDVjZC1hZWVhLTljOTYzYTYyNjFlYiIsIkJyb2tlclVyaSI6Imh0dHBzOi8vcmRicm9rZXItZy1jYS1yMC53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1VyaSI6Imh0dHBzOi8vcmRkaWFnbm9zdGljcy1nLWNhLXIwLnd2ZC5taWNyb3NvZnQuY29tLyIsIkVuZHBvaW50UG9vbElkIjoiYzY5NDIzNzEtNzVjZi00MGU0LWFiNTAtN2IxNzA2OWRhNDRjIiwiR2xvYmFsQnJva2VyVXJpIjoiaHR0cHM6Ly9yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJHZW9ncmFwaHkiOiJDQSIsIkdsb2JhbEJyb2tlclJlc291cmNlSWRVcmkiOiJodHRwczovL2M2OTQyMzcxLTc1Y2YtNDBlNC1hYjUwLTdiMTcwNjlkYTQ0Yy5yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJCcm9rZXJSZXNvdXJjZUlkVXJpIjoiaHR0cHM6Ly9jNjk0MjM3MS03NWNmLTQwZTQtYWI1MC03YjE3MDY5ZGE0NGMucmRicm9rZXItZy1jYS1yMC53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1Jlc291cmNlSWRVcmkiOiJodHRwczovL2M2OTQyMzcxLTc1Y2YtNDBlNC1hYjUwLTdiMTcwNjlkYTQ0Yy5yZGRpYWdub3N0aWNzLWctY2EtcjAud3ZkLm1pY3Jvc29mdC5jb20vIiwiQUFEVGVuYW50SWQiOiI4Y2VlZTI2ZC1mM2YyLTQyYTUtODQ5MS1hNGE3ZjJmZTAxZjIiLCJuYmYiOjE3MDc2MzQ4MzQsImV4cCI6MTcxMDIyNjgyNiwiaXNzIjoiUkRJbmZyYVRva2VuTWFuYWdlciIsImF1ZCI6IlJEbWkifQ.WPWjnO-9unQho74boC6DCJWFd0G3rxs6fkUmrKU1QO_hpqU-MiDR2ETuzKNhtA9KjKKCiZR6rILrwIu2x0mVy4I4Tzu_eTWyBsNi1wtqkGZby5KthYzFg5leqiULvy-u2kmIYBJnchwUBtiOnYNqRh8Qg1kvkAkojK8gNYrulV3vclvprnav0HGbsZ9oEdK1WDqjhyH0jGreEGDqneScdOp_CA7kImGex1LZrPPVBslwMjn8SuHCKsD6LF_eDfzI0oTRnfW22TOFqsJqhicTlQaU3zuiN8bOUFtasj2hI3Rvk71yE_3FFdQYd2uRFlBezkt4l1qOhX9D-xSf184nMQ"
}

resource "random_string" "AVD_local_password" {
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
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
  depends_on = [
      azurerm_network_interface.avd_vm_nic
  ]
  name                = "ansuvm-01"
  resource_group_name = data.azurerm_resource_group.ws.name
  location            = data.azurerm_resource_group.ws.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "Password@1234"
  provision_vm_agent = true

  network_interface_ids = [azurerm_network_interface.avd_vm_nic.id]

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

locals {
   shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  commandtorun         = "New-Item -Path HKLM:/SOFTWARE/Microsoft/RDInfraAgent/AADJPrivate"
  powershell_command   = "${local.commandtorun}; ${local.shutdown_command}; ${local.exit_code_hack}"
}

resource "azurerm_virtual_machine_extension" "AVDModule" {
  depends_on = [
      azurerm_windows_virtual_machine.avd_sessionhost
  ]
  count = 1
  name                 = "Microsoft.PowerShell.DSC"
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_sessionhost.id
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.73"
  settings = <<-SETTINGS
    {
        "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_11-22-2021.zip",
        "ConfigurationFunction": "Configuration.ps1\\AddSessionHost",
        "Properties" : {
          "hostPoolName" : "${data.azurerm_virtual_desktop_host_pool.avdhostpool.name}",
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
  virtual_machine_id   = azurerm_windows_virtual_machine.avd_sessionhost.id
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
  virtual_machine_id =    azurerm_windows_virtual_machine.avd_sessionhost.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}
