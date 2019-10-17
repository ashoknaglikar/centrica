@isTest
private class aUPD_AutocancelAppointmentQuoteCanc_test {
    
     
     
    static testMethod void myUnitTest() {
        
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=district.Id, Code__c='yyyyyyyy');                
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=Acc.Id,Salutation='Mr');
        insert contact;                                 
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = System.today()+2,LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        system.debug('opty--->'+opty);
        
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
                                 Status_Reason__c = 'Purchase Elsewhere', Status__c ='New',
                                 Type__c = 'Sales', Opportunity__c = opty.id,
                                  Who__c = who
                                 );	
         
         app.Big_Machines_Quote_Number__c = 'Test Quote 1';
         	                                 
         insert app;
         
        system.debug('emp--->'+emp);           
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test Quote 1', Opportunity__c= opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='No Visit - House Closed',
        										   			  bmStatusReason__c = 'House Closed' , App_Assigned_To__c= 'test - 2991',closeDate__c= system.today()+7,
        										   			  secondVisitComplete__c= '',Surveyor_Name__c='' );
        										   			  
        insert quote;  
        
        update quote;            
          
        Appointment__c app_test = [Select Status__c from Appointment__c where ID = :app.Id limit 1];
        
        System.assertEquals(app_test.Status__c, 'House Closed'); 
                                     
    } 
     static testMethod void myUnitTestmethod() {
        
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=district.Id, Code__c='yyyyyyyy');                
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=Acc.Id,Salutation='Mr');
        insert contact;                                 
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = System.today()+2,LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        system.debug('opty--->'+opty);
        
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
                                 Status_Reason__c = 'Purchase Elsewhere', Status__c ='New',
                                 Type__c = 'Sales', Opportunity__c = opty.id,
                                  Who__c = who
                                 );	
                                 	                                 
         app.Big_Machines_Quote_Number__c = 'Test Quote 2';
         
         insert app;
         
        system.debug('emp--->'+emp);           
        
    	string fvc;
    	Date firstvisit = system.today()+7;
    	fvc = firstvisit.format(); 
    	system.debug('firstvisitcomplete-->'+fvc );
    	string actualFVC =  fvc.substring(6,10)+'-'+fvc.substring(3,5)+'-'+fvc.substring(0,2);
    	system.debug('actualFVC-->'+actualFVC );
    	BigMachines_Quote__c quote1 = new BigMachines_Quote__c(Name = 'Test Quote 2', Opportunity__c= opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='No Visit - House Closed',
        										   			  bmStatusReason__c = 'House Closed' , App_Assigned_To__c= 'test - 2991',
        										   			  secondVisitComplete__c= '',Surveyor_Name__c='',firstVisitComplete__c= actualFVC);                           
        insert quote1;      
        
        update quote1;            
          
        Appointment__c app_test = [Select Status__c from Appointment__c where ID = :app.Id limit 1];
        
        System.assertEquals(app_test.Status__c, 'House Closed'); 
                                     
    }                                                                     
}