# hslu_msed
Hochschule Luzern - Modern Software Engineering and Development

## Overview

This repository contains Infrastructure as Code (IaC) for deploying Azure cloud services using Terraform.

## Infrastructure Components

The project deploys the following Azure services:

- **Azure Data Lake Storage Gen2 (ADLS Gen2)**: Scalable data lake for analytics workloads
- **Cosmos DB**: Globally distributed NoSQL database with SQL API
- **Azure SQL Database**: Managed relational database service
- **Azure Functions**: Serverless compute platform for event-driven applications

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription with appropriate permissions

### Quick Start

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Follow the instructions in [terraform/README.md](terraform/README.md) for detailed setup and deployment steps.

## Repository Structure

```
.
├── terraform/          # Terraform configuration files
│   ├── main.tf        # Main infrastructure definitions
│   ├── variables.tf   # Variable declarations
│   ├── outputs.tf     # Output definitions
│   ├── providers.tf   # Provider configuration
│   └── README.md      # Detailed Terraform documentation
└── README.md          # This file
```

## Documentation

For detailed information about the Terraform infrastructure, including:
- Resource specifications
- Configuration options
- Deployment instructions
- Troubleshooting

Please refer to [terraform/README.md](terraform/README.md).

## License

This project is part of the HSLU MSED program.
