terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    random = {
      source  = "hashicorp/random"
    }
    time = {
      source  = "hashicorp/time"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
