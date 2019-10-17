// After insert trigger on Contact for Data Migration

trigger bINS_On_Contact on Contact (before insert)
{

    /*System.debug('Before Insert DataMig trigger activated');
    
    Map<String,Contact> contactAccounts = new Map<String,Contact>{};*/
  
    
    for(Contact newContact : Trigger.new)
    {   
        if(newContact.Email__c!=null)
        {
            newContact.Preferred_Contact_Method__c='Email';
        }else if(newContact.MobilePhone != null)
        {
            newContact.Preferred_Contact_Method__c='Text (SMS)';
        }
        /*System.debug('Executing for ' + newContact.Contact_Num_2__c +
                                         contactAccounts.get(newContact.Contact_Num_2__c));
        if(contactAccounts.get(newContact.Contact_Num_2__c) == null)
        {
            System.debug('Inside Loop for Before Insert Contact');
            contactAccounts.put(newContact.Contact_Num_2__c,newContact);
            newContact.Primary_Contact__c=true;
        }*/
        
        // ++ Added for CR#792 start
        newContact.Landlord_Email_Trigger_Date_Time__c = system.now().addMinutes(-45);
        // -- Added for CR#792 end
        
    }
    
     
       
    
}