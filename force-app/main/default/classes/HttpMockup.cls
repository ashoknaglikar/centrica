@isTest
global class HttpMockup implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('<?xml version="1.0" encoding="utf-8" ?><CREATE_LANDMARK><RESPONSE_STATUS><CODE>1</CODE><DESCRIPTION>SUCCESS</DESCRIPTION></RESPONSE_STATUS><LANDMARK_COORDINATES><LAT>42.842705</LAT><LON>-85.67502</LON></LANDMARK_COORDINATE');
        res.setStatusCode(200);
        return res;
    }
}