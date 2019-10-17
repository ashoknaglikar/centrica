@isTest
private class SendASPAcknowledgmentsTest {

    static testMethod void myUnitTest() {
    	cls_IsRun.generalTriggerSwitch= true;
        lock.jobTriggerSwitch = true;
        
        Account Acc = TestClassHelper.createAccout();
        insert Acc;
                        
        Opportunity opp = TestClassHelper.createCHILead(Acc);
        insert opp;
          
        BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
        insert bm ;
       
        
        District__c ds = TestClassHelper.createDistrict(); 
        insert ds;
        
        Job__c jb = TestClassHelper.createJob('Pending','Mismatch',opp.ID, ds.Id);
        jb.Quote__c=bm.Id;
        insert jb;
        
        ASP__c asp = new ASP__c();
        asp.Function__c = 'Installtion';
        asp.Definition__c = 'Installtion';
        asp.Picklist__c = 'Installtion';
        asp.Description__c='Installtion';
        insert asp;
        
        
        
        ASP_Exception__c excpe1  = new ASP_Exception__c(Assigned_To__c= userinfo.getUserId(), Status__c = 'In Progress', Allowed_Amount__c = 100,  
	            												Authorised_Amount__c =200, Cateogry__c = 'Category', ASP__c = asp.Id, ASP_Applied_Time__c =  'timeline', 
	            												Exception_User__c = userinfo.getUserid(), Role_Name__c = 'Role Name', Whats_Used__c = 'Discount', Due_Date__c = system.today().addDays(7));
	            			
        ASP_Exception__c excpe2  = new ASP_Exception__c(Assigned_To__c= userinfo.getUserId(), Status__c = 'In Progress', Allowed_Amount__c = 100,  
	            												Authorised_Amount__c =200, Cateogry__c = 'Category', ASP__c = asp.Id, ASP_Applied_Time__c =  'timeline', 
	            												Exception_User__c = userinfo.getUserid(), Role_Name__c = 'Role Name', Whats_Used__c = 'Discount', Due_Date__c = system.today().addDays(-1));
	            												
	    ASP_Exception__c excpe3  = new ASP_Exception__c(Assigned_To__c= userinfo.getUserId(), Status__c = 'Escalated', Allowed_Amount__c = 100,  
	            												Authorised_Amount__c =200, Cateogry__c = 'Category', ASP__c = asp.Id, ASP_Applied_Time__c =  'timeline', 
	            												Exception_User__c = userinfo.getUserid(), Role_Name__c = 'Role Name', Whats_Used__c = 'Discount', Due_Date__c = system.today().addDays(-1));
	            			                												
	            			        
        
        insert new list<ASP_Exception__c>{excpe1, excpe2, excpe3};
        
        SendASPAcknowledgments.sendAckListLink();
    	
    	
        // TO DO: implement unit test
    }
}