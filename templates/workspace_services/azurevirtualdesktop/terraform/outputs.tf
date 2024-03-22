output "workspace_services_vnet_iprange" {
  value = jsonencode(data.azurerm_subnet.services.address_prefixes)
}
