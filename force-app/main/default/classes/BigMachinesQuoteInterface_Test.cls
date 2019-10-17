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
private class BigMachinesQuoteInterface_Test {
    
     static testmethod void TestBigMachinesQuoteInterface(){

        id Avav = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        
        User u = TestClassHelper.createUser();
        insert u;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = u.Id;
        emp.UsesBM__c = true;
        emp.Default_Pricebook_ID__c = 'CHC';
        insert emp;
        
        Account acct = TestClassHelper.createAccout();
        acct.BillingPostalCode = 'SK1 2QL';
        acct.Phone = '012345678';
        acct.Fax = '012345678';
        acct.Country_Differentiator__c = 'test';
        acct.Asbestos_Found_Date_New__c = system.today();
        acct.healthSafety_Notes__c = 'Notes';
        acct.Number_of_Bedrooms__c = 2;
        acct.Patch_ID__c = 'test';
        insert acct;
        
        ProductHolding__c prdHldng = TestClassHelper.createProductHodling(acct.id);
        prdHldng.IsCurrentCustomerOfAnyProduct__c = 'Yes';
        insert prdHldng;
        
        Contact c = TestClassHelper.createContact(acct);
        c.Preferred_Contact_Method__c = 'Text (SMS)';
        c.HomePhone ='01234567899';
        c.MobilePhone='01234567899';
        c.OtherPhone='01234567899';
        c.OtherStreet = 'OtherStreet';
        c.OtherCity = 'other city';
        c.OtherPostalCode = 'other code';
        c.OtherState = 'other state';
        c.OtherCountry = 'other country';
        c.Email__c = 'test@test.com';
        insert c;
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign; 
        
        Campaign newCampaign1 = new Campaign(Name = 'Test Temp Campaign1', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue' , ParentId = newCampaign.Id);
        insert newCampaign1;
        
        Opportunity opty = TestClassHelper.createCHILead(acct);
        opty.Enquiry_Type__c = 'test Type';
        opty.Lead_Comments__c = 'Test Comments';
        opty.Visit_Type__c = 'Sales';
        opty.Comments__c = 'Test Comments';
        opty.Is_the_customers_boiler_working__c = 'Yes';
        opty.Is_the_customer_vulnerable__c = 'Yes';
        opty.Does_the_customer_have_hot_water__c = 'No';
        opty.Vulnerable_reason__c = 'Simply';
        opty.Customer_have_any_other_form_of_HEAT__c = 'Yes';
        opty.Latest_customer_category__c = 1;
        opty.SMStatus__c = 'Eligible';
        opty.Free_Insulation_Eligible__c = 'Yes';
        opty.GDCashBack__c = true;
        opty.CampaignId = newCampaign1.Id;
        insert opty;
        
        Appointment__c App = TestClassHelper.createAppointment(opty,emp.Id,u.Id,Avav,c.id);
        Datetime now = datetime.now();
        Datetime startTime = Datetime.newInstance(now.year(), now.month(), now.day()+1, 6, 0, 0);
        App.Start__c = startTime;
        Datetime endTime = Datetime.newInstance(now.year(), now.month(), now.day()+1, 8, 0, 0);
        App.End__c = endTime;
        insert App;
        
        List<ID> AppId = new List<ID>();
            
        AppID.add(App.Id);
         BigMachinesQuoteInterface.getAppointment(AppId);
         BigMachinesQuoteInterface.getCHILead(App.Opportunity__c);
         BigMachinesQuoteInterface.getAssociatedApps(App.Opportunity__c, App.Start__c);
        BigMachinesQuoteInterface.getAccount(opty.AccountID);
        ProductHoldingAccount__c pd1  = new ProductHoldingAccount__c();
        pd1 = TestClassHelper.createProductHodlingAcnt(opty.AccountID);
        ProductHoldingAccount__c pd2  = new ProductHoldingAccount__c();
        pd2 = TestClassHelper.createProductHodlingAcnt(opty.AccountID);
        pd2.Type__c='Electricity';
       
        BigMachinesQuoteInterface.createFullUpdateXMLString(null, App, opty, acct, null, new list<ProductHoldingAccount__c>{pd1,pd2});
        BigMachinesQuoteInterface.createCancelXMLString();
        BigMachinesQuoteInterface.login();
        BigMachinesQuoteInterface.createQuote('12345678');
        BigMachinesQuoteInterface.updateQuote('12345678', '12345678', 'XMLUpdateMsg', 'BMAction');    
        BigMachinesQuoteInterface.batchUpdateBigMachines();
        //try{BigMachinesQuoteInterface.updateBigMachines(AppId);}catch(Exception e){}
        //try{BigMachinesQuoteInterface.updateBigMachinesWhenCancelled(AppId);}catch(Exception e){}
        //try{BigMachinesQuoteInterface.updateBigMachinesWhenAppReassigned(AppId,'test@test.com');}catch(Exception e){}
    }  
}