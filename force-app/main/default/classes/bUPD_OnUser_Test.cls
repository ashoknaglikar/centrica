/* This is the test class for the trigger bUPD_OnUser which updates the employees inactive when the corresponding salesforce is updated inactive*/

@isTest
private class bUPD_OnUser_Test{
    static User UInstal1;
    static User UInstal2;
    static Employee__c emp1;
    
    static testmethod void test_bUPD_OnUser() 
    { 
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs(thisUser) 
        {   
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        Profile PInsta2 = [select id from Profile where name = 'Standard User'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt1', email='standarduser1@testorg.com',
                                        emailencodingkey='UTF-8', lastname='Tsting1', languagelocalekey='en_US',
                                        localesidkey='en_US',timezonesidkey='America/Los_Angeles', 
                                        username='standardser1@testorg.com',Migration_ID__c ='A763BHe32341',IsActive=true); 
        insert UInstal1;
        system.assertEquals('standardser1@testorg.com', UInstal1.username); 
        UInstal2 = new User(profileid=PInsta2.Id,alias = 'standt2', email='standarduser2@testorg.com',
                                        emailencodingkey='UTF-8', lastname='Tsting1', languagelocalekey='en_US',
                                        localesidkey='en_US',timezonesidkey='America/Los_Angeles', 
                                        username='standardser2@testorg.com',Migration_ID__c ='A763BHe32342',IsActive=true); 
        insert UInstal2;
        system.assertEquals('standardser2@testorg.com', UInstal2.username); 
        }
        System.RunAs(UInstal2)
        {  
        Test.StartTest();
        updateuser(); 
        Test.StopTest();    
        }   
    }
    
    static testmethod void test_bUPD_OnUser1() 
    { 
        User thisUser = TestClassHelper.createUser();
        insert thisUser;
        Profile PInsta = [select id from Profile where name = 'Standard User'];
        
        thisUser.ProfileId = PInsta.id;
        Update thisUser;
    }
    
    @future
    private static void updateuser()
    {
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        
        insert supplier;
                                        
        emp1 = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                                 Employee_Number__c = '0000000',Resource_Id__c='7fejs1',Resource_Type__c='Installer',
                                                 Inactive__c=false,Salesforce_User__c=UInstal1.ID);
                                                 
        insert emp1;
        
        system.assertEquals(UInstal1.ID, emp1.Salesforce_User__c);                                        
        system.assertEquals('Installer', emp1.Resource_Type__c);    
        UInstal1.IsActive=false;
        update UInstal1;
    }
}