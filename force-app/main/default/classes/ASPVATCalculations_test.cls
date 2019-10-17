@isTest(SeeAllData=true)

    private class ASPVATCalculations_test 
    {
        static List<BigMachines_Quote__c> quoteList;
        static testMethod void method1() 
        {
                //Map<String, PricebookEntry> PricebookEntriesMap = new Map<String, PricebookEntry>();
                //Map<String, ID> priceBooksUsedMap = new Map<String, ID>();
                
                Account Acc = TestClassHelper.createAccout();
                insert Acc;
                                
                Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                  
                BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
                bm.Pricebook_Id__c='CHX';
                bm.quoteNumber_quote__c='quote.Id';
                bm.closeDate__c=system.today();
                bm.geographicUpliftFactor__c = 10;
                insert bm ;
             
                quoteList = new List<BigMachines_Quote__c>();
                quoteList.add(bm);
              
                Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',  IsActive = true, First_VAT_Code__c = '1'); 
                insert product;
                
                List<Quote_Product__c > qplist= new List<Quote_Product__c>();
                Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                Materials__c=true,Labour__c=false,Part_Number__c='CBLRAS', BigMachines_Quote__c=bm.Id,Merchant_Price__c=307,
                Name='CBLRAS',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4', installationNotes__c= 'test notes');
                insert quoteProduct;
                qplist.add(quoteProduct);
                
                //VAT_Codes__c vat1 = new VAT_Codes__c (End_Date__c = system.today().adddays(500),Start_Date__c = system.today().adddays(101),VAT_Code_1__c ='1',
                //VAT_Code_1_Rate__c = 20.0,VAT_Code_4__c = '4',VAT_Code_4_Rate__c = 5.0,Status__c = 'Active' ); 
                //insert vat1 ;
                
                Pricebook2 Pricebook = new Pricebook2(IsActive=true,name='CHX');
                insert Pricebook ;
               
                
               
                PriceBook2 standardPB = [select ID from Pricebook2 where IsStandard=true ];
                PricebookEntry pbentrys2 = new PricebookEntry(IsActive=true,UnitPrice=50,Pricebook2Id=standardPB.id, Product2Id=product.Id,Usestandardprice=false);
                insert pbentrys2 ;
                PricebookEntry pbentrys1 = new PricebookEntry(IsActive=true,UnitPrice=50,Pricebook2Id=Pricebook.id, Product2Id=product.Id,Usestandardprice=false);
                insert pbentrys1 ;
                
                //PricebookEntriesMap.put('pbentrys1',pbentrys1);
                
                ASPVATCalculations avc= new ASPVATCalculations();
                String overwrite='2011-01-04';
                bm.closeDate__c=system.today();
                //PricebookEntriesMap.put('pbentrys1',pbentrys1 );
                //quoteProduct.Name='Hii';
                //quoteProduct.pricebookID=Pricebook.Id;
                //Pricebook2 =Pricebook.Id;
                avc.calculateVatForNonUDP(qplist);
               
        }
        
        static testMethod void method2() 
        {       
                Map<Id,Product2> mappr2 = new Map<Id,Product2>();
                
                Account Acc = TestClassHelper.createAccout();
                insert Acc;
                                
                Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                  
                BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
                bm.Pricebook_Id__c='CHX';
                bm.quoteNumber_quote__c='quote.Id';
                bm.closeDate__c=system.today()-1095;
                insert bm ;
                
                Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',  IsActive = true); 
                insert product;
                mappr2.put(product.id,product);
               
                List<Quote_Product__c > qplist= new List<Quote_Product__c>();
                Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                Materials__c=true,Labour__c=false,Part_Number__c='CBLRAS', BigMachines_Quote__c=bm.Id,Merchant_Price__c=307,
                Name='CBLRAS',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4', installationNotes__c= 'test notes');
                insert quoteProduct;
                qplist.add(quoteProduct);
            	
            	PriceBook2 standardPB = [select ID from Pricebook2 where IsStandard=true ];
            
            	Pricebook2 Pricebook = new Pricebook2(IsActive=true,name='CHX');
                insert Pricebook ;
            
                PricebookEntry pbentrys2 = new PricebookEntry(IsActive=true,UnitPrice=50,Pricebook2Id=standardPB.id, Product2Id=product.Id,Usestandardprice=false);
                insert pbentrys2 ;
                PricebookEntry pbentrys1 = new PricebookEntry(IsActive=true,UnitPrice=50,Pricebook2Id=Pricebook.id, Product2Id=product.Id,Usestandardprice=false);
                insert pbentrys1 ;
                
                ASPVATCalculations avc= new ASPVATCalculations();
                bm.closeDate__c=date.newInstance(2009, 01, 01);
                String overwrite='2011-01-04';
                avc.calculateVatForNonUDP(qplist);
                
                quoteProduct.User_Defined_Product__c=true;
                product.User_Defined_Product__c=false;
                avc.calculateVatForUDP(qplist,mappr2);
                
                quoteProduct.User_Defined_Product__c=true;
                product.User_Defined_Product__c=true;
                quoteProduct.ASP_Reason__c='Added';
                quoteProduct.User_Defined_VAT_Rate__c='General VAT';
                quoteProduct.Unit_Price_Inc_VAT__c=22.02;
                quoteProduct.Unit_Merchant_Price_Exc_VAT__c=22.03;
                quoteProduct.User_Defined_Description__c='hi';
                avc.calculateVatForUDP(qplist,mappr2);
               
            
        }

    }