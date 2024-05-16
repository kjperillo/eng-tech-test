# Storage Account for Blob read/write operations
resource "azurerm_storage_account" "tech_test_sa" {
  name                     = "techtesttargetsa"
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
    filter = true
    tag = true
  }
}

# Storage Account for Function App
resource "azurerm_storage_account" "tech_test_function_storage" {
  name                     = "perillofuncstorage"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = var.tags
}

resource "azurerm_application_insights" "application_insight" {
  name                = "tech-test-appinsight"
  resource_group_name = var.rg_name
  location            = var.rg_location
  application_type    = "other"
}

# Storage Container for Function App Code
resource "azurerm_storage_container" "echo_file_function_code" {
  name                  = "echo-file-function-code"
  storage_account_name  = azurerm_storage_account.tech_test_function_storage.name
  container_access_type = "private"
}

# resource "null_resource" "source_code_hash" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   provisioner "local-exec" {
#     command = "find ${path.module}/code -type f -exec md5 {} \\; | sort -k 2 | md5 > ${path.module}/code_hash"
#   }
# }

# data "local_file" "source_code_hash" {
#   filename = "${path.module}/code_hash"
# }

# Package Function App Code
data "archive_file" "function_app" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/function_app.zip"
#   depends_on = [
#     data.local_file.source_code_hash
#   ]
}

# Upload Function App Code
resource "azurerm_storage_blob" "function_zip" {
  name                   = "function_app.zip"
  storage_account_name   = azurerm_storage_account.tech_test_function_storage.name
  storage_container_name = azurerm_storage_container.echo_file_function_code.name
  type                   = "Block"
  source                 = data.archive_file.function_app.output_path
  depends_on             = [azurerm_storage_container.echo_file_function_code]
}

# App Service Plan
resource "azurerm_service_plan" "tech_test_plan" {
  name                = "tech-test-plan"
  location            = var.rg_location
  resource_group_name = var.rg_name
  os_type             = "Linux"
  sku_name            = "Y1"
  tags = var.tags
}

# Function App
resource "azurerm_linux_function_app" "tech_test_function_app" {
  name                       = "tech-test-linux-function-app"
  location                   = var.rg_location
  resource_group_name        = var.rg_name
  storage_account_name       = azurerm_storage_account.tech_test_function_storage.name
  storage_account_access_key = azurerm_storage_account.tech_test_function_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.tech_test_plan.id
  site_config {
    application_stack {
        python_version = "3.11"
    }
  }
  zip_deploy_file = data.archive_file.function_app.output_path
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "python"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.application_insight.instrumentation_key
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    AzureWebJobsStorage            = azurerm_storage_account.tech_test_function_storage.primary_connection_string
  }
  tags = var.tags
  depends_on = [azurerm_storage_blob.function_zip]
}

# Event Grid Subscription
resource "azurerm_eventgrid_event_subscription" "tech_test_event_subscription" {
  name                 = "tech-test-event-subscription"
  scope                = azurerm_storage_account.tech_test_sa.id
  event_delivery_schema = "EventGridSchema"
  included_event_types  = ["Microsoft.Storage.BlobCreated"]
  azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.tech_test_function_app.id}/functions/echoFunction"
  }
  depends_on = [azurerm_linux_function_app.tech_test_function_app]
}
