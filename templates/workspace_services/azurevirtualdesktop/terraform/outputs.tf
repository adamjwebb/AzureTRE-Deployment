output "workspace_services_snet_iprange" {
  value = jsonencode(data.azurerm_subnet.services.address_prefixes)
}
