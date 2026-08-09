terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.108"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.phoenix.kube_config[0].host
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.phoenix.kube_config[0].cluster_ca_certificate)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.phoenix.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.phoenix.kube_config[0].client_key)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.phoenix.kube_config[0].host
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.phoenix.kube_config[0].cluster_ca_certificate)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.phoenix.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.phoenix.kube_config[0].client_key)
  }
}