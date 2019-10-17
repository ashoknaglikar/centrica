global without sharing class UnavailabilityDelete {
    
    //this delete is done with a custom button rather than a standard delete button to
    //restrict the users ability to delete Diary_Entry__c objects to Unavailability
    //only
    
    //some constants
    public static String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    webservice static void deleteUnav(Id unavId)
    {
        Diary_Entry__c unavDiary = [select Id, RecordTypeId ,d.Type__c, d.Start__c,Unavailability_Notes__c,Authoriser__c, 
                                 d.End__c, d.Employee__c,d.Employee_Salesforce1_ID__c,(Select id from Unavailability_History_Trackers__r), Removal_Reason__c,Amendment_Reason__c  from Diary_Entry__c d
                                where Id = : unavId];
                    
        // Retrieve the Unavailability records against the Employee
        Unavailability__c[] unAvail = [select id, u.Start_Date_Time__c, u.Remove_Unavailability__c, u.Quote_number__c, Unavailability_Notes__c,Amendment_Reason__c,
                                u.Opportunity__c, u.End_Date_Time__c, u.Employee__c, u.Employee_Salesforce_ID__c From Unavailability__c u
                                where 
                                      Start_Date_Time__c >= : unavDiary.Start__c and
                                      End_Date_Time__c <=: unavDiary.End__c and
                                      Employee_Salesforce_ID__c = : unavDiary.Employee_Salesforce1_ID__c
                                      and Unavailability_Reason__c = 'Survey Booking']; 
                                      
        //System.debug('unAvailability name'+unAvail[0].id);

        if(unavDiary.RecordTypeId == ENTRY_RECTYPE_UNAVAIL)
        {  
            if(unAvail != null && unAvail.size() > 0){
                try{
                    for( Unavailability__c unAv : unAvail){    //PRB00024517 fix starts
                    System.debug('unAvailability Id before'+unAv.id);
                    
                        if(!unAv.Remove_Unavailability__c == true){
                        
                        System.debug('unAvailability Id after'+unAv.id);
                              unAv.Remove_Unavailability__c = true;
                               update unAv;
                              
                               }
                         }                                    //PRB00024517 fix ends
                  }
                catch(DMLException e){
                    System.debug('----EXCEPTION ----'+e);
                  }
                }      
            delete unavDiary;
            UnavailabilityHistoryHelper uht = new UnavailabilityHistoryHelper();
            
            List<Diary_Entry__c> de_list= new List<Diary_Entry__c>(); 
            
            if(unavDiary.Unavailability_History_Trackers__r.size() > 0 && unavDiary.Unavailability_History_Trackers__r[0].id!=null)
            {
               //uht.Removeunavailabilty(new list<id>{unavDiary.Unavailability_History_Trackers__r[0].id}, list<Diary_Entry__c> de_List);
           
               de_list.add(unavDiary);
               uht.Removeunavailabilty(de_List);
               
              
            }
        
        }
     
        else
        {
            throw new UnavailabilityDeleteException('Unable to delete Diary Entry as it is not of type \'Unavailability\'');
        }
        
    }

    public class UnavailabilityDeleteException extends Exception{}
}