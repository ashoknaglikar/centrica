public class TestEventAndAppointmentSynchronisation {
            
    // We use an integer to generate an employee number (avoids duplicate entries)
    static RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];
    static Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
    static Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
    static String empNum ;
    static String empNum1 ;
    static User stduser; 
    static Order__c orders;
    static Account account;
    static Contact contact;
    static Campaign camp;
    static Supplier__c supplier;
    static Supplier__c supplier1;
    static Employee__c emp;
    static Employee__c emp1; //S
    static Employee__c altEmp;
    static Employee__c empObj;
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
    static Employee_Skills__c empSkill19;
    static Employee_Skills__c empSkill20;
    static Employee_Skills__c empSkill21;
    static Employee_Skills__c empSkill22;
    static Employee_Skills__c empSkill23;
    static Employee_Skills__c empSkill24;
    static Employee_Skills__c empSkill25;
    static Employee_Skills__c empSkill26;
    static Employee_Skills__c empSkill27;
    static Employee_Skills__c empSkill28;
    static Employee_Skills__c empSkill29;
    static Employee_Skills__c empSkill30;
    static Employee_Skills__c empSkill31;
    static Employee_Skills__c empSkill32;
    static Employee_Skills__c empSkill33;
    static Employee_Skills__c empSkill34;
    static Employee_Skills__c empSkill35;
    static Employee_Skills__c empSkill36;
    static Employee_Skills__c empSkill37;
    static Employee_Skills__c[] empSkills;
    static Employee_Skills__c[] empSkills1;
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
    
    /* Setup
        An inner class to provide easy access to objects, details and methods
        that help coding of the test classes
    */
        
    public class Setup {

        // Variables - all public so they can be read by test methods for easy comparison. 
        // These are populated when the Setup constructor is called
        public String empId = '';
        public String altEmpId = '';
        public String userId = '';
        public String altUserId = ''; 
        public String contactId = '';
        public String altContactId = '';
        public String leadId = '';
        public string accountId = '';
        public String availableApptRecTypeId = '';
        public String unavailableApptRecTypeId = '';
        public String availableEvtRecTypeId = '';
        public String unavailableEvtRecTypeId = '';
        public String appointmentApptRecTypeId = '';
        public String appointmentEvtRecTypeId = '';
        public String installtionEvtRecTypeId = '';
        public String installtionApptRecTypeId = '';
        public String itineraryEvtRecTypeId = '';
    	public String itineraryApptRecTypeId = '';
        public Appointment__c app1;
        public Setup() {
        	
            // Set up employees
            String strTemp = System.now().format('ssSS').substring(1);            
            empNum = '1907';
            empNum1 = '1108';
            
            List<Employee__c> lstEmp = [select First_Name__c,Employee_Number__c,id from Employee__c where Employee_Number__c =:empNum limit 1];
            
            if(lstEmp!= null && lstEmp.size() > 0)
            {
            	emp = lstEmp[0];
            }
            else
            {
            	emp = new Employee__c(First_Name__c = 'emp', Last_Name__c = 'emp', Employee_Number__c = (''+(empNum)));
                insert emp;
            }
            
            lstEmp = [select First_Name__c,Employee_Number__c,id from Employee__c where Employee_Number__c =:empNum1 limit 1];
            if(lstEmp!= null && lstEmp.size() > 0)
            {
            	altEmp = lstEmp[0];
            }
            else
            {
            	altEmp = new Employee__c(First_Name__c = 'altEmp', Last_Name__c = 'altEmp', Employee_Number__c = (''+(empNum1)), Salesforce_User__c = userinfo.getuserid());
                insert altEmp;
            }
            
     
            empId = emp.Id;
            
            altEmpId = altEmp.Id;           
                    
            // Set up accounts
                                   
            Account acc1;
            if(account != null)
            	acc1 = account;
        	else
        	{
           		acc1 = new Account(name = 'createNewEvt(bool, bool) acc', BillingStreet='147 Pitt', 
                                        BillingPostalCode='SW19 6DB', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
                
            	Database.insert(acc1);
            	account = acc1;
        	}
        	
        	 //Database.insert(new Account[]{acc1, acc2});
            //Database.insert(new Account[]{acc1});
            accountId = acc1.id;
            System.debug('------------------ acc1.id = ' + acc1.id);
            // Set up Contacts
            contact = new Contact(LastName = 'contact', AccountId = acc1.Id, Primary_Contact__c = false);
            
            //Contact altContact = new Contact(LastName = 'altContact', AccountId = acc2.Id);
            //Database.insert(new Contact[]{contact, altContact});
            Database.insert(new Contact[]{contact});
            contactId = contact.Id;
           // altContactId = altContact.Id;
            
            // Set up recordTypes
            //RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];

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
            
            // Set up a lead
            Lead lead = new Lead(LastName = 'lead', Company = 'lead Co.', Status = 'Open', Phone = '07738248711', PostalCode = 'RM6 5DD');
            Database.insert(lead);
            leadId = lead.Id;
            
          
        }
        
        /* createNewAppt
            Creates, inserts and returns a new Appointment object. 
            
            Boolean isInstall controls whether the appointment is an installation.
            String billingStreet determines the billing street for the associated Account
            
        */
    public Appointment__c createNewAppt(Boolean isInstall, String biilingStreet) {
    	 cls_IsRun.setgeneralTriggerSwitch();
            // Create new account
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
      
        String postcodeSector = 'SE3 9';
         //RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];

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
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet= biilingStreet ,BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;
        
        if(camp == null)
        {  
	        camp = new Campaign(Source__c = 'MC', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
	        Database.insert(camp);
        }
        
        supplier1 = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A12341',Resource_Type__c='Resource');
        insert supplier1;
        //Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user;
        String suppliernum =  System.now().format('ssSS').substring(1);
        if(stduser == null)
        {
	        user = new User(LastName = 'us1er1', Alias = 'use1', 
	                                Email = 'a1@b.com', Username='user' + suppliernum + '@testorg.com',
	                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
	                                Migration_ID__c = 'user1@hotmail.com',
	                                TimeZoneSidKey = 'Europe/London', 
	                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US',IsActive = true);
	        insert user;
	        stduser = user; 
        }
        else
        	user = stduser;
        	
        userId = user.Id;
        emp = new Employee__c(Name = 'testJI3', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier1.Id,
                                         Employee_Number__c = '0002998',Resource_Id__c='732js2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp,altEmp};                                          
        upsert employees;
        
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
        
        /*empSkills = new Employee_Skills__c[]{empSkill1,empSkill2,empSkill3,empSkill4,empSkill5,empSkill6,empSkill7,empSkill8,empSkill9,empSkill10,empSkill11,empSkill12,empSkill13,empSkill14,empSkill15,empSkill16,empSkill17,empSkill18}; 
        insert empSkills;*/  
        
        //alt employee
        empSkill19 = new Employee_Skills__c(Skill_Name__c = 'LPG Installation', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill20 = new Employee_Skills__c(Skill_Name__c = 'Roof Work', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill21 = new Employee_Skills__c(Skill_Name__c = 'Building Work', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill22 = new Employee_Skills__c(Skill_Name__c = 'Connect Solar Panels', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill23 = new Employee_Skills__c(Skill_Name__c = 'Contractor Installation', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill24 = new Employee_Skills__c(Skill_Name__c = 'Electrical', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill25 = new Employee_Skills__c(Skill_Name__c = 'Mechanical', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill26 = new Employee_Skills__c(Skill_Name__c = 'Payment Collection', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill27 = new Employee_Skills__c(Skill_Name__c = 'Scaffolder', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill28 = new Employee_Skills__c(Skill_Name__c = 'Specialist Building', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill29 = new Employee_Skills__c(Skill_Name__c = 'Unvented Hot Water', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill30 = new Employee_Skills__c(Skill_Name__c = 'Powerflush', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill31 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill32 = new Employee_Skills__c(Skill_Name__c = 'WATER HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill33 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill34 = new Employee_Skills__c(Skill_Name__c = 'Asbestos Removal', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill35= new Employee_Skills__c(Skill_Name__c = 'Survey', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill36= new Employee_Skills__c(Skill_Name__c = 'Waste Collection', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        
        empSkills1 = new Employee_Skills__c[]{
        	empSkill1,empSkill2,empSkill3,empSkill4,empSkill5,empSkill6,empSkill7,empSkill8,empSkill9,empSkill10,empSkill11,empSkill12,empSkill13,empSkill14,empSkill15,empSkill16,empSkill17,empSkill18
        	,empSkill19,empSkill20,empSkill21,empSkill22,empSkill23,empSkill24,empSkill25,empSkill26,empSkill27,empSkill28,empSkill29,empSkill30,empSkill31,empSkill32,empSkill33,empSkill34,empSkill35,empSkill36}; 
        insert empSkills1;  
        
        //Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345',IsActive =true);
        insert UInstal1;
        
        
        
        //inserting opportunity with different employee
        //opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  //AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
        Opportunity opp;
        if(opportunity == null)
        {
	        opportunity = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
	                                                CloseDate = Date.today().addyears(1), 
	                                                StageName = 'Active',Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false,
	                                                Product_Interest__c='Central Heating Boiler',
	                                                CampaignId = camp.Id, LeadSource='Engineer');
	        Database.insert(opportunity);  
	       	opp = opportunity;
        }
        else
        	opp = opportunity;
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=employees[0].Id,
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
        String unvRecordID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Unavailable');
        Appointment__c app = new Appointment__c(Start__c = startTime, 
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
           insert app;
           
         Appointment_History__c newHistory = new Appointment_History__c(
                            Any_Time__c = app.Any_Time__c,
                            Appointment__c = app.Id,
                            Assigned_To__c = employees[0].id,
                            Converted_Visit_Type__c = app.Converted_Visit_Type__c,
                            Not_Created_By_Dataloader__c = Lock.userIsNotDataloader,
                            Do_Not_Send_To_Premier__c = app.Do_Not_Send_To_Premier__c, 
                            End__c = app.End__c,
                            Mode__c = app.Mode__c,
                            Notes__c = app.Notes__c,
                            Overbooked__c = app.Overbooked__c,
                            Resource_Type__c = app.Resource_Type__c,
                            Sale_Flag__c = app.Sale_Flag__c,
                            Show_Time_As__c = app.Show_Time_As__c,
                            Siebel_Created_Date__c = app.Siebel_Created_Date__c,
                            Specific_Date_Requested__c = app.Specific_Date_Requested__c,
                            Start__c = app.Start__c,
                            Status_Reason__c = app.Status_Reason__c,
                            Status__c = app.Status__c,
                            Subject__c = app.Subject__c,
                            Time_Band__c = app.Time_Band__c,
                            Type__c = app.Type__c,
                            Visit_Type__c = app.Visit_Type__c,
                            WhatID__c = app.Opportunity__c,
                            WhoId__c = app.Who__c
                            );
        insert newHistory;
        
        /*Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
                                                WHERE a.Appointment__c = :app.Id]; */

        return app;
        }
       public Appointment__c createNewAppt1(Boolean isInstall, String biilingStreet, String userName) {
       	 cls_IsRun.setgeneralTriggerSwitch();
            // Create new account
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
         //RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];

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
        if(account == null)
        {
	        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
	                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
	     
	        insert account;
        }
        
        if(contact == null)
        {
	        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
	                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
	                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
	           
	        
	        insert contact;  
        }
        if(camp == null)
        {
        	camp = new Campaign(Source__c = 'MC', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        	Database.insert(camp);
        }
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        //Profile p = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
        User user;
        if(stduser == null)
        {
	        user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
	        insert user;
	        stduser = user; 
        }
        else
        	user = stduser;
        
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c=user.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp,altEmp};                                          
        upsert employees;
        altEmpId = altEmp.Id;    
               
        
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
        
        /*empSkills = new Employee_Skills__c[]{empSkill1,empSkill2,empSkill3,empSkill4,empSkill5,empSkill6,empSkill7,empSkill8,empSkill9,empSkill10,empSkill11,empSkill12,empSkill13,empSkill14,empSkill15,empSkill16,empSkill17,empSkill18}; 
        insert empSkills;*/
        
        //alt employee
        empSkill19 = new Employee_Skills__c(Skill_Name__c = 'LPG Installation', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill20 = new Employee_Skills__c(Skill_Name__c = 'Roof Work', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill21 = new Employee_Skills__c(Skill_Name__c = 'Building Work', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill22 = new Employee_Skills__c(Skill_Name__c = 'Connect Solar Panels', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill23 = new Employee_Skills__c(Skill_Name__c = 'Contractor Installation', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill24 = new Employee_Skills__c(Skill_Name__c = 'Electrical', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill25 = new Employee_Skills__c(Skill_Name__c = 'Mechanical', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill26 = new Employee_Skills__c(Skill_Name__c = 'Payment Collection', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill27 = new Employee_Skills__c(Skill_Name__c = 'Scaffolder', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill28 = new Employee_Skills__c(Skill_Name__c = 'Specialist Building', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill29 = new Employee_Skills__c(Skill_Name__c = 'Unvented Hot Water', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill30 = new Employee_Skills__c(Skill_Name__c = 'Powerflush', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill31 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill32 = new Employee_Skills__c(Skill_Name__c = 'WATER HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill33 = new Employee_Skills__c(Skill_Name__c = 'FIRE/WALL HEATER FIXING', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill34 = new Employee_Skills__c(Skill_Name__c = 'Asbestos Removal', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill35= new Employee_Skills__c(Skill_Name__c = 'Survey', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill36= new Employee_Skills__c(Skill_Name__c = 'Waste Collection', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        empSkill37= new Employee_Skills__c(Skill_Name__c = 'Installation', Own_Jobs_Only__c = true,Employee__c =employees[1].id);
        
        empSkills1 = new Employee_Skills__c[]{
        	empSkill1,empSkill2,empSkill3,empSkill4,empSkill5,empSkill6,empSkill7,empSkill8,empSkill9,empSkill10,empSkill11,empSkill12,empSkill13,empSkill14,empSkill15,empSkill16,empSkill17,empSkill18
        	,empSkill19,empSkill20,empSkill21,empSkill22,empSkill23,empSkill24,empSkill25,empSkill26,empSkill27,empSkill28,empSkill29,empSkill30,empSkill31,empSkill32,empSkill33,empSkill34,empSkill35,empSkill36
        	,empSkill37}; 
        insert empSkills1;  
        
        //Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        
        //inserting opportunity with different employee
        //opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  //AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
        
        
                                                        
        Opportunity opp;
        if(opportunity == null)
        {
	        opportunity = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                CampaignId = camp.Id, LeadSource='Engineer');
	        Database.insert(opportunity);  
	       	opp = opportunity;
        }
        else
        	opp = opportunity;
        	
                
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c='employeesId - EmployeeNumber ',
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

        
        //District__c district = [Select id from District__c limit 1];
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;        
       
       
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
        Appointment__c app = new Appointment__c(Start__c = startTime, 
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
                try{
                insert app;
                }
            catch(Exception ex)
            {
                //error
            }
        app.EmployeeTextMailAddress__c='mail1@mail.com';
        update app;
        Lock.reassigned.put(app.id,app.Reassignment_Override__c);
        String InstID = RecordTypeIdHelper.getRecordTypeId('Appointment__c','Installation');
        app1 = new Appointment__c(Start__c = startTime,
                                 End__c = endTime, Subject__c = subject, Job_Element__c = JE.id,
                                 Assigned_To__c =employees[0].id, OwnerId = user.id,
                                 Any_Time__c = anyTime, Description__c = description,
                                 Converted_Visit_Type__c = convertedVisitType,
                                 Do_Not_Send_To_Premier__c = doNotSendToPremier,
                                 Mode__c = mode, Overbooked__c = overbooked,
                                 Resource_Type__c = resourceType, 
                                 Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
                                 Status_Reason__c = statusReason, Status__c = 'Happened',
                                 Time_Band__c = timeBand, Type__c = mode,
                                 Visit_Type__c = visitType, Opportunity__c = opp.id,
                                 EmployeeTextMailAddress__c='mail2@mail.com',
                                 Who__c = who,Unavailability_Reason__c = 'Survey Booking',RecordTypeId =InstID);
         insert app1;
        String InstID1 = appointmentApptRecTypeId;
        Appointment__c app2 = new Appointment__c(Start__c = startTime, Job_Element__c = JE.id,
                                 End__c = endTime, Subject__c = subject, 
                                 Assigned_To__c = employees[0].id, OwnerId = user.id,
                                 Any_Time__c = anyTime, Description__c = description,
                                 Converted_Visit_Type__c = convertedVisitType,
                                 Do_Not_Send_To_Premier__c = doNotSendToPremier,
                                 Mode__c = mode, Overbooked__c = overbooked,
                                 Resource_Type__c = resourceType, 
                                 Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
                                 Status_Reason__c = statusReason, Status__c = status,
                                 Time_Band__c = timeBand, Type__c = typeC,
                                 Visit_Type__c = visitType, Opportunity__c = opp.id,
                                 Who__c = who,Unavailability_Reason__c = 'Survey Booking',RecordTypeId =InstID1);
         insert app2;
        Lock.reassigned.put(app2.id,false);
        String CustExpID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Customer Experience Case Event');
        Appointment__c app3 = new Appointment__c(Start__c = startTime, 
                                 End__c = endTime, Subject__c = subject, 
                                 Assigned_To__c = employees[0].id, OwnerId = user.id,
                                 Any_Time__c = anyTime, Description__c = description,
                                 Converted_Visit_Type__c = convertedVisitType,
                                 Do_Not_Send_To_Premier__c = doNotSendToPremier,
                                 Mode__c = mode, Overbooked__c = overbooked,
                                 Resource_Type__c = resourceType, 
                                 Sale_Flag__c = sale, Show_Time_As__c = showTimeAs,
                                 Status_Reason__c = statusReason, Status__c = status,
                                 Time_Band__c = timeBand, Type__c = typeC,
                                 Visit_Type__c = visitType, Opportunity__c = opp.id,
                                 Who__c = who,Unavailability_Reason__c = 'Survey Booking',RecordTypeId =CustExpID);
         insert app3;
         
        
         Lock.reassigned.put(app3.id,false);
         Appointment_History__c newHistory = new Appointment_History__c(
                            Any_Time__c = app.Any_Time__c,
                            Appointment__c = app.Id,
                            Assigned_To__c = employees[0].id,
                            Converted_Visit_Type__c = app.Converted_Visit_Type__c,
                            Not_Created_By_Dataloader__c = Lock.userIsNotDataloader,
                            Do_Not_Send_To_Premier__c = app.Do_Not_Send_To_Premier__c, 
                            End__c = app.End__c,
                            Mode__c = app.Mode__c,
                            Notes__c = app.Notes__c,
                            Overbooked__c = app.Overbooked__c,
                            Resource_Type__c = app.Resource_Type__c,
                            Sale_Flag__c = app.Sale_Flag__c,
                            Show_Time_As__c = app.Show_Time_As__c,
                            Siebel_Created_Date__c = app.Siebel_Created_Date__c,
                            Specific_Date_Requested__c = app.Specific_Date_Requested__c,
                            Start__c = app.Start__c,
                            Status_Reason__c = app.Status_Reason__c,
                            Status__c = app.Status__c,
                            Subject__c = app.Subject__c,
                            Time_Band__c = app.Time_Band__c,
                            Type__c = app.Type__c,
                            Visit_Type__c = app.Visit_Type__c,
                            WhatID__c = app.Opportunity__c,Previous_Assigned_To_Textmail__c='mail@mail.com',
                            WhoId__c = app.Who__c
                            );
        insert newHistory;
        
        List<Appointment_History__c> lstAppHistory = new List<Appointment_History__c>();
        lstAppHistory.add(newHistory);
        system.debug('--lstAppHistory' +lstAppHistory);
        /** s**/
        Lock.appHistories.put(app.id,lstAppHistory);
        Lock.appHistories.put(app1.id,lstAppHistory);
        System.debug('Lock.appHistories contains Key');
        
        newHistory.Status__c = app1.Status__c;
        
        update newHistory;
       
        
        //Lock.appHistories.put(app.id);
        
        /*Appointment_History__c[] appHistories = [SELECT a.WhatID__c FROM Appointment_History__c a 
                                                WHERE a.Appointment__c = :app.Id]; */

        return app;
        }
        

        /* createNewEvt
            Creates, inserts and returns a new Event object. 
            
            Boolean whoIsLead controls whether the Event's WhoID corresponds to a lead
            Boolean whatIsOpp controls whether the Event's WhatID corresponds to an opportunity
            String billingStreet determines the billing street for the associated Account       
        */
        
      public Event createNewEvt(Boolean whoIsLead, Boolean whatIsOpp, String billingStreet) {
      	 cls_IsRun.setgeneralTriggerSwitch();
            Setup s = new Setup();
            Appointment__c app1 = s.createNewAppt1(false, '146 Pitt','test2@testorg.com');
            
            // Create new Account
            Account acc;
            if(account != null)
            	acc = account;
        	else
        	{
           		acc = new Account(name = 'createNewEvt(bool, bool) acc', BillingStreet=billingStreet, 
                                        BillingPostalCode='SW19 6DB', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
            	Database.insert(acc);
        	}
            
            String who = contact.id;
            if(whoIsLead)
                who = leadId;
            String userID = stduser.id;
            Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
            Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 18, 0, 0);
            Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 20, 0, 0);
            String subject = 'createNewEvt() Test';
            Boolean anyTime = true; // Also: True
            Boolean convertedVisitType = false; // Also: True
            String description = 'createNewEvt() description';
            Boolean doNotSendToPremier = false; // Also: false
            Boolean allDayEvent = false; // Also: True
            Datetime lastSentToPremier = Datetime.now();
            String mode = 'SA'; // Other options available
            Boolean overbooked = true; // Also: False
            String recordTypeId = appointmentEvtRecTypeId; // Other options available
            String resourceType = 'Z';
            Boolean sale = true; // Also: False
            String showTimeAs = 'Busy'; // Also: Out of Office, Free
            String statusReason = 'RAISED IN FAVOUR'; // Other options available
            String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
            String timeBand = 'EV'; // Also: PM, EV, AT
            String typeC = 'Survey'; // Other options available
            String visitType = 'Pickup'; // Also: Recall Visit, Pickup
            //String opportunity = opp.Id;
            String postcodeSector = 'SE3 1';
            String what = acc.Id; // Other options available
            if(whatIsOpp)
                what = opportunity.Id;
            Event evt = new Event(StartDateTime = startTime, EndDateTime = endTime,
                                OwnerId = userID, Any_Time__c = anyTime, 
                                Converted_Visit_Type__c = convertedVisitType, Description = description, 
                                Do_Not_Send_To_Premier__c = doNotSendToPremier, IsAllDayEvent = allDayEvent,
                                Mode__c = mode, Subject = subject,
                                Overbooked__c = overbooked, 
                                RecordTypeId = recordTypeId, Resource_Type__c = resourceType,
                                Sale_Flag__c = sale, ShowAs = showTimeAs, 
                                Status_Reason__c = statusReason, Status__c = status,
                                Time_Band__c = timeBand, Type__c = typeC, Visit_Type__c = visitType,
                                WhoId = who,AppointmentID__c=app1.id);
                                
            // We cannot have a WhatID that is an Opportunity
            // if the WhoID is a Lead; otherwise we can set
            // the WhatId as above          
            if(!whoIsLead)
                evt.WhatId = what;

            Database.insert(evt);                           
            return evt;             
        }
        
         
        
      public Event createNewEvt(Boolean whoIsLead, Boolean whatIsOpp, String billingStreet, String EmployeeNumber) {
      	 cls_IsRun.setgeneralTriggerSwitch();
            Setup s = new Setup();
            Appointment__c app1 = s.createNewAppt1(false, '146 Pitt','test2@testorg.com');
            // Create new Account
            /*Account acc = new Account(name = 'createNewEvt(bool, bool) acc', BillingStreet=billingStreet, 
                                        BillingPostalCode='SW19 6DB', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
            Database.insert(acc);*/
            
            Account acc;
            if(account != null)
            	acc = account;
        	else
        	{
           		acc = new Account(name = 'createNewEvt(bool, bool) acc', BillingStreet=billingStreet, 
                                        BillingPostalCode='SW19 6DB', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
            	Database.insert(acc);
        	}
        	/*
            System.debug('----------------------- acc.Id = ' + acc.Id);
            if(contact == null)
            {
	            contact = new Contact(Phone='9422332343', MailingStreet='Test Street',MailingState='Test State',
	                                     MailingPostalCode='411111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
	                                     FirstName='First1 name',Email='test1@gmail.com',AccountId=acc.Id,Salutation='Mr'); 
	           
	            insert contact;
            }  
            
            
            Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
            Database.insert(camp);          
            
            // Create new Opportunity (LeadSource = 'MARCOMMS', CHI Lead) for Account
            Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'createNewEvt() opp', AccountId = acc.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active', 
                                                Product_Interest__c='Central Heating Boiler',
                                                CampaignId = camp.Id);
            Database.insert(opp);
            
            
            
            
            String tempString = billingStreet.replace(' ','');
            Profile p1 = [SELECT p.ID FROM profile p WHERE p.UserType='Standard' limit 1];
            User user2 = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1' + tempString + '@b.com', Username='test7' + tempString + '@testorg.com',
                                ProfileId = p1.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1' + tempString + '@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
            insert user2;
            userID = user2.id;
            User user3 = new User(LastName = 'us5er5', Alias = 'use5', 
                                Email = 'a5' + tempString + '@b.com', Username='test5' + tempString + '@testorg.com',
                                ProfileId = p1.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user5' + tempString + '@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
            insert user3;
            String suppliernum =  System.now().format('ssSS').substring(1);
            supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A' + suppliernum,Resource_Type__c='Resource');
            insert supplier;        
            
            emp = new Employee__c(Name = 'testJI3', Salesforce_User__c=user2.id ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = EmployeeNumber,Resource_Id__c=suppliernum + 's2',Resource_Type__c='Installer');
                                         
            employees = new Employee__c[]{emp};                                          
            insert employees;
            
                
            // Determine what values we are going to use for the Event          
            Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
            Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 18, 0, 0);
            Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 20, 0, 0);
            String subject = 'createNewEvt() Test';
            Boolean anyTime = true; // Also: True
            Boolean convertedVisitType = false; // Also: True
            String description = 'createNewEvt() description';
            Boolean doNotSendToPremier = false; // Also: false
            Boolean allDayEvent = false; // Also: True
            Datetime lastSentToPremier = Datetime.now();
            String mode = 'SA'; // Other options available
            Boolean overbooked = true; // Also: False
            String recordTypeId = appointmentEvtRecTypeId; // Other options available
            String resourceType = 'Z';
            Boolean sale = true; // Also: False
            String showTimeAs = 'Busy'; // Also: Out of Office, Free
            String statusReason = 'RAISED IN FAVOUR'; // Other options available
            String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
            String timeBand = 'EV'; // Also: PM, EV, AT
            String typeC = 'Sales'; // Other options available
            String visitType = 'Pickup'; // Also: Recall Visit, Pickup
            //String opportunity = opp.Id;
            String postcodeSector = 'SE3 1';
            
            // Need to check booleans passed in
            String who = contact.id;
            if(whoIsLead)
                who = leadId;
                
            system.debug('who----' +who);
                
            String what = acc.Id; // Other options available
            if(whatIsOpp)
                what = opp.Id;
                
            system.debug('what----' +what);
            
            //Create the new event
            */
            String userID = stduser.id;
            Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
            Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 18, 0, 0);
            Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 20, 0, 0);
            String subject = 'createNewEvt() Test';
            Boolean anyTime = true; // Also: True
            Boolean convertedVisitType = false; // Also: True
            String description = 'createNewEvt() description';
            Boolean doNotSendToPremier = false; // Also: false
            Boolean allDayEvent = false; // Also: True
            Datetime lastSentToPremier = Datetime.now();
            String mode = 'SA'; // Other options available
            Boolean overbooked = true; // Also: False
            String recordTypeId = appointmentEvtRecTypeId; // Other options available
            String resourceType = 'Z';
            Boolean sale = true; // Also: False
            String showTimeAs = 'Busy'; // Also: Out of Office, Free
            String statusReason = 'RAISED IN FAVOUR'; // Other options available
            String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
            String timeBand = 'EV'; // Also: PM, EV, AT
            String typeC = 'Sales'; // Other options available
            String visitType = 'Pickup'; // Also: Recall Visit, Pickup
            //String opportunity = opp.Id;
            String postcodeSector = 'SE3 1';
            String who = contact.id;
            if(whoIsLead)
                who = leadId;
            String what = acc.Id; // Other options available
            if(whatIsOpp)
                what = opportunity.Id;
            Event evt = new Event(StartDateTime = startTime, EndDateTime = endTime,
                                OwnerId = userID, Any_Time__c = anyTime, 
                                Converted_Visit_Type__c = convertedVisitType, Description = description, 
                                Do_Not_Send_To_Premier__c = doNotSendToPremier, IsAllDayEvent = allDayEvent,
                                Mode__c = mode, Subject = subject,
                                Overbooked__c = overbooked, 
                                RecordTypeId = recordTypeId, Resource_Type__c = resourceType,
                                Sale_Flag__c = sale, ShowAs = showTimeAs, 
                                Status_Reason__c = statusReason, Status__c = status,
                                Time_Band__c = timeBand, Type__c = typeC, Visit_Type__c = visitType,
                                WhoId = who,AppointmentID__c=app1.id);
                                
            // We cannot have a WhatID that is an Opportunity
            // if the WhoID is a Lead; otherwise we can set
            // the WhatId as above          
            if(!whoIsLead)
                evt.WhatId = what;

            Database.insert(evt);                           
            return evt;             
        }

        /* createNewEvt
            Creates, inserts and returns a new Event object. 
            
            String billingStreet determines the billing street for the associated Account       
        */
                
     public Event createNewEvt(String billingStreet) {
            Setup s = new Setup();
            Appointment__c app1 = s.createNewAppt1(false, '146 Pitt','test2@testorg.com');
            
            // Create new Account
            Account acc = new Account(name = 'createNewEvt() acc', BillingStreet=billingStreet, 
                                        BillingPostalCode='RM6 6EH', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
            Database.insert(acc);
            
            /*Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
            Database.insert(camp);
            
            // Create new Opportunity
            Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'createNewEvt() opp', AccountId = acc.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',
                                                Product_Interest__c='Central Heating Boiler',
                                                CampaignId = camp.Id);
            Database.insert(opp);
            
            // Create new Contact
            Contact con = new Contact(LastName = 'createNewEvt lastName', AccountId = acc.Id);
            Database.insert(con);
            
            
            // Create new Event object and insert
            System.debug('-------------- recordTypeId = ' + recordTypeId);
            System.debug('-------------- opp.Id = ' + opp.Id);
            System.debug('-------------- con.Id = ' + con.Id);
            */
            /*Event evt = new Event(StartDateTime = startTime, EndDateTime = endTime,
                                OwnerId = altUserId, Any_Time__c = anyTime, 
                                Converted_Visit_Type__c = convertedVisitType, Description = description, 
                                Do_Not_Send_To_Premier__c = doNotSendToPremier, IsAllDayEvent = allDayEvent,
                                Mode__c = mode, Subject = subject, 
                                Overbooked__c = overbooked, 
                                RecordTypeId = recordTypeId, Resource_Type__c = resourceType,
                                Sale_Flag__c = sale, ShowAs = showTimeAs, 
                                Status_Reason__c = statusReason, Status__c = status,
                                Time_Band__c = timeBand, Type__c = typeC, Visit_Type__c = visitType,
                                WhatId = opp.Id, WhoId = con.Id);*/
            String who = contact.id;
            String userID = stduser.id;
            Datetime now = Datetime.newInstance(2100, 6, 15, 8, 0, 0);
            Datetime startTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 18, 0, 0);
            Datetime endTime = Datetime.newInstance(now.year()+7, now.month()+7, now.day()+7, 20, 0, 0);
            String subject = 'createNewEvt() Test';
            Boolean anyTime = true; // Also: False
            Boolean convertedVisitType = false; // Also: True
            String description = 'createNewEvt() description';
            Boolean doNotSendToPremier = false; // Also: False
            Boolean allDayEvent = false; // Also: false
            Datetime lastSentToPremier = Datetime.now();
            String mode = 'SU'; // Other options available
            Boolean overbooked = true; // Also: False
            String recordTypeId = appointmentEvtRecTypeId; // Other options available
            String resourceType = 'Z';
            Boolean sale = true; // Also: True
            String showTimeAs = 'Busy'; // Also: Out of Office, Free
            String statusReason = 'RAISED IN FAVOUR'; // Other options available
            String status = 'Appointed'; // Also: Appointed, Happened, Cancelled
            String timeBand = 'AT'; // Also: AM, PM, EV
            String typeC = 'Joint'; // Other options available
            String visitType = 'Pickup'; // Also: Recall Visit, Pickup
            //String opportunity = opp.Id;
            String postcodeSector = 'SE3 5';
            String what = acc.Id; // Other options available
            
            Event evt = new Event(StartDateTime = startTime, EndDateTime = endTime,
                                Any_Time__c = anyTime, 
                                Converted_Visit_Type__c = convertedVisitType, Description = description, 
                                Do_Not_Send_To_Premier__c = doNotSendToPremier, IsAllDayEvent = allDayEvent,
                                Mode__c = mode, Subject = subject, 
                                Overbooked__c = overbooked, 
                                RecordTypeId = recordTypeId, Resource_Type__c = resourceType,
                                Sale_Flag__c = sale, ShowAs = showTimeAs, 
                                Status_Reason__c = statusReason, Status__c = status,
                                Time_Band__c = timeBand, Type__c = typeC, Visit_Type__c = visitType,
                                WhatId = what, WhoId = contact.Id,AppointmentID__c=app1.id);
                                
            System.debug('Before insert: ' + evt.StartDateTime + ' ' + evt.EndDateTime);
            Database.insert(evt);
            
            System.debug('After insert: ' + evt.StartDateTime + ' ' + evt.EndDateTime);                         
            return evt;             
        }
        
       
        
       public Appointment__c getAppointment(String eventId) {
            Appointment__c app = [SELECT a.Id, a.Start__c, a.End__c, 
                                a.Subject__c, a.Assigned_To__c, a.Any_Time__c, a.EventId__c, 
                                a.Description__c, a.Converted_Visit_Type__c, 
                                a.Do_Not_Send_To_Premier__c,
                                a.Mode__c, a.Overbooked__c, a.RecordTypeId,
                                a.Resource_Type__c, a.Sale_Flag__c, a.Show_Time_As__c,
                                a.Status_Reason__c, a.Status__c, a.Time_Band__c, a.Type__c,
                                a.Visit_Type__c, a.Opportunity__c, a.Who__c 
                                FROM Appointment__c a 
                                WHERE a.EventId__c = :eventId limit 1];
                                
            return app; 
        }
        
        
       public Event getEvent(String appointmentId) {
            Event evt = [SELECT e.StartDateTime, e.EndDateTime,
            e.Any_Time__c, e.Description,
            e.Converted_Visit_Type__c, 
            e.Do_Not_Send_To_Premier__c, e.IsAllDayEvent,
            e.Mode__c, e.Subject,
            e.Overbooked__c, e.Resource_Type__c,
            e.Sale_Flag__c, e.ShowAs, e.Status_Reason__c,
            e.Status__c, e.Time_Band__c, e.Type__c, 
            e.Visit_Type__c, e.WhatId, e.WhoId, 
            e.OwnerId, e.RecordTypeId 
            FROM Event e WHERE e.AppointmentID__c = :appointmentId limit 1];
            
            return evt;
        }

                    
      public Event[] getEvents(String appointmentId) {
            Event[] evt = [SELECT e.StartDateTime, e.EndDateTime,
            e.Any_Time__c, e.Description,
            e.Converted_Visit_Type__c, 
            e.Do_Not_Send_To_Premier__c, e.IsAllDayEvent,
            e.Mode__c, e.Subject,
            e.Overbooked__c, e.Resource_Type__c,
            e.Sale_Flag__c, e.ShowAs, e.Status_Reason__c,
            e.Status__c, e.Time_Band__c, e.Type__c, 
            e.Visit_Type__c, e.WhatId, e.WhoId, 
            e.OwnerId, e.RecordTypeId 
            FROM Event e WHERE e.AppointmentID__c = :appointmentId];
            
            return evt;
        }

       public Appointment__c[] getAppointments(String eventId) {
            Appointment__c[] app = [SELECT a.Id, a.Start__c, a.End__c, 
                                a.Subject__c, a.Assigned_To__c, a.Any_Time__c, a.EventId__c, 
                                a.Description__c, a.Converted_Visit_Type__c, 
                                a.Do_Not_Send_To_Premier__c,
                                a.Mode__c, a.Overbooked__c, a.RecordTypeId,
                                a.Resource_Type__c, a.Sale_Flag__c, a.Show_Time_As__c,
                                a.Status_Reason__c, a.Status__c, a.Time_Band__c, a.Type__c,
                                a.Visit_Type__c, a.Opportunity__c, a.Who__c 
                                FROM Appointment__c a 
                                WHERE a.EventId__c = :eventId];
                                
            return app; 
        }
    }

  
   static testMethod void editAppt_SetCancelled() 
   {
        string availableRecordID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Available');
        Setup s = new Setup();
        Test.startTest();
        Appointment__c app1 = s.createNewAppt1(false, '146 Pitt','test2@testorg.com');
        app1 = s.app1;
        // Edit Fields
        System.debug('----------------1 app1.Type__c = ' + app1.Type__c);
        System.debug('----------------1 app1.RecordTypeId = ' + app1.RecordTypeId);
        System.debug('----------------1 app1.Status__c = ' + app1.Status__c);
        
        app1.Subject__c = 'editAppt() subject'; 
        app1.Description__c = 'editAppt() description';
        app1.Converted_Visit_Type__c = false;
        app1.Do_Not_Send_To_Premier__c = false;
        app1.Mode__c = 'SA';
        app1.Overbooked__c = false;
        app1.Resource_Type__c = 'H'; 
        app1.Sale_Flag__c = true;
        app1.Show_Time_As__c = 'Out Of Office';
        app1.Status_Reason__c = 'HOUSE CLOSED';
        app1.Status__c = 'Cancelled';
        app1.Type__c = 'Technical';
        app1.Visit_Type__c = 'Recall Visit';
        app1.RecordTypeId = availableRecordID;
        app1.Overbooked__c = false;
        //app.Opportunity__c = opp.Id;
        
        Lock.apptReassignedLock = true;
        Lock.updatingOverbooked = false;
        Database.update(app1);
        
        System.debug('----------------1 app1.Status__c = ' + app1.Status__c);
        System.debug('----------------2 app1.Type__c = ' + app1.Type__c);
        System.debug('----------------2 app1.RecordTypeId = ' + app1.RecordTypeId);
        Lock.apptReassignedLock = true;
        Lock.updatingOverbooked = false;
        System.debug('app.Id: ' + app1.Id);
        // Get Event
        
        /*
        Event evt = s.getEvent(app1.Id);
        app1 = s.getAppointment(evt.Id);
        Test.stopTest();
        */
        
        // Check Event's fields
        //s.check(app, evt);
        //System.assertEquals(evt.OwnerId, s.userId);
        //System.assertEquals(app.Assigned_To__c, s.empId);
   }
   
   static testMethod void editAppt_Change_Assignment() 
   {
   		
        string availableRecordID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Available');
        Setup s = new Setup();
        Test.startTest();
        Appointment__c app1 = s.createNewAppt1(false, '146 Pitt','test2@testorg.com');
        app1 = s.app1;
        // Edit Fields
        System.debug('----------------1 app1.Type__c = ' + app1.Type__c);
        System.debug('----------------1 app1.RecordTypeId = ' + app1.RecordTypeId);
        System.debug('----------------1 app1.Status__c = ' + app1.Status__c);
        
        app1.Subject__c = 'editAppt() subject'; 
        app1.Description__c = 'editAppt() description';
        app1.Converted_Visit_Type__c = false;
        app1.Do_Not_Send_To_Premier__c = false;
        app1.Mode__c = 'SA';
        app1.Overbooked__c = true;
        app1.Resource_Type__c = 'H'; 
        app1.Sale_Flag__c = true;
        app1.Show_Time_As__c = 'Out Of Office';
        app1.Status_Reason__c = 'HOUSE CLOSED';
        app1.Status__c = 'Cancelled';
        app1.Type__c = 'Technical';
        app1.Visit_Type__c = 'Recall Visit';
        app1.RecordTypeId = availableRecordID;
        app1.Overbooked__c = false;
        //app1.Opportunity__c = opp.Id;
        
        Lock.apptReassignedLock = true;
        Lock.updatingOverbooked = false;
        Database.update(app1);
        
        System.debug('----------------1 app1.Status__c = ' + app1.Status__c);
        //System.debug('----------------2 app1.Type__c = ' + app1.Type__c);
        //System.debug('----------------2 app1.RecordTypeId = ' + app1.RecordTypeId);
        Lock.apptReassignedLock = true;
        Lock.updatingOverbooked = false;
        System.debug('app.Id: ' + app1.Id);
        // Get Event
        
        /*
        Event evt = s.getEvent(app1.Id);
        app1 = s.getAppointment(evt.Id);
        Test.stopTest();
        */
        
        // Check Event's fields
        //s.check(app, evt);
        //System.assertEquals(evt.OwnerId, s.userId);
        //System.assertEquals(app1.Assigned_To__c, s.empId);
   }
   
    
    static testMethod void editAppt1() {
        ////appreassigned true
        Setup s1 = new Setup();
        
        Appointment__c app1 = s1.createNewAppt1(false, '199 Pitt','test0@testorg.com');
        /*
        Account acc1 = new Account(name = 'editAppt1() acc', BillingStreet='19 Roundacre', 
                                BillingPostalCode='SW20 6DB', BillingCity='London', 
                                BillingCountry='UK', BillingState='London');
       
        Database.insert(acc1);
        
        Campaign camp1 = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp1);
        
        Opportunity opp1 = new Opportunity (LeadSource = 'MARCOMMS', name = 'edit1Appt() opp', AccountId = acc1.Id,
                                            CloseDate = Date.today().addyears(2), 
                                            StageName = 'Active',
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp1.Id);
        Database.insert(opp1);
        */
        // Edit Fields
        app1.Subject__c = 'editAppt() subject'; 
        app1.Description__c = 'editAppt() description';
        app1.Converted_Visit_Type__c = false;
        app1.Do_Not_Send_To_Premier__c = false;
        app1.Mode__c = 'SA';
        app1.Overbooked__c = true;
        app1.Resource_Type__c = 'H'; 
        app1.Sale_Flag__c = true;
        app1.Show_Time_As__c = 'Out Of Office';
        app1.Status_Reason__c = 'HOUSE CLOSED';
        app1.Status__c = 'Happened';
        app1.Type__c = 'Survey';
        app1.Visit_Type__c = 'Recall Visit';
        app1.Opportunity__c = opportunity.Id;
        
       
        Lock.apptReassignedLock = false;
        Lock.updatingOverbooked = true;
        update(app1);
        Lock.apptReassignedLock = false;
        Lock.updatingOverbooked = true;
        
        System.debug('app.Id: ' + app1.Id);
        // Get Event
        Event evt1 = s1.getEvent(app1.Id);
        app1 = s1.getAppointment(evt1.Id);
                    
        // Check Event's fields
        //s1.check(app1, evt1);
        //System.assertEquals(evt.OwnerId, s.userId);
        //System.assertEquals(app.Assigned_To__c, s.empId);
     }
     
    
    static testMethod void editApptFromEvent() {
        Setup s = new Setup();
        Test.startTest();
        Appointment__c newApp = s.createNewAppt1(false, '145 Pitt','test3@testorg.com');
        
        // Get Event
        Event evt = s.getEvent(newApp.Id);

        evt.Description = 'editApptFromEvt()';
        evt.Converted_Visit_Type__c = false;
        evt.Do_Not_Send_To_Premier__c = true;
        evt.Mode__c = 'Merchant Delivery';
        evt.Overbooked__c = false;
        evt.Resource_Type__c = 'V';
        evt.Sale_Flag__c = false;
        evt.ShowAs = 'Busy';
        evt.Status_Reason__c = 'SAS CANCELLED DURING SURVEY';
        evt.Status__c = 'Happened';
        evt.Type__c = 'Waste Collection';
        evt.Visit_Type__c = 'First Visit';

        Lock.clearAll();
        Database.update(evt);               

        Appointment__c app = s.getAppointment(evt.Id);
        evt = s.getEvent(app.Id);
        Test.stopTest();
                            
        // Check Appointment's fields
        //s.check(app, evt);
        //System.assertEquals(evt.OwnerId, s.userId);
        //System.assertEquals(app.Assigned_To__c, s.empId);
                     
    }
    
   
   
    static testMethod void editEvt() {
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(false, true, '144 Pitt');

        // Edit Fields
        evt.Description = 'editEvt()';
        evt.Converted_Visit_Type__c = true;
        evt.Do_Not_Send_To_Premier__c = true;
        evt.Mode__c = 'Merchant Delivery';
        evt.Overbooked__c = false;
        evt.Resource_Type__c = 'V';
        evt.Sale_Flag__c = false;
        evt.ShowAs = 'Busy';
        evt.Status_Reason__c = 'SAS CANCELLED DURING SURVEY';
        evt.Status__c = 'Happened';
        evt.Type__c = 'Waste Collection';
        evt.Visit_Type__c = 'First Visit';

        Lock.clearAll();
        Database.update(evt);
        
        // Get Appointment
        
        //Appointment__c app = s.getAppointment(evt.Id);
        //evt = s.getEvent(app.Id);
        Test.stopTest();
        
        // Check Appointment's fields
        //s.check(app, evt);
       // System.assertEquals(evt.OwnerId, s.userId);
       // System.assertEquals(app.Assigned_To__c, s.empId);       
       
    }
   
  
   static testMethod void editEvtFromAppt() {
        Setup s = new Setup();
        Test.startTest();
        Event newEvt = s.createNewEvt(false, true, '143 Pitt');
        system.debug('newEvt.id----' +newEvt.id);
        /*
        Account acc = new Account(name = 'editEvt() acc', BillingStreet='14 Roundacre', 
                                    BillingPostalCode='SW19 6DB', BillingCity='London', 
                                    BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        
        Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp);
        
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'editEvt() opp', AccountId = acc.Id,
                                            CloseDate = Date.today().addyears(2), 
                                            StageName = 'Active', 
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id);
        
        Database.insert(opp);
        */
        Appointment__c app = s.getAppointment(newEvt.Id);

        // Edit Fields
        app.Subject__c = 'editEvtFromAppt() subject'; 
        app.Description__c = 'editEvtFromAppt() description';
        app.Converted_Visit_Type__c = true;
        app.Do_Not_Send_To_Premier__c = false;
        app.Mode__c = 'Electrician';
        app.Overbooked__c = true;
        app.Resource_Type__c = 'H'; 
        app.Sale_Flag__c = true;
        app.Show_Time_As__c = 'Out Of Office';
        app.Status_Reason__c = 'HOUSE CLOSED';
        app.Status__c = 'Happened';
        app.Type__c = 'Technical';
        app.Visit_Type__c = 'Recall Visit';
        //app.Opportunity__c = opp.Id;
        
        Lock.clearAll();
        Database.update(app);

        Event evt = s.getEvent(app.Id);
        app = s.getAppointment(evt.Id);
        Test.stopTest();

        // Check Event's fields
        //s.check(app, evt);
          
    }
   
  static testMethod void deleteAppt() {
        Setup s = new Setup();
        Test.startTest();
        Appointment__c app = s.createNewAppt1(false, '142 Pitt','test4@testorg.com');

        // Check Event exists
        Event[] evtBefore = s.getEvents(app.Id);
       // System.assertEquals(1, evtBefore.size());
        
        // Delete Appointment
        Lock.clearAll();
        Database.delete(app);
        
        // Check Event no longer exists
        Event[] evtAfter = s.getEvents(app.Id);
        Test.stopTest();
    }
    
   
  
    static testMethod void deleteApptFromEvt() {
        Setup s = new Setup();
        Test.startTest();
        Appointment__c app = s.createNewAppt1(false, '141 Pitt','test8@testorg.com');
        String appId = app.Id;
        
        // Check Event exists
        Event[] evtBefore = s.getEvents(appId);
        //System.assertEquals(1, evtBefore.size());
        String evtId = evtBefore[0].Id;
        
        // Delete Appointment
        Lock.clearAll();
        Database.delete(evtBefore);
        
        // Check Event no longer exists
        Event[] evtAfter = s.getEvents(appId);
       
        
        // Check Appointment no longer exists
        Appointment__c[] appBefore = s.getAppointments(evtId);
        System.debug('appBefore.size(): ' + appBefore.size());
        Test.stopTest();
        
    }  
    
   
 
   static testMethod void deleteEvt() {
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(false, true, '140 Pitt');
        
        // Check Appointment exists
        Appointment__c[] appBefore = s.getAppointments(evt.Id);
       // System.assertEquals(1, appBefore.size());
        
        // Delete Event
        Lock.clearAll();
        Database.delete(evt);
        
        // Check Appointment no longer exists
        Appointment__c[] appAfter = s.getAppointments(evt.Id);
        Test.stopTest();
       
    }
    
    

   static testMethod void deleteEvtFromAppt() {
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(false, true, '139 Pitt');
        String evtId = evt.Id;
        
        // Check Appointment exists
        Appointment__c[] appBefore = s.getAppointments(evtId);
        //System.assertEquals(1, appBefore.size());
        String appId = appBefore[0].Id;
        
        // Delete Appointment
        Lock.clearAll();
        Database.delete(appBefore);
        
        // Check Appointment no longer exists
        Appointment__c[] appAfter = s.getAppointments(evtId);
        //System.assertEquals(0, appAfter.size());
        
        // Check Event no longer exists
        Event[] evtAfter = s.getEvents(appId);
        //System.debug('evtAfter.size(): ' + evtAfter.size());
        Test.stopTest();
           
    }
    
   
    static testMethod void createApptInstallation() {
        Setup s = new Setup();
        Test.startTest();        
        Appointment__c app = s.createNewAppt1(true, '138 Pitt','test55@testorg.com');

        Event[] evt = s.getEvents(app.Id);
        Test.stopTest();
            
        //System.assertEquals(0, evt.size());
    }
	
   

    static testMethod void createEventNoWhoOrWhat() {
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(false, false, '137 Pitt');

        Appointment__c[] apps = s.getAppointments(evt.Id);      
        Test.stopTest(); 
        //System.assertEquals(0, apps.size());
    }
    
     static testMethod void createEventWhoAsLead() {
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(true, true, '136 Pitt','0002998');

        Appointment__c[] apps = s.getAppointments(evt.Id);  
            
        //System.assertEquals(0, apps.size());
        /*
        Event evt2 = s.createNewEvt(true, false, '135 Pitt','0002999');
        
        Appointment__c[] apps2 = s.getAppointments(evt2.Id);*/ 
        Test.stopTest();   
        //System.assertEquals(0, apps2.size());        
    }
  
    

   static testMethod void createEventWhatAsOpp() {
   		
   		
        /*
        set<ID> cnts = new set<ID>(); 
        for(Contact cnt :[Select c.id, c.Primary_Contact__c, c.AccountId from Contact c 
	                where  c.AccountId = null and  c.Primary_Contact__c =true])
        {
        	cnts.Add(cnt.id);
        }
        
        
        for(List<Appointment__c> appts :[Select id from Appointment__c 
                where Who__c in:cnts])
        {
        	delete appts;
        }
        
        for(List<Contact> cnts1 :[Select c.id, c.Primary_Contact__c, c.AccountId from Contact c 
                where  c.AccountId = null and  c.Primary_Contact__c =true])
        {
        	delete cnts1;
        }
        
        */
        
   		
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(false, false, '121 Pitt', '0002998');
        
        Appointment__c[] apps = s.getAppointments(evt.Id);
        
        system.debug('99999999apps---------......'+apps);
        
        //System.assertEquals(0, apps.size());
        
        /*Event evt2 = s.createNewEvt(false, true, '132 Pitt', '0002999');

        Appointment__c[] apps2 = s.getAppointments(evt2.Id);*/
        Test.stopTest();
        //System.assertEquals(1, apps2.size());
    }
    
		static testMethod void createEventWhatNotOpp() {
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(true, false, '131 Pitt','0002998');
        
        Appointment__c[] apps = s.getAppointments(evt.Id);  
            
        //System.assertEquals(0, apps.size());
        /*
        Event evt2 = s.createNewEvt(false, false, '130 Pitt','0002999');

        Appointment__c[] apps2 = s.getAppointments(evt2.Id);*/
        Test.stopTest();    
        //System.assertEquals(0, apps2.size());
    }
    
    	static testMethod void createEventWhoNotLead() {
        Setup s = new Setup();
        Test.startTest();
        Event evt = s.createNewEvt(false, true, '134 Pitt','0002998');
        
        Appointment__c[] apps = s.getAppointments(evt.Id);  
            
        //System.assertEquals(1, apps.size());
        /*
        Event evt2 = s.createNewEvt(false, false, '133 Pitt','0002999');
        
        Appointment__c[] apps2 = s.getAppointments(evt2.Id);
        Test.stopTest();*/       
        //System.assertEquals(0, apps2.size());               
        
    }
        
    
  
  
   static testMethod void changeFromInstallation() {
        Setup s = new Setup();
        Test.startTest();
        Appointment__c appInstallation = s.createNewAppt1(true, '129 Pitt','test63@testorg.com');

        Event[] evtBefore = s.getEvents(appInstallation.Id);
            
        //System.assertEquals(0, evtBefore.size());
        
        appInstallation.Type__c = 'Survey';
        
        Lock.clearAll();
        Database.update(appInstallation);

        Event[] evtAfter = s.getEvents(appInstallation.Id);     
        Test.stopTest();
        //System.assertEquals(1, evtAfter.size());
        
    }
    
   
   static testMethod void changeToInstallation() {
        Setup s = new Setup();
        Test.startTest();
        Appointment__c appNotInstallation = s.createNewAppt1(false, '128 Pitt','test65@testorg.com');

        Event[] evtBefore = s.getEvents(appNotInstallation.Id);
            
        //System.assertEquals(1, evtBefore.size());
        
        appNotInstallation.Type__c = 'Electrical';
        
        Lock.clearAll();
        Database.update(appNotInstallation);

        Event[] evtAfter = s.getEvents(appNotInstallation.Id);      
        Test.stopTest();
        //System.assertEquals(0, evtAfter.size());
    }
    
  static testMethod void testDatabaseOps1() {
        
        Setup s = new Setup();
        Test.startTest();
        Appointment__c app1 = s.createNewAppt1(false, '127 Pitt','test66@testorg.com');
        //Appointment__c app2 = s.createNewAppt(false, '126 Pitt','test68@testorg.com');
        
        //Map<ID, Appointment__c> apps = new Map<ID, Appointment__c> {app1.Id => app1, app2.Id => app2}; 
        Map<ID, Appointment__c> apps = new Map<ID, Appointment__c> {app1.Id => app1};
        Map<ID, Event> evts = new Map<ID, Event>();

        Event[] events = [SELECT e.Id, e.AppointmentID__c FROM Event e WHERE e.AppointmentID__c IN :apps.keySet()];     
        for(Event e : events) {
            evts.put(e.AppointmentID__c, e);
        }
        
        DatabaseOperations.databaseInsert(apps, evts);
        Test.stopTest();
    }
    
  

   static testMethod void testDatabaseOpsDel() {
        Setup s = new Setup();
        Test.startTest();
        Appointment__c app1 = s.createNewAppt1(false, '123 Pitt','test69@testorg.com');
        //Appointment__c app2 = s.createNewAppt(false, '122 Pitt','test71@testorg.com');
        
        //Map<ID, Appointment__c> apps = new Map<ID, Appointment__c> {app1.Id => app1, app2.Id => app2}; 
        Map<ID, Appointment__c> apps = new Map<ID, Appointment__c> {app1.Id => app1};
        
        Event[] events = [SELECT e.Id, e.AppointmentID__c FROM Event e WHERE e.AppointmentID__c IN :apps.keySet()];     
        Map<ID, ID> eventIDs = new Map<ID, ID>();
        
        for(Event e : events) {
            eventIDs.put(e.Id, e.AppointmentID__c);
        }
        
        Lock.clearAll();
        Database.delete(new List<ID>(eventIDs.keySet()));
        Lock.clearAll();
        DatabaseOperations.databaseDelete(apps, eventIds);  
        Test.stopTest();
    }
    
    /* added as a part of phase 5 for delete_event_installer trigger 
        Date : 11/06/2010
        Change History :
    */
}