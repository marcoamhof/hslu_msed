variable "project_name" {
  description = "Name of the project, used as prefix for resources"
  type        = string
  default     = "hslumsed"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "hslumsed"
}

# ADLS Gen2 Variables
variable "adls_account_tier" {
  description = "Performance tier for ADLS Gen2 storage account"
  type        = string
  default     = "Standard"
}

variable "adls_replication_type" {
  description = "Replication type for ADLS Gen2 storage account"
  type        = string
  default     = "LRS"
}

# Cosmos DB Variables
variable "cosmos_db_offer_type" {
  description = "Offer type for Cosmos DB"
  type        = string
  default     = "Standard"
}

variable "cosmos_db_consistency_level" {
  description = "Consistency level for Cosmos DB"
  type        = string
  default     = "Session"
}

variable "cosmos_db_max_throughput" {
  description = "Maximum throughput for Cosmos DB with autoscale"
  type        = number
  default     = 1000
}

# Azure SQL Variables
variable "sql_admin_username" {
  description = "Administrator username for Azure SQL Server"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "Administrator password for Azure SQL Server (min 8 chars, must include uppercase, lowercase, numbers, and special characters)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.sql_admin_password) >= 8
    error_message = "SQL admin password must be at least 8 characters long."
  }
}

variable "sql_db_sku_name" {
  description = "SKU name for Azure SQL Database"
  type        = string
  default     = "Basic"
}

variable "sql_db_max_size_gb" {
  description = "Maximum size in GB for Azure SQL Database"
  type        = number
  default     = 2
}

# Azure Functions Variables
variable "function_app_service_plan_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "Y1" # Consumption plan
}

variable "function_runtime" {
  description = "Runtime for Azure Functions"
  type        = string
  default     = "dotnet"
}

variable "function_runtime_version" {
  description = "Runtime version for Azure Functions (.NET version: v6.0, v7.0, v8.0)"
  type        = string
  default     = "v8.0"
}

# Key Vault Variables
variable "key_vault_sku_name" {
  description = "SKU name for Azure Key Vault"
  type        = string
  default     = "standard"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "HSLU MSED"
    ManagedBy = "Terraform"
  }
}
