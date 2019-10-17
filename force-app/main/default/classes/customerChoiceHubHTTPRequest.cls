global class customerChoiceHubHTTPRequest {
    global static Integer customerRecordCreation(List<id> oppList ){
        customerChoiceHubSystem custChoiceHubSys=new customerChoiceHubSystem();
        List< Opportunity> opportunityLst=new List<Opportunity>();
        if(oppList.size()>0){
            opportunityLst=[select id,Account.Primary_contact__r.FirstName,CHI_Lead_Id__c,	Account.Primary_Contact__r.LastName,Install_Address_Street__c, Comms_Email_Field__c,Mobile_Phone__c,Home_Phone__c,
                            Install_Address_City__c,Install_Postcode__c,Marketing_Preferences__c , Customer_Marketing_Consent__c, MPU_time__c
                            from Opportunity 
                            where id in :oppList];
            if(opportunityLst.size()>0){
                custChoiceHubSys.id=system.label.System_Id;
                custChoiceHubSys.sourceSystemType=system.label.Source_System_Type;
                custChoiceHubSys.sourceSystemId=system.label.Source_System_Id;
                datetime systemTime = system.now();
                
                custChoiceHubSys.timestamp=systemTime.year()+'-'+systemTime.month()+'-'+systemTime.day()+'T'+systemTime.hour()+':'+systemTime.minute()+':'+systemTime.Second();
                List<customerChoiceHub> cchList = new List <customerChoiceHub>();
                for(opportunity opp :opportunityLst){
                    datetime changeTime = opp.MPU_time__c!=null? opp.MPU_time__c : system.now();
                    customerChoiceHub.contactObj cch=new customerChoiceHub.contactObj();   
                    cch.id=opp.CHI_Lead_Id__c;
                    cch.idOrigin = system.label.Id_Origin;
                    cch.timestamp=changeTime.year()+'-'+changeTime.month()+'-'+changeTime.day()+'T'+changeTime.hour()+':'+changeTime.minute()+':'+changeTime.Second();
                    cch.firstName = opp.Account.Primary_contact__r.FirstName;
                    cch.lastName = opp.Account.Primary_Contact__r.LastName;
                    //cch.fullName = cch.firstName +' ' +cch.lastName;
                    if(opp.Comms_Email_Field__c!=null)
                    cch.email = opp.Comms_Email_Field__c;
                    if(opp.Mobile_Phone__c!=null)
                    cch.mobileNumber = opp.Mobile_Phone__c.startswith('0')?opp.Mobile_Phone__c.replacefirst('0', '+44'):'';
                    if(opp.Home_Phone__c!=null)
                    cch.phoneNumber = opp.Home_Phone__c.startswith('0')?opp.Home_Phone__c.replacefirst('0', '+44'):'';
                    cch.country = 'GB';
                    cch.city = opp.Install_Address_City__c;
                    cch.postalCode = opp.Install_Postcode__c;
                   
                    cch.houseNumber=opp.Install_Address_Street__c.replaceAll('[^0-9]', '');//write logic for extracting house no from street 
                    cch.street = opp.Install_Address_Street__c;
                    if(cch.houseNumber!=null)
                    cch.street = opp.Install_Address_Street__c.replacefirst(cch.houseNumber, '');
                    customerChoiceHub obj = new customerChoiceHub();
                    obj.contact = cch;
                    custChoiceHubSys.contacts = obj;
                }
                //custChoiceHubSys.contact.addall(cchList);
            }
        }
        
        
        cchNewCustomerList newcustomerList = new cchNewCustomerList();
        newcustomerList.customers.add(custChoiceHubSys);
        
        String request=JSON.serialize(newcustomerList);
        /*
        String request= '{"Customers":[    {   "id": "DS_51",   "sourceSystemType": "EXT",   "sourceSystemId": "ANY",   "timestamp": "2018-03-16T18:11:58",   "contacts": {      "contact": {'+
         '"id": "CH20",         "idOrigin": "ZCHI",         "timestamp": "2018-03-16T18:11:58",         "firstName": "Ali",         "lastName" : "Ahmed",         "fullName": "Ali Ahmed",         "country": "GB",'+
         '"postalCode": "LS9",         "city": "London",         "street": "Regent Street",         "houseNumber": "12",         "email" : "a.a@nomail.uk",         "mobileNumber" : "+44789900999",         "phoneNumber" : "+44282131210"      }   }   }   ]}';
        */
        system.debug('request=='+request);
        
        HTTPRequest req=new HTTPRequest();
        req.setEndpoint(system.label.CCH_Customer_Create_Endpoint);
        //req.setEndpoint('https://s0076-iflmap.hcisbt.eu1.hana.ondemand.com/http/MarketingPermissionsCertTest');//+':443'	);
        req.setMethod('POST');
        req.setBody(request);
        //req.setClientCertificateName(system.label.CCHCertificateName);
        
        /*
        String username=system.label.CCH_Username;
        String password=system.label.CCH_Password;
        system.debug('username: '+username +' password: '+password);
        Blob headerValue=blob.valueOf(username+':'+password);
        
        string authorizationHeader ='Basic '+encodingUtil.base64Encode(headerValue);
        system.debug('authorizationheader: '+authorizationHeader);
        
        req.setHeader('authorization', authorizationHeader);
        */
        req.setHeader('Content-Type', 'application/json');
        
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('Response -->'+res);
        Integer statusCode=res.getStatusCode();
        system.debug('Respose body 1-->'+res.getBody());
        if(statusCode == 200 && res.getBody()!=null && res.getBody().contains('<statusCode>204</statusCode>'))
        return 200;
        else
        return 400;
        
    }
    
    global static Integer customerMarketingPermissions(List<opportunity> oppList){
        CCHChoiceWithMarketingPremission.innerClass customerMarketingPreferences=new CCHChoiceWithMarketingPremission.innerClass();

        List<customerChoiceHubMarketingPreference> chpList= new List<customerChoiceHubMarketingPreference>();

        customerMarketingPreferences.id=system.label.System_Id;
        customerMarketingPreferences.sourceSystemType=system.label.Source_System_Type;
        customerMarketingPreferences.sourceSystemId=system.label.Source_System_Id;
        datetime systemTime = system.now();
        customerMarketingPreferences.timestamp=systemTime.year()+'-'+systemTime.month()+'-'+systemTime.day()+'T'+systemTime.hour()+':'+systemTime.minute()+':'+systemTime.Second();
        customerChoiceHubMarketing cchList = new customerChoiceHubMarketing();
        
        for(opportunity opp:oppList){
            customerChoiceHubMarketing.contactObj cch=new customerChoiceHubMarketing.contactObj();
            
            cch.id = opp.CHI_Lead_Id__c;
            cch.idOrigin = system.label.Id_Origin ;
            
            datetime changeTime = opp.MPU_time__c!=null? opp.MPU_time__c : system.now();
            cch.timestamp = changeTime.year()+'-'+changeTime.month()+'-'+changeTime.day()+'T'+changeTime.hour()+':'+changeTime.minute()+':'+changeTime.Second();
            
            
           /*
            if(opp.Customer_Marketing_Consent__c == 'Yes' && opp.Marketing_Preferences__c!=null)
            {
                for(String str:opp.Marketing_Preferences__c.split(';')){
                    customerChoiceHubMarketingPreference CHP=new customerChoiceHubMarketingPreference();
                    CHP.outboundCommunicationMedium = str;
                    CHP.optIn='Y';
                    chpList.add(CHP);
                    if(str=='Mobile' || str=='Text Message')
                        CHP.id=opp.Mobile_Phone__c;  
                    else if(str=='Phone')
                        CHP.id=opp.Home_Phone__c;
                    CHP.timestamp= system.now();
                }
            }else if(opp.Customer_Marketing_Consent__c == 'No')
            {

            }
            */

            string optin = 'N';
            

            Schema.DescribeFieldResult fieldResult = Opportunity.Marketing_Preferences__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry f : ple)
            {
                string value  = f.getValue();
                
                    customerChoiceHubMarketingPreference CHP=new customerChoiceHubMarketingPreference();
                    CHP.outboundCommunicationMedium = value == 'MOBILE' ? 'PHONE':value;
                    optin = 'N';
                    if(opp.Customer_Marketing_Consent__c == 'Yes' && opp.Marketing_Preferences__c!=null && opp.Marketing_Preferences__c.contains(value))
                    {
                        optin = 'Y';
                    }else if(opp.Customer_Marketing_Consent__c == 'No')
                    {
                        optin = 'N';
                    }

                    CHP.optIn=optin;
                    CHP.timestamp= cch.timestamp;
                    system.debug(value+' '+optin);
                    if((value=='MOBILE' || value=='SMS') && opp.Mobile_Phone__c!= null && opp.Mobile_Phone__c.startswith('0'))
                    {
                        string mobile = opp.Mobile_Phone__c.replacefirst('0', '+44');
                        CHP.id=mobile;  
                        CHP.idOrigin = 'MOBILE';
                        chpList.add(CHP);
                    }
                    else if(value=='PHONE' && opp.Home_Phone__c != null &&  opp.Home_Phone__c.startswith('0'))
                    {
                        string homePhone = opp.Home_Phone__c.replacefirst('0', '+44');
                        CHP.id=homePhone; 
                        CHP.idOrigin = 'PHONE';
                        chpList.add(CHP);
                    }else if(value == 'EMAIL' && opp.Comms_Email_Field__c !=null)
                    {
                        CHP.id=opp.Comms_Email_Field__c; 
                        CHP.idOrigin = 'EMAIL';
                        chpList.add(CHP);

                    }
                    else if(value == 'PAPER')
                    {
                        CHP.id=opp.CHI_Lead_Id__c; 
                        CHP.idOrigin = 'ZPOST_CHI';
                        chpList.add(CHP);
                    }
                    
                    
                
            }
            cch.marketingPermissions.contactMarketingPermissions.addall(chpList);
            cchList.contact = cch;

        }
        
        customerMarketingPreferences.contacts = cchList;

        CCHChoiceWithMarketingPremission obj = new CCHChoiceWithMarketingPremission();
        obj.Customers.add(customerMarketingPreferences); 


        String beforeCorrection=JSON.serialize(obj);
        
        //customerChoiceHubHTTPRequest.createCustomerOrUpdateMarketingPreferences(new list<string>{'00625000009OZTC'});
        system.debug(beforeCorrection);
        string middlePart = ',"idOrigin":"ZCHI","id":"'+oppList[0].CHI_Lead_Id__c+'"';
        string middlePart_1 = '"id":"'+oppList[0].CHI_Lead_Id__c+'","idOrigin":"ZCHI",';
        string remove_1 = beforeCorrection.replace(middlePart, '');
        system.debug(remove_1);
        system.debug(beforeCorrection);
        system.debug(remove_1.indexOf('"contact":{'));
        string firstPart = remove_1.substring(0,remove_1.indexOf('"contact":{')+'"contact":{'.length());
        system.debug(firstPart);
        string secondPart = remove_1.substring(remove_1.indexOf('"contact":{')+'"contact":{'.length(),remove_1.length());
        system.debug(secondPart);
        
        string request = firstPart+middlePart_1+secondPart;
        
        //request = '{"Customers":[{"id":"WED03","sourceSystemType":"EXT","sourceSystemId":"ANY","timestamp":"2018-04-05T18:13:58","contacts":{"contact":{"id":"SMWED02","idOrigin":"ZUKHOME","timestamp":"2018-04-13T18:13:58","marketingPermissions":{"contactMarketingPermissions":[{"id":"smwed02@nomail.uk","idOrigin":"EMAIL","optIn":"Y","outboundCommunicationMedium":"EMAIL","timestamp":"2018-04-13T18:15:59"}]}}}}]}';
        system.debug('customerMarketingPreferences=='+request);


        HTTPRequest req=new HTTPRequest();
        req.setEndpoint(system.label.CCH_Update_Marketing_Pref);
        req.setMethod('PUT');
        req.setBody(request);
        //req.setClientCertificateName(system.label.CCHCertificateName);
        
        /*
        String username=system.label.CCH_Username;
        String password=system.label.CCH_Password;
        system.debug('username: '+username +' password: '+password);
        Blob headerValue=blob.valueOf(username+':'+password);
        
        string authorizationHeader ='Basic '+encodingUtil.base64Encode(headerValue);
        system.debug('authorizationheader: '+authorizationHeader);
        
        req.setHeader('authorization', authorizationHeader);
        */
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Integer statusCode=res.getStatusCode();
        
        system.debug('Respose body 2-->'+res.getBody());
        if(statusCode == 200 && res.getBody()!=null && res.getBody().contains('<statusCode>204</statusCode>'))
        return 200;
        else
        return 400;
    } 
    
    global static void createCustomerOrUpdateMarketingPreferences(List<Id> oppList){
        List< Opportunity> opportunityLst=new List<Opportunity>();
        if(oppList.size() > 0){
            Integer statusCode=customerChoiceHubHTTPRequest.customerRecordCreation(oppList);
            if(statusCode==200){
                opportunityLst=[select id,CHI_Lead_Id__c,	Comms_Email_Field__c,Mobile_Phone__c,Home_Phone__c
                            ,Install_Postcode__c,Marketing_Preferences__c , Customer_Marketing_Consent__c,MPU_time__c
                            ,SAP_Cloud_Integration_Status__c from Opportunity where id in: oppList]; 
                
                statusCode=customerChoiceHubHTTPRequest.customerMarketingPermissions(opportunityLst);
                if(statusCode==200 ){
                    opportunityLst[0].SAP_Cloud_Integration_Status__c='success';
                }
                else{
                    opportunityLst[0].SAP_Cloud_Integration_Status__c='error';
                }
            }
            else{
                opportunityLst[0].SAP_Cloud_Integration_Status__c='error';  
                
            }
        }
        lock.triggerUpdatingOpps = true;
        cls_IsRun.generalTriggerSwitch =true;
        if(opportunityLst.size()>0)
        update opportunityLst;
    }

    @future(callout=true)
    Global static void callCreateCustomerOrUpdateMarketingPreferences(List<id> oppList){
        //List< Opportunity> opportunityList=new List<Opportunity>();
        //opportunityList=[select id from opportunity where id in :oppList];
        customerChoiceHubHTTPRequest.createCustomerOrUpdateMarketingPreferences(oppList);
        
    } 

    global class errorClass{
        global string errorCode;
        global list<String> errorMessage{get;set;}
        global errorClass(){
            this.errorMessage= new list<String>();
        }
    }
}