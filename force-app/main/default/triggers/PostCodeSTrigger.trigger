trigger PostCodeSTrigger on Postcode_Sector__c (before delete ,after insert,after update, before update) {

   //This is code to restrict users(other than administrators ) from post code sector deletion 
   if (Trigger.isBefore && Trigger.isDelete){
   
      No_Triggers__c notrigger = No_Triggers__c.getInstance(UserInfo.getUserId());
      
        for(Postcode_Sector__c inc:Trigger.Old){
        if (notrigger != null && !notrigger.Flag__c)
        {
           inc.adderror('You do not have permission to delete post code sector');
        }
        else if(notrigger == null){
           inc.adderror('You do not have permission to delete post code sector');
        
         }
      }
      
   }
   set<id> subpatchid = new set<Id>();
   
   if(trigger.isAfter){
   
    if(trigger.IsInsert){
        
         for(Postcode_Sector__c pCSector : Trigger.New){
            
             if(pCSector.name!=null && pCSector.Type__c=='Sales'){
                  subpatchid.add(pCSector.Sub_Patch__c);
             }
        
        }
    }else if(trigger.isUpdate){
        
        for(Postcode_Sector__c pCSector : Trigger.New){
            Postcode_Sector__c oldRecord  = trigger.OldMap.get(pCSector.Id);
             if(pCSector.name!=null && ((pCSector.Type__c=='Sales' && oldRecord.Type__c != 'Sales') || 
               (pCSector.Name != oldRecord.Name  && pCSector.Type__c=='Sales' )|| 
               (pCSector.Type__c!='Sales' && oldRecord.Type__c == 'Sales') || 
               (pCSector.Sub_Patch__c != oldRecord.Sub_Patch__c))){
                  subpatchid.add(pCSector.Sub_Patch__c);
             }
             
            
        }
    }
    
   }else if(trigger.isupdate)
   {
    for(Postcode_Sector__c pCSector : Trigger.New)
    {
         Postcode_Sector__c oldRecord  = trigger.OldMap.get(pCSector.Id);
         if(pCSector.Type__c == 'Sales' && pCSector.Old_Subpatch__c == null && pCSector.Sub_Patch__c != oldRecord.Sub_Patch__c )
         {
            pCSector.Old_Subpatch__c=oldRecord.Sub_Patch__c;
            subpatchid.add(oldRecord.Sub_Patch__c);
         }
    }
   }
   
   list<Sub_Patch__c> updateList = new list<Sub_Patch__c>();
   for(id i : subpatchid)
   {
        updateList.add(new Sub_Patch__c(id = i, OFS_WZ_Status__c = 'Ready To Be Picked Up', OFS_WZ_Sub_Status__c = 'Updated'));
   }
   //This code to update status and sub status of post code sector record whenever its created/updated
   if(updateList.size()>0)
   update updateList;
/*   
    if (Trigger.isbefore && Trigger.isinsert){
        for(Postcode_Sector__c pCSector : Trigger.New){
            
             if(pCSector.name!=null && pCSector.Type__c=='Sales'){
                  //pCSector.OFS_Keys_Status__c='Ready To Be picked Up';
                  //pCSector.OFS_Keys_Sub_Status__c='Created';
                  subpatchid.add(pCSector.Sub_Patch__c);
             }
        }
   
     }
     
     
   
    if (Trigger.isbefore && Trigger.isupdate){
        for(Postcode_Sector__c pCSector : Trigger.New){
             Postcode_Sector__c oldpCSector  = Trigger.oldMap.get(pCSector.Id);
             
             if(pCSector.name!=null && pCSector.name!=oldpCSector.name && pCSector.Type__c=='Sales'  && ((oldpCSector.OFS_Keys_Sub_Status__c=='Created' && oldpCSector.OFS_Keys_Status__c=='Completed')|| (oldpCSector.OFS_Keys_Sub_Status__c=='PCS name updated' && oldpCSector.OFS_Keys_Status__c=='Completed'))){
                  pCSector.OFS_Keys_Status__c='Ready To Be Picked Up';
                  pCSector.OFS_Keys_Sub_Status__c ='PCS name updated';
                  pCSector.Old_PostCodeSector__c=oldpCSector.name;
             }
             if(pCSector.Sub_Patch__c!=null && pCSector.Sub_Patch__c!=oldpCSector.Sub_Patch__c && pCSector.Type__c=='Sales')
             {
                  pCSector.OFS_Keys_Status__c='Ready To Be Picked Up';
                  pCSector.OFS_Keys_Sub_Status__c='PCS sub patch updated';
                   system.debug('*oldpCSector.Sub_Patch__r.name'+oldpCSector.Sub_Patch__r.name);
                    system.debug('*oldpCSector.Sub_Patch__c'+oldpCSector.Sub_Patch__c);
                    if(oldpCSector.Sub_Patch__c !=null){
                    pCSector.Old_Subpatch__c=[select id,name from sub_patch__c where id=:oldpCSector.Sub_Patch__c limit 1].name;
                 
                    }  
                  
            }
            //  sub_patch__c  subPatch=[select id,name from sub_patch__c where id=:pCSector.Sub_Patch__c limit 1];
                 //   subPatch.OFS_WZ_Status__c='Ready To Be Picked Up';
                    //update subPatch;
        }
   
     }
     */
}