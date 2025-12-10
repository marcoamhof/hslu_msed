# Azure Infrastructure with Terraform

This directory contains Terraform configuration files to deploy Azure infrastructure for the HSLU MSED project.

## Resources Deployed

1. **Azure Data Lake Storage Gen2 (ADLS Gen2)**
   - Storage account with hierarchical namespace enabled
   - Three filesystems: `data`, `raw`, and `processed`

2. **Cosmos DB**
   - Cosmos DB account with SQL API
   - Database: `maindb`
   - Container: `items` with partition key `/id`
   - Autoscale throughput configuration

3. **Azure SQL Database**
   - SQL Server instance
   - SQL Database with configurable SKU
   - Firewall rule to allow Azure services

4. **Azure Functions**
   - Linux App Service Plan (Consumption plan by default)
   - Function App with Python runtime
   - Storage account for function app
   - Pre-configured app settings with connection strings

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription

## Setup

1. **Authenticate with Azure**
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Create terraform.tfvars file**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   
   Edit `terraform.tfvars` and set your desired values, especially:
   - `sql_admin_password` (use a strong password)
   - `project_name` (must be unique for storage accounts)
   - Other configuration parameters as needed

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the execution plan**
   ```bash
   terraform plan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply
   ```

## Configuration

### Required Variables

- `sql_admin_password`: Password for the SQL Server administrator account (sensitive)

### Optional Variables

All other variables have sensible defaults. See `variables.tf` for the complete list and `terraform.tfvars.example` for examples.

### Important Notes

- Storage account names must be globally unique and between 3-24 characters
- The default `project_name` is "hslumsed" - you may need to change this if it conflicts
- SQL admin password must meet Azure's complexity requirements
- The Function App is pre-configured with connection strings to all storage services

## Outputs

After successful deployment, Terraform will output:
- Resource group details
- ADLS Gen2 endpoints and filesystem names
- Cosmos DB endpoint and database/container names
- Azure SQL Server FQDN and database name
- Function App URL and configuration

To view outputs after deployment:
```bash
terraform output
```

To view sensitive outputs (like Cosmos DB keys):
```bash
terraform output cosmos_db_primary_key
```

## Resource Naming Convention

Resources follow the pattern: `{project_name}-{environment}-{resource_type}`

Example with defaults:
- Resource Group: `hslumsed-dev-rg`
- Cosmos DB: `hslumsed-dev-cosmos`
- SQL Server: `hslumsed-dev-sql`
- Function App: `hslumsed-dev-func`

Storage accounts remove hyphens and environment suffix: `hslumseddevadls`, `hslumseddevfunc`

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Security Considerations

- Never commit `terraform.tfvars` to version control (it's in `.gitignore`)
- Use Azure Key Vault for production secrets
- Consider using managed identities instead of connection strings
- Review and adjust firewall rules for production environments
- The current SQL firewall rule allows all Azure services - restrict this in production

## Next Steps

After deploying the infrastructure:

1. **Deploy Azure Functions code**
   - Navigate to the Function App in Azure Portal
   - Use VS Code Azure Functions extension, or
   - Use Azure CLI: `az functionapp deployment source config-zip`

2. **Configure ADLS Gen2**
   - Set up access control (ACLs)
   - Configure lifecycle management policies

3. **Set up Cosmos DB**
   - Create additional containers as needed
   - Configure indexing policies

4. **Configure Azure SQL**
   - Run database migrations
   - Set up additional firewall rules
   - Configure geo-replication if needed

## Troubleshooting

### Storage Account Name Conflicts
If you get an error about storage account name already taken, change the `project_name` variable to something unique.

### Authentication Issues
Ensure you're logged in with `az login` and have the correct subscription selected.

### Permission Errors
Your Azure account needs Contributor or Owner permissions on the subscription to create resources.
