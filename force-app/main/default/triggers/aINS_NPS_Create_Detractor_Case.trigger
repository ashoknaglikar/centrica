/*
Type Name: aINS_NPS_Create_Detractor_Case
Author: Cognizant
Change Date: 23/04/2010
Reason: To create detractor case if score is less than or eqaul to 6
Change History: Modified this trigger for fixing bulk data loader testing on NPS.

*/

trigger aINS_NPS_Create_Detractor_Case on NPS__c (after insert) 
{
    List<Case> lstCases = new List<Case>();
    List<Id> lstNpsId = new List<Id>();
    Map<Id,NPS__c> mapIdNps = new Map<Id,NPS__c>();
    System.debug('STEP 1: inside trigger aINS_NPS_Create_Detractor_Case...');
    
    try
    {
        //Retrieve id of detractor record type 
        ID DetractorRecordTypeId = [select Id from RecordType where Name = 'Detractor' 
        and SobjectType = 'Case'].Id;
        
        System.debug('STEP 2: inside trigger: DetractorRecordTypeId: '+DetractorRecordTypeId);
        for(Integer i=0; i < Trigger.new.size(); i++)
        {
           lstNpsId.add(Trigger.new[i].Id);
        }
        list<Opportunity> oppLst = new list<Opportunity>();
        System.debug('STEP 3: inside trigger: lstNpsId: '+lstNpsId);
        
        for(NPS__c npsRecord : [Select n.Step1_Score__c, n.Step1_Comments__c, 
        n.Preferred_Contact_Method__c, n.Contact__c, n.Contact_Email__c, 
        n.Account__r.Primary_Contact_Last_Name__c, n.Account__r.Primary_Contact_First_Name__c,
        n.Account__r.Primary_Contact_Salutation__c, n.Account__r.Primary_Contact__c,Opportunity__c,Opportunity__r.OnlineNPSRecievedDate__c,
        n.Account__c From NPS__c n where n.Id in : lstNpsId])
        {
        	if(npsRecord.Opportunity__r.OnlineNPSRecievedDate__c == null)
        	{        	
	        	Opportunity o = new Opportunity(Id =npsRecord.Opportunity__c, OnlineNPSRecievedDate__c=system.today());
	        	oppLst.add(o);
        	}
        	
            mapIdNps.put(npsRecord.Id,npsRecord);
        }
        
        System.debug('STEP 4: inside trigger: mapIdNps: '+mapIdNps);
        
        for(Integer i=0; i < Trigger.new.size(); i++)
        {
            //If Survey feedback check on NPS <= 6 trigger a detractor case
            if(Trigger.new[i].Step1_Score__c <= -1)
            {
                //Create a new Detractor case
                System.debug('STEP 5: inside trigger: getting into create case of trigger...');
                Case newCase = new Case();
                
                newCase.AccountId = (mapIdNps.get(Trigger.new[i].Id)).Account__c;
                newCase.Opportunity__c = (mapIdNps.get(Trigger.new[i].Id)).Opportunity__c;
                newCase.Origin = 'Web';
                newCase.Reason = 'New problem';
                newCase.Type = 'Customer Satisfaction Survey';
                newCase.Status = 'New';
                newCase.Priority = 'Medium';
                newCase.Case_Source__c = 'Customer';
                
                System.debug('STEP 6: inside trigger: newCase.Preferred_Contact__c: '+newCase.Preferred_Contact__c);
                newCase.Preferred_Contact__c = 'Primary';
                System.debug('STEP 7: inside trigger: newCase.Preferred_Contact__c: '+newCase.Preferred_Contact__c);
                newCase.OwnerId = UserInfo.getUserId();
                
                NPS__c npsRec = mapIdNps.get(Trigger.new[i].Id);
                newCase.ContactId = npsRec.Account__r.Primary_Contact__c;
                System.debug('----------------------- newCase.ContactId: '+newCase.ContactId);
                newCase.NPS_Score__c = (mapIdNps.get(Trigger.new[i].Id)).Step1_Score__c;
                newCase.NPS_Response__c = (mapIdNps.get(Trigger.new[i].Id)).Step1_Comments__c;
                
                newCase.NPS__c = Trigger.new[i].ID;
                newCase.RecordTypeId = DetractorRecordTypeId;
                newCase.NPS_Contact_Email__c = Trigger.new[i].Contact_Email__c;
                lstCases.Add(newCase);
                System.debug('STEP 8: inside trigger: lstCases: '+lstCases);
            }    
        }
        
        //insert detractor cases;
        if(lstCases != null && lstCases.size() > 0)
        {
            //insert lstCases;
            System.debug('STEP 9: inside trigger: before insert lstCases: '+lstCases);
            Database.insert(lstCases,false);
            System.debug('STEP 10: inside trigger: after insert lstCases: '+lstCases);
        }
        if(oppLst.size()>0)
        {
        	update oppLst;
        }    
    }

    catch(Exception e)
    {
        System.debug('Unable to insert cases: error occured due to validation rule: '+e);
    }

}