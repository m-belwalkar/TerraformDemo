variable "resource_group_name" {
  default       = "CDCDemoTerraform"
  description   = "Name of the resource group."
}

variable "resource_group_location" {
  default = "westus"
  description   = "Location of the resource group."
}

variable "azurerm_app_service_plan_name" {
  default = "cdcpocdemo1"
  description   = "App Service plan name."
}
variable "azurerm_app_service_producer" {
  default = "cdcpocdemoproducer1"
  description   = "App Service name."
}