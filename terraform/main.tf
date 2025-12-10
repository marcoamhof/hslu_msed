# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name != "" ? var.resource_group_name : "${var.project_name}-${var.environment}-rg"
  location = var.location
  tags     = var.tags
}

# Azure Data Lake Storage Gen2
resource "azurerm_storage_account" "adls" {
  name                     = lower("${var.project_name}${var.environment}adls")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.adls_account_tier
  account_replication_type = var.adls_replication_type
  account_kind             = "StorageV2"
  is_hns_enabled           = true # This enables hierarchical namespace for ADLS Gen2

  tags = var.tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data" {
  name               = "data"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "raw" {
  name               = "raw"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "processed" {
  name               = "processed"
  storage_account_id = azurerm_storage_account.adls.id
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                = "${var.project_name}-${var.environment}-cosmos"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = var.cosmos_db_offer_type
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = var.cosmos_db_consistency_level
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }

  tags = var.tags
}

# Cosmos DB SQL Database
resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "maindb"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name

  autoscale_settings {
    max_throughput = var.cosmos_db_max_throughput
  }
}

# Cosmos DB SQL Container
resource "azurerm_cosmosdb_sql_container" "main" {
  name                = "items"
  resource_group_name = azurerm_cosmosdb_account.main.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/id"]

  autoscale_settings {
    max_throughput = var.cosmos_db_max_throughput
  }
}

# Azure SQL Server
resource "azurerm_mssql_server" "main" {
  name                         = "${var.project_name}-${var.environment}-sql"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password

  tags = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "main" {
  name        = "${var.project_name}-${var.environment}-db"
  server_id   = azurerm_mssql_server.main.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb = var.sql_db_max_size_gb
  sku_name    = var.sql_db_sku_name

  tags = var.tags
}

# Firewall rule to allow Azure services
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Storage Account for Azure Functions
resource "azurerm_storage_account" "function" {
  name                     = lower("${var.project_name}${var.environment}func")
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

# App Service Plan for Azure Functions
resource "azurerm_service_plan" "function" {
  name                = "${var.project_name}-${var.environment}-asp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = var.function_app_service_plan_sku

  tags = var.tags
}

# Azure Function App
resource "azurerm_linux_function_app" "main" {
  name                = "${var.project_name}-${var.environment}-func"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.function.id

  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  site_config {
    application_stack {
      python_version = var.function_runtime_version
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = var.function_runtime
    "COSMOS_DB_ENDPOINT"       = azurerm_cosmosdb_account.main.endpoint
    "COSMOS_DB_KEY"            = azurerm_cosmosdb_account.main.primary_key
    "COSMOS_DB_DATABASE"       = azurerm_cosmosdb_sql_database.main.name
    "COSMOS_DB_CONTAINER"      = azurerm_cosmosdb_sql_container.main.name
    "ADLS_ACCOUNT_NAME"        = azurerm_storage_account.adls.name
    "ADLS_ACCOUNT_KEY"         = azurerm_storage_account.adls.primary_access_key
    "SQL_CONNECTION_STRING"    = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

  tags = var.tags
}
