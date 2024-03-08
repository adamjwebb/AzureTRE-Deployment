variable "tre_id" {
  type        = string
  description = "Unique TRE ID"
}

variable "workspace_id" {
  type = string
}

variable "tre_resource_id" {
  type        = string
  description = "Resource ID"
}
/*
variable "avd_workspace_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
}

variable "avd_workspace_description" {
type        = string
description = "Description of the Azure Virtual Desktop workspace"
}

variable "avd_hostpool_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
}

variable "avd_hostpool_description" {
type        = string
description = "Description of the Azure Virtual Desktop hostpool"
}

variable "avd_application_group_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop application group"
}

variable "avd_application_group_description" {
type        = string
description = "Description of the Azure Virtual Desktop application group"
}
*/

variable "avd_sessionhost_image" {
  type = string
}

variable "avd_sessionhost_size" {
  type = string
}

variable "avd_sessionhost_image_gallery_id" {
  type    = string
  default = ""
}

variable "auth_tenant_id" {
  type        = string
  description = "Used to authenticate into the AAD Tenant to create the AAD App"
}
variable "auth_client_id" {
  type        = string
  description = "Used to authenticate into the AAD Tenant to create the AAD App"
}
variable "auth_client_secret" {
  type        = string
  description = "Used to authenticate into the AAD Tenant to create the AAD App"
}
