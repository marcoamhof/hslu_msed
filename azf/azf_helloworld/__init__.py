import logging
import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Function: Hello World HTTP Trigger
    
    This function responds to HTTP GET and POST requests with a greeting message.
    It can personalize the greeting if a 'name' parameter is provided.
    """
    logging.info('Python HTTP trigger function processed a request.')

    # Try to get 'name' parameter from query string or request body
    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            req_body = None
        
        if req_body:
            name = req_body.get('name')

    # Return personalized or default greeting
    if name:
        return func.HttpResponse(
            f"Hello, {name}! This HTTP triggered function executed successfully.",
            status_code=200
        )
    else:
        return func.HttpResponse(
            "Hello World! This HTTP triggered function executed successfully. "
            "Pass a name in the query string or in the request body for a personalized response.",
            status_code=200
        )
