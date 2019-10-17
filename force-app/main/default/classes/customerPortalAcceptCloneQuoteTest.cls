@isTest
public class customerPortalAcceptCloneQuoteTest {
    public static BigMachines_Quote__c quote;
    public static list<IV_Vectors__c > vectorList;
    
    private static testmethod void  secnario1()
    {
    
      customerAcceptCloneQuotePortalResponse objResponse = new customerAcceptCloneQuotePortalResponse();
     
      Account acc = TestClassHelper.createAccout();
      insert acc;
    
      Contact con = TestClassHelper.createContact(acc);
      insert con;
    
      Opportunity opp  = TestClassHelper.createCHILead(acc);
      insert opp;
        
      quote = TestClassHelper.createBMQuote(opp);
      quote.appliedAllowancesTotal__c =0.0;
      quote.totalNetPrice_quote__c =2000;
      quote.BigMachines_Transaction_Id__c = 'test123';      
      insert quote;
     
        Attachment attach=new Attachment();    
        attach.Name='Installation notes';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=quote.id;
        insert attach;
        
        ASP__c asp = new ASP__c(Quote__c=quote.Id,ASP_Date__c=date.today(),function__c='Sales',definition__c='Building Work',Picklist__c='Downtime',Status__c='Entered');
        insert asp; 
        Product2 product1 = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123');
        Product2 product2 = new Product2(ProductCode='ABC456', Name='ABC456', BigMachines_Part_Number__c='ABC456');
        Product2 product3 = new Product2(ProductCode='UDPQP1', Name='UDPQP1', BigMachines_Part_Number__c='UDPQP1',User_Defined_Product__c=true );  
        Product2[] products = new Product2[]{product1,product2,product3};     
        insert products;
        Quote_Product__c lineItem1 = new Quote_Product__c(Product__c=products[0].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp.Id, Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote.Id, Name='ABC123');               
        insert lineItem1;
        
        District__c district = TestClassHelper.createDistrict();
        insert district;
      
        vectorList = new list<IV_Vectors__c>();
        vectorList.add(new IV_Vectors__c(Name = 'Finance_Accepted_Statuses', Key__c = ',Accepted,Awaiting eSignature,') );
        vectorList.add(new IV_Vectors__c(Name = 'Finance_Reffered_Statuses', Key__c = ',Referred,Introducer Pending,Conditionally Accepted,') );
        vectorList.add(new IV_Vectors__c(Name = 'Finance_Declined_Statuses', Key__c = ',Declined,') );
        vectorList.add(new IV_Vectors__c(Name = 'Finance_Parked_Status', Key__c = ',Parked,') );
        vectorList.add(new IV_Vectors__c(Name = 'Finance_Other_Statuses', Key__c = ',Newly Created,') );
        insert vectorList;
        
        Finance_Product__c fp= new Finance_Product__c(Name='Barclays Finance Ex',Interest_Rate__c=14.9,Selling_Type__c='Off Trade',
                                                  Active__c=TRUE,Product_Code__c='FTSTDO',Asset_Type__c='CH1',Asset_Type_Description__c='Boiler');
        insert fp;
        
        Finance_Application__c fa=new Finance_Application__c();
        fa.Finance_Product__c = fp.id;
        fa.CHI_Lead__c = opp.id; 
        fa.application_status__c = 'Parked';
        insert fa;
      
    Job__c job = TestClassHelper.createJob('Pending', 'Install Date required', opp.id, district.id);
    job.Customer_Preferred_Date__c=system.today();
    job.Customer_PreElectric__c=false;
    job.Asbestos_Removal_Hours__c=0;
    insert job;
    
    string paymentType= 'Finance';
    decimal voucherAmount = 100;
    string voucherName ='test';
    string voucherCode = 'QWERT12345';
    
    test.startTest();
    Test.setMock(HttpCalloutMock.class, new HttpMockup());
    try{    
    customerPortalAcceptCloneQuote.acceptCloneQuotemethod(String.valueof(job.id),string.valueof(opp.id),string.valueof(quote.id),paymentType,voucherAmount,voucherName,voucherCode);
    }
    catch(Exception e)
    {}
    test.stopTest();
    }
    
   
}