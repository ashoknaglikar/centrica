@isTest
private class instUpdateCustCategoaryMasterRecord_Test {
	
	static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
    static string sgcCustCatRecTypeId;
    static string salesCustCatRecTypeId;
    static string installCustCatRecTypeId;
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
                                                Customer_Category_Record_Modified_By__c = UserInfo.getUserId(),
                                                pending_update_to_customer_category__c = true);
        
        insert opp;
        
        //Fetch record type data
        RecordType[] recordTypes = [SELECT r.Id, r.sObjectType, r.Name FROM RecordType r WHERE r.IsActive = true];
        for(RecordType rt : recordTypes)
        {
        	if(rt.sObjectType == 'Customer_category__c')
        	{
        		if(rt.Name == 'SGC')
        		{
        			sgcCustCatRecTypeId = rt.id;
        		}
        		else if(rt.Name == 'Sales')
        		{
        			salesCustCatRecTypeId = rt.id;
        		}
        		else
        		{
        			installCustCatRecTypeId = rt.id;
        		}
        	}
        }
        
	}
    static testMethod void testCustCategoaryMasterRecord1() {
    	createData();
        Customer_category__c cust = new Customer_category__c(Opportunity__c = opp.id , RecordTypeId = sgcCustCatRecTypeId);
        insert cust;
        opp.pending_update_to_customer_category__c = true;
        opp.Is_the_customers_boiler_working__c = 'Yes';
        opp.Last_customer_cat_info_update_source__c = 'SGC';
        update opp;
    }
    
    static testMethod void testCustCategoaryMasterRecord2() {
    	createData();
        Customer_category__c cust = new Customer_category__c(Opportunity__c = opp.id , RecordTypeId = salesCustCatRecTypeId);
        insert cust;
        opp.pending_update_to_customer_category__c = true;
        opp.Is_the_customers_boiler_working__c = 'No';
        opp.Last_customer_cat_info_update_source__c = 'Sales';
        update opp;
    }
    
    static testMethod void testCustCategoaryMasterRecord3() {
    	createData();
        Customer_category__c cust = new Customer_category__c(Opportunity__c = opp.id , RecordTypeId = installCustCatRecTypeId);
        insert cust;
        opp.pending_update_to_customer_category__c = true;
        opp.Is_the_customers_boiler_working__c = 'Yes';
        opp.Does_the_customer_have_hot_water__c = 'Yes';
        opp.Last_customer_cat_info_update_source__c = 'Installation';
        update opp;
    }
    
    static testMethod void testCustCategoaryMasterRecord4() {
    	createData();
        Customer_category__c cust = new Customer_category__c(Opportunity__c = opp.id , RecordTypeId = installCustCatRecTypeId);
        insert cust;
        opp.pending_update_to_customer_category__c = true;
        opp.Is_the_customers_boiler_working__c = 'Yes';
        opp.Does_the_customer_have_hot_water__c = 'Yes';
        opp.Last_customer_cat_info_update_source__c = 'Installation';
        opp.StageName = 'Expired';
        update opp;
    }
    
    static testMethod void testCustCategoaryMasterRecord5() {
    	createData();
        opp.pending_update_to_customer_category__c = true;
        opp.Is_the_customers_boiler_working__c = 'Yes';
        opp.Does_the_customer_have_hot_water__c = 'Yes';
        opp.Last_customer_cat_info_update_source__c = 'SGC';
        update opp;
    }
    
     static testMethod void testCustCategoaryMasterRecord6() {
    	createData();
        opp.pending_update_to_customer_category__c = true;
        opp.Is_the_customers_boiler_working__c = 'Yes';
        opp.Does_the_customer_have_hot_water__c = 'Yes';
        opp.Last_customer_cat_info_update_source__c = 'Sales';
        update opp;
    }
    
     static testMethod void testCustCategoaryMasterRecord7() {
    	createData();
        opp.pending_update_to_customer_category__c = true;
        opp.Is_the_customers_boiler_working__c = 'Yes';
        opp.Does_the_customer_have_hot_water__c = 'Yes';
        opp.Last_customer_cat_info_update_source__c = 'Installation';
        update opp;
    }
}