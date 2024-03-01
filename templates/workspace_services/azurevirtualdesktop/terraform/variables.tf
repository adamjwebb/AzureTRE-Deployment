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

variable "avd_workspace_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
default = "test display name"
}

variable "avd_workspace_description" {
type        = string
description = "Description of the Azure Virtual Desktop workspace"
default = "test description"
}

variable "avd_hostpool_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
default = "test display name"
}

variable "avd_hostpool_description" {
type        = string
description = "Description of the Azure Virtual Desktop hostpool"
default = "test description"
}

variable "avd_application_group_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop application group"
default = "test display name"
}

variable "avd_application_group_description" {
type        = string
description = "Description of the Azure Virtual Desktop application group"
default = "test description"
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
