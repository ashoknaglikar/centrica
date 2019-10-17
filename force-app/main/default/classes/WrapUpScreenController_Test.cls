/*
Test class for WrapUpScreenController.
Created date: 28/10/09.
*/
@isTest
private class WrapUpScreenController_Test{
    
    static Account account;
    static Contact contact;
    static Opportunity opportunity;
    static Campaign campaign;
    static Inbound_Call__c callObj;
    static List<Opportunity> opportunityList;
    
    static void createData()
    {
        account=new Account();
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
        
        contact=new Contact();
            contact.Primary_Contact__c=true;
            contact.LastName='Last Name';
            contact.FirstName='First name';
            contact.Email='test@gmail.com';
            contact.AccountId=account.Id;
            
            insert contact;
        
        campaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert campaign;
        
        
        opportunity = new Opportunity();
      
        opportunity.name='Test Opp';
        opportunity.StageName='Active';
        opportunity.CloseDate=System.today();
        opportunity.CampaignId=campaign.Id;
        opportunity.AccountId=account.Id;
        opportunity.LeadSource='Marcomms'; 
        opportunity.Product_Interest__c='Solar';
        opportunity.Lead_Comments__c='test lead comments';
        opportunity.Unappointed_Lead_Reason__c = 'hh';
        insert opportunity;
        
        opportunityList=new List<Opportunity>();
        opportunityList.add(opportunity);
        
        callObj = new Inbound_Call__c();
        callObj.CHI_Lead__c = opportunity.Id;
        callObj.Workflow_Step__c = 1;
        insert callObj;
        
    }
    static testmethod void wrapUpScreenMethod()
    {
        createData();
        ApexPages.currentPage().getParameters().put('c',callObj.Id);
        WrapUpScreenController controller1=new WrapUpScreenController();
        
        controller1.leadCommentsAppend='test comments append';
        controller1.oppList=opportunityList;
        controller1.closeCall();
        //controller1.oppList=opportunityList;
        controller1.leadTaNotesAppend=null;
        controller1.opportunity = opportunity;
        controller1.opportunity.Unappointed_Lead_Reason__c= '';
        //controller1.closeCall();
        //WrapUpScreenController controller = new WrapUpScreenController(); 
        controller1.getAccountInfo();
        //controller1.opportunity = opportunity;
        controller1.getConList();
        controller1.getOpportunities();
        controller1.getAppointments();
        controller1.closeCall();
        controller1.createTask();     
        controller1.methodForTest();
    }
    static testmethod void wrapUpScreenMethod1()
    {
        createData();
        opportunity.Lead_Comments__c = null;
        opportunity.ta_notes__c  = 'testTANotes';
        opportunity.Opt_Out__c = false;
        opportunity.Unappointed_Lead_Reason__c = 'Prospect';
        opportunity.Reason_Code__c = null;
        opportunity.Override_Call_Back_Date__c = date.ValueOf('2013-09-21');        
        opportunity.Call_Back_Date__c = 'Over Ride Call Back Date';
        opportunity.Do_Not_Call_Back__c = false;
        update opportunity;
        ApexPages.currentPage().getParameters().put('c',callObj.Id);
        WrapUpScreenController controller1=new WrapUpScreenController();
        controller1.closeCall();
        
    }
    
    static testmethod void wrapUpScreenMethod2()
    {
        createData();
        opportunity.Opt_Out__c = false;
        opportunity.Unappointed_Lead_Reason__c = 'Prospect';
        opportunity.Reason_Code__c = null;
        opportunity.Call_Back_Date__c = null;
        opportunity.Do_Not_Call_Back__c = false;
        update opportunity;
        ApexPages.currentPage().getParameters().put('c',callObj.Id);
        WrapUpScreenController controller1=new WrapUpScreenController();
        controller1.closeCall();
        
    }
   
   static testmethod void wrapUpScreenMethod3()
    {
        createData();
        opportunity.Opt_Out__c = false;
        opportunity.Unappointed_Lead_Reason__c = 'Prospect';
        opportunity.Reason_Code__c = 'test';
        opportunity.Call_Back_Date__c = null;
        opportunity.Do_Not_Call_Back__c = false;
        update opportunity;
        ApexPages.currentPage().getParameters().put('c',callObj.Id);
        WrapUpScreenController controller1=new WrapUpScreenController();
        controller1.closeCall();
        
    }
    
    static testmethod void wrapUpScreenMethod4()
    {
        createData();
        opportunity.Opt_Out__c = false;
        opportunity.Unappointed_Lead_Reason__c = 'Prospect';
        opportunity.Do_Not_Call_Back__c = false;
        opportunity.Reason_Code__c = 'test';
        opportunity.Call_Back_Date__c = 'test';
        update opportunity;
        ApexPages.currentPage().getParameters().put('c',callObj.Id);
        WrapUpScreenController controller1=new WrapUpScreenController();
        controller1.closeCall();
        
    }
    
}