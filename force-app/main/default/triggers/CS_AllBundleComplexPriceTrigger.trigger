trigger CS_AllBundleComplexPriceTrigger on CS_Bundle_Complex_Price_Association__c (before insert, before update) {
    
    // Do not execute for any user that has the No Triggers flag set to true.
    No_Triggers__c notriggers = No_Triggers__c.getInstance(UserInfo.getUserId());
    if (notriggers != null && notriggers.Flag__c)
    {
        return;
    }

    // prepare map that returns set of CS Parts for given Bundle Id
    Map<Id,Set<Id>> bundleToSetOfParts = new Map<Id,Set<Id>>();

    for (CS_Bundle_Complex_Price_Association__c bcpa : Trigger.new) {
        if (!bundleToSetOfParts.containsKey(bcpa.CS_Bundle__c)) {
            bundleToSetOfParts.put(bcpa.CS_Bundle__c, new Set<Id>());
        }
        bundleToSetOfParts.get(bcpa.CS_Bundle__c).add(bcpa.CS_Part__c);
    }

    Map<Id, CS_Bundle_Complex_Price_Association__c> existingRecordsMap = new Map<Id, CS_Bundle_Complex_Price_Association__c>([SELECT Id, Name, CS_Bundle__c, CS_Part__c, Lower_Skill_Hours_Limit__c, Upper_Skill_Hours_Limit__c FROM CS_Bundle_Complex_Price_Association__c WHERE CS_Bundle__c IN :bundleToSetOfParts.keySet()]);

    for (CS_Bundle_Complex_Price_Association__c bcpa : Trigger.new) {
        for (CS_Bundle_Complex_Price_Association__c existingBcpa : existingRecordsMap.values()) {

            // MC Added 2015-04-20
            // skip checking on self record
            if(bcpa.Id != null && existingBcpa.Id != null && bcpa.Id == existingBcpa.Id) continue;

            // match wannabe bcpa record with existing bcpa by Bundle Id
            if (bcpa.CS_Bundle__c == existingBcpa.CS_Bundle__c) {
                System.debug('### MATCHED BUNDLE ID: ' + existingBcpa.CS_Bundle__c);

                // match wannabe bcpa record with existing bcpa by Part Id
                if (bcpa.CS_Part__c == existingBcpa.CS_Part__c) {
                    System.debug('### MATCHED PART ID: ' + existingBcpa.CS_Part__c);

                    CS_AllBundleComplexPriceTriggerHelper.Bound bcpaBound = new CS_AllBundleComplexPriceTriggerHelper.Bound(bcpa.Lower_Skill_Hours_Limit__c, bcpa.Upper_Skill_Hours_Limit__c);

                    CS_AllBundleComplexPriceTriggerHelper.Bound existingBcpaBound = new CS_AllBundleComplexPriceTriggerHelper.Bound(existingBcpa.Lower_Skill_Hours_Limit__c, existingBcpa.Upper_Skill_Hours_Limit__c);

                    if (bcpaBound.overlaps(existingBcpaBound))
                    {
                        bcpa.addError(CS_AllBundleComplexPriceTriggerHelper.OVERLAPPING_BOUNDS_ERROR + existingBcpa.Name);
                    }
                }
            }
        }
    }
}