@isTest
private class RemoteQuoteCloneTest{
     
 private static testMethod void testmethod1() {
    Account TestAccount1 = new Account(Name = 'P1Controller Account 1', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');
    insert TestAccount1;
                    
    Contact TestContact1 = new Contact(FirstName = 'P1Controller', LastName = 'Contact1', AccountId = TestAccount1.Id);
    insert TestContact1;                    
              
    Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
    Database.insert(camp);
    
    Opportunity TestOpp1 = new Opportunity(LeadSource = 'MA',ta_notes__c='test', AccountId = TestAccount1.Id, Name = 'RemoteQuote Opp 1', CloseDate = system.today()+10, StageName='Active', Product_Interest__c='Guided Sale', CampaignId = camp.Id);
    insert TestOpp1; 
    
    List<category_Indicator__c> ciList = new List<category_Indicator__c >();
    category_Indicator__c ci1= new category_Indicator__c(Reason__c='Age',Sub_Reason__c='75 and over',Heating__c='No',Hot_Water__c='No',Other_Heat__c='No',Vunerable__c='Yes',Category__c=1,customer_category_Logic__c='0'); 
    category_Indicator__c ci2= new category_Indicator__c(Heating__c='No',Hot_Water__c='No',Other_Heat__c='No',Vunerable__c='Yes',Category__c=1,customer_category_Logic__c='0'); 
    category_Indicator__c ci3= new category_Indicator__c(Heating__c='No',Hot_Water__c='No',Other_Heat__c='Yes',Vunerable__c='Yes',Category__c=3,customer_category_Logic__c='0');   
      ciList.add(ci1);
      ciList.add(ci2);
      ciList.add(ci3);
      insert ciList;
    
    PageReference pageRef = Page.RemoteQuoteClonePage;
    pageRef.getParameters().put('id', String.valueOf(TestOpp1.Id));
    pageRef.getParameters().put('Heat','No');
    pageRef.getParameters().put('HW','No' );
    pageRef.getParameters().put('OH','No' );
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(TestOpp1);
    RemoteQuoteCloneController controller1 = new RemoteQuoteCloneController(sc);
   
    controller1.selectedProduct='Small Commercial';
    controller1.getcustomerCateogryType();
    controller1.bookAppointment();   
    controller1.indicator();  
       
    controller1.selectedProduct=null;    
    controller1.bookAppointment();
    
   

    }
    
    private static testMethod void testmethod2() {
    
    Account TestAccount1 = new Account(Name = 'P1Controller Account 1', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');
    insert TestAccount1;
                    
    Contact TestContact1 = new Contact(FirstName = 'P1Controller', LastName = 'Contact1', AccountId = TestAccount1.Id);
    insert TestContact1;                    
              
    Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
    Database.insert(camp);
    
    Opportunity TestOpp1 = new Opportunity(LeadSource = 'MA',ta_notes__c='test', AccountId = TestAccount1.Id, Name = 'RemoteQuote Opp 1', CloseDate = system.today()+10, StageName='Active', Product_Interest__c='Guided Sale', CampaignId = camp.Id);
    insert TestOpp1; 
    
    PageReference pageRef = Page.RemoteQuoteClonePage;
    pageRef.getParameters().put('id', String.valueOf(TestOpp1.Id));   
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController sc = new ApexPages.StandardController(TestOpp1);
    RemoteQuoteCloneController controller1 = new RemoteQuoteCloneController(sc);
   
    controller1.selectedProduct='Small Commercial';
    controller1.getcustomerCateogryType();   
    controller1.indicator(); 
    
    }

}