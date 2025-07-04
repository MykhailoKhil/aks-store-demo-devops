# Input variables for AKS Store Demo Terraform configuration

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "aks-store-demo-rg"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  default     = "aksstoredemoregistry"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-store-demo"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-store-demo"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30.12"
}

variable "node_count" {
  description = "Initial number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "min_node_count" {
  description = "Minimum number of nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the AKS cluster"
  type        = number
  default     = 5
}

variable "vm_size" {
  description = "VM size for the AKS nodes"
  type        = string
  default     = "standard_d2_v4"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "AKS Store Demo"
    ManagedBy   = "Terraform"
  }
}

variable "admin_username" {
  description = "Admin username for the AKS nodes"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for the AKS nodes"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ingress_namespace" {
  description = "Kubernetes namespace for the ingress controller"
  type        = string
  default     = "ingress-nginx"
}
