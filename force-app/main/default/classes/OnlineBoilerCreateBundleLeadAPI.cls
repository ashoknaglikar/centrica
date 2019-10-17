@RestResource(urlMapping='/createBundleLead/*')
global class OnlineBoilerCreateBundleLeadAPI {
    
    @httppost
    global static createBundleLeadResponse createBundleLeadMethod(/*string request*/)
    {
        RestRequest req = RestContext.request;
        String request = req.requestBody.toString();
        system.debug('into online boiler API'+request);
        createBundleLeadResponse reply = new createBundleLeadResponse();
        
        if(!string.isBlank(request))
        {
           createBundleLeadRequest requestObj =   (createBundleLeadRequest) JSON.deserialize(request, createBundleLeadRequest.class);
           createBundleLeadHelper createBundleLeadObj = new createBundleLeadHelper();
           reply =  createBundleLeadObj.createBundleLeadFunc(requestObj);
        }else{
            createBundleLeadResponse.cls_errorList error = new createBundleLeadResponse.cls_errorList();
            error.errorCode = '1';
            error.errorName = 'Request is blank';
            error.description = 'Request is blank';
            reply.errorList.add(error);
        }
       system.debug('into online boiler API reply '+reply);
       return reply;
    }
        

}