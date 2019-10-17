/*
*    Author  : Cognizant 
*    Purpose : This trigger updates teh Balanace payment method on opportunity by the recently added BGS payamen trecord's payment method
*/
trigger aINS_updateOppBalPayMethod on BGS_Payment__c (after insert) {
    System.debug('@ Updating Oppotuntiy @ '+Trigger.new);
    // Variable to hold bgs pay method per related opportunity
    Map<Id,BGS_Payment__c> bgsPayOppMap = new Map<Id,BGS_Payment__c>();
    
    for(BGS_Payment__c bgs_pay : Trigger.new)
   // if(bgs_pay.Payment_Type__c <>'Deposit'){
        bgsPayOppMap.put(bgs_pay.Opportunity__c,bgs_pay);
   // }
    if(bgsPayOppMap.size() > 0){
        // Retrieve opportunities to update
        Opportunity[] oppList = [select id,PCN_Status__c,isSystem__c,Balance_Payment_Method__c from Opportunity where id in : bgsPayOppMap.keySet()];
        list<Opportunity> updateList = new list<Opportunity> ();
        for(Opportunity opp : oppList){
        	BGS_Payment__c newTempPayment = bgsPayOppMap.get(opp.Id);
        	boolean updated = false;
			if(newTempPayment.Payment_Type__c <>'Deposit')        	
			{
				updated = true;
            	opp.Balance_Payment_Method__c = newTempPayment.Payment_Method__c;
            	opp.isSystem__c=true;
			}else if(newTempPayment.Payment_Type__c == 'Deposit' && userinfo.getuserid() != system.label.BM_UserId)
			{
				updated = true;
				opp.Payment_Reference_Number__c = newTempPayment.BGS_Payment_Reference_Num__c;
            	opp.StageName = 'Deposit Taken';
			}
			if(updated)
			updateList.add(opp);
        }
        try{
        	if(updateList.size()>0)
            update updateList;
        }catch(DMLException e){
            System.debug('# Cant update opportunity #'+e.getMessage());
        }
    }
    
    
    
}