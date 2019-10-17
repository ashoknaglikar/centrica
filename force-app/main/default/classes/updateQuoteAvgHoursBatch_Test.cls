@isTest
private class updateQuoteAvgHoursBatch_Test{
    private static id[] productorderIds;
    private static id distirictId;
              
    static void updateQuoteAvgHoursBatch(){   
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
        
        
        String District = distirictId;//[Select Id, Name From District__c where Name='Decompile District'][0].id;                
        Job__c[] Job = TestScenarioCreateJob('Installed','Installed',opty.Id,District );         
       
        // 2011 CHI Commission Scheme changes - Start
        TestScenarioCreateMaterial();
        List<Product_Order__c> NWACForMaterials =   [Select a.Product_Code__c, a.NWAC__c From  Product_Order__c a where Id in:productorderIds];
        System.debug('NWAC__c '+ NWACForMaterials[0].NWAC__c + ' For Material '+ NWACForMaterials[0].Product_Code__c);
        System.debug('NWAC__c '+ NWACForMaterials[1].NWAC__c + ' For Material '+ NWACForMaterials[1].Product_Code__c);       
        TestScenarioCreateSkillRates(District);
        // 2011 CHI Commission Scheme changes - End
              
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,2);               
                       
        Job[0].Quote__c=quote[0].Id; 
        Job[0].Installation_Date__c=system.today();       
        update Job;   
        
        system.debug('Job is: '+job);    
        Supplier__c supplier1 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12XX21', Name='British Gas');
        Supplier__c supplier2 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='99XX66', Name='Flower Inc');
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
            
        //create the reference data for work and materials                                              
        TestScenarioCreateWorkAndMaterials();  
        
        // Add Products
        
        Product2 Prod1 = new Product2(Name = 'ABC123', Non_Commisionable__c = False);
        Product2 Prod2 = new Product2(Name = '654321', Non_Commisionable__c = False);         
        Product2 Prod3 = new Product2(Name = '123456', Non_Commisionable__c = False); 
        
        Product2 Prod4 = new Product2(Name = '123480', Non_Commisionable__c = False); 
        Product2 Prod5 = new Product2(Name = '123481', Non_Commisionable__c = False); 
        Product2 Prod6 = new Product2(Name = '123482', Non_Commisionable__c = False); 
        Product2 Prod7 = new Product2(Name = '123483', Non_Commisionable__c = False); 
        Product2 Prod8 = new Product2(Name = '123484', Non_Commisionable__c = False); 
        Product2 Prod9 = new Product2(Name = '123485', Non_Commisionable__c = False); 
        Product2 Prod10 = new Product2(Name = '123486', Non_Commisionable__c = False); 
        Product2 Prod11 = new Product2(Name = '123487', Non_Commisionable__c = False); 
        Product2 Prod12 = new Product2(Name = '123488', Non_Commisionable__c = False); 
        Product2 Prod13 = new Product2(Name = '123489', Non_Commisionable__c = False);
        Product2 Prod14 = new Product2(Name = '123490', Non_Commisionable__c = False);
        Product2 Prod33 = new Product2(Name = '123491', Non_Commisionable__c = False); 
        Product2 Prod34 = new Product2(Name = '123492', Non_Commisionable__c = False); 
        Product2 Prod35 = new Product2(Name = '123493', Non_Commisionable__c = False); 
        Product2 Prod36 = new Product2(Name = '123494', Non_Commisionable__c = False); 
        Product2 Prod37 = new Product2(Name = '123495', Non_Commisionable__c = False); 
        Product2 Prod38 = new Product2(Name = '123496', Non_Commisionable__c = False); 
        Product2 Prod39 = new Product2(Name = '123497', Non_Commisionable__c = False); 
        Product2 Prod40 = new Product2(Name = '123498', Non_Commisionable__c = False); 
        Product2 Prod41 = new Product2(Name = '123499', Non_Commisionable__c = False); 
        Product2 Prod15 = new Product2(Name = '123500', Non_Commisionable__c = False);
        Product2 Prod16 = new Product2(Name = '123501', Non_Commisionable__c = False);
        Product2 Prod17 = new Product2(Name = '123502', Non_Commisionable__c = False);
        Product2 Prod18 = new Product2(Name = '123503', Non_Commisionable__c = False);
        Product2 Prod19 = new Product2(Name = '123504', Non_Commisionable__c = False);
        Product2 Prod20 = new Product2(Name = '123505', Non_Commisionable__c = False);
        Product2 Prod21 = new Product2(Name = '123506', Non_Commisionable__c = False);
        Product2 Prod22 = new Product2(Name = '123507', Non_Commisionable__c = False);
        Product2 Prod23 = new Product2(Name = '123508', Non_Commisionable__c = False);
        Product2 Prod24 = new Product2(Name = '123509', Non_Commisionable__c = False);
        Product2 Prod25 = new Product2(Name = '123510', Non_Commisionable__c = False);
        Product2 Prod26 = new Product2(Name = '123511', Non_Commisionable__c = False);
        Product2 Prod27 = new Product2(Name = '123512', Non_Commisionable__c = False);
        Product2 Prod28 = new Product2(Name = '123513', Non_Commisionable__c = False);
        Product2 Prod29 = new Product2(Name = '123514', Non_Commisionable__c = False);
        Product2 Prod30 = new Product2(Name = '123515', Non_Commisionable__c = False);
        Product2 Prod31 = new Product2(Name = '123516', Non_Commisionable__c = False);
        Product2 Prod32 = new Product2(Name = '123517', Non_Commisionable__c = False);

 
             
        Product2[] Products = new Product2[]{Prod1,Prod2,Prod3,Prod4,Prod5,Prod6,Prod7,Prod8,Prod9,Prod10,Prod11,Prod12,Prod13,prod14,
                               prod15,prod16,prod17,prod18,prod19,prod20,prod21,prod22,prod23,prod24,prod25,prod26,prod27,prod28,prod29,prod30,prod31,prod32,Prod33,Prod34,Prod35,Prod36,Prod37,Prod38,Prod39,Prod40,Prod41};           
        insert Products;
        
        id[] ASPId = new list<id>();
             

        Quote_Product__c lineItem = new Quote_Product__c(Part_Number__c='123456', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123456', product__c = Prod3.Id);                              
        insert lineItem;        
        
        //Add line items related to the ASP
        Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='ABC123', product__c = Prod1.Id);        
        Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='654321', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='654321', product__c = Prod2.Id);   
       
        Quote_Product__c lineItem3 = new Quote_Product__c(Part_Number__c='123480', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123480', product__c = Prod4.Id);   
        Quote_Product__c lineItem4 = new Quote_Product__c(Part_Number__c='123481', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123481', product__c = Prod5.Id);   
        Quote_Product__c lineItem5 = new Quote_Product__c(Part_Number__c='123482', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123482', product__c = Prod6.Id);   
        Quote_Product__c lineItem6 = new Quote_Product__c(Part_Number__c='123483', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123483', product__c = Prod7.Id);   
        Quote_Product__c lineItem7 = new Quote_Product__c(Part_Number__c='123484', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123484', product__c = Prod8.Id);   
        Quote_Product__c lineItem8 = new Quote_Product__c(Part_Number__c='123485', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123485', product__c = Prod9.Id);   
        Quote_Product__c lineItem9 = new Quote_Product__c(Part_Number__c='123486', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123486', product__c = Prod10.Id);   
        Quote_Product__c lineItem10 = new Quote_Product__c(Part_Number__c='123487', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123487', product__c = Prod11.Id);   
        Quote_Product__c lineItem11 = new Quote_Product__c(Part_Number__c='123488', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123488', product__c = Prod12.Id);   
        Quote_Product__c lineItem13 = new Quote_Product__c(Part_Number__c='123489', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123489', product__c = Prod13.Id);   
        Quote_Product__c lineItem14 = new Quote_Product__c(Part_Number__c='123490', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123490', product__c = Prod14.Id);   
        Quote_Product__c lineItem15 = new Quote_Product__c(Part_Number__c='123491', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123491', product__c = Prod33.Id);   
        Quote_Product__c lineItem16 = new Quote_Product__c(Part_Number__c='123492', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123492', product__c = Prod34.Id);   
        Quote_Product__c lineItem17 = new Quote_Product__c(Part_Number__c='123493', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123493', product__c = Prod35.Id);   
        Quote_Product__c lineItem18 = new Quote_Product__c(Part_Number__c='123494', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123494', product__c = Prod36.Id);   
        Quote_Product__c lineItem19 = new Quote_Product__c(Part_Number__c='123495', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123495', product__c = Prod37.Id);   
        Quote_Product__c lineItem20 = new Quote_Product__c(Part_Number__c='123496', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123496', product__c = Prod38.Id);   
        Quote_Product__c lineItem21 = new Quote_Product__c(Part_Number__c='123497', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123497', product__c = Prod39.Id);   
        Quote_Product__c lineItem22 = new Quote_Product__c(Part_Number__c='123498', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123498', product__c = Prod40.Id);   
        Quote_Product__c lineItem23 = new Quote_Product__c(Part_Number__c='123499', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123499', product__c = Prod41.Id);   

        Quote_Product__c lineItem24 = new Quote_Product__c(Part_Number__c='123500', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123500', product__c = Prod15.Id);   
        Quote_Product__c lineItem25 = new Quote_Product__c(Part_Number__c='123502', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123502', product__c = Prod17.Id);   
        Quote_Product__c lineItem26 = new Quote_Product__c(Part_Number__c='123503', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123503', product__c = Prod18.Id);   
        Quote_Product__c lineItem27 = new Quote_Product__c(Part_Number__c='123504', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123504', product__c = Prod19.Id);   
        Quote_Product__c lineItem28 = new Quote_Product__c(Part_Number__c='123505', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123505', product__c = Prod20.Id);   
        Quote_Product__c lineItem29 = new Quote_Product__c(Part_Number__c='123506', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123506', product__c = Prod21.Id);   
        Quote_Product__c lineItem30 = new Quote_Product__c(Part_Number__c='123507', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123507', product__c = Prod22.Id);   
        Quote_Product__c lineItem31 = new Quote_Product__c(Part_Number__c='123508', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123508', product__c = Prod23.Id);   
        Quote_Product__c lineItem32 = new Quote_Product__c(Part_Number__c='123509', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123509', product__c = Prod24.Id);   
        Quote_Product__c lineItem33 = new Quote_Product__c(Part_Number__c='123510', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123510', product__c = Prod25.Id);   
        Quote_Product__c lineItem34 = new Quote_Product__c(Part_Number__c='123511', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123511', product__c = Prod26.Id);   
        Quote_Product__c lineItem35 = new Quote_Product__c(Part_Number__c='123512', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123512', product__c = Prod27.Id);   
        Quote_Product__c lineItem36 = new Quote_Product__c(Part_Number__c='123513', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123513', product__c = Prod28.Id);   
        Quote_Product__c lineItem37 = new Quote_Product__c(Part_Number__c='123514', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123514', product__c = Prod29.Id);   
        Quote_Product__c lineItem38 = new Quote_Product__c(Part_Number__c='123515', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123515', product__c = Prod30.Id);   
        Quote_Product__c lineItem39 = new Quote_Product__c(Part_Number__c='123516', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123516', product__c = Prod31.Id);   
        Quote_Product__c lineItem40 = new Quote_Product__c(Part_Number__c='123517', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123517', product__c = Prod32.Id);   
        Quote_Product__c lineItem12 = new Quote_Product__c(Part_Number__c='123517', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123517', product__c = Prod32.Id);   

        //LineItem12
        Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem12,lineItem1,lineItem2,lineItem3,lineItem4,lineItem5,lineItem6,lineItem7,lineItem8,lineItem9,lineItem10,lineItem11,lineItem13,
                                             lineItem14,lineItem15,lineItem16,lineItem17,lineItem18,lineItem19,lineItem20,lineItem21,lineItem22,lineItem23,lineItem24,lineItem25,lineItem26,lineItem27,lineItem28,lineItem29,lineItem30,lineItem31,lineItem32,lineItem33,lineItem34,lineItem35,lineItem36,lineItem37,lineItem38,lineItem39,lineItem40};           
        insert lineItems;             
        
         String[] QProducts = new String[]{lineItem.Id, lineItem1.Id,lineItem2.Id};
               
        Job_Element__c JE1 = new Job_Element__c();        
        JE1.Job__c = Job[0].Id;        
        JE1.Type__c='Material';                 
        JE1.New_Supplier_Number__c= supplier2.Supplier_Num__c;        
        JE1.Current_Supplier__c='CSupplier1';        
        JE1.Current_Supplier_Number__c='321';        
        JE1.Code__c=supplier2.Supplier_Num__c;        
        JE1.Supplier_Order_Number__c='1212';        
        JE1.Status__c='Active';        
        JE1.Sub_Status__c='Awaiting Order';        
        JE1.Description__c='testDescription';        
        JE1.Line_Item_ID__c=lineItem.Id;        
        JE1.Skill__c='Scaffolder';        
        JE1.Units__c=125;        
        JE1.P5_IsItinerary__c=false;             
        insert JE1;      
        
        
        Job_Element__c JE2 = new Job_Element__c();        
        JE2.Job__c = Job[0].Id;        
        JE2.Type__c='Material';
        JE2.New_Supplier_Number__c= supplier2.Supplier_Num__c;        
        JE2.Current_Supplier__c='CSupplier1';        
        JE2.Current_Supplier_Number__c='321';        
        JE2.Code__c=supplier2.Supplier_Num__c;        
        JE2.Supplier_Order_Number__c='1212';        
        JE2.Status__c='Active';        
        JE2.Sub_Status__c='Awaiting Order';        
        JE2.Description__c='testDescription';        
        JE2.Line_Item_ID__c=lineItem1.Id;        
        JE2.Skill__c='Scaffolder';        
        JE2.Units__c=125;        
        JE2.P5_IsItinerary__c=false;        
        insert JE2;
        
        Job_Element__c JE3 = new Job_Element__c();        
        JE3.Job__c = Job[0].Id;        
        JE3.Type__c='Work'; 
        JE3.New_Supplier_Number__c= supplier2.Supplier_Num__c;        
        JE3.Current_Supplier__c='CSupplier1';        
        JE3.Current_Supplier_Number__c='321';        
        JE3.Code__c=supplier2.Supplier_Num__c;        
        JE3.Supplier_Order_Number__c='1212';        
        JE3.Status__c='Active';        
        JE3.Sub_Status__c='Awaiting Order';        
        JE3.Description__c='testDescription';        
        JE3.Line_Item_ID__c=lineItem2.Id;              
        JE3.Skill__c='Scaffolder';        
        JE3.Units__c=125;        
        JE3.P5_IsItinerary__c=false;        
        insert JE3;
        
        Job_Element__c JE4 = new Job_Element__c();        
        JE4.Job__c = Job[0].Id;        
        JE4.Type__c='Work'; 
        JE4.New_Supplier_Number__c= supplier2.Supplier_Num__c;        
        JE4.Current_Supplier__c='CSupplier1';        
        JE4.Current_Supplier_Number__c='321';        
        JE4.Code__c=supplier2.Supplier_Num__c;        
        JE4.Supplier_Order_Number__c='1212';        
        JE4.Status__c='Active';        
        JE4.Sub_Status__c='Awaiting Order';        
        JE4.Description__c='testDescription';        
        JE4.Line_Item_ID__c=lineItem24.Id;              
        JE4.Skill__c='Scaffolder';        
        JE4.Units__c=125;        
        JE4.P5_IsItinerary__c=false;        
        insert JE4;
        
                 
    }
    
    static testmethod void Test_case1(){
        updateQuoteAvgHoursBatch();
        Test.startTest();
        updateQuoteAvgHours UpdQuote = new updateQuoteAvgHours();
        Database.ExecuteBatch(UpdQuote);
        Test.stopTest();
    }
    
    @isTest
    private static Account TestScenarioCreateAccount(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        distirictId = district.Id;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=district.Id, Code__c='yyyyyyyy');                
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        return Acc;
    }
    
    //test method        
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }
    
    //test method 
    public static BigMachines_Quote__c[] TestScenarioCreateQuote(Opportunity opty,integer num){
        CS_Allowance__c cs = new CS_Allowance__c(Name = 'test', Amount__c = 500);
        insert cs;
        
        BigMachines_Quote__c quote;
        if(num==1)
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile',Average_Labour_Cost_Quote__c = 123,Average_Material_Cost_Quote__c=100, Billed__c = true, Opportunity__c = opty.id, quote_reconciled__c=true, CS_Allowance_1__c = cs.Id,CS_Allowance_2__c = cs.Id,CS_Allowance_3__c = cs.Id,CS_Allowance_4__c = cs.Id,CS_Allowance_5__c = cs.Id,CS_Allowance_6__c = cs.Id, appliedAmount1__c = 100, appliedAmount2__c = 200 , appliedAmount3__c = 100 , appliedAmount4__c = 100 , appliedAmount5__c = 50 , appliedAmount6__c = 100 );           
        if(num==2)
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Average_Labour_Cost_Quote__c = 123,Average_Material_Cost_Quote__c=100, Billed__c = true, Commissionable_Sales_Value__c = 300.00, Non_Commission_Sales_Value__c = 100.00 ,Transferred_to_Premier__c = null, Line_Items_Decompiled__c = true, Is_Primary__c = true, Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2,
            CS_Allowance_1__c = cs.Id,CS_Allowance_2__c = cs.Id,CS_Allowance_3__c = cs.Id,CS_Allowance_4__c = cs.Id,CS_Allowance_5__c = cs.Id,CS_Allowance_6__c = cs.Id, appliedAmount1__c = 100, appliedAmount2__c = 200 , appliedAmount3__c = 100 , appliedAmount4__c = 100 , appliedAmount5__c = 50 , appliedAmount6__c = 100 );                   
        BigMachines_Quote__c[] quotelist = new BigMachines_Quote__c[]{quote};
        insert quotelist;        
        return quotelist;
    }
    
    //test method     
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId, string District){
        
        Job__c job1 = new Job__c(District__c = District , Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=0,Unvented_Hot_Water_Hours__c=0,Specialist_Building_Hours__c=0,Scaffolder_Hours__c=0,Roof_Work_Hours__c=0,Payment_Collection_Hours__c=0,Mechanical_Hours__c=0,LPG_Installation_Hours__c=0,Fire_Wall_Heater_Fixing_Hours__c=0,Electrical_Hours__c=0,Contractor_Installation_Hours__c=0,Connect_Solar_Panel_Hours__c=0,Building_Work_Hours__c=0,PowerFlush_Hours__c=0,Electrical_Work_ASP_Hours__c=0,Asbestos_Removal_Hours__c=0,Asbestos_Removal_Fixed_Rate_Hours__c=0,Solar_Hours__c=0);              
        Job__c[] joblist = new Job__c[]{job1};          
        system.debug('joblist contains :'+joblist);
        insert joblist;        
        return joblist;
    }
    
     //test method     
    public static void TestScenarioCreateSkillRates(string District){
        
        Avg_Skill_Rate__c SkillRate1 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='MECHANICAL');
        Avg_Skill_Rate__c SkillRate2 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ELECTRICAL');
        Avg_Skill_Rate__c SkillRate3 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='POWERFLUSH');
        Avg_Skill_Rate__c SkillRate4 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ROOF WORK');
        Avg_Skill_Rate__c SkillRate5 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='BUILDING WORK');
        Avg_Skill_Rate__c SkillRate6 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='WATER HEATER FIXING');
        Avg_Skill_Rate__c SkillRate7 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='SPECIALIST BUILDING');
        Avg_Skill_Rate__c SkillRate8 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='SCAFFOLDER');
        Avg_Skill_Rate__c SkillRate9 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='PAYMENT COLLECTION');
        Avg_Skill_Rate__c SkillRate10 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='FIREWALL HEATER FIXING');
        Avg_Skill_Rate__c SkillRate11 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='CONTRACTOR INSTALLATION');
        Avg_Skill_Rate__c SkillRate12 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='CONNECT SOLAR PANELS');
       
        Avg_Skill_Rate__c SkillRate13 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='PRE-ELECTRICAL SURVEY');
        Avg_Skill_Rate__c SkillRate14 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='SOLAR');
        Avg_Skill_Rate__c SkillRate15 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='CONTRACTOR_INSTALLATION');
        Avg_Skill_Rate__c SkillRate16 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='SPECIALIST_BUILDING_WORK');
        Avg_Skill_Rate__c SkillRate17 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='ASBESTOS_REMOVAL');
        Avg_Skill_Rate__c SkillRate18 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='LPG_INSTALLATION');
        Avg_Skill_Rate__c SkillRate19 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='QUALITY INSPECTION');
        Avg_Skill_Rate__c SkillRate20 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='CAVITY WALL INSULATION');
        Avg_Skill_Rate__c SkillRate21 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='DOUBLE HANDED WORK');
        Avg_Skill_Rate__c SkillRate22 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='INSTALL SOLAR PANELS');
        Avg_Skill_Rate__c SkillRate23 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='SPECIALIST BUILDING WORK');
        
        Avg_Skill_Rate__c SkillRate24 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='LPG INSTALLATIONELECTRICAL WORK ASP');
        Avg_Skill_Rate__c SkillRate25 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='ASBESTOS REMOVAL');
        Avg_Skill_Rate__c SkillRate26 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 100,Skill__c ='ASBESTOS REMOVAL FIXED RATE');
        Avg_Skill_Rate__c SkillRate27 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ECOGEN MECHANICAL');
        Avg_Skill_Rate__c SkillRate28 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ECOGEN ELECTRICAL');
        Avg_Skill_Rate__c SkillRate29 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='UNVENTED HOT WATER');
        Avg_Skill_Rate__c SkillRate30 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='UNVENTED_HOT_WATER');
        Avg_Skill_Rate__c SkillRate31 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='FIRE_WALL HEATER FIXING');
        Avg_Skill_Rate__c SkillRate32 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='CONNECT_SOLAR_PANELS');
        Avg_Skill_Rate__c SkillRate33 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ROOF_WORK');
        Avg_Skill_Rate__c SkillRate34 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ELECTRICAL_WORK_ASP');
        Avg_Skill_Rate__c SkillRate35 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ASBESTOS_REMOVAL-FIXED_RATE');
        Avg_Skill_Rate__c SkillRate36 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='ASBESTOS REMOVAL-FIXED RATE');
        Avg_Skill_Rate__c SkillRate37 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='PAYMENT_COLLECTION');
        Avg_Skill_Rate__c SkillRate38 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='WATER_HEATER_FIXING');
        Avg_Skill_Rate__c SkillRate39 = new Avg_Skill_Rate__c(District__c = District , Rate__c = 200,Skill__c ='INSULATION (LOFT)');      
       
        Avg_Skill_Rate__c[] SkillRates = new Avg_Skill_Rate__c[]{SkillRate1,SkillRate2,SkillRate3,SkillRate4,SkillRate5,SkillRate6,SkillRate7,SkillRate8,SkillRate9,SkillRate10,SkillRate11,SkillRate12,SkillRate13,SkillRate14,SkillRate15,SkillRate16,SkillRate17,SkillRate18,SkillRate19,SkillRate20,SkillRate21,SkillRate22,
                                           SkillRate23,SkillRate24,SkillRate25,SkillRate26,SkillRate27,SkillRate28,SkillRate29,SkillRate30,SkillRate31,SkillRate32,SkillRate33,SkillRate34,SkillRate35,SkillRate36,SkillRate37,SkillRate38,SkillRate39};        
               
        insert SkillRates;    
    }
    
    //test method     
    public static void TestScenarioCreateMaterial(){
        
        Product_Order__c Material1 = new Product_Order__c(Product_Number__c = 'MC', GWAC__c = 300, Rebate__c = 100 );
        Product_Order__c Material2 = new Product_Order__c(Product_Number__c = 'MC2', GWAC__c = 400, Rebate__c = 100);
                      
        Product_Order__c[] Materials = new Product_Order__c[]{Material1,Material2};        
               
        insert Materials;        
        productorderIds = new Id[]{Materials[0].Id,Materials[1].Id};
    }
    
    @isTest
    private static void TestScenarioCreateWorkAndMaterials(){
        
        Product_Work_Code__c productWorkCode1 = new Product_Work_Code__c(Work_Code__c='ABC123', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='PowerFlush', Skill_Type__c='Work', Product_Code__c='ABC123', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode2 = new Product_Work_Code__c(Work_Code__c='123ABC', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='B', Skill_Type__c='Work', Product_Code__c='ABC123', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode3 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='Mechanical', Skill_Type__c='Work', Product_Code__c='123456', End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode4 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='Electrical', Skill_Type__c='Work', Product_Code__c='654321', Hours__c=0.45, End_Date__c=date.today(), Active__c = True); 
        
        Product_Work_Code__c productWorkCode15 = new Product_Work_Code__c(Work_Code__c='123480', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='POWERFLUSH', Skill_Type__c='POWERFLUSH', Product_Code__c='123480', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode16 = new Product_Work_Code__c(Work_Code__c='123481', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ROOF WORK', Skill_Type__c='ROOF WORK', Product_Code__c='123481', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode7 = new Product_Work_Code__c(Work_Code__c='123482', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='BUILDING WORK', Skill_Type__c='BUILDING WORK', Product_Code__c='123482', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode8 = new Product_Work_Code__c(Work_Code__c='123483', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='WATER HEATER FIXING', Skill_Type__c='WATER HEATER FIXING', Product_Code__c='123483', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode9 = new Product_Work_Code__c(Work_Code__c='123484', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='SPECIALIST BUILDING', Skill_Type__c='SPECIALIST BUILDING', Product_Code__c='123484', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode10 = new Product_Work_Code__c(Work_Code__c='123485', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='SCAFFOLDER', Skill_Type__c='SCAFFOLDER', Product_Code__c='123485', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode11 = new Product_Work_Code__c(Work_Code__c='123486', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='PAYMENT COLLECTION', Skill_Type__c='PAYMENT COLLECTION', Product_Code__c='123486', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode12 = new Product_Work_Code__c(Work_Code__c='123487', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='FIREWALL HEATER FIXING', Skill_Type__c='FIREWALL HEATER FIXING', Product_Code__c='123487', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode13 = new Product_Work_Code__c(Work_Code__c='123488', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='CONTRACTOR INSTALLATION', Skill_Type__c='CONTRACTOR INSTALLATION', Product_Code__c='123488', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode14 = new Product_Work_Code__c(Work_Code__c='123489', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='CONNECT SOLAR PANELS', Skill_Type__c='CONNECT SOLAR PANELS', Product_Code__c='123489', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode17 = new Product_Work_Code__c(Work_Code__c='123490', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='PRE-ELECTRICAL SURVEY', Skill_Type__c='PRE-ELECTRICAL SURVEY', Product_Code__c='123490', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode18 = new Product_Work_Code__c(Work_Code__c='123491', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='SOLAR', Skill_Type__c='SOLAR', Product_Code__c='123491', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode19 = new Product_Work_Code__c(Work_Code__c='123492', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='CONTRACTOR_INSTALLATION', Skill_Type__c='CONTRACTOR_INSTALLATION', Product_Code__c='123492', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode20 = new Product_Work_Code__c(Work_Code__c='123493', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='SPECIALIST_BUILDING_WORK', Skill_Type__c='SPECIALIST_BUILDING_WORK', Product_Code__c='123493', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode21 = new Product_Work_Code__c(Work_Code__c='123494', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ASBESTOS_REMOVAL', Skill_Type__c='ASBESTOS_REMOVAL', Product_Code__c='123494', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode22 = new Product_Work_Code__c(Work_Code__c='123495', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='LPG_INSTALLATION', Skill_Type__c='LPG_INSTALLATION', Product_Code__c='123495', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode23 = new Product_Work_Code__c(Work_Code__c='123496', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='QUALITY INSPECTION', Skill_Type__c='QUALITY INSPECTION', Product_Code__c='123496', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode24 = new Product_Work_Code__c(Work_Code__c='123497', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='CAVITY WALL INSULATION', Skill_Type__c='CAVITY WALL INSULATION', Product_Code__c='123497', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode25 = new Product_Work_Code__c(Work_Code__c='123498', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='DOUBLE HANDED WORK', Skill_Type__c='DOUBLE HANDED WORK', Product_Code__c='123498', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode26 = new Product_Work_Code__c(Work_Code__c='123499', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='INSTALL SOLAR PANELS', Skill_Type__c='INSTALL SOLAR PANELS', Product_Code__c='123499', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 

        Product_Work_Code__c productWorkCode27 = new Product_Work_Code__c(Work_Code__c='123500', Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='SPECIALIST BUILDING WORK', Skill_Type__c='SPECIALIST BUILDING WORK', Product_Code__c='123500', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
       // Product_Work_Code__c productWorkCode28 = new Product_Work_Code__c(Work_Code__c='123501',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='SPECIALIST BUILDING WORK', Skill_Type__c='SPECIALIST BUILDING WORK', Product_Code__c='123501', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode29 = new Product_Work_Code__c(Work_Code__c='123502',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='LPG INSTALLATIONELECTRICAL WORK ASP', Skill_Type__c='LPG INSTALLATIONELECTRICAL WORK ASP', Product_Code__c='123502', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode30 = new Product_Work_Code__c(Work_Code__c='123503',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ASBESTOS REMOVAL', Skill_Type__c='ASBESTOS REMOVAL', Product_Code__c='123503', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode31 = new Product_Work_Code__c(Work_Code__c='123504',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ASBESTOS REMOVAL FIXED RATE', Skill_Type__c='ASBESTOS REMOVAL FIXED RATE', Product_Code__c='123504', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode32 = new Product_Work_Code__c(Work_Code__c='123505',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ECOGEN MECHANICAL', Skill_Type__c='ECOGEN MECHANICAL', Product_Code__c='123505', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode33 = new Product_Work_Code__c(Work_Code__c='123506',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ECOGEN ELECTRICAL', Skill_Type__c='ECOGEN ELECTRICAL', Product_Code__c='123506', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode34 = new Product_Work_Code__c(Work_Code__c='123507',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='UNVENTED HOT WATER', Skill_Type__c='UNVENTED HOT WATER', Product_Code__c='123507', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode35 = new Product_Work_Code__c(Work_Code__c='123508',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='UNVENTED_HOT_WATER', Skill_Type__c='UNVENTED_HOT_WATER', Product_Code__c='123508', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode36 = new Product_Work_Code__c(Work_Code__c='123509',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='FIRE_WALL HEATER FIXING', Skill_Type__c='FIRE_WALL HEATER FIXING', Product_Code__c='123509', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode37 = new Product_Work_Code__c(Work_Code__c='123510',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='CONNECT_SOLAR_PANELS', Skill_Type__c='CONNECT_SOLAR_PANELS', Product_Code__c='123510', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode38 = new Product_Work_Code__c(Work_Code__c='123511',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ROOF_WORK', Skill_Type__c='ROOF_WORK', Product_Code__c='123511', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode39 = new Product_Work_Code__c(Work_Code__c='123512',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ELECTRICAL_WORK_ASP', Skill_Type__c='ELECTRICAL_WORK_ASP', Product_Code__c='123512', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode40 = new Product_Work_Code__c(Work_Code__c='123513',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ASBESTOS_REMOVAL-FIXED_RATE', Skill_Type__c='ASBESTOS_REMOVAL-FIXED_RATE', Product_Code__c='123513', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode41 = new Product_Work_Code__c(Work_Code__c='123514',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='ASBESTOS REMOVAL-FIXED RATE', Skill_Type__c='ASBESTOS REMOVAL-FIXED RATE', Product_Code__c='123514', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode42 = new Product_Work_Code__c(Work_Code__c='123515',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='PAYMENT_COLLECTION', Skill_Type__c='PAYMENT_COLLECTION', Product_Code__c='123515', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode43 = new Product_Work_Code__c(Work_Code__c='123516',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='WATER_HEATER_FIXING', Skill_Type__c='WATER_HEATER_FIXING', Product_Code__c='123516', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 
        Product_Work_Code__c productWorkCode44 = new Product_Work_Code__c(Work_Code__c='123517',Work_Code_Description__c='Description', Start_Date__c=date.today()-10, Skill__c='INSULATION (LOFT)', Skill_Type__c='INSULATION (LOFT)', Product_Code__c='123517', Hours__c=0.45, End_Date__c=date.today()+10, Active__c = True); 


        // CHI 2011 Commission 
        Product_Work_Code__c productWorkCode5 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today()- 10, Skill__c='Electrical', Skill_Type__c='Electrical', Product_Code__c='654321', Hours__c=0.45, End_Date__c=date.today() + 10, Active__c = True);
        Product_Work_Code__c productWorkCode6 = new Product_Work_Code__c(Work_Code__c='123457', Work_Code_Description__c='Description', Start_Date__c=date.today()- 10, Skill__c='MECHANICAL', Skill_Type__c='MECHANICAL', Product_Code__c='654321', End_Date__c=date.today() + 10, Active__c = True);
               //productWorkCode1,productWorkCode2,productWorkCode3,productWorkCode4,
        Product_Work_Code__c[] productWorkCodeList = new Product_Work_Code__c[]{productWorkCode1,productWorkCode2,productWorkCode3,productWorkCode4,productWorkCode5, productWorkCode6,productWorkCode15,productWorkCode16,productWorkCode7,productWorkCode8,productWorkCode9,productWorkCode10,productWorkCode11,productWorkCode12,productWorkCode13,productWorkCode14,productWorkCode17,productWorkCode18,productWorkCode19,productWorkCode20,productWorkCode21,productWorkCode22,productWorkCode23,productWorkCode24,productWorkCode25,productWorkCode26,
                                                           productWorkCode27,productWorkCode29,productWorkCode30,productWorkCode31,productWorkCode32,productWorkCode33,productWorkCode34,productWorkCode35,productWorkCode36,productWorkCode37,productWorkCode38,productWorkCode39,productWorkCode40,productWorkCode41,productWorkCode42,productWorkCode43,productWorkCode44  };        
        insert productWorkCodeList;
        
        Product_Materials__c productMaterials1 = new Product_Materials__c(Start_Date__c=date.today()-5, Quantity__c=2.0, Product_Code__c='ABC123', Material_Description__c='Material Description', Material_Code__c='CMC', End_Date__c=date.today()+5, Active__c = True);
        Product_Materials__c productMaterials2 = new Product_Materials__c(Start_Date__c=date.today()-5, Quantity__c=3.0, Product_Code__c='ABC123', Material_Description__c='Material Description', Material_Code__c='CMC', End_Date__c=date.today()+5, Active__c = True);      
        Product_Materials__c productMaterials3 = new Product_Materials__c(Start_Date__c=date.today()-5, Quantity__c=3.0, Product_Code__c='123456', Material_Description__c='Material Description', Material_Code__c='CMC', End_Date__c=date.today()+5, Active__c = True);
        // CHI 2011 Commission 
        Product_Materials__c productMaterials4 = new Product_Materials__c(Start_Date__c=date.today()-10, Quantity__c=3.0, Product_Code__c='654321', Material_Description__c='Material Description', Material_Code__c='CMC', End_Date__c=date.today()+10, Active__c = True);
        Product_Materials__c productMaterials5 = new Product_Materials__c(Start_Date__c=date.today()-10, Quantity__c=3.0, Product_Code__c='654321', Material_Description__c='Material Description2', Material_Code__c='CMC2', End_Date__c=date.today()+10, Active__c = True);    
                    
        Product_Materials__c[] productMaterialsList = new Product_Materials__c[]{productMaterials1,productMaterials2,productMaterials3, productMaterials4, productMaterials5};        
        insert productMaterialsList;
    }
}