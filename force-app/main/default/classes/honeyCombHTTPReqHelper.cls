@isTest
                        
global class honeyCombHTTPReqHelper implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
         HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"Accepeted"}');
        res.setStatusCode(201);
        return res;
    }
}