global class landlordHelper {
    
    
    public static void createLandlordRecords(list<Opportunity> opportuinties)
    {
        list<Landlord_Record__c> insertinRecords = new list<Landlord_Record__c>();
        
        Map<id, Opportunity> AccOppMap = new Map<id, Opportunity>();
        
        for(Opportunity o : opportuinties)
        {
            AccOppMap.put(o.AccountId, o);
        }
        
        map<Id, Account> AccounMap = new map<Id, Account>([select id, (Select id , Contact_Type__c from contacts order by CreatedDate asc), Sales_Subpatch__r.District__c from Account where id in :AccOppMap.keyset()]);
        
        for(id i : AccounMap.keyset())
        {
            Landlord_Record__c newLandLord = new Landlord_Record__c(Name='Temp Name', CHI_Lead__c = AccOppMap.get(i).Id, LL_External_Id__c = AccOppMap.get(i).CHI_Lead_Id1__c);
            
            
            boolean agentAdded = false;
            boolean lanlordAdded = false;
            boolean tenantAdded = false;
            
            for(Contact c: AccounMap.get(i).Contacts)
            {
                if(!agentAdded && c.Contact_Type__c == 'Tenant')
                {
                    newLandLord.Tenant_Contact__c = c.Id;
                    tenantAdded = true;
                }else if(!lanlordAdded && (c.Contact_Type__c == 'Landlord' || c.Contact_Type__c == 'Multi-premise'))
                {
                    newLandLord.Landlord__c = c.Id;
                    lanlordAdded = true;
                }else if(!agentAdded && c.Contact_Type__c == 'Agent')
                {
                    newLandLord.Agent_Contact__c = c.id;
                    agentAdded = true;
                }
                newLandLord.District__c = AccounMap.get(i).Sales_Subpatch__r.District__c;
            }
            
            insertinRecords.add(newLandLord);
            
        }
        
        if(insertinRecords.size()>0)
        {
            try{
            upsert insertinRecords LL_External_Id__c;
            }catch (exception e){}
        }
            
        
    }
    
    public static string createForLLR(id[] oppIds)
    {
        
        List<Opportunity> oppList = [Select id, AccountId,CHI_Lead_Id1__c from Opportunity where id in:oppIds];
        
        try{
        landlordHelper.createLandlordRecords(oppList);
        }catch(exception e)
        {
            return ('Some thing went wrong.'+e.getmessage());
        }
        
        return 'Sucessfully Created.';
        
    } 
    
    

}