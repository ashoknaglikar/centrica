@isTest
private class TestQuoteProductForASPCalculateSalesP {
   
    ///////////////////////////////////////////////////////////////////////
    // TESTING CLASSES for QuoteProductForASPCalculateSalesPrice trigger //
    ///////////////////////////////////////////////////////////////////////
      
      //Test that when a quote product relating to an ASP is inserted that its sales price is populayed correctly
      @isTest
      public static void Test1QuoteProductForASPCalculateSalesP(){
           //Setup test environment
            Account Acc = TestScenarioCreateAccount();
            Opportunity opty = TestScenarioCreateOppty(Acc); 
            Job__c[] Job = TestScenarioCreateJob('Pending','Mismatch',opty.ID);          
            BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty);
            Job[0].Quote__c=quote[0].Id;       
            update Job;
            
            system.debug('Quote[0].stage__c is: '+Quote[0].stage__c); 
            system.debug('Quote[0].is_primary__c is: '+Quote[0].is_primary__c);
            system.debug('Quote[0].close__c is: '+Quote[0].closeDate__c);
            ASP__c asp = TestScenarioCreateASP(quote);
            Pricebook2[] PriceBooks = TestScenarioCreatePriceBook();
            Product2[] products = TestScenarioCreateProducts();
            PricebookEntry[] pbentries = TestScenarioCreatePricBookEntries(products, PriceBooks);
            Supplier__c supplier1 = TestScenarioCreatSupplier();
            
            //create line items relating to an ASP and assert price is set correctly by trigger   
            Test.startTest();
            Quote_Product__c lineItem1 = new Quote_Product__c(Product__c=products[0].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp.Id, Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='ABC123');               
            Quote_Product__c lineItem2 = new Quote_Product__c(Product__c=products[1].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp.Id, Part_Number__c='ABC456', Quantity__c=3.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='ABC456');
            Quote_Product__c lineItem3 = new Quote_Product__c(Product__c=products[2].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp.Id, Part_Number__c='UDPQP', Quantity__c=3.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='UDPQP',Unit_Merchant_Price_Exc_VAT__c = 100,Unit_Price_Inc_VAT__c =200,User_Defined_Description__c='its a test UDP',User_Defined_VAT_Rate__c='General VAT',Supplier__c = supplier1.Id,User_Defined_Product__c = true);      
                      
            Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2,lineItem3};     
            insert lineItems;       
            Test.stopTest();
            Quote_Product__c lineItem1After = [select Sales_Price__c, price_list_price_each__c from Quote_Product__c where id=:lineItems[0].id];
            //assert salesprice equal unit price x uplift factor x vat rate
            System.assertEquals(50.00,lineItem1After.Sales_Price__c);
            
            Quote_Product__c lineItem2After = [select Sales_Price__c, price_list_price_each__c from Quote_Product__c where id=:lineItems[1].id];
            //assert salesprice equal unit price x uplift factor x vat rate
            System.assertEquals(30,lineItem2After.Sales_Price__c);
      }
     @isTest
    public static void Test2QuoteProductForASPCalculateSalesP(){
       		Account Acc1 = TestScenarioCreateAccount1();
            Opportunity opty1 = TestScenarioCreateOppty1(Acc1); 
            Job__c[] Job1 = TestScenarioCreateJob1('Pending','Mismatch',opty1.ID);          
            BigMachines_Quote__c[] quote1 = TestScenarioCreateQuote1(opty1);
            Job1[0].Quote__c=quote1[0].Id;       
            update Job1;
            system.debug('Quote1[0].stage__c is: '+Quote1[0].stage__c); 
            system.debug('Quote1[0].is_primary__c is: '+Quote1[0].is_primary__c);
            system.debug('Quote1[0].close__c is: '+Quote1[0].closeDate__c); 
        	ASP__c asp1 = TestScenarioCreateASP1(quote1);
            Pricebook2[] PriceBooks = TestScenarioCreatePriceBook();
            Product2[] products = TestScenarioCreateProducts();
            PricebookEntry[] pbentries = TestScenarioCreatePricBookEntries(products, PriceBooks);
            Supplier__c supplier1 = TestScenarioCreatSupplier();
            Test.startTest();
            Quote_Product__c lineItem11 = new Quote_Product__c(Product__c=products[0].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp1.Id, Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote1[0].Id, Name='ABC123');               
            Quote_Product__c lineItem21 = new Quote_Product__c(Product__c=products[1].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp1.Id, Part_Number__c='ABC456', Quantity__c=3.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote1[0].Id, Name='ABC456');
            Quote_Product__c lineItem31 = new Quote_Product__c(Product__c=products[2].Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added', ASP__c=asp1.Id, Part_Number__c='UDPQP', Quantity__c=3.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote1[0].Id, Name='UDPQP',Unit_Merchant_Price_Exc_VAT__c = 100,Unit_Price_Inc_VAT__c =200,User_Defined_Description__c='its a test UDP',User_Defined_VAT_Rate__c='General VAT',Supplier__c = supplier1.Id,User_Defined_Product__c = true);      
                      
            Quote_Product__c[] lineItems1 = new Quote_Product__c[]{lineItem11,lineItem21,lineItem31};     
            insert lineItems1;       
            Test.stopTest();
    }  
      
    @isTest
    private static Account TestScenarioCreateAccount(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');    
        insert district;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=district.Id, Code__c='yyyyyyyy');             
         insert subPatch;
         Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
         Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                      
         insert Acc; 
         return Acc;
        
    }
    private static Account TestScenarioCreateAccount1(){
        District__c district1 = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyas');    
        insert district1;
        Sub_Patch__c subPatch1 = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=district1.Id, Code__c='yyyyyas');             
         insert subPatch1;
         Postcode_Sector__c postcodeSector1 = new Postcode_Sector__c(Type__c='Installation', Name='XAX X', Sub_Patch__c=subPatch1.Id, Code__c='yAXyyas');
        insert postcodeSector1;
         Account Acc1 = new Account(Name = 'test account quote decompile1', BillingStreet='Test Street1', BillingPostalCode = 'XAX XXY');                      
         insert Acc1;       
         return Acc1;
    }
    
    //test method        
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
		insert opty; 
        return opty;
        
    }
    private static Opportunity TestScenarioCreateOppty1(Account Acc1){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty1 = new Opportunity(Name = 'Test for Quote Decompile1', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc1.Id);
        insert opty1;       
        return opty1;
    }
    
    //test method        
    private static ASP__c TestScenarioCreateASP(BigMachines_Quote__c[] quote){
        
        ASP__c asp = new ASP__c(Quote__c=quote[0].Id,ASP_Date__c=date.today(),function__c='Sales',definition__c='Building Work',Picklist__c='Downtime',Status__c='Entered');
        insert asp;        
        return asp;
    }
    private static ASP__c TestScenarioCreateASP1(BigMachines_Quote__c[] quote1){
        
         ASP__c asp1 = new ASP__c(Quote__c=quote1[0].Id,ASP_Date__c=date.today(),function__c='Sales',definition__c='Building Work',Picklist__c='Downtime',Status__c='Entered');
        insert asp1; 
       return asp1;
        
    }
    
    //test method 
    public static BigMachines_Quote__c[] TestScenarioCreateQuote(Opportunity opty){
        
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, Pricebook_Id__c='testabc', geographicUpliftFactor__c=2, stage__c='Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',is_primary__c=true,closeDate__c = system.today());           
        BigMachines_Quote__c[] quotelist = new BigMachines_Quote__c[]{quote};
        insert quotelist;        
        return quotelist;
    }
    public static BigMachines_Quote__c[] TestScenarioCreateQuote1(Opportunity opty1){
       	BigMachines_Quote__c quote1= new BigMachines_Quote__c(Name = 'Test for Quote Decompile1', Opportunity__c = opty1.id, Pricebook_Id__c='testabc', geographicUpliftFactor__c=2, stage__c='Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',is_primary__c=true,closeDate__c = system.today().adddays(100));
        BigMachines_Quote__c[] quotelist1 = new BigMachines_Quote__c[]{quote1};
        insert quotelist1;        
        return quotelist1;
    }
    
    //test method     
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId){
        
        Job__c job1 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID);              
        Job__c[] joblist = new Job__c[]{job1};          
        insert joblist;        
        return joblist;
    }
    
    public static Job__c[] TestScenarioCreateJob1(string status, string substatus, ID opty1Id){
        
        Job__c job2 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=opty1ID);              
        Job__c[] joblist = new Job__c[]{job2};          
        insert joblist;        
        return joblist;
    }
    
    //test method     
    public static Product2[] TestScenarioCreateProducts(){
      
        Product2 product1 = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123');
        Product2 product2 = new Product2(ProductCode='ABC456', Name='ABC456', BigMachines_Part_Number__c='ABC456');
        Product2 product3 = new Product2(ProductCode='UDPQP1', Name='UDPQP1', BigMachines_Part_Number__c='UDPQP1',User_Defined_Product__c=true );  
        Product2[] products = new Product2[]{product1,product2,product3};     
        insert products; 
        return products;
    }
    
    //test method     
    public static PricebookEntry[] TestScenarioCreatePricBookEntries(Product2[] products, Pricebook2[] Pricebooks){
      
        PriceBook2 standardPB = [select ID from Pricebook2 where IsStandard=true];
        //need to create an entry for the products in the standard price book else validation rules fail the insert
        PricebookEntry pbentrys1 = new PricebookEntry(IsActive=true,UnitPrice=50, Product2Id=products[0].Id, Pricebook2Id=standardPB.id);
        PricebookEntry pbentrys2 = new PricebookEntry(IsActive=true,UnitPrice=30, Product2Id=products[1].Id, Pricebook2Id=standardPB.id);
        PricebookEntry[] standardentries = new PricebookEntry[]{pbentrys1,pbentrys2};
        insert standardentries;
        
        PricebookEntry pbentry1 = new PricebookEntry(Usestandardprice=false,IsActive=true,UnitPrice=50, Product2Id=products[0].Id, Pricebook2Id=Pricebooks[0].id);
        PricebookEntry pbentry2 = new PricebookEntry(Usestandardprice=false,IsActive=true,UnitPrice=30, Product2Id=products[1].Id, Pricebook2Id=Pricebooks[0].id);
        
        
        
        PricebookEntry[] pbentries = new PricebookEntry[]{pbentry1,pbentry2};
        insert pbentries;
        return pbentries;
        }
        
         //test method     
    public static Pricebook2[] TestScenarioCreatePriceBook(){
        Pricebook2 Pricebook = new Pricebook2(IsActive=true,name='testabc');
        Pricebook2[] Pricebooks = new Pricebook2[]{Pricebook};
        insert Pricebooks;
        return PriceBooks;
  }
  	public static Supplier__c TestScenarioCreatSupplier(){
  		Supplier__c supplier1 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12XX21', Name='British Gas');
  		insert supplier1;
  		return supplier1;
  	}           
  }