@isTest
private class CopyQuoteExtension_Test {
   
  static Account acc;
  static contact con;
  static opportunity opp;
  static BigMachines_Quote__c quote;
  static Attachment attach;
  static ASP__c asp;
  static Product2[] products;
  static Quote_Product__c lineItem1;
  
  static void createTestData(){
        acc = TestclassHelper.createAccout();
        insert acc;
        
        con = TestclassHelper.createContact(acc);
        insert con;
        
        opp = TestclassHelper.createCHILead(acc);
        insert opp;
        
        quote = TestClassHelper.createBMQuote(opp);
        insert quote;
        
        attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=quote.id;
        insert attach;
        
        asp = new ASP__c(Quote__c=quote.Id,ASP_Date__c=date.today(),function__c='Sales',definition__c='Building Work',Picklist__c='Downtime',Status__c='Entered');
        insert asp; 
        
        Product2 product1 = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123');
        Product2 product2 = new Product2(ProductCode='ABC456', Name='ABC456', BigMachines_Part_Number__c='ABC456');
        Product2 product3 = new Product2(ProductCode='UDPQP1', Name='UDPQP1', BigMachines_Part_Number__c='UDPQP1',User_Defined_Product__c=true );  
        products = new Product2[]{product1,product2,product3};     
        insert products;
        
        lineItem1 = new Quote_Product__c(Product__c=products[0].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp.Id, Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote.Id, Name='ABC123');               
        insert lineItem1;
   }

	static testMethod void testmethod1() {
        createTestData();
        opp.closeDate__c = system.today();
		update opp;
        
        BGS_Payment__c bgs= new BGS_Payment__c(BGS_Payment_Reference_Num__c='87896541236',Amount__c=200);
        PageReference pageRef = Page.CopyQuotePage;
        pageRef.getParameters().put('id', String.valueOf(quote.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        CopyQuoteExtension controller1 = new CopyQuoteExtension(sc);
        
        controller1.selectedPaymentType ='Payment on Completion';
        controller1.leadPayment=bgs;
        
        Test.setMock(HttpCalloutMock.class, new HttpMockup());
        Test.startTest();
        controller1.cloneQuote();
        controller1.cancel();
        controller1.dummy();
        Test.stopTest();
        
        controller1.selectedPaymentType =null;
        controller1.cloneQuote();
        
        controller1.selectedDepositMethod='credit Card';
        controller1.cloneQuote(); 
        
        BGS_Payment__c bgs1= new BGS_Payment__c(BGS_Payment_Reference_Num__c='8789654126',Amount__c=200);
        controller1.leadPayment=bgs1;
        controller1.cloneQuote();
        
	}
	
	/*	static testMethod void testmethod2() {
		createTestData();
		opp.closeDate__c = system.today();
		update opp;
        BGS_Payment__c bgs= new BGS_Payment__c(BGS_Payment_Reference_Num__c='87896541236',Amount__c=200);
        PageReference pageRef = Page.CopyQuotePage;
        pageRef.getParameters().put('id', String.valueOf(quote.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        CopyQuoteExtension controller1 = new CopyQuoteExtension(sc);
        
        controller1.selectedPaymentType ='Payment on Completion';
        controller1.leadPayment=bgs;
        controller1.cloneQuote();
        
		}*/

}