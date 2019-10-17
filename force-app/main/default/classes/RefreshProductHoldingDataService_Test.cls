public class RefreshProductHoldingDataService_Test 
{
	static testmethod void testRefreshProductHoldingDataService()
	{
		Inbound_Call__c callObj = new Inbound_Call__c();
        callObj.Workflow_Step__c = 1;
        insert callObj;
        Inbound_Call__c inboundCall =[select Id,Workflow_Step__c from Inbound_Call__c limit 1];
        
        
        //Add parameters to page URL 
        System.debug('####**** inboundCall'+inboundCall);
        //ApexPages.currentPage().getParameters().put('c',inboundCall.Id);
        
        ///////////////
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
        account.CustomerUCRN__c = 'testucrn';
        account.BuildingNo__c = '1234';
        
        insert account;
        
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
        
        Contact contact1=new Contact();
        contact1.Primary_Contact__c=false;
        contact1.Phone='9022332343';                
        contact1.MailingStreet='test Street';
        contact1.MailingState='Test State1';
        contact1.MailingPostalCode='M25 017';
        contact1.MailingCountry='Test country1';
        contact1.MailingCity='Test City';
        contact1.LastName='Last Name1';
        contact1.FirstName='First name1';
        contact1.Email='test@gmail.com';
        contact1.AccountId=account.Id;
        
        insert contact1;

        contactList.add(contact);
        contactList.add(contact1);
		
		ContactInfo conInfo = new ContactInfo();
        conInfo.contact= contact;
        conInfo.AddSlct = true;
        conInfo.ConSlct = true;
        conInfo.AddStrt='Street';
        conInfo.AddCty='city';
        conInfo.AddStat='state';
        conInfo.AddCntr='country';
        conInfo.AddZip='442222';
        conInfo.ConAdd='conAddress';
        
        ContactInfo conInfo1 = new ContactInfo();
        conInfo1.contact= contact1;
        conInfo1.AddSlct = true;
        conInfo1.ConSlct = true;
        conInfo1.AddStrt='Street';
        conInfo1.AddCty='city';
        conInfo1.AddStat='state';
        conInfo1.AddCntr='country';
        conInfo1.AddZip='442222';
        conInfo1.ConAdd='conAddress';

        List<ContactInfo> contactInfoList= new List<ContactInfo>();        
        contactInfoList.add(conInfo);
        contactInfoList.add(conInfo1);
            
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
        
        insert opportunity;
        
        RefreshProductHoldingDataService.refreshProductHoldingData(account.CustomerUCRN__c, null, account);
        
        
        Workflow.WorkflowInfo WorkflowInfo = new Workflow.WorkflowInfo();
    	WorkflowInfo.CustomerUCRN = account.CustomerUCRN__c;
    	
    	Account relatedAccount = [select id , HouseName__c, BuildingNo__c, POBoxNumber__c, BillingPostalCode, ProductHoldingLastUpdated__c  from Account where id =: account.Id];
    	
    	WorkflowInfo.Call = new Inbound_Call__c();
    	WorkflowInfo.Call.Billing_Zip__c = relatedAccount.BillingPostalCode;
    	
    	WorkflowInfo.HouseNumber = account.BuildingNo__c;
        
        RefreshProductHoldingDataService.refreshProductHoldingData(WorkflowInfo, account);
	}
}