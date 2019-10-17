@isTest
private class EnMassNBBSInterface_test {

	static NIAS_Code__c Nias;
	static  List<Opportunity> oppList = new List<Opportunity>();
    static testMethod void myUnitTest() {
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
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer', Emp_type__c = 'S');
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992', Emp_type__c = 'S');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
         Nias = new NIAS_Code__c(CST_CODE__c=123, EMP_CODE__c=223, GEOG_CODE__c='12', WRK_TYPE__c='123',
                   INCOME_CODE__c=323, INSTALLER__c='1', OTH_CODE__c=123, PYMT_CODE__c='123', RESOURCE_TYPE__c=emp.Emp_type__c, 
                   WVD_CODE__c=321,BUS_STREAM_ID__c = 'CH' );
                   insert Nias;
                   
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today() , Payment_Method__c = 'Cash', 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
        Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(), Payment_Method__c = 'Cash',
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment;
        
        oppList = [select ID, Name, StageName,CloseDate, Payment_Method__c, AccountId, LeadSource, 
        	Product_Interest__c, Referral_Employee__c,Override_Billing_checks__c from Opportunity where id in:opp];
       
		List<VAT_Codes__c> lstVats = new List<VAT_Codes__c>();
		
		for(VAT_Codes__c vatCode :[select id, Status__c from VAT_Codes__c])
		{
			vatCode.Status__c = 'Inactive';
			lstVats.Add(vatCode);
		}
		
        VAT_Codes__c vatCode = new VAT_Codes__c(VAT_Code_1__c='1', VAT_Code_2__c='2', VAT_Code_3__c='3', VAT_Code_4__c='4', Status__c='Active');
        lstVats.Add(vatCode);
        
        upsert lstVats;
       
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(oppList);
        ssc.setSelected(oppList);
        EnMassNBBSInterface EnMass = new EnMassNBBSInterface(ssc);
        
        EnMass.ConfirmSubmit();
     }
}