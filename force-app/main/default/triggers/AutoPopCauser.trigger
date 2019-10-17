trigger AutoPopCauser on Case (before insert,before update) {
   list<Case> casList = new List<Case>();
   Set<Id> AccIds= new Set<Id>();
   Set<Id> JobIds= new Set<Id>();
   Set<Id> OppIds = new Set<Id>();
   Map<String,String> JMap;
   Map<String,String> AMap;
   Map<String,String> OMap;
   Map<String,String> dsmMap;
  
   map<string, Map<String,String>> finalMap = new map<string, Map<String,String>>();
   map<string, string> causerDriverMap =  new map<string, string>();
   
   for(Case ca:Trigger.new){
        if((trigger.isInsert && ((!ca.No_primary_causer__c && ca.Primary_Cause__c !=null) || (!ca.No_primary_causer_2__c && ca.Primary_Cause_2__c!=null) || (!ca.No_primary_causer_3__c && ca.Primary_Cause_3__c!=null))) ||
           (trigger.isUpdate && (trigger.oldmap.get(ca.Id).Primary_Cause__c !=ca.Primary_Cause__c || trigger.oldmap.get(ca.Id).Primary_Cause_2__c !=ca.Primary_Cause_2__c || trigger.oldmap.get(ca.Id).Primary_Cause_3__c !=ca.Primary_Cause_3__c)))
        {
           
          casList.add(ca);
          if(ca.AccountId!=null)
          AccIds.add(ca.AccountId);
          
          if(ca.Job__c!=null)
          jobIds.add(ca.Job__c);
          
          
          If(ca.Opportunity__c!=null)
          oppIds.add(ca.Opportunity__c);
          
       }
   }
   AMap = new Map<String,String>();
   dsmMap = new map<string, string>();
   map<string, string> postcodeGroupMap = new map<string, string>();
   map<string,string> accountPostcodeMap = new map<string, string>();
   map<string,string> postcodeManagerMap = new map<string, string>();
   
   system.debug(LoggingLevel.INFO,'--------->'+casList);
   system.debug(LoggingLevel.INFO,'========>'+jobIds);
   if(AccIds.size()>0){
     List<Account> AQuery = [select id,name,Post_code_Sector__c ,Sales_Subpatch__c,Sales_Subpatch__r.District__c,Sales_Subpatch__r.District__r.DHMName__c,Sales_Subpatch__r.District__r.STMName__c,Sales_Subpatch__r.District__r.DHMName__r.Salesforce_User__c,Sales_Subpatch__r.District__r.STMName__r.Salesforce_User__c from Account Where Id=:Accids];
     
     for(Account  ac : AQuery)
     {
         accountPostcodeMap.put(ac.Id , ac.Post_code_Sector__c);
         postcodeGroupMap.put(ac.Post_code_Sector__c, null);
     }
     
     
     
    for(Postcode_sector__c p : [Select name, Area_Group__c from Postcode_sector__c where Name in :postcodeGroupMap.keyset() and Type__c = 'Installation' and Area_Group__c!=null] )
    {
        //if()
        postcodeGroupMap.put(p.Name, p.Area_Group__c );
        
    }
    system.debug(postcodeGroupMap);
    for(Employee__c e: [Select id, Area_Group__c, Salesforce_User__c from Employee__c where Area_Group__c in:postcodeGroupMap.values() and Area_Group__c!=null])
    {
        postcodeManagerMap.put(e.Area_Group__c,e.Salesforce_User__c);
    }
    
    
     
     if(AQuery.size()>0){
     String DHM_User='';
    // String DSM_User='';
     
        for(Account Acc: AQuery){
            
          if(Acc.Sales_Subpatch__r.District__r.DHMName__r.Salesforce_User__c!=null)
          AMap.put(Acc.Id, Acc.Sales_Subpatch__r.District__r.DHMName__r.Salesforce_User__c);
          
          if(Acc.Sales_Subpatch__r.District__r.STMName__r.Salesforce_User__c!=null)
          dsmMap.put(acc.Id, Acc.Sales_Subpatch__r.District__r.STMName__r.Salesforce_User__c);
         
          system.debug(LoggingLevel.INFO,'=====DSMMap:'+dsmMap);
          
        }      
     }
     
   }
   OMap = new Map<string,string>();
   if(OppIds.size()>0){
     List<Opportunity> oppList = [Select id,name,(select id,name,Opportunity__c,Assigned_To__c,Assigned_To__r.Salesforce_User__c,Status__c from Appointments__r where (Status__c=:'Appointed' OR Status__c=:'Happened') Order By CreatedDate Desc LIMIT 1) from Opportunity where id=:OppIds];
     if(oppList.size()>0){
       //String HSA = '';
      
         for(Opportunity opp:OppList)
            if(opp.Appointments__r!=null && opp.Appointments__r.size()>0 && opp.Appointments__r[0].Assigned_To__r.Salesforce_User__c!=null)
            OMap.put(opp.Id,opp.Appointments__r[0].Assigned_To__r.Salesforce_User__c);
           // HSA = '';
          
           system.debug(LoggingLevel.INFO,'=====DSMMap:'+OMap); 
        
    }
    
   }
   system.debug(LoggingLevel.INFO,'----=-=-=-=-=->'+OMap);
   JMap = new Map<String,String>();
   if(Jobids.size()>0){
       List<Job__c> JQuery = [select id,name,Quote__c,Quote__r.App_Assigned_To__c,District__c,District__r.DHMName__c,District__r.STMName__c,District__r.DHMName__r.salesforce_user__c,District__r.STMName__r.Salesforce_User__c,(select id,name,User__c,Diary_Entry__c,Diary_Entry__r.Job_Hours__c,Job__c,Sub_Type__c from User_Jobs__r where Sub_Type__c=:'Mechanical' ORDER BY Diary_Entry__r.Job_Hours__c DESC) from Job__c where id=:Jobids];
       system.debug(LoggingLevel.INFO,'=========JOB Q:'+JQuery);
       //String Mechanical='';
       
       for(Job__c j:Jquery){
              if(j.User_Jobs__r.size()>0 && j.User_Jobs__r[0].User__c!=null)
              Jmap.put(j.id,j.User_Jobs__r[0].User__c);
              //Mechanical = j.User_Jobs__r[0].User__c;            
              //system.debug(LoggingLevel.INFO,'------------>>>>>>>'+Mechanical);
               
              //Mechanical = '';
              
           }
   }
   system.debug(LoggingLevel.INFO,'----=-=-=-=-=->'+JMap);
   if(JMap.size()>0)
   {
       finalMap.put('MECHANICAL INSTALLER', JMap);
   }
   
   
   if(AMap.size()>0)
   {
       finalMap.put('DHM', AMap);
   }
   
   if(OMap.size()>0)
   {
       finalMap.put('HSA', OMap);
   }
   
   if(dsmMap.size()>0)
   {
       finalMap.put('DSM', dsmMap);
   }
   
   
  
   for(Case_Causer_Mappings__c  c: Case_Causer_Mappings__c.getAll().values())
   {
       causerDriverMap.put(c.Cause__c.touppercase(), c.Causer__c.touppercase());
   }
  
  if(casList.size()>0){
      for(case c:casList){
          
         if(accountPostcodeMap.containsKey(c.AccountId))
         {
             string pc = accountPostcodeMap.get(c.AccountId);
             system.debug(postcodeManagerMap);
             string groupStr  = postcodeGroupMap.containskey(pc)?postcodeGroupMap.get(pc):'';
             if(groupStr!='' && postcodeManagerMap.containskey(groupStr) )
             c.OwnerId  = postcodeManagerMap.get(groupStr);
             
             if(c.ownerId == null)
             c.OwnerId = userinfo.getUserId();
             
         }
         system.debug(loggingLevel.INFO,'----->'+finalMap+c.Primary_Cause__c.touppercase()+causerDriverMap); 
          
          c.Primary_Cause__c = c.Primary_Cause__c!=null?c.Primary_Cause__c.toupperCase():null;
          c.Primary_Cause_2__c = c.Primary_Cause_2__c!=null?c.Primary_Cause_2__c.toupperCase():null;
          c.Primary_Cause_3__c = c.Primary_Cause_3__c!=null?c.Primary_Cause_3__c.toupperCase():null;
          //system.debug(loggingLevel.INFO,'----->'+c.Primary_Cause__c+c.Primary_Cause_2__c+c.Primary_Cause_3__c);
         
          if(causerDriverMap.containsKey(c.Primary_Cause__c))
          {
              string who = causerDriverMap.get(c.Primary_Cause__c);
              system.debug(LoggingLevel.INFO,'------>'+who);
              if(finalMap.containskey(who))
              {   
                  system.debug(LoggingLevel.INFO,'------>'+finalMap.get(who));
                  map<string, string> tempString = finalMap.get(who);
                  if(tempString.containskey(c.Job__c))
                  {
                       c.Primary_Causer__c = tempString.get(c.Job__c);
                  }else if(tempString.containskey(c.AccountId))
                  {
                       c.Primary_Causer__c = tempString.get(c.AccountId);
                  }else if(tempString.containskey(c.Opportunity__c))
                  {
                       c.Primary_Causer__c = tempString.get(c.Opportunity__c);
                  }
              }
              
          }
          
          if(causerDriverMap.containsKey(c.Primary_Cause_2__c))
          {
              string who = causerDriverMap.get(c.Primary_Cause_2__c);
              system.debug(LoggingLevel.INFO,'Line 147:'+who); 
              if(finalMap.containskey(who))
              {
                  map<string, string> tempString = finalMap.get(who);
                  if(tempString.containskey(c.Job__c))
                  {
                       c.Secondary_Causer__c = tempString.get(c.Job__c);
                  }else if(tempString.containskey(c.AccountId))
                  {
                       c.Secondary_Causer__c = tempString.get(c.AccountId);
                  }else if(tempString.containskey(c.Opportunity__c))
                  {
                       c.Secondary_Causer__c = tempString.get(c.Opportunity__c);
                  }
              }
              
          }
          
          if(causerDriverMap.containsKey(c.Primary_Cause_3__c))
          {
              string who = causerDriverMap.get(c.Primary_Cause_3__c);
               
              if(finalMap.containskey(who))
              {
                  map<string, string> tempString = finalMap.get(who);
                  if(tempString.containskey(c.Job__c))
                  {
                       c.Third_causer__c = tempString.get(c.Job__c);
                  }else if(tempString.containskey(c.AccountId))
                  {
                       c.Third_causer__c = tempString.get(c.AccountId);
                  }else if(tempString.containskey(c.Opportunity__c))
                  {
                       c.Third_causer__c = tempString.get(c.Opportunity__c);
                  }
              }
              
          }
          
         
          
          /*
          
         if(Jmap!=null && Jmap.containsKey(c.Job__c)){
             String Mec_User = Jmap.get(c.Job__c);
             
                 if(c.Primary_Cause__c == 'Installation visit' && Mec_User!=''){
                 system.debug('===============================================');
                 c.Primary_Causer__c = Mec_User;
                 }
                 else if(c.Primary_Cause__c == 'Post Install/Aftercare - Installation' && Mec_User!='')
                 c.Primary_Causer__c = Mec_User ;
                 
                 
                 
                 if(c.Primary_Cause_2__c == 'Installation visit' && Mec_User!='')
                 c.Secondary_Causer__c = Mec_User ;
                 else if(c.Primary_Cause_2__c == 'Post Install/Aftercare - Installation' && Mec_User!='')
                 c.Secondary_Causer__c = Mec_User ;
                 
                 
                 
                 if(c.Primary_Cause_3__c== 'Installation visit' && Mec_User!='')
                 c.Third_causer__c = Mec_User ;
                 else if(c.Primary_Cause_3__c== 'Post Install/Aftercare - Installation' && Mec_User!='')
                 c.Third_causer__c = Mec_User ;
                 
                 
         }
         if(AMap!=null && AMap.containsKey(c.AccountId)){
           string DH_DM = AMap.get(c.AccountId);
           if(DH_DM != null && DH_DM != ''){
             string[] UpdVal = DH_DM.split(':');
             string DHM_User = string.valueof(UpdVal[0]); 
             string DSM_User = string.valueof(UpdVal[1]); 
             system.debug('==============>'+DHM_User+' '+DSM_User);
             //system.debug('232323232 '+c.Primary_Cause_3__c);
             //system.debug('123213232132312 : '+c.Primary_Causer__c);
             if(c.Primary_Cause__c == 'Installation visit - Mangement' && DHM_User!=''){
             system.debug('============>Inside Installation Visit management');             
             c.Primary_Causer__c = DHM_User;
             }
             else if(c.Primary_Cause__c == 'Sales visit - Management' && DSM_User!='')
             c.Primary_Causer__c = DSM_User;
             
             if(c.Primary_Cause_2__c == 'Installation visit - Mangement' && DHM_User!='')
             c.Secondary_Causer__c = DHM_User;
             else if(c.Primary_Cause_2__c == 'Sales visit - Management' && DSM_User!='')
             c.Secondary_Causer__c = DSM_User;
             
             if(c.Primary_Cause_3__c== 'Installation visit - Mangement' && DHM_User!='')
             c.Third_causer__c = DHM_User;
             else if(c.Primary_Cause_3__c == 'Sales visit - Management' && DSM_User!='')
             c.Third_causer__c = DSM_User;
                              
    
           }
         }
         
         if(OMap!=null && OMap.containsKey(c.Opportunity__c)){
           String HSA_User = OMap.get(c.Opportunity__c);
           system.debug('==============>'+c.Primary_Causer__c);
           if(c.Primary_Cause__c == 'Sales visit - Regulated activity' && HSA_User!='')
           c.Primary_Causer__c = HSA_User;
           else if(c.Primary_Cause__c == 'Sales visit' && HSA_User!='')
           c.Primary_Causer__c = HSA_User;
           
          if(c.Primary_Cause_2__c == 'Sales visit - Regulated activity' && HSA_User!='')
          c.Secondary_Causer__c = HSA_User;
          else if(c.Primary_Cause_2__c == 'Sales visit' && HSA_User!='')
          c.Secondary_Causer__c = HSA_User;
             
          if(c.Primary_Cause_3__c== 'Sales visit - Regulated activity' && HSA_User!='')
          c.Third_causer__c = HSA_User;
          else if(c.Primary_Cause_3__c== 'Sales visit' && HSA_User!='')
          c.Third_causer__c = HSA_User;
         
         }*/
         
         
      }     
    } 
     
}