locals {
  short_service_id                              = substr(var.tre_resource_id, -4, -1)
  short_workspace_id                            = substr(var.workspace_id, -4, -1)
  workspace_resource_name_suffix                = "${var.tre_id}-ws-${local.short_workspace_id}"
  keyvault_name                                 = lower("kv-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  service_resource_name_suffix                  = "${local.short_workspace_id}svc${local.short_service_id}"
  core_resource_group_name                      = "rg-${var.tre_id}"
  avd_workspace_name                            = lower("vdws-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  avd_hostpool_name                             = lower("vdpool-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  avd_application_group_name                    = lower("vdag-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  avd_hostpool_registrationinfo_expiration_date = timeadd(timestamp(), "720h")
  workspace_ad_group_naming_prefix = var.workspace_ad_group_naming_prefix != "" ? var.workspace_ad_group_naming_prefix : "${local.workspace_resource_name_suffix} "
  tre_workspace_service_tags = {
    tre_id                   = var.tre_id
    tre_workspace_id         = var.workspace_id
    tre_workspace_service_id = var.tre_resource_id
  }
}
