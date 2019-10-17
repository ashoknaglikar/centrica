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
 /*
    Type Name: QuoteProductDecompileHelper_Test.
    Author: Cognizant
    Created Date: 01/09/2010
    Reason: This class is test class for  QuoteProductDecompileHelper class.            
    Change History:
    29/11/10 - Added Test for changes done for 2011 CHI Commission Scheme changes. 
*/
 
@isTest
private class QuoteProductDecompileHelper_Test {
    private static id[] productorderIds;
    private static id distirictId;
   @istest           
    static void TestASPSubmission(){   
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
        ASP__c asp = new ASP__c(Charge_to_Customer__c=0,Quote__c=quote[0].Id, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today(), ASP_Installation_Date__c=date.today());
        asp.Status__c='Entered'; 
        
        insert asp;
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
                     
        Product2[] Products = new Product2[]{Prod1,Prod2, Prod3};           
        insert Products;
        
        id[] ASPId = new list<id>();
             

        Quote_Product__c lineItem = new Quote_Product__c(Part_Number__c='123456', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123456', product__c = Prod3.Id);                              
        insert lineItem;        
        
        //Add line items related to the ASP
        Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='ABC123', product__c = Prod1.Id);        
        Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='654321', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='654321', product__c = Prod2.Id);   
                             
        Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2};           
        insert lineItems;             
        
         String[] QProducts = new String[]{lineItem.Id, lineItem1.Id,lineItem2.Id};
        
        //update existing line item to remove as part of ASP
        ASPId.add(asp.Id);
        lineItem.ASP__c=asp.Id;
        lineItem.Name='123456';
        lineItem.ASP_Status__c='Entered';
        lineItem.ASP_Reason__c='Removed';
        lineItem.ASP_Action__c='Remove Parts and Hours'; 
        lineitem.ASP_Impact__c=0;
        update lineItem;  
        
     //   delete asp;
        ASP__c asp1 = new ASP__c(Charge_to_Customer__c=0,Quote__c=quote[0].Id, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today(), ASP_Installation_Date__c=date.today());
        asp1.Status__c='Entered';
        insert asp1;
        
        ASPId.add(asp1.Id);
        lineItem1.ASP__c=asp1.Id;
        lineItem1.ASP_Status__c='Entered';
        lineItem1.ASP_Reason__c='Removed';
        lineItem1.ASP_Action__c='Remove Parts Only'; 
        lineItem1.ASP_Impact__c=0;
        update lineItem1;
        
   //     delete asp1;
        ASP__c asp2 = new ASP__c(Charge_to_Customer__c=0,Quote__c=quote[0].Id, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today(), ASP_Installation_Date__c=date.today());
        asp1.Status__c='Entered';
        insert asp2;
        ASPId.add(asp2.Id);
        //ASPId[2] = asp2.Id;
        lineItem2.ASP__c=asp2.Id;
        lineItem2.ASP_Status__c='Entered';
        lineItem2.ASP_Reason__c='Removed';
        lineItem2.ASP_Action__c='Remove Hours Only'; 
        lineItem2.ASP_Impact__c=0;
        update lineItem2;
        
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
        
        String ASPQuote = quote[0].Id;
        List<ID> quoteProductsRemovedIDs = new List<ID>();
        quoteProductsRemovedIDs.add(lineItem.Id);
        quoteProductsRemovedIDs.add(lineItem1.Id);
        quoteProductsRemovedIDs.add(lineItem2.Id);
        
        list<Job_Element__c> jobElementsToRemove = new List<Job_Element__c>();
        jobElementsToRemove.add(JE1);
        quoteProductsRemovedIDs.add(lineItem.Id);
        List<ID> qpRemovePartsAndHours = new List<ID>();
        List<ID> qpRemoveParts = new List<ID>();
        List<ID> qpRemoveHours = new List<ID>();
        qpRemovePartsAndHours.add(lineItem.Id);
        qpRemoveParts.add(lineItem1.Id);
        qpRemoveHours.add(lineItem2.Id);        
        map<string, Quote_Product__c> quanMap = new map<string, Quote_Product__c> {'ABC123'=> lineItem1};
         QuoteProductDecompileHelper.returnJobElements(asp1,quoteProductsRemovedIDs,jobElementsToRemove,qpRemoveParts,qpRemoveHours,qpRemovePartsAndHours,quanMap);
         
          // 2011 CHI Commission Scheme changes
         BigMachines_Quote__c triggerQuote = [Select b.X2011_Commission_Sales_value__c , b.Projected_Commissionable_Margin__c, b.Consider_for_Installation_Planning__c, b.Average_Material_Cost_Quote__c, b.Average_Labour_Cost_Quote__c, b.Is_Primary__c, b.finalPriceVisibleToCustomer__c, b.quote_reconciled__c, b.Line_Items_Decompiled__c, b.skillTotalWaterHeatingFixing__c, b.skillTotalUnventedHotWater__c, b.skillTotalSpecialistBuilding__c, b.skillTotalSolar__c, b.skillTotalScaffolder__c, b.skillTotalRoofWork__c, b.skillTotalPowerFlush__c, b.skillTotalPaymentCollection__c, b.skillTotalMechanical__c, b.skillTotalLPGInstallation__c, b.skillTotalFireWallHeaterFixing__c, b.skillTotalElectrical__c, b.skillTotalContractorInstallation__c, b.skillTotalConnectSolarPanels__c, b.skillTotalBuildingWork__c, b.skillTotalAsbestosRemoval__c,isSystem__c, b.skillTotalAsbestosRemovalFixedRate__c, b.SkillTotalElectricalWorkASP__c, b.skillTotal_ecogenElectrical__c, b.skillTotal_ecogenMechanical__c, b.ASP_after_Billed__c,b.stage__c,b.Charge_to_Cutomer_after_Billed__c,b.Billed__c,
         CS_Allowance_1__c,CS_Allowance_2__c,CS_Allowance_3__c,CS_Allowance_4__c,CS_Allowance_5__c,CS_Allowance_6__c, appliedAmount1__c, appliedAmount2__c, appliedAmount3__c, appliedAmount4__c, appliedAmount5__c , appliedAmount6__c,Non_Commissionable_sales_value__c From BigMachines_Quote__c b where Id=:quote[0].Id];
         list<Quote_Product__c> quoteProductsRelatingToASP = [Select Id, ASP_Status__c, Supplier__c, Exclude_Decomposition__c,Quantity__c, Part_Number__c, ASP_Reason__c, ASP_Action__c, User_Defined_Product__c, Product_Description__c, Supplier__r.Name, Supplier__r.Supplier_Num__c,Commission_Value__c,Non_Commision_Pack__c, Sales_Order_Value__c, Unit_Merchant_Price_Exc_VAT__c, User_Defined_Description__c From Quote_Product__c where Id IN:QProducts];
         
         QuoteProductDecompileHelper.calculatePCM(triggerQuote, quoteProductsRelatingToASP,1);
         QuoteProductDecompileHelper.calculatePCM(triggerQuote, quoteProductsRelatingToASP,0);
                 
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
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, quote_reconciled__c=true, CS_Allowance_1__c = cs.Id,CS_Allowance_2__c = cs.Id,CS_Allowance_3__c = cs.Id,CS_Allowance_4__c = cs.Id,CS_Allowance_5__c = cs.Id,CS_Allowance_6__c = cs.Id, appliedAmount1__c = 100, appliedAmount2__c = 200 , appliedAmount3__c = 100 , appliedAmount4__c = 100 , appliedAmount5__c = 50 , appliedAmount6__c = 100 );           
        if(num==2)
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Commissionable_Sales_Value__c = 300.00, Non_Commission_Sales_Value__c = 100.00 ,Transferred_to_Premier__c = null, Line_Items_Decompiled__c = true, Is_Primary__c = true, Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2,
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
                      
        Avg_Skill_Rate__c[] SkillRates = new Avg_Skill_Rate__c[]{SkillRate1,SkillRate2};        
               
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
        Product_Work_Code__c productWorkCode3 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='Mechanical', Skill_Type__c='Work', Product_Code__c='123456', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode4 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='Electrical', Skill_Type__c='Work', Product_Code__c='654321', Hours__c=0.45, End_Date__c=date.today(), Active__c = True); 
        // CHI 2011 Commission 
        Product_Work_Code__c productWorkCode5 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today()- 10, Skill__c='Electrical', Skill_Type__c='Electrical', Product_Code__c='654321', Hours__c=0.45, End_Date__c=date.today() + 10, Active__c = True);
        Product_Work_Code__c productWorkCode6 = new Product_Work_Code__c(Work_Code__c='123457', Work_Code_Description__c='Description', Start_Date__c=date.today()- 10, Skill__c='MECHANICAL', Skill_Type__c='MECHANICAL', Product_Code__c='654321', Hours__c=0.45, End_Date__c=date.today() + 10, Active__c = True);
               
        Product_Work_Code__c[] productWorkCodeList = new Product_Work_Code__c[]{productWorkCode1,productWorkCode2,productWorkCode3,productWorkCode4, productWorkCode5, productWorkCode6};        
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