variable "workspace_id" {
  type        = string
  description = "TRE workspace ID"
  default     = "324c"
}

variable "tre_id" {
  type        = string
  description = "TRE ID"
  default = "awtre"
}

variable "tre_resource_id" {
  type        = string
  description = "Resource ID"
  default = "7b19ec56-b928-4a28-bcf3-ee5a7249324c"

}

variable "avd_workspace_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
default     = "AVD Workspace"
}

variable "avd_workspace_description" {
type        = string
description = "Description of the Azure Virtual Desktop workspace"
default     = "This is an AVD Workspace!"
}

variable "avd_hostpool_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop workspace"
default     = "AVD Workspace"
}

variable "avd_hostpool_description" {
type        = string
description = "Description of the Azure Virtual Desktop hostpool"
default     = "This is an AVD Hostpool!"
}

variable "avd_application_group_display_name" {
type        = string
description = "Name of the Azure Virtual Desktop application group"
default     = "AVD Application Group"
}

variable "avd_application_group_description" {
type        = string
description = "Description of the Azure Virtual Desktop application group"
default     = "This is an AVD Application Group!"
}
