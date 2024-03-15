locals {
  short_service_id                              = substr(var.tre_resource_id, -4, -1)
  short_workspace_id                            = substr(var.workspace_id, -4, -1)
  #aad_tenant_id                                 = data.azurerm_key_vault_secret.aad_tenant_id.value
  workspace_resource_name_suffix                = "${var.tre_id}-ws-${local.short_workspace_id}"
  keyvault_name                                 = lower("kv-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  service_resource_name_suffix                  = "${local.short_workspace_id}svc${local.short_service_id}"
  core_resource_group_name                      = "rg-${var.tre_id}"
  avd_hostpool_name                             = lower("vdpool-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  avd_sessionhost_name                        = lower("vdvmws${local.short_workspace_id}-01")
  workspace_ad_group_naming_prefix = var.workspace_ad_group_naming_prefix != "" ? var.workspace_ad_group_naming_prefix : "${local.workspace_resource_name_suffix} "
  tre_workspace_service_tags = {
    tre_id                   = var.tre_id
    tre_workspace_id         = var.workspace_id
    tre_workspace_service_id = var.tre_resource_id
  }

  # Load VM SKU/image details from porter.yaml
  porter_yaml   = yamldecode(file("${path.module}/../porter.yaml"))
  avd_sessionhost_sizes      = local.porter_yaml["custom"]["vm_sizes"]
  avd_sessionhost_image_details = local.porter_yaml["custom"]["image_options"]

  # Create local variables to support the VM resource
  selected_image = local.avd_sessionhost_image_details[var.avd_sessionhost_image]
  # selected_image_source_refs is an array to enable easy use of a dynamic block
  selected_image_source_refs = lookup(local.selected_image, "source_image_reference", null) == null ? [] : [local.selected_image.source_image_reference]
  selected_image_source_id   = lookup(local.selected_image, "source_image_name", null) == null ? null : "${var.avd_sessionhost_image_gallery_id}/images/${local.selected_image.source_image_name}"
}


