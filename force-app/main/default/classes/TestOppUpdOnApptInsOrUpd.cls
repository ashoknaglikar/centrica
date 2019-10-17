/*
This code is duplicate is not needed as we already have 
OppUpdOnApptInsOrUpd_Test

*/

@istest
public class TestOppUpdOnApptInsOrUpd {
   /*
    static Order__c orders;
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Opportunity opp;
    static Appointment__c app, app1;
    static Employee__c emp;
    static Employee_Skills__c empSkill1;
    static Employee_Skills__c empSkill2;
    static Employee_Skills__c empSkill3;
    static Employee_Skills__c empSkill4;
    static Employee_Skills__c empSkill5;
    static Employee_Skills__c empSkill6;
    static Employee_Skills__c empSkill7;
    static Employee_Skills__c empSkill8;
    static Employee_Skills__c empSkill9;
    static Employee_Skills__c empSkill10;
    static Employee_Skills__c empSkill11;
    static Employee_Skills__c empSkill12;
    static Employee_Skills__c empSkill13;
    static Employee_Skills__c empSkill14;
    static Employee_Skills__c empSkill15;
    static Employee_Skills__c empSkill16;
    static Employee_Skills__c empSkill17;
    static Employee_Skills__c empSkill18;
    static Employee_Skills__c[] empSkills;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opportunity;
    //static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Product2 product;
    static Quote_Product__c quoteProduct;
    static Job__c job;
    static SFPO7523_Batch__c objBatch;
    static SFPO7523_Order_Header__c objHeader;
    static Order__c ord;
    static List<Order__c> orderlist;
    static String availableApptRecTypeId = '';
    static String unavailableApptRecTypeId = '';
    static String availableEvtRecTypeId = '';
    static String unavailableEvtRecTypeId = '';
    static String appointmentApptRecTypeId = '';
    static String appointmentEvtRecTypeId = '';
    static String installtionEvtRecTypeId = '';
    static String installtionApptRecTypeId = '';
    //static Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
    static  void createTestData() {
        //TestEventAndAppointmentSynchronisation.Setup s = 
                                       // new TestEventAndAppointmentSynchronisation.Setup();
        Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
        Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
        Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 8, 0, 0);
        String subject = 'createNewAppt() Test';
        Boolean anyTime = false; // Also: True
        Boolean convertedVisitType = true; // Or False
        String description = 'createNewAppt() description';
        Boolean doNotSendToPremier = false; // Also: true
        Boolean allDayEvent = false; // Also: True
        Datetime lastSentToPremier = Datetime.now();
        String mode = 'SU'; // Other options available
        mode = 'Installation';
        Boolean overbooked = True; // Also: True
        String resourceType = 'A';
        Boolean sale = false; // Also: True
        String showTimeAs = 'Busy'; // Also: Out of Office, Free
        String statusReason = 'INFORMATION PROVIDED'; // Other options available
        String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
        String timeBand = 'AM'; // Also: PM, EV, AT
        String typeC = 'Survey'; // Other options available
        String visitType = 'First Visit'; // Also: Recall Visit, Pickup
      
        String postcodeSector = 'SE3 9';
         RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];

            for(RecordType rt : recordTypes) {
                if(rt.sObjectType == 'Event') {
                    if(rt.Name == 'Available')
                        availableEvtRecTypeId = rt.Id;
                    else if(rt.Name == 'Unavailable')
                        unavailableEvtRecTypeId = rt.Id;
                    else if (rt.Name=='Installation') 
                        installtionEvtRecTypeId=rt.id;
                    else
                        appointmentEvtRecTypeId = rt.Id;
                } else if(rt.sObjectType == 'Appointment__c'){
                    if(rt.Name == 'Available')
                        availableApptRecTypeId = rt.Id;
                    else if(rt.Name == 'Unavailable')
                        unavailableApptRecTypeId = rt.Id;
                    else if (rt.Name=='Installation') 
                        installtionApptRecTypeId=rt.id; 
                    else
                        appointmentApptRecTypeId = rt.Id;                   
                }
            }
        String recordTypeId = appointmentApptRecTypeId; // Other options available
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City',Landlord_Account__c=true);
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr',Contact_Type__c='Landlord'); 
           
        
        insert contact;  
        Campaign camp = new Campaign(Source__c = 'MC', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
        
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        Profile p = [SELECT p.ID FROM profile p WHERE Name='System Administrator' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',UsesBM__c=true);
        
        employees = new Employee__c[]{emp};                                          
        insert employees;
        
        District__c TestSalesDistrict = new District__c(Type__c='Sales', Name='P1Controller_SalesDistrict', Code__c='xxxxxxxx');
        insert TestSalesDistrict;
        
        Sub_Patch__c TestSalesSubPatch = new Sub_Patch__c(Type__c='Sales',Name='P1Controller_SalesSubpatch', District__c=TestSalesDistrict.Id, Code__c='xxxxxxxx',Appointment_Source__c='OFS',OFS_Bucket_Name__c=emp.id,OFS_Start_Date__c=Date.today());
        insert TestSalesSubPatch;
        
        account.Sales_Subpatch__c = TestSalesSubPatch.id;
        update account;
        
        
        
        empSkill1 = new Employee_Skills__c(Skill_Name__c = 'LPG Installation', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill2 = new Employee_Skills__c(Skill_Name__c = 'Roof Work', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill3 = new Employee_Skills__c(Skill_Name__c = 'Building Work', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill4 = new Employee_Skills__c(Skill_Name__c = 'Connect Solar Panels', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill5 = new Employee_Skills__c(Skill_Name__c = 'Contractor Installation', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill6 = new Employee_Skills__c(Skill_Name__c = 'Electrical', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill7 = new Employee_Skills__c(Skill_Name__c = 'Mechanical', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill8 = new Employee_Skills__c(Skill_Name__c = 'Payment Collection', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill9 = new Employee_Skills__c(Skill_Name__c = 'Scaffolder', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill10 = new Employee_Skills__c(Skill_Name__c = 'Specialist Building', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill11 = new Employee_Skills__c(Skill_Name__c = 'Unvented Hot Water', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill12 = new Employee_Skills__c(Skill_Name__c = 'Powerflush', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill13 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill14 = new Employee_Skills__c(Skill_Name__c = 'WATER HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill15 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill16 = new Employee_Skills__c(Skill_Name__c = 'Asbestos Removal', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill17= new Employee_Skills__c(Skill_Name__c = 'Survey', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill18= new Employee_Skills__c(Skill_Name__c = 'Waste Collection', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        empSkill18= new Employee_Skills__c(Skill_Name__c = 'Sales', Own_Jobs_Only__c = true,Employee__c =employees[0].id);
        
        empSkills = new Employee_Skills__c[]{empSkill1,empSkill2,empSkill3,empSkill4,empSkill5,empSkill6,empSkill7,empSkill8,empSkill9,empSkill10,empSkill11,empSkill12,empSkill13,empSkill14,empSkill15,empSkill16,empSkill17,empSkill18}; 
        insert empSkills;  
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        
        //inserting opportunity with different employee
        //opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  //AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
         opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                CampaignId = camp.Id, LeadSource='Engineer');
                                                        
       Database.insert(opp);  
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=employees[0].Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        /*quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;
                
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
       
       
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp.ID,status__c='Planned',Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job;
        job.Status__c='Planned';
        update job;
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        JE.P5_IsItinerary__c=true;
        insert JE;
    
        
        // Create Appointment
        //Appointment__c app = s.createNewAppt(false, '102 Pitt');    
        String who = contact.id;
        app = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = subject, 
                                 Assigned_To__c = employees[0].id, OwnerId = user.id,
                                 Any_Time__c = anyTime, Description__c = description,
                                 Converted_Visit_Type__c = convertedVisitType,
                                 Do_Not_Send_To_Premier__c = doNotSendToPremier,
                                 Mode__c = mode, Overbooked__c = overbooked,
                                 RecordTypeId = recordTypeId,
                                 Resource_Type__c = resourceType, 
                                 Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
                                 Status_Reason__c = statusReason, Status__c = status,
                                 Time_Band__c = timeBand, Type__c = typeC,
                                 Visit_Type__c = visitType, Opportunity__c = opp.id,
                                 Who__c = who,Job__c=job.id);
       insert app;
       cls_IsRun.isAppInsertUpdate = false;
       app1 = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = subject, 
                                 Assigned_To__c = employees[0].id, OwnerId = user.id,
                                 Any_Time__c = anyTime, Description__c = description,
                                 Converted_Visit_Type__c = convertedVisitType,
                                 Do_Not_Send_To_Premier__c = doNotSendToPremier,
                                 Mode__c = mode, Overbooked__c = overbooked,
                                 RecordTypeId = recordTypeId,
                                 Resource_Type__c = resourceType, 
                                 Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
                                 Status_Reason__c = statusReason, Status__c = 'Appointed',
                                 Time_Band__c = timeBand, Type__c = 'Sales',
                                 Visit_Type__c = visitType, Opportunity__c = opp.id,
                                 Who__c = who,Job__c=job.id);
       insert app1;
    }
    
    static testmethod void TestAppointment_Appointed()
    {
       createTestData();
       test.starttest();
       opp.Number_of_Sales_Appointments__c=0;
       //opp.Number_of_Sales_Appointments__c= null;
       opp.Number_of_Cancelled_Sales_Appointments__c = null;
       opp.Number_of_Appointed_Sales_Appointments__c =1;
       opp.First_Appointment_Date__c=null;
       update opp;
     
       //**** SALES***\\
       app.Status__c= 'Appointed';
       app.Type__c='Survey';
       
       /*opp.Number_of_Sales_Appointments__c=0;
       //opp.Number_of_Sales_Appointments__c= null;
       opp.Number_of_Cancelled_Sales_Appointments__c = null;
       opp.Number_of_Appointed_Sales_Appointments__c =1;
       opp.First_Appointment_Date__c=null;
       update opp;
       cls_IsRun.isAppInsertUpdate = false;
       
       update app;
       test.stoptest();
       
    }
    
           
         
    static testmethod void TestAppointment_Happened()
    {   
           createTestData();
            test.starttest();           
           //opp.Type__c=='Sales'
           opp.Number_of_Sales_Appointments__c=0;
           opp.Number_of_Appointed_Survey_Appointments__c = 1;
           opp.Number_of_Cancelled_Sales_Appointments__c = null;
           update opp;
           
           //** Happened**\\
           app.Status__c='Happened';    
           cls_IsRun.isAppInsertUpdate = false;
           update app;
           test.stoptest();
    }
    
    static testmethod void Test_Sales_Appointment_Appointed()
    {   
           createTestData();
            test.starttest();           
           //opp.Type__c=='Sales'
           opp.Number_of_Sales_Appointments__c=1;
           opp.Number_of_Appointed_Survey_Appointments__c = 0;
           opp.Number_of_Cancelled_Sales_Appointments__c = null;
           update opp;
           
           //** Happened**\\
           app1.Status__c='Appointed';  
           app1.Type__c='Sales';
           cls_IsRun.isAppInsertUpdate = false;
           update app1;
           test.StopTest();           
    }
    
    static testmethod void TestAppointment_Survey_Cancelled()
    {
        createTestData();
        test.starttest();        
        opp.Number_of_Sales_Appointments__c =2;
        opp.Number_of_Appointed_Survey_Appointments__c=2;
        update opp;
        
        app.Status__c='Cancelled';  
        cls_IsRun.isAppInsertUpdate = false;
        update app;
        test.stoptest();
    }
    
    static testmethod void TestAppointment_Sales_Cancelled()
    {
        createTestData();
        test.starttest();
        opp.Number_of_Sales_Appointments__c =2;
        opp.Number_of_Appointed_Survey_Appointments__c=2;
        update opp;
        app1.Status__c='Cancelled'; 
        cls_IsRun.isAppInsertUpdate = false;
        update app1;
        test.Stoptest();
    }
    
     static testmethod void TestAppointment_populate_tenant_name()
    {
        createTestData();
        test.starttest();
        contact.Contact_Type__c = 'Tenant';
        update contact;      
        app.Tenants_Name__c = null;
        app.Tenants_Email__c = null;        
        update app;  
        test.stopTest();        
    }
    
     static testmethod void TestAppointment_populate_Landlord_name()
    {
        createTestData();
        test.starttest();        
        contact.Contact_Type__c = 'Multi-premise';
        update contact;
        app.Landlords_Name__c = null;
        app.Landlords_Email__c = null;     
        update app;
        test.stopTest();        
    }
   */
}