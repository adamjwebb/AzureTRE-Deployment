# Assign roles to the application group

resource "azurerm_role_assignment" "desktop_virtualization_user_airlock_managers" {
  scope              = azurerm_virtual_desktop_application_group.avd_application_group.id
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_user.id
  principal_id       = data.azuread_group.workspace_airlock_managers.id
}

resource "azurerm_role_assignment" "desktop_virtualization_user_workspace_researchers" {
  scope              = azurerm_virtual_desktop_application_group.avd_application_group.id
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_user.id
  principal_id       = data.azuread_group.workspace_researchers.id
}

resource "azurerm_role_assignment" "desktop_virtualization_user_workspace_owners" {
  scope              = azurerm_virtual_desktop_application_group.avd_application_group.id
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_user.id
  principal_id       = data.azuread_group.workspace_owners.id
}
