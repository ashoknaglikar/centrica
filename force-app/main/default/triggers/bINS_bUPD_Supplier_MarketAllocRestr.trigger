trigger bINS_bUPD_Supplier_MarketAllocRestr on Supplier__c (before insert, before update) {
    
    //Retrieving the old values of Market allocation    
    List<Supplier__c> Listobjsup = new List<Supplier__c>([Select s.Id,s.Type__c, s.Market_Allocation__c From Supplier__c s where s.Type__c='Product'and (s.Status_code__c!='B' or s.Status_code__c!='D')  and s.Id NOT IN : trigger.new]);
    Double count=0;
    Supplier__c objsup = new Supplier__c();
    Integer i=0;
    if(Trigger.isInsert || Trigger.isUpdate)
    {
        //Adding the values for other suppliers of Market Allocation
        Listobjsup.AddAll(trigger.new);
        for(Supplier__c su: Listobjsup)
        {
            if(su.Market_Allocation__c != null)
                count += su.Market_Allocation__c ; 
        }
        
        //Checking the condition of 100%
        if(count > 100)
        {
            for(Supplier__c s1 : trigger.new)
            {
                if(s1.Type__c == 'Product')
                    s1.addError('Percentage Marked Allocation cannot exceed 100%.');
            }
        }
    }

}