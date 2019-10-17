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
private class BatchGWAC_PopulateClass_test {

    static testMethod void PrepareData() {
        	//inserting Account
            Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                        BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
         
            insert account;
            //inserting Contact
            Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                 MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                 FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
            insert contact;
    
            //inserting Supplier
                        Supplier__c supplier = new supplier__c(Name='Testrt4etr supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource',Market_Allocation__c=1);
            insert supplier;
           	 if(supplier.Market_Allocation__c>=100)
         	{
         		supplier.Market_Allocation__c=2;
         		update supplier;
         		system.debug('supplier.Market_Allocation__c2----'+supplier.Market_Allocation__c);
         	}
			//if(supplier)          
            //inserting ListOfProOrd;
            Id recTypeobjId= ([Select r.Id From RecordType r where  r.Name= 'Material Record Type' limit 1].Id);
            Product_Order__c ProOrdObj= new Product_Order__c(RecordTypeId=recTypeobjId,Currency_Type__c='GBP');
            insert ProOrdObj;
            Product_Order__c ProOrdObj1= [select id from Product_Order__c where id =:ProOrdObj.id];
            system.debug('----- Product order Id-------->>>>'+ProOrdObj.id);
            List<Product_Order__c> ListOfProOrd=new List<Product_Order__c>();
            ListOfProOrd.add(ProOrdObj1);
            List<Id> ListOfProOrdId=new List<Id>();
            ListOfProOrdId.add(ProOrdObj1.Id);
           
            //inserting ListOfRAteCard      
            Rate_Card__c RateCardObj= new Rate_Card__c(P5_Supplier__c=supplier.Id);
            insert RateCardObj;
            List<Rate_Card__c> ListOfRateCard=new List<Rate_Card__c>();
            ListOfRateCard.add(RateCardObj);
             
            //inserting ListOfRAteCardItems      
            Rate_Card_Items__c RateCrdItem= new Rate_Card_Items__c(Material__c=ProOrdObj1.Id,Rate_Card__c=RateCardObj.Id,Cost__c=400,Start_Date__c=system.today(),End_Date__c=system.today() +3);
            insert RateCrdItem;
            List<Rate_Card_Items__c> ListOfRateCardItem=new List<Rate_Card_Items__c>();
            ListOfRateCardItem.add(RateCrdItem);
            System.debug('-----------LIstof rate card Items--->>>>'+ListOfRateCardItem);
    
    
   // static testMethod void WithPositiveData() 
     //{
      	//PrepareData();
      	BatchGWAC_PopulateClass BGP=new BatchGWAC_PopulateClass();
      	
        //List<Product_Order__c> products = [select id from Product_Order__c limit 10];
         //DOE.createOrderDetails(InterfaceOrderlst,batchSuppOrderMap,trancodeMap);
        
        Test.startTest();        
        //database.executeBatch(DOE);
        Database.BatchableContext BC; 
        BGP.createGWACBatch();
        //BGP.createGWACBatch();
        
        
       //BGP.createGWACBatch();
        BGP.execute(BC,ListOfProOrd);  
        BGP.finish(BC);
        Test.stopTest(); 
    }
      
}