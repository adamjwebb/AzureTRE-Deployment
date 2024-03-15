data "azurerm_resource_group" "ws" {
  name = "rg-${var.tre_id}-ws-${local.short_workspace_id}"
}

data "azurerm_resource_group" "core" {
  name = "rg-${var.tre_id}"
}

data "azurerm_virtual_network" "ws" {
  name                = "vnet-${var.tre_id}-ws-${local.short_workspace_id}"
  resource_group_name = data.azurerm_resource_group.ws.name
}

data "azurerm_subnet" "services" {
  name                 = "ServicesSubnet"
  virtual_network_name = data.azurerm_virtual_network.ws.name
  resource_group_name  = data.azurerm_resource_group.ws.name
}

data "azurerm_key_vault" "ws" {
  name                = local.keyvault_name
  resource_group_name = data.azurerm_resource_group.ws.name
}

data "azurerm_key_vault_secret" "avd_hostpool_registrationtoken"{
  name = "${local.avd_hostpool_name}-registration-token"
  key_vault_id = data.azurerm_key_vault.ws.id
}

data "azurerm_virtual_desktop_host_pool" "avdhostpool" {
  name = local.avd_hostpool_name
  resource_group_name = data.azurerm_resource_group.ws.name
}

data "azurerm_role_definition" "desktop_virtualization_user" {
  name = "Desktop Virtualization User"
}

data "azurerm_role_definition" "virtual_machine_user_login" {
  name = "Virtual Machine User Login"
}

data "azurerm_role_definition" "virtual_machine_admin_login" {
  name = "Virtual Machine Administrator Login"
}

data "azuread_group" "workspace_owners" {
  display_name     = "${local.workspace_ad_group_naming_prefix}Workspace Owners"
  security_enabled = true
}

data "azuread_group" "workspace_researchers" {
  display_name     = "${local.workspace_ad_group_naming_prefix}Workspace Researchers"
  security_enabled = true
}

data "azuread_group" "workspace_airlock_managers" {
  display_name     = "${local.workspace_ad_group_naming_prefix}Airlock Managers"
  security_enabled = true
}

