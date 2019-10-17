@isTest
private class PriorityInstallDetailsController_Test {
	
	static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
	static void createData()
	{
		//Prepare account data
		account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        //Prepare contact data
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
                                     
        insert contact;
        
        //prepare supplier data
        supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        //prepare employee data
        emp = new Employee__c(Name = 'testJI1', Salesforce_User__c = UserInfo.getUserId() ,First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                              Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        insert emp;
        
        //Prepare opportunity data
        opp = new Opportunity (Name = 'Test1 Opp', AccountId = account.Id,
                                                CloseDate = Date.today().addyears(1), 
                                                StageName = 'Active',Override_Billing_checks__c=false,
                                                Product_Interest__c='Central Heating Boiler',
                                                LeadSource='Engineer', Referral_Employee__c =emp.id,
                                                Customer_Category_Record_Modified_By__c = UserInfo.getUserId());
        
        insert opp;
	}
    static testMethod void myUnitTest1() {
    	createData();
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest2() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'Yes';
    	opp.Does_the_customer_have_hot_water__c = 'No';
    	opp.Is_the_customer_vulnerable__c = 'Yes';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest3() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'Yes';
    	opp.Does_the_customer_have_hot_water__c = 'No';
    	opp.Is_the_customer_vulnerable__c = 'No';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    static testMethod void myUnitTest4() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'No';
    	opp.Does_the_customer_have_hot_water__c = 'Yes';
    	opp.Is_the_customer_vulnerable__c = 'Yes';
    	opp.Customer_have_any_other_form_of_HEAT__c = 'Yes';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest5() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'No';
    	opp.Does_the_customer_have_hot_water__c = 'Yes';
    	opp.Is_the_customer_vulnerable__c = 'No';
    	opp.Customer_have_any_other_form_of_HEAT__c = 'Yes';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
     static testMethod void myUnitTest6() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'No';
    	opp.Does_the_customer_have_hot_water__c = 'Yes';
    	opp.Is_the_customer_vulnerable__c = 'Yes';
    	opp.Customer_have_any_other_form_of_HEAT__c = 'No';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest7() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'No';
    	opp.Does_the_customer_have_hot_water__c = 'Yes';
    	opp.Is_the_customer_vulnerable__c = 'No';
    	opp.Customer_have_any_other_form_of_HEAT__c = 'No';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest8() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'No';
    	opp.Does_the_customer_have_hot_water__c = 'No';
    	opp.Is_the_customer_vulnerable__c = 'Yes';
    	opp.Customer_have_any_other_form_of_HEAT__c = 'Yes';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest9() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'No';
    	opp.Does_the_customer_have_hot_water__c = 'No';
    	opp.Is_the_customer_vulnerable__c = 'Yes';
    	opp.Customer_have_any_other_form_of_HEAT__c = 'No';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest10() {
    	createData();
    	opp.Is_the_customers_boiler_working__c = 'No';
    	opp.Does_the_customer_have_hot_water__c = 'No';
    	opp.Is_the_customer_vulnerable__c = 'No';
    	opp.Customer_have_any_other_form_of_HEAT__c = 'No';
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
    
    static testMethod void myUnitTest11() {
    	createData();
    	opp.Latest_customer_category__c = 99;
    	update opp;
    	ApexPages.StandardController sc = new ApexPages.StandardController(opp);
      	PriorityInstallDetailsController priorityInstall = new PriorityInstallDetailsController(sc);
        priorityInstall.cancelDetails();
        priorityInstall.editDetails();
        priorityInstall.saveDetails();
        
    }
}