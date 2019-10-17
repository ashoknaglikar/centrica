@isTest
private class QFUVoucherFileBatch_Test {
    static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
    static BigMachines_Quote__c bm;
    static offer__c off;
    
    static void createTestData()
    {
        //Prepare account data
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        //Prepare contact data
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
                                     
        insert contact;
        
        account.Primary_Contact__c = contact.id;
        update account;
        
        //prepare supplier data
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                              Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        insert emp;
        
        //Prepare opportunity data
        opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                LeadSource='Engineer', Referral_Employee__c =emp.id,
                                                Comms_Email_Field__c='abc@test.com',
                                                Customer_Category_Record_Modified_By__c = UserInfo.getUserId());
        
        insert opp;
        
        bm = TestClassHelper.createBMQuote(opp);
        bm.stage__c='Quote Finalised - Not Accepted';
        bm.discountsTotalOnPricing__c=10;
        insert bm;
        
        off = new offer__C(Offer_Code__c='QWERT12345', Value__c=100,Description__c='test',Start_Date__c=system.today()-5,End_Date__c=system.today()+5,Offer_Type__c ='Monetary');
        insert off;
    }

    private static testMethod void testmethod1() {
        createTestData();
        string offcode= off.id;
        set<id> leadIds = new set<id>{opp.id};
        String fileName = 'test';
        date fromdate=system.today()-5;
        date todate= system.today()+5;
        boolean isSalesforce= true;
        boolean isContactEngine=false;
        boolean isText=false;
        boolean isEmail =false;
        string preparequery = '';
        string subquery='';
        
        Test.startTest();
        QFUVoucherFileBatch newObj = new QFUVoucherFileBatch(offcode,preparequery,subquery,fileName,fromdate,todate,isSalesforce,isContactEngine,isText,isEmail);
        Database.executeBatch(newObj);
        Test.stopTest();
    }
   

}