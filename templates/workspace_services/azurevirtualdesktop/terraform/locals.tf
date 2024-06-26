locals {
  short_service_id                              = substr(var.tre_resource_id, -4, -1)
  short_workspace_id                            = substr(var.workspace_id, -4, -1)
  workspace_resource_name_suffix                = "${var.tre_id}-ws-${local.short_workspace_id}"
  keyvault_name                                 = lower("kv-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  service_resource_name_suffix                  = "${local.short_workspace_id}svc${local.short_service_id}"
  core_resource_group_name                      = "rg-${var.tre_id}"
  avd_workspace_name                            = lower("vdws-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  avd_workspace_friendly_name                   = "IHA TRE Workspace - ${local.short_workspace_id}"
  avd_hostpool_name                             = lower("vdpool-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  avd_hostpool_custom_rdp_properties            = "audiocapturemode:i:1;audiomode:i:0;enablerdsaadauth:i:1;targetisaadjoined:i:1;enablecredsspsupport:i:1;redirectclipboard:i:0;redirectcomports:i:0;usbdevicestoredirect:s:;drivestoredirect:s:;redirectprinters:i:0;"
  avd_application_group_name                    = lower("vdag-${substr(local.workspace_resource_name_suffix, -20, -1)}")
  avd_hostpool_registrationinfo_expiration_date = timeadd(timestamp(), "720h")
  workspace_ad_group_naming_prefix              = var.workspace_ad_group_naming_prefix != "" ? var.workspace_ad_group_naming_prefix : "IHA-MS-${var.tre_id}-WS-${local.short_workspace_id}-"
  tre_portal_fqdns_list                         = distinct(compact(split(",", replace(var.tre_portal_fqdns, " ", ""))))
  tre_workspace_service_tags = {
    tre_id                   = var.tre_id
    tre_workspace_id         = var.workspace_id
    tre_workspace_service_id = var.tre_resource_id
  }
}
