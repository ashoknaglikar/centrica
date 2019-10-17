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
private class CreateJobComp_Commissioning_report_test {
    
    static testMethod void createJobReports() {
        
        String WasteID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Waste Disposal Report');
        String MinorID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Minor Electrical Installation');
        String AsbestosID= RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Asbestos Report');
        String GasID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Gas Installation Works');
        String EleID = RecordTypeIdHelper.getRecordTypeId('Commissioning_Report__c', 'Electrical Installation at Risk');
        
         Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
         Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer',salesforce_user__c = UInstal1.Id);
        /*Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');*/
        Employee__c[] employees = new Employee__c[]{emp};                                          
        insert employees;
        
       
        
        
        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Active',CloseDate=System.today().addYears(1),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
        /*Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);*/
        Opportunity[] opp = new Opportunity[]{opportunity};                                                 
        insert opp;
 
                
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        cls_IsRun.dontFireTriggers = true;
        insert quote;
        /*quote.Pricebook_Id__c='ary73';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;*/
     
        
        Job__c job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5,Suspend_Job__c = false, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,Status__c='Planned',Cancel_Merchant_Orders__c='Yes',Suspension_Reason__c='Save Team',Suspension_Reason_List__c='Redundant',
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Is_Downtime_Job__c = false,Installation_Date__c=Date.today(),Installer__c=UInstal1.Id);
       
        cls_IsRun.isJobCompletion=false;     
        system.debug('cls_IsRun.isJobCompletion2' +cls_IsRun.isJobCompletion);   
        insert job; 
        system.debug('cls_IsRun.isJobCompletion1' +cls_IsRun.isJobCompletion);
        cls_IsRun.isJobCompletion=false;     
        system.debug('cls_IsRun.isJobCompletion2' +cls_IsRun.isJobCompletion);   
        Payment_Collection__c obj_Payment= new Payment_Collection__c();
        obj_Payment=new Payment_Collection__c(Opportunity__c = opp[0].id, Account__c = account.id, ContactAddress__c = job.Address__c, 
                                              Job__c = job.id,ContactName__c=job.Customer_Name__c, Contact__c = job.Primary_Contact__c,
                                              Job_Special_ID__c = job.id + 'P1' , Balance_Outstanding__c = job.BalanceOutstanding__c, 
                                              District__c = job.District_Name__c, Job_Installation_Date__c = job.Installation_Date__c,
                                              Installer_Name__c = job.InstallerName__c, Sum_of_Payments__c = job.Sum_of_Payments__c,
                                              ASP_Addition__c = job.ASP_Addition__c, ASP_Discount__c = job.ASP_Discount__c,
                                              ASP_Removal__c = job.ASP_Removal__c, Original_Quote_Value__c = job.Original_Quote_Value__c,
                                              Quote_Nett_Amount__c = job.Quote_Nett_Amount__c, Payment_Collection_Status__c = 'Pending', 
                                              Financed_Amount__c = job.Financed_Amount__c);
        system.debug('cls_IsRun.isJobCompletion3' +cls_IsRun.isJobCompletion);
        insert obj_Payment;
        system.debug('cls_IsRun.isJobCompletion4' +cls_IsRun.isJobCompletion);
        cls_IsRun.isJobCompletion=false;    
        system.debug('cls_IsRun.isJobCompletion5' +cls_IsRun.isJobCompletion); 
        
           
        Commissioning_Report__c commissionreport1 = new Commissioning_Report__c(RecordtypeId=GasID,Report_Name__c= 'Gas Installation Works',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Job_Special_ID__c = job.Id +'G1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c);
                                                    
        Commissioning_Report__c commissionreport2 = new Commissioning_Report__c(RecordtypeId=EleID,Report_Name__c= 'Electrical Installation at Risk',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Job_Special_ID__c = job.Id +'E1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c);
        Commissioning_Report__c commissionreport3 = new Commissioning_Report__c(RecordtypeId=EleID,Report_Name__c= 'Asbestos Report',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Job_Special_ID__c = job.Id +'A1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c);
        Commissioning_Report__c commissionreport4 = new Commissioning_Report__c(RecordtypeId=EleID,Report_Name__c= 'Minor Electrical Installation',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Job_Special_ID__c = job.Id +'M1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c);
        Commissioning_Report__c commissionreport5 = new Commissioning_Report__c(RecordtypeId=EleID,Report_Name__c= 'Waste Disposal Report',Client_Name__c = job.Customer_Name__c,
                                                    Customer_Name__c = job.Customer_Name__c,Job_Number__c = job.Id,Phone_Number_Home__c  = job.Telephone_Number__c,Phone_Number_Work__c  = job.Telephone_Number_Work__c,
                                                    Address__c = job.Address__c,Job_Special_ID__c = job.Id +'W1',Property__c = job.Account_Id__c,District__c =job.District_Name__c,
                                                    Job_Installation_Date__c =job.Installation_Date__c,InstallerName__c=job.InstallerAliasName__c);
        Commissioning_Report__c[] commReport = new Commissioning_Report__c[]{commissionreport1,commissionreport2,commissionreport3,commissionreport4,commissionreport5};
        system.debug('cls_IsRun.isJobCompletion6' +cls_IsRun.isJobCompletion);
        cls_IsRun.isJobCompletion=false;
        system.debug('cls_IsRun.isJobCompletion7' +cls_IsRun.isJobCompletion);
        insert commReport;
        cls_IsRun.isJobCompletion=false;
        // CR - To create installation inspection document for DHM survey.
        CreateInstallationInspectionDocument.createInstallationInspecDoc(job.Id);
        // CR - To create installation inspection document for DHM survey.
        system.debug('cls_IsRun.isJobCompletion8' +cls_IsRun.isJobCompletion);
        system.debug('job.Status__c' +job.Status__c);
        system.debug('job.Suspend_Job__c)' +job.Suspend_Job__c);
        obj_Payment.Reason_for_Discrepancy__c='Dispute';
        obj_Payment.Payment_Collection_Status__c ='Complete';
        obj_Payment.If_Yes_When__c = System.datetime.now();
        obj_Payment.Reason_for_Discrepancy__c ='Dispute';
        obj_Payment.Payment_Notes__c = 'Test';
    
          update obj_Payment;
        cls_IsRun.isJobCompletion=false;    
        system.debug('cls_IsRun.isJobCompletion5' +cls_IsRun.isJobCompletion); 
        
    }

}