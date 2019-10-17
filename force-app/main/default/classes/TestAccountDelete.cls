@isTest
private class TestAccountDelete {

    public class Setup {
        
        public String accId = '';
        public String empId = '';
        public String userId = '';
        public String contactId = '';
        public String recordTypeId = ''; 
        public String avRecordTypeId = '';
        public String oppId = '';
            
        public Setup() {
            // Set up employee
            Employee__c emp1 = new Employee__c(First_Name__c = 'emp1', Last_Name__c = 'emp1', 
                                            Phone_No__c = '07734845276', Employee_Number__c = '8798');
                                                                                    
            Database.insert(emp1);
            empId = emp1.Id;
                
            // Set up account
            Account acc = new Account(name = 'testPreviousAppointmentHistory() acc', 
                                    BillingStreet='1 Forge', 
                                    BillingPostalCode='SW19 6DB', BillingCity='London', 
                                    BillingCountry='UK', BillingState='London');
                                                
            Database.insert(acc);
            accId = acc.Id;
                
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
            User user1 = new User(LastName = 'us1er1', Alias = 'use1ralias1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');

            // Need to use insert rather than Database.insert for users
            insert(user1);
            userId = user1.Id;
            
            // Update Employees with details from Users
            emp1.Salesforce_User__c = userId;
            Database.update(emp1);
            recordTypeId = Utilities.getRecordTypeId('Appointment', 'Appointment__c');
            avRecordTypeId = Utilities.getRecordTypeId('Available', 'Appointment__c');
        }
        
        public Appointment__c createNewAppointment(Datetime startT, Datetime endT) {

            Datetime siebel = Datetime.now();
            
            Appointment__c app = new Appointment__c(Start__c = startT, End__c = endT,
                     Any_Time__c = false, Converted_Visit_Type__c = false,
                     Do_Not_Send_To_Premier__c = true, 
                     Mode__c = 'SA', Notes__c = 'Notes field', 
                     Overbooked__c = true, Resource_Type__c = 'S',
                     Sale_Flag__c = true, Show_Time_As__c = 'Busy',
                     Siebel_Created_Date__c = siebel, 
                     Specific_Date_Requested__c = true, Status__c = 'Appointed',
                     Status_Reason__c = 'RAISED IN FAVOUR', Type__c = 'Sales',
                     Visit_Type__c = 'First Visit',                      
                     Assigned_To__c = empId, OwnerId = userId,
                     RecordTypeId = recordTypeId,
                     Opportunity__c = oppId, Who__c = contactId);
                                
            return app;
        }

        public Appointment__c getAppointment(Id appointmentId) {
            return [SELECT a.Any_Time__c, a.Assigned_To__c, a.Converted_Visit_Type__c,
                            a.Do_Not_Send_To_Premier__c, a.End__c, a.Mode__c, a.Notes__c,
                            a.Overbooked__c, a.Resource_Type__c, a.Sale_Flag__c, 
                            a.Show_Time_As__c, a.Siebel_Created_Date__c, 
                            a.Specific_Date_Requested__c, a.Start__c, a.Status_Reason__c,
                            a.Status__c, a.Subject__c, a.Time_Band__c, a.Type__c, 
                            a.Visit_Type__c, a.Opportunity__c, a.Who__c
                            FROM Appointment__c a WHERE a.Id = :appointmentId];
        }
        
        public Appointment__c insertNewAppointment(Appointment__c app) {
            Lock.clearAll();
            Database.insert(app);
            return getAppointment(app.Id);
        }
    }

    static testmethod void testAccountDelete() {
        
        Setup s = new Setup();
        
        // Create and insert an Appointment
        Datetime startTime = Datetime.newInstance(2112, 10, 2, 6, 0, 0);
        Datetime endTime = Datetime.newInstance(2112, 10, 2, 12, 0, 0);
        Appointment__c app = s.createNewAppointment(startTime, endTime);
        app = s.insertNewAppointment(app);

        String appId = app.Id;
        app = [SELECT a.EventID__c FROM Appointment__c a WHERE a.Id = :appId];
        String eventId = app.EventID__c;
        Appointment_History__c ah = [SELECT a.Id FROM Appointment_History__c a WHERE a.Appointment__c = :appId limit 1];
        String appHistoryId = ah.Id;
        
        Lock.clearAll();
        Database.delete(s.accId);
        
        try {
            app = [SELECT a.Id FROM Appointment__c a WHERE a.Id = :appId limit 1];
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }

        try {
            Event ev = [SELECT e.Id FROM Event e WHERE e.Id = :eventId limit 1];
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }

        try {
            ah = [SELECT a.Id FROM Appointment_History__c a WHERE a.Id = :appHistoryId limit 1];
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }
    
        try {
            Contact contact = [SELECT c.Id FROM Contact c WHERE c.Id = :s.contactId limit 1];
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }
    
        try {
            Opportunity opp = [SELECT o.Id FROM Opportunity o WHERE o.Id = :s.oppId limit 1];
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }   

        try {
            Account acc = [SELECT a.Id FROM Account a WHERE a.Id = :s.accId limit 1];
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }           
        
    }
}