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
private class TopcallFaxHeaderRecord_test {

    static testMethod void myUnitTest() {
        //try{ 
        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource',EDI_Tolerance_Value__c=2,P5_Order_Lead_Time__c = 123,Fax_Setup__c=true);
        insert supplier;
        Supplier__c supplier1 = new supplier__c(Name='Tes1t supplier',Type__c='Resource',P5_Order_Lead_Time__c = 223,EDI_Tolerance_Value__c=1,Supplier_Num__c='A1233',Resource_Type__c='Resource',Fax_Setup__c=true);
        insert supplier1;
        
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
                                         
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',Supplier__c=supplier1.Id,
                                         Employee_Number__c = '1002992',Resource_Id__c='7fejR2',Resource_Type__c='Installer');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        User UInstal2 = new User(profileid=PInstal.Id,alias = '1standt', email='1standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='1Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser1@testorg.com',Migration_ID__c ='A763BHe32349');
        insert UInstal2;
        
        NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
        Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=true);
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment;
        BGS_Payment__c payment1 = new BGS_Payment__c(Opportunity__c=opportunity1.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment1;
         
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote;
        BigMachines_Quote__c quote1= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[1].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp1.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote1;
                
        Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
       
       
        Job__c job = new Job__c();

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =system.today() - 4,Installation_Date__c=system.today() - 4,District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job;
        
        Job__c job1 = new Job__c();

        job1 = new Job__c(CHI_Lead__c = opp[1].ID,Quote__c=quote1.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =system.today() - 5,Installation_Date__c=system.today() - 5,District__c=district.Id,Installer__c=UInstal2.Id);
                         
        
                        
        insert job1;
        
        List<order__c> OrdList = new List<order__c>();
        /* order__c ord = new  order__c();
        ord.Job__c=job.Id;
        ord.Supplier__c=supplier1.Id;
        ord.Status__c='Active';
        ord.SAP_Number__c='23750';
        ord.Type__c='Material';
        ord.Amendment_Number__c=25;
        ord.Supplier_Fax_number__c='12340';
        ord.Delivery_Date_Changed__c=true;  
        ord.SupplierBranchNum__c='786';  
        ord.Topcall_Fax_Status__c = 'Awaiting Integration';      
        insert ord;*/
        
        
       
        order__c ord1 = new  order__c();
        ord1.Job__c=job1.Id;
        //ord1.Job_Delivery_Date__c=Date.today();
        ord1.Supplier__c=supplier.Id;
        ord1.Status__c='Active';
        ord1.SAP_Number__c='23756';
        ord1.Type__c='Material';
        ord1.Amendment_Number__c=23;
        ord1.Supplier_Fax_number__c='12345';
        ord1.Amendment_Number__c = 1;
        ord1.SupplierBranchNum__c = '123';
        ord1.Delivery_Date_Changed__c=true;  
        ord1.SupplierBranchNum__c='100298';  
        ord1.Topcall_Fax_Status__c = 'Awaiting Integration';    
        insert ord1;
        
        
       
          
       system.debug('Job_Delivery_Date__c**'+ord1.Job_Delivery_Date__c);
       system.debug('SupplierBranchNum__c**'+ord1.SupplierBranchNum__c);
        //save order attachments
        Attachment attachObj = new Attachment();
        attachObj.Name = 'test attachment';
        attachObj.Body = Blob.valueof('test attachment body');
        attachobj.ParentId = ord1.id;
        insert attachobj;  
        
        ord1 = [Select SAP_Number__c,Fax_Enabled__c,SupplierBranchNum__c,Job_Delivery_Date__c,supplier__r.EDI_Tolerance_Value__c,Status__c,Delivery_Date_Changed__c,Returned_Items__c,Amendment_Number__c,
            Topcall_Fax_Status__c, Supplier_Fax_number__c, Supplier__c,supplier__r.name,supplier__r.Supplier_Num__c,supplier__r.P5_Order_Lead_Time__c,Sync__c, Id, Fax_Setup__c,(Select Id,ParentId, Name From Attachments) From order__c where id =:ord1.id];
       /* ord = [Select Fax_Enabled__c,SupplierBranchNum__c,Job_Delivery_Date__c,Status__c,Delivery_Date_Changed__c,Returned_Items__c,Amendment_Number__c,
            Topcall_Fax_Status__c, Supplier_Fax_number__c, Sync__c, Id, Fax_Setup__c,(Select Id,ParentId, Name From Attachments) From order__c where id =:ord.id];*/
        OrdList.add(ord1);
        //OrdList.add(ord);
        
        
        
        List<Attachment> docs = [Select Id,ParentId, Name,Body,ContentType 
            From Attachment where ParentId = :ord1.ID];
        
        system.debug(OrdList + 'ORDERLIST---');
        system.debug('------------- docs = ' + docs);
      
          Integer daysBetween =(System.today()).daysBetween(OrdList[0].Job_Delivery_Date__c);
          system.debug('----daysBetween' +daysBetween);
     
        
       /* String context= '1 0 1 3 9 ? 2010';
        SchedulableContext sc;
    System.schedule('testScheduledApex',context, new ProcessOrderForFaxAndEDI());
        ProcessOrderForFaxAndEDI GT = new ProcessOrderForFaxAndEDI();
        GT.execute(sc); */
        TopcallFaxHeaderRecord TopFHR = new TopcallFaxHeaderRecord();
        Database.BatchableContext BC;
        Test.startTest();
        //TopFHR.start(BC);
        TopFHR.execute(BC,OrdList);
        //TopFHR.finish(BC);
        Test.stopTest();
        /*}catch(system.exception e)
        {
        }*/
        
    }
}