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
    private class GWAC_PopulateClass_Test 
    {
    
        static testMethod void GWACCAlMethod() 
        {
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
            Supplier__c supplier = new supplier__c(Name='Testrt4etr supplier',Type__c='Product',Supplier_Num__c='A1234',Resource_Type__c='Resource');
            supplier.ANA_Number__c='12';
             if(supplier.Market_Allocation__c>=100)
            {
                supplier.Market_Allocation__c=2;
                insert supplier;
                system.debug('supplier.Market_Allocation__c2----'+supplier.Market_Allocation__c);
            }else
            {
                
                insert supplier;
            }
            system.debug('supplier.Market_Allocation__c2----'+supplier.Market_Allocation__c);
            //inserting ListOfProOrd;
            Id recTypeobjId= ([Select r.Id From RecordType r where  r.Name= 'Material Record Type' limit 1].Id);
            Product_Order__c ProOrdObj= new Product_Order__c(RecordTypeId=recTypeobjId,Currency_Type__c='GBP');
            insert ProOrdObj;
            List<Product_Order__c> ListOfProOrd=new List<Product_Order__c>();
            ListOfProOrd.add(ProOrdObj);
            
            //inserting ListOfRAteCard      
            Rate_Card__c RateCardObj= new Rate_Card__c(P5_Supplier__c=supplier.ID);
            RateCardObj.Rate_Card_Ext_Id__c='12';
            insert RateCardObj;
            system.debug('-------RateCardObj.P5_Supplier__c------->'+RateCardObj.P5_Supplier__c);
            List<Rate_Card__c> ListOfRateCard=new List<Rate_Card__c>();
            ListOfRateCard.add(RateCardObj);
             
            //inserting ListOfRAteCardItems      
            Rate_Card_Items__c RateCrdItem= new Rate_Card_Items__c(Material__c=ProOrdObj.Id,Rate_Card__c=RateCardObj.Id,Cost__c=400,Start_Date__c=system.today(),End_Date__c=system.today() +3);
            insert RateCrdItem;
            Rate_Card_Items__c RateCrdItem1= new Rate_Card_Items__c(Material__c=ProOrdObj.Id,Rate_Card__c=RateCardObj.Id,Cost__c=400,Start_Date__c=system.today(),End_Date__c=system.today() +3);
            insert RateCrdItem1;
            
            system.debug('RateCrdItem.Supplier__c-----'+RateCrdItem.Supplier__c);
            system.debug('RateCrdItem.Cost__c-----'+RateCrdItem.Cost__c);
            system.debug('RateCardObj----'+RateCardObj.P5_Supplier__c);
            List<Rate_Card_Items__c> ListOfRateCardItem=new List<Rate_Card_Items__c>();
            ListOfRateCardItem.add(RateCrdItem);
            ListOfRateCardItem.add(RateCrdItem1);
            /*List<Product_Order__c> ListproOrder = new List<Product_Order__c>([Select p.Rebate__c, p.NWAC__c, p.Margin__c, p.Id, p.GWAC__c, (Select P5_Supplier__c, Product_Type__c From Material_Rate_Cards__r where P5_Supplier__r.Type__c='Product' ), (Select Cost__c From Rate_Card_Items__r) From Product_Order__c p where p.Id =:ProOrdObj.Id]);
            System.debug('ListproOrder = '+ ListproOrder); */
            
            //Calling the Webservice Method from the Class     
            GWAC_PopulateClass.GWACCal(ProOrdObj.Id);
            GWACHelperClass gwachelper = new GWACHelperClass(); 
            gwachelper.methodForBatchGWAC_PopulateClass(ListOfRateCardItem); 
         
        }
        
    }