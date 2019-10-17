@isTest
private class TestAutopopCauser{
   
  static testMethod void myUnitTest() {
       //Test.startTest();
       Profile p = [SELECT p.ID FROM profile p WHERE Name='System Administrator' limit 1];
        User user = new User(LastName = 'us1er1', Alias = 'use1', 
                                Email = 'a1@b.com', Username='us1er1@gmail.com',
                                ProfileId = p.Id, EmailEncodingKey='UTF-8',
                                Migration_ID__c = 'user1@hotmail.com',
                                TimeZoneSidKey = 'Europe/London', 
                                LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        insert user;
        
      
       supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
       insert supplier;
       
        District__c TestSalesDistrict = new District__c(Type__c='Sales', Name='P1Controller_SalesDistrict', Code__c='xxxxxxxx');
        insert TestSalesDistrict;
        
        Sub_Patch__c TestSalesSubPatch = new Sub_Patch__c(Type__c='Sales',Name='P1Controller_SalesSubpatch', District__c=TestSalesDistrict.Id, Code__c='xxxxxxxx');
        insert TestSalesSubPatch;
       
       Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='SA',Salesforce_User__c=user.id,Supplier__c=supplier.Id);
       insert emp;
            
       TestSalesDistrict.DHMName__c=emp.id;
       TestSalesDistrict.STMName__c=emp.id;
       update TestSalesDistrict;
       
       Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                    BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City',Sales_Subpatch__c=TestSalesSubPatch.id);
       insert account;
        
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
        insert contact; 
        account.Primary_Contact__c = contact.id;
        update account;
        
                                       
        Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),                                                 
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,
                                                  Override_Billing_checks__c=false);
        insert opportunity; 
       Id availableRecordTypeId = [select id from RecordType where Name = 'Available' and SobjectType='Appointment__c' limit 1].Id;    
       datetime AppointmentTime0700am = datetime.newinstance(date.today().Year(), date.today().addMonths(1).Month(), date.today().addDays(1).Day(), 7,0,0);    
       datetime AppointmentTime0900am = datetime.newinstance(date.today().Year(), date.today().addMonths(1).Month(), date.today().addDays(1).Day(), 9,0,0);
       Appointment__c TestAppointment1 = new Appointment__c(Type__c='sales', Mode__c = 'SA', Start__c =AppointmentTime0700am, Show_Time_As__c='Out Of Office', RecordTypeId = availableRecordTypeId, End__c=AppointmentTime0900am, Assigned_To__c=emp.Id,opportunity__c=opportunity.id,status__c='Appointed',Who__c=contact.id);
       insert TestAppointment1;
       
       BigMachines_Quote__c quote= new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opportunity.Id,discountsTotalOnPricing__c=100,
                                  POC_Payment_Method__c = 'Finance',App_Assigned_To__c='test - ' + emp.Employee_Number__c, createdDate_quote__c = System.today(),
                                                             Stage__c = 'Quote Finalised - Accepted', bmstatusreason__c='Quote Finalised - Accepted',
                                                             is_primary__c=true, quote_reconciled__c = True,finalPriceVisibleToCustomer__c=1000,
                                                             priceMatchDifference__c = -45, ISpec_Difference__c = 45, Pricebook_Id__c='CHX');
                                                                 
        insert quote;
        quote.Pricebook_Id__c='CHX';
        quote.quoteNumber_quote__c=quote.Id;
        update quote;
        
        Job__c job = new Job__c(CHI_Lead__c = opportunity.ID, Quote__c=quote.Id,PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                            Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,Electrical_Hours__c = 1,Is_Remedial_Job__c = false, 
                            Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,Is_Downtime_Job__c = false ,
                            Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1,
                            Water_Heating_Fixing_Hours__c =  5,Customer_Preferred_Date__c = Date.today(), Contractors__c=true, Own_Labour__c=true,
                            Double_Handed_Job__c = true, Delivery_Date__c =Date.today(),Installation_Date__c=Date.today());                                                                 
            
                
         insert job;
        
        Installer__c inst = new Installer__c(name='Inst1',Sub_Type__c='Mechanical',user__c=user.id,Job__c=job.id,Start_Date__c=date.today().adddays(1),End_Date__c=date.today().adddays(1));
        insert inst;
        
        Case_Causer_Mappings__c CM1 = new Case_Causer_Mappings__c(name='map1',Cause__c='Installation visit',Causer__c='Mechanical Installer'); 
        Case_Causer_Mappings__c CM2 = new Case_Causer_Mappings__c(name='map2',Cause__c='Post Install/Aftercare - Installation',Causer__c='Mechanical Installer'); 
        Case_Causer_Mappings__c CM3 = new Case_Causer_Mappings__c(name='map3',Cause__c='Installation visit - Mangement',Causer__c='DHM'); 
        Case_Causer_Mappings__c CM4 = new Case_Causer_Mappings__c(name='map4',Cause__c='Sales visit - Management',Causer__c='DSM'); 
        Case_Causer_Mappings__c CM5 = new Case_Causer_Mappings__c(name='map5',Cause__c='Sales visit - Regulated activity',Causer__c='HSA'); 
        Case_Causer_Mappings__c CM6 = new Case_Causer_Mappings__c(name='map6',Cause__c='Sales visit',Causer__c='HSA'); 
        Case_Causer_Mappings__c[] CM = new Case_Causer_Mappings__c[]{CM1,CM2,CM3,CM4,CM5,CM6};
        Insert CM; 

       Test.startTest();         
       
       Case newCase=new Case();
            newCase.AccountId = account.Id;
            newCase.Opportunity__c = opportunity.Id;
            newCase.Origin = 'Web';
            newCase.Reason = 'New problem';
            newCase.Type = 'Customer Satisfaction Survey';
            newCase.Status = 'New';
            newCase.Priority = 'Medium';
            newCase.Case_Source__c = 'Customer';
            newCase.Preferred_Contact__c = 'Primary';
            newCase.OwnerId = UserInfo.getUserId();         
            newCase.ContactId = contact.Id;
            newCase.Primary_Cause__c = 'Installation visit - Mangement';
            newcase.Primary_Cause_2__c = 'Installation visit - Mangement';
            newcase.Primary_Cause_3__c = 'Installation visit - Mangement';
            
            insert newCase;
            newcase.Primary_Causer__c = null;
            newcase.Secondary_Causer__c = null;
            newcase.Third_causer__c = null;
            newcase.Primary_Cause__c = 'Sales visit - Management';
            newcase.Primary_Cause_2__c = 'Sales visit - Management';
            newCase.Primary_Cause_3__c = 'Sales visit - Management';
            
            update newcase;
            newcase.Primary_Causer__c = null;
            newcase.Secondary_Causer__c = null;
            newcase.Third_causer__c = null;
            newcase.Primary_Cause__c = 'Sales visit - Regulated activity';
            newcase.Primary_Cause_2__c = 'Sales visit - Regulated activity';
            newCase.Primary_Cause_3__c = 'Sales visit - Regulated activity';
            
            update newcase;
            newcase.Primary_Causer__c = null;
            newcase.Secondary_Causer__c = null;
            newcase.Third_causer__c = null;
            newcase.Primary_Cause__c = 'Sales visit';
            newcase.Primary_Cause_2__c = 'Sales visit';
            newCase.Primary_Cause_3__c = 'Sales visit';
            
            update newcase; 
            
            newcase.Primary_Causer__c = null;
            newcase.Secondary_Causer__c = null;
            newcase.Third_causer__c = null;
            newcase.Primary_Cause__c = 'Installation visit';
            newcase.Primary_Cause_2__c = 'Installation visit';
            newCase.Primary_Cause_3__c = 'Installation visit';
            
            update newcase; 
            
            newcase.Primary_Causer__c = null;
            newcase.Secondary_Causer__c = null;
            newcase.Third_causer__c = null;
            newcase.Primary_Cause__c = 'Post Install/Aftercare - Installation';
            newcase.Primary_Cause_2__c = 'Post Install/Aftercare - Installation';
            newCase.Primary_Cause_3__c = 'Post Install/Aftercare - Installation';
            
            update newcase; 
             
            test.stopTest();
                  
       
    }
   
   
  
}