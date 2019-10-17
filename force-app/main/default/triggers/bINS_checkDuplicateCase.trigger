trigger bINS_checkDuplicateCase on Case (before insert){
    Map<string,List<case>> recTypeMap = new Map<string,List<case>>();
    Set<String> accIdSet = new Set<String>();
    
    
    for(Case cases : Trigger.new){
        if(cases.RecordTypeId != system.label.ASPCase)
        {
            accIdSet.add(cases.Accountid);
            if(recTypeMap.containsKey(cases.recordtypeid)){
                List<case> casesList = recTypeMap.get(cases.RecordTypeId);
                casesList.add(cases);
                recTypeMap.put(cases.RecordTypeId,casesList);
            }else{
                 List<case> casesList = new  List<case>();
                 casesList.add(cases);
                 recTypeMap.put(cases.RecordTypeId,casesList);
            }
        }
    }

/*    
    Case[] existingCases = [select id,isClosed,RecordTypeId,AccountId   from case where RecordTypeId in :recTypeMap.keySet() and AccountId in : accIdSet and isClosed = false];
    if(existingCases.size() > 0){
        for(Case cases : existingCases ){
            List<case> newCase = recTypeMap.get(cases.RecordTypeId);
            for(Case c : newCase){
                if(c.RecordTypeId == cases.RecordTypeId  && c.AccountId == cases.AccountId){
                    c.addError('Cannot add more than one open cases of same record type.');
                }
            }
        }    
    }
*/    
}