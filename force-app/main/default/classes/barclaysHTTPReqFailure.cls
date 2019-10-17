@isTest
                        
global class barclaysHTTPReqFailure implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals(system.label.BarclaysEndPoint, req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody('<?xml version="1.0" encoding="utf-8"?>'+
                '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
                '<soap:Body>'+
                '<SubmitNewApplicationResponse xmlns="http://www.barclays-partnerfinance.com/">'+
                '<SubmitNewApplicationResult>'+
                '<Errors IsError="true">'+
                '<ErrorDetails>'+
                '<ErrorDetail Code="209" Message="The client reference supplied already exists" />'+
                '</ErrorDetails>'+
                '</Errors>'+
                '<Token>00000000-0000-0000-0000-000000000000</Token>'+
                '<ProposalID>0</ProposalID>'+
                '</SubmitNewApplicationResult>'+
                '</SubmitNewApplicationResponse>'+
                '</soap:Body>'+
                '</soap:Envelope>');
        res.setStatusCode(200);
        return res;
    }
}