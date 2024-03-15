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

variable "workspace_ad_group_naming_prefix" {
  type        = string
  description = "Naming prefix for Workspace Azure AD groups"
  default     = ""
}
