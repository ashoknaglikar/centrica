// After insert trigger on Contact for Data Migration

trigger PrimaryContact on Contact (before insert)
{

    System.debug('Before Insert DataMig trigger activated');
    
    Map<String,Contact> contactAccounts = new Map<String,Contact>{};
  
    
    for(Contact newContact : Trigger.new)
    {   
        System.debug('Executing for ' + newContact.Contact_Num_2__c +
                                         contactAccounts.get(newContact.Contact_Num_2__c));
        if(contactAccounts.get(newContact.Contact_Num_2__c) == null)
        {
            System.debug('Inside Loop for Before Insert Contact');
            contactAccounts.put(newContact.Contact_Num_2__c,newContact);
            newContact.Primary_Contact__c=true;
        }
        
    }
    
     
       
    
}