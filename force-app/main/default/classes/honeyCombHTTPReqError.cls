@isTest
                        
global class honeyCombHTTPReqError implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
         HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"applicationId":1,"errors":[],"succeeded":true,"Status":"AwaitingDecision"}');
        //res.setBody('{"applicationId":"Test"}');
        res.setStatusCode(200);
        return res;
    }
}