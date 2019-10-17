@isTest
public class TestScaffoldViewController {
    static Account account;
    static Contact contact;
    static Supplier__c supplier;
    static Supplier__c supplier1;
    static Supplier__c supplier2;
    static Employee__c emp;
    static Employee__c emp1;
    static Employee__c[] employees;
    static User UInstal1;
    static Opportunity opportunity;
    static Opportunity[] opp;
    static BigMachines_Quote__c quote;
    static Product2 product;
    static Quote_Product__c quoteProduct;
    static Job__c job;
    static Order__c ord; 
    static List<Order__c> ordlst;
    static List<Order_Line_Item__c> Ordlinelst;
    static Shift_Pattern__c Shift;
    static Week__c Week;
    static Diary_Entry__c DiaryEntry;
    
    
    @testSetup static void testDataSetup() {
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                            BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        
        insert account;
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
        
        
        insert contact;  
        supplier = new supplier__c(Name='Test supplier',ANA_Number__c='121',Type__c='Resource',Supplier_Num__c='A1234',Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
        
        insert supplier;
        
        supplier1 = new supplier__c(Name='Test supplier1',ANA_Number__c='122',Type__c='Resource',Supplier_Num__c='B1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='Contractor');
        insert supplier1;
        
        supplier2 = new supplier__c(Name='Test supplier2',ANA_Number__c='123',Type__c='Product',Status_code__c='A',Supplier_Num__c='C1234', Phone1__c='12312',Van_Stock__c=true,Fax_Setup__c=true,Resource_Type__c='S');
        insert supplier2;
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                              Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',Salesforce_User__c = userinfo.getUserId());
        emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',Supplier__c=supplier.Id,
                               Employee_Number__c = '0002992',Resource_Id__c='7fejs3',Resource_Type__c='Installer',Salesforce_User__c = userinfo.getUserId());
        employees = new Employee__c[]{emp,emp1};                                          
            insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                            emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                            localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        
        
        //inserting opportunity with different employee
        opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
        
        opp = new Opportunity[]{opportunity};                                                 
            insert opp;
        
        
        quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                        POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                        Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                        is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        
        product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
        
        
        
        
        insert product;
        insert quoteProduct;
        Shift = new Shift_Pattern__c(Name = 'Test Shift', Pool_Shift_Pattern__c = true, Shift_Pattern_ID__c = 'TS1',Total_Hours__c = '1',Monday_Start_Time__c = '08:00',Monday_End_Time__c = '09:00' );
        insert Shift;
        
        Week = new Week__c(Employee__c = emp.id, Shift_Pattern__c = Shift.id, Week_Commencing__c = date.today());
        insert Week;
        
        //DiaryEntry = new Diary_Entry__c(Week__c = Week.id, Sub_Type__c = 'Mechanical', Job__c = job.id, Start__c = Datetime.now() , End__c = Datetime.now(), Hours__c = 1);
        //insert DiaryEntry;  
        District__c district = TestClassHelper.createDistrict();
        insert district;
        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                         Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                         Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                         Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                         Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                         Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                         Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
        insert job;
        
        //Creating  Order                          
        ord = new Order__c();
        ord.Job__c= job.Id;
        ord.SAP_Number__c='12';
        ord.Status__c='Active';
        ord.Sync__c=true;
        ord.SAP_Number__c='1234';
        ord.Supplier__c=supplier.Id;
        ord.Order_Value__c=456; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Work';
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
        insert ord;
        ordlst = new List<Order__c>();
        ordlst.add(ord);
        
    }
    
    public static testMethod void test1() 
    {
        scaffoldViewController scf = new scaffoldViewController();
        scf.selectedJobID = [SELECT Id FROM Job__c LIMIT 1].Id;
        scf.showDetail = true;
        scf.getEmployeeInfo();
        scf.getPurchaseOrders();
        scf.getJobDetails();
        scf.getPhotos();
        scf.getJobElements();
        scf.getSAPList();
        scf.getResourceList();
        scf.checkDates();
        scf.getSelected();
        scf.search();
    }
    
    public static testMethod void test2() 
    {
        scaffoldViewController scf = new scaffoldViewController();
        scf.startDate1.Installation_Date__c = null;
        scf.selectedJobID = [SELECT Id FROM Job__c LIMIT 1].Id;
        scf.showDetail = true;
        scf.getEmployeeInfo();
        scf.getPurchaseOrders();
        scf.getJobDetails();
        scf.getPhotos();
        scf.getJobElements();
        scf.getSAPList();
        scf.getResourceList();
        scf.checkDates();
        scf.getSelected();
        scf.search();
    }
    
    public static testMethod void test3() 
    {
        scaffoldViewController scf = new scaffoldViewController();
        scf.startDate1.Installation_Date__c =  date.newInstance(2018, 11, 21);
        scf.endDate1.Installation_Date__c = date.newInstance(2018, 11, 11);
        scf.selectedJobID = [SELECT Id FROM Job__c LIMIT 1].Id;
        scf.showDetail = true;
        scf.getEmployeeInfo();
        scf.getPurchaseOrders();
        scf.getJobDetails();
        scf.getPhotos();
        scf.getJobElements();
        scf.getSAPList();
        scf.getResourceList();
        scf.checkDates();
        scf.getSelected();
        scf.search();
    }

    public static testMethod void test4() 
    {
        scaffoldViewController scf = new scaffoldViewController();
        scf.startDate1.Installation_Date__c =  date.newInstance(2018, 11, 1);
        scf.endDate1.Installation_Date__c = date.newInstance(2018, 11, 31);
        scf.selectedJobID = [SELECT Id FROM Job__c LIMIT 1].Id;
        scf.showDetail = true;
        scf.getEmployeeInfo();
        scf.getPurchaseOrders();
        scf.getJobDetails();
        scf.getPhotos();
        scf.getJobElements();
        scf.getSAPList();
        scf.getResourceList();
        scf.checkDates();
        scf.getSelected();
        scf.search();
    }
}