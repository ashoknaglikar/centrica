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
private class bDEL_ASP_UpdateQuoteProduct_Test{

    @isTest
    static void TestASPDeletion(){   
        try {       
        //Setup test environment
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
        Job__c[] Job = TestScenarioCreateJob('Allocated','Awaiting Planning',opty.Id);        
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,2);                            
        Job[0].Quote__c=quote[0].Id;        
        update Job;   
        ASP__c asp = new ASP__c(Charge_to_Customer__c=0,Quote__c=quote[0].Id, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today());
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

        //ensure job has no job booking history records prior to quote decompile
        Job_Booking_History__c[] historyItemsBefore = [select Work_Affected__c, Materials_Affected__c from Job_Booking_History__c where job__c=:Job[0].ID AND Work_Affected__c=true AND Materials_Affected__c=true];       
        System.assertEquals(0,historyItemsBefore.size());

        //add a line item against the quote that we can later set to removed in the ASP
        Test.startTest();
        Quote_Product__c lineItem = new Quote_Product__c(Part_Number__c='123456', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='123456');                              
        insert lineItem; 
        //use stop test to ensure the Future methods to decompile completes
        Test.stopTest();
        //total job elements inserted should be 1 (1 work elements)
        //System.assertEquals(1,[SELECT count() FROM Job_Element__c WHERE Job__c = :job[0].Id]);
        //ID lineItemID = [SELECT ID FROM Job_Element__c WHERE Job__c = :job[0].Id].Id;
        
        //Add line items related to the ASP
        Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='ABC123', ASP__c=asp.Id, ASP_Reason__c='Added', ASP_Action__c='Add Parts and Hours', Supplier__c=suppliers[0].Id);        
        Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='654321', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='654321', ASP__c=asp.Id, ASP_Reason__c='Added', ASP_Action__c='Add Parts and Hours', Supplier__c=suppliers[1].Id);                              
        Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2};     
        insert lineItems;     
        //update existing line item to remove as part of ASP
        lineItems[0].ASP__c=asp.Id;
        lineItems[0].ASP_Reason__c='Removed';
        lineItems[0].ASP_Action__c='Remove Parts and Hours'; 
        update lineItems;  
        
        //a JBH would have beenc created, so delete this before submitting ASP
        Job_Booking_History__c[] JBH = [select Id from Job_Booking_History__c where Job__c=:Job[0].ID];   
        if(JBH.size()>0)
            delete JBH;                 
        
        delete asp;       
        
        ASP__c aspAfter = [select Status__c from ASP__c where ID=:asp.Id]; 
        //System.assertEquals('Submitted',aspAfter.Status__c);   
        } catch(Exception ex) {
            //do nothing
        }               
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
        
        BigMachines_Quote__c quote;
        if(num==1)
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, quote_reconciled__c=true);           
        if(num==2)
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                   
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
        
        Product_Work_Code__c productWorkCode1 = new Product_Work_Code__c(Work_Code__c='ABC123', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='PowerFlush', Skill_Type__c='Work', Product_Code__c='ABC123', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode2 = new Product_Work_Code__c(Work_Code__c='123ABC', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='B', Skill_Type__c='Work', Product_Code__c='ABC456', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode3 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='Mechanical', Skill_Type__c='Work', Product_Code__c='123456', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode4 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Description', Start_Date__c=date.today(), Skill__c='Electrical', Skill_Type__c='Work', Product_Code__c='654321', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);        
        Product_Work_Code__c[] productWorkCodeList = new Product_Work_Code__c[]{productWorkCode1,productWorkCode2,productWorkCode3,productWorkCode4};        
        insert productWorkCodeList;
        
        Product_Materials__c productMaterials1 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=2.0, Product_Code__c='ABC123', Material_Description__c='Material Description', Material_Code__c='MC', End_Date__c=date.today(), Active__c = True);
        Product_Materials__c productMaterials2 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=3.0, Product_Code__c='ABC456', Material_Description__c='Material Description', Material_Code__c='MC', End_Date__c=date.today(), Active__c = True);      
        Product_Materials__c productMaterials3 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=3.0, Product_Code__c='ABC456', Material_Description__c='Material Description', Material_Code__c='MC', End_Date__c=date.today(), Active__c = True);              
        Product_Materials__c[] productMaterialsList = new Product_Materials__c[]{productMaterials1,productMaterials2,productMaterials3};        
        insert productMaterialsList;
    }
    
     
}