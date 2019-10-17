/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class aspAcknowledgmentsContTest {

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
        
        pagereference pageref = new pagereference('/apex/aspExceptionPage');
        test.setCurrentPage(pageref);
        aspAcknowledgmentsCont cont_asp = new aspAcknowledgmentsCont();
        cont_asp.changeview();
        cont_asp.Beginning();
        cont_asp.Next();
        cont_asp.Previous();
        cont_asp.End();
        cont_asp.getDisablePrevious();
        cont_asp.getDisableNext();
        cont_asp.getTotal_size();
        cont_asp.getTotalPages();
        cont_asp.getPageNumber();
        
        // TO DO: implement unit test
    }
}