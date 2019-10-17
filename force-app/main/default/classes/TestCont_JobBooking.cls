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
private class TestCont_JobBooking {

    static testMethod void testJobEntries() {
        
        
    //  Cont_UnavailabilityEntriesPage controller1 = new Cont_UnavailabilityEntriesPage();
        Work_Cycle__c workCycle;
        Shift_Pattern__c sPattern;
        Employee__c testEmp1;
        Employee__c testEmp2;
        Entries_To_Plan__c ETP;
        Entries_To_Plan__c ETP1;
        Supplier__c supplier;
        Unavailability__c Unavailability;
        Diary_Entry__c Entries; 
        Diary_Entry__c Entries1; 
        List <Week__c> week = new List<Week__c> ();
        
        supplier = new Supplier__c(Name = 'TestSupp', Supplier_Num__c = 'x12345',Type__c = 'Product');
        
        Database.insert(supplier);
        testEmp1 = new Employee__c(Name = 'Test111', First_Name__c = 'testemp111', Last_Name__c = 'testemp1', 
                                                                Pool_Diary__c = false, Phone_No__c = '07222222223', 
                                                                    Employee_Number__c = '000000', Resource_Type__c = 'Installer', Supplier__c = supplier.Id);
        
        testEmp2 = new Employee__c(Name = 'Test222', First_Name__c = 'testemp222', Last_Name__c = 'testemp2', 
                                                                Pool_Diary__c = true, Phone_No__c = '07222222222', 
                                                                    Employee_Number__c = '000001', Resource_Type__c = 'Installer',Supplier__c=supplier.Id);
        
        Database.insert(testEmp1);
    
        Database.insert(testEmp2);
        
          
        sPattern = createShiftpattern(false);
        
        Database.insert(sPattern);
        workCycle = new Work_Cycle__c();
        workCycle.Employee__c = testEmp1.Id;
        workCycle.Shift_Pattern__c = sPattern.Id;
        workCycle.Start_Date__c = Date.today().toStartOfWeek().addDays(7);
        workCycle.End_Date__c = Date.today().toStartOfWeek().addDays(13);
        workCycle.Number_of_Weeks__c = 1;
        WorkCycle.Impact_Checked__c = true;
        Database.insert(workCycle);
        Integer count = [Select count() from Week__c w where w.Employee__c = :testEmp1.Id];
        Week__c w = new Week__c(Employee__c =  testEmp1.Id, Shift_Pattern__c = sPattern.ID, Week_Commencing__c = Date.today().toStartOfWeek(),
                                Monday_Max_Hours__c = 9, Tuesday_Max_Hours__c = 9, Wednesday_Max_Hours__c = 9, Thursday_Max_Hours__c = 9, 
                                Friday_Max_Hours__c = 9, Saturday_Max_Hours__c = null, Sunday_Max_Hours__c = null);
                                
        Week.add(w);                        
        Database.insert(w);
        System.assertEquals(0, count);
        Job__c job = CreatefirstJob();
       
        Job__c job1 = CreatesecondJob();
        
        
       
            
        Entries = new Diary_Entry__c(Week__c = w.Id, Start__c = DateTime.newInstance(Date.today().toStartOfWeek().addDays(7),Time.newInstance(8,0,0,0)), RecordTypeId = '012200000009ipQ', End__c =DateTime.newInstance(Date.today().toStartOfWeek().addDays(7),Time.newInstance(9,0,0,0)) , Employee__c = testEmp1.Id , Type__c = 'Job Booking' , Job__c = job.Id);
        Entries1 = new Diary_Entry__c(Week__c = w.Id, Start__c = DateTime.newInstance(Date.today().toStartOfWeek().addDays(8),Time.newInstance(8,0,0,0)), RecordTypeId = '012200000009ipQ', End__c =DateTime.newInstance(Date.today().toStartOfWeek().addDays(8),Time.newInstance(9,0,0,0)) , Employee__c = testEmp1.Id , Type__c = 'Job Booking' , Job__c = job1.Id);
        Database.insert(Entries);
        ETP = new Entries_To_Plan__c(Employee__c = testEmp1.Id, 
                                     Diary_ID__c = Entries.Id, 
                                     Record_Type__c = Entries.Type__c, 
                                     End__c = Entries.End__c, 
                                     Start__c = Entries.Start__c,
                                     Job__c = job.Id);
        ETP1 = new Entries_To_Plan__c(Employee__c = testEmp1.Id, 
                                     Diary_ID__c = Entries1.Id, 
                                     Record_Type__c = Entries1.Type__c, 
                                     End__c = Entries1.End__c, 
                                     Start__c = Entries1.Start__c,
                                     Job__c = job1.Id);
        list<Entries_To_Plan__c> EntryLst = new list<Entries_To_Plan__c> ();
        EntryLst.add(ETP1);
        EntryLst.add(ETP);  
        insert(EntryLst);
        test.startTest();
        system.debug('///////////////////////'+workCycle);
        PageReference pageRef1 = new PageReference('apex/JobBookingEntries?s='+ workCycle.Id); 
        
        Test.setCurrentPage(pageRef1);
        Cont_JobBookingPage controller = new Cont_JobBookingPage();
        controller.getJobEntries();
        controller.deleterecords();
        //controller.suspendrecords(); 
        controller.jobId= job.Id;
        controller.Suspended();
        controller.UnSuspended();
        //PageReference pageRef2 = new PageReference('apex/UnavailabilityEntries?s='+ workCycle.Id); 
        //Test.setCurrentPage(pageRef2);
        //controller1.getEntries();
        //controller1.RemoveUnavilabilities();
        //controller1.deleterecords();
        test.stoptest();
            }
 public static Shift_Pattern__c createShiftpattern(Boolean isPoolShiftPattern){
    
    Shift_Pattern__c shp = new Shift_Pattern__c();
    
    shp.Pool_Shift_Pattern__c = isPoolShiftPattern;
    
    shp.Monday_Start_Time__c = '08:00';
    shp.Tuesday_Start_Time__c = '08:00';
    shp.Wednesday_Start_Time__c = '08:00';
    shp.Thursday_Start_Time__c = '08:00';
    shp.Friday_Start_Time__c = '08:00';
    shp.Saturday_Start_Time__c = '08:00';
    shp.Sunday_Start_Time__c = '08:00';
    
    shp.Monday_End_Time__c = '18:00';
    shp.Tuesday_End_Time__c = '18:00';
    shp.Wednesday_End_Time__c = '18:00';
    shp.Thursday_End_Time__c = '18:00';
    shp.Friday_End_Time__c = '18:00';
    shp.Saturday_End_Time__c = '18:00';
    shp.Sunday_End_Time__c = '18:00';
    
    if(isPoolShiftPattern){
        
        shp.Name = 'Sample pool shift pattern';
        shp.Monday_Max_Hours__c = 50;
        shp.Tuesday_Max_Hours__c = 50;
        shp.Wednesday_Max_Hours__c = 50;
        shp.Thursday_Max_Hours__c = 50;
        shp.Friday_Max_Hours__c = 50;
        shp.Saturday_Max_Hours__c = 50;
        shp.Sunday_Max_Hours__c = 50;
        
    }else {
        
        shp.Name = 'Sample non-pool shift pattern';
        
    }
    
    return shp;
    
   }
            
public static Job__c CreatefirstJob()
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
        Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');
        Employee__c[] employees = new Employee__c[]{emp, emp1};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        
  //      NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
        Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
   //     BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
     //   insert payment;

 
                
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

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        insert job;
        return job;
} 
public static Job__c CreatesecondJob()
{
        Account account1=new Account(Name='Test account11',Number_of_Bedrooms__c=1,BillingStreet='Test Street1',BillingState='Test State1',
                                    BillingPostalCode='4411111',BillingCountry='Test Country1',BillingCity='Test City1'); 
        insert account1;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account1.Id,Salutation='Mr'); 
           
        
        insert contact;  
        Supplier__c supplier1 = new supplier__c(Name='Test supplier1',Type__c='Resource',Supplier_Num__c='A1232',Resource_Type__c='Resource');
        insert supplier1;
        
        Employee__c emp1 = new Employee__c(Name = 'testJI11', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier1.Id,
                                         Employee_Number__c = '0002993',Resource_Id__c='7fejs3',Resource_Type__c='Installer');
        Employee__c emp11 = new Employee__c(Name = 'testJI21', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002994');
        Employee__c[] employees = new Employee__c[]{emp1, emp11};                                          
        insert employees;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal11 = new User(profileid=PInstal.Id,alias = 'standt1', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardserashok@testorg.com',Migration_ID__c ='A763BHe32346');
        insert UInstal11;
        
  //      NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account1.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[1].id,Override_Billing_checks__c=false);
                                                    
        Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account1.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};                                                 
        insert opp;
        
   //     BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
     //   insert payment;

 
                
        BigMachines_Quote__c quote1= new BigMachines_Quote__c(Name = 'Test for Quote Decompile1', Opportunity__c = opp[1].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp1.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
        insert quote1;
        quote1.Pricebook_Id__c='ary73';
        quote1.quoteNumber_quote__c=quote1.Id;
        update quote1;
        
      
                
        Product2 product = new Product2(ProductCode='ABC124', Name='ABC124', BigMachines_Part_Number__c='ABC124',  IsActive = true);
        
        Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC124', BigMachines_Quote__c=quote1.Id,Merchant_Price__c=307,
                                                            Name='ABC124',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


        insert product;
        insert quoteProduct;

        
        District__c district = [Select id from District__c limit 1];
                
       
       
        Job__c job1 = new Job__c();

        job1 = new Job__c(CHI_Lead__c = opp[1].ID,Quote__c=quote1.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal11.Id);
                         
        insert job1;
        return job1;
}         
    
   
}