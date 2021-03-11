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
private class SendAppointment_Test {

    static testMethod void AppReport(){
        
        //Appointment__c insertApp = new Appointment__c();
        RecordType recType = [select id from recordtype where sObjectType ='Appointment__c' and Name='Appointment'];
        
        Account acc = new Account(name = 'test  account', BillingStreet='8 Merten', 
                                  BillingPostalCode='SW19 6DE', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London',Landlord_Account__c = true);
        
        Database.insert(acc);
        ProductHolding__c prd = TestClassHelper.createProductHodling(acc.Id);
        insert prd;
        
        ProductHoldingAccount__c prdA = TestClassHelper.createProductHodlingAcnt(prd.Id);
        insert prdA;
        
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp); 
        Contact contact = new Contact(AccountId=acc.Id,Best_Phone__c='01234567890', LastName='updateContact Test', HomePhone = '01234567890',MobilePhone = '01234567890',OtherPhone = '01234567890' );
        Database.insert(contact);
        
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'test extract flag lead', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Appointed', 
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id,
                                            Latest_customer_category__c = 1,
                                            SMStatus__c = 'Eligible',
                                            ta_notes__c = 'test Notes',
                                            Lead_Comments__c= 'test Comments',
                                            GDCashBack__c =true);      
        Database.insert(opp);
        Employee__c emp = new Employee__c(Employee_Number__c='98750496',Name='Emp Name',primary_role__C = 'HSA',Is_app_email_ready__c=true,SalesForce_User__c = UserInfo.getUserId());
        Database.insert(emp);
        
        Datetime startdt = DateTime.newInstance((System.today()).year(), (System.today()).month(), (System.today()).day(), (System.now()).hour(),00,00);
        Datetime enddt = DateTime.newInstance((System.today()).year(), (System.today()).month(), (System.today()).day(), (System.now()).hour()+ 13,30,00);
        
        Appointment__c insertApp = new Appointment__c(Assigned_To__c= emp.id,RecordTypeId = recType.id,Who__c = contact.Id,
                                                Start__c = startdt, End__c = enddt,Subject__c = 'test appointment report',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',Type__c='Sales',TA_Notes_Group_4__c = 'test',Appointment_Attendee__c = 'Tenant');
       
        List<Appointment__c> lstapp= new List<Appointment__c>();
        Opportunity opp2 = TestClassHelper.createCHILead(acc);
        insert opp2;
        
        Appointment__c app = TestClassHelper.createAppointment(opp2,emp.id,userinfo.getuserid(),recType.id, contact.id);
         
        lstapp.add(insertApp);
        lstapp.add(app);
        insert lstapp;
        
        //lstapp= [SELECT a.assigned_to__r.primary_role__c,Opportunity__r.SMStatus__c,Appointment_Attendee__c,HSAOfficePrecalled__c,assigned_to__r.Is_app_email_ready__c,a.Opportunity__r.Campaign.Media_Cost_Code__c,a.Opportunity__r.Campaign.Description,a.Opportunity__r.Product_Interest__c,a.Assigned_To__r.Salesforce_User__c,a.Assigned_To__r.Salesforce_User__r.Email,a.Opportunity__r.Lead_Comments__c,a.Opportunity__r.Landlord_Lead_Details__c,a.Visit_Date__c, job__r.name, a.Type__c,recordtype.name,a.TA_Notes_All__c, a.Subject__c,a.Status__c, a.Skill__c, a.Offer__c, a.Notes__c, a.EmployeeName__c, a.Duration__c, a.Description__c,a.Contact_Work_Phone__c, a.Contact_Phone__c, a.Contact_Mobile__c, a.Contact_Home_Phone__c, a.Contact_Best_Phone__c,a.Call_Notes__c, a.CHI_Lead_Number_For_Ref_Emp__c, a.CHI_Lead_No__c, a.Billing_Street__c, a.Billing_City__c, a.Big_Machines_Quote_ID__c, a.BM_Salesperson__c, a.Assigned_To_Phone__c, a.Assigned_To_Name__c,a.Who__r.Name,  End_Time__c,a.Start_Time__c, a.Postcode_Sector__c, opportunity__r.name,Pref_Contact_Method__c,a.Duration_Mins_Calc__c,opportunity__r.Account.BillingCountry, opportunity__r.Account.billingPostalCode, opportunity__r.Account.BillingState, opportunity__r.Account.BillingCity, opportunity__r.Account.BillingStreet,who__r.salutation,a.Big_Machines_Quote_Number__c,Assigned_To__c, opportunity__r.Account.Asbestos_found__c, opportunity__r.Account.Asbestos_Found_Date_New__c,Opportunity__r.ta_notes__c,opportunity__r.Account.Landlord_Account__c,opportunity__r.Latest_customer_category__c,opportunity__r.GDCashBack__c , opportunity__r.Free_Insulation_Eligible__c  From Appointment__c a WHERE   id = :insertApp.Id];
        Database.BatchableContext BC;
        Test.StartTest();
        SendAppointment Sendapp=new SendAppointment();     
          
        SendAppointment.sendAppListLink();  
        Test.StopTest();

    }
    
    static testmethod void grreDealAppt()
    {
        RecordType recType = [select id from recordtype where sObjectType ='Appointment__c' and Name='Appointment'];
        
        Account acc = new Account(name = 'test  account', BillingStreet='8 Merten', 
                                  BillingPostalCode='SW19 6DE', BillingCity='London', 
                                  BillingCountry='UK', BillingState='London',Landlord_Account__c = true,Asbestos_Found_Date_New__c = system.today(),Asbestos_found__c='Yes');
        
        Database.insert(acc);
        ProductHolding__c prd = TestClassHelper.createProductHodling(acc.Id);
        insert prd;
        
        ProductHoldingAccount__c prdA = TestClassHelper.createProductHodlingAcnt(prd.Id);
        insert prdA;
        
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
        Database.insert(camp); 
        Contact contact = new Contact(AccountId=acc.Id,Best_Phone__c='01234567890', LastName='updateContact Test', MobilePhone = '01234567890',OtherPhone = '01234567890' );
        Database.insert(contact);
        
        Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'test extract flag lead', 
                                            AccountId = acc.Id, 
                                            CloseDate = Date.today().addyears(1), 
                                            StageName = 'Appointed', 
                                            Product_Interest__c='Central Heating Boiler',
                                            CampaignId = camp.Id,
                                            Latest_customer_category__c = 1,
                                            SMStatus__c = 'Eligible',
                                            ta_notes__c = 'test Notes',
                                            Lead_Comments__c= 'test Comments',
                                            GDCashBack__c =true);      
        Database.insert(opp);
        Employee__c emp = new Employee__c(Employee_Number__c='98750496',Name='Emp Name',primary_role__C = 'HSA',Is_app_email_ready__c=true,SalesForce_User__c = UserInfo.getUserId());
        Database.insert(emp);
        
        Datetime startdt = DateTime.newInstance((System.today()).year(), (System.today()).month(), (System.today()).day(), (System.now()).hour(),00,00);
        Datetime enddt = DateTime.newInstance((System.today()).year(), (System.today()).month(), (System.today()).day(), (System.now()).hour()+ 13,30,00);
        
        Appointment__c insertApp = new Appointment__c(Assigned_To__c= emp.id,RecordTypeId = recType.id,Who__c = contact.Id,
                                                Start__c = startdt, End__c = enddt,Subject__c = 'test appointment report',
                                                Opportunity__c = opp.Id, Status__c = 'Appointed',Type__c='Green Deal',TA_Notes_Group_4__c = 'test',Appointment_Attendee__c = 'Tenant');
       
        
        Opportunity opp2 = TestClassHelper.createCHILead(acc);
        insert opp2;
        Appointment__c app = TestClassHelper.createAppointment(opp2,emp.id,userinfo.getuserid(),recType.id, contact.id);
         
        
        List<Appointment__c> lstapp= new List<Appointment__c>();
        lstapp.add(insertApp);
        lstapp.add(app);
        insert lstapp;
        BigMachines_Quote__c bm = TestClassHelper.createBMQuote(opp);
        bm.Is_Primary__c =true;
        insert bm;
        lstapp= [SELECT a.assigned_to__r.primary_role__c,Opportunity__r.SMStatus__c,Appointment_Attendee__c,HSAOfficePrecalled__c,assigned_to__r.Is_app_email_ready__c,a.Opportunity__r.Campaign.Media_Cost_Code__c,a.Opportunity__r.Campaign.Description,a.Opportunity__r.Product_Interest__c,a.Assigned_To__r.Salesforce_User__c,a.Assigned_To__r.Salesforce_User__r.Email,a.Opportunity__r.Lead_Comments__c,a.Opportunity__r.Landlord_Lead_Details__c,a.Visit_Date__c, job__r.name, a.Type__c,recordtype.name,a.TA_Notes_All__c, a.Subject__c,a.Status__c, a.Skill__c, a.Offer__c, a.Notes__c, a.EmployeeName__c, a.Duration__c, a.Description__c,a.Contact_Work_Phone__c, a.Contact_Phone__c, a.Contact_Mobile__c, a.Contact_Home_Phone__c, a.Contact_Best_Phone__c,a.Call_Notes__c, a.CHI_Lead_Number_For_Ref_Emp__c, a.CHI_Lead_No__c, a.Billing_Street__c, a.Billing_City__c, a.Big_Machines_Quote_ID__c, a.BM_Salesperson__c, a.Assigned_To_Phone__c, a.Assigned_To_Name__c,a.Who__r.Name,  End_Time__c,a.Start_Time__c, a.Postcode_Sector__c, opportunity__r.name,Pref_Contact_Method__c,a.Duration_Mins_Calc__c,opportunity__r.Account.BillingCountry, opportunity__r.Account.billingPostalCode, opportunity__r.Account.BillingState, opportunity__r.Account.BillingCity, opportunity__r.Account.BillingStreet,who__r.salutation,a.Big_Machines_Quote_Number__c,Assigned_To__c, opportunity__r.Account.Asbestos_found__c, opportunity__r.Account.Asbestos_Found_Date_New__c,Opportunity__r.ta_notes__c,opportunity__r.Account.Landlord_Account__c,opportunity__r.Latest_customer_category__c,opportunity__r.GDCashBack__c , opportunity__r.Free_Insulation_Eligible__c From Appointment__c a WHERE   id in :lstapp];
        Database.BatchableContext BC;
        Test.StartTest();
        SendAppointment Sendapp=new SendAppointment();     
        Sendapp.start(BC);
        Sendapp.execute(BC,lstapp); 
        Test.stoptest();
    }
}