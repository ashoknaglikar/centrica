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
private class TopcallOrderGenerationPDF_Test {

    static testMethod void CreateDataTestMethod() {
        // TO DO: implement unit test
        
               Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
               insert account;
        
               Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
               insert contact;
        
               Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource',partner__c='Y');
               insert supplier;
         
               Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer'); 
               emp.Phone_No__c='9089001234';
               insert emp;
               
               
               Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
               User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
               insert UInstal1;
               
               
               Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);                                 
         
               BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
               insert quote;
        
               Product2 product = new Product2(ProductCode='ABC123', Name='ABC123', BigMachines_Part_Number__c='ABC123',  IsActive = true);
        
               Quote_Product__c quoteProduct = new Quote_Product__c(Product__c=product.Id, ASP_Action__c='Add Parts Only', ASP_Reason__c='Added',  
                                                            Part_Number__c='ABC123', BigMachines_Quote__c=quote.Id,Merchant_Price__c=307,
                                                            Name='ABC123',Sales_Price__c=100,Quantity__c=10,VAT_Code__c='4');
                                                            
       


              insert product;
              insert quoteProduct;

        
               District__c district = [Select id from District__c limit 1];
               
               
        
        
        
              Job__c job = new Job__c();

              job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true,Status__c='Planned', Delivery_Date__c =Date.today(),Installation_Date__c=Date.today(),District__c=district.Id,Installer__c=UInstal1.Id);
                insert job;
                
                Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
                insert week;
                
                RecordType RcdTypId = [Select r.Id, sObjectType From RecordType r where r.Name='Job Booking' and sObjectType = 'Diary_Entry__c']; 
                
                Diary_Entry__c DEntry = new Diary_Entry__c(Job__c =job.ID ,Employee__c=emp.Id,Week__c=week.Id, RecordTypeID=RcdTypId.Id);
                
                insert DEntry;
               
                Order__c ord = new Order__c();
                ord.Job__c= job.Id;
                ord.Supplier__c = supplier.id;
                ord.Status__c='Active' ;
                ord.Delivery_Date_Changed__c=true;
                ord.Topcall_Fax_Status__c='Integrated';
                insert ord;
                ord.Type__c='Work';
                update ord;
                List<order__c> orderList=new List<order__c>();
                orderList.add(ord);
                
                
                String sSupplierNum=[Select Supplier__r.Supplier_Num__c From order__c Where Id=:ord.Id].Supplier__r.Supplier_Num__c;
                
                List<Diary_Entry__c> DiaryEntryList=new List<Diary_Entry__c>{};
                
                System.debug('---------------- sSupplierNum = ' + sSupplierNum);
                
                DiaryEntryList=[Select Week__r.Employee__r.Employee_Number__c, Record_Type__c, Week__r.Employee__r.Supplier__r.Supplier_Num__c
                                        From Diary_Entry__c where Job__c=:job.ID];
                
                /*DiaryEntryList=[Select Week__r.Employee__r.Employee_Number__c
                                        From Diary_Entry__c where Job__c=:job.ID 
                                        And Record_Type__c='Job Booking' And Week__r.Employee__r.Supplier__r.Supplier_Num__c=:sSupplierNum];
                  */                      
                System.debug('---------------- DiaryEntryList = ' + DiaryEntryList);                                        
                
                
                PageReference pageRef = new PageReference('/apex/TopcallOrderGenerationPDF?jid=' +job.Id );
                Test.setCurrentPage(pageRef);
               
                TopcallOrderGenerationPDF.FileGenarationDetails obj=new TopcallOrderGenerationPDF.FileGenarationDetails();
                
                TopcallOrderGenerationPDF TOGP=new TopcallOrderGenerationPDF();
                TOGP.GeneratePDFandAttach(orderList);
                TOGP.GeneratePDF();
                ord.Type__c='Material';
                update ord;
                orderList.add(ord);
                TOGP.GeneratePDFandAttach(orderList);
    }
}