@isTest
public with sharing class TestCustomerHistoryCard {
	static testMethod void Test_CreateCustomerHistoryCard() 
    {
	Account account=new Account(Name='Test Account',Number_of_Bedrooms__c=1,BillingStreet='Cust Street',BillingState='Cust State',
                                    BillingPostalCode='TW18 3HT',BillingCountry='Cust Country',BillingCity='Cust City');
        insert account;
        Contact contact=new Contact(Primary_Contact__c=true,Phone='9022332343', MailingStreet='Test Street',MailingState='Cust State',
                                     MailingPostalCode='TW18 3HT',MailingCountry='Test Country', MailingCity='Cust City',LastName='Cust Name',
                                     FirstName='Cust name',Email='test@gmail.com',AccountId=account.Id,Salutation='Mr'); 
        insert contact;
        Opportunity opportunity = new Opportunity(Name = 'TestCust1 Opp', StageName ='Active',CloseDate=System.today().addYears(1),                                                 
                                                  AccountId=account.Id, LeadSource='NET 01', Product_Interest__c = 'Solar', Override_Billing_checks__c=false,Amount = 3000);
        Opportunity[] opp = new Opportunity[]{opportunity};                                                 
        insert opp;
 		List<Job__c>  jobList = new List<Job__c>();
 		jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Customer_Journey__c='Welcome call not made – unable to contact customer',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()+5));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Customer_Journey__c='Welcome call made - 28 day call required',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()+5));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Mid_Call_Date__c = Date.Today(),Customer_Journey__c='Welcome call made - mid call required',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()+5));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Customer_Journey__c='Mid Call failed - 28 day call required',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()+5));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Mid_Call_Date__c = Date.Today(),Customer_Journey__c='Mid call completed - 28 day call required',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()+5));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Customer_Journey__c='Journey completion call failed - unable to contact customer',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Customer_Journey__c='Journey completion call not made - customer issues to be resolved',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Customer_Journey__c='Journey completion call made – customer issues to be resolved',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()));
        jobList.add(new Job__c(CHI_Lead__c = opp[0].ID,Status__c='Pending',Customer_Journey__c='Journey completed – 28 day handover',
                                Delivery_Date__c =Date.today(),Installation_Date__c=Date.today()));
    		
    		insert jobList;
    		
    		for(Job__c job: JobList){
    			CreateCustomerHistoryCard.createCustHistoryCard(job.id,true);
    		}
        test.startTest();		
		jobList[0].Customer_Journey__c = 'Welcome call made - 28 day call required';
    	jobList[0].X28_Day_Referral__c = 'test refferal';
    	update jobList[0];
	    jobList[0].Customer_Journey__c = 'Welcome call made - mid call required';
	    jobList[0].Mid_call_date__c = Date.Today();
    	update jobList[0];
    	jobList[0].Customer_Journey__c = 'Mid Call failed - 28 day call required';
    	update jobList[0];
    	jobList[0].Customer_Journey__c = 'Mid call completed - 28 day call required';
    	update jobList[0];
    	jobList[0].Customer_Journey__c = 'Journey completion call failed - unable to contact customer';
    	update jobList[0];
    	jobList[0].Customer_Journey__c = 'Journey completion call not made - customer issues to be resolved';
    	jobList[0].X28_Day_Referral__c = 'test refferal';
        jobList[0].X28_Referral_Reason__c = 'test reason';
    	update jobList[0];
    	jobList[0].Customer_Journey__c = 'Journey completion call made – customer issues to be resolved';
    	update jobList[0];
    	jobList[0].Customer_Journey__c = 'Journey completed – 28 day handover';
    	update jobList[0];
    	
    	test.stopTest();
    	
    }
}