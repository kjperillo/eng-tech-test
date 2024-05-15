# App Service Plan
resource "azurerm_service_plan" "tech_test_plan" {
  name                = "tech-test-plan"
  location            = var.rg_location
  resource_group_name = var.rg_name
  os_type = "Linux"
  sku_name = "Y1"
  tags = var.tags
}

# Function App
resource "azurerm_linux_function_app" "tech_test_function_app" {
  name                = "tech-test-linux-function-app"
  location                   = var.rg_location
  resource_group_name        = var.rg_name

  storage_account_name       = var.tech_test_function_storage_name
  storage_account_access_key = var.tech_test_function_storage_key
  service_plan_id            = azurerm_service_plan.tech_test_plan.id

  site_config {
    application_stack {
        python_version = "3.12"
    }
  }
  tags = var.tags
}

# resource "azurerm_function_app" "main" {
#   name                       = "techtestfunctionapp"
#   location                   = var.rg_location
#   resource_group_name        = var.rg_name
#   app_service_plan_id        = azurerm_app_service_plan.tech_test_plan.id
#   storage_account_name       = var.tech_test_function_storage_name
#   storage_account_access_key = var.tech_test_function_storage_key
#   os_type                    = "Linux"
#   runtime_stack              = "python"
#   version                    = "~3"

#   app_settings = {
#     "AzureWebJobsStorage" = azurerm_storage_account.function.primary_connection_string
#     "FUNCTIONS_EXTENSION_VERSION" = "~3"
#     "WEBSITE_RUN_FROM_PACKAGE" = "1"
#   }

#   tags = var.tags
# }

# Event Grid Subscription
resource "azurerm_eventgrid_event_subscription" "tech_test_event_subscription" {
  name                 = "tech-test-event-subscription"
  scope                = var.tech_test_function_storage_id
  event_delivery_schema = "EventGridSchema"
  included_event_types  = ["Microsoft.Storage.BlobCreated"]
  azure_function_endpoint {
    function_id = azurerm_linux_function_app.tech_test_function_app.id
  }
}