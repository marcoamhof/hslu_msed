using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;
using System.Text.Json;

namespace HsluMsedFunction;

public class HttpTriggerFunction
{
    private readonly ILogger<HttpTriggerFunction> _logger;

    public HttpTriggerFunction(ILogger<HttpTriggerFunction> logger)
    {
        _logger = logger;
    }

    [Function("HttpTriggerFunction")]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequestData req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");

        // Parse query parameters
        string? name = null;
        var query = req.Url.Query;
        if (!string.IsNullOrEmpty(query))
        {
            var queryParts = query.TrimStart('?').Split('&');
            foreach (var part in queryParts)
            {
                var keyValue = part.Split('=');
                if (keyValue.Length == 2 && keyValue[0].Equals("name", StringComparison.OrdinalIgnoreCase))
                {
                    name = Uri.UnescapeDataString(keyValue[1]);
                    break;
                }
            }
        }

        // Try to read from request body if name not in query
        if (string.IsNullOrEmpty(name) && req.Body.CanRead)
        {
            try
            {
                var requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                if (!string.IsNullOrWhiteSpace(requestBody))
                {
                    var data = JsonSerializer.Deserialize<JsonElement>(requestBody);
                    if (data.TryGetProperty("name", out var nameProperty))
                    {
                        name = nameProperty.GetString();
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning($"Failed to parse request body: {ex.Message}");
            }
        }

        // Create response
        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

        string responseMessage = string.IsNullOrEmpty(name)
            ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
            : $"Hello, {name}. This HTTP triggered function executed successfully.";

        await response.WriteStringAsync(responseMessage);

        return response;
    }
}
