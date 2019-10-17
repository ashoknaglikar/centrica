trigger aINS_aUPD_updateOpptyUpdate on Compensation__c (after insert, after update) {
    Set<String> oppSet = new Set<String>();
    Map<String,Opportunity> oppMap = new Map<String,Opportunity>();
    List<Opportunity> oppUpdate =  new List<Opportunity>();
    Integer count=0;
    
    for(Compensation__c comp : Trigger.new){
        if(comp.Related_ChI_Lead__c != null && comp.Value_Compensated__c != null )
            oppSet.add(comp.Related_ChI_Lead__c); 
    }
    if(oppSet.size() > 0){
        Opportunity[] oppList = [select Compensation_Amount__c,id from opportunity where id in : oppSet];
        for(Opportunity opp : oppList){
           oppMap.put(opp.Id,opp); 
        }
        
        for(Compensation__c comp : Trigger.new){
            Opportunity oppObj = oppMap.get(comp.Related_ChI_Lead__c);
    
            if(Trigger.isInsert){
                if(oppObj.compensation_Amount__c == null)
                    oppObj.compensation_Amount__c =0;
                oppObj.compensation_Amount__c = oppObj.compensation_Amount__c + comp.Value_Compensated__c; 
                oppUpdate.add(oppObj);
            }else{
                if(Trigger.old[count].Value_Compensated__c != null && comp.Value_Compensated__c != Trigger.old[count].Value_Compensated__c){ 
                 if(oppObj.compensation_Amount__c == null)
                        oppObj.compensation_Amount__c =0;               
                    oppObj.Compensation_Amount__c = oppObj.Compensation_Amount__c+comp.Value_Compensated__c - Trigger.old[count].Value_Compensated__c ;
                    oppUpdate.add(oppObj);
                } 
            }   
        }
        try{
            update oppUpdate ;
        }catch(DMLException e){
            System.debug('@ EXCEPTION @'+e.getMessage());
        }
     }        
}