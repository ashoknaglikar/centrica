@RestResource(urlMapping='/engineerLeadCreate/*')
global class engineerLeadCreateRestHeler {
    
    @httppost
    global static webservice_CHI_Online.ManageCustomerBookingResponse financeApplicationCreation(string request)
    {
        webservice_CHI_Online.ManageCustomerBookingResponse reply  = new webservice_CHI_Online.ManageCustomerBookingResponse();
        
        if(!string.isBlank(request))
        {
            system.debug('JSON Request -->'+request);
            
            webservice_CHI_Online.ManageCustomerBooking  requestObj =   (webservice_CHI_Online.ManageCustomerBooking) JSON.deserialize(request, webservice_CHI_Online.ManageCustomerBooking.class);
            
            system.debug('After Deserialization -->'+requestObj);
            
            webManageCustomerBooking enginnerClassObj = new webManageCustomerBooking();
            
            //use the requestObj to make the online manage customer booking. 
            reply =  enginnerClassObj.webManageCustomerBookingFunc(requestObj);
            
           
            
        }else{
            system.debug('JSON Request -->'+request);
            reply.Error.Code = 11;
            reply.Error.Message = 'Request is blank';
            system.debug(reply.Error.Message);
        }
       return reply;
    }
        

}