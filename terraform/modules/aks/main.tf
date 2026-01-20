resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  kubernetes_version = var.kubernetes_version

  sku_tier = "Free"

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  default_node_pool {
    name                 = "system"
    temporary_name_for_rotation = "systemtmp"
    vm_size              = var.node_vm_size
    type                 = "VirtualMachineScaleSets"
    auto_scaling_enabled = true
    min_count            = var.node_min_count
    max_count            = var.node_max_count
    orchestrator_version = var.kubernetes_version
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"

    dynamic "load_balancer_profile" {
      for_each = var.outbound_public_ip_id == null ? [] : [var.outbound_public_ip_id]

      content {
        outbound_ip_address_ids = [load_balancer_profile.value]
      }
    }
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  tags = var.tags
}
