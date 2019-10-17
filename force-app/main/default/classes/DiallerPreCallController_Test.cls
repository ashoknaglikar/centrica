@isTest
private class DiallerPreCallController_Test {

	static Appointment__c appoint;
	static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
	static void createData()
	{
		String recType = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
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
        //prepare appointment data
        appoint = new Appointment__c(Assigned_To__c = emp.Id , RecordTypeId = recType , Opportunity__c = opp.id ,Who__c = contact.id , Start__c = system.now()-10 , End__c = system.now()-5 , Date_Visit_Booked__c = system.today()-10 , Status__c = 'Happened' ,Confirmation_Email__c = system.today()-15 ,NSSE_Email_Sent__c = system.today()-5 , HistrorySOAppDate__c = system.today()-15);
        insert appoint;
    }
    static testMethod void testPreCall()
    {
        createData();
        DiallerPreCallController preCall = new DiallerPreCallController();
        preCall.appointment.Confirmation_Email__c = system.today()-15;
        preCall.appointment.NSSE_Email_Sent__c = system.today()-5;
        preCall.appointment.HistrorySOAppDate__c = system.today()-15;
        preCall.appointment.Date_Visit_Booked__c = system.today()-5;
        preCall.status = 'Happened';
        preCall.getStatusValues();
        preCall.createDiallerFile();
        preCall.back();
    }
    
}