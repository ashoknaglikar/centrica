/**
Type Name: aUPD_Case_SendSecondNPSEmail
Author: Cognizant
Created Date: 21/04/2010
Reason: To update Second_NPS_Email_Sent__c field of the NPS and trigger a
        workflow to send secondary NPS survey email.
Change History:
*/

trigger aUPD_Case_SendSecondNPSEmail on Case (after update) {
    //Variable declarations section.
    List<NPS__c> lstNps = new List<NPS__c>();
    List<Id> lstNpsObjectId = new List<String>();
    Id detractorCaseRecordTypeId = null;
    List<NPS__c> npsObjList = new List<NPS__c>();
    List<NPS__c> lstNPSToBeUpdated = new List<NPS__c>();

    //Retrieving Recordtype Id of 'Detractor Case' record type.  
    detractorCaseRecordTypeId = [Select r.Name, r.Id From RecordType r where 
    r.Name='Detractor' and SobjectType = 'Case' limit 1].Id;
    
    //Retrieving all the cases of type Detractor and have NPS record related to it.
    for(Integer i = 0; i < Trigger.new.size(); i++)
    {
        System.debug('#### case old status: ' +Trigger.old[i].Status); 
        System.debug('#### case new status: ' +Trigger.new[i].Status); 
        System.debug('#### Trigger.new[i].RecordTypeID == detractorCaseRecordTypeId--: '
        +Trigger.new[i].RecordTypeID +'==='+ detractorCaseRecordTypeId);
        
        System.debug('---Trigger.old[i].IsClosed--' + Trigger.old[i].IsClosed + 
        '---Trigger.new[i].IsClosed---' + Trigger.new[i].IsClosed +
        '---Trigger.new[i].Send_Secondary_Card__c--' +
        Trigger.new[i].Send_Secondary_Card__c +
        '---Trigger.old[i].Send_Secondary_Card__c--' +
        Trigger.old[i].Send_Secondary_Card__c +
        '----Trigger.old[i].RecordTypeID == detractorCaseRecordTypeId--' +
        Trigger.old[i].RecordTypeID + detractorCaseRecordTypeId);
        
        /**
        Previous condition of checking Status  = 'Resolved' is now changed to 
        checking for IsClosed  = true'.
        */    
        if((Trigger.new[i].IsClosed) && 
            (Trigger.new[i].Send_Secondary_Card__c == true) &&
            (Trigger.old[i].RecordTypeID == detractorCaseRecordTypeId))
        {   
            Id npsObjectId = Trigger.new[i].NPS__c;
            lstNpsObjectId.add(npsObjectId);
        }
    }
    System.debug('#### lstNpsObjectId: ' +lstNpsObjectId); 
    
    //Retrieving NPS object for which the case is updated and set to closed.
    for(NPS__c npsObject : [select Id, Second_NPS_Email_Sent__c,
    DontUpdateNpsManually__c, Preferred_Contact_Method__c from NPS__c 
    where id in : lstNpsObjectId])
    {
        /**
        For the case, which is to be closed, if Preferred contact method is
        Email,        then set 'Second_NPS_Email_Sent__c' = true which will trigger the
        second workflow and Email will be sent for second NPS survey.
        */   
             
        if(npsObject.Preferred_Contact_Method__c == 'Email')
        {
            npsObject.Second_NPS_Email_Sent__c = true;
            npsObject.DontUpdateNpsManually__c = true;
            lstNPSToBeUpdated.Add(npsObject);
        }
    }
    
    /**
    Updating all NPS records if they satisfy the criteria for sending
    secondory email.
    */
    if(lstNPSToBeUpdated.size() > 0)
    {
        try
        {
            update lstNPSToBeUpdated;
        }
        catch(Exception e)
        {
            System.debug('Exception while updating NPS through trigger: ' + e);
        }
        
    }

}