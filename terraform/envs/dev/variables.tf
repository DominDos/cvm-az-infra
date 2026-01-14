variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "westeurope"
}

variable "env" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "prefix" {
  type        = string
  description = "Naming prefix"
  default     = "cvm"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources"
  default     = {}
}

variable "aks_kubernetes_version" {
  type        = string
  description = "Optional AKS Kubernetes version (null to let Azure pick default)"
  default     = null
  nullable    = true
}

variable "aks_dns_prefix" {
  type        = string
  description = "AKS DNS prefix"
  default     = "cvm-dev-aks"
}

variable "aks_node_vm_size" {
  type        = string
  description = "AKS node VM size"
  default     = "Standard_B2s"
}
