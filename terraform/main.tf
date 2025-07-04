# Main Terraform configuration for AKS Store Demo

# Create a resource group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = var.tags
}

# Create AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.vm_size
    os_disk_size_gb     = 30
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  role_based_access_control_enabled = true

  http_application_routing_enabled = false
  
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  tags = var.tags

  depends_on = [
    azurerm_virtual_network.aks_vnet,
    azurerm_subnet.aks_subnet
  ]
}

# Create Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "${var.aks_cluster_name}-vnet"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Create Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.aks_cluster_name}-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.aks_cluster_name}-logs"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Assign AcrPull role to the AKS cluster's managed identity
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Create a public IP for the ingress controller
resource "azurerm_public_ip" "ingress" {
  name                = "${var.aks_cluster_name}-ingress-pip"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
