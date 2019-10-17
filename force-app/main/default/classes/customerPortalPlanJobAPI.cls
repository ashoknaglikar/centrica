@RestResource(urlMapping='/returnPlanningOptions/*')
global class customerPortalPlanJobAPI {
    
	@HttpPost    
    global static getHSAPlanInstallDateResponseJSON.installdateResponse planJob(string leadId,string quoteId, string jobId,date customerPreferredDate,String navigate)
    {
        system.debug('@@@@planning API in-----> ');
             
        String oppId = CustomerPortalHelper.getOpportunityId(leadId);
        getHSAPlanInstallDateResponseJSON.installdateResponse objResponse = customerPortalHSAPlanHelper.InstallDateList(oppId,quoteID,jobID,customerPreferredDate,navigate);
        
        system.debug('@@@@planning API Out------>');
        return objResponse;
    }

}