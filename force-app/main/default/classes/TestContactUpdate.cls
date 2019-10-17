public class TestContactUpdate {
    static integer empNum = 8798;
    static Order__c orders;
    static Account acc;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opp;
    static Campaign camp;
    
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
    static String empNumber;
    static User user;
    
    static void CreateTestData() 
    {
    
         String suppliernum =  System.now().format('ssSS').substring(1);
        // Create Account
         acc = new Account(name = 'updateOpportunityStatus() acc', BillingStreet='8 Roundacre', 
                                  BillingPostalCode='SW19 6DF', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London');
        
        Database.insert(acc);
        
        camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp); 
        
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A' + suppliernum,Resource_Type__c='Resource');
        insert supplier;
        Profile p = [select id from Profile where name = 'System Administrator' limit 1];
        user = new User(LastName = 'us1er1234', Alias = 'use12cfg', 
                                Email = 'a1@b.com', Username='bmsfdcintegration@user.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1234cfg' + suppliernum + '@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        //userID = user.id;            
           empNumber = '1907';
          
            
            List<Employee__c> lstEmp = [select First_Name__c,Employee_Number__c,id from Employee__c where Employee_Number__c =:empNumber limit 1];
            
            if(lstEmp!= null && lstEmp.size() > 0)
            {
                  emp = lstEmp[0];
            }
            else
            {
                emp = new Employee__c(First_Name__c = 'emp', Last_Name__c = 'emp', Employee_Number__c = (''+(empNumber)));
                insert emp;
            }
            system.debug(emp+'****emp***');

        //employees = new Employee__c[]{emp};                                          
        //insert employees;
        
        empSkill1 = new Employee_Skills__c(Skill_Name__c = 'LPG Installation', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill2 = new Employee_Skills__c(Skill_Name__c = 'Roof Work', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill3 = new Employee_Skills__c(Skill_Name__c = 'Building Work', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill4 = new Employee_Skills__c(Skill_Name__c = 'Connect Solar Panels', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill5 = new Employee_Skills__c(Skill_Name__c = 'Contractor Installation', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill6 = new Employee_Skills__c(Skill_Name__c = 'Electrical', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill7 = new Employee_Skills__c(Skill_Name__c = 'Mechanical', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill8 = new Employee_Skills__c(Skill_Name__c = 'Payment Collection', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill9 = new Employee_Skills__c(Skill_Name__c = 'Scaffolder', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill10 = new Employee_Skills__c(Skill_Name__c = 'Specialist Building', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill11 = new Employee_Skills__c(Skill_Name__c = 'Unvented Hot Water', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill12 = new Employee_Skills__c(Skill_Name__c = 'Powerflush', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill13 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill14 = new Employee_Skills__c(Skill_Name__c = 'WATER HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill15 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill16 = new Employee_Skills__c(Skill_Name__c = 'Asbestos Removal', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill17= new Employee_Skills__c(Skill_Name__c = 'Survey', Own_Jobs_Only__c = true,Employee__c =emp.id);
        empSkill18= new Employee_Skills__c(Skill_Name__c = 'Waste Collection', Own_Jobs_Only__c = true,Employee__c =emp.id);
        
        empSkills = new Employee_Skills__c[]{empSkill1,empSkill2,empSkill3,empSkill4,empSkill5,empSkill6,empSkill7,empSkill8,empSkill9,empSkill10,empSkill11,empSkill12,empSkill13,empSkill14,empSkill15,empSkill16,empSkill17,empSkill18}; 
        insert empSkills;  
             
        
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
        /*
        Appointment__c app1 = new Appointment__c(Start__c = startTime, End__c = endTime,
                                                Subject__c = 'updateOpportunityStatus() subject 1',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',
                                                Who__c = contact.Id, RecordTypeId = appointmentApptRecTypeId);
        
        
        Appointment__c app2 = new Appointment__c(Start__c = startTime.addDays(5), 
                                                End__c = endTime.addDays(4),
                                                Subject__c = 'updateOpportunityStatus() subject 2',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',
                                                Who__c = contact.Id, RecordTypeId = appointmentApptRecTypeId);
        app1.OwnerId=user.Id;
        app2.OwnerId=user.Id;
        app1.Type__c='Electrical';
        app2.Type__c='Survey';
        app1.Assigned_To__c = emp.id;
        app2.Assigned_To__c = emp.id;
        Appointment__c[] apps = new Appointment__c[]{app1};
        
        System.debug('TestOpportunityUpdate, apps.size(): ' + apps.size());
        
        Database.insert(apps);
        
        // Check that we have the right number of Appointment History objects
        
        Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
                                                WHERE a.WhatID__c = :opp.Id];
        
        try {
            //System.assertEquals(2, appHistories.size());
        } catch(Exception ex) {
            //System.assertEquals(0, appHistories.size());
        }
        // Check that no changes to the contact doesn't affect things
        
        Lock.clearAll();                    
        Database.update(contact);

        try {
            //System.assertEquals(2, appHistories.size());
        } catch(Exception ex) {
            //System.assertEquals(0, appHistories.size());
        }
        */
        // Change Salutation
    }
    
    static testmethod void UpdateContact_Salutation() 
    {
        CreateTestData();
        Lock.clearAll();        
        contact.Salutation = 'Mrs';     
        Database.update(contact);       
    }
    
    static testmethod void UpdateContact_FirstName() 
    { 
        // Change First Name
        CreateTestData();
        Lock.clearAll();
        contact.FirstName = 'First';
        Database.update(contact);
    }
    
    static testmethod void UpdateContact_LastName() 
    {       
        CreateTestData();
        // Change Last Name
        
        Lock.clearAll();
        contact.LastName = 'Last';
        Database.update(contact);       
    }
    static testmethod void UpdateContact_HomePhone() 
    {        
        // Change Home Phone
        CreateTestData();
        Lock.clearAll();
        contact.HomePhone = '02083321234';
        Database.update(contact);       
    }
    
    static testmethod void UpdateContact_OtherPhone() 
    {       
        // Change Work Phone
        CreateTestData();
        Lock.clearAll();
        contact.OtherPhone = '02083321235';
        Database.update(contact);       
    }
    
    static testmethod void UpdateContact_MobilePhone() 
    {
        // Change Mobile Phone
        CreateTestData();
        Lock.clearAll();
        contact.MobilePhone = '07083321236';
        Database.update(contact);       
    }
    
    static testmethod void UpdateContact_Phone() 
    {
        // Change Primary... ?
        CreateTestData();
        Lock.clearAll();
        contact.Phone = '02083321237';
        Database.update(contact);       
    }
    static testmethod void UpdateContact_contactBeforeUpdateTrigger() 
    {
        
        CreateTestData();
        Lock.clearAll();   
        System.runAs(user)
        {     
            contact.Salutation = 'Mrs';  
            contact.Dont_Update_Finance_Info__c = true;
            contact.bm_cCCreditCheckOutcome__c = 'test';   
            Database.update(contact);       
        }
    }
}