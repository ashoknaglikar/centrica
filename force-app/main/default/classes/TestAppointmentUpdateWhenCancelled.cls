public class TestAppointmentUpdateWhenCancelled {
    //
    static testMethod void testAppointmentUpdateWhenCancelled () {
    
       //User temp_user = [select Id from User where Email = 'prashant.kulkarni@centrica.com'and isActive = true limit 1];
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
        
        
        Employee__c emp = new Employee__c (First_Name__c='Jon',
                                           last_name__c='B',
                                           Salesforce_User__c =userinfo.getuserID(),
                                           employee_number__c='jj');
                                           
        Database.SaveResult empSv = Database.Insert(emp);
        
        Datetime startt = Datetime.newInstance(2015, 6, 15, 7, 0, 0);
        Datetime endt = Datetime.newInstance(2015, 6, 15, 9, 0, 0);
        
        
        Appointment__c firstApp = new Appointment__c(Assigned_To__c=empSv.getId(), 
                                                     Status__c='Appointed',
                                                     Start__c = startt, End__c = endt, 
                                                     Visit_Type__c = 'First Visit', Type__c = 'Sales',
                                                     Overbooked__c = false, Mode__c = 'SA', Opportunity__c= opp.Id, Who__c = contact.Id);
        Database.SaveResult app = Database.Insert(firstApp);
        
        integer cntBefore = [select count() from Appointment__c where Start__c = :startt and end__c = :endt and Assigned_To__c = :empSv.getId()]; 
        Appointment__c upApp = new Appointment__c(id=app.getId(), Status__c='Cancelled', Status_Reason__c = 'FAILED CREDIT', Primary_cancellation_reason__c = 'test', Secondary_cancellation_reason__c = 'test');
        update upApp;
        
        
        integer cntAfter = [select count() from Appointment__c where Start__c = :startt and end__c = :endt and Assigned_To__c = :empSv.getId()];
        
        System.debug('Before ' + cntBefore + ' After ' + cntAfter);
        //System.assertNotEquals(cntBefore, cntAfter);
        
    }
    
}