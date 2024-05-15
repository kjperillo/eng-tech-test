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

module "blob" {
  source = "../../modules/azure/blob"

  rg_location = azurerm_resource_group.tech-test-rg.location
  rg_name     = azurerm_resource_group.tech-test-rg.name

  tags = var.tags
}

module "function" {
  source      = "../../modules/azure/function"
  rg_location = azurerm_resource_group.tech-test-rg.location
  rg_name     = azurerm_resource_group.tech-test-rg.name

  tech_test_function_storage_key  = module.blob.tech_test_function_storage_key
  tech_test_function_storage_name = module.blob.tech_test_function_storage_name
  tech_test_function_storage_id   = module.blob.tech_test_function_storage_id

  tags = var.tags
}

