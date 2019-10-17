/**Type Name: aUPD_Case_SendSecondNPSEmail_Test
Author: CognizantCreated 
Date: 11/05/2010
Reason: To update Second_NPS_Email_Sent__c field of the NPS and trigger a workflow to send secondary NPS survey email.
Change History:*/
@isTest
Private class aUPD_Case_SendSecondNPSEmail_Test
{
//variable declaration section.
    /*static Account account;  
    static Contact contact;
    static Employee__c emp ;
    static Opportunity opportunity ;
    static NPS__c NpsRec,NpsRec1;
    static Case case_obj;*/
    
    
   
static testMethod void SecondNpsEmailTestMethod()
        { 
        // Insert mandatory fields in the Account       
        Account account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                             BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
        insert account;
                       
        // Insert mandatory fields in the Contact  
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                            MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                            FirstName='First name',Preferred_Contact_Method__c='Letter',Email='test@gmail.com',Email__c='test@gmail.com',
                            AccountId=account.Id);     
        insert contact;
        
        //UPDATING ACCOUNT WITH PRIMARY CONTACT.
        account.Primary_Contact__c = contact.Id;
        update account;
        
        // Insert mandatory fields in the Employee custom object                
        Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                              Employee_Number__c = '0002991');
        insert emp;
        
        //Retrive details of employee to insert new opportunity  
        emp = [select id from Employee__c where id=:emp.Id];
          
        // Insert mandatory fields in the Opportuinty(CHI_lead).  
        Opportunity opportunity = new Opportunity(Name = 'TestOpporunity' + System.now().format('mmddyyhh'), StageName ='Active',CloseDate=System.today(), 
                                      AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                  
        insert opportunity;
              
                 
        opportunity = [select id, CHI_Lead_Id__c,Name from Opportunity where id = :opportunity.Id ];
                      
        NPS__c NpsRec = new NPS__c(Account__c = account.Id,CHI_Lead_Name__c=opportunity.Name,
                            opportunity__c=opportunity.Id,Step1_Score__c=2,Step1_Comments__c='uilg', source__c = 'Sales Appointment');
        insert NpsRec;
         
        //FETCHING EXIXTING DETRACTOR CASE RECORD TYPE ID.
        ID DetractorRecordTypeId = [select Id from RecordType where Name = 'Detractor' 
                                    and SobjectType = 'Case'].Id; 
                                    
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
            newCase.ContactId = npsRec.Account__r.Primary_Contact__c;
            newCase.NPS_Score__c = npsRec.Step1_Score__c;
            newCase.NPS_Response__c = npsRec.Step1_Comments__c;         
            newCase.NPS__c = npsRec.Id;         
            newCase.RecordTypeId = DetractorRecordTypeId;
            newCase.NPS_Contact_Email__c = npsRec.Contact_Email__c;
            newCase.ContactId = contact.Id; 
        insert newCase;
                            
        //case_obj = [select id, Status, Reason, Send_Secondary_Card__c from Case where NPS__c =:NpsRec.Id];
        newCase.Status='Resolved';
        newCase.Reason='Existing problem';
        newCase.Send_Secondary_Card__c=true;
        update newCase;
        
        
        NpsRec=[Select id,Second_NPS_Email_Sent__c,DontUpdateNpsManually__c,Preferred_Contact_Method__c from NPS__c where id =:NpsRec.id];
               
      
        }

static testMethod void SecondNpsPostTestMethod()
    { 
        try
        {
            
            Account account= new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',
                                 BillingPostalCode='441111',BillingCountry='Test Country',BillingCity='Test City');
            insert account;
            // Insert mandatory fields in the Account  
            
                 
            
            Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name',
                                FirstName='First name',Preferred_Contact_Method__c='Email',Email='test@gmail.com',Email__c='test@gmail.com',
                                AccountId=account.Id);     
            insert contact;
            // Insert mandatory fields in the Contact  
            
            //UPDATING ACCOUNT WITH PRIMARY CONTACT.
            account.Primary_Contact__c = contact.Id;
            update account;    
                   
            Employee__c emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                                  Employee_Number__c = '0002991');
            insert emp;
            // Insert mandatory fields in the Employee custom object 
            
             emp = [select id from Employee__c where id=:emp.Id];
            //Retrive details of employee to insert new opportunity    
            
            Opportunity opportunity = new Opportunity(Name = 'TestOpporunity1' + System.now().format('mmddyyhh'), StageName ='Active',CloseDate=System.today(), 
                                          AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,
                                          Amount_Settled__c=100,Amount=150,discountsTotalOnPricing__c=50,Status__c='Active');                                  
            insert opportunity;
            
            // Insert mandatory fields in the Opportuinty(CHI_lead).        
                
            
            NPS__c NpsRec = new NPS__c(Account__c = account.Id,CHI_Lead_Name__c=opportunity.Name,opportunity__c=opportunity.Id,
                                Step1_Score__c=2,Step1_Comments__c='uilg');
            insert NpsRec;
            
            //FETCHING EXIXTING DETRACTOR CASE RECORD TYPE ID.
            ID DetractorRecordTypeId = [select Id from RecordType where Name = 'Detractor' 
                                        and SobjectType = 'Case'].Id; 
                                        
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
                newCase.ContactId = npsRec.Account__r.Primary_Contact__c;
                newCase.NPS_Score__c = npsRec.Step1_Score__c;
                newCase.NPS_Response__c = npsRec.Step1_Comments__c;         
                newCase.NPS__c = npsRec.Id;         
                newCase.RecordTypeId = DetractorRecordTypeId;
                newCase.NPS_Contact_Email__c = npsRec.Contact_Email__c;
                
                newCase.ContactId = contact.Id; 
            insert newCase;     
            
            newCase = [select id, Status, Reason, Send_Secondary_Card__c from Case where NPS__c =:NpsRec.Id limit 1];
            //newCase.IsClosed = true;
            newCase.Status='Resolved';
            newCase.Reason='Existing problem';
            newCase.Send_Secondary_Card__c=true;
            update newCase;   
        }catch(Exception e){
            System.debug('Exception occured in SecondNpsPostTestMethod(): '+e);
        }   
      } 

}