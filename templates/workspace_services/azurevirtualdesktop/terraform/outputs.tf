output "workspace_services_snet_iprange" {
  value = jsonencode(data.azurerm_subnet.services.address_prefixes)
}

output "tre_portal_fqdns" {
  value = jsonencode(local.tre_portal_fqdns_list)
}
