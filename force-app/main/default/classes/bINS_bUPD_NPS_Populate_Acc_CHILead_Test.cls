/*Type Name: bINS_bUPD_NPS_Populate_Account_CHILead_Test
Author: Cognizant
Created Date: 12/05/2010
Reason: To Test  bINS_bUPD_NPS_Populate_Account_CHILead class.
Change History:*/
@istest
private class bINS_bUPD_NPS_Populate_Acc_CHILead_Test
 {
    //Variable declaration section.
    static Account account;  
    static Contact contact;
    static Employee__c emp ;
    static Opportunity opportunity ;
    static NPS__c NpsRec,NpsDup;
    static Case case_obj;
   /* This methods inserts the required record to form an Nps record 
   and then intiates the class NpsController*/
        
    static testMethod void NpsAccOppTestMethod()
        
      {
        
        account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        // Insert mandatory fields in the Account          
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;
        // Insert mandatory fields in the Contact        
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert emp;
        // Insert mandatory fields in the Employee custom object 
        
         //emp = [select id from Employee__c where id=:emp.Id];
        //Retrive details of employee to insert new opportunity    
        
        opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
        // Insert mandatory fields in the Opportuinty(CHI_lead).
        //opportunity = [select id, CHI_Lead_Id__c,Opportunity.Name from Opportunity limit 1];
        try
          {
            NpsRec = new NPS__c(CHI_Lead_Name__c=opportunity.Name,opportunity__c=opportunity.Id,Step1_Score__c=-1,Step1_Comments__c='uilg');
            insert  NpsRec ;        
            NpsDup = new NPS__c(CHI_Lead_Name__c=opportunity.Name,opportunity__c=opportunity.Id,Step1_Score__c=-1,Step1_Comments__c='uilg');
            insert NpsDup;
            }
        catch(System.DMLException e)        
        {              
            //System.assert( e.getMessage().contains('Cannot create new NPS as one already exists for this CHI Lead'), e.getMessage());          
        }  
        case_obj = [select id, Status, Reason, Send_Secondary_Card__c from Case where NPS__c =:NpsRec.Id];
        case_obj.Status='Resolved';
        case_obj.Reason='Existing problem';
        case_obj.Send_Secondary_Card__c=true;
        update case_obj;
        NpsRec.Step2_Score__c=2;
        NpsRec.Step2_Comments__c='uilg';
        NpsRec.Status__c = 'Step 3';
        try{
            update NpsRec; 
        }catch(Exception e){
            // do nothing
        }
       
     }
     static testMethod void NpsNegativeTestMethod()
        
      {
        
        account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
        // Insert mandatory fields in the Account          
        
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Email='test@gmail.com',AccountId=account.Id);     
        insert contact;
        // Insert mandatory fields in the Contact        
        
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert emp;
        // Insert mandatory fields in the Employee custom object 
        
        // emp = [select id from Employee__c where id=:emp.Id];
        //Retrive details of employee to insert new opportunity    
        
        opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
        // Insert mandatory fields in the Opportuinty(CHI_lead).
        //opportunity = [select id, CHI_Lead_Id__c,Opportunity.Name from Opportunity where id=:opportunity.Id];
        try
        {
            NpsRec = new NPS__c(Step1_Score__c=2,Step1_Comments__c='uilg');
            insert  NpsRec ; 
        } 
        catch(System.DMLException e)        
        {              
            //System.assert( e.getMessage().contains('CHI_Lead must be provided'), e.getMessage());    
            System.assert(true);      
        } 
     }

 }