resource "azurerm_network_interface" "avd_sessionhost_nic" {
  name                          = "${local.avd_sessionhost_name}-nic"
  resource_group_name           = data.azurerm_resource_group.ws.name
  location                      = data.azurerm_resource_group.ws.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = data.azurerm_subnet.services.id
    private_ip_address_allocation = "Dynamic"
  }
    tags                          = local.tre_workspace_service_tags

  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_windows_virtual_machine" "avd_sessionhost" {
  depends_on = [
      azurerm_network_interface.avd_sessionhost_nic
  ]
  name                          = local.avd_sessionhost_name
  resource_group_name           = data.azurerm_resource_group.ws.name
  location                      = data.azurerm_resource_group.ws.location



  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  admin_password      = "Password@1234"
  provision_vm_agent = true

  network_interface_ids = [azurerm_network_interface.avd_sessionhost_nic.id]

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

# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "avd_workspace" {
  name                          = local.avd_workspace_name
  resource_group_name           = data.azurerm_resource_group.ws.name
  location                      = data.azurerm_resource_group.ws.location
  friendly_name                 = var.avd_workspace_display_name
  description                   = var.avd_workspace_description
  public_network_access_enabled = true
  tags                          = local.tre_workspace_service_tags

  lifecycle { ignore_changes = [tags] }
}
