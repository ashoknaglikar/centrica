@isTest 
Private class NotifyTaskOverDue_test
{
	private static RecordType recordType=[Select r.SobjectType,r.Name, r.Id From RecordType r  where r.Name=:'Complaint' and r.SobjectType=:'Case' limit 1];
	private static Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
    static testMethod void testBatchwithInValidData()
    {
    	DateTime createdDateValue = DateTime.now(); //DateTime variable
        String createdDate_Formatted_Date = createdDateValue.format('yyyy-MM-dd'); //date portion of the createdDateValue variable formatted as Strting
        String createdDate_Formatted_Time = createdDateValue.format('HH:mm:ss'); //time portion of the createdDateValue variable formatted as Strting
        String createdDate_Formatted_Zone = createdDateValue.format('Z'); //timezone offset of the createdDateValue variable formatted as Strting
        String finalDateTimeValue = createdDate_Formatted_Date+'T'+createdDate_Formatted_Time+createdDate_Formatted_Zone.substring(0, createdDate_Formatted_Zone.length()-2)+':00';    
    	cls_IsRun.generalTriggerSwitch = true;
        cls_IsRun.dontFireTriggers = true;
        Database.BatchableContext BC;
        NotifyTaskOverDue nto=new NotifyTaskOverDue();
        NotifyTaskOverDue.notifyManagers();
        List<Case> ca=new List<Case>();

        //recordType = [Select r.SobjectType,r.Name, r.Id From RecordType r  where r.Name=:'Complaint' and r.SobjectType=:'Case' limit 1];
        
       
           
        Account acc1 = new Account(name = 'RA UpdateAcc', BillingStreet='19 Roundacre',BillingPostalCode='SW19 6DB', BillingCity='London',BillingCountry='UK', BillingState='London');    
        insert(acc1);  
        
        Contact contact = new Contact(AccountId=acc1.Id,Lastname='George');
        insert contact;
        acc1.Primary_Contact__c=contact.Id;
        update acc1;
        Campaign camp = new Campaign(Source__c = 'S', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');   
        insert(camp);             
        Opportunity opp = new Opportunity (name = 'Task() opp', AccountId = acc1.Id,CloseDate = Date.today().addyears(1),StageName = 'Active', CHI_Lead_Id2__c='56789087',Product_Interest__c='Central Heating Boiler',LeadSource='MARCOMMS',CampaignId=camp.Id);    
        insert(opp);
        
        Case caseone = new Case(Opportunity__c=opp.Id,Status='New',Priority='High',Issued_To_Group__c='Sales', AccountId=acc1.Id,RecordTypeId=recordtype.Id,Description='test description',
                                Subject='Test subject',Reason='Existing Problem', Primary_Cause__c='Price',ContactId=contact.Id,Classification__c='Sales',Case_Source__c='Customer');
        insert caseone;  
        ca.add(caseone);    
        
        //PInstal = [select id from Profile where name = 'CHI Standard Installer'];
        
        User managerUser = new User(Phase_4_Ready__c=true,profileid=PInstal.Id,LastName = 'updateUser1', Alias = 'update1',Email = 'user@update.com', Username='user_test1@update.com',EmailEncodingKey='UTF-8',Migration_ID__c = 'user@update.com',TimeZoneSidKey = 'Europe/London',LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        managerUser.Migration_ID__c = 'user_test1@update.com';
        insert managerUser;
        
        User user1 = new User(Phase_4_Ready__c=true,profileid=PInstal.Id,LastName = 'updateUser1', Alias = 'update1',Email = 'user@update.com', Username='user_test2@update.com',EmailEncodingKey='UTF-8',Migration_ID__c = 'user@update.com',TimeZoneSidKey = 'Europe/London',LocaleSidKey = 'en_GB', LanguageLocaleKey = 'en_US');
        user1.ManagerId = managerUser.ID;        
        managerUser.Migration_ID__c = 'user_test2@update.com';
        insert user1;
       
           
        Task t1 = new Task(WhatId=ca.get(0).id, Subject='Test subject', Status__c='In-Progress',  Status='In Progress', Priority='Low',OwnerId=user1.Id,Description='Test description', Communication_Status__c='Sent', Call_Notes__c='Test notes',ActivityDate =System.today()-5,Type__c = 'Customer Experience Case' );

        insert t1;
        List<Task> tasklist= new List<Task>();
        tasklist.add(t1);
        
             
        nto.soql+= ' AND CreatedDate >= '+finalDateTimeValue;
        nto.start(BC);
        nto.execute(BC, tasklist);
        nto.finish(BC);
        
    }
    
}