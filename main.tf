terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.54.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }

  }
  backend "azurerm" {
    resource_group_name  = "Terraform-Resource-Group"
    storage_account_name = "taskboardstorage41388"
    container_name       = "taskboardcontainer"
    key                  = "terraform.tfstate"
  }
}



resource "random_integer" "ri" {
  min = 1
  max = 50000
}

provider "azurerm" {
  features {}
  subscription_id = "b40d68bb-c74b-42d1-a7c9-9a4da68f7402"
}


resource "azurerm_resource_group" "arg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_resource_group.arg.location
  os_type             = var.os_type
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "alwa" {
  name                = azurerm_service_plan.asp.name
  resource_group_name = azurerm_resource_group.arg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssql_database.name};User ID=${azurerm_mssql_server.server.administrator_login};Password=${azurerm_mssql_server.server.administrator_login_password};Trusted_Connection=False;MultipleActiveResultSets=True;"
  }
  site_config {

    application_stack {
      dotnet_version = "8.0"
    }
    always_on = false
  }
}

resource "azurerm_app_service_source_control" "example" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = var.github_repo_url
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_mssql_server" "server" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "mssql_database" {
  name                 = "${var.sql_database_name}-${random_integer.ri.result}"
  server_id            = azurerm_mssql_server.server.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "S0"
  enclave_type         = "VBS"
  geo_backup_enabled   = false
  zone_redundant       = false
  storage_account_type = "Local"

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall" {
  name             = var.firewall_rule_name
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

