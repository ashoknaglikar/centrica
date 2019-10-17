trigger Workforce2_CreateActivityMessageForAppointment_c on Appointment__c (after insert, after update, before delete){
   
     
     if(TOA2.Workforce2_Ctrl.fromExternalSystem()|| cls_IsRun.appointmentSwitch || IV_Vectors__c.getInstance('ETAWorkforce_Switch').Key__c != 'on') return;
     
     /*
        Logic moved to AppointmentTriggerHelper on 22/02/2017.
        
     */
     
     AppointmentTriggerHelper.processOFSMessage(trigger.oldMap, trigger.newMap);
    
     /*
     Map<Id,Appointment__c> Appointment_cMap=(Trigger.isDelete?Trigger.oldMap:Trigger.newMap);
     TOA2.Workforce2_RecursiveUpdateGuard.startUpdate(Appointment_cMap.keyset());
     List<TOA2__Workforce2_ActivityMessage__c> messages = new List<TOA2__Workforce2_ActivityMessage__c>();
     list<id> oppIdList  = new list<id>();
     list<Appointment__c> potentialCandidates = new List<Appointment__c>();
     for (Appointment__c obj : Appointment_cMap.values())
     {
         try{
               
               if(obj.End__c.adddays(1)>= system.now() && ((obj.Type__c == 'Sales' && obj.Opportunity__c != null )|| (obj.PushToOFS__c == true && trigger.oldmap.get(obj.Id).PushToOFS__c==false )))
                {
                    oppIdList.add(obj.Opportunity__c);   
                    potentialCandidates.add(obj);
                    
                }            
                
                                                                        
             }catch(Exception exc){
                 obj.addError(exc.getMessage());
             }
     }
     
     map<id, Appointment__c> oldMap = new map<id, Appointment__c>();
     map<id, Appointment__c> newMap = new map<id, Appointment__c>();
     
     
     if(oppIdList.size()>0)
     {
        Map<Id , Opportunity> oppListMap = new map<Id , Opportunity>([Select id,Product_Interest__c, Account.Sales_Subpatch__r.OFS_Start_Date__c,  Account.Sales_Subpatch__r.Appointment_Source__c, Account.Sales_Subpatch__r.OFS_Bucket_Name__c  from  Opportunity where Id in : oppIdList and Account.Sales_Subpatch__r.Appointment_Source__c  = 'OFS']);
        

        for (Appointment__c obj : potentialCandidates)
        {
            
            if(oppListMap.containsKey(obj.Opportunity__c))
            {
                Opportunity temp =  oppListMap.get(obj.Opportunity__c);
                TOA_Product_Interest__c toaPI = TOA_Product_Interest__c.getInstance(temp.Product_Interest__c);
                if(((temp.Account.Sales_Subpatch__r.OFS_Start_Date__c<=obj.Start__c) || (!trigger.isinsert && trigger.oldmap.containskey(obj.Id) && obj.PushToOFS__c == true && trigger.oldmap.get(obj.Id).PushToOFS__c==false ))&& toaPI != null && toaPI.Active__c == true )
                {
                    
                    
                    if(!trigger.isinsert && trigger.oldmap.containskey(obj.Id))
                    {
                        oldMap.put(obj.Id,trigger.oldmap.get(obj.Id));
                    }
                    
                    if(!trigger.isdelete && trigger.newmap.containskey(obj.Id))
                    {
                        newMap.put(obj.Id,trigger.newmap.get(obj.Id));
                    }
                    if(!Lock.cancelStatus.containskey(obj.Id)  && !trigger.isinsert  && obj.Status__c == 'Cancelled' && trigger.oldmap.get(obj.Id).Status__c != 'Cancelled')
                    {
                        //messages.add(new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+obj.Id,TOA2__appt_number__c=obj.Id,TOA2__type__c='cancel_activity'));
                        Lock.cancelStatus.put(obj.Id, new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+obj.Id,TOA2__appt_number__c=obj.Id,TOA2__type__c='cancel_activity'));
                        if(Lock.idStatus.containsKey(obj.Id))
                        Lock.idStatus.remove(obj.Id);
                        
                    }else if( !Lock.cancelStatus.containskey(obj.Id) && !Lock.idStatus.containskey(obj.Id) && obj.Status__c  != 'Cancelled' && obj.Status__c !='Happened')
                    {
                        /*messages.add(new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+obj.Id,
                                                                                     TOA2__appt_number__c=obj.Id
                                                                             ));*/
                       /*Lock.idStatus.put(obj.Id, new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c='A-'+obj.Id,
                                                                                     TOA2__appt_number__c=obj.Id
                                                                                ));                                                         
                    }
                    
                }
                
                
            }
        }
        
        
     } 
     
     if(Lock.cancelStatus.size()>0|| Lock.idStatus.size()>0)
     {
         messages.addall(Lock.cancelStatus.values());
         messages.addall(Lock.idStatus.values());
         Database.upsertresult[] result=Database.upsert(messages,false);
         System.assertEquals(result.size(),messages.size());
         for(Integer i=0,size=result.size();i<size;++i){
             if(!result[i].isSuccess()) 
             {
                 system.debug(result[i].getErrors()[0].getMessage());
                 final Id Appointment_cId=Id.valueOf(((String)messages[i].get('TOA2__InternalKey__c')).substring(2));
                 Appointment_cMap.get(Appointment_cId).addError(result[i].getErrors()[0].getMessage());
             }
         }
     }
     //TOA2.Workforce2_Ctrl.analizeLinks('Appointment__c', Trigger.oldMap, Trigger.newMap, messages);
     TOA2.Workforce2_Ctrl.analizeLinks('Appointment__c', oldMap, newMap, messages);
     TOA2.Workforce2_RecursiveUpdateGuard.finishUpdate(Appointment_cMap.keyset());
     
     //TOA2.Workforce2_RecursiveUpdateGuard.finishUpdate(Trigger.newMap.keySet());*/
 }