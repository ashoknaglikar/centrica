@isTest
private class populateOtherInstaller_test {
    static testMethod void testInstaller() {

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
        
        account.Primary_Contact__c=contact.Id;
        update account;
        
        User u2 = [select Phase_4_Ready__c,id from User where Phase_4_Ready__c=: true limit 1];
        
        Supplier__c sup = new Supplier__c(Name = 'TestSupp', Supplier_Num__c = 'X12345',Type__c = 'Product');
        insert sup;
        
        Employee__c emp = new Employee__c();
        emp.Name = 'SBB1Test1';
        emp.First_Name__c = 'SBB1';
        emp.Last_Name__c = 'Test1';
        emp.Employee_Number__c = '943144';
        emp.Resource_Type__c='Installer';
        emp.Salesforce_User__c = u2.Id;
        emp.Inactive__c = false;
        emp.Supplier__c  = sup.id;
        insert emp;
         
        Campaign campaign=[select Id from campaign limit 1];
        List<Opportunity> opportunityList=new List<Opportunity>();
        
        Opportunity opp= new Opportunity();
        Opportunity opportunity = new Opportunity();
      
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms';
        opportunity.Product_Interest__c='Solar';
        opportunity.Lead_Comments__c = 'Lead Comments';
        opportunity.Referral_Employee__c = emp.Id;
      
        insert opportunity;        
        
        
        Job__c job = new Job__c(CHI_Lead__c = opportunity.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=1, PowerFlush_Hours__c = 1, Building_Work_Hours__c = 1,
                                Connect_Solar_Panel_Hours__c = 1, Contractor_Installation_Hours__c = 1,
                                Electrical_Hours__c = 1, Fire_Wall_Heater_Fixing_Hours__c = 1, LPG_Installation_Hours__c = 1,
                                Payment_Collection_Hours__c = 1, Roof_Work_Hours__c = 1,
                                Specialist_Building_Hours__c = 1, Unvented_Hot_Water_Hours__c = 1, Water_Heating_Fixing_Hours__c =1, 
                                Customer_Preferred_Date__c = Date.today(), Installation_Date__c = Date.today(),
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = true);
        insert job;

        job.Status__c = 'Planned';

        update job;
        
                
        Week__c week = new Week__c(Employee__c = emp.Id);
        
        insert week;

        Diary_Entry__c diary = new Diary_Entry__c (Job__c = job.id, Start__c = System.now() ,End__c = System.now() ,Type__c = 'Installation',Sub_Type__c = 'Asbestos Removal',Week__c = week.Id,Employee__c = emp.Id);
          
        insert diary;
        
        List<Installer__c> instList = new List<Installer__c>();
        
        Installer__c ins1 = new Installer__c(name='Mechanical',Diary_Entry__c = diary.Id,Job__c = job.Id,User__c = u2.Id,Installer_Status__c='Active');
        
        Installer__c ins2 = new Installer__c(name='Electrical',Diary_Entry__c = diary.Id,Job__c = job.Id,User__c = u2.Id,Installer_Status__c='Active');
        
        Installer__c ins3 = new Installer__c(name='Specialist Building',Diary_Entry__c = diary.Id,Job__c = job.Id,User__c = u2.Id,Installer_Status__c='Active');
        
        instList.add(ins1);
        
        instList.add(ins2);
        
        instList.add(ins3);
        
        insert instList;
          
      }
}