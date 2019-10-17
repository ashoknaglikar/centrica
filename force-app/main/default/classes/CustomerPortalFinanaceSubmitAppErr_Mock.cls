@isTest
global class CustomerPortalFinanaceSubmitAppErr_Mock implements WebServiceMock {
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
       wwwBarclaysPartnerfinanceCom.LoadApplicationResponse_element respElement = new wwwBarclaysPartnerfinanceCom.LoadApplicationResponse_element();
       
               wwwBarclaysPartnerfinanceCom.ResultWO result = new wwwBarclaysPartnerfinanceCom.ResultWO();
               wwwBarclaysPartnerfinanceCom.ErrorsWO erWo= new wwwBarclaysPartnerfinanceCom.ErrorsWO();
               erWo.ErrorCode=400;
               erWo.ErrorDescription='test not found';
               wwwBarclaysPartnerfinanceCom.ArrayOfErrorsWO err= new wwwBarclaysPartnerfinanceCom.ArrayOfErrorsWO();
               err.ErrorsWO = new list<wwwBarclaysPartnerfinanceCom.ErrorsWO>();
               err.ErrorsWO.add(erWo);
               result.Errors=err;
               
               respElement.LoadApplicationResult=result;
               response.put('response_x', respElement); 
   }
}