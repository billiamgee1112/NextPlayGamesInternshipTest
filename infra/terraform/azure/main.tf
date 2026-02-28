// Azure Terraform skeleton
terraform {
  required_version = ">= 1.0"
}

provider "azurerm" {
  features = {}
}

// Example: Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
