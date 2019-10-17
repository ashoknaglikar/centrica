public class TestOpportunityUpdate {
    static integer empNum = 8798;
    static Order__c orders;
    static Account acc;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Employee__c emp1; //S
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opp;
    //static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Product2 product;
    static Quote_Product__c quoteProduct;
    static Job__c job;
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
    
    static String availableApptRecTypeId = '';
    static String unavailableApptRecTypeId = '';
    static String availableEvtRecTypeId = '';
    static String unavailableEvtRecTypeId = '';
    static String appointmentApptRecTypeId = '';
    static String appointmentEvtRecTypeId = '';
    static String installtionEvtRecTypeId = '';
    static String installtionApptRecTypeId = '';
    static testMethod void updateOpportunityStatus(){
        //TestEventAndAppointmentSynchronisation.Setup s = new TestEventAndAppointmentSynchronisation.Setup();
        
         String suppliernum =  System.now().format('ssSS').substring(1);
        // Create Account
         acc = new Account(name = 'updateOpportunityStatus() acc', BillingStreet='8 Roundacre', 
                                  BillingPostalCode='SW19 6DF', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London');
        
        Database.insert(acc);
        
        Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp); 
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A' + suppliernum,Resource_Type__c='Resource');
        insert supplier;
        Profile p = [select id from Profile where name = 'System Administrator' limit 1];
        User user = new User(LastName = 'us1er1567', Alias = 'use1567', 
                                Email = 'a1cfg@b.com', Username='Smith2testingcfg@user.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1567' + suppliernum + '@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        //userID = user.id;
        emp = new Employee__c(Name = 'testJI3', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '000' + suppliernum,Resource_Id__c=suppliernum + 's2',Resource_Type__c='Installer');
        
        emp1 = new Employee__c(Name = 'testJI3', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0001' + suppliernum,Resource_Id__c=suppliernum + 's3',Resource_Type__c='Installer');
                
        employees = new Employee__c[]{emp,emp1};                                          
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
             
        // Create Free Insulation Postcode
        Free_Insulation_Postcode__c frreInsulPostCode = new Free_Insulation_Postcode__c(Name = 'SW19 6DF' , Start_Date__c = system.today()-2 , End_Date__c = system.today()+20);
        insert frreInsulPostCode;
        
        // Create Opportunity
         opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'updateOpportunityStatus() opp', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
               
        Database.insert(opp);
        String oppId = opp.Id;
        
         contact = new Contact(LastName = 'contact', AccountId = acc.Id);
        Database.insert(contact);
        
        //RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];
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
        Boolean overbooked = false; // Also: True
        String resourceType = 'A';
        Boolean sale = false; // Also: True
        String showTimeAs = 'Busy'; // Also: Out of Office, Free
        String statusReason = 'INFORMATION PROVIDED'; // Other options available
        String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
        String timeBand = 'AM'; // Also: PM, EV, AT
        String typeC = 'Survey'; // Other options available
        String visitType = 'First Visit'; // Also: Recall Visit, Pickup
//      String suppliernum =  System.now().format('ssSS').substring(1);
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
        //String recordTypeId = appointmentApptRecTypeId; 
        
        // Create Appointments
        //Datetime startTime = Datetime.newInstance(2011, 11, 1);
        //Datetime endTime = Datetime.newInstance(2011, 11, 10);
        Appointment__c app1 = new Appointment__c(Start__c = startTime, End__c = endTime,
                                                Subject__c = 'updateOpportunityStatus() subject 1',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',
                                                Who__c = contact.Id, RecordTypeId = appointmentApptRecTypeId);
        
        Appointment__c app2 = new Appointment__c(Start__c = startTime.addDays(5), 
                                                End__c = endTime.addDays(4),
                                                Subject__c = 'updateOpportunityStatus() subject 2',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',
                                                Who__c = contact.Id, RecordTypeId = appointmentApptRecTypeId);
        
        app1.Type__c='Electrical';
        app1.Assigned_To__c = employees[0].id;
        //app2.Assigned_To__c = employees[0].id;
        Appointment__c[] apps = new Appointment__c[]{app1};
        
        System.debug('TestOpportunityUpdate, apps.size(): ' + apps.size());
        
        Database.insert(apps);
        
        // Check Appointment Histories exist
        
        Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
                                                WHERE a.WhatID__c = :opp.Id];
        
        //System.assertEquals(2, appHistories.size());

        // Change Status field on Opportunity
        //opp = [SELECT o.Id, o.StageName FROM Opportunity o WHERE o.Id = :oppId];
        
        Lock.clearAll();
        System.debug('Current stage name: ' + opp.StageName);
        opp.StageName = 'Deposit Taken';
        Database.update(opp);
        
        appHistories.clear();
        // Check for App History, check fields
        appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
                        WHERE a.WhatID__c = :opp.Id];
        
        //System.assertEquals(4, appHistories.size());
        
        // Change again, check another Appointment History inserted, check fields
    }
    
    static testmethod void CheckLeadFieldHistory(){
        Account account = TestClassHelper.createAccout();
        insert account ;
        Opportunity oppo = TestClassHelper.createCHILead(account);
        oppo.Product_Interest__c = 'Oil Boiler';
        insert oppo;
        oppo.Product_Interest__c = 'Solar PV';
        test.startTest();
        update oppo;
        test.stopTest();
    }
}