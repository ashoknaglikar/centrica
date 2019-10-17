@isTest
Private class PerformOpportunityReconcilliation_test
{	
	static Account account;  
    static Contact contact;
    static Employee__c emp ;
    static Opportunity opportunity ;
   static testMethod void PerformOppReconcilTestMethod()
    { 
    String context= '0 0 0 * * ? *';
    SchedulableContext sc;
    System.schedule('testScheduledApex',context, new ReconcileOpportunity());
    ReconcileOpportunity RO = new ReconcileOpportunity();
    
    Test.startTest();
    
    RO.execute(sc);
    String s1='123';
     Map<String,Outstanding_Deposit__c> bgsRefMap = new Map<String,Outstanding_Deposit__c>();
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
	
	 emp = [select id from Employee__c where id=:emp.Id];
	//Retrive details of employee to insert new opportunity    
	
	opportunity = new Opportunity(Name = 'TestOpporunity', StageName ='Active',CloseDate=System.today(), 
	                              AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id
	                              ,isSystem__c=true,Settled_Date_NBU1__c=System.today(),Amount_Settled__c=123,Payment_Reference_Number__c='812');                                  
	insert opportunity;	

    List<Opportunity> opplst = new List<Opportunity>();
    opplst.add(opportunity);
       
	NBSF7522_Batch__c NBSFbatch = new NBSF7522_Batch__c(Type__c ='SFDC to NBBS',Record_Count__c =8,Run_Number__c = '2134',Batch_Status__c='S');
  	insert NBSFbatch;
   	Outstanding_Deposit__c outstndDepst =new Outstanding_Deposit__c(Transcash_Invoice_Number__c='12', Processed__c=true, Payment_Type__c=1,Indicator_Code__c='1',Deposit_Date__c=System.today(),Amount__c=123,Batch__c=NBSFbatch.Id );
   	insert outstndDepst;
   	List<Outstanding_Deposit__c> slist = new List<Outstanding_Deposit__c>();
   	slist.add(outstndDepst);
   	bgsRefMap.put(s1,outstndDepst);
   	
    PerformOpportunityReconcilliation PORecon = new PerformOpportunityReconcilliation();
    
    Database.BatchableContext BC;
    
   	
   	
    PORecon.execute(BC,slist);
    //PORecon.finish(BC);
    
   	Test.stopTest();
	
 }
 }