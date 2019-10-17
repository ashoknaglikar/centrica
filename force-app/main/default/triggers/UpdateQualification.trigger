trigger UpdateQualification on P5_RMT_Contractors__c (after Update) {
 
  list<id> contIds = new list<id>();
  list<id> contIds1 = new list<id>();
  list<P5_Qualification__c> qualifications;
  if(Trigger.isUpdate && Trigger.isAfter){
    for (P5_RMT_Contractors__c  contractor : trigger.new)
    {
        P5_RMT_Contractors__c oldCont = trigger.oldmap.get(contractor.id); 
        P5_RMT_Contractors__c newCont = trigger.newmap.get(contractor.id);
       
        //Where the RMT Supplier is made inactive
        if ((oldCont.P5_Status__c <> newCont.P5_Status__c) && newCont.P5_Status__c == 'Inactive')
         contIds.add(newCont.id);
         
        //if ((oldCont.P5_Status__c <> newCont.P5_Status__c) && newCont.P5_Status__c == 'Active')
        // contIds1.add(newCont.id);
        
    }
    if(contIds.size()>0)
    qualifications = [select id,Contractor__c from P5_Qualification__c where contractor__c=:contIds];
    
   // if(contIds1.size()>0){
    //qualifications = [select id,Contractor__c from P5_Qualification__c where Contractor__c=:contIds1];
    
    if(qualifications != null)
    update qualifications;

  }
}