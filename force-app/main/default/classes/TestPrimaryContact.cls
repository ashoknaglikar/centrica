@istest
public class TestPrimaryContact {
	
	static testMethod void updateContact() {
		
	/* Create an Account and a Primary Contact, associate contact with Account and check that the
	Contact has been set as primary on the account*/
	// Create Account
		Account acc = new Account(Name='Dummy123', BillingStreet='8 Roundacre TEST 888', BillingPostalCode='SW19 1ZZ',
			 BillingCity='London', BillingCountry='UK', BillingState='London');
		
		Database.insert(acc);


		// Create Contact
		Contact contact = new Contact(AccountId=acc.Id, LastName='updatePrimaryContact Test');
		//contact.Contact_Num_2__c='ABCDEF123';
		contact.Primary_Contact__c=true;
		Database.insert(contact);



		Contact contactB = new Contact(AccountId=acc.Id, LastName='secondaryContact Test');
		Database.insert(contactB);
		
		Account primContAcc = [select a.id,a.Primary_Contact__c, a.Primary_Contact_Last_Name__c from Account a
		where a.id = :acc.id];
				
		Contact primCont = [select c.LastName, c.Primary_Contact__c from Contact c  where
								c.AccountId = :primContAcc.id and c.Primary_Contact__c=true];
					
		System.assertEquals(primContAcc.Primary_Contact_Last_Name__c, primCont.LastName);
		
	
		
		/*move the contact from acc to newAcc, and check that the alternative contact on acc has	
		now been marked as the primary contact by equating last names on Acc and Contact*/
		
		Account newAcc = new Account(Name='ABC567', BillingStreet='1 East Lodge', BillingPostalCode='SW19 6DE',
			 BillingCity='London', BillingCountry='UK', BillingState='London');
		Database.insert(newAcc);
		
		contact.AccountId = newAcc.id;
		
		
		update contact;
		System.debug('contact id for the moved contact rec is ' + contact.Id);
		
		Account oldAccountUpd = [Select a.Primary_Contact__c,a.Primary_Contact_Last_Name__c from Account a
		where a.id=:acc.id];
		
		Contact[] newBPrimary = [Select c.id, c.Primary_Contact__c, c.LastName from Contact c 
								where c.AccountId = :acc.id];
	
		System.assertEquals(oldAccountUpd.Primary_Contact_Last_Name__c,newBPrimary[0].LastName);
		
		contact = [Select c.Id, c.Primary_Contact__c,c.LastName from Contact c where c.Id = :contact.Id];
		
		System.assertEquals(false,contact.Primary_Contact__c);
		
		/*set the primary_contact flag on the contact moved to newAcc to true, and check it has	
		now been marked as the primary contact by equating last names on Acc and Contact*/
		
		contact.Primary_Contact__c = true;
		update contact;
		
		Account newAccountUpd = [Select a.Primary_Contact_Last_Name__c, a.Primary_Contact__c from Account a
		where a.id=:newAcc.id];
		
		System.assertEquals(contact.Id,newAccountUpd.Primary_Contact__c);
		System.assertEquals(newAccountUpd.Primary_Contact_Last_Name__c,contact.LastName);
		
		
		/*Add a new contact, update that to set it as a primary, and check that this change is reflected
		on the account, by comparing last names on account and contact */
		
		Contact newContact4NewAcc = new Contact(AccountId=newAcc.id, LastName='NewAcc SecondaryCont');
		Database.insert(newContact4NewAcc);
		
		test.starttest();
		newContact4NewAcc.Primary_Contact__c = true;
		update newContact4NewAcc;
		
		newAccountUpd = [Select a.Primary_Contact_Last_Name__c from Account a
		where a.id=:newAcc.id];
		
		System.assertEquals(newContact4NewAcc.LastName,newAccountUpd.Primary_Contact_Last_Name__c);
		
		
		/*delete the existing prim contact on newAcc, and check if the alt contact	
		has now been marked as the primary contact by equating last names on Acc and Contact*/
				
		Database.delete(contact);
		
		newAccountUpd = [Select a.Primary_Contact_Last_Name__c from Account a
		where a.id=:newAcc.id];
		
		System.assertEquals(newAccountUpd.Primary_Contact_Last_Name__c,newContact4NewAcc.LastName);
		
		/* Insert a new Primary Contact on an Account already having primary contact, verify that newly 
		inserted contact becomes primary */
		
		Contact contactBNew = new Contact(AccountId=newAcc.Id, LastName='PrimaryContact3 Test',
		Primary_Contact__c=true);
		Database.insert(contactBNew);
		
		newAccountUpd = [Select a.Primary_Contact_Last_Name__c from Account a
		where a.id=:newAcc.id];
		
		System.assertEquals(newAccountUpd.Primary_Contact_Last_Name__c,contactBNew.LastName);
		
		/*Delete the only contact on an Account and check that the Primary_Contact__c on the account is null*/
		System.assertEquals(newBPrimary[0].id,oldAccountUpd.Primary_Contact__c);
		Database.delete(newBPrimary[0]);
		oldAccountUpd = [Select a.Primary_Contact_Last_Name__c,a.Primary_Contact__c from Account a
		where a.id=:acc.id];
		System.assertEquals(null,oldAccountUpd.Primary_Contact__c);
		System.assertEquals(null,oldAccountUpd.Primary_Contact_Last_Name__c); 
		test.stoptest();
	}
	

}