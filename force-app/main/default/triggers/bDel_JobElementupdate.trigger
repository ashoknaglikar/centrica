trigger bDel_JobElementupdate on Appointment__c (before delete) {
Map<String,Appointment__c> elementMap = new Map<String,Appointment__c>();
Set<Id> elementid = new Set<Id>();
    String itiRTID = RecordTypeIdHelper.getRecordTypeId('Appointment__c', 'Itinerary');
    for(Appointment__c app : Trigger.old){
        if(app.Job_Element__c != null && app.RecordTypeId == itiRTID){
            elementMap.put(app.Job_Element__c,app);
            elementid.add(app.Job_Element__c);
           }
    }
    if(elementMap.size() > 0){
        List<Job_ELement__c> eleList = [select id,Job__c,Type__c,code__c,Start_Date__c, Completion_Date__c From Job_Element__c where id in :elementid];
        system.debug('eleList--------->'+eleList); 
        Set<String> jobIds = new Set<String>();
        Map<String,String> jeCodesMap = new Map<String,String>();
        Set<String> codes = new Set<String>();
        for(Job_ELement__c je : eleList){           
            jobIds.add(je.Job__c);
            codes.add(je.code__c);
            jeCodesMap.put(je.code__c,je.id);
        }
        BookItineraryApp.updateelementsAppdeleteFuture(jobIds,codes);
       
        }
    }