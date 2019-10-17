@RestResource(urlMapping='/updateMarketingPreference/*')
Global class customerChoiceHubREST {
    @HttpPost
    global static void updateMarketingPreference(){
        //system.debug('marketingPreference -->'+Customers);
        //try{
            RestRequest req = RestContext.request;
            set<string> oppId=new set<string>();
            string body  = req.requestBody.tostring(); 
            system.debug(body);
            list<Opportunity> opplist  = new List<Opportunity>();
            list<Opportunity> lstOpportunity  = new List<Opportunity>();
            map<string,Opportunity> mapChiLead=new map<string,Opportunity>();
            CCHChoiceWithMarketingPremission result=   (CCHChoiceWithMarketingPremission) JSON.deserialize(body, CCHChoiceWithMarketingPremission.class);
            system.debug(result);
            if(result!=null){
                
                for(CCHChoiceWithMarketingPremission.innerClass classObj : result.Customers){
                    oppId.add(classObj.contacts.contact.id);
                    
                }
                lstOpportunity = [select id,Bill_FirstName__c,CHI_Lead_Id__c,Bill_LastName__c,Comms_Email_Field__c,Mobile_Phone__c,Home_Phone__c,
                                  Bill_Country__c,Bill_City__c,Install_Postcode__c,Bill_Street__c,Marketing_Preferences__c 
                                  from Opportunity 
                                  where CHI_Lead_Id__c In :oppId];
                If(lstOpportunity.size()>0){
                    for(Opportunity opp:lstOpportunity){
                        mapChiLead.put(opp.CHI_Lead_Id__c, opp) ;
                    }
                }
                for(CCHChoiceWithMarketingPremission.innerClass classObj : result.Customers)
                {
                    system.debug(classObj);
                    system.debug('I am here -->'+classObj.id);
                    Opportunity opp = new Opportunity();
                    
                    
                    string chiLeadId = '';
                    string marketingPrefernce = '';
                    if(classObj.contacts!=null && classObj.contacts.contact!=null && classObj.contacts.contact.marketingPermissions!=null)
                    {
                        customerChoiceHubMarketing.marketingList marketObj = classObj.contacts.contact.marketingPermissions;
                        
                        chiLeadId = classObj.contacts.contact.id;
                        opp=mapChiLead.get(chiLeadId);
                        if(marketObj.contactMarketingPermissions!=null)
                        {
                            for(customerChoiceHubMarketingPreference cm : marketObj.contactMarketingPermissions)
                            {
                                if(cm.optIn == 'Y')
                                {
                                    marketingPrefernce +=cm.idOrigin +';';
                                }
                            }
                        }
                    }
                    opp.Marketing_Preferences__c=marketingPrefernce;
                    opp.Customer_Marketing_Consent__c = 'No';
                    
                    if(marketingPrefernce!='')     
                    {
                        
                        opp.Customer_Marketing_Consent__c = 'Yes';
                    }
                    
                    opplist.add(opp);
                }
                Lock.cchContactOppRecursiveStopper = true;
                if(opplist.size()>0)
                    update opplist;
            }
        //}catch (Exception e)
        //{
            //throw e;
        //}
    }
}