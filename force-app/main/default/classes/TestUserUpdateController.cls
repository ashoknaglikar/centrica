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
private class TestUserUpdateController {

    public static testMethod void testUserUpdateController() {
    	
        // Set up a new temporary user
        Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];                
        User user1 = new User(LastName = 'updateUser1', Alias = 'update1', 
                                Email = 'user@update.com', Username='user@update.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user@update.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert(user1);
    
        // Set up employee
        Employee__c emp1 = new Employee__c(First_Name__c = 'emp11', Last_Name__c = 'emp11', 
                                            Phone_No__c = '00000000', Employee_Number__c = '0000',Salesforce_User__c=user1.ID);
        Database.insert(emp1);
    
        //Set page URL for the test method	
        String pageURL = 'apex/userupdate?id='+user1.Id+'&previd='+emp1.Id;
	    PageReference pageRef = new PageReference(pageURL);
		Test.setCurrentPage(pageRef);
        UserUpdateController u1 = new UserUpdateController();
       
        u1.getuserSelected();
        String nextPage = u1.save().getUrl();
        System.assertEquals('/'+emp1.Id, nextPage);

        nextPage = u1.cancel().getUrl();
        System.assertEquals('/'+emp1.Id, nextPage);
       
    }
    
}