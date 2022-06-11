# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

variable "location" {
  default = "switzerlandnorth"
}

variable "prefix" {
  default = "zrhapttf2"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "apiTf" {
  name     = "zrh-apt-tf2"
  location = var.location
}

resource "azurerm_storage_account" "apiTf" {
  location                  = azurerm_resource_group.apiTf.location
  account_tier              = "Standard"
  access_tier               = "Hot"
  account_replication_type  = "LRS"
  name                      = "${var.prefix}storageacct"
  enable_https_traffic_only = true
  resource_group_name       = azurerm_resource_group.apiTf.name
}


resource "azurerm_application_insights" "apiTf" {
  name                = "${var.prefix}-appinsights"
  resource_group_name = azurerm_resource_group.apiTf.name
  location            = var.location
  application_type    = "web"
}

resource "azurerm_service_plan" "apiTf" {
  name                = "${var.prefix}-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.apiTf.name
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_windows_function_app" "apiTf" {
  name                       = "${var.prefix}-funcapp"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.apiTf.name
  service_plan_id            = azurerm_service_plan.apiTf.id
  storage_account_name       = azurerm_storage_account.apiTf.name
  storage_account_access_key = azurerm_storage_account.apiTf.primary_access_key

  https_only = true

  app_settings = {
    /*"AzureWebJobsDashboard"                    = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.apiTf.name};AccountKey=${azurerm_storage_account.apiTf.primary_access_key}"
    "AzureWebJobsStorage"                      = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.apiTf.name};AccountKey=${azurerm_storage_account.apiTf.primary_access_key}"
    
    //"FUNCTIONS_EXTENSION_VERSION"              = "~4"
    //"APPINSIGHTS_INSTRUMENTATIONKEY"           = azurerm_application_insights.apiTf.instrumentation_key*/
    "FUNCTIONS_WORKER_RUNTIME"                 = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"             = "~16"
    //"WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.apiTf.name};AccountKey=${azurerm_storage_account.apiTf.primary_access_key}"
    //"WEBSITE_CONTENTHARE" = "${azure}"
  }
  site_config {
    application_insights_key               = azurerm_application_insights.apiTf.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.apiTf.connection_string


  }
}


