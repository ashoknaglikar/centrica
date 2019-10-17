/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SuspendCancelJob_test {

    static testMethod void SuspendCancelJobTest() {
        
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
        //emp.Is_Active_Salesforce_User__c='true';
        //emp.Inactive__c=false;
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp',StageName ='Active',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
        Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment;

 
                
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        
        update quote;
                
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
 
       
        Job__c job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].Id,Quote__c=quote.Id,sub_Status__c='Billed',PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Status__c='Planned',
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Suspend_Job__c=false,Cancel_Merchant_Orders__c='Yes',Suspension_Reason_List__c='Redundant',
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        job.Is_Downtime_Job__c=false;
        insert job;
        
        system.debug(job.User_Jobs__r+'check**');
       
        List<Job__c> lstjob = new List<Job__c>();
        lstjob.add(job);
        
        Installer__c install= new Installer__c(Installer_Status__c='Active',Job__c=job.Id );
        insert install;
        
        
        Order__c  ord = new Order__c();
        ord.Job__c= job.Id;
        ord.SAP_Number__c='12';
        ord.Status__c='Active';
        ord.Sync__c=true;
        ord.SAP_Number__c='1234';
        ord.Supplier__c=supplier.Id;
        ord.Order_Value__c=456;
        ord.Prior_Order_Value__c=213; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Work';
        
         //Supplier__r.Name
         //Supplier__r.Supplier_Num__c
        //Amended_or_Removed_Items__c
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
        ord.Approved__c=true;
        // ord.Order_Date__c.format();
        insert ord;
        List<Order__c> ordlst = new List<Order__c>();
        ordlst = new List<Order__c>();
        ordlst.add(ord);
        
        Job_Element__c JE2 = new Job_Element__c();
        JE2.Job__c = job.Id;
        JE2.Type__c='Work';
        JE2.New_Supplier__c=null;
        JE2.Order__c=ord.Id;
        JE2.New_Supplier_Number__c= '1233';
        JE2.Current_Supplier__c='CSupplier1';
        JE2.Current_Supplier_Number__c='321';
        JE2.Code__c='345';
        JE2.Supplier_Order_Number__c='1212';
        JE2.Status__c='Active';
        JE2.Sub_Status__c='Awaiting Order';
        JE2.Description__c='testDescription';
        JE2.Line_Item_ID__c='124';
        JE2.Skill__c='Scaffolder';
        JE2.Units__c=125;
        insert JE2;
        List<Job_Element__c> JEList_Work1 =new List<Job_Element__c>();
        JEList_Work1.add(JE2);
        
        
        //Order_Line_Item__c OrdLine = new Order_Line_Item__c();
        //OrdLine.Order_Line_Item_Number__c=714;
       // OrdLine.P5_Job_Element__c=JE.Id;
        //OrdLine.P5_Purchase_Order__c=ord.Id;
        //ordline.P5_Product__c=product.Id;
        //insert OrdLine;
        
         update job;
               
         
        ApexPages.StandardController stdCancelController1 = new ApexPages.StandardController(opp[0]);
        SuspendCancelJob SusCan_job1 = new SuspendCancelJob(stdCancelController1);
        
        SusCan_job1.suspendLead();  
        
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(opp[0]);
        SuspendCancelJob SusCan_job = new SuspendCancelJob(stdCancelController);
        Test.startTest();
        string oppid = opportunity.Id;
        
        SusCan_job.getorderChoice();    
        SusCan_job.getS_msg();
        String choice='work';
        SusCan_job.setorderChoice(choice);
        SusCan_job.getChoices();
        
        SusCan_job.suspendLead();  
        
        ord.Type__c='Material';
        update ord;
        String choice1='Material';
        SusCan_job.setorderChoice(choice1);
        SusCan_job.getChoices();
        
        SusCan_job.suspendLead();  
        
        ord.Type__c='All';
        update ord;
        String choice2='All';
        SusCan_job.setorderChoice(choice2);
        SusCan_job.getChoices();
        
        SusCan_job.suspendLead(); 
        
        opp[0].CloseDate = system.today().adddays(1);
        update opp[0];
        
        Delete job;
        Suscan_job.suspendLead();
        
        Test.stopTest();
        
        
        //SusCan_job.cancelJobAndChildren(opp[0].Id);
        //SusCan_job.cancelLead();
        //SusCan_job.suspendOppty();
        //SusCan_job.CancelOppty();
        
        
 
    }
    
    static testMethod  void cancelLeadTest()
    {
        
        
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
        //emp.Is_Active_Salesforce_User__c='true';
        //emp.Inactive__c=false;
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp',StageName ='Active',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
        Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment;

 
                
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        
        update quote;
                
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
 
       
        Job__c job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].Id,Quote__c=quote.Id,sub_Status__c='Billed',PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Status__c='Planned',
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Suspend_Job__c=false,Cancel_Merchant_Orders__c='Yes',Suspension_Reason_List__c='Redundant',
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        job.Is_Downtime_Job__c=false;
        insert job;
        
        system.debug(job.User_Jobs__r+'check**');
       
        List<Job__c> lstjob = new List<Job__c>();
        lstjob.add(job);
        
        Installer__c install= new Installer__c(Installer_Status__c='Active',Job__c=job.Id );
        insert install;
        
        
        Order__c  ord = new Order__c();
        ord.Job__c= job.Id;
        ord.SAP_Number__c='12';
        ord.Status__c='Active';
        ord.Sync__c=true;
        ord.SAP_Number__c='1234';
        ord.Supplier__c=supplier.Id;
        ord.Order_Value__c=456;
        ord.Prior_Order_Value__c=213; 
        ord.Amendment_Number__c=678;
        ord.Type__c='Work';
        
         //Supplier__r.Name
         //Supplier__r.Supplier_Num__c
        //Amended_or_Removed_Items__c
        ord.Order_Date__c=System.today();
        ord.Fax_Setup__c=true;
        ord.Approved__c=true;
        // ord.Order_Date__c.format();
        insert ord;
        List<Order__c> ordlst = new List<Order__c>();
        ordlst = new List<Order__c>();
        ordlst.add(ord);
        
        Job_Element__c JE2 = new Job_Element__c();
        JE2.Job__c = job.Id;
        JE2.Type__c='Work';
        JE2.New_Supplier__c=null;
        JE2.Order__c=ord.Id;
        JE2.New_Supplier_Number__c= '1233';
        JE2.Current_Supplier__c='CSupplier1';
        JE2.Current_Supplier_Number__c='321';
        JE2.Code__c='345';
        JE2.Supplier_Order_Number__c='1212';
        JE2.Status__c='Active';
        JE2.Sub_Status__c='Awaiting Order';
        JE2.Description__c='testDescription';
        JE2.Line_Item_ID__c='124';
        JE2.Skill__c='Scaffolder';
        JE2.Units__c=125;
        insert JE2;
        List<Job_Element__c> JEList_Work1 =new List<Job_Element__c>();
        JEList_Work1.add(JE2);
        
        
        //Order_Line_Item__c OrdLine = new Order_Line_Item__c();
        //OrdLine.Order_Line_Item_Number__c=714;
       // OrdLine.P5_Job_Element__c=JE.Id;
        //OrdLine.P5_Purchase_Order__c=ord.Id;
        //ordline.P5_Product__c=product.Id;
        //insert OrdLine;
        
         update job;
        test.starttest();
        ApexPages.StandardController stdCancelController = new ApexPages.StandardController(opp[0]);
        SuspendCancelJob SusCan_job = new SuspendCancelJob(stdCancelController);
        string oppid = opportunity.Id;
        
        SusCan_job.getorderChoice();    
        SusCan_job.getS_msg();
        String choice='work';
        SusCan_job.setorderChoice(choice);
        SusCan_job.getChoices();
        
        //SusCan_job.suspendLead(); 
        SusCan_job.cancelJobAndChildren(opp[0].Id);
        SusCan_job.cancelLead();
        SusCan_job.suspendOppty();
        SusCan_job.CancelOppty();   
        
        // ++ Added for PTS CR start
        SusCan_job.orderChoice = 'All';
        job.DeliveryID__c = 'testDelId';
        update job;
        SusCan_job.redirectToPTS();
        SusCan_job.suspendLead();
        // -- Added for PTS CR end
        test.stopTest();
   
    }
}