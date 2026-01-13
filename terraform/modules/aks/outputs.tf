output "id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "AKS cluster ID"
}

output "name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "AKS cluster name"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.this.node_resource_group
  description = "AKS node resource group"
}

output "cluster_identity_principal_id" {
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
  description = "Cluster managed identity principal ID"
}

output "cluster_identity_tenant_id" {
  value       = azurerm_kubernetes_cluster.this.identity[0].tenant_id
  description = "Cluster managed identity tenant ID"
}

output "kubelet_identity_client_id" {
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id, null)
  description = "Kubelet identity client ID (if available)"
}

output "kubelet_identity_object_id" {
  value       = try(azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id, null)
  description = "Kubelet identity object ID (if available)"
}
