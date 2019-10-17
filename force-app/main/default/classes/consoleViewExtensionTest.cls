// This class contains unit tests for validating the behavior of Apex class consoleViewExtension.cls
// Harry Dhanoa(Westbrook) 21st June 2015

@isTest
private class consoleViewExtensionTest {

    public static testmethod void homeVisitBooked() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        o.Date_time_appointment_booked__c = date.today();
        update o;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        system.assertEquals(controller.progressBarStatusPicName, '1.png');  
    }

    
    public static testMethod void homeVisitComplete() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=Acc.Id,Salutation='Mr');
        insert contact;
        Supplier__c supplier = new Supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '2991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        insert emp;
        Datetime startTime;
        Datetime endTime;
        Datetime now;
         String who = contact.id;
         now = system.today();  
         startTime = Datetime.newInstance(system.today().year(), system.today().month(), system.today().day()+7, 13, 0, 0);
         endTime = Datetime.newInstance(system.today().year(), system.today().month(), system.today().day()+7, 21, 0, 0);                                            
         Appointment__c app = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = 'Test', 
                                 Assigned_To__c = emp.id, OwnerId = user.id,
                                 Any_Time__c = false, Description__c = 'Test desc',Converted_Visit_Type__c = false,
                                 Do_Not_Send_To_Premier__c = false,Mode__c='Installation',Overbooked__c = true,
                                 Resource_Type__c ='A',Sale_Flag__c = false,Show_Time_As__c= 'Busy',Time_Band__c = 'AM',Visit_Type__c ='First Visit',
                                 Status_Reason__c = 'Purchase Elsewhere', Status__c ='Happened',
                                 Type__c = 'Sales', Opportunity__c = o.id,
                                  Who__c = who
                                 ); 
                                
         app.Big_Machines_Quote_Number__c = 'Test Quote 1';
                                             
         insert app;

        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        system.assertEquals(controller.progressBarStatusPicName, '0.png');  
    }
   
    public static testMethod void quoteIssued() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = o.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Not Accepted',bmStatusReason__c='Quote Finalised - Not Accepted',geographicUpliftFactor__c=2);                           
        insert quote; 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        system.assertEquals(controller.progressBarStatusPicName, '3.png');  
    }
    
    public static testMethod void quoteAccepted() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = o.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                           
        insert quote; 
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        system.assertEquals(controller.progressBarStatusPicName, '4.png');  
    }

    public static testMethod void installArranged() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        BigMachines_Quote__c quote = TestScenarioCreateQuote(o);  
        Job__c job = TestScenarioCreateJob('Planned','Install Date Required',o.ID,quote.Id);
        
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
        insert week;
        
        Diary_Entry__c[] deList = new List<Diary_Entry__c>();
        deList.add(new Diary_Entry__c (Employee__c=emp.Id,Week__c=week.Id,job__c=job.Id,Sub_Type__c='Mechanical'));
        deList.add(new Diary_Entry__c (Employee__c=emp.Id,Week__c=week.Id,job__c=job.Id,Sub_Type__c='Electrical'));
        insert deList;
        
        //system.debug('>>>>>'+deList);
        //system.debug('>>>>>'+[SELECT Job__c,Employee_Name__c,Sub_Type__c  
        //                                      FROM Diary_Entry__c 
        //                                      WHERE Sub_Type__c='Mechanical' or  Sub_Type__c='Electrical']);
        //system.debug('>>>>>'+[SELECT Delivery_Slot__c, Delivery_Date__c,Installation_Date__c, 
        //                                    Scaffolding_Required__c, DHM_Name__c, DHM_Phone__c,
        //                                    (SELECT Employee_Name__c,Sub_Type__c  
        //                                      FROM Diary_Entries__r 
        //                                      WHERE Sub_Type__c='Mechanical' or  Sub_Type__c='Electrical') 
        //                              FROM    Job__c j 
        //                              WHERE   Is_Remedial_Job__c = false and  
        //                                      Is_Downtime_Job__c = false and 
        //                                      CHI_Lead__c = :o.Id LIMIT 1]);
                        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        system.assertEquals(controller.progressBarStatusPicName, '5.png');  
    }

    public static testMethod void installCompleted() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        BigMachines_Quote__c quote = TestScenarioCreateQuote(o);  
        Job__c job = TestScenarioCreateJob('Installed','Install Date Required',o.ID,quote.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        system.assertEquals(controller.progressBarStatusPicName, '6.png');  
    }

    public static testMethod void finalPayment() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=Acc.Id,Salutation='Mr'); 
        insert contact; 
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=o.Id,Contact__c=contact.Id, Payment_Type__c='Balance Payment');
        insert payment;
        
        BigMachines_Quote__c quote1 = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Is_Primary__c = true , Opportunity__c = o.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Not Accepted',bmStatusReason__c='Quote Finalised - Not Accepted',geographicUpliftFactor__c=2);                           
        insert quote1; 
        
        Product2 product = new Product2(ProductCode='CBLRAS', Name='CBLRAS', BigMachines_Part_Number__c='CBLRAS',  IsActive = true, Guarantee__c=true, Description ='something'); 
                insert product;
                
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                Materials__c=true,Labour__c=false,Part_Number__c='CBLRAS', BigMachines_Quote__c=quote1.Id,Merchant_Price__c=307,
                Name='CBLRAS',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4', installationNotes__c= 'test notes');
                insert quoteProduct;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        system.assertEquals(controller.homeCare, 'something');   
        system.assertEquals(controller.progressBarStatusPicName, '7.png');  
    }

    public static testMethod void npsReceived() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        
        Note n = new Note(Body = 'Name is Bond....', ParentId=o.Id, title='New Note from code');
        insert n;
        
        RecordType RcdTypId = [Select r.Id From RecordType r where r.Name='Dispute'and sObjectType = 'Case']; 
        Case caseObj = new Case();
        caseObj.RecordTypeId=RcdTypId.Id;
        caseObj.AccountId=Acc.Id;
        caseObj.Subject='Test Case';
        caseObj.Description='Test Desc';
        caseObj.Disputed_Amount__c=100;
        caseObj.Communication_status__c='Awaiting Office';
        caseObj.Case_Source__c='Customer';
        caseObj.Priority='High';
        caseObj.Classification__c='Sales';
        caseObj.Status='New';
        caseObj.Opportunity__c=o.Id;
        insert caseObj;
                
        NPS__c nps=new NPS__c(Step1_Score__c=1,Status__c = 'Step 1',Account__c=Acc.id,Opportunity__c=o.id);
        insert nps;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        controller.knowledgeSearchString = 'something' ;
        
        system.assertNotEquals(controller.progressBarStatusPicName, '8.png');  
    }
    
    public static testMethod void testMethods() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        controller.knowledgeSearch();
        controller.updateIframeId();
        controller.globalsearch();
        controller.knowledgeSearchString = 'P194';
        controller.globalsearch();
        controller.openNewTask();
        controller.openNewNote();
        controller.numbersBoxList = new List<String>();
        controller.numbersBoxMap= new Map<String,Decimal>();
        system.assertEquals(controller.openAccount().getUrl(), '/'+Acc.Id); 
        system.assertEquals(controller.openLead().getUrl(), '/'+o.Id);
        system.assertNotEquals(controller.openNewCase().getUrl(), '/500/o');
          
    }
   
    public static testMethod void negativeTesting() {
        Account Acc = TestScenarioCreateAccount();
        Opportunity o = TestScenarioCreateOppty(Acc);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(o);    
        PageReference pageRef = Page.ConsoleView;
        Test.setCurrentPage(pageRef);
        //ApexPages.currentPage().getParameters().put('id',o.Id );
        consoleViewExtension controller = new consoleViewExtension(sc);
        //system.assertEquals(controller.hasError, false);  
    }

  
    public static Account TestScenarioCreateAccount(){
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
    
    public static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }
    
    public static BigMachines_Quote__c TestScenarioCreateQuote(Opportunity opty)
    {                
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                           
        insert quote;              
        return quote;    
    }
    
    public static Job__c TestScenarioCreateJob(string status, string substatus, ID optyId, ID quoteId){
        
        Job__c job = new Job__c(Quote__c=quoteId, Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=1,Unvented_Hot_Water_Hours__c=1,Specialist_Building_Hours__c=1,Scaffolder_Hours__c=1,Roof_Work_Hours__c=1,Payment_Collection_Hours__c=1,Mechanical_Hours__c=1,LPG_Installation_Hours__c=1,Fire_Wall_Heater_Fixing_Hours__c=1,Electrical_Hours__c=1,Contractor_Installation_Hours__c=1,Connect_Solar_Panel_Hours__c=1,Building_Work_Hours__c=1,PowerFlush_Hours__c=1,Electrical_Work_ASP_Hours__c=1,Asbestos_Removal_Hours__c=1,Asbestos_Removal_Fixed_Rate_Hours__c=1,Solar_Hours__c=1,Ecogen_Electrical_Hours__c=1,Ecogen_Mechanical_Hours__c=1 , ECO_Hours__c=1, Landlord_Check_Hours__c=1);              
        job.Is_Remedial_Job__c = false;
        job.Is_Downtime_Job__c = false;
        insert job;      
        return job;
    }

    
}