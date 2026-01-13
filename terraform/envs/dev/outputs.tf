output "resource_group_name" {
  value       = azurerm_resource_group.workload.name
  description = "Workload resource group name"
}

output "aks_name" {
  value       = module.aks.name
  description = "AKS cluster name"
}

output "aks_node_resource_group" {
  value       = module.aks.node_resource_group
  description = "AKS node resource group name"
}

output "acr_name" {
  value       = module.acr.name
  description = "ACR name"
}

output "acr_login_server" {
  value       = module.acr.login_server
  description = "ACR login server"
}

output "log_analytics_workspace_id" {
  value       = module.log_analytics.workspace_id
  description = "Log Analytics Workspace ID"
}
