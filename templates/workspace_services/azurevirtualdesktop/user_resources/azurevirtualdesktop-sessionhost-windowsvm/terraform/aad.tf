# Assign roles to the host pool

resource "azurerm_role_assignment" "virtual_machine_user_login_airlock_managers" {
  scope              = azurerm_windows_virtual_machine.avd_sessionhost.id
  role_definition_id = data.azurerm_role_definition.virtual_machine_user_login.id
  principal_id       = data.azuread_group.workspace_airlock_managers.id
}

resource "azurerm_role_assignment" "virtual_machine_user_login_workspace_researchers" {
  scope              = azurerm_windows_virtual_machine.avd_sessionhost.id
  role_definition_id = data.azurerm_role_definition.virtual_machine_user_login.id
  principal_id       = data.azuread_group.workspace_researchers.id
}

resource "azurerm_role_assignment" "virtual_machine_admin_login_workspace_owners" {
  scope              = azurerm_windows_virtual_machine.avd_sessionhost.id
  role_definition_id = data.azurerm_role_definition.virtual_machine_admin_login.id
  principal_id       = data.azuread_group.workspace_owners.id
}
