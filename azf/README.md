# Azure Functions

This directory contains Azure Functions for the project.

## Functions

### azf_helloworld

An HTTP trigger function that responds with a greeting message.

**Trigger Type:** HTTP (GET/POST)

**Request Parameters:**
- `name` (optional): Name to include in the greeting

**Example Usage:**

```bash
# GET request with query parameter
curl http://localhost:7071/api/azf_helloworld?name=John

# POST request with JSON body
curl -X POST http://localhost:7071/api/azf_helloworld \
  -H "Content-Type: application/json" \
  -d '{"name":"John"}'
```

**Response:**
- With name: `Hello, {name}. This HTTP triggered function executed successfully.`
- Without name: `This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.`

## Local Development

### Prerequisites

1. Python 3.8 or later
2. Azure Functions Core Tools

### Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the function locally:
   ```bash
   func start
   ```

3. Test the function:
   ```bash
   curl http://localhost:7071/api/azf_helloworld?name=Test
   ```

## Deployment

Deploy to Azure using Azure Functions Core Tools:

```bash
func azure functionapp publish <your-function-app-name>
```

Or use the Terraform configuration in the `/terraform` directory.
