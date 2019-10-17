public class TestAppointmentReassigned{
    
    public class TestAppointmentReassignedSetup {
        public Employee__c chrisEmp = null;
        public Employee__c johnEmp = null;
        public User chris = null;
        public User john = null;
        public String availableEvtRecTypeId = null;
        public String unAvailableEvtRecTypeId = null;
        public String appointmentEvtRecTypeId = null;
        public String availableApptRecTypeId = null;
        public String unAvailableApptRecTypeId = null;
        public String appointmentApptRecTypeId = null; 
        
        public TestAppointmentReassignedSetup() {
            chrisEmp = new Employee__c(First_Name__c = 'emp', Last_Name__c='surname', Employee_Number__c = '00001A');
            johnEmp = new Employee__c(First_Name__c = 'altEmp', Last_Name__c='surname', Employee_Number__c = '87218'); 
            Database.insert(new Employee__c[] {chrisEmp, johnEmp});     
            
            RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];

            for(RecordType rt : recordTypes) {
                if(rt.sObjectType == 'Event') {
                    if(rt.Name == 'Available')
                        availableEvtRecTypeId = rt.Id;
                    else if(rt.Name == 'Unavailable')
                        unavailableEvtRecTypeId = rt.Id;
                    else
                        appointmentEvtRecTypeId = rt.Id;
                } else if(rt.sObjectType == 'Appointment__c'){
                    if(rt.Name == 'Available')
                        availableApptRecTypeId = rt.Id;
                    else if(rt.Name == 'Unavailable')
                        unavailableApptRecTypeId = rt.Id;
                    else
                        appointmentApptRecTypeId = rt.Id;                   
                }
            }           
            
            Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
            chris = new User(LastName = 'Flower', Alias = 'cflower', 
                                Email = 'fl@us.com', Username='flower@user.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user@user.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
            john = new User(LastName = 'Brayshaw', Alias = 'jbrayshaw', 
                                Email = 'bbjb@neigh.com', Username='john@bray.com',
                                Migration_ID__c = 'altuser@altuser.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8', 
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
    
            insert(new User[]{chris, john});
                
            chrisEmp.Salesforce_User__c = chris.Id;
            johnEmp.Salesforce_User__c = john.Id;
            Database.update(new Employee__c[] {chrisEmp, johnEmp});
        }
        
        public Appointment__c bookAppointment(Employee__c e, Boolean overBooked) {
            Account acc = new Account(name = 'bookAppointment()', BillingStreet='Test Street', BillingPostalCode='W5 1AH');
            Database.insert(acc);
            
            Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Name='Test campaign', Group_Code__c='MEDA');
            Database.insert(camp);
                        
            Opportunity opp = new Opportunity (LeadSource = ' MARCOMMS', name = 'bookAppointment() opp', AccountId = acc.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active', Product_Interest__c='Central Heating Boiler1',
                                                CampaignId = camp.Id);
            Database.insert(opp);
                                        
            Contact con = new Contact(LastName='bookAppt', AccountId=acc.Id);
            Database.insert(con);
                    
            Datetime startTime = Datetime.newInstance(2100, 6, 15, 10, 0, 0);
            Datetime endTime = Datetime.newInstance(2100, 6, 15, 12, 0, 0);
            Appointment__c app = new Appointment__c(Start__c = startTime, 
                                                    End__c = endTime, Assigned_To__c = e.Id,
                                                    Show_Time_As__c = 'Busy', Type__c='Sales', 
                                                    Opportunity__c = opp.Id, Who__c = con.id,
                                                    Mode__c='SA', Visit_Type__c = 'First Visit');
            
            app.Overbooked__c = false;
            if(overBooked)
                app.Overbooked__c = true;
                
            Database.insert(app);
            return app;
        }
        
        public Appointment__c bookAvailableAppointment(Employee__c e, Appointment__c a) {
            Appointment__c app = new Appointment__c(Start__c = a.Start__c, 
                                                    End__c = a.End__c, Assigned_To__c = e.Id,
                                                    Show_Time_As__c = 'Out of Office', Type__c='Sales',
                                                    RecordTypeId = availableApptRecTypeId, Mode__c='SA');
                                                    
            Database.insert(app);
            return app;
        }
    }
    
    static testMethod void reassignBookedToNoAvailability() {
        TestAppointmentReassignedSetup s = new testAppointmentReassignedSetup(); 
        Appointment__c app = s.bookAppointment(s.chrisEmp, false);
        app.Assigned_To__c = s.johnEmp.Id;
        Lock.clearAll();
        Database.update(app);
        
        Appointment__c[] chrisApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.chrisEmp.Id];
        Appointment__c[] johnApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.johnEmp.Id];
        
        System.assertEquals(1, johnApps.size());
        System.assertEquals(true, johnApps[0].Overbooked__c);
        System.assertEquals(s.availableApptRecTypeId, chrisApps[0].RecordTypeId);
        System.assertEquals(1, chrisApps.size());
    }
    

    static testMethod void reassignOverbookedToNoAvailability() {
        TestAppointmentReassignedSetup s = new testAppointmentReassignedSetup(); 
        Appointment__c app = s.bookAppointment(s.chrisEmp, true);
        app.Assigned_To__c = s.johnEmp.Id;
        Lock.clearAll();
        
        Database.update(app);
        
        Appointment__c[] chrisApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.chrisEmp.Id];
        Appointment__c[] johnApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.johnEmp.Id];
        
        System.assertEquals(0, chrisApps.size());
        System.assertEquals(1, johnApps.size());
        System.assertEquals(true, johnApps[0].Overbooked__c);
    }
    
    static testMethod void reassignBookedToAvailable() {
        TestAppointmentReassignedSetup s = new testAppointmentReassignedSetup(); 
        Appointment__c app = s.bookAppointment(s.chrisEmp, false);
        Appointment__c avApp = s.bookAvailableAppointment(s.johnEmp, app);
        
        app.Assigned_To__c = s.johnEmp.Id;
        Lock.clearAll();
        Database.update(app);
        
        Appointment__c[] chrisApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.chrisEmp.Id];
        Appointment__c[] johnApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.johnEmp.Id];
        
        System.assertEquals(1, chrisApps.size());
        System.assertEquals(1, johnApps.size());
        System.assertEquals(s.availableApptRecTypeId, chrisApps[0].RecordTypeId);
        //System.assertEquals(s.appointmentApptRecTypeId, johnApps[0].RecordTypeId);        
    }
    
    static testMethod void reassignOverbookedToAvailable() {
        TestAppointmentReassignedSetup s = new testAppointmentReassignedSetup(); 
        Appointment__c app = s.bookAppointment(s.chrisEmp, true);       
        Appointment__c avApp = s.bookAvailableAppointment(s.johnEmp, app);
        
        app.Assigned_To__c = s.johnEmp.Id;
        Lock.clearAll();
        Database.update(app);
        
        Appointment__c[] chrisApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.chrisEmp.Id];
        Appointment__c[] johnApps = [SELECT a.RecordTypeId, a.Overbooked__c 
                                FROM Appointment__c a WHERE a.Assigned_To__c = :s.johnEmp.Id];
        
        System.assertEquals(0, chrisApps.size());
        System.assertEquals(1, johnApps.size());
        //System.assertEquals(s.appointmentApptRecTypeId, johnApps[0].RecordTypeId);
    }   

}