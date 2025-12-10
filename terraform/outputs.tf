# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# ADLS Gen2 Outputs
output "adls_storage_account_name" {
  description = "Name of the ADLS Gen2 storage account"
  value       = azurerm_storage_account.adls.name
}

output "adls_primary_endpoint" {
  description = "Primary DFS endpoint for ADLS Gen2"
  value       = azurerm_storage_account.adls.primary_dfs_endpoint
}

output "adls_filesystems" {
  description = "List of ADLS Gen2 filesystems"
  value = [
    azurerm_storage_data_lake_gen2_filesystem.data.name,
    azurerm_storage_data_lake_gen2_filesystem.raw.name,
    azurerm_storage_data_lake_gen2_filesystem.processed.name
  ]
}

# Cosmos DB Outputs
output "cosmos_db_endpoint" {
  description = "Endpoint for Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_account_name" {
  description = "Name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmos_db_database_name" {
  description = "Name of the Cosmos DB SQL database"
  value       = azurerm_cosmosdb_sql_database.main.name
}

output "cosmos_db_container_name" {
  description = "Name of the Cosmos DB SQL container"
  value       = azurerm_cosmosdb_sql_container.main.name
}

output "cosmos_db_primary_key" {
  description = "Primary key for Cosmos DB account"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

# Azure SQL Outputs
output "sql_server_name" {
  description = "Name of the Azure SQL Server"
  value       = azurerm_mssql_server.main.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the Azure SQL Server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "sql_database_name" {
  description = "Name of the Azure SQL Database"
  value       = azurerm_mssql_database.main.name
}

# Azure Functions Outputs
output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_url" {
  description = "Default hostname of the Azure Function App"
  value       = "https://${azurerm_linux_function_app.main.default_hostname}"
}

output "function_storage_account_name" {
  description = "Name of the storage account for Azure Functions"
  value       = azurerm_storage_account.function.name
}

output "app_service_plan_name" {
  description = "Name of the App Service Plan"
  value       = azurerm_service_plan.function.name
}
