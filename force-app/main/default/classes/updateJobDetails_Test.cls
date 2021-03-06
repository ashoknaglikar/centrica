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
private class updateJobDetails_Test {

    static testMethod void craetingData() {
                  
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
                  /*Employee__c emp1 = new Employee__c(Name = 'testJI2', First_Name__c = 'SBB2', Last_Name__c = 'Test2',
                                         Employee_Number__c = '1002992');*/
          
                  Employee__c[] employees = new Employee__c[]{emp};                                          
                  insert employees;
        
                  Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
                  User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
                   insert UInstal1;
        
        
        
                  //inserting opportunity with different employee
                  Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=false);
                                                    
                     /*Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =employees[0].id,Override_Billing_checks__c=true);*/
                  Opportunity[] opp = new Opportunity[]{opportunity};                                                 
                  insert opp;
 
                
                  BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opp[0].Id,discountsTotalOnPricing__c=100,
                                                            POC_Payment_Method__c = 'Finance',App_Assigned_To__c=emp.Id,
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000);
                  insert quote;
                  quote.deliveryDate__c = System.today();
                  quote.installationDate__c = System.today()+2;
                  update quote;
		            /*quote.Pricebook_Id__c='ary73';
		                quote.quoteNumber_quote__c=quote.Id;
		                 update quote;*/
     
       
                  Job__c job = new Job__c();

                  job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1,
                                Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5,previous_resources__c = ' ',Suspension_Reason__c = ' ',
                                Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,Suspend_Job__c=false,Cancel_Merchant_Orders__c='Yes',Suspension_Reason_List__c='Redundant',
                                Double_Handed_Job__c = true, Delivery_Date__c =System.today(),Installation_Date__c=System.today()+2,Installer__c=UInstal1.Id);
                insert job; 
                //select Quote__r.skillTotalWaterHeatingFixing__c,Overriden__c,Quote__r.skillTotalUnventedHotWater__c,Quote__r.skillTotalSpecialistBuilding__c,Quote__r.skillTotalScaffolder__c,Quote__r.skillTotalRoofWork__c,Quote__r.skillTotalPaymentCollection__c,Quote__r.skillTotalMechanical__c,Quote__r.skillTotalLPGInstallation__c,Quote__r.skillTotalFireWallHeaterFixing__c,Quote__r.skillTotalElectrical__c,Quote__r.skillTotalContractorInstallation__c,Quote__r.skillTotalConnectSolarPanels__c,Quote__r.skillTotalBuildingWork__c,Quote__r.skillTotalPowerFlush__c,Quote__r.SkillTotalElectricalWorkASP__c,Quote__r.skillTotalAsbestosRemoval__c,Quote__r.skillTotalAsbestosRemovalFixedRate__c,Quote__r.skillTotalSolar__c,Quote__r.installationDate__c,Quote__r.deliveryDate__c,Installation_Date__c,Delivery_Date__c from Job__c where id =:jobId]; 
                updateJobDetails.overrideJob(job.Id); 
                              
    }
}