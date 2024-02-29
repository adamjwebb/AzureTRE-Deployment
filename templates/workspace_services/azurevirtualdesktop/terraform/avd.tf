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

# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "avd_hostpool" {
  name                     = local.avd_hostpool_name
  resource_group_name      = data.azurerm_resource_group.ws.name
  location                 = data.azurerm_resource_group.ws.location
  friendly_name            = var.avd_hostpool_display_name
  description              = var.avd_hostpool_description
  validate_environment     = false
  start_vm_on_connect      = false
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;enablerdsaadauth:i:1;targetisaadjoined:i:1;"
  type                     = "Pooled"
  maximum_sessions_allowed = 16
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]
  tags                     = local.tre_workspace_service_tags

  lifecycle { ignore_changes = [tags] }
}

# Set registration information for AVD host pool
resource "azurerm_virtual_desktop_host_pool_registration_info" "avd_hostpool_registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  expiration_date = local.avd_hostpool_registrationinfo_expiration_date
}

# Create AVD DAG
resource "azurerm_virtual_desktop_application_group" "avd_application_group" {
  name                = local.avd_application_group_name
  resource_group_name = data.azurerm_resource_group.ws.name
  location            = data.azurerm_resource_group.ws.location
  friendly_name       = var.avd_application_group_display_name
  description         = var.avd_application_group_description
  host_pool_id        = azurerm_virtual_desktop_host_pool.avd_hostpool.id
  type                = "Desktop"
  tags                = local.tre_workspace_service_tags

  lifecycle { ignore_changes = [tags] }
}

# Associate Workspace and DAG
resource "azurerm_virtual_desktop_workspace_application_group_association" "avd_application_group_association" {
  application_group_id = azurerm_virtual_desktop_application_group.avd_application_group.id
  workspace_id         = azurerm_virtual_desktop_workspace.avd_workspace.id
}

resource "azurerm_key_vault_secret" "avd_registration_token" {
  name         = "avd-registration-token"
  value        = azurerm_virtual_desktop_host_pool_registration_info.avd_hostpool_registrationinfo.token
  key_vault_id = data.azurerm_key_vault.ws.id
  tags         = local.tre_workspace_service_tags

  lifecycle { ignore_changes = [tags] }
}
