# Azure Function - HSLU MSED

This directory contains a C# Azure Function with HTTP trigger.

## Structure

- `HttpTriggerFunction.cs` - HTTP trigger function that responds to GET and POST requests
- `Program.cs` - Entry point and host configuration
- `HsluMsedFunction.csproj` - Project file with .NET 8.0 and Azure Functions v4
- `host.json` - Function app configuration
- `local.settings.json` - Local development settings (not committed to git)

## Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local)
  ```powershell
  npm install -g azure-functions-core-tools@4 --unsafe-perm true
  ```

## Local Development

1. **Restore dependencies**
   ```powershell
   dotnet restore
   ```

2. **Build the project**
   ```powershell
   dotnet build
   ```

3. **Run locally**
   ```powershell
   func start
   ```

4. **Test the function**
   ```powershell
   # GET request with query parameter
   curl "http://localhost:7071/api/HttpTriggerFunction?name=John"
   
   # POST request with JSON body
   curl -X POST http://localhost:7071/api/HttpTriggerFunction -H "Content-Type: application/json" -d '{"name":"John"}'
   ```

## Deploy to Azure

After deploying infrastructure with Terraform:

```powershell
# Build and publish
dotnet publish --configuration Release

# Deploy using Azure CLI
func azure functionapp publish <function-app-name>
```

Or use the Azure Functions VS Code extension for easier deployment.

## Function Details

### HttpTriggerFunction

- **Trigger**: HTTP (GET, POST)
- **Authorization Level**: Function (requires function key)
- **Route**: `api/HttpTriggerFunction`
- **Input**: Accepts `name` parameter from query string or JSON body
- **Output**: Returns personalized greeting message

## Configuration

Update `local.settings.json` with your Azure resource connection strings after deploying infrastructure.
