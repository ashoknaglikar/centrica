@isTest
global class customerChoiceHubHTTPRequest_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<statusCode>204</statusCode>');
        res.setStatusCode(200);
        return res;
    }
}