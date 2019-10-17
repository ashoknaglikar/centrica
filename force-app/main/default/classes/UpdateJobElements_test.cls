@isTest
private class UpdateJobElements_test
{
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Employee__c emp;
    static Job__c job;
    static List<String> ordlistId;
    static Installer__c installer;
    static User user;
    static List<Installer__c> lstinstaller;
    static Job_Element__c JE1;
    static List<Order__c> ordlst1;
    static Order__c ord1;
    
    static testMethod void createTestData()
	{
		account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
		insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
        insert contact;
        
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
         
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
        
        insert emp;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);                                 
         
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
        
        job = new Job__c();

        job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        insert job;
        
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        JE.type__c = 'Work';
        JE.Status__c = 'Active'; 

        insert JE;
        //update job;
        
        JE.type__c = 'Material';
        
        update JE;
        //update job;
        
        Order__c ord = new Order__c();
        ord.Job__c= job.Id;
        insert ord;
        
        
        JE1= new Job_Element__c();
        JE1.Job__c = job.Id;
        JE1.type__c = 'Work';
        JE1.Status__c = 'Active'; 
        insert JE1;
        
        ord1 = new Order__c();
        ord1.Job__c= job.Id;
        ord1.SAP_Number__c='12';
        ord1.Status__c='Active';
        ord1.Sync__c=true;
        ord1.SAP_Number__c='1234';
        ord1.Supplier__c=supplier.Id;
        ord1.Order_Value__c=456; 
        ord1.Amendment_Number__c=678;
        ord1.Type__c='Material';
         //Supplier__r.Name
         //Supplier__r.Supplier_Num__c
        //Amended_or_Removed_Items__c
        ord1.Order_Date__c=System.today();
        ord1.Fax_Setup__c=true;
        // ord.Order_Date__c.format();
        insert ord1;
        ordlst1 = new List<Order__c>();
        ordlst1.add(ord1);
        
        ordlistId=new List<String>();
        ordlistId.add(ord.Id);
        
        Order_Line_Item__c OrdLine = new Order_Line_Item__c();
        OrdLine.Order_Line_Item_Number__c=714;
        OrdLine.P5_Job_Element__c=JE.Id;
        OrdLine.P5_Purchase_Order__c=ord.Id;
        Ordline.P5_Product__c=product.Id;
        
        Ordline.P5_Status_c__c='Active';
        insert OrdLine;
        
       //user = new User(Select u.Username, u.TimeZoneSidKey, u.ProfileId, u.LocaleSidKey, u.LastName, u.LanguageLocaleKey, u.EmailEncodingKey, u.Email,CommunityNickname,Alias);
       //insert user;
       installer= new Installer__c(User__c=UInstal1.Id,Job__c=job.Id,Installer_Status__c='Inactive');
       insert installer;
       lstinstaller = new List<Installer__c>();
       lstinstaller.add(installer);
       
       
	}
    
	static testMethod void testCancelOrderLineItems()
	{ 
		createTestData();
		
        UpdateJobElements.cancelOrderLinesFuture(ordlistId);
	}
	
	static testMethod void testCancelElementsItems()
	{ 
		createTestData();
		Set<String> jobIDs = new Set<String>{job.Id};
        UpdateJobElements.cancelJobElementsFuture(jobIDs);
	}
	static testMethod void testSuspendJobLineItems()
	{ 
		createTestData();
		
        UpdateJobElements.suspendJobElementsFuture(job.Id,True);
	}
	
	static testMethod void testSuspendJobLineItems2()
	{ 
		createTestData();
		
        UpdateJobElements.suspendJobElementsFuture(job.Id,false);
	}
	
	static testMethod void testUnSuspendJobLineItems()
	{ 
		createTestData();
		
		UpdateJobElements.unsuspendJobElementsFuture(job.Id);
	}
	
	static testMethod void suspendJobElementswithNoupdatejobelements()
	{ 
		createTestData();
		
		UpdateJobElements.suspendJobElementsFuture(job.Id,False);
	}
	
	/**
	This methos is added to complete the coverage of bug fix: Cancel itinerary order too on suspending the job.
	DATE: 21-FEB-2011. 
	*/
	
	static testMethod void testSuspendJobAndCancelWorkItineraryOrder()
	{ 
		createTestData();
		Job_Element__c JE2 = new Job_Element__c();
        JE2.Job__c = job.Id;
        JE2.type__c = 'Work';
        JE2.Status__c = 'Active'; 
        JE2.P5_IsItinerary__c = true;

        insert JE2;
          
        Product2 product = new Product2(ProductCode='AB275', Name='AB275', BigMachines_Part_Number__c='AB275',  IsActive = true);
                  
        Order__c ord2 = new Order__c();
        ord2.Job__c= job.Id;
        ord2.SAP_Number__c='12';
        ord2.Status__c='Active';
        ord2.Sync__c=true;
        ord2.SAP_Number__c='1235';
        ord2.Supplier__c=supplier.Id;
        ord2.Order_Value__c=456; 
        ord2.Amendment_Number__c=678;
        ord2.Type__c='Itinerary';
        ord2.Order_Date__c=System.today();
        ord2.Fax_Setup__c=true;
        insert ord2;
        List<Order__c> ordlst2 = new List<Order__c>();
        ordlst2.add(ord2);
        
               
        Order_Line_Item__c OrdLine3 = new Order_Line_Item__c();
        OrdLine3.Order_Line_Item_Number__c=714;
        OrdLine3.P5_Job_Element__c=JE2.Id;
        OrdLine3.P5_Purchase_Order__c=ord2.Id;
        OrdLine3.P5_Product__c=product.Id;
        OrdLine3.P5_Type__c='Material';
        
        OrdLine3.P5_Status_c__c='Active';
        insert OrdLine3;
		
        UpdateJobElements.suspendJobElementsFuture(job.Id,True);
	}
}