trigger updateIncompleteCommisionRptCount on Commissioning_Report__c (after insert,after update, before update) 
{
    
    // ++ Added Priority Installations CR start
    Map<Id,String> customerBoilerWorkingInfoMap = new Map<Id,String>();
    List<Opportunity> oppListForBoilerWorking = new List<Opportunity>();
    map<string, string> cocStatusMap = new Map<string, string>();
    map<Id, String> CocStatus = new map<id, string>();

    Id gasCommReportRecordTypeId = null;
    // ++ Added Priority Installations CR end
    
if(Trigger.isafter && Trigger.isupdate)
 {
    for(Integer i =0; i < Trigger.new.size(); i++)
     {
       
       if(Trigger.new[i].RecordTypeName__c.contains('Gas'))
      {
            

        if(Trigger.new[i].Status__c == 'Completed' && Trigger.old[i].Status__c != 'Completed')
        {
            if(Trigger.new[i].GD_Claims_of_conformity__c !=null)
                {
                    system.debug('@@@@@Trigger.new[i].GD_Claims_of_conformity__c '+ Trigger.new[i].GD_Claims_of_conformity__c);
                    
                    if(Trigger.new[i].GD_Claims_of_conformity__c == 'Completed- Electronically' || Trigger.new[i].GD_Claims_of_conformity__c == 'Completed- Manual Sent to office' || Trigger.new[i].GD_Claims_of_conformity__c == 'Yes')
                    {
                        string oppid = Trigger.new[i].CHILeadId__c;  
                        integer len = oppid.length();
                        if(len == 18)
                        oppid = oppid.substring(0,15);
                        cocStatusMap.put(oppid , 'Yes');

                    }else
                    {
                        cocStatusMap.put(Trigger.new[i].CHILeadId__c , 'No');
                    }
                }
 
        }
      }

}
      List<Green_Deal_Measures__c> updatingGDM = new List<Green_Deal_Measures__c>();
      if(cocStatusMap.keyset().size()>0)
      {
        for(Green_Deal_Measures__c gdm : [select id, COCRecieved__c , CHILeadId__c from Green_Deal_Measures__c where CHILeadId__c in :cocStatusMap.keyset() and Recommended_measure__c = 'Condensing Boilers'])
        {
            gdm.COCRecieved__c = cocStatusMap.get(gdm.CHILeadId__c);
            updatingGDM.add(gdm);
        }
        if(updatingGDM.size()>0)
        update updatingGDM;
      }  
}    
   
 if(Trigger.isUpdate)
 {
    if(trigger.isbefore)
    {
        set<Id> completedDocs = new  set<Id>();
        for(Commissioning_Report__c c: trigger.new)
        {
            Commissioning_Report__c oldCom = trigger.oldmap.get(c.Id); 
            if(oldCom.Status__c!='Completed' && c.Status__c == 'Completed' && c.COC_Required__c == 'Yes' && c.GD_Claims_of_conformity__c == 'Completed- Electronically')
            {
                completedDocs.add(c.id);
            }
        }
        set<Id> jcdWithCoc = new set<Id>();
        if(completedDocs.size()>0)
        {
            
            For(Attachment coc : [Select id,ParentId from Attachment where ParentId in : completedDocs and Name = 'Claims Of Conformity.pdf'])
            {
                jcdWithCoc.add(coc.ParentId);
            }
            for(Commissioning_Report__c c: trigger.new)
            {
                if(!jcdWithCoc.contains(c.Id))
                {
                    c.adderror('There are no Claims of Conformity document present.');
                }
            }
        }
    }
   try {
        System.debug('@cls id run @'+cls_IsRun.isJobCompletion);
        if (cls_IsRun.isJobCompletion==false) {
            cls_IsRun.setIsJobCompletion();
            Set<Id> set_JobId=new Set<Id>{};
            for (Commissioning_Report__c obj_Comm:Trigger.new){
                if ((obj_Comm.RecordTypeName__c.contains('Gas')|| obj_Comm.RecordTypeName__c == 'Electrical' || obj_Comm.RecordTypeName__c == 'System' )  
                   && (obj_Comm.Status__c=='Completed')) 
                   {
                        set_JobId.add(obj_Comm.Job_Number__c);
                        // ++ Added Priority Installations CR start
                        customerBoilerWorkingInfoMap.put(obj_Comm.Job_Number__c , obj_Comm.existing_boiler_working__c);
                        // ++ Added Priority Installations CR end
                    }
            }
            System.debug('@set_JobId @'+set_JobId);
            if (set_JobId.size()>0) {           
                List<Job__c> lst_Job =new List<Job__c>{};
                for (Job__c obj_job:[select Not_completed_commission_report__c,Id , CHI_Lead__r.Was_the_customer_s_boiler_working__c , CHI_Lead__r.CreatedDate from Job__c where Id In:set_JobId and Status__c != 'Installed']) 
                {
                    obj_Job.Not_completed_commission_report__c=0;
                    lst_Job.add(obj_Job); 
                    // ++ Added Priority Installations CR start
                    if(customerBoilerWorkingInfoMap.containsKey(obj_job.id) && (obj_job.CHI_Lead__r.CreatedDate).date() >= Date.valueOf(System.Label.Priority_Install_Release_Date))
                    {
                        obj_job.CHI_Lead__r.Was_the_customer_s_boiler_working__c = customerBoilerWorkingInfoMap.get(obj_job.id);
                        oppListForBoilerWorking.add(obj_job.CHI_Lead__r);
                    }
                    // ++ Added Priority Installations CR end          
                }
                if(lst_job.size()>0) 
                {
                    database.update(lst_Job);
                    System.debug('@successfull@');
                }
                // ++ Added Priority Installations CR start
                if(oppListForBoilerWorking.size() > 0)
                {
                    update oppListForBoilerWorking;
                }
                // ++ Added Priority Installations CR end  
            }
        }
    } catch (Exception ex) {
        System.debug('Exception  : '+ex.getMessage());
    }
 }// Added as part of customer history card change request. 
  /*else if(Trigger.isInsert)
  {
     try{
        Set<Id> set_JobId=new Set<Id>{};
        Map<Id,Id> map_JobCompDocId=new Map<Id,Id>{};
        List<Customer_history_card__c> custHistCardList = new List<Customer_history_card__c>();
            for (Commissioning_Report__c obj_Comm:Trigger.new){
                if (obj_Comm.RecordTypeName__c.contains('Gas')){
                        set_JobId.add(obj_Comm.Job_Number__c);
                        map_JobCompDocId.put(obj_Comm.Job_Number__c,obj_Comm.Id);
                    }
            }
            System.debug('@set_JobCompDocId @'+map_JobCompDocId);
            
            //Starts - Added as part of SOQL limit issue
            if(set_JobId.size()>0){ 
            for(Customer_history_card__c c : [Select Job__r.Id,Job_Completion_Document__r.Id from Customer_history_card__c where Job__c in :set_JobId]){
                c.Job_Completion_Document__c = map_JobCompDocId.get(c.Job__r.Id);
                custHistCardList.add(c);
            }
            if(custHistCardList.size()>0){
                Database.Update(custHistCardList);
            }
            }
            //Ends - Added as part of SOQL limit issue
    }catch(Exception ex){
        System.debug('Exception  : '+ex.getMessage());
    }
 }*/
 
}