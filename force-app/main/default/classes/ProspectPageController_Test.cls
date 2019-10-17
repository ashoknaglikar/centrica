@isTest
private class ProspectPageController_Test {

    static testMethod void myUnitTest() {
                      
        
	        Inbound_Call__c inCall = new Inbound_Call__c();
	        inCall.Workflow_Step__c = 2.0;
	        inCall.Workflow_Type__c = 2.0;
	        inCall.Related_To__c = 'CHI LEAD';
	        inCall.Billing_Street__c = 'Street_test';
	        inCall.Billing_City__c = 'City';
	        inCall.Billing_State__c = 'State';
	        inCall.Billilng_Country__c = 'Country';
	        inCall.Billing_Zip__c='345'; 
	        
	        insert inCall;   
	        
	        System.debug('------incall----'+inCall);	            
	             
	        Lead testLead = new Lead();
	        testLead.Status = 'Open';
	        testLead.State = inCall.Billing_State__c;
	        testLead.City = inCall.Billing_City__c;
	        testLead.Street = inCall.Billing_Street__c;
	        testLead.Country = inCall.Billilng_Country__c;
	        testLead.PostalCode = inCall.Billing_Zip__c;
	        //testLead.Customer_Prefferd_Date__c = System.today()+3;
	        testLead.LastName = 'testLastName';
	        testLead.Company = 'myCompany';
	
	        insert testLead; 
	        
	        system.debug('------testLead----'+testLead);
	        
	        string callid = inCall.Id; 
	        system.debug('------inCall.Id----'+callid);
	        
	        //PageReference pageRef = new PageReference('/apex/ProspectPage?c='+callid);	        
	        PageReference pageRef = page.ProspectPage;
	        pageRef.getParameters().put('c',inCall.Id);
	        Test.setCurrentPage(pageRef);
			pageRef.setRedirect(true);    
			
			ProspectPageController controller1= new ProspectPageController();
			controller1.getacc();
			controller1.BtnWasteCall_Click();
			
			//LeadSelectClass LSC = new LeadSelectClass();
		
			controller1.Leadlist.add(testLead);
		    controller1.getLeadClassList();
		    controller1.BtnContinue_Click();		    		   
		    //controller1.setErrorMsg();	
			
		
	}
}