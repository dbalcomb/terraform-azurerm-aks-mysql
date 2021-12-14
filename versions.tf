terraform {
  required_version = "~> 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.83"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.6"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
