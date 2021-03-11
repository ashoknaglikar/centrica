@isTest
private class RemoteQuoteCloneTest{
     
 private static testMethod void testmethod1() {
    Opportunity TestOpp1 = [Select id from Opportunity][0];
    id appointment = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
    Employee__c HSA = [Select id from Employee__c ][0];
    Contact TestContact1 = [Select id from Contact][0];
        
    Appointment__c appt = TestClassHelper.createAppointment(TestOpp1,HSA.Id,userinfo.getuserId(),appointment, TestContact1.Id);
    insert appt;
    
    PageReference pageRef = Page.RemoteQuoteClonePage;
    pageRef.getParameters().put('id', String.valueOf(TestOpp1.Id));
    pageRef.getParameters().put('Heat','No');
    pageRef.getParameters().put('HW','No' );
    pageRef.getParameters().put('OH','No' );
    pageRef.getParameters().put('vul','Yes' );
    
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(TestOpp1);
    
    RemoteQuoteCloneController controller1 = new RemoteQuoteCloneController(sc);
    controller1.reason = 'Age';
    controller1.subreason = 'Well Being';
    controller1.selectedProduct='Small Commercial';
    controller1.getcustomerCateogryType();
    controller1.bookAppointment();   
    controller1.indicator();  
       
    controller1.selectedProduct=null;    
    controller1.bookAppointment();
    
   

    }
    
    private static testMethod void testmethod2() {
        
    Opportunity TestOpp1 = [Select id from Opportunity][0];
    PageReference pageRef = Page.RemoteQuoteClonePage;
    pageRef.getParameters().put('id', String.valueOf(TestOpp1.Id));   
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(TestOpp1);
    RemoteQuoteCloneController controller1 = new RemoteQuoteCloneController(sc);
   
    controller1.selectedProduct='Small Commercial';
    controller1.getcustomerCateogryType();   
    controller1.indicator(); 
    
    }
    
    @testsetup
    private static void setupData()
    {
        categoryMap__c tempMap1 = new categoryMap__c(Name = 'Rec1', Reason__c = 'Age' , Subreason__c = 'Well Being');
        categoryMap__c tempMap2 = new categoryMap__c(Name = 'Rec2', Reason__c = 'Age' , Subreason__c = 'Well Being2');
        insert new list<categoryMap__c> {tempMap1, tempMap2};
        
        Account TestAccount1 = new Account(Name = 'P1Controller Account 1', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');
        insert TestAccount1;
                        
        Contact TestContact1 = new Contact(FirstName = 'P1Controller', LastName = 'Contact1', AccountId = TestAccount1.Id);
        insert TestContact1;                    
                  
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
        
        Opportunity TestOpp1 = new Opportunity(LeadSource = 'MA',ta_notes__c='test', AccountId = TestAccount1.Id, Name = 'RemoteQuote Opp 1', CloseDate = system.today()+10, StageName='Active', Product_Interest__c='Guided Sale', CampaignId = camp.Id);
        insert TestOpp1; 
        
        Employee__c HSA = TestClassHelper.createEmployee();
        HSA.Primary_role__c = 'HSA';
        insert HSA;
        
        
        
       insert(testclassHelper.createCustomerLogicRecords());
    }

}