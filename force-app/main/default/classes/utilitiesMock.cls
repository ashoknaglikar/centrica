@IsTest
global class utilitiesMock implements HttpCalloutMock {
global HTTPResponse respond(HTTPRequest req) {

    HttpResponse res=new HttpResponse();
    res.setHeader('', '');
    res.setBody('{"destination_addresses" : [ "Neville Cl, Bolton BL1 2XR, UK" ],"origin_addresses" : [ "Caistor St, Stockport SK1 2LG, UK" ],"rows" : [{"elements" : [{"distance" : { "text" : "22.8 mi","value" : 36753 },"duration" : {"text" : "32 mins","value" : 1924},"duration_in_traffic" : {"text" : "36 mins","value" : 2178},"status" : "OK"}]}],"status" : "OK"}');
    res.setStatusCode(200);
return res;
    
}
}