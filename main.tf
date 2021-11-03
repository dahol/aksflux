terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.83.0"
    }
  }
}

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "dh-aks-rg" {
  name     = "${var.nameprefix}-aks-flux-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "cluster-vnet" {
  name                = "cluster-vnet"
  location            = azurerm_resource_group.dh-aks-rg.location
  resource_group_name = azurerm_resource_group.dh-aks-rg.name
  address_space       = var.prod_vnet_cidr

  tags = var.tags
}

resource "azurerm_subnet" "node-snet" {
  name                 = "node-snet"
  resource_group_name  = azurerm_resource_group.dh-aks-rg.name
  virtual_network_name = azurerm_virtual_network.cluster-vnet.name
  address_prefixes     = var.prod_node_snet_cidr

  # Enforce network policies to allow Private Endpoint to be added to the subnet
  enforce_private_link_endpoint_network_policies = true


}

resource "azurerm_kubernetes_cluster" "dh-aks" {
  name                = "${var.nameprefix}-dh-aks"
  location            = azurerm_resource_group.dh-aks-rg.location
  resource_group_name = azurerm_resource_group.dh-aks-rg.name
  dns_prefix          = "dh"
  tags                = var.tags

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
  }



  identity {
    type = "SystemAssigned"
  }

  /*   linux_profile {
    ssh_key {
      key_data = tls_private_key.node_ssh.public_key_openssh
    }
    admin_username = var.vmadmin
  } */
}




output "client_certificate" {
  value = azurerm_kubernetes_cluster.dh-aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.dh-aks.kube_config_raw

  sensitive = true
}
