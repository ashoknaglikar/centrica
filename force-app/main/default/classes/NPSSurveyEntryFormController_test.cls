@istest
private class NPSSurveyEntryFormController_test
{
    static Account account;
    static Contact contact;
    static Employee__c emp;
    static Opportunity opportunity;
     static Opportunity opportunity1;
     static NPS__c nps;
    
    static testmethod void NpssurveyTestMethod()
    {
        account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',                      BillingPostalCode='441111',BillingCountry='United Kingdom',BillingCity='Test City');
  
        try
        {        
            insert account;  
            update account;        
        } 
        catch(System.DMLException e)
        {    
            System.assert( e.getMessage().contains('Account created '),   
            e.getMessage());    
        }  
         Account  account1=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Test Street',BillingState='Test State',                      BillingPostalCode='441111',BillingCountry='United Kingdom',BillingCity='Test City');   
        contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State', MailingPostalCode='4411189',MailingCountry='Test country', MailingCity='Test City',LastName='Last Name', FirstName='First name',Email='test@gmail.com',AccountId=account.Id);                  
     
        try{     
           insert contact; 
           update contact;         
        } 
        catch(System.DMLException e)
        {  
            System.assert( e.getMessage().contains('Contact created '), e.getMessage());  
        }  
          
        emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',
                                         Employee_Number__c = '0002991');
                                         
        insert emp;
        
        
        opportunity = new Opportunity(Name = 'Test Opp' + System.now().format('mmddyyyy'), StageName ='Active',CloseDate=System.today(), 
                                                 AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                                   
        insert opportunity;
                 
         opportunity = [select id from Opportunity where id=:opportunity.Id];
         //opportunity = [select id, CHI_Lead_Id__c from Opportunity where id=:opportunity.Id];
        
        //end of just checking
        PageReference pageRef2 = new PageReference('/apex/NPSSurveyEntryForm?s=' + opportunity.Id);      
        Test.setCurrentPage(pageRef2);                    
        NPSSurveyEntryFormController npsPageController2 = new NPSSurveyEntryFormController();
        
     
     }
     
     private static testMethod void NpssurveyTestMethodPositiveValidStepCount()
     {
         NpssurveyTestMethod();
         opportunity1 = new Opportunity(Name = 'Test Opp' + System.now().format('mmddyyyy'), StageName ='Active',CloseDate=System.today(), 
                                                 AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id);                                                   
        insert opportunity1;
        /* nps=new NPS__c(Step1_Score__c=1,Status__c = 'Step 1',Account__c=account.id,Opportunity__c=opportunity1.id);
        insert nps;*/
     	//nps=[select Step1_Score__c,Status__c,Account__c from NPS__c limit 1];
        PageReference pageRef = new PageReference('/apex/NPSSurveyEntryForm?h=1&s='+ opportunity1.Id);      
        Test.setCurrentPage(pageRef);                    
        NPSSurveyEntryFormController npsPageController = new NPSSurveyEntryFormController();
        
        npsPageController.Hit = '1';
        npsPageController.DisplayNPSExistsError = true;
        npsPageController.IsLoadError = true;
     
                          
        //System.debug('------- newnps = ' + newnps);
        npsPageController.PostSurvey();
        
        //nps = npsPageController.Entry;
        nps = [select Step1_Score__c from NPS__c where Opportunity__c = :opportunity1.ID];
        //nps = [select Step1_Score__c,Status__c,Account__c from NPS__c where Opportunity__c = :opportunity1.ID];
        PageReference pageRef1 = new PageReference('/apex/NPSSurveyEntryForm?h=2&s=' + nps.Id);
        Test.setCurrentPage(pageRef1);                    
        NPSSurveyEntryFormController npsPageController1 = new NPSSurveyEntryFormController();
        
        npsPageController1.Hit = '1';
        npsPageController1.DisplayNPSExistsError = true;
        npsPageController1.IsLoadError = true;
     
                          
        //System.debug('------- newnps = ' + newnps);
                
            npsPageController1.PostSurvey();
        
   }
        
     //retrieve the CHI Lead/NPS id passed to page
     private static testMethod void NpssurveyTestMethodNoStepCount()
     {
        NpssurveyTestMethod();
       	PageReference pageRef = new PageReference('/apex/NPSSurveyEntryForm?s=' + opportunity.Id);      
        Test.setCurrentPage(pageRef);                    
        NPSSurveyEntryFormController npsPageController = new NPSSurveyEntryFormController();
        npsPageController.Hit = '0';
       
        //System.debug('------- newnps = ' + newnps);
        try
        {        
            npsPageController.PostSurvey();
        } 
        catch(System.DMLException e)
        {  
            System.assert( e.getMessage().contains('NoStepCount'),  e.getMessage());
        }
     }
     //retrieve the CHI lead and Negative step count passed to page
     private static testMethod void NpssurveyTestMethodNegativeStepCount()
     {
        NpssurveyTestMethod();
        PageReference pageRef = new PageReference('/apex/NPSSurveyEntryForm?h=-1&s=' + opportunity.Id);      
        Test.setCurrentPage(pageRef);                    
        NPSSurveyEntryFormController npsPageController = new NPSSurveyEntryFormController();
        npsPageController.Hit = '-1';
                       
        //System.debug('------- newnps = ' + newnps);
        try
        {        
            npsPageController.PostSurvey();
        } 
        catch(System.DMLException e)
        {  
            System.assert( e.getMessage().contains('NegativeStepCount with Opportunity ID'),e.getMessage());
        }
     }
     //retrieve the CHI lead and Invalid Possitive step count passed to page
     private static testMethod void NpssurveyTestMethodPositiveInvalidStepCount()
     {
         NpssurveyTestMethod();
        PageReference pageRef = new PageReference('/apex/NPSSurveyEntryForm?h=4&s='+ opportunity.Id);      
        Test.setCurrentPage(pageRef);                    
        NPSSurveyEntryFormController npsPageController = new NPSSurveyEntryFormController();
        
        npsPageController.Hit = '2';
                              
                          
        //System.debug('------- newnps = ' + newnps);
        try
        {        
            npsPageController.PostSurvey();
        } 
        catch(System.DMLException e)
        {  
            System.assert( e.getMessage().contains('PositiveInvalidStepCount'),  e.getMessage());
        }
     }
     //retrieve the CHI lead and valid Possitive step count passed to page
     
        //retrieve the CHI lead and valid Possitive step count2 passed to page
      private static testMethod void NpssurveyTestMethodPositiveValidStepCount2()
     {
     	
     	//Step 2
     	NpssurveyTestMethod();
     	//opportunity1 = [select id, CHI_Lead_Id__c from Opportunity where id=:opportunity1.Id];
     	//insert opportunity1;
       	//nps=new NPS__c(Step1_Score__c=1,Account__c=account.id,Opportunity__c=opportunity1.id);
     	//insert nps;  
        PageReference pageRef = new PageReference('/apex/NPSSurveyEntryForm?h=2&s=' + opportunity.Id);      
        Test.setCurrentPage(pageRef);                    
        NPSSurveyEntryFormController npsPageController = new NPSSurveyEntryFormController();
        npsPageController.SurveyPosted=true;
        npsPageController.Hit = '2';
        npsPageController.ContactSalutation='Salutiontest';
        npsPageController.ContactFirstName='First Name';
        npsPageController.ContactLastName='Last Name'; 
         
        //System.debug('------- newnps = ' + newnps);
            npsPageController.PostSurvey();
  
     
     }
    
            //retrieve the CHI lead and valid Possitive step count3 passed to page
      private static testMethod void NpssurveyTestMethodPositiveValidStepCount3()
     {
     	
     	
     	NpssurveyTestMethod();
          
        PageReference pageRef = new PageReference('/apex/NPSSurveyEntryForm?h=3&s=' + opportunity.Id);      
        Test.setCurrentPage(pageRef);                    
        NPSSurveyEntryFormController npsPageController = new NPSSurveyEntryFormController();
 
        npsPageController.Hit = '3';
             
        //System.debug('------- newnps = ' + newnps);
            npsPageController.PostSurvey();
      
     
     }
 
     
 	private static testMethod void NpssurveyTestContact()
    {
         NpssurveyTestMethod();
              
              
        NPSSurveyEntryFormController npsPageController = new NPSSurveyEntryFormController();
        
        contact.firstName = 'test';
        contact.salutation= 'saltest';
        contact.LastName= 'last';     
        update contact;          
        //System.debug('------- newnps = ' + newnps);
        try
        {        
            npsPageController.getPrimaryContactDetails();
        } 
        catch(System.DMLException e)
        {  
            System.assert( e.getMessage().contains('TestContact'),  e.getMessage());
        }
    }
    
    
          
     
     
 
     
}