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
private class bINSUPD_chkEmpSkillForItnry_test {

    static testMethod void chkEmpSkilItnryTest() {
        
        String itineraryId1 = RecordTypeIdHelper.getRecordTypeId('Appointment__c','Itinerary');
       // String itineraryId2 = RecordTypeIdHelper.getRecordTypeId('Itinerary');
        
        Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
     
        insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact;  
        
        Appointment__c  appmnt = new Appointment__c ();
        
        Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
        insert supplier;
        
        Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser@testorg.com',Migration_ID__c ='A763BHe32345');
        insert UInstal1;
        Employee__c emp = new Employee__c(Name = 'testJI1', salesforce_user__c = UInstal1.id, First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        insert emp;
        
        Employee_Skills__c EmpSkill = new Employee_Skills__c();   
        EmpSkill.Employee__c = emp.Id;
        EmpSkill.Skill_Name__c =  'Asbestos Removal'; 
        EmpSkill.Own_Jobs_Only__c=true;
        EmpSkill.Skill_Type__c = 'Own Jobs Only';
        insert EmpSkill;
        
        
        NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Active',CloseDate=System.today().addYears(1),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
                                                    
        /*Opportunity opportunity1 = new Opportunity(Name = 'Test2 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),
                                                AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=true);
        Opportunity[] opp = new Opportunity[]{opportunity, opportunity1};  */                                               
        insert opportunity;
        
        BGS_Payment__c payment = new BGS_Payment__c(Opportunity__c=opportunity.Id,Contact__c=contact.Id,Payment_Method__c=Nias.PYMT_CODE__c);
        insert payment;

 
                
        BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
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

        job = new Job__c(CHI_Lead__c = opportunity.ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today().adddays(2), Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =system.today().adddays(1),Installation_Date__c=system.today().adddays(2),District__c=district.Id,Installer__c=UInstal1.Id);
                         
        
                        
        insert job;
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        JE.P5_IsItinerary__c=true;
        JE.Skill__c='Asbestos Removal';
        JE.Type__c='Itinerary';
        JE.P5_IsItinerary__c = true;
        insert JE;
        appmnt.RecordTypeId = itineraryId1 ;
        appmnt.Job_Element__c = JE.Id;
        appmnt.Any_Time__c =true;
        appmnt.Start__c = system.today();
        appmnt.End__c = system.today().addDays(1);
        appmnt.Assigned_To__c=emp.id;
        appmnt.Type__c = 'Asbestos Removal';
        insert appmnt;
        
       
    }
}