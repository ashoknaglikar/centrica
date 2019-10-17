trigger financeApplicationTrigger on Finance_Application__c (before update, before insert) {
    if(trigger.isbefore)
    {
        if(trigger.isUpdate)
        {
            list<Finance_Application__c> needDataDeleting =  new list<Finance_Application__c>();
            
            
            for(Finance_Application__c f : trigger.new)
            {
                
                if(f.Delete_data__c == true)
                {
                    needDataDeleting.add(f);
                }
                
                
            }
            barclaysIntegrationHelper bObj = new barclaysIntegrationHelper();
                
            bObj.deleteCustomerData(needDataDeleting);
            
        }else if(trigger.isinsert)
        {
            system.debug(financePhase3helper.decidePhaseOfApplication());
            if(trigger.new.size()>1)
            {
                trigger.new[0].adderror('Finance Application insert if not bulkified as system needs to decide the lender on one on one basis');
                return;
                
            }else if(financePhase3helper.decidePhaseOfApplication() == 'phase3' && !trigger.new[0].Do_Not_Derive_Product__c)
            {
                trigger.new[0].Valid_New_Application__c = true; 
                financePhase3helper.nextLenderWithFinanceProduct(trigger.new[0]);
                //trigger.new[0].Add_logging__c=true;
            }
            
            
        }
    }
        
    
}