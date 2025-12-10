# Azure Functions

This directory contains Azure Functions for the HSLU MSED project.

## Functions

### azf_helloworld

A simple HTTP trigger function that demonstrates the basic structure of an Azure Function.

**Endpoint:** HTTP GET/POST  
**Authentication:** Function level

**Parameters:**
- `name` (optional): A name to personalize the greeting. Can be passed as a query parameter or in the request body.

**Example requests:**
```bash
# Basic request
curl https://<function-app-name>.azurewebsites.net/api/azf_helloworld

# With name parameter (query string)
curl "https://<function-app-name>.azurewebsites.net/api/azf_helloworld?name=Marco"

# With name parameter (POST body)
curl -X POST https://<function-app-name>.azurewebsites.net/api/azf_helloworld \
  -H "Content-Type: application/json" \
  -d '{"name": "Marco"}'
```

## Local Development

### Prerequisites
- Python 3.8 or higher
- Azure Functions Core Tools

### Setup
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Install Azure Functions Core Tools:
   ```bash
   npm install -g azure-functions-core-tools@4
   ```

3. Run locally:
   ```bash
   func start
   ```

The function will be available at `http://localhost:7071/api/azf_helloworld`

## Deployment

This Azure Function can be deployed using:
- Azure CLI
- Azure Portal
- CI/CD pipelines
- Terraform (see `/terraform` directory for infrastructure as code)

## Configuration

- `host.json`: Azure Functions host configuration
- `requirements.txt`: Python dependencies
- `function.json`: Function-specific configuration (bindings, triggers, etc.)
