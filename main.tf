terraform {
  backend "azure" {}
  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}
/*
resource "azurerm_resource_group" "rg" {
  name      = var.resource_group_name
  location  = var.resource_group_location
}

resource "azurerm_virtual_network" "example" {
  name                = "cdcpoc-vnet"
  address_space       = ["10.7.29.0/29"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.7.29.0/29"]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_storage_account" "rgname" {
  name                     = "cdcbckginfrastorageacc"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access  = true

}
resource "azurerm_storage_container" "rgname" {
  name                  = "cdccontainer"
  storage_account_name  = azurerm_storage_account.rgname.name
  container_access_type = "container"
}
*/