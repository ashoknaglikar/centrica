public without sharing class AppointmentTriggerHelper {

    public static void processOFSMessage(map < id, Appointment__c > triggerOldMap, map < id, Appointment__c > triggerNewMap) {

        Map < Id, Appointment__c > Appointment_cMap = (Trigger.isDelete ? triggerOldMap : triggerNewMap);
        TOA2.Workforce2_RecursiveUpdateGuard.startUpdate(Appointment_cMap.keyset());
        List < TOA2__Workforce2_ActivityMessage__c > messages = new List < TOA2__Workforce2_ActivityMessage__c > ();
        list < id > oppIdList = new list < id > ();
        list < Appointment__c > potentialCandidates = new List < Appointment__c > ();
        for (Appointment__c obj: Appointment_cMap.values()) {
            try {

                if (obj.End__c.adddays(1) >= system.now() && ((obj.Type__c == 'Sales' && obj.Opportunity__c != null) || (obj.PushToOFS__c == true && triggerOldMap.get(obj.Id).PushToOFS__c == false))) {
                    oppIdList.add(obj.Opportunity__c);
                    potentialCandidates.add(obj);
                }
            } catch (Exception exc) {
                obj.addError(exc.getMessage());
            }
        }

        map < id, Appointment__c > oldMap = new map < id, Appointment__c > ();
        map < id, Appointment__c > newMap = new map < id, Appointment__c > ();


        if (oppIdList.size() > 0) {
            Map < Id, Opportunity > oppListMap = new map < Id, Opportunity > ([Select id, Product_Interest__c, Account.Sales_Subpatch__r.OFS_Start_Date__c, Account.Sales_Subpatch__r.Appointment_Source__c, Account.Sales_Subpatch__r.OFS_Bucket_Name__c from Opportunity where Id in: oppIdList and Account.Sales_Subpatch__r.Appointment_Source__c = 'OFS']);


            for (Appointment__c obj: potentialCandidates) {

                if (oppListMap.containsKey(obj.Opportunity__c)) {
                    Opportunity temp = oppListMap.get(obj.Opportunity__c);
                    TOA_Product_Interest__c toaPI = TOA_Product_Interest__c.getInstance(temp.Product_Interest__c);
                    if (((temp.Account.Sales_Subpatch__r.OFS_Start_Date__c <= obj.Start__c) || (!trigger.isinsert && triggerOldMap.containskey(obj.Id) && obj.PushToOFS__c == true && triggerOldMap.get(obj.Id).PushToOFS__c == false)) && toaPI != null && toaPI.Active__c == true) {
                    	
						Appointment__c oldRecord = (!trigger.isInsert)?triggerOldMap.get(obj.Id):null;

                        if (!trigger.isinsert && triggerOldMap.containskey(obj.Id)) {
                            oldMap.put(obj.Id, triggerOldMap.get(obj.Id));
                        }

                        if (!trigger.isdelete && triggerNewMap.containskey(obj.Id)) {
                            newMap.put(obj.Id, triggerNewMap.get(obj.Id));
                        }
                        if (!Lock.cancelStatus.containskey(obj.Id) && !trigger.isinsert && obj.Status__c == 'Cancelled' && triggerOldMap.get(obj.Id).Status__c != 'Cancelled') {
                            Lock.cancelStatus.put(obj.Id, new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c = 'A-' + obj.Id, TOA2__appt_number__c = obj.Id, TOA2__type__c = 'cancel_activity'));
                            if (Lock.idStatus.containsKey(obj.Id))
                                Lock.idStatus.remove(obj.Id);

                        } else if (!Lock.cancelStatus.containskey(obj.Id) && !Lock.idStatus.containskey(obj.Id) && 
                        			obj.Status__c != 'Cancelled' && obj.Status__c != 'Happened' && 
                        			/*
                        				trigger to controll the updates going in to OFS. Only changes to following field will create a messge.
                        				
                        				If its new appointment insert then there is no need to check.
                        			*/
                        			(trigger.isInsert || 
                        			(obj.PushToOFS__c && oldRecord.PushToOFS__c!=obj.PushToOFS__c)||
                        			oldRecord.Opportunity__c != obj.Opportunity__c ||
                        			oldRecord.Who__c != obj.Who__c||
                        			oldRecord.Assigned_To__c != obj.Assigned_To__c ||
                        			oldRecord.SLA_End__c != obj.SLA_End__c ||
                        			oldRecord.SLA_Start__c != obj.SLA_Start__c ||
                        			oldRecord.Status__c != obj.Status__c ||
                        			oldRecord.Time_Band__c != obj.Time_Band__c ||
                        			oldRecord.Visit_Type__c != obj.Visit_Type__c ||
                        			oldRecord.Type__c != obj.Type__c||
                        			oldRecord.Subpatch_Code__c != obj.Subpatch_Code__c ||
                        			oldRecord.Bring_forward_visit__c != obj.Bring_forward_visit__c ||
                        			oldRecord.SFDC_Customer_Commited_Window__c != obj.SFDC_Customer_Commited_Window__c ||
                        			oldRecord.TOA_Duration__c != obj.TOA_Duration__c ||
                        			oldRecord.TA_Notes_All__c != obj.TA_Notes_All__c ||
                        			oldRecord.Broken_Appointment_Details__c != obj.Broken_Appointment_Details__c ||
                        			oldRecord.Broken_Promise_Flag__c != obj.Broken_Promise_Flag__c ||
                        			oldRecord.Customer_Category__c != obj.Customer_Category__c ||
                        			oldRecord.Forbidden_Resource__c != obj.Forbidden_Resource__c ||
                        			oldRecord.Prefferred_Resource__c != obj.Prefferred_Resource__c ||
                        			oldRecord.Required_Resource__c != obj.Required_Resource__c 
                        			)) {

                            Lock.idStatus.put(obj.Id, new TOA2__Workforce2_ActivityMessage__c(TOA2__InternalKey__c = 'A-' + obj.Id,
                                TOA2__appt_number__c = obj.Id
                            ));
                        }

                    }
				}
            }


        }

        if (Lock.cancelStatus.size() > 0 || Lock.idStatus.size() > 0) {
            messages.addall(Lock.cancelStatus.values());
            messages.addall(Lock.idStatus.values());
            Database.upsertresult[] result = Database.upsert(messages, false);
            System.assertEquals(result.size(), messages.size());
            for (Integer i = 0, size = result.size(); i < size; ++i) {
                if (!result[i].isSuccess()) {
                    system.debug(result[i].getErrors()[0].getMessage());
                    final Id Appointment_cId = Id.valueOf(((String) messages[i].get('TOA2__InternalKey__c')).substring(2));
                    Appointment_cMap.get(Appointment_cId).addError(result[i].getErrors()[0].getMessage());
                }
            }
        }

        //TOA2.Workforce2_Ctrl.analizeLinks('Appointment__c', triggerOldMap, triggerNewMap, messages);
        TOA2.Workforce2_Ctrl.analizeLinks('Appointment__c', oldMap, newMap, messages);
        TOA2.Workforce2_RecursiveUpdateGuard.finishUpdate(Appointment_cMap.keyset());
        //TOA2.Workforce2_RecursiveUpdateGuard.finishUpdate(triggerNewMap.keySet());

    }

}