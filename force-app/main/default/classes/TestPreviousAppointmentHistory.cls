public class TestPreviousAppointmentHistory {

    static Integer empNum = 8798;
        
    public class Setup {
        // Variables - all public so they can be read by test methods for easy comparison. 
        // These are populated when the Setup constructor is called
        public String empId = '';
        public String userId = '';
        public String contactId = '';
        public String recordTypeId = ''; 
        public String oppId = '';
        
        public Setup() {
            // Set up a boiler
            Boiler__c boiler = new Boiler__c(Manufacturer__c = 'Biasix', Model__c = 'Saviox');
            Database.insert(boiler);
                    
            // Set up employee
            Employee__c emp = new Employee__c(First_Name__c = 'emp', Last_Name__c = 'emp', 
                                            Phone_No__c = '07734845276', Employee_Number__c = '8798');
                                            
            //Employee__c emp = new Employee__c(First_Name__c = 'emp', Last_Name__c = 'emp', 
            //                              Phone_No__c = '07734845276', Employee_Number__c = (''+(empNum++)));                                         
            Database.insert(emp);
            empId = emp.Id;         
                
            // Set up account
            Account acc = new Account(name = 'testPreviousAppointmentHistory() acc', 
                                    BillingStreet='1 Forge', 
                                    BillingPostalCode='SW19 6DB', BillingCity='London', 
                                    BillingCountry='UK', BillingState='London');
                                                
            Database.insert(acc);
                
            // Set up Contacts
            Contact contact = new Contact(LastName = 'contact', AccountId = acc.Id);
            Database.insert(contact);
            contactId = contact.Id;
            
            Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
            Database.insert(camp);
            
            Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'testPreviouAppointmentHistory() opp', AccountId = acc.Id,
                                            CloseDate = Date.newInstance(2100, 12, 31), 
                                            StageName = 'Active', Referral_Employee__c = empId, 
                                            Product_Interest__c='Central Heating Boiler1',
                                            CampaignId = camp.Id);
            Database.insert(opp);
            oppId = opp.Id;
            
            // Set up users - includes getting a profile
            Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
            User user = new User(LastName = 'us1er1', Alias = 'use1ralias1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');

            // Need to use insert rather than Database.insert for users
            insert(user);
            userId = user.Id;
            
            // Update Employees with details from Users
            emp.Salesforce_User__c = userId;
            Database.update(emp);
            recordTypeId = Utilities.getRecordTypeId('Appointment', 'Appointment__c');
        }
        
        public void updateOpportunityBoilerInfo(String manufacturer, String model) {
            Opportunity opp = [SELECT o.Current_Boiler_Manufacturer__c, o.Current_Boiler_Model__c 
                                FROM Opportunity o WHERE o.Id = :oppId];
            Boiler__c boiler = [SELECT b.Id FROM Boiler__c b
                                WHERE b.Manufacturer__c = :manufacturer and b.Model__c = :model];
            opp.Current_Boiler__c = boiler.Id;
            Database.update(opp);
        }
        
        public void updateOpportunityEnquiryLeadSource(String leadSource, String grp, String source, String mediaType) {
            
            if(grp != null || source != null) {
                Employee__c emp = [SELECT e.Id, e.Group__c, e.Source__c 
                                    FROM Employee__c e where e.Id = :empId];
                if(grp != null)
                    emp.Group__c = grp;
                if(source != null)
                    emp.Source__c = source;
                Database.update(emp);
            }

            Opportunity opp = [SELECT o.LeadSource, o.Referral_Employee__r.Group__c, 
                                o.Referral_Employee__r.Source__c, o.Campaign.Type
                                FROM Opportunity o WHERE o.Id = :oppId];
                                
            if(mediaType != null) {
                Campaign c = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name = 'Test Campaign', Type=mediaType);
                Database.insert(c);
                opp.CampaignId = c.Id;
                //Database.update(opp);
            }
                                
            if(leadSource != null)
                opp.LeadSource = leadSource;
                
            Database.update(opp);
        }
        
        public Appointment__c createNewAppointment(Datetime startT, Datetime endT, String callNotes) {
            Appointment__c app = new Appointment__c(Start__c = startT, 
                     End__c = endT, Call_Notes__c = callNotes,
                     Assigned_To__c = empId, OwnerId = userId,
                     RecordTypeId = recordTypeId,
                     Show_Time_As__c = 'Busy', Status__c = 'Appointed',
                     Type__c = 'Sales', Opportunity__c = oppId, 
                     Visit_Type__c = 'First Visit',
                     Status_Reason__c = 'RAISED IN FAVOUR', Who__c = contactId);                
            return app;
        }
        
        public Appointment__c updateToHappened(Appointment__c app) {
            app = getAppointment(app.Id);
            app.Status__c = 'Happened';
            Lock.clearAll();
            Database.update(app);
            return getAppointment(app.Id);
        }
        
        public Appointment__c insertNewAppointment(Appointment__c app) {
            Lock.clearAll();
            Database.insert(app);
            return getAppointment(app.Id);
        }
        
        public void insertNewAppointments(Appointment__c[] apps) {
            Lock.clearAll();
            Database.insert(apps);
        }
        
        public void upsertAppointments(Appointment__c[] apps) {
            Lock.clearAll();
            Database.upsert(apps);
        }
        
        public Appointment__c getAppointment(Id appointmentId) {
            return [SELECT a.Previous_Appointment_History__c, a.Status__c, a.Boiler_Manufacturer__c, 
                    a.Boiler_Model__c, a.TA_Notes_Group_4__c 
                    FROM Appointment__c a WHERE a.Id = :appointmentId];
        }
    }
    
    // Originally we checked values of hours and minutes - however after
    // the tests were written, validation rules were created that meant
    // times could only be on the hour, hence the tests on minutes were
    // no longer needed
    
    static testmethod void checkStartEndTimes() {
        Setup s = new Setup();
        
        test.starttest();
        // Hour < 10, Minute < 10
        Datetime startT = Datetime.newInstance(2112, 12, 12, 6, 0, 0);
        Datetime endT = Datetime.newInstance(2112, 12, 12, 8, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startT, endT, 'app1Notes');
        Database.insert(app1);
        app1 = [SELECT a.Start_Time__c, a.End_Time__c 
                FROM Appointment__c a WHERE a.Id = :app1.id];
        System.assertEquals('06:00', app1.Start_Time__c);
        System.assertEquals('08:00', app1.End_Time__c);
        s.updateToHappened(app1);
        
        // Hour < 10, Minute > 10
        startT = Datetime.newInstance(2112, 12, 12, 6, 0, 0);
        endT = Datetime.newInstance(2112, 12, 12, 12, 0, 0);
        Appointment__c app2 = s.createNewAppointment(startT, endT, 'app2Notes');
        Database.insert(app2);
        app2 = [SELECT a.Start_Time__c, a.End_Time__c 
                FROM Appointment__c a WHERE a.Id = :app2.id];       
        System.assertEquals('06:00', app2.Start_Time__c);
        System.assertEquals('12:00', app2.End_Time__c);
        s.updateToHappened(app2);
        
        // Hour > 10, Minute < 10
        startT = Datetime.newInstance(2112, 12, 12, 12, 0, 0);
        endT = Datetime.newInstance(2112, 12, 12, 14, 0, 0);
        Appointment__c app3 = s.createNewAppointment(startT, endT, 'app3Notes');
        Database.insert(app3);
        app3 = [SELECT a.Start_Time__c, a.End_Time__c 
                FROM Appointment__c a WHERE a.Id = :app3.id];       
        System.assertEquals('12:00', app3.Start_Time__c);
        System.assertEquals('14:00', app3.End_Time__c);     
        s.updateToHappened(app3);
        
        // Hour > 10, Minute > 10
        startT = Datetime.newInstance(2112, 12, 12, 12, 0, 0);
        endT = Datetime.newInstance(2112, 12, 12, 14, 0, 0);
        Appointment__c app4 = s.createNewAppointment(startT, endT, 'app4Notes');
        Database.insert(app4);
        app4 = [SELECT a.Start_Time__c, a.End_Time__c 
                FROM Appointment__c a WHERE a.Id = :app4.id];       
        System.assertEquals('12:00', app4.Start_Time__c);
        System.assertEquals('14:00', app4.End_Time__c);
        s.updateToHappened(app4);
        
        // Hour = 10, Minute = 10
        startT = Datetime.newInstance(2112, 12, 12, 10, 0, 0);
        endT = Datetime.newInstance(2112, 12, 12, 12, 0, 0);
        Appointment__c app5 = s.createNewAppointment(startT, endT, 'app5Notes');
        Database.insert(app5);
        app5 = [SELECT a.Start_Time__c, a.End_Time__c 
                FROM Appointment__c a WHERE a.Id = :app5.id];
        System.assertEquals('10:00', app5.Start_Time__c);
        System.assertEquals('12:00', app5.End_Time__c);
        test.stoptest();
    }
    
    // Simple test, create 1 Appointment and set it to Happened, create another
    // Appointment and check its Previous Appointment History. Set that Appointment's
    // Status to Happened and create another Appointment and check the new
    // Appointment's Previous Appointment History.
    
    static testmethod void testPAH1() {
        Setup s = new Setup();
        
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 6, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        app1 = s.updateToHappened(app1);
        System.debug('app1: ' + app1);
        System.debug('app1 pah: ' + app1.Previous_Appointment_History__c);
        
        startTime = Datetime.newInstance(2112, 10, 6, 6, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 6, 12, 0, 0);
        Appointment__c app2 = s.createNewAppointment(startTime, endTime, 'app2Notes');
        app2 = s.insertNewAppointment(app2);
        
        System.debug('app2: ' + app2);
        System.debug('app2 pah: ' + app2.Previous_Appointment_History__c);
        
        String expectedPAH = 'Appointment Date: 02/10/2112 06:00, ' + 
                    'Employee Init Name: emp emp - 8798, Employee Mobile: 07734845276, ' +
                    'Prev Visit Detail: app1Notes, Status Reason: RAISED IN FAVOUR,';
        
        System.assertEquals(expectedPAH, app2.Previous_Appointment_History__c);
        
        app2 = s.updateToHappened(app2);
        
        startTime = Datetime.newInstance(2112, 10, 10, 6, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 10, 12, 0, 0);

        Appointment__c app3 = s.createNewAppointment(startTime, endTime, 'app3Notes');
        app3 = s.insertNewAppointment(app3);

        System.debug('app3: ' + app3);
        System.debug('app3 pah: ' + app3.Previous_Appointment_History__c);
        
        expectedPAH = 'Appointment Date: 06/10/2112 06:00, ' + 
                    'Employee Init Name: emp emp - 8798, Employee Mobile: 07734845276, ' +
                    'Prev Visit Detail: app2Notes, Status Reason: RAISED IN FAVOUR,';
                    
        System.assertEquals(expectedPAH, app3.Previous_Appointment_History__c);
    }
    
    static testmethod void testPAH2() {
        // Basic test where inserting more than one appointment. Also try with
        // appointments inserted 'out of order' i.e. the first appointment in the
        // insertion list is later than the second appointment.
        Setup s = new Setup();
        test.starttest();
        // First appointment - happened
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        app1 = s.updateToHappened(app1);
        
        // Second and third appointment
        startTime = Datetime.newInstance(2112, 10, 9, 14, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 9, 18, 0, 0);
        Appointment__c app2 = s.createNewAppointment(startTime, endTime, 'app2Notes');
        startTime = Datetime.newInstance(2112, 10, 15, 14, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 15, 18, 0, 0);
        Appointment__c app3 = s.createNewAppointment(startTime, endTime, 'app3Notes');
        
        app2 = s.insertNewAppointment(app2);
        app2 = s.getAppointment(app2.Id);
        String expectedPAH = 'Appointment Date: 02/10/2112 10:00, ' + 
                    'Employee Init Name: emp emp - 8798, Employee Mobile: 07734845276, ' +
                    'Prev Visit Detail: app1Notes, Status Reason: RAISED IN FAVOUR,';
        System.assertEquals(expectedPAH, app2.Previous_Appointment_History__c);
        app2.Status__c = 'Cancelled';
        Database.update(app2);
        
        //s.insertNewAppointments(new List<Appointment__c>{app2, app3});
        //app2 = s.getAppointment(app2.Id);
        app3 = s.insertNewAppointment(app3);
        app3 = s.getAppointment(app3.Id);
        
        //String expectedPAH = 'Appointment Date: 02/10/2112 10:00, ' + 
        //          'Employee Init Name: emp emp - 8798, Employee Mobile: 07734845276, ' +
        //          'Prev Visit Detail: app1Notes, Status Reason: RAISED IN FAVOUR,';
                    
        //System.assertEquals(expectedPAH, app2.Previous_Appointment_History__c);
        System.assertEquals(expectedPAH, app3.Previous_Appointment_History__c);
        
        s.updateToHappened(app3);
        
        startTime = Datetime.newInstance(2112, 10, 18, 14, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 18, 18, 0, 0);
        Appointment__c app4 = s.createNewAppointment(startTime, endTime, 'app2Notes');
        startTime = Datetime.newInstance(2112, 10, 17, 14, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 17, 18, 0, 0);
        Appointment__c app5 = s.createNewAppointment(startTime, endTime, 'app3Notes');
        s.insertNewAppointments(new List<Appointment__c>{app4, app5});
        app4 = s.getAppointment(app4.Id);
        app5 = s.getAppointment(app5.Id);       
        
        expectedPAH = 'Appointment Date: 15/10/2112 14:00, ' + 
                    'Employee Init Name: emp emp - 8798, Employee Mobile: 07734845276, ' +
                    'Prev Visit Detail: app3Notes, Status Reason: RAISED IN FAVOUR,';
                    
        System.assertEquals(expectedPAH, app4.Previous_Appointment_History__c);
        System.assertEquals(expectedPAH, app5.Previous_Appointment_History__c);
        test.stoptest();
    }

    static testmethod void testPAH3() {
        // Insert capacity and convert it to an appointment 
        Setup s = new Setup();
        
        Appointment__c app1 = s.createNewAppointment(null, null, 'none');
        
        try {
            Database.insert(app1);
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }
    }
    
    static testmethod void testBoilerInfo() {
        Setup s = new Setup();
        String man = 'Biasix';
        String mod = 'Saviox';
        s.updateOpportunityBoilerInfo(man, mod);
        
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);        
        
        System.assertEquals(app1.Boiler_Manufacturer__c, man);
        System.assertEquals(app1.Boiler_Model__c, mod);
    }
    
    static testmethod void testTANotes4Test1() {
        Setup s = new Setup();
        s.updateOpportunityEnquiryLeadSource('Engineer', 'grep', null, null);
        
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        
        System.assertEquals('<grep >', app1.TA_Notes_Group_4__c);
    }
    
    static testmethod void testTANotes4Test2() {
        Setup s = new Setup();
        s.updateOpportunityEnquiryLeadSource('Engineer', 'ENGI', null, null);
        
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        
        System.assertEquals('<ENGI emp emp 07734845276 >', app1.TA_Notes_Group_4__c);       
    }
    
    static testmethod void testTANotes4Test3() {
        Setup s = new Setup();
        s.updateOpportunityEnquiryLeadSource('Engineer', null, 'PL', null);
        
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        
        //System.assertEquals('<null >', app1.TA_Notes_Group_4__c);       
    }   

    static testmethod void testTANotes4Test4() {
        Setup s = new Setup();
        s.updateOpportunityEnquiryLeadSource('Engineer', 'ENGI', 'PL', null);
        
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        
        //System.assertEquals('<emp emp 07734845276 ENGI >', app1.TA_Notes_Group_4__c);       
    }   
    
    static testmethod void testTANotes4Test5() {
        Setup s = new Setup();
        s.updateOpportunityEnquiryLeadSource('MARCOMMS', 'ENGI', 'PL', 'Radio');
        
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        
        //System.assertEquals('<Radio >', app1.TA_Notes_Group_4__c);      
    }       
    
    /*static testmethod void testPAH4() {
        // First appointment - happened
        Setup s = new Setup();
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 10, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app1 = s.createNewAppointment(startTime, endTime, 'app1Notes');
        app1 = s.insertNewAppointment(app1);
        app1 = s.updateToHappened(app1);

        // Second and third appointment
        startTime = Datetime.newInstance(2112, 10, 9, 14, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 9, 18, 0, 0);
        Appointment__c app2 = s.createNewAppointment(startTime, endTime, 'app2Notes');
        app2 = s.insertNewAppointment(app2);
        app2.Status__c = 'Happened';
        
        String expectedPAH = 'Appointment Date: 02/10/2112 10:00, ' + 
                    'Employee Init Name: emp emp - 8798, Employee Mobile: 07734845276, ' +
                    'Prev Visit Detail: app1Notes, Status Reason: RAISED IN FAVOUR,';
        
        startTime = Datetime.newInstance(2112, 10, 15, 14, 0, 0);
        endTime = Datetime.newInstance(2112, 10, 15, 18, 0, 0);
        Appointment__c app3 = s.createNewAppointment(startTime, endTime, 'app3Notes');
        
        System.debug('HERE!');          
        
        s.upsertAppointments(new List<Appointment__c>{app2, app3});
        app2 = s.getAppointment(app2.Id);
        app3 = s.getAppointment(app3.Id);
        
        expectedPAH = 'Appointment Date: 09/10/2112 14:00, ' + 
                    'Employee Init Name: emp emp - 8798, Employee Mobile: 07734845276, ' +
                    'Prev Visit Detail: app2Notes, Status Reason: RAISED IN FAVOUR,';
        
        System.assertEquals(expectedPAH, app3.Previous_Appointment_History__c);
    }*/
}