output "workspace_services_vnet_iprange" {
  value = data.azurerm_subnet.services.id
}
