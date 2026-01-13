variable "name" {
  type        = string
  description = "ACR name (must be globally unique, 5-50 alphanumeric)"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "sku" {
  type        = string
  description = "ACR SKU"
  default     = "Standard"
}

variable "admin_enabled" {
  type        = bool
  description = "Enable admin user"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
