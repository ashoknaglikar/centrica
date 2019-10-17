/**
 
 */
@isTest
private class aupd_CheckReplanning_test {

    static testMethod void CheckReplanning() {
       
        try{
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
        
        NIAS_Code__c Nias =[select id,PYMT_CODE__c,GEOG_CODE__c from NIAS_Code__c Nias limit 1];

        
        //inserting opportunity with different employee
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
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

        job = new Job__c(CHI_Lead__c = opp[0].ID,Quote__c=quote.Id, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =  5, 
                                Customer_Preferred_Date__c = Date.today()-1, Contractors__c=true, Own_Labour__c=true,
                                Double_Handed_Job__c = true, Delivery_Date__c =system.today()-1,Installation_Date__c=system.today()-1,District__c=district.Id,Installer__c=UInstal1.Id);
                                        
                        
        insert job;
        Job_Element__c JE = new Job_Element__c();
        JE.Job__c = job.Id;
        insert JE;
        //update job;   
        
        Order__c ord = new Order__c();
        ord.Job__c= job.Id;
        ord.Type__c='Material';
        ord.Delivery_Date_Changed__c=false;
        insert ord;
              
        Order_Line_Item__c OrdLine = new Order_Line_Item__c();
        OrdLine.Order_Line_Item_Number__c=714;
        OrdLine.P5_Job_Element__c=JE.Id;
        OrdLine.P5_Purchase_Order__c=ord.Id;
        ordline.P5_Product__c=product.Id;
        insert OrdLine;
        
        
        system.debug(job.Delivery_Date__c+'before update###');
        job.Delivery_Date__c = system.today()+3;
        job.Installation_Date__c=system.today()+3;
        update job;
        
        system.debug(job.Delivery_Date__c+'After update###');
        
        //code fix done by BGSAMS support - RHC Batch 7/11/2012 - starts
        
        Lock.jobTriggerSwitch=true;
        update job;
        
        //code fix done by BGSAMS support - RHC Batch 7/11/2012 - ends
        
        }
        catch(system.Exception e)
        {
            
        }
        
    
    }
    
    static testmethod void setJobSkillHistory(){
        Account acc = TestClassHelper.createAccout();
        insert acc;
        Contact con = TestClassHelper.createContact(acc);
        insert con;
        Opportunity opp =  TestClassHelper.createCHILead(acc);
        insert opp;
        District__c dist = TestClasshelper.createDistrict();
        insert dist;
        Job__c job =  TestClassHelper.createJob('plannes', 'planned', opp.id, dist.id);
        job.Water_Heating_Fixing_Hours__c = 1;
        job.Unvented_Hot_Water_Hours__c = 1;
        job.Specialist_Building_Hours__c = 1;
        job.Solar_Hours__c = 1;
        job.Scaffolder_Hours__c = 1;
        job.Roof_Work_Hours__c = 1;
        job.PowerFlush_Hours__c = 1;
        job.Payment_Collection_Hours__c = 1;
        job.Mechanical_Hours__c = 1;
        job.LPG_Installation_Hours__c = 1;
        job.Fire_Wall_Heater_Fixing_Hours__c = 1;
        job.Electrical_Work_ASP_Hours__c = 1;
        job.Electrical_Hours__c = 1;
        job.Contractor_Installation_Hours__c = 1;
        job.Connect_Solar_Panel_Hours__c = 1;
        job.Building_Work_Hours__c = 1;
        job.Asbestos_Removal_Hours__c = 1;  
        job.Asbestos_Removal_Fixed_Rate_Hours__c = 1;   
        job.Ecogen_Electrical_Hours__c = 1;   
        job.Ecogen_Mechanical_Hours__c = 1;   
        job.ECO_Hours__c = 1; 
        insert job; 
        
        job.Water_Heating_Fixing_Hours__c = 2;
        job.Unvented_Hot_Water_Hours__c = 2;
        job.Specialist_Building_Hours__c = 2;
        job.Solar_Hours__c = 2;
        job.Scaffolder_Hours__c = 2;
        job.Roof_Work_Hours__c = 2;
        job.PowerFlush_Hours__c = 2;
        job.Payment_Collection_Hours__c = 2;
        job.Mechanical_Hours__c = 2;
        job.LPG_Installation_Hours__c = 2;
        job.Fire_Wall_Heater_Fixing_Hours__c = 2;
        job.Electrical_Work_ASP_Hours__c = 2;
        job.Electrical_Hours__c = 2;
        job.Contractor_Installation_Hours__c = 2;
        job.Connect_Solar_Panel_Hours__c = 2;
        job.Building_Work_Hours__c = 2;
        job.Asbestos_Removal_Hours__c = 2;  
        job.Asbestos_Removal_Fixed_Rate_Hours__c = 2;   
        job.Ecogen_Electrical_Hours__c = 2;   
        job.Ecogen_Mechanical_Hours__c = 2;   
        job.ECO_Hours__c = 2;      
        
        try{
            update job;
        }
        catch(Exception e){
            System.debug('Exception : ====='+e.getMessage());
        }
                               
    }
}