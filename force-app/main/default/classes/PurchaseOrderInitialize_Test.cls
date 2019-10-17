@isTest
private class PurchaseOrderInitialize_Test {    
               
               
               static testMethod void PurchaseOrderInitializeTestMethod(){
             
               //ApexPages.standardController controller = new ApexPages.standardController(new Job__c());
               Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
               insert account;
        
               Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
               insert contact;
        
               Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
               insert supplier;
         
               Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
        
               insert emp;
               
               
               Profile PInstal = [select id from Profile where name = 'System Administrator'];
               User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
               insert UInstal1;
               
               Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),Platform__c='SFDC',                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);                                 
         
               insert opportunity;
              
               BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
               insert quote;
        
               Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
               Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


              insert product;
              insert quoteProduct;

        
               District__c district = [Select id from District__c limit 1];
               
               //if job status is Planned and iDairyEntry is True
        
        
        
              Job__c job = new Job__c();

              job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true,Status__c='Planned', Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
               insert job;
               
               Test.startTest();
               ApexPages.standardController controller = new ApexPages.standardController(job);
               PurchaseOrderInitialize poi=new PurchaseOrderInitialize(controller);
               
               poi.init();
               poi.returnBack();
               
               job.Status__c='Pending';
               update job;
               
               system.runAs(UInstal1)
               {
               ApexPages.standardController controller1 = new ApexPages.standardController(job);
               PurchaseOrderInitialize poi1=new PurchaseOrderInitialize(controller1);
               
               poi1.init();
               poi1.returnBack();
               }
               job = [select Order_Locking_User__c,order_locking_time__c from Job__c where Id = : job.id];
               system.assertnotequals(job.Order_Locking_User__c,userinfo.getuserid());
               system.assertnotequals(job.order_locking_time__c, system.now());
               Test.stopTest();
               
    
               }
               
               

	static testMethod void PremierPlatformTestMethod(){
              
                       
               
               //ApexPages.standardController controller = new ApexPages.standardController(new Job__c());
               Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
               insert account;
        
               Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
               insert contact;
        
               Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
               insert supplier;
         
               Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
        
               insert emp;
               
               
               Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
               User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
               insert UInstal1;
               
               
               Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id,Platform__c='Premier', LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);                                 
         
         		insert opportunity;
             
               
               BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
               insert quote;
        
               Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
               Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
    
              insert product;
              insert quoteProduct;

        
               District__c district = [Select id from District__c limit 1];
               
               //if job status is Planned and iDairyEntry is True
        
        
        
              Job__c job = new Job__c();

              job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true,Status__c='Planned', Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
               insert job;
               /*
               Test.startTest();
               ApexPages.standardController controller = new ApexPages.standardController(job);
               PurchaseOrderInitialize poi=new PurchaseOrderInitialize(controller);
               
               poi.init();
               poi.returnBack();
               job.Status__c='Planned';
               update job;
               
               ApexPages.standardController controller1 = new ApexPages.standardController(new Job__c());
               PurchaseOrderInitialize poi1=new PurchaseOrderInitialize(controller1);
               poi1.blNoDiaryEntry=true;
               poi1.init();
               poi1.returnBack();
               Test.stopTest(); */
               
            
               }
               
               
	static testMethod void PremierPlatformTest_Completedjob()
	{
               //ApexPages.standardController controller = new ApexPages.standardController(new Job__c());
	   Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
	                        BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
       insert account;

       Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                             MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                             FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
       insert contact;

       Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
       insert supplier;
 
       Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                 Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 

       insert emp;
           
               
       Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
       User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                        emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                        localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
       insert UInstal1;
       
       
       Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                          AccountId=account.Id,Platform__c='Premier', LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);                                 
 
 		insert opportunity;
     
       
       BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                    POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                     Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                     is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
       insert quote;

       Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);

       Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                    Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                    Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
    
	   insert product;
       insert quoteProduct;

        
       District__c district = [Select id from District__c limit 1];
               
       //if job status is Planned and iDairyEntry is True
        
        
        
       Job__c job = new Job__c();

       job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                        Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                        Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                        Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                        Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                        Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                        Double_Handed_Job__c = true,Status__c='Completed', Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                 

                
       insert job;
               
       
       job.Status__c='Planned';
       update job;
       
       /*ApexPages.standardController controller = new ApexPages.standardController(job);
       PurchaseOrderInitialize poi=new PurchaseOrderInitialize(controller);
       poi.init();
       poi.returnBack();
       */
       
       Week__c week = setupForDEs(emp);
       List<Diary_Entry__c> lstde = createDEs1(emp, job);
       
       ApexPages.standardController controller1 = new ApexPages.standardController(job);
       PurchaseOrderInitialize poi1=new PurchaseOrderInitialize(controller1);
       poi1.blNoDiaryEntry=false;
       poi1.init();
       poi1.returnBack();
       Job__c tempjob = (Job__c) controller1.getRecord();
		System.debug('---------- count :' + [Select count() from Diary_Entry__c where Job__c=:tempjob.Id]);
            
   }
   
   static Week__c setupForDEs(Employee__c emp) {
		Shift_Pattern__c sp = new Shift_Pattern__c(Name='Testing Shift Pattern', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
													Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
													Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
													Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
													Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
													Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
													Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
													Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
		Database.insert(sp);
		
		Week__c w = new Week__c(Employee__c = emp.ID, Shift_Pattern__c = sp.ID, Week_Commencing__c = Date.today().toStartOfWeek(),
								Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
								Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
		Database.insert(w);

		return w;
	}
	
	
	static List<Diary_Entry__c> createDEs1(Employee__c emp, Job__c job) {
		Week__c w = setupForDEs(emp);
		Date startOfThisWeek = Date.today().addDays(7).toStartOfWeek();
		
		Diary_Entry__c de1 = new Diary_Entry__c(Week__c = w.ID, Hours__c = 0, job__c =job.id,
									Start__c = DateTime.newInstance(startOfThisWeek, Time.newInstance(8,0,0,0)), 
									End__c = DateTime.newInstance(startOfThisWeek.addDays(4), Time.newInstance(17,0,0,0)), 
									RecordTypeID = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability'));

		return insertDEs(new List<Diary_Entry__c> {de1});
	}
	
	static List<Diary_Entry__c> insertDEs(List<Diary_Entry__c> des) {
		Database.insert(des);
		Set<ID> deIDs = new Set<ID>();
		for(Diary_Entry__c de : des) {
			deIDs.add(de.ID);
		}
		
		List<Diary_Entry__c> fromDB = 
			[select d.ID, d.Week__r.Shift_Pattern__r.Monday_Start_Time__c, d.Week__r.Shift_Pattern__r.Monday_End_Time__c,
					d.Week__r.Shift_Pattern__r.Tuesday_Start_Time__c, d.Week__r.Shift_Pattern__r.Tuesday_End_Time__c,
					d.Week__r.Shift_Pattern__r.Wednesday_Start_Time__c, d.Week__r.Shift_Pattern__r.Wednesday_End_Time__c,
					d.Week__r.Shift_Pattern__r.Thursday_Start_Time__c, d.Week__r.Shift_Pattern__r.Thursday_End_Time__c,
					d.Week__r.Shift_Pattern__r.Friday_Start_Time__c, d.Week__r.Shift_Pattern__r.Friday_End_Time__c,
					d.Week__r.Shift_Pattern__r.Saturday_Start_Time__c, d.Week__r.Shift_Pattern__r.Saturday_End_Time__c,
					d.Week__r.Shift_Pattern__r.Sunday_Start_Time__c, d.Week__r.Shift_Pattern__r.Sunday_End_Time__c,
					d.Week__r.Monday_Available_Hours__c, d.Week__r.Tuesday_Available_Hours__c,
                    d.Week__r.Wednesday_Available_Hours__c, d.Week__r.Thursday_Available_Hours__c,
                    d.Week__r.Friday_Available_Hours__c, d.Week__r.Saturday_Available_Hours__c,
                    d.Week__r.Sunday_Available_Hours__c, d.Record_Type__c, d.Start__c, d.End__c,
                    d.Week__r.Monday_Start_Time__c, d.Week__r.Monday_End_Time__c,
                    d.Week__r.Tuesday_Start_Time__c, d.Week__r.Tuesday_End_Time__c,
                    d.Week__r.Wednesday_Start_Time__c, d.Week__r.Wednesday_End_Time__c,
                    d.Week__r.Thursday_Start_Time__c, d.Week__r.Thursday_End_Time__c,
                    d.Week__r.Friday_Start_Time__c, d.Week__r.Friday_End_Time__c,
                    d.Week__r.Saturday_Start_Time__c, d.Week__r.Saturday_End_Time__c,
                    d.Week__r.Sunday_Start_Time__c, d.Week__r.Sunday_End_Time__c, Job__c
				from Diary_Entry__c d where d.Id IN :deIDs];
		return fromDB;
	}
}