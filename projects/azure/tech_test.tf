/*
  Tech Test Project - Azure

    Calls vnet module to create a virtual network with a public and private subnet and NAT Gateway
    Calls function module to create a function app with a storage account and a python function that 
    echos the contents of a text file uploaded to the blob storage container to a log file
*/

# Create Resource Group
resource "azurerm_resource_group" "tech-test-rg" {
  name     = "identify-tech-test"
  location = var.location
}

module "vnet" {
  source = "../../modules/azure/vnet"

  rg_location = azurerm_resource_group.tech-test-rg.location
  rg_name     = azurerm_resource_group.tech-test-rg.name
  tags        = var.tags
}


module "function" {
  source      = "../../modules/azure/function"
  rg_location = azurerm_resource_group.tech-test-rg.location
  rg_name     = azurerm_resource_group.tech-test-rg.name

  tags = var.tags
}

