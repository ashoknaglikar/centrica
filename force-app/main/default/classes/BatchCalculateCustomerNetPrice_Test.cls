@isTest
private class BatchCalculateCustomerNetPrice_Test {
    @isTest
    static void TestCalculateNetPrice(){          
        try {
            //Setup test environment
            Account Acc = TestScenarioCreateAccount();
            Opportunity opty = TestScenarioCreateOppty(Acc);
            Job__c[] Job = TestScenarioCreateJob('Allocated','',opty.Id);        
            BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);                            
            quote[0].stage__c = 'Quote Finalised - Accepted';  
            quote[0].bmStatusReason__c =  'Quote Finalised - Accepted';  
            quote[0].Transferred_to_Premier__c = null;
            quote[0].Line_Items_Decompiled__c = true;
            quote[0].BM_Completed__c = true;
            quote[0].quote_reconciled__c =true; 
            update quote[0];                     
            Job[0].Quote__c=quote[0].Id;        
            update Job;   
            system.debug('Job is: '+job);    
            Supplier__c supplier1 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12CC21', Name='British Gas CC');
            Supplier__c supplier2 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='99CC66', Name='Flower Inc CC');
            Supplier__c[] suppliers = new Supplier__c[]{supplier1,supplier2};
            insert suppliers;
            Employee__c employee1 = new Employee__c(Supplier__c=suppliers[0].Id, Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
            Employee__c employee2 = new Employee__c(Supplier__c=suppliers[1].Id, Name = 'Test Emp 2', Employee_Number__c = '0999008', Primary_Role__c = 'STM', Last_Name__c='Emp2', First_Name__c='TestP1Controller');
            Employee__c [] TestEmployees = new Employee__c[]{employee1,employee2};      
            insert TestEmployees; 
            Week__c week1 = new Week__c(Employee__c=employee1.Id);
            Week__c week2 = new Week__c(Employee__c=employee2.Id);
            Week__c[] weeks = new Week__c[]{week1,week2};
            insert weeks;           
            Diary_Entry__c de1 = new Diary_Entry__c(week__c = weeks[0].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Mechanical',Job__c=Job[0].ID);
            Diary_Entry__c de2 = new Diary_Entry__c(week__c = weeks[1].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Electrical',Job__c=Job[0].ID);
            Diary_Entry__c[] diaryEntries = new Diary_Entry__c[]{de1,de2};
            insert diaryEntries;
            
            system.debug('Job is still: '+job);
            //create the reference data for work and materials                                              
            TestScenarioCreateWorkAndMaterials();       
    
            Test.startTest();
            //Add a number of line items and assert later that the correct number of job elements has been created        
            //Below are 2 identical line items against a quote. As each line item quantity is set to 1, we should get a total of 2 x (1 related Work Element + 0 related Material Elements) = 2 Job Elements created the against job.
            Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='456789', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='456789');        
            Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='987654', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='987654');                              
            Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2};     
            insert lineItems;       
            //do a stoptest() to ensure the future method to decompile the quote has finished
            Test.stopTest();

              // Invoke the logic for calculating net customer price excluding VAT.
                    
                    List<BigMachines_Quote__c> bmQuoteListToConsider = new List<BigMachines_Quote__c>();
                    
                    CalculateQuoteNetValue c = new CalculateQuoteNetValue();
                    
                    BigMachines_Quote__c quoteToConsider = [select id, name, createdDate_quote__c,IsSystem__c, 
                          Number_of_paperworks_recieved__c,
                          Opportunity__r.Platform__c,
                          Opportunity__r.CHI_Lead_Id__c,Opportunity__c, 
                          Opportunity__r.Account.Primary_Contact__r.Salutation,
                          Opportunity__r.Account.Primary_Contact__r.FirstName,
                          Opportunity__r.Account.Primary_Contact__r.LastName,
                          Opportunity__r.Account.BillingStreet,
                          Opportunity__r.Account.BillingCity,
                          Opportunity__r.Account.BillingState,
                          Opportunity__r.Account.BillingPostalCode,
                          Opportunity__r.Account.Primary_Contact__r.MailingCity,
                          Opportunity__r.Account.Primary_Contact__r.MailingState,
                          Opportunity__r.Account.Primary_Contact__r.MailingPostalCode ,
                          Opportunity__r.Account.Primary_Contact__r.MailingStreet,
                          Opportunity__r.Payment_Reference_Number__c,
                          Opportunity__r.Override_Billing_checks__c,
                          Opportunity__r.discountsTotalOnPricing__c,
                          Opportunity__r.Manual_Bill__c,VAT_1_Total_Amount_For_Net_Price_Calc__c,VAT_4_Total_Amount_For_Net_Price_Calc__c,Net_Price_Charged_To_Customer__c,
                          Opportunity__r.Bill_to_Office__c,
                          Opportunity__r.StageName,Opportunity__r.Bill_Period__c,Opportunity__r.Installation_Date_Billing__c,
                          VAT_17_5_Total_Amount__c, POC_Payment_Method__c,ASP_Discounts__c,
                          VAT_5_Total_Amount__c,discountsTotalOnPricing__c,App_Assigned_Payroll__c,
                          Pricebook_Id__c, App_Assigned_To__c,POC_Payment_Option__c, 
                          priceMatchDifference__c,ISpec_Difference__c,Billed__c,newPriceMatchDifference__c,closeDate__c,
                          newTotalNetPrice_quote__c,
           (Select ID from Paperwork_Recieved_Details__r where Sales_Paperwork_Validated_Date__c != null),
           (Select Employee_ID__c, Employee__r.Emp_type__c From Diary_Entries__r where Employee__r.Group__c = 'INST'),                                                                      
           (Select Product_Code__c, VAT_Code__c, User_Defined_VAT_Code__c,FirstVATCode__c, Gross_Total__c, Merchant_Price__c,Total_Price__c, BigMachines_Quote__c From Quote_Products__r),
           (Select Id, Delivery_Date__c,Installation_Date__c,Status__c, Region_Code__c,Is_Downtime_Job__c,Is_Remedial_Job__c,createddate From Jobs__r where Is_Downtime_Job__c = false and Is_Remedial_Job__c = false)
            from  BigMachines_Quote__c where Id= :quote[0].Id];
             
                  bmQuoteListToConsider.add(quoteToConsider);
            
                  c.calculateQuoteNetValueForCustomer(bmQuoteListToConsider);
            
            // Test coverage for batch which calculates net price charged to customers.
                  
                 BatchCalculateCustomerNetPrice BOE = new BatchCalculateCustomerNetPrice();
                 Database.BatchableContext BC; 
                 BOE.execute(BC,bmQuoteListToConsider);
                 BOE.finish(BC);
            
           // Test job trigger for calculating net price.
           
           Job__c job_calc = [Select status__c,Installation_Date__c from Job__c where CHI_Lead__r.ID = :opty.Id];
           
           // Scenario 1 change status from allocated to planned & Scenario 2 change the installation date of the planned job.
                     
            cls_IsRun.isCalculateNetCustomerPrice = false;
            job_calc.Installation_Date__c = Date.today();
            job_calc.status__c = 'Allocated';
            update job_calc;
            cls_IsRun.isCalculateNetCustomerPrice = false;
            job_calc.status__c = 'Planned';
            update job_calc;
            cls_IsRun.isCalculateNetCustomerPrice = false;
            job_calc.Installation_Date__c = Date.today().addDays(1);
            update job_calc;
            
          // Test OpportunityUpdate Trigger
                 
          Opportunity opp = [Select Installation_Date_Billing__c, Bill_Period__c from Opportunity where ID = :opty.Id];
          cls_IsRun.isCalculateNetCustomerPrice = false;
          opp.Installation_Date_Billing__c = '2010-12-31';
          opp.Bill_Period__c = 'Before 04/01';  
          update opp;
          cls_IsRun.isCalculateNetCustomerPrice = false;
          opp.Installation_Date_Billing__c = '2011-01-04';
          opp.Bill_Period__c = 'After 04/01';  
          update opp;
          cls_IsRun.isCalculateNetCustomerPrice = false;
          opp.Installation_Date_Billing__c = null;
          opp.Bill_Period__c = null;  
          update opp;

        } catch(Exception ex) {
            
            System.debug('Exception ocurred '+ex.getMessage());
            
            
        }
    }
    
    @isTest
    private static Account TestScenarioCreateAccount(){
        District__c district = new District__c(Type__c='Installation', Name='Calculate District', Code__c='ccccccccc');      
        insert district;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='CCC C', District__c=district.Id, Code__c='ccccccccc');                
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='CCC C', Sub_Patch__c=subPatch.Id, Code__c='ccccccccc');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account calculate net price', BillingStreet='Test Calculate', BillingPostalCode = 'CCC CCC');                       
        insert Acc;        
        return Acc;
    }
    
    //test method        
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign Calc', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Calculate Price', StageName = 'Prospecting', Platform__c = 'SFDC',CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
        
    }
    
    //test method 
    public static BigMachines_Quote__c[] TestScenarioCreateQuote(Opportunity opty,integer num){
        
        BigMachines_Quote__c quote;
        if(num==1)
            quote = new BigMachines_Quote__c(Name = 'Test for Calc Price', Opportunity__c = opty.id, quote_reconciled__c=true);           
        if(num==2)
            quote = new BigMachines_Quote__c(Name = 'Test for Calc Price', Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                   
        BigMachines_Quote__c[] quotelist = new BigMachines_Quote__c[]{quote};
        insert quotelist;        
        return quotelist; 
    }
    
    //test method     
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId){
        
        Job__c job1 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=0,Unvented_Hot_Water_Hours__c=0,Specialist_Building_Hours__c=0,Scaffolder_Hours__c=0,Roof_Work_Hours__c=0,Payment_Collection_Hours__c=0,Mechanical_Hours__c=0,LPG_Installation_Hours__c=0,Fire_Wall_Heater_Fixing_Hours__c=0,Electrical_Hours__c=0,Contractor_Installation_Hours__c=0,Connect_Solar_Panel_Hours__c=0,Building_Work_Hours__c=0,PowerFlush_Hours__c=0,Electrical_Work_ASP_Hours__c=0,Asbestos_Removal_Hours__c=0,Asbestos_Removal_Fixed_Rate_Hours__c=0,Solar_Hours__c=0);              
        Job__c[] joblist = new Job__c[]{job1};          
        system.debug('joblist contains :'+joblist);
        insert joblist;        
        return joblist;
    }
    
    @isTest
    private static void TestScenarioCreateWorkAndMaterials(){
        
        Product_Work_Code__c productWorkCode1 = new Product_Work_Code__c(Work_Code__c='CCC123', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='PowerFlush', Skill_Type__c='Work', Product_Code__c='CCC123', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode2 = new Product_Work_Code__c(Work_Code__c='123CCC', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='B', Skill_Type__c='Work', Product_Code__c='CCC456', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode3 = new Product_Work_Code__c(Work_Code__c='456789', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='Mechanical', Skill_Type__c='Work', Product_Code__c='456789', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode4 = new Product_Work_Code__c(Work_Code__c='456789', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='Electrical', Skill_Type__c='Work', Product_Code__c='987654', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);        
        Product_Work_Code__c[] productWorkCodeList = new Product_Work_Code__c[]{productWorkCode1,productWorkCode2,productWorkCode3,productWorkCode4};        
        insert productWorkCodeList;
        
        Product_Materials__c productMaterials1 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=2.0, Product_Code__c='CCC123', Material_Description__c='Scaffolding', Material_Code__c='C', End_Date__c=date.today(), Active__c = True);
        Product_Materials__c productMaterials2 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=3.0, Product_Code__c='CCC456', Material_Description__c='Scaffolding', Material_Code__c='MC', End_Date__c=date.today(), Active__c = True);      
        Product_Materials__c productMaterials3 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=3.0, Product_Code__c='CCC456', Material_Description__c='Scaffolding', Material_Code__c='MC', End_Date__c=date.today(), Active__c = True);              
        Product_Materials__c[] productMaterialsList = new Product_Materials__c[]{productMaterials1,productMaterials2,productMaterials3};        
        insert productMaterialsList;
    }
	
}