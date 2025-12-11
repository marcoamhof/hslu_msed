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

# Data source to get current client configuration
data "azurerm_client_config" "current" {}

# Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                       = "${var.project_name}-${var.environment}-kv"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.key_vault_sku_name
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Access policy for the current user/service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]
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

# Cosmos DB SQL Container - Todo
resource "azurerm_cosmosdb_sql_container" "todo" {
  name                = "todo"
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
# SECURITY NOTE: This allows all Azure services to connect. For production, use more
# restrictive firewall rules or implement Virtual Network integration with private endpoints.
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
  os_type             = "Windows"
  sku_name            = var.function_app_service_plan_sku

  tags = var.tags
}

# Key Vault Secrets
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "cosmos_db_primary_key" {
  name         = "cosmos-db-primary-key"
  value        = azurerm_cosmosdb_account.main.primary_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "adls_primary_key" {
  name         = "adls-primary-key"
  value        = azurerm_storage_account.adls.primary_access_key
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "sql-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${var.sql_admin_username};Password=${var.sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Azure Function App
# SECURITY NOTE: This configuration uses connection strings and access keys for simplicity.
# For production, consider using managed identities and Azure Key Vault references instead.
# See README.md for security best practices.
resource "azurerm_windows_function_app" "main" {
  name                = "${var.project_name}-${var.environment}-func"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.function.id

  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  site_config {
    application_stack {
      dotnet_version = var.function_runtime_version
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

# Azure AD Application for Service Principal
resource "azuread_application" "main" {
  display_name = "${var.project_name}-${var.environment}-app"
}

# Service Principal
resource "azuread_service_principal" "main" {
  client_id = azuread_application.main.client_id
}

# Service Principal Password
resource "azuread_service_principal_password" "main" {
  service_principal_id = azuread_service_principal.main.object_id
}

# Role Assignment - Contributor on Resource Group
resource "azurerm_role_assignment" "sp_contributor" {
  scope                = azurerm_resource_group.main.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.main.object_id
}

# Role Assignment - Storage Blob Data Contributor on ADLS
resource "azurerm_role_assignment" "sp_storage_blob" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.main.object_id
}

# Key Vault Access Policy for Service Principal
resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.main.object_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Store Service Principal credentials in Key Vault
resource "azurerm_key_vault_secret" "sp_client_id" {
  name         = "sp-client-id"
  value        = azuread_application.main.client_id
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "sp_client_secret" {
  name         = "sp-client-secret"
  value        = azuread_service_principal_password.main.value
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "sp_tenant_id" {
  name         = "sp-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}
