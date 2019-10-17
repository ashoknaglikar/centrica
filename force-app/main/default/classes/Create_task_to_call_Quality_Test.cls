/**
Type Name:Create_task_to_call_Quality_test
Author: Cognizant
Created Date: 24/06/2010
Reason: This is Test class for Create_task_to_call_Quality
Change History
 */
@isTest 
public class Create_task_to_call_Quality_Test {  

      
    public static testmethod void Create_task_to_callQuality(){ 
    
    //bUPD_task_test.bUPD_tasTest();
    
    Account account=new Account(Name='Test Account Check',Number_of_Bedrooms__c=1,BillingStreet='Test Street Check',BillingState='Test State',
                                    BillingPostalCode='211111',BillingCountry='Check Country',BillingCity='Test City');
     
    insert account;
    
    Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Test State',
                                     MailingPostalCode='441111',MailingCountry='Test Country', MailingCity='Test City',LastName='Last Name',
                                     FirstName='First name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
           
        
    insert contact;
    
    Supplier__c supplier = new supplier__c(Name='Check supplier',Type__c='Resource',Supplier_Num__c='D1234',Resource_Type__c='Resource');
    insert supplier;
    
    Profile PInstal = [select id from Profile where name = 'CHI Standard Installer'];
    User UInstal1 = new User(profileid=PInstal.Id,alias = 'standt', email='standarduser1@testorg.com',
                                emailencodingkey='UTF-8', lastname='Tsting', languagelocalekey='en_US',
                                localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='standardser1@testorg.com',Migration_ID__c ='A763BHe32345');
    insert UInstal1; 
    
    Employee__c emp = new Employee__c(Name = 'testCC1', First_Name__c = 'SCC1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '1002991',Salesforce_User__c = UInstal1.Id,Resource_Id__c='7ccjs2',Resource_Type__c='Installer');
                                         
    insert emp; 
    
    Opportunity opportunity = new Opportunity(Name = 'Test1 Opp', StageName ='Quote Finalised - Accepted',CloseDate=System.today(),isSystem__c=false,                                                
                                                  AccountId=account.Id, LeadSource='Engineer', Product_Interest__c = 'Solar', Referral_Employee__c =emp.id,Override_Billing_checks__c=false);
                                                 
    insert opportunity;
    
    String District = [Select Id, Name From District__c limit 1].id;                
    
    
    BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opportunity); 
    Job__c[] Job = TestScenarioCreateJob('Installed','Installed',opportunity.Id,District, quote[0].id );    
    
   
    Week__c week = new Week__c(Employee__c=emp.Id,Friday_Booked_Hours__c=5,Friday_Max_Hours__c=6,Friday_Unavailability_Reason__c='Being Investigated',Friday_Unavailable_Hours__c=1,Monday_Booked_Hours__c=10,
                                    Monday_Unavailable_Hours__c=0,Saturday_Booked_Hours__c=3,Saturday_Max_Hours__c=4,Saturday_Unavailable_Hours__c=0,
                                    Sunday_Booked_Hours__c=0,Sunday_Max_Hours__c=0,Sunday_Unavailable_Hours__c=0,
                                    Tuesday_Booked_Hours__c=3,Tuesday_Max_Hours__c=4,Tuesday_Unavailable_Hours__c=0,
                                    Thursday_Booked_Hours__c=3,Thursday_Max_Hours__c=4,Thursday_Unavailable_Hours__c=0,
                                    Wednesday_Booked_Hours__c=3,Wednesday_Max_Hours__c=4,Wednesday_Unavailable_Hours__c=0,Week_Commencing__c=Date.today()-5);
     insert week;
     Diary_Entry__c DEntry = new Diary_Entry__c(Employee__c=emp.Id,Week__c=week.Id,Sub_Type__c='Mechanical',Job__c=Job[0].Id,Start__c=DateTime.Now(),End__c=Datetime.now().addHours(5));
     insert DEntry;
    
    Payment_Collection__c p = new Payment_Collection__c();
    p.Name = 'Payment';
    p.Was_Job_completed_to_specification__c = 'Yes';
    p.Were_there_any_changes_to_the_Job__c = 'Yes (see notes)';
    p.Have_you_demod_the_system_controls__c = 'Yes';
    p.Payment_Collection_Status__c ='Pending'; 
    p.Has_NPS_been_explained_to_Customer__c = 'Yes';
    p.Have_you_arranged_a_call_back_time__c = 'Yes';
    p.Reason_for_Discrepancy__c='Dispute';
    p.Payment_Notes__c = 'test';
    p.Opportunity__c = opportunity .Id;
    p.Job__c=Job[0].Id;
    p.Job_Special_ID__c = Job[0].Id + 'P1';
    Insert P;

    
    //Update up;
    p.Reason_for_Discrepancy__c='Dispute';
    p.Payment_Collection_Status__c ='Complete';
    p.If_Yes_When__c = System.datetime.now();
    p.Reason_for_Discrepancy__c ='Dispute';
   
    p.Payment_Notes__c = 'test';
    Update p;
    
    Customer_history_card__c chc = new Customer_history_card__c(Job__c=Job[0].Id,Payment_Collection__c=p.Id);
    
    Database.insert(chc);
    /*
    List<Task> taskList = [Select Id,Status,Any_Issues_with_Installation__c,Date_of_post_call_check_completion__c,Post_installation_call_notes__c from Task where WhatId = :p.Id];
    
    System.debug('Task List '+taskList);
    
    for(Task task : taskList){
        
        task.Any_Issues_with_Installation__c = 'No';
        task.Date_of_post_call_check_completion__c = Date.Today();
        task.Post_installation_call_notes__c = 'Test';
        task.Is_post_installation_call_task__c = true;
        task.Status = 'Completed';
        
    }
    
      if(taskList.size()>0){
      
        Database.Update(taskList); 
        
      }*/
   
    }
    
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId, string District, Id bigMacihneQuoteId){
        
        Job__c job1 = new Job__c(District__c = District ,Quote__c=bigMacihneQuoteId, Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=0,Unvented_Hot_Water_Hours__c=0,Specialist_Building_Hours__c=0,Scaffolder_Hours__c=0,Roof_Work_Hours__c=0,Payment_Collection_Hours__c=0,Mechanical_Hours__c=0,LPG_Installation_Hours__c=0,Fire_Wall_Heater_Fixing_Hours__c=0,Electrical_Hours__c=0,Contractor_Installation_Hours__c=0,Connect_Solar_Panel_Hours__c=0,Building_Work_Hours__c=0,PowerFlush_Hours__c=0,Electrical_Work_ASP_Hours__c=0,Asbestos_Removal_Hours__c=0,Asbestos_Removal_Fixed_Rate_Hours__c=0,Solar_Hours__c=0);              
        Job__c[] joblist = new Job__c[]{job1};          
        system.debug('joblist contains :'+joblist);
        insert joblist;        
        return joblist;
    }
    public static BigMachines_Quote__c[] TestScenarioCreateQuote(Opportunity opty){
    
    BigMachines_Quote__c quote;
    quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Commissionable_Sales_Value__c = 300.00, Non_Commission_Sales_Value__c = 100.00 ,Transferred_to_Premier__c = null, Line_Items_Decompiled__c = true, Is_Primary__c = true, Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2,POC_Payment_Method__c = 'Cash');                   
    BigMachines_Quote__c[] quotelist = new BigMachines_Quote__c[]{quote};
    insert quotelist;        
    return quotelist;
    }
    }