public class TestCreditCheckControler {
	
		
	public static testMethod void testCreditCheckController(){
		
		//Create Account
		Account acc = new Account(Name='Dummy123', BillingStreet='23 Roundacre', BillingPostalCode='SW19 6DB',
			 BillingCity='London', BillingCountry='UK', BillingState='London');
		
		Database.insert(acc);


		//Create Contact
		Contact contact = new Contact(AccountId=acc.Id, FirstName='CreditUser', LastName='CreditCheckUser',
		Salutation='Ms',Gender__c='F',MailingStreet='9 Hadleigh Court',MailingCity='Leeds',
		MailingState='West Yorkshire', MailingPostalCode='LS17 6DP', MailingCountry='England');
		contact.Primary_Contact__c=true;
		Database.insert(contact);
		
		Contact contactB = new Contact(AccountId=acc.Id, LastName='secondaryContact Test');
		Database.insert(contactB);
		
		Campaign camp = new Campaign(Source__c = 'MARCOMMS', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test campaign');
		Database.insert(camp);		
		
		//Create Opportunity
		Opportunity opp = new Opportunity (LeadSource = 'MARCOMMS', name = 'CreditCheckOpp', AccountId = acc.Id,
												CloseDate = Date.today().addyears(1), 
												StageName = 'Active', Product_Interest__c='Central Heating Boiler',
												CampaignId = camp.Id);
		
		Database.insert(opp);
												
		//Create Quote for the Opp, which will populate opp.Accept_Quote_Amt__c
		Quote__c quote = new Quote__c(Accepted_Date__c=Datetime.now(),
		Amount__c=289,Opportunity__c=opp.id,Quote_Num__c='CCTest12357', Status__c='Accepted' );
		
		Database.insert(quote);
		
		CreditCheckControler ccController;
		PageReference pageRef;
		Credit_Check__c creditCheckObj;

		//Located at address, searches<9, Not Bankrupt, Deposit should be 10%
	    pageRef = new PageReference('/apex/CreditCheck?oppId='+opp.Id + 
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:numOfSearchesInput=5'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:locatedAtCheckBox=1'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyStatus=Solvent'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyCheckbox=0'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:experianRef=Exp123456');
	    Test.setCurrentPage(pageRef);
	    
	    ccController=new CreditCheckControler();
	    creditCheckObj=ccController.getOCreditCheck();
	    creditCheckObj.Located_At_Address__c=true;
	    creditCheckObj.Bankrupt__c=false;
	    creditCheckObj.Number_of_Searches__c=7;
	    
	   	ccController.deposit();
	   	
	   	ccController.getOCreditCheck();
	   	
	   	 //Check that the contact that has been retrieved is the Primary Contact for th Account
	    //System.assertEquals(contact.MailingPostalCode,creditCheckObj.Postcode_Searched__c);
	    //System.assertEquals(contact.MailingStreet,creditCheckObj.Street_Searched__c);
	    
	   	System.assertEquals(creditCheckObj.Deposit_Percent_Reqd__c,10);
	   	
	   	
	   	//Located at address, searches>9, Not Bankrupt, Deposit should be 50%
	    pageRef = new PageReference('/apex/CreditCheck?oppId='+opp.Id + 
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:numOfSearchesInput=15'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:locatedAtCheckBox=1'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyStatus=Solvent'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyCheckbox=0'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:experianRef=Exp123456');
	    Test.setCurrentPage(pageRef);
	   	
	   	creditCheckObj=ccController.getOCreditCheck();
	    creditCheckObj.Located_At_Address__c=true;
	    creditCheckObj.Bankrupt__c=false;
	    creditCheckObj.Number_of_Searches__c=12;
	    ccController.deposit();
	   	
	   	System.assertEquals(50,creditCheckObj.Deposit_Percent_Reqd__c);
	    
	    		
	   	//Located at address, searches<9, Bankrupt, Deposit should be 100%
	    pageRef = new PageReference('/apex/CreditCheck?oppId='+opp.Id + 
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:numOfSearchesInput=5'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:locatedAtCheckBox=1'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyStatus=Solvent'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyCheckbox=1'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:experianRef=Exp123456');
	    Test.setCurrentPage(pageRef);
	    
	    creditCheckObj=ccController.getOCreditCheck();
	    creditCheckObj.Located_At_Address__c=true;
	    creditCheckObj.Bankrupt__c=true;
	    creditCheckObj.Number_of_Searches__c=1;
	    ccController.deposit();
	   		   	
	   	System.assertEquals(100,creditCheckObj.Deposit_Percent_Reqd__c);
	    
		//Located at address, searches>9, Bankrupt, Deposit should be 100%
	    pageRef = new PageReference('/apex/CreditCheck?oppId='+opp.Id + 
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:numOfSearchesInput=51'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:locatedAtCheckBox=1'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyStatus=Solvent'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyCheckbox=1'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:experianRef=Exp123456');
	    Test.setCurrentPage(pageRef);
	    
	    creditCheckObj=ccController.getOCreditCheck();
	    creditCheckObj.Located_At_Address__c=true;
	    creditCheckObj.Bankrupt__c=true;
	    creditCheckObj.Number_of_Searches__c=12;
	    ccController.deposit();
	   		   	
	   	System.assertEquals(100,creditCheckObj.Deposit_Percent_Reqd__c);
	    
	    
	    //Not Located at address, searches<9, Not Bankrupt, Manual Override to be Applied for Deposit
	    pageRef = new PageReference('/apex/CreditCheck?oppId='+opp.Id + 
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:numOfSearchesInput=5'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:locatedAtCheckBox=1'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyStatus=Solvent'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyCheckbox=1'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:experianRef=Exp123456');
	    Test.setCurrentPage(pageRef);
	    
	    creditCheckObj=ccController.getOCreditCheck();
	    creditCheckObj.Located_At_Address__c=false;
	    creditCheckObj.Bankrupt__c=false;
	    creditCheckObj.Number_of_Searches__c=1;
	    ccController.deposit();
	   		   	
	   	System.assertEquals(200,creditCheckObj.Deposit_Percent_Reqd__c);
	   	
	   	//Not Located at address, searches>9, Bankrupt, Manual Override to be Applied for Deposit
	    pageRef = new PageReference('/apex/CreditCheck?oppId='+opp.Id + 
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:numOfSearchesInput=5'+
	    '&j_id0:j_id2:creditCheckBlock:infoBlock:locatedAtCheckBox=1'+
	    '&j_id0:j_id2:creditCheckBlock:infoBl	ock:bankruptcyStatus=Solvent'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:bankruptcyCheckbox=1'+
	    'j_id0:j_id2:creditCheckBlock:infoBlock:experianRef=Exp123456');
	    Test.setCurrentPage(pageRef);
	    
	    creditCheckObj=ccController.getOCreditCheck();
	    creditCheckObj.Located_At_Address__c=false;
	    creditCheckObj.Bankrupt__c=true;
	    creditCheckObj.Number_of_Searches__c=12;
	    ccController.deposit();
	   		   	
	   	System.assertEquals(200,creditCheckObj.Deposit_Percent_Reqd__c);
	    
	}

}