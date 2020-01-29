@isTest(SeeAllData=true)

    private class AspEnhanced_test 
    {
        static testMethod void method1() 
        {
                cls_IsRun.generalTriggerSwitch= true;
                lock.jobTriggerSwitch = true;
                
                Account Acc = TestClassHelper.createAccout();
                insert Acc;
                                
                Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                  
                BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
                insert bm ;
               
                
                District__c ds = TestClassHelper.createDistrict(); 
                insert ds;
                
                Job__c jb = TestClassHelper.createJob('Pending','Mismatch',opp.ID, ds.Id);
                jb.Quote__c=bm.Id;
                insert jb;
                
                ASP__c asp = new ASP__c();
                //aspView=true;
                
                
                Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',  IsActive = true); 
                insert product;
                
                Product_Work_Code__c prodCode = new Product_Work_Code__c(Product__c = product.Id, Work_Code__c = 'Test', Skill_type__c = 'Mechanical', Hours__c = 3 , Active__c = true, Start_date__c = system.today().adddays(-10), End_date__c = system.today().adddays(10), Skill__c = 'Mecanical', Product_Code__c = product.name, Work_Code_Description__c = 'Test this Description');
                insert prodCode;
                
                Quote_Product__c qp = TestClassHelper.createQuoteProduct(bm.id);
                qp.Product__c=product.id;
                insert qp; 
               
                ApexPages.standardController controller1 = new ApexPages.standardController(asp);
                pagereference pageref = new pagereference('/apex/Aspenhanced?chiId='+opp.id);
                test.setCurrentPage(pageref);
                AspEnhanced cont_asp = new AspEnhanced(controller1);
                
            
                cont_asp = new AspEnhanced(controller1);
                cont_asp.createNew();
                cont_asp.asp.Function__c = 'Installtion';
                cont_asp.asp.Definition__c = 'Installtion';
                cont_asp.asp.Picklist__c = 'Installtion';
                cont_asp.asp.Description__c='Installtion';
                //create Asp
                cont_asp.createASP();
                //update ASP
                cont_asp.updateAsp();
                //Add new Quote Product
                
                test.starttest();
                cont_asp.AddProductQuote();
                cont_asp.showList[0].qp.Product__c = product.Id;
                cont_asp.updateQuoteProd();
                cont_asp.confirm();
                cont_asp.asp.Charge_to_Customer__c = 88.0;
                cont_asp.addDiscount();
                cont_asp.asp.Charge_to_Customer__c = 78.0;
                cont_asp.addDiscount();
                //pageRef.getParameters().put('cost_cust', '22');   
                qp.Product__c=product.id;
                cont_asp.FullList[0].remove=true;
                cont_asp.AddRemoveQty();
            
                
                cont_asp.showList[0].add = true;
                cont_asp.addRemoveAbove();
                
                cont_asp.showList[0].sub = true;
                cont_asp.addRemoveAbove();
                
                cont_asp.showList[0].sub = true;
                cont_asp.addRemoveAbove();
                
                //cont_asp.showList[0].qp.ASP_Reason__c ='Removed';
                //cont_asp.addRemoveAbove();
            
                cont_asp.AddProductQuote();
                cont_asp.showList[0].qp.Product__c = product.Id;
                cont_asp.updateQuoteProd();
                cont_asp.showList[0].remove=true;
                cont_asp.RemovePQabove();
                
               
                cont_asp.AddProductQuote();
                cont_asp.showList[0].qp.Product__c = product.Id;
                cont_asp.updateQuoteProd();
                cont_asp.AddRemoveQty();
                cont_asp.FullList[0].remove=true;
                cont_asp.RemovePQ();
                
                asp.Quote__c=bm.id;
                cont_asp.viewSelectedASP();
                asp.Quote__c=bm.id;

               
            
                cont_asp.AddUDP();
                cont_asp.userDefinedList[0].qp.Quantity__c = 1;
                cont_asp.userDefinedList[0].qp.Unit_Price_Inc_VAT__c=1;
                cont_asp.userDefinedList[0].qp.Unit_Merchant_Price_Exc_VAT__c =1;
                cont_asp.updateUDP();
                
                cont_asp.userDefinedList[0].remove=true;
                cont_asp.RemoveUDPabove();
                
                cont_asp.AddUDP();
                cont_asp.userDefinedList[0].qp.Quantity__c = 1;
                cont_asp.userDefinedList[0].qp.Unit_Price_Inc_VAT__c=1;
                cont_asp.userDefinedList[0].qp.Unit_Merchant_Price_Exc_VAT__c =1;
                cont_asp.updateUDP();
                
            
                /*cont_asp.confirm();
                cont_asp.OnChangesClick();
                
                pageRef.getParameters().put('cost_cust', string.valueof(cont_asp.totalVal));
                cont_asp.addDiscount();
                test.stopTest();
                cont_asp.confirm();
            
                cont_asp.Submit();
                cont_asp.queryASP(cont_asp.asp.Id);
                cont_asp.asp.ASP_Type__c ='Remedial';
                cont_asp.Submit();
                cont_asp.asp.Approved_By__c = userinfo.getuserid();
                cont_asp.Submit();
                for(AspEnhanced.quoteproductClass qpc : cont_asp.FullList)
                {
                    qpc.Remove = true;
                }
                
                cont_asp.RemovePQ();
                asp.Status__c = 'Entered';
                cont_asp.deleteASP();
                
                test.setCurrentPage(new pagereference('/apex/Aspenhanced?id='+cont_asp.asp.id));
                cont_asp = new AspEnhanced(controller1);
                cont_asp.OnChangesClick();
                cont_asp.jobList.add(jb);
                
                cont_asp.planJob();
                    
                cont_asp.jobList[0].Customer_Preferred_Date__c=system.today();
                cont_asp.planJob();*/
     }
     
     static testMethod void method1_1() 
        {
                cls_IsRun.generalTriggerSwitch= true;
                lock.jobTriggerSwitch = true;
                
                Account Acc = TestClassHelper.createAccout();
                insert Acc;
                                
                Opportunity opp = TestClassHelper.createCHILead(Acc);
                insert opp;
                  
                BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
                insert bm ;
               
                
                District__c ds = TestClassHelper.createDistrict(); 
                insert ds;
                
                Job__c jb = TestClassHelper.createJob('Pending','Mismatch',opp.ID, ds.Id);
                jb.Quote__c=bm.Id;
                insert jb;
                
                ASP__c asp = new ASP__c();
                //aspView=true;
                
                
                Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',  IsActive = true); 
                insert product;
                
                Product_Work_Code__c prodCode = new Product_Work_Code__c(Product__c = product.Id, Work_Code__c = 'Test', Skill_type__c = 'Mechanical', Hours__c = 3 , Active__c = true, Start_date__c = system.today().adddays(-10), End_date__c = system.today().adddays(10), Skill__c = 'Mecanical', Product_Code__c = product.name, Work_Code_Description__c = 'Test this Description');
                insert prodCode;
                
                Quote_Product__c qp = TestClassHelper.createQuoteProduct(bm.id);
                qp.Product__c=product.id;
                insert qp; 
               
                ApexPages.standardController controller1 = new ApexPages.standardController(asp);
                pagereference pageref = new pagereference('/apex/Aspenhanced?chiId='+opp.id);
                test.setCurrentPage(pageref);
                AspEnhanced cont_asp = new AspEnhanced(controller1);
                
            
                cont_asp = new AspEnhanced(controller1);
                cont_asp.createNew();
                cont_asp.asp.Function__c = 'Installtion';
                cont_asp.asp.Definition__c = 'Installtion';
                cont_asp.asp.Picklist__c = 'Installtion';
                cont_asp.asp.Description__c='Installtion';
                //create Asp
                cont_asp.createASP();
                //update ASP
                cont_asp.updateAsp();
                //Add new Quote Product
                
                test.starttest();
                cont_asp.confirm();
                cont_asp.OnChangesClick();
                
                pageRef.getParameters().put('cost_cust', string.valueof(cont_asp.totalVal));
                cont_asp.addDiscount();
                test.stopTest();
                cont_asp.confirm();
            
                cont_asp.Submit();
                cont_asp.queryASP(cont_asp.asp.Id);
                cont_asp.asp.ASP_Type__c ='Remedial';
                cont_asp.Submit();
                cont_asp.asp.Approved_By__c = userinfo.getuserid();
                cont_asp.Submit();
                for(AspEnhanced.quoteproductClass qpc : cont_asp.FullList)
                {
                    qpc.Remove = true;
                }
                
                cont_asp.RemovePQ();
                asp.Status__c = 'Entered';
                cont_asp.deleteASP();
                
                test.setCurrentPage(new pagereference('/apex/Aspenhanced?id='+cont_asp.asp.id));
                cont_asp = new AspEnhanced(controller1);
                cont_asp.OnChangesClick();
                cont_asp.jobList.add(jb);
                
                cont_asp.planJob();
                    
                cont_asp.jobList[0].Customer_Preferred_Date__c=system.today();
                cont_asp.planJob();
     }
     
      static testMethod void method2() 
       {
           
            cls_IsRun.generalTriggerSwitch = true;
            Product2 prod = [select id,Name from Product2 where isActive = true limit 1];      
                    
            
            Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',  IsActive = true); 
            insert product;
            
            Product_Work_Code__c prodCode = new Product_Work_Code__c(Product__c = product.Id, Work_Code__c = 'Test', Skill_type__c = 'Mechanical', Hours__c = 3 , Active__c = true, Start_date__c = system.today().adddays(-10), End_date__c = system.today().adddays(10), Skill__c = 'Mecanical', Product_Code__c = product.name, Work_Code_Description__c = 'Test this Description');
            insert prodCode;
            
            Product2 product2 = new Product2(ProductCode='test1234', Name='test1234', BigMachines_Part_Number__c='test1234',  IsActive = true); 
            insert product2;
            
            Product_Work_Code__c prodCode2 = new Product_Work_Code__c(Product__c = product2.Id, Work_Code__c = 'Test', Skill_type__c = 'Mechanical', Hours__c = 3 , Active__c = true, Start_date__c = system.today().adddays(-10), End_date__c = system.today().adddays(10), Skill__c = 'Mecanical', Product_Code__c = product2.name, Work_Code_Description__c = 'Test this Description');
            insert prodCode2;
            
            Account Acc = TestClassHelper.createAccout();
            insert Acc;
            
            Opportunity opp = TestClassHelper.createCHILead(Acc);
            insert opp;
           
            BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
            insert bm ;
            
            list<Quote_Product__c > quoteProdList = new  list<Quote_Product__c >();
            
            for(integer i= 1;i<=2; i++ )
            {
                Quote_Product__c quoteProd = TestClassHelper.createQuoteProduct(bm.Id);
                quoteProd.Quantity__c= i;
                if(i==1)
                quoteProd.Product__c =  product.Id;
                else if(i==2)
                quoteProd.Product__c =  product2.Id;
                   
                
                quoteProdList.add(quoteProd);  
            }
            Quote_Product__c quoteProd = TestClassHelper.createQuoteProduct(bm.Id);
            quoteProd.Product__c =   prod.Id;
            quoteProd.Quantity__c = 3;
            quoteProd.Name = prod.Name;
            quoteProdList.add(quoteProd);
            
            insert quoteProdList;
            
            Job__c jb = TestClassHelper.createJob('Pending','Mismatch',opp.ID, null);
            jb.Quote__c=bm.Id;
            jb.Is_Downtime_Job__c=false;
            jb.Is_Remedial_Job__c=true;
            jb.Customer_Preferred_Date__c = system.Today() +1 ;
            jb.Split_Job__c=false;
            insert jb;
                 
           
            
           
            Case caseObj = new Case();
            caseObj.RecordTypeId=system.label.ASPCase;
            caseObj.Subject='Test Case';
            caseObj.Description='Test Desc';
            caseObj.Disputed_Amount__c=100;
            caseObj.Communication_status__c='Awaiting Office';
            caseObj.Case_Source__c='Customer';
            caseObj.Priority='High';
            caseObj.Classification__c='Sales';
            caseObj.Status='New';
            insert caseObj;
            
                     
            
            ASP_Requested_Items__c ASPRequestedItem =new ASP_Requested_Items__c(ASP_Request__c = caseObj.id, Product__c = prod.Id, Quantity__c = 2,     Action__c = 'Add');
            insert  ASPRequestedItem;  
            
            
            ASP_Requested_Items__c ASPRequestedItem2 =new ASP_Requested_Items__c(ASP_Request__c = caseObj.id, Product__c = prod.Id, Quantity__c = 2,    Action__c = 'Remove');
            insert  ASPRequestedItem2;  
            
            
            ASP_Requested_Items__c ASPRequestedItem4 =new ASP_Requested_Items__c(ASP_Request__c = caseObj.id, Product__c = product.Id, Quantity__c = 2,     Action__c = 'Remove');
            insert  ASPRequestedItem4;  
            
            ASP__c asp = TestClassHelper.createAsp(bm.Id);
          
            insert asp;
            
            ASP__c asp2 = TestClassHelper.createAsp(bm.Id);
            asp2.Request_For_ASP__c = caseObj.Id;
            insert asp2;
            
            ApexPages.standardController controller1 = new ApexPages.standardController(asp);
            pagereference pageRef = new pagereference('/apex/Aspenhanced?id='+asp.id);
            test.setCurrentPage(pageRef);
            AspEnhanced cont_asp = new AspEnhanced(controller1);    
            
            //to reduce the no of queired . Relying on Controller to get the discount Prod.
            
            ASP_Requested_Items__c ASPRequestedItem3 =new ASP_Requested_Items__c(ASP_Request__c = caseObj.id, Product__c = cont_asp.disountProd.Id, Quantity__c = 2,    Action__c = 'Add');
            insert  ASPRequestedItem3; 
            
            controller1 = new ApexPages.standardController(asp);
            pageRef = new pagereference('/apex/Aspenhanced?retURL=/'+bm.Id);
            test.setCurrentPage(pageRef);
            cont_asp = new AspEnhanced(controller1);   
           
            pageRef = new pagereference('/apex/Aspenhanced?retURL=/'+bm.Id);
            test.setCurrentPage(pageRef);
            cont_asp = new AspEnhanced(controller1); 
           
            jb.Is_Remedial_Job__c=false;
            update jb;
            test.starttest();
            controller1 = new ApexPages.standardController(asp2);
            pageRef = new pagereference('/apex/Aspenhanced?id='+asp2.id+'&edit=1');
            test.setCurrentPage(pageRef);
            cont_asp = new AspEnhanced(controller1);            
            
            cont_asp.reqPrdId = ASPRequestedItem.Id;
            cont_asp.addSelProd();
            cont_asp.rejSelProd();
             
            cont_asp.reqPrdId = ASPRequestedItem2.Id;
            cont_asp.addSelProd(); 
            
            cont_asp.reqPrdId = ASPRequestedItem3.Id;
            cont_asp.addSelProd(); 
            
            cont_asp.reqPrdId = ASPRequestedItem4.Id;
            cont_asp.addSelProd(); 
            
            cont_asp.aspId = asp2.Id;
            cont_asp.viewSelectedASP();
            cont_asp.showSelectedASP();
            AspEnhanced.quoteproductClass testthis = new AspEnhanced.quoteproductClass(new Quote_Product__c());
            for(AspEnhanced.quoteproductClass asq:cont_asp.FullList)
            {
                if(asq.qp.Quantity__c==1)
                {
                    testthis = asq;
                    break;
                }   
            }
            testthis.add = true;
            cont_asp.AddRemoveQty();
            
            testthis.sub = true;
            cont_asp.AddRemoveQty();
           
            testthis.sub = true;
            cont_asp.AddRemoveQty(); 
            
            testthis.sub = true;
            cont_asp.AddRemoveQty();
            
            testthis.add = true;
            cont_asp.AddRemoveQty();
           
            testthis.add = true;
            cont_asp.AddRemoveQty();
           
            testthis.add = true;
            cont_asp.AddRemoveQty();
           
            //testthis.remove=true;
            //cont_asp.RemovePQ();
           
            for(AspEnhanced.quoteproductClass asq:cont_asp.FullList)
            {
                if(asq.qp.Quantity__c==2)
                {
                    testthis = asq;
                    break;
                }   
            }
           
            testthis.sub = true;
            cont_asp.AddRemoveQty(); 
           
            testthis.sub = true;
            cont_asp.addRemoveAbove();
           
            testthis.add = true;
            cont_asp.AddRemoveQty();
                        
            testthis.sub = true;
            cont_asp.AddRemoveQty(); 
           
            testthis.sub = true;
            cont_asp.AddRemoveQty(); 
           
            testthis.sub = true;
            cont_asp.AddRemoveQty(); 
            
           for(AspEnhanced.quoteproductClass asq:cont_asp.showList)
            {
                if(asq.qp.ASP_Reason__c=='Removed')
                {
                    testthis = asq;
                    break;
                }   
            }
            
           
            testthis.sub = true;
            cont_asp.addRemoveAbove();
            cont_asp.calucalateCustomerPayementVariation();
          test.stopTest();
           
        }
        
       static testMethod void method3() 
       {
            cls_IsRun.generalTriggerSwitch = true;
            Product2[] prod = [select id,Name from Product2 where isActive = true limit 3];      
                    
            Product_Work_Code__c prodCode1 = new Product_Work_Code__c(Product__c = prod[0].Id, Work_Code__c = 'Test', Skill_type__c = 'Mechanical', Hours__c = 3 , Active__c = true, Start_date__c = system.today().adddays(-10), End_date__c = system.today().adddays(10), Skill__c = 'Mecanical', Product_Code__c = prod[0].name, Work_Code_Description__c = 'Test this Description');
            Product_Work_Code__c prodCode2 = new Product_Work_Code__c(Product__c = prod[1].Id, Work_Code__c = 'Test', Skill_type__c = 'Buliding Work', Hours__c = 3 , Active__c = true, Start_date__c = system.today().adddays(-10), End_date__c = system.today().adddays(10), Skill__c = 'Mecanical', Product_Code__c = prod[1].name, Work_Code_Description__c = 'Test this Description');
            Product_Work_Code__c prodCode3 = new Product_Work_Code__c(Product__c = prod[2].Id, Work_Code__c = 'Test', Skill_type__c = 'Power Flush', Hours__c = 3 , Active__c = true, Start_date__c = system.today().adddays(-10), End_date__c = system.today().adddays(10), Skill__c = 'Mecanical', Product_Code__c = prod[2].name, Work_Code_Description__c = 'Test this Description');
                
                
            insert new list<Product_Work_Code__c>{prodCode1,prodCode2, prodCode3};
            
            //system.debug('Product-->'+prod);
            Account Acc = TestClassHelper.createAccout();
            insert Acc;
            
            Opportunity opp = TestClassHelper.createCHILead(Acc);
            insert opp;
           
            BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
            insert bm ;
            
            list<Quote_Product__c > quoteProdList = new  list<Quote_Product__c >();
            
            for(integer i= 1;i<=2; i++ )
            {
                Quote_Product__c quoteProd = TestClassHelper.createQuoteProduct(bm.Id);
                quoteProd.Quantity__c= i;
                if(i==1)
                {    
                    quoteProd.Product__c =  prod[0].Id;
                    quoteProd.Name=prod[0].Name;
                    //system.debug('1st product-->'+prod[0].Name);
                }   
                else if(i==2)
                {
                    quoteProd.Product__c =  prod[1].Id;
                    quoteProd.Name=prod[1].Name;
                    //system.debug('2st product-->'+prod[1].Name);
                }
                   
                
                quoteProdList.add(quoteProd);  
            }
            Quote_Product__c quoteProd = TestClassHelper.createQuoteProduct(bm.Id);
            quoteProd.Product__c =   prod[2].Id;
            quoteProd.Quantity__c = 3;
            quoteProd.Name = prod[2].Name;
            quoteProdList.add(quoteProd);
            
            insert quoteProdList;
            //system.debug('quoteProdList--->'+quoteProdList);
            Job__c jb = TestClassHelper.createJob('Pending','Mismatch',opp.ID, null);
            jb.Quote__c=bm.Id;
            insert jb;
           
             
            ASP__c asp = TestClassHelper.createAsp(bm.Id);
          
            insert asp;
            
           
            ApexPages.standardController controller1 = new ApexPages.standardController(asp);
          
            pagereference pageRef = new pagereference('/apex/Aspenhanced?id='+asp.id+'&edit=1');
            test.setCurrentPage(pageRef);
            AspEnhanced cont_asp = new AspEnhanced(controller1);   
            
          
           for(AspEnhanced.quoteproductClass asq:cont_asp.FullList)
           {
               if(asq.qp.Quantity__c==1)
               {
                   asq.add = true;
                   break;
               }    
           }
           cont_asp.AddRemoveQty();
           for(AspEnhanced.quoteproductClass asq:cont_asp.FullList)
           {
               if(asq.qp.Quantity__c==1)
               {
                   asq.remove = true;
                   break;
               }    
           }
           cont_asp.RemovePQ();
           //system.debug('Ashok-->'+cont_asp.FullList);
           for(AspEnhanced.quoteproductClass asq:cont_asp.FullList)
           {
               if(asq.qp.Quantity__c==2)
               {
                   asq.sub = true;
                   break;
               }    
           }
          
           cont_asp.AddRemoveQty();
           
           for(AspEnhanced.quoteproductClass asq:cont_asp.FullList)
           {
               if(asq.qp.Quantity__c==2)
               {
                   asq.remove = true;
                   break;
               }    
           }
           cont_asp.RemovePQ();
           
           for(AspEnhanced.quoteproductClass asq:cont_asp.FullList)
           {
               if(asq.qp.Quantity__c==3)
               {
                   asq.remove = true;
                   break;
               }    
           }
           cont_asp.RemovePQ();
           
            system.debug('Ashok-->2nd'+cont_asp.showList);
           for(AspEnhanced.quoteproductClass asq:cont_asp.showList)
           {
               //if(asq.qp.Quantity__c==3)
               {
                   asq.remove = true;
                   break;
               }    
           }
           cont_asp.RemovePQabove();
           cont_asp.updateQuoteProd();
           
       } 

    }