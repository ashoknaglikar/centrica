@isTest
private class createBundleLeadHelper_Test {
	static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
    static BigMachines_Quote__c bm;
    static Appointment__c TestAppointment1;
    //static offer__c off;
    static Campaign newCampaign;
    static Bundle__c bundle;
    static Bundle_Part__c bunPart;
    static Bundle_Part__c bunPart1;
    static CS_Part__c csPart;
    static CS_VAT_Code__c vatcode;
    static Product2 pro;
    
    static createBundleLeadRequest.cls_CustomerData cusdata= new createBundleLeadRequest.cls_CustomerData();
    static createBundleLeadRequest.cls_customerDetails cusdetails= new createBundleLeadRequest.cls_customerDetails();
    static createBundleLeadRequest.cls_contactDetails contactdata= new createBundleLeadRequest.cls_contactDetails();
    static createBundleLeadRequest.cls_Address addr= new createBundleLeadRequest.cls_Address();
    static createBundleLeadRequest.cls_bundle bun= new createBundleLeadRequest.cls_bundle();
    static createBundleLeadRequest.cls_allowancesApplied allow = new createBundleLeadRequest.cls_allowancesApplied();
    
	static void createData()
	{
		//Prepare account data
		account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='14 Test Street',BillingState='Test State',
                                    BillingPostalCode='441 111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        //account = [select id,name,Account_id__c,Number_of_Bedrooms__c,BillingStreet,BillingState,BillingPostalCode,BillingCountry,BillingCity from account where id=:account.id];
        //Prepare contact data
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441 111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
                                     
        insert contact;
        
        newCampaign = new Campaign(Name = 'ENG1', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;       
        
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
        
        
        
        bm = TestClassHelper.createBMQuote(opp);
        insert bm;
        
        bundle = new Bundle__c(Reference_Code__c='001');
        insert bundle;
        
        vatcode= new CS_VAT_Code__c(name='test vatcode',Percentage__c=20);
        insert vatcode;
        
        pro = new product2(name ='HIVE');
        insert pro;
        
        csPart= new CS_Part__c(name='Test',Part_Code__c='PPTB36',VAT_Code__c=vatcode.id,product__c =pro.id);
        insert csPart;
        
        bunPart = new Bundle_Part__c(Bundle__c= bundle.id,CS_Part__c=csPart.id,Price__c=2299.00,Quantity__c=1);
        insert bunPart;
        
    }
    
    static void createRequestData()
	{
        cusdata.chiLeadChannel='Online';
        cusdata.resStatus='Owner';
        cusdata.productInterest='Online Boiler';
        cusdata.mediaCode='ENGI';
        cusdata.marketingPreference='Email';
        cusdata.isMarketingConsent='Yes';
        cusdata.asbestosIdentified ='no';
        cusdata.isHomecare =true;
        cusdata.isPowerflush =false;
        cusdata.fuelType ='natural Gas';
        cusdata.homeCareAccountNumber ='911234567890';
        cusdata.hiveReq =true;
        cusdata.plumeKitReq =true;
        
        cusdetails.Salutation='Mr';
        cusdetails.LastName='test';
        cusdetails.FirstName='test';
        
        contactdata.MobilePhone='0789654123';
        contactdata.Email ='abc@cde.com';
        
        addr.TownCity='LEEDS';
        addr.Street='EDINBURGH PLACE';
        addr.PostCode='LS12 3RQ';
        addr.NameNumber='14';
        addr.CountyProvince='UK';
        
        cusdata.customerDetails =cusdetails;
        cusdata.contactDetails =contactdata;
        cusdata.Address =addr;
        
        bun.id ='001';
        bun.boilerCode ='CBLR0001';
        bun.totalBundlePrice ='2999.0';
        bun.totalAllowance ='700.0';
        bun.totalPriceAfterDicount ='2299.0';
        
        allow.name='£200.00 Homecare loyalty engineer discount';
        allow.amount=200.0;
        allow.code='QWER32';
        bun.allowancesApplied = new List<createBundleLeadRequest.cls_allowancesApplied>{allow};
	}
	
    static testMethod void testmethod1()
    {
        createData();
        createRequestData();
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }

     static testMethod void testmethod2()
     {
        createData();
        createRequestData();
        addr.PostCode=null;
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }
    
    static testMethod void testmethod3()
     {
        createData();
        createRequestData();
        addr.NameNumber =null;
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }
    
    static testMethod void testmethod4()
     {
        createData();
        createRequestData();
        bun.allowancesApplied = new List<createBundleLeadRequest.cls_allowancesApplied>{allow,allow,allow,allow,allow,allow,allow};
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }
    
     static testMethod void testmethod5()
     {
        createData();
        createRequestData();
        bun.allowancesApplied = new List<createBundleLeadRequest.cls_allowancesApplied>{allow,allow,allow,allow,allow,allow};
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }

     static testMethod void testmethod6()
     {
        createData();
        createRequestData();
        addr.TownCity='Test City';
        addr.Street='Test Street';
        addr.PostCode='441111';
        addr.NameNumber='14';
        
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }

    static testMethod void testmethod7()
     {
        createData();
        
        bm.Opportunity__c =null;
        update bm;
        
        createRequestData();
        addr.TownCity='Test City';
        addr.Street='Test Street';
        addr.PostCode='441111';
        addr.NameNumber='14';
        
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }
    
     static testMethod void testmethod8()
     {
        createData();
        bm.Opportunity__c =null;
        update bm;
        newCampaign.name='web';
        update newCampaign;
        
        opp.stageName='Expired';
        update opp;
        
        createRequestData();
        addr.TownCity='Test City';
        addr.Street='Test Street';
        addr.PostCode='441111';
        addr.NameNumber='14';
        
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }
    
    static testMethod void testmethod9()
     {
        createData();
        
        bm.Opportunity__c =null;
        update bm;
        
        date pageDate = date.today();
        datetime AppointmentTime0700am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 7,0,0);     
        datetime AppointmentTime0900am = datetime.newinstance(pageDate.Year(), pageDate.addMonths(1).Month(), pageDate.addDays(1).Day(), 9,0,0);
        
        Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;        

        TestAppointment1 = new Appointment__c(Type__c='Sales', Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime0900am, Assigned_To__c=emp.Id , Status__c = 'Appointed',Opportunity__c=opp.id, Create_History__c = true,who__c=contact.id);
        insert TestAppointment1;
        
        createRequestData();
        addr.TownCity='Test City';
        addr.Street='Test Street';
        addr.PostCode='441111';
        addr.NameNumber='14';
       
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        Test.starttest();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
        test.stoptest();
    }
    
    static testMethod void testmethod10()
     {
        createData();
        delete opp;
        newCampaign.name='web';
        update newCampaign;
        
        createRequestData();
        addr.TownCity='Test City';
        addr.Street='Test Street';
        addr.PostCode='441111';
        addr.NameNumber='14';
       
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }

     static testMethod void testmethod11()
     {
        createData();
        bunPart1 = new Bundle_Part__c(Bundle__c= bundle.id,CS_Part__c=csPart.id,Quantity__c=1);
        insert bunPart1;
        
        createRequestData();
        createBundleLeadRequest req = new createBundleLeadRequest();
        req.CustomerData = cusdata;
        req.bundle = bun;
        String myJSON = JSON.serialize(req);

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }
    
    static testMethod void testmethod12()
     {
        createData();
        String myJSON = '';

        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/createBundleLead';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        RestContext.request = request;
        createBundleLeadResponse repl = OnlineBoilerCreateBundleLeadAPI.createBundleLeadMethod();
    }




    
    
    
}