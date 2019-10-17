@istest(SeeAllData=true)
public with sharing class TestClassHelper {
    
    public static Account  createAccout()
    {
         Account acc = new Account(name = 'Water hardness test', BillingStreet='Test', 
                                  BillingPostalCode='SW19 6DZ', BillingCity='Test', 
                                  BillingCountry='Test', BillingState='Test');
                                  
        return acc;
    }
    
    public static Contact  createContact(Account acc)
    {
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=acc.Id,Salutation='Mr'); 
                                  
        return contact;
    }
    
    public static Opportunity  createCHILead(Account Acc)
    {
        Campaign newCampaign = TestClassHelper.createCampaign();
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        return opty;
    }
 //Change by BGSAMS support on 25/01/2012 to avoid failure of TestJobCreateTriggerSetDistrict class due to the code fix added in Trigger JobBeforeInsertUpdate to prevent duplicate jobs in case of preallocation scenario job insertion -  PRB00006300 starts   
 //The below function can be used in case multiple CHILEADS need to be created as TEST DATA
    public static List<Opportunity> createMultipleCHILead(Account Acc, Integer manyopps)
    {
        Campaign newCampaign = TestClassHelper.createCampaign();
        insert newCampaign; 
        List<Opportunity> opporlist = new List<Opportunity>(); 
        for(Integer i = 0; i < manyopps; i++) 
         {      
         Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
         opporlist.add(opty);
         }       
        return opporlist;
    } 
        public static List<Job__c> createMultipleJobs(string status, string substatus,  Opportunity[] optyId, Integer howMany){
        
        List<Job__c> joblist = new List<Job__c>(); 
        for(Integer i = 1; i < howMany; i++)
        {
            
            Job__c job1 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID[i].id);
            jobList.add(job1);
        }                              
        return joblist;
    } 
 //Change by BGSAMS support on 25/01/2012 to avoid failure of TestJobCreateTriggerSetDistrict class due to the code fix added in Trigger JobBeforeInsertUpdate to prevent duplicate jobs in case of preallocation scenario job insertion -  PRB00006300 Ends   
    
    public static Campaign  createCampaign()
    {
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        return newCampaign;         
    }
    
    public static BigMachines_Quote__c  createBMQuote(Opportunity opty)
    {
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Commissionable_Sales_Value__c = 300.00, Non_Commission_Sales_Value__c = 100.00 ,Transferred_to_Premier__c = null, Line_Items_Decompiled__c = true, Is_Primary__c = true, Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                   
        return quote;        
    }
    
    public static Job__c  createJob(string status, string substatus, ID optyId, string District)
    {
        Job__c job = new Job__c(District__c = District , Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=0,Unvented_Hot_Water_Hours__c=0,Specialist_Building_Hours__c=0,Scaffolder_Hours__c=0,Roof_Work_Hours__c=0,Payment_Collection_Hours__c=0,Mechanical_Hours__c=0,LPG_Installation_Hours__c=0,Fire_Wall_Heater_Fixing_Hours__c=0,Electrical_Hours__c=0,Contractor_Installation_Hours__c=0,Connect_Solar_Panel_Hours__c=0,Building_Work_Hours__c=0,PowerFlush_Hours__c=0,Electrical_Work_ASP_Hours__c=0,Asbestos_Removal_Hours__c=0,Asbestos_Removal_Fixed_Rate_Hours__c=0,Solar_Hours__c=0);
        return job;
    }
    
    public static District__c  createDistrict()
    {
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        return district;
    }
    
     
     public static Idea createidea(id userid)
    {
        Idea ida = new Idea(Status='closed', Title='Hi we are',District__c='Angila',On_Behalf_Of__c=userid);      
        return ida;
    }
     
    
    public static Appointment__c  createAppointment(Opportunity opp,Id employeeid, Id userid,Id recordTypeId, id who)
    {
        Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
        Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
        Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 8, 0, 0);
        Appointment__c app = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = 'createNewAppt() Test', 
                                 Assigned_To__c = employeeid, OwnerId = userid,
                                 Any_Time__c = false, Description__c = 'createNewAppt() description',
                                 Converted_Visit_Type__c = true,
                                 Do_Not_Send_To_Premier__c = true,
                                 Mode__c = 'Installation', Overbooked__c = false,
                                 RecordTypeId = recordTypeId,
                                 Resource_Type__c = 'A', 
                                 Sale_Flag__c = true, Show_Time_As__c = 'Busy',
                                 Status_Reason__c = 'INFORMATION PROVIDED', Status__c = 'Appointed',
                                 Time_Band__c = 'AM', Type__c = 'Sales',
                                 Visit_Type__c = 'First Visit', Opportunity__c = opp.id,
                                 Who__c = who);
        return app;
    }
    public static Employee__c createEmployee()
    {
        Employee__c emp = new Employee__c(First_Name__c = 'emp', Last_Name__c = 'emp', Employee_Number__c = (''+ '1991'));
        return emp;
    }
    
    public static User createUser()
    {
        Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                    Email = 'a1@b.com', Username='user123454321@testorg.com',
                                    ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                    Migration_ID__c = 'user1@hotmail.com',
                                    TimeZoneSidKey = 'Europe/London', 
                                    LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US',IsActive = true);
        return user;
    }
    
    public static Consumables__c createCosumable()
    {
        Consumables__c cosumable = new Consumables__c (Product_Code__c = 'test Product', Status__c = 'Active');
        return cosumable;
    }
    
    public static Consumables_Requests__c createCosumableRequest(id empId)
    {
        Consumables_Requests__c c = new Consumables_Requests__c(Employee__c =empId , Employee_ID__c ='0123454' );
        return c;
    }
    
    public static Consumable_Items__c createCosumableItem(Id cosumableId,id cRId )
    {
        Consumable_Items__c item = new Consumable_Items__c(Item_Requested__c = cosumableId, Quantity__c = 1, Request__c = cRId);
        return item;
    }
    
    public static BGS_Payment__c createBGSPayment(id OppId, string PaymentType, id Contactid)
    {
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=OppId,Contact__c=Contactid,Payment_Method__c=PaymentType);
        return payment;
    }
    public static Attachment createAttachemnt(string ParentId)
    {
        Attachment att = new Attachment(Body = Blob.valueOf('FFFFFF'),ContentType = 'application/pdf',Name = '1234554321.pdf',ParentId = ParentId);
        return att;
    }
    public static Region__c createRegion()
    {
        Region__c region= new Region__c(Name = 'test',CodE__c = 'testcode');
        return region;
    }
    
    public static RMT_Supplier__c createRMTSupplier()
    { 
        RMT_Supplier__c RMTSupplier = new RMT_Supplier__c (Name = 'Test1', Supplier_Number__c = '111b', P5_Business_Stream__c = 'CHI', Supplier_Status__c = 'Active', 
                                            Supplier_Contact_Name__c = 'Phil Dennison', Telephone__c = '07789571350', Supplier_Email__c = 'phil.dennison@centica.com');
        return RMTSupplier;
    }
    
    public static P5_RMT_Contractors__c createContractor()
    {        
        P5_RMT_Contractors__c Contractor = new P5_RMT_Contractors__c (P5_First_Name__c = 'FirstName', P5_Last_Name__c = 'LastName', 
                                                P5_Status__c = 'Active', Resource_ID__c = '123456b');
        return Contractor;
    }
    
    public static Supplier__c createSupplier()
    {
        Supplier__c Supplier = new Supplier__c (Supplier_Num__c = '111b');
        return supplier;
    }
    
    public static ProductHolding__c createProductHodling(id AppId)
    {
        ProductHolding__c prodHolding= new ProductHolding__c(Account__c = AppId, ServiceCover__c = 'HomeCare200', GasPaymentMethod__c = 'Cash', GasMonthlySpend__c = 100.00, GasIsCurrentCustomer__c = true, GasAnnualSpend__c = 100.00, ElectricityPaymentMethod__c = 'Credit Card', ElectricityMonthlySpend__c = 100.00, ElectricityIsCurrentCustomer__c = true,
                                                  ElectricityAnnualSpend__c = 100.00, CreditRating__c = 'Excellent', Status__c = 'Current' );
        return prodHolding;
    }
    
    public static ProductHoldingAccount__c createProductHodlingAcnt(id PrdId)
    {
        ProductHoldingAccount__c prodHoldingAct= new ProductHoldingAccount__c(ProductHolding__c =PrdId,Type__c = 'Gas', MonthlySpend__c = 123, PaymentMethod__c = 'Cash'  );
        return prodHoldingAct;
    }
    
    public static ASP__c createAsp(ID quoteId)
    {
        ASP__c asp = new ASP__c(Charge_to_Customer__c=0,Quote__c=quoteId, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today());
        return  asp;
    }
    public static Green_Deal_Questions__c createGDPreQual(id JobId, Id OpportunityId)
    {
        Green_Deal_Questions__c  gdPq = new Green_Deal_Questions__c(Job__c = JobId, CHI_Lead__c = OpportunityId);
        return gdPq;
        
    }
    
    public static Commissioning_Report__c createJobCompletionDoc(id recordType, id Job)
    {
        Commissioning_Report__c jcd = new Commissioning_Report__c(Job_Number__c = Job, RecordTypeId =recordType, Status__c = 'Incomplete' );
        return jcd;
    }
    
    
    
    public static Week__c createWeek(Id EmployeeId)
    {
        Week__c week = new Week__c (Employee__c = EmployeeId);
        
        return week;
    }
    
    public static Quote_Product__c createQuoteProduct(id bmQuoteId)
    
    {
    	return new Quote_Product__c(BigMachines_Quote__c = bmQuoteId, 	Name = 'CBLR001', Quantity__c=1);
    }
    
    public static Diary_Entry__c createDe(string weekid, string Type)
    {
    	return new Diary_Entry__c(Week__c = weekid, RecordTypeId = Type );
    }
    
    
    public static Sub_Patch__c createSubPatch(id disrictId)
    {
    	return (new Sub_Patch__c(District__c =disrictId, Type__c = 'Sales', Code__c= 'T01' ));
    }
    
    public static PostCode_Sector__c createPostCode(id subPatchId)
    {
    	return (new PostCode_Sector__c(Sub_Patch__c =subPatchId, Type__c = 'Sales', Name ='AB1 1' ));
    }
    
    public static Role__c createHSARole(id EmpId)
    {
    	return (new Role__c(Employee__c =EmpId, Type__c = 'HSA', Start_Date__c = system.today().adddays(-50).tostartofweek(), End_Date__c= system.today().adddays(100).tostartofweek()  ));
    }
    
    public static Role_Sub_Patch__c createRoleSubPatch(id RoleId, Id SubPatchId)
    {
    	return (new Role_Sub_Patch__c(Role__c =RoleId, Sub_Patch__c = SubPatchId, Type__c = 'Availability', Start_Date__c = system.today().adddays(-50).tostartofweek(), End_Date__c= system.today().adddays(100).tostartofweek() )); 
    }
    	
    
    
    
}