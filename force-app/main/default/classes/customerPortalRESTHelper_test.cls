@istest
public class customerPortalRESTHelper_test {
    
    private static testmethod void  secnario1()
    {
        dynamicCustomerPortalJSONClass obj_Inner = new dynamicCustomerPortalJSONClass();
        obj_Inner.evenList = new list<customerPortalEventClass>();
        
        Account acc = TestClassHelper.createAccout();
        insert acc;
        
        Contact con = TestClassHelper.createContact(acc);
        insert con;
        
        Opportunity opp  = TestClassHelper.createCHILead(acc);
        insert opp;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'sta11', Email='stan1@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stand1@testorg.com');
            insert u;
        
        Employee__c emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c=u.id;
        insert emp;
        id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        
        Bigmachines_Quote__c bmQuote1 = TestClassHelper.createBMQuote(opp);
        bmQuote1.Is_Primary__c = false;
        bmQuote1.Status__c = 'Quote Finalised - Not Accepeted';
        insert bmQuote1;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        Bigmachines_Quote__c bmQuote2 = TestClassHelper.createBMQuote(opp);
        insert bmQuote2;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        Job__c j = TestClassHelper.createJob('Pending', 'Install Date Required', opp.Id, null );
        insert j;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        
        j.Status__c = 'Suspended';
        update j;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        List <Job__c> jList = [Select id , CHI_Lead__c from Job__c where Status__c = 'Allocated' and lastModifiedDate>=: system.today().addDays(-2)];
        
        if(jList.size()>0)
        customerPortalRESTHelper.post(string.valueof(jList[0].CHI_Lead__c), 'test bowser', 'test ip', 'test resloution');
        
        jList = [Select id , CHI_Lead__c from Job__c where Status__c = 'Installed' and lastModifiedDate>=: system.today().addDays(-2)];
        
        if(jList.size()>0)
        customerPortalRESTHelper.post(string.valueof(jList[0].CHI_Lead__c), 'test bowser', 'test ip', 'test resloution');
        
        
      
    }
    private static testmethod void  secnario2()
    {
        dynamicCustomerPortalJSONClass obj_Inner = new dynamicCustomerPortalJSONClass();
        obj_Inner.evenList = new list<customerPortalEventClass>();
        
        Account acc = TestClassHelper.createAccout();
        insert acc;
        
        Contact con = TestClassHelper.createContact(acc);
        insert con;
        
        Opportunity opp  = TestClassHelper.createCHILead(acc);
        insert opp;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
         User u = new User(Alias = 'stand11', Email='stan11@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='stand11@testorg.com');
            insert u;
        
        Employee__c emp = TestClassHelper.createEmployee( );
        emp.Salesforce_User__c=u.id;
        insert emp;
        emp.Inactive__c=false;
        update emp;
        id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
        app.Assigned_To__c=emp.id;
        insert app;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        
        Bigmachines_Quote__c bmQuote1 = TestClassHelper.createBMQuote(opp);
        bmQuote1.Is_Primary__c = false;
        bmQuote1.Status__c = 'Quote Finalised - Not Accepeted';
        insert bmQuote1;
        
        bmQuote1.Is_Primary__c = false;
        update bmQuote1;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
      
        Job__c j = TestClassHelper.createJob('Planned', 'Install Date Required', opp.Id, null );
        insert j;
        customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        j.Status__c = 'Installed';
        update j;
         customerPortalRESTHelper.post(string.valueof(opp.id), 'test bowser', 'test ip', 'test resloution');
        
        date today=system.today();
        date endDate=system.today()+10;
        
        customerPortalRESTHelper pHelper=new customerPortalRESTHelper();
        pHelper.createChildEvent(true,today,endDate,'t1','t2','t3','t4','t5','t6','t7');
        
    }




    private static testmethod void  secnarioPhase3aAcceptQuoteNegativeScenarios()
    {
        
        Account acc = TestClassHelper.createAccout();
        insert acc;
        
        Contact con = TestClassHelper.createContact(acc);
        insert con;
        
        Opportunity opp  = TestClassHelper.createCHILead(acc);

        insert opp;

        opp = [Select id, Opp_Id_Encrypted__c from Opportunity where id = :opp.Id ];

        system.debug('before update---->'+opp);
        update opp;
        system.debug('After update---->'+opp);
         
        Employee__c emp = TestClassHelper.createEmployee( );
        emp.Salesforce_User__c=userinfo.getuserid();
        insert emp;
       
        id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
        app.Assigned_To__c=emp.id;
        insert app;
        
        system.debug('ID Ecrypted-- >'+opp.Opp_Id_Encrypted__c);
        // before Quote
        customerPortalQuoteHelper.getQuote(opp.Opp_Id_Encrypted__c);
        
        Bigmachines_Quote__c bmQuote1 = TestClassHelper.createBMQuote(opp);
        bmQuote1.Is_Primary__c = false;
        bmQuote1.Status__c = 'Quote Finalised - Not Accepeted';
        bmQuote1.bmStatusReason__c = 'Still Considering';
        insert bmQuote1;
        // without quote submitted date
        customerPortalQuoteHelper.getQuote(opp.Opp_Id_Encrypted__c);


        // after with out quote odf
        bmQuote1.Is_Primary__c = false;
        bmQuote1.stage__c = 'Quote Finalised - Not Accepeted';
        bmQuote1.SubmittedDate_quote__c = system.today().adddays(-30);
        bmQuote1.bmStatusReason__c = 'Asbestos';
        update bmQuote1;
        customerPortalQuoteHelper.getQuote(opp.Opp_Id_Encrypted__c);

        // after Asbestos
        bmQuote1.SubmittedDate_quote__c = system.today().adddays(-30);
        bmQuote1.bmStatusReason__c = 'Asbestos';
        update bmQuote1;
        customerPortalQuoteHelper.getQuote(opp.Opp_Id_Encrypted__c);


    }
 
    private static testmethod void  secnarioPhase3aAcceptQuotePostitiveScenarios()
    {
        
        Account acc = TestClassHelper.createAccout();
        insert acc;
        
        Contact con = TestClassHelper.createContact(acc);
        insert con;
        
        Opportunity opp  = TestClassHelper.createCHILead(acc);

        insert opp;

        opp = [Select id, Opp_Id_Encrypted__c from Opportunity where id = :opp.Id ];

        system.debug('before update---->'+opp);
        update opp;
        system.debug('After update---->'+opp);
         
        Employee__c emp = TestClassHelper.createEmployee( );
        emp.Salesforce_User__c=userinfo.getuserid();
        insert emp;
       
        id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
        app.Assigned_To__c=emp.id;
        insert app;
        
        system.debug('ID Ecrypted-- >'+opp.Opp_Id_Encrypted__c);
        
        Bigmachines_Quote__c bmQuote1 = TestClassHelper.createBMQuote(opp);
        bmQuote1.Is_Primary__c = false;
        bmQuote1.stage__c = 'Quote Finalised - Not Accepeted';
        bmQuote1.Sub_Status__c = 'Still Considering';
        bmQuote1.SubmittedDate_quote__c = system.today().adddays(-30);
        insert bmQuote1;
        
        Attachment att = TestClassHelper.createAttachemnt(bmQuote1.Id);
        att.Name = '1234Test_quote.pdf';
        insert att;

        // without quote submitted date
        customerPortalQuoteHelper.getQuote(opp.Opp_Id_Encrypted__c);

        Product2 product2 = new Product2(ProductCode='CBLR001', Name='CBLR001', BigMachines_Part_Number__c='CBLR001',  IsActive = true); 
        insert product2;

        Quote_Product__c qp = TestClassHelper.createQuoteProduct(bmQuote1.Id);
        qp.Product__c = product2.Id;
        insert qp;

        customerPortalQuoteHelper.getQuote(opp.Opp_Id_Encrypted__c);




    }

    private static testmethod void  secnarioPhase3aAcceptQuoteAcceptScenarios()
    {

        Account acc = TestClassHelper.createAccout();
        insert acc;
        
        Contact con = TestClassHelper.createContact(acc);
        insert con;
        
        Opportunity opp  = TestClassHelper.createCHILead(acc);

        insert opp;

        opp = [Select id, Opp_Id_Encrypted__c from Opportunity where id = :opp.Id ];

        system.debug('before update---->'+opp);
        update opp;
        system.debug('After update---->'+opp);
         
        Employee__c emp = TestClassHelper.createEmployee( );
        emp.Salesforce_User__c=userinfo.getuserid();
        insert emp;
       
        id appt = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Appointment');
        Appointment__c app = TestClassHelper.createAppointment(opp, emp.id, userinfo.getuserid(),appt, con.Id );
        app.Assigned_To__c=emp.id;
        insert app;
        
        system.debug('ID Ecrypted-- >'+opp.Opp_Id_Encrypted__c);
        
        Bigmachines_Quote__c bmQuote1 = TestClassHelper.createBMQuote(opp);
        bmQuote1.Is_Primary__c = false;
        bmQuote1.stage__c = 'Quote Finalised - Not Accepeted';
        bmQuote1.Sub_Status__c = 'Still Considering';
        bmQuote1.SubmittedDate_quote__c = system.today().adddays(-30);
        insert bmQuote1;
        try{
        customerPortalAcceptQuote.acceptQuote(opp.Opp_Id_Encrypted__c, null, null, null, null, null, null);
        } catch(Exception e){}
        
        try{
            customerPortalAcceptQuote.acceptQuote(opp.Opp_Id_Encrypted__c, bmQuote1.Id, '13/10/2017 15:31', '19/10/2017 00:00', '5pm - 7pm', 'Finance', true);
        } catch(Exception e){}

        try{
            customerPortalAcceptQuote.acceptQuote(opp.Opp_Id_Encrypted__c, bmQuote1.Id, '13/10/2017 15:31', '19/10/2017 00:00', '5pm - 7pm', 'Payment On Completion', true);
        } catch(Exception e){}

         try{
            customerPortalAcceptQuote.acceptQuote(opp.Opp_Id_Encrypted__c, bmQuote1.Id, '13/10/2017 15:31', '19/10/2017 00:00', '5pm - 7pm', 'Cancelled', true);
        } catch(Exception e){}

    } 


    @testSetup
    private static void setUpdata()
    {
        list<IV_Vectors__c > vectorList = new list<IV_Vectors__c>();
        vectorList.add(new IV_Vectors__c(Name = 'Customer Portal', Key__c = '380db410e8b11fa9') );
        vectorList.add(new IV_Vectors__c(Name = 'Quote_Expiry_Days', Key__c = '90') );
        vectorList.add(new IV_Vectors__c(Name = 'Portal Key Length', Key__c = '8') );
        vectorList.add(new IV_Vectors__c(Name = 'Quote_Created_Time', Key__c = '30') );
        vectorList.add(new IV_Vectors__c(Name = 'Portal Second Phase', Key__c = '2017-02-16') );
        vectorList.add(new IV_Vectors__c(Name = 'Finance_Accepted_Statuses', Key__c = ',Accepted,Parked,') );
        vectorList.add(new IV_Vectors__c(Name = 'Finance_Reffered_Statuses', Key__c = ',Referred,') );
        insert vectorList;




    }
    

}