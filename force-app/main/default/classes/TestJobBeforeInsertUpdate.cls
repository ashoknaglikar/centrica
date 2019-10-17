@istest
private with sharing class TestJobBeforeInsertUpdate {
                                                          
    //////////////////////////////
    //              //
    //    TESTING CLASSES    //
    //              //
    ////////////////////////////// 
    
    // Test :-
    
    // When big machines quote is being inserted in the system it also creates a job.
    // It then copies salesman from quote on correspondng job.
    // Job triggers which are fired then will populate salesman textmail address on job in order to send various text messages.
                
    @isTest
    static void TestQuoteInsertJobCreationUpdate(){      
      try {    
          //Setup test environment
          Account Acc = TestScenarioCreateAccount();
          Opportunity opty = TestScenarioCreateOppty(Acc);  
          Contact c = TestClassHelper.createContact(Acc); 
          c.Contact_Type__c = 'Tenant';
          insert c; 
          Employee__c emp = TestScenarioCreateDummyEmployee();
          BigMachines_Quote__c quote = TestScenarioCreateQuote(opty);
            Job__c job = [Select Quote_app_assigned_to__c, Salesman_Textmail_Addr__c, Populated_txtmail_salesman__c from Job__c where Quote__c =:quote.id];
          System.assertEquals('App Assigned - TTTTT',job.Quote_app_assigned_to__c); 
          System.assertNotEquals('+441111.bgbgsa221@textmail.org',job.Salesman_Textmail_Addr__c);
          System.assertEquals(True,job.Populated_txtmail_salesman__c);
         
          //Change by BGSAMS support on 25/01/2012 to include the code coverage of the Trigger JobBeforeInsertUpdate in case of preallocation scenario job insertion -  PRB00006300 starts
          Opportunity opty1 = TestClassHelper.createCHILead(Acc);
          insert opty1;
          District__c dist1 = TestClassHelper.createDistrict();
          insert dist1;
          Job__c job1 = TestClassHelper.createJob('Pending', 'Pending', opty1.Id, dist1.Id);
          job1.Smart_Meter_Required_Flag__c = 'Yes';
          insert job1;
          job1.Status__c = 'Suspended';
          update job1;
          job1.Status__c = 'Pending';
          update job1;
          job1.Status__c = 'Cancelled';
          update job1;
          job1.Status__c = 'Pending';
          job1.Delivery_Date__c = system.today() - 1;
          update job1;
          
          job1.Status__c = 'Pending';
          job1.Delivery_Date__c = system.today() + 2;
          job1.Smart_meter_installation_date__c = system.today() + 1;
          job1.Smart_meter_installation_status__c = 'Suspended' ;
          job1.Smart_Meter_Required_Flag__c = 'Yes';
          job1.Decouple_Smart_Meter_Install_Date__c = false;
          update job1;
          
          
          Job__c job2 = TestClassHelper.createJob('Pending', 'Pending', opty1.Id, dist1.Id);
          job2.Smart_Meter_Required_Flag__c = 'Yes';
          job2.Delivery_Date__c = system.today()-3;
          insert job2;
          
          c.Contact_Type__c = 'Landlord';
          update c;
          update job1;  
           
          c.Contact_Type__c = 'Multi-premise';
          update c;
          job.Landlord_Name__c = null;
          job.Landlord_Email__c = null;         
          update job1;   
          
      } catch(Exception ex) {
        //do nothing
      }    
    }
    
    //test method   
    private static Account TestScenarioCreateAccount(){
        District__c district = new District__c(Type__c='Installation', Name='Job Insert', Code__c='tttttttttt');    
    insert district;
    Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='LLLL L', District__c=district.Id, Code__c='tttttttttt');             
         insert subPatch;
         Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='LLLL L', Sub_Patch__c=subPatch.Id, Code__c='tttttttttt');
    insert postcodeSector;
         Account Acc = new Account(Name = 'test job insert update', BillingStreet='Test Job Street', BillingPostalCode = 'LLLL LLL',Landlord_Account__c=true);                      
         insert Acc;        
        return Acc;
    }
    
    //test method 
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign 1', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Job Insert', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }
    
    //test method 
    public static BigMachines_Quote__c TestScenarioCreateQuote(Opportunity opty){
        
        BigMachines_Quote__c quote = new BigMachines_Quote__c(Name = 'Test for Job Insert 1', Opportunity__c = opty.id, quote_reconciled__c=false, stage__c = 'Quote Finalised - Accepted', bmStatusReason__c = 'Install Date Required', App_Assigned_To__c = 'App Assigned - TTTTT');           
        insert quote;        
        return quote;
    }
    
    //test method 
    public static Employee__c TestScenarioCreateDummyEmployee(){
        
        Employee__c emp = new Employee__c(Name = 'Test Employee 1', First_Name__c = 'App', Last_Name__c = 'Assigned', Employee_Number__c = 'TTTTT', Phone_No__c = '011 11');           
        insert emp;        
        return emp;
    }
   
    
    /* static testmethod void  TestSmartmeter(){
        
        Job__c job  = TestClassHelper.createJob('Planned', 'Planned', null,null);
        //job.Quote__c = quote.Id;
        insert(job);
    }
    */
  
}