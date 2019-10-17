public class ContactTriggerHandler {
    
    public static void updateMarketingPreferenceFieldOnopportunity(map<id,contact> triggerOld,List<contact> triggerNew){

        map<id, contact> accIdMap =new map<id, Contact>();
        
        for(Contact con :triggernew){
            if(con.Primary_contact__c && (con.Marketing_Preference__c != triggerOld.get(con.id).Marketing_Preference__c || con.Marketing_Consent__c != triggerOld.get(con.id).Marketing_Consent__c))
            accIdMap.put(con.AccountId, con);
        }

        List<opportunity> oppList=new List<opportunity>();

        oppList= [select id,AccountId,Marketing_Preferences__c,Customer_Marketing_Consent__c from opportunity where AccountId in :accIdMap.keyset()];

        for(opportunity opp : oppList)
        {
            if(accIdMap.containsKey(opp.AccountId))
            {
                Contact con = accIdMap.get(opp.AccountId);
                opp.Marketing_Preferences__c=con.Marketing_Preference__c;
                opp.Customer_Marketing_Consent__c=con.Marketing_Consent__c;
            }
        }
        if(oppList.size()>0)
        update oppList;
        
    }
    
}