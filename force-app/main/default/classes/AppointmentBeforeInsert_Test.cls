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
private class AppointmentBeforeInsert_Test {
    
    

     static Order__c orders;
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Appointment__c app;
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
    static String itineraryEvtRecTypeId = '';
    static String itineraryApptRecTypeId = '';
    static Datetime startTime;
    static Datetime endTime;
    static Datetime now;
    //static Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
    static void preparedata() {
        //TestEventAndAppointmentSynchronisation.Setup s = 
                                       // new TestEventAndAppointmentSynchronisation.Setup();
        now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
        startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 6, 0, 0);
        endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 21, 0, 0);
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
                    else if (rt.Name=='Itinerary') 
                        itineraryEvtRecTypeId=rt.id;
                    else
                        appointmentEvtRecTypeId = rt.Id;
                } else if(rt.sObjectType == 'Appointment__c'){
                    if(rt.Name == 'Available')
                        availableApptRecTypeId = rt.Id;
                    else if(rt.Name == 'Unavailable')
                        unavailableApptRecTypeId = rt.Id;
                    else if (rt.Name=='Installation') 
                        installtionApptRecTypeId=rt.id;
                     else if (rt.Name=='Itinerary') 
                        itineraryApptRecTypeId=rt.id; 
                    else
                        appointmentApptRecTypeId = rt.Id;                   
                }
            }
        String recordTypeId = appointmentApptRecTypeId; // Other options available
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        Campaign camp = new Campaign(Source__c = 'MC', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
        
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp};                                          
        insert employees;
        
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
        Opportunity opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                CampaignId = camp.Id, LeadSource='Engineer');
                                                        
       Database.insert(opp);  
 
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c='test Employee - 100101111e',
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        /*quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;*/
                
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        //District__c district = [Select id from District__c limit 1];
                
       
       
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job;
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
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
                                 Who__c = who);
                                 
    }
           //insert app;
           
           
           
           /*upupdate app;
           app.Start__c=Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 17, 0, 0);
           update app;
           app.Start__c=Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 7, 0, 0);
           app.End__c=Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 21, 0, 0);
           update app;*/
           static testmethod  void StartCondition1()
           {
            preparedata();
            insert app;
           } 
           static testmethod  void StartCondition2()
           {
            preparedata();
            startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 13, 0, 0);
            endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 21, 0, 0);
            app.Start__c=startTime;
            //system.debug('app.Start__c--'+app.Start__c);
            insert app;
            //system.debug('app.Start__c2'+app.Start__c);
           }
           static testmethod  void StartCondition3()
           {
            preparedata();
            startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 17, 0, 0);
            endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 21, 0, 0);
            app.Start__c=startTime;
            //system.debug('app.Start__c--'+app.Start__c);
            insert app;
            //system.debug('app.Start__c2'+app.Start__c);
           }
           static testmethod  void StartCondition4()
           {
            preparedata();
            startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 7, 0, 0);
            endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 21, 0, 0);
            app.Start__c=startTime;
            app.End__c=endTime;
            //system.debug('app.Start__c--'+app.Start__c);
            insert app;
            //system.debug('app.Start__c2'+app.Start__c);
           }
           
           
           
           
           
           
                                                                                                                 
                                                
                                                   
    
}