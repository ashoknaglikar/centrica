@isTest
global class CustomerPortalFinanaceRestHelper_Mock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element respElement = new wwwBarclaysPartnerfinanceCom.ApplicationEnquiryResponse_element();
               
               wwwBarclaysPartnerfinanceCom.ErrorsWO erWo= new wwwBarclaysPartnerfinanceCom.ErrorsWO();
               erWo.ErrorCode=400;
               erWo.ErrorDescription='test not found';
               wwwBarclaysPartnerfinanceCom.ArrayOfErrorsWO err= new wwwBarclaysPartnerfinanceCom.ArrayOfErrorsWO();
               err.ErrorsWO = new list<wwwBarclaysPartnerfinanceCom.ErrorsWO>();
               err.ErrorsWO.add(erWo);
               respElement.errors=err;
               response.put('response_x', respElement); 
   }
}