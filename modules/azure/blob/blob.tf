# Storage Account for Blob read/write operations
resource "azurerm_storage_account" "tech_test_sa" {
  name                     = "techteststorageacct"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

# Storage Container for Blob
resource "azurerm_storage_container" "tech_test_container" {
  name                  = "tech-test-container"
  storage_account_name  = azurerm_storage_account.tech_test_sa.name
  container_access_type = "private"
}

# Storage Account Key
data "azurerm_storage_account_sas" "tech_test_sas" {
  connection_string = azurerm_storage_account.tech_test_sa.primary_connection_string
  https_only        = true
  start             = "2024-01-01"
  expiry            = "2025-01-01"
  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob = true
    queue = false
    table = false
    file = false
  }
  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    filter = false
    tag = false
  }
}

# Storage Account for Function App
resource "azurerm_storage_account" "tech_test_function_storage" {
  name                     = "functionappstorage"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

output "tech_test_function_storage_name" {
  value = azurerm_storage_account.tech_test_function_storage.name
}

output "tech_test_function_storage_key" {
  value = azurerm_storage_account.tech_test_function_storage.primary_access_key
}

output "tech_test_function_storage_id" {
  value = azurerm_storage_account.tech_test_function_storage.id 
  
}

output "sas_url_query_string" {
  value = data.azurerm_storage_account_sas.tech_test_sas.sas
}