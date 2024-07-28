terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31.0"
    }
  }
}


provider "azurerm" {
  features {}
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}