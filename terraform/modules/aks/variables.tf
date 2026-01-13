variable "name" {
  type        = string
  description = "AKS cluster name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "dns_prefix" {
  type        = string
  description = "AKS DNS prefix"
}

variable "node_vm_size" {
  type        = string
  description = "System node pool VM size"
  default     = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  type        = string
  description = "Optional Kubernetes version (null for default)"
  default     = null
  nullable    = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID"
}

variable "tags" {
  type        = map(string)
  description = "Tags"
  default     = {}
}
