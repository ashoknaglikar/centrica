trigger PrimaryContactOnInsOrUpd on Contact (after insert,after update, after delete) {

Map<Id, Contact> accountContactMap = new Map<Id,Contact>{};
Map<Id, Contact> accountContactchiMap = new Map<Id,Contact>{}; // added by BGSAMS support 28/06/2011
Map<Id, Contact> accountlandlordMap = new Map<Id,Contact>{};

if(!Lock.employeeTrigger && trigger.isInsert && (System.label.CallHistory == 'on' || system.label.SystemAdminId.contains(userinfo.getProfileId())))
{
    Lock.callHistory = true;
	ContactTriggerHelper.methodAfterInsert(trigger.new , trigger.newmap);
}else if(!Lock.employeeTrigger && trigger.isUpdate  && System.label.CallHistory == 'on')
{
    Lock.callHistory = true;
	ContactTriggerHelper.methodAfterUpdate(trigger.new , trigger.newmap, trigger.old, trigger.oldmap);
}

if (!System.Trigger.isDelete)
{   
    Account[] accountsToUpd ;
    Contact[] contactsToUpd;
   
    
           
    for(Contact newContact : Trigger.new) {
    
        if (newContact.Primary_Contact__c==true && (System.Trigger.isInsert ||
(System.Trigger.isUpdate && Trigger.oldMap.get(newContact.Id).Primary_Contact__c!=newContact.Primary_Contact__c)))
        {
            accountContactMap.put(newContact.AccountId,newContact);
        
        }// if primary contact
        
        if(trigger.isInsert)
        {
        	if(newContact.Contact_Type__c =='Landlord' ||newContact.Contact_Type__c =='Agent' || newContact.Contact_Type__c =='Multi-premise' )
        	{
        		accountlandlordMap.put(newContact.AccountId,newContact);
        	}
        }
    
    } // for new contact
    
    accountsToUpd = [Select a.id,a.Primary_Contact__c from Account a 
                                         where a.id in :accountContactMap.keySet()] ;
                                         
        for (Account accToUpd : accountsToUpd)
        {
        	if(accountContactMap.containskey(accToUpd.Id))
        	{
	            Contact newCont = accountContactMap.get(accToUpd.Id);
	            if (System.Trigger.isInsert || (System.Trigger.IsUpdate &&
	            (Trigger.oldMap.get(newCont.Id).AccountId == newCont.AccountId)))
	                accToUpd.Primary_Contact__c = accountContactMap.get(accToUpd.Id).Id;
        	}
        }
        
      if(accountlandlordMap.size()>0)
      {
      	list<Landlord_Record__c> updateList = new list<Landlord_Record__c>();
      	For(Landlord_Record__c l :[select id,CHI_Lead__r.AccountId from Landlord_Record__c where 	CHI_Lead__r.AccountId in :accountlandlordMap.keyset()])
      	{
      		if(accountlandlordMap.containskey(l.CHI_Lead__r.AccountId))
      		{
      			if(accountlandlordMap.get(l.CHI_Lead__r.AccountId).Contact_Type__c == 'Landlord' || accountlandlordMap.get(l.CHI_Lead__r.AccountId).Contact_Type__c == 'Multi-premise')
      			{
      				l.Landlord__c = accountlandlordMap.get(l.CHI_Lead__r.AccountId).Id;
      			} else if(accountlandlordMap.get(l.CHI_Lead__r.AccountId).Contact_Type__c == 'Agent')
      			{
      				l.Agent_Contact__c = accountlandlordMap.get(l.CHI_Lead__r.AccountId).Id;
      			}else if(accountlandlordMap.get(l.CHI_Lead__r.AccountId).Contact_Type__c == 'Tenant')
      			{
      				l.Tenant_Contact__c = accountlandlordMap.get(l.CHI_Lead__r.AccountId).Id;
      			}
      			
      			updateList.add(l);
      		}
      	}
      	
      	if(updateList.size()>0)
      	{
      		update updateList;
      	}
      }  
        
        contactsToUpd = [Select c.id, c.Primary_Contact__c, c.AccountId from Contact c 
                where  c.AccountId in :accountContactMap.keySet()  and  c.Primary_Contact__c =true
                and c.Id not in :Trigger.newMap.keySet()];
        
        for (Contact contact : contactsToUpd)
        {
            if (System.Trigger.isInsert || (System.Trigger.isUpdate &&
            (Trigger.oldMap.get(accountContactMap.get(contact.AccountId).Id).AccountId 
                                                                            == contact.AccountId)))
                contact.Primary_Contact__c=false;
        }
        
      if (contactsToUpd!=null && !contactsToUpd.isEmpty())
     Database.update(contactsToUpd);
     if(accountsToUpd!=null && !accountsToUpd.isEmpty())
     Database.update(accountsToUpd); 


}
    
     
if (!System.Trigger.isInsert)
{       
    Contact[] contactsAltToPrim;
    
    Account[] accsToAltPrim;
    
    Id[] primContIdsToFalse = new Id[]{};
    
    Contact[] primContsToFalse;
    Contact[] contactsToUpdchi; // added by BGSAMS support 28/06/2011
    Map<Id,Contact> accountContactMapForAltPrim = new Map<Id,Contact>{};
    
    if (System.Trigger.isUpdate)
    {
        for(Contact newContact : Trigger.new) {
            
            if(newContact.Primary_Contact__c == true)
            {
                accountContactchiMap.put(newContact.AccountId,newContact);    // added by BGSAMS support 28/06/2011 to uncheck the previous primary contacts on the account.  
                Contact oldContact = Trigger.oldMap.get(newContact.Id);
                 
                if(newContact.AccountId != oldContact.AccountId)
                { 
                    //if the contact was Primary even before this update
                    if (oldContact.Primary_Contact__c==true)
                        accountContactMapForAltPrim.put(oldContact.AccountId,null);
                      
                    System.debug('Old and new account ids don\'t match for ' + oldContact.Id);
                    
                    primContIdsToFalse.add(newContact.Id);
                }// if acc ids have changed
            } //if primary contact
        }//for
    } //System.Trigger.isUpdate
    
        if (System.Trigger.isDelete)
        {
            for(Contact oldDelContact : Trigger.old) 
            {//for all delted contacts
                if (oldDelContact.Primary_Contact__c ==true)
                {
                    accountContactMapForAltPrim.put(oldDelContact.AccountId,null);
                
                }//if 
                
            }//for all deleted contacts
        }//System.Trigger.isDelete
        
        if(!primContIdsToFalse.isEmpty())
        {
            primContsToFalse = [Select c.Id,c.Primary_Contact__c from Contact c 
                                            where c.Id in :primContIdsToFalse];
            
            
                                                 
            for(Contact primContToFalse : primContsToFalse)
            {
                // 25/01/2011
                // Stop CHI Online contacts from being un-set as primary when contacts are being inserted by CHI Online webservice
                // Note that this means CHI Online shuld never log in via a browser as it can mess with the primary contacts
                // for Accounts e.g. Account can end up having 2 primary contacts

                // Check if contact is from CHI Online
                
                System.debug('UserInfo ' +UserInfo.getUserName());   
                
                if (!UserInfo.getUserName().contains('chi_online')) {
                    
                    System.debug('Setting Primary_Contact__c = false for ' + primContToFalse.Id);
                    
                    primContToFalse.Primary_Contact__c = false;
                                 
                    
                }
                else {  
                    
                    // added by BGSAMS support 28/06/2011 to prevent more than one primary contact even if created by CHI online
                     contactsToUpdchi = [Select c.id, c.Primary_Contact__c, c.AccountId from Contact c 
                where  c.AccountId in :accountContactchiMap.keySet()  and  c.Primary_Contact__c =true
                and c.Id not in :Trigger.newMap.keySet()];
                
                for (Contact contact : contactsToUpdchi)
        {
           
                contact.Primary_Contact__c=false;
                
                System.debug('Setting Primary_Contact__c = false for ' + contactsToUpdchi);
                
                
                      }
                    
                    
                }
                
            }
                    
        }
        contactsAltToPrim = [Select c.Id, c.Primary_Contact__c, c.AccountId from Contact c 
                where  c.AccountId in :accountContactMapForAltPrim.keySet()  and  c.Primary_Contact__c =false];
                
                if(!contactsAltToPrim.isEmpty()) {
                    for(Contact cont : contactsAltToPrim) 
                    {   //if an an alt cont has not already been made primary for this acc
                        if (accountContactMapForAltPrim.get(cont.AccountId) == null)
                        { 
 System.debug('contactsAltToPrim' + contactsAltToPrim);
  
                          accountContactMapForAltPrim.put(cont.AccountId,cont);
                            cont.Primary_Contact__c = true;
                        }// end-if an alt cont has not already been made primary
                    }//for
                    
                    accsToAltPrim = [Select a.id,a.Primary_Contact__c from Account a
                                        where a.id in :accountContactMapForAltPrim.keySet()];
                    
                    for (Account acc : accsToAltPrim)
                    {
                        if (accountContactMapForAltPrim.get(acc.Id).Id !=null)
                            acc.Primary_Contact__c = accountContactMapForAltPrim.get(acc.Id).Id;
                        else
                            acc.Primary_Contact__c = null;
                    }
                    
               }// if contacts empty
               
      
       if(primContsToFalse!=null && !primContsToFalse.isEmpty())
            Database.update(primContsToFalse);
       if(contactsAltToPrim!= null && !contactsAltToPrim.isEmpty())
            Database.update(contactsAltToPrim);
       if(accsToAltPrim!=null && !accsToAltPrim.isEmpty())
            Database.update(accsToAltPrim);
       if(contactsToUpdchi!=null && !contactsToUpdchi.isEmpty())
        Database.update(contactsToUpdchi); 
         }//if it is an update - System.Trigger.isUpdate
    }