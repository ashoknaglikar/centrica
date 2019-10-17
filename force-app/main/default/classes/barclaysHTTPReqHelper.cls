@isTest
                        
global class barclaysHTTPReqHelper implements HttpCalloutMock {
    
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
                    '<Errors IsError="false" />'+
                    '<Token>c27910b1-0b36-4571-953d-56024e3b6eab</Token>'+
                    '<ProposalID>3062688</ProposalID>'+
                    '</SubmitNewApplicationResult>'+
                    '</SubmitNewApplicationResponse>'+
                    '</soap:Body>'+
                    '</soap:Envelope>');
        res.setStatusCode(200);
        return res;
    }
}