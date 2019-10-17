@isTest
private class ContactEditViewComponentController_Test{

    static testmethod void contactControllerTestMethod(){
    //c.Account.BillingCountry, c.Account.BillingPostalCode, c.Account.BillingState, c.Account.BillingCity,c.Account.BillingStreet,c.Title, c.SystemModstamp, c.Suppress_Mail_Date__c, c.Suppress_Call_Date__c, c.Stop_Reason__c, c.Stop_Reason_Date__c, c.Siebel_Created_Date__c, c.Salutation, c.ReportsToId, c.Primary_Contact__c, c.Premier_Mobile_Phone__c, c.Prem_Work__c, c.Prem_Mobile__c, c.Prem_Home__c, c.Preferred_Phone_Type__c, c.Preferred_Contact_Method__c, c.Phone, c.OwnerId, c.OtherStreet, c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherCountry, c.OtherCity, c.Name, c.MobilePhone, c.Middle_Name__c, c.MasterRecordId, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.LeadSource, c.LastName, c.LastModifiedDate, c.LastModifiedById, c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, c.IsDeleted, c.Id, c.HomePhone, c.Gender__c, c.FirstName, c.Fax, c.Email__c, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Description, c.Department, c.CreatedDate, c.CreatedById, c.Contact_Num__c, c.Contact_Num_2__c, c.Contact_Num_1__c, c.Circumstance__c, c.Birthdate, c.Best_Time_to_Contact__c, c.Best_Phone__c, c.AssistantPhone, c.AssistantName, c.Alternative_Form_of_Literature__c, c.AccountId
        Account m_account;
        Account account=new Account();
        account.Name='Test Account';
        account.Number_of_Bedrooms__c=1;
        account.Gas_Supply_At_Address__c=true;
        account.Current_Heating_System__c=true;
        account.BillingStreet='Test Street';
        account.BillingState='Test State';
        account.BillingPostalCode='441111';
        account.BillingCountry='Test Country';
        account.BillingCity='Test City';
        account.Water_Hardness__c=0;
        
        insert account;

        List<Contact> conList = new List<Contact>();
        List<Contact> contactList = new List<Contact>();
        Contact contact=new Contact();
            contact.Primary_Contact__c=true;
            contact.Phone='9022332343';                    
            contact.MailingStreet='test Street';
            contact.MailingState='Test State';
            contact.MailingPostalCode='4411189';
            contact.MailingCountry='Test country';
            contact.MailingCity='Test City';
            contact.LastName='Last Name';
            contact.FirstName='First name';
            contact.Email='test@gmail.com';
            contact.AccountId=account.Id;
            
            insert contact;
            contactList.add(contact);
            
            ContactEditViewComponentController controller= new ContactEditViewComponentController();
            controller.setConList(contactList);
            controller.getConList();
            // Cognizant Support - Modified This Test Class To Deploy Inner Class Fix For Summer 10 Release For ContactEditViewComponentController
            List<ContactInfo> coninfoList_Temp = new List<ContactInfo>();
            ContactInfo contactInfo= new ContactInfo();
            contactInfo.contact=contact;
            contactInfo.AddSlct=true;
            contactInfo.ConSlct=true;
            contactInfo.AddStrt='Test';
            contactInfo.AddCty='Test';
            contactInfo.AddStat='Test';
            contactInfo.AddCntr='Test';
            contactInfo.AddZip='Test';
            
            Boolean b1=contactInfo.AddSlct;
            Boolean b2=contactInfo.ConSlct;
            String s1=contactInfo.AddStrt;
            String s2=contactInfo.AddCty;
            String s3=contactInfo.AddStat;
            String s4=contactInfo.AddCntr;
            String s5=contactInfo.AddZip;
            
            coninfoList_Temp.add(contactInfo);
            
            controller.setConInfoList(coninfoList_Temp);
            
            controller.getConInfoList();
    }

}