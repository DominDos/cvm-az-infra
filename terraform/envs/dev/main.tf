terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

locals {
  name_prefix = "${var.prefix}-${var.env}"

  tags = merge(
    var.tags,
    {
      env     = var.env
      project = var.prefix
    }
  )

  acr_name = substr(replace(lower("${var.prefix}${var.env}acr"), "-", ""), 0, 50)
}

resource "azurerm_resource_group" "workload" {
  name     = "${local.name_prefix}-rg"
  location = var.location
  tags     = local.tags
}

resource "azurerm_public_ip" "aks_egress" {
  name                = "${local.name_prefix}-aks-egress-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.tags
}

module "log_analytics" {
  source              = "../../modules/log_analytics"
  name                = "${local.name_prefix}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}

module "acr" {
  source              = "../../modules/acr"
  name                = local.acr_name
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  sku                 = "Standard"
  tags                = local.tags
}

module "aks" {
  source                     = "../../modules/aks"
  name                       = "${local.name_prefix}-aks"
  dns_prefix                 = var.aks_dns_prefix
  location                   = var.location
  resource_group_name        = azurerm_resource_group.workload.name
  kubernetes_version         = var.aks_kubernetes_version
  node_vm_size               = var.aks_node_vm_size
  node_min_count             = 1
  node_max_count             = 2
  outbound_public_ip_id       = azurerm_public_ip.aks_egress.id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  tags                       = local.tags
}
