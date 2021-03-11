@isTest
private class QuotesPageCont_Test {
	static Account account;
    static Contact contact;
    static Opportunity opp;
    static Supplier__c supplier;
    static Employee__c emp;
    static BigMachines_Quote__c bm;
    static offer__c off;
    static District__c district;
    static Region__c region;
    
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
                                                Customer_Category_Record_Modified_By__c = UserInfo.getUserId(),Comms_Email_Field__c='test@abc.com');
        
        insert opp;
        
        bm = TestClassHelper.createBMQuote(opp);
        bm.stage__c='Quote Finalised - Not Accepted';
        bm.submittedDate_quote__c=system.today();
        bm.discountsTotalOnPricing__c=100;
        insert bm;
        
        district =TestClassHelper.createDistrict();
        insert district;
        
        region= testclassHelper.createRegion();
        region.Type__c = 'Installation';
        insert region;
        
        off = new offer__C(Offer_Code__c='QWERT12345', Value__c=100,Description__c='test',Start_Date__c=system.today()-5,End_Date__c=system.today()+5,Offer_Type__c ='Monetary');
        insert off;
    }
    static testMethod void testmethod1()
    {
        createData();
        PageReference pageRef = Page.QuotesPage;
        Test.setCurrentPage(pageRef);
        QuotesPageCont controller = new QuotesPageCont();
        controller.count=0;
        controller.bm = new BigMachines_Quote__c(installationDate__c=system.today()-1,closeDate__c=system.today()+1);
        controller.voucherFile = new QFU_Voucher_File__c(offer__c=off.id);
        controller.isPrevious = true;
        controller.currentProductHoldings = 'Gas';
        controller.partNumber = 'P194,P195';
        controller.allCoreBundleSelected = new List<SelectOption>{new SelectOption('A1 B1','A1 B1')};
        controller.allAllowanceKeySelected = new List<SelectOption>{new SelectOption('EC','EC')};
        controller.allProductIntSelected = new List<SelectOption>{new SelectOption('Guided Sale','Guided Sale')};
        controller.allDistrictsSelected = new List<SelectOption>{new SelectOption('IA West Scotland','1A West Scotland')};
        controller.allRegionsSelected = new List<SelectOption>{new SelectOption('Test Region','Test Region')};
        controller.allCustomerCategorySelected = new List<SelectOption>{new SelectOption('1','1')};
        controller.getProductInterestOptions();
        controller.getAllowanceKeyOptions();
        controller.getAllowanceKeyOptions();
        controller.getCoreBundleOptions();
        controller.getAreaItems();
        controller.getRegionItems();
           controller.queryLeads();
           controller.applyVoucher();
           controller.queryVoucherFiles();
           controller.firstPage();
           controller.previousPage();
           controller.nextPage();
           controller.lastPage();
           controller.back();
           controller.previousVFSent();
    }
    
    static testMethod void testmethod2()
    {
        createData();
        PageReference pageRef = Page.QuotesPage;
        Test.setCurrentPage(pageRef);
        QuotesPageCont controller = new QuotesPageCont();
        controller.count=0;
        controller.voucherFile = new QFU_Voucher_File__c(offer__c=off.id);
        controller.isPrevious = true;
        controller.opplist = new List<opportunity>{opp};
        controller.bm= new BigMachines_Quote__c(installationDate__c=system.today(),closeDate__c=system.today()+1);
        controller.isSalesforce= false;
           controller.isContactEngine=false;
            controller.isText = false;
            controller.isEmail = false;
         controller.downloadCSV();
         controller.queryLeads();
         controller.count=1;
         controller.applyVoucher();
         List<opportunity> leadlist = new List<opportunity>{opp};
         controller.extratctXLS(leadlist);
           
    }
    
    
    
    static testMethod void testmethod3()
    {
        createData();
        PageReference pageRef = Page.QuotesPage;
        Test.setCurrentPage(pageRef);
        QuotesPageCont controller = new QuotesPageCont();
        controller.count=0;
        controller.getProductInterestOptions();
        controller.getAllowanceKeyOptions();
        controller.getAllowanceKeyOptions();
        controller.getCoreBundleOptions();
        controller.getAreaItems();
        controller.getRegionItems();
        controller.getCustomerCategoryOptions();
           controller.back();
           controller.queryLeads();
           controller.isprevious=true;
           controller.voucherFile = new QFU_Voucher_File__c(offer__c=null);
           controller.applyVoucher();
           controller.queryVoucherFiles();
    }
    
}