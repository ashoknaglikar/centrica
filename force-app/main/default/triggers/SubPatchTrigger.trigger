//This is trigger to catch events on sub patch object
trigger SubPatchTrigger on Sub_Patch__c (before delete,before insert,before update) {

   //This is code to restrict users(other than administrators ) from sub patch records deletion 
   if (Trigger.isBefore && Trigger.isDelete){
   
      No_Triggers__c notrigger = No_Triggers__c.getInstance(UserInfo.getUserId());
      for(Sub_Patch__c inc:Trigger.Old){
          if (notrigger != null && !notrigger.Flag__c)
          {
            inc.adderror('You do not have permission to delete sub patch');
          }
          else if(notrigger == null)
          {
            inc.adderror('You do not have permission to delete sub patch');
          }
         } 
    }
    
    if (Trigger.isBefore && Trigger.isinsert){
        for(Sub_Patch__c sPatch : Trigger.New){
            
             if(sPatch.name!=null && sPatch.Type__c=='Sales'){
                  sPatch.OFS_WZ_Status__c='Ready To Be Picked Up';
                  sPatch.OFS_WZ_Sub_Status__c='Created';
             }
        }
   
     }
    
     if (Trigger.isbefore && Trigger.isupdate){
        for(Sub_Patch__c sPatch : Trigger.New){
             Sub_Patch__c oldSPatch = Trigger.oldMap.get(sPatch.Id);
             
             if(sPatch.name!=null && sPatch.Type__c=='Sales' && (sPatch.name!=oldSPatch.name   || sPatch.Type__c !=oldSPatch.Type__c ||sPatch.District__c != oldSPatch.District__c)  ){
                  sPatch.OFS_WZ_Status__c='Ready To Be Picked Up';
                  sPatch.OFS_WZ_Sub_Status__c='Updated';
                  sPatch.Old_Subpatch_OFS__c=oldSPatch.name;
             }
             system.debug('*sPatch.Type__c'+sPatch.Type__c);
             if(sPatch.Type__c!='Sales' && oldSPatch.Type__c=='Sales' ){
                  sPatch.OFS_WZ_Status__c='Ready To Be Picked Up';
                  sPatch.OFS_WZ_Sub_Status__c='Deactivated';
                  system.debug('*sPatch'+ sPatch.OFS_WZ_Status__c+sPatch.OFS_WZ_Sub_Status__c);
                 
             }
        }
   
     }
    
 }