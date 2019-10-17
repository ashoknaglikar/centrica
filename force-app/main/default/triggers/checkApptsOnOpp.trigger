trigger checkApptsOnOpp on Opportunity (before delete , before insert) {
    if(cls_IsRun.generalTriggerSwitch)
    {
        return;
    }
    List<Opportunity> oppList = new List<Opportunity>();
    
    // ++ Added for Free Insulation change start
    set<id> accountIdSet = new set<id>();
    set<id> freeInsulationAccountIdSet = new set<id>();
    List<String> freeInsulPostcodes = new List<String>();
    Map<String , Id> accountPostCodeIdmap = new Map<String , Id>();
    Map<Id,String> accountIdInsulRefNumberMap = new Map<Id,String>();
    
    Map<String,Gas_Council__c> populatemodel = new Map<String,Gas_Council__c>();
    set<String> gasnumber = new set<String>();
    
   if(Trigger.isBefore && Trigger.isInsert)
   {
       system.debug('@@@@@enteringgggggggg');
       for(Opportunity opp : Trigger.new)
        {
            accountIdSet.add(opp.AccountId);
            
            
            if(opp.Gas_Council_Number__c==null && opp.Gas_Council_Number__c=='' && opp.Gas_Council_Number__c.startsWith('42'))
            {
                system.debug('@@@@@opp.Gas_Council_Number__c.startsWith'+opp.Gas_Council_Number__c);
                opp.Make__c='warm air unit';
                opp.Model__c='warm air unit';
            }
            else
            {
                system.debug('@@@@@opp.Gas_Council_Number__c'+opp.Gas_Council_Number__c);
                gasnumber.add(opp.Gas_Council_Number__c);
            }
            
            
        }
      
      if(gasnumber.size()>0)
      {  
      system.debug('@@@@@gasnumber.size()'+gasnumber.size());
      for(Gas_Council__c g: [select id, Make__c,Model__c,Rating__c,Efficiency__c,Parts_Listing__c,Name from Gas_Council__c  where Name =:gasnumber])
      {
        system.debug('@@@@@Gas_Council__c g'+g);
        populatemodel.put(g.Name, g);
        system.debug('@@@@@populatemodel'+populatemodel);
        
      }
      }
      if(accountIdSet != null && accountIdSet.size() > 0)
        {
            for(Account acc : [select id,BillingPostalCode from Account where id in: accountIdSet])
            {
                freeInsulPostcodes.add(acc.BillingPostalCode);
                accountPostCodeIdmap.put(acc.BillingPostalCode , acc.Id);
            }
        }
        if(freeInsulPostcodes != null && freeInsulPostcodes.size() > 0)
        {
            for(Free_Insulation_Postcode__c freePostcodes : [select id,Name,Active__c , Ofgem_Insulation_Reference__c from Free_Insulation_Postcode__c where Name in: freeInsulPostcodes and Active__c = 'True'])
            {
                if(accountPostCodeIdmap != null && accountPostCodeIdmap.size() > 0)
                {
                    if(accountPostCodeIdmap.containsKey(freePostcodes.Name))
                    {
                        freeInsulationAccountIdSet.add(accountPostCodeIdmap.get(freePostcodes.Name));
                        accountIdInsulRefNumberMap.put(accountPostCodeIdmap.get(freePostcodes.Name) , freePostcodes.Ofgem_Insulation_Reference__c);
                    }
                }
            }
        }
        for(Opportunity CHILead : Trigger.new)
        {
            if(freeInsulationAccountIdSet != null && freeInsulationAccountIdSet.size() > 0)
            {
                if(freeInsulationAccountIdSet.contains(CHILead.AccountId))
                {
                    CHILead.Free_Insulation_Eligible__c = 'Yes';
                    CHILead.Ofgem_Insulation_Reference__c = accountIdInsulRefNumberMap.get(CHILead.AccountId);
                }
            }
            else
            {
                CHILead.Free_Insulation_Eligible__c = 'No';
            }
            if(CHILead.Gas_Council_Number__c !=null )
            {
	            if(populatemodel.containsKey(CHILead.Gas_Council_Number__c))
	            {
		             system.debug('@@@populatemodel.containsKey'+populatemodel.containsKey(CHILead.Gas_Council_Number__c));
		             Gas_Council__c gc= populatemodel.get(CHILead.Gas_Council_Number__c);
		             CHILead.Make__c=gc.Make__c;
		             CHILead.Model__c=gc.Model__c;
		             CHILead.Rating__c=gc.Rating__c;
		             CHILead.Efficiency__c=gc.Efficiency__c;
		             CHILead.Parts_Listing__c=gc.Parts_Listing__c;
	            }else
	            {
	            	CHILead.Make__c='Unidentified Boiler';
		            CHILead.Model__c='Unidentified Boiler';	
	            }
            }    
            
        }
       // }
   }
    // -- Added for Free Insulation change end
    
    if(Trigger.isBefore && Trigger.isDelete)
    {
        Appointment__c[] appts = [Select a.Opportunity__c from Appointment__c a where Opportunity__c in :Trigger.old 
                                                   and RecordTypeId = '012200000004iOK' and Status__c = 'Appointed'];

        for(Opportunity opp:Trigger.old){
            oppList.add(opp);
        }
        
        if(appts.size()>0){
        
        for(Appointment__c appt:appts){
            
            for(Opportunity opp:oppList){
                
                 if(appt.Opportunity__c == opp.Id){
                    
                    opp.addError('Please cancel the corresponding appointment before deleting this Opportunity.');
                    
                    }
                
                }
            
            }
        
        }
    }
    
    
    

}