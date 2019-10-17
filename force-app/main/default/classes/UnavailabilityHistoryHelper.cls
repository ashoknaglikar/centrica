public class UnavailabilityHistoryHelper  {

    list<Unavailability_History_Tracker__c> HistoryTrackerList;
   
    //list<Unavailability_History_Child_Record__c> childrecordList;
  
 public void Createhistoryrecords(List<Diary_Entry__c> de_list){
 //list<Unavailability_History_Tracker__c>
    
    HistoryTrackerList = new list<Unavailability_History_Tracker__c> ();
    
    for(Diary_Entry__c ed:de_list)
    
 {
    if(ed.Create_History__c)
    {
        Unavailability_History_Tracker__c HistoryTracker = new Unavailability_History_Tracker__c ();
        HistoryTracker.CHI_Lead_Number__c = ed.CHI_Lead_Number__c;
        HistoryTracker.Employee__c = ed.Employee_ID__c;
        HistoryTracker.End__c = ed.End__c;
        HistoryTracker.Hours__c = ed.Hours__c;
        HistoryTracker.Start__c = ed.Start__c;
        HistoryTracker.Sub_Type__c = ed.Sub_Type__c;
        HistoryTracker.Type__c = ed.Primary_Type__c;
        HistoryTracker.Unavailability_Notes__c = ed.Unavailability_Notes__c;
        //HistoryTracker.Unavailability_Reason__c = ed.Unavailability_Notes__c;
        HistoryTracker.Diary_Entry__c = ed.Id;
        HistoryTracker.Week__c = ed.Week__c;
       
        //system.debug('****History Record***'+HistoryTracker);
        HistoryTrackerList.add(HistoryTracker);
    }
    
 }
 if(HistoryTrackerList.size()>0)
   
   {
     insert HistoryTrackerList;
     
   
   }
    
 }
 public void Createhistorychildrecords(List<Diary_Entry__c> de_list, string HistoryRecordId){
 
 //childrecordList= new list<Unavailability_History_Child_Record__c> ();
     HistoryTrackerList = new list<Unavailability_History_Tracker__c> ();
    for(Diary_Entry__c ed:de_list)
    
    {
          Unavailability_History_Tracker__c HistoryTracker = new Unavailability_History_Tracker__c (Id = HistoryRecordId, 
                                                                Diary_Entry__c = ed.Id,
                                                                Type__c = ed.Primary_Type__c, 
                                                                Sub_Type__c = ed.Sub_Type__c,
                                                                Unavailability_Notes__c = ed.Unavailability_Notes__c,
                                                                Start__c = ed.Start__c,
                                                                End__c = ed.End__c,
                                                                Hours__c = ed.Hours__c, 
                                                                CHI_Lead_Number__c=ed.CHI_Lead_Number__c, 
                                                                Amendment_Reason__c = ed.Amendment_Reason__c);
          HistoryTrackerList.add(HistoryTracker);
          
          
         
   }
   if(HistoryTrackerList.size()>0)
   {
    update HistoryTrackerList;
   }
 
   
 }
 public void Removeunavailabilty(list<Diary_Entry__c> de_List){
     HistoryTrackerList = new list<Unavailability_History_Tracker__c> ();
  
  system.debug('de_List-->'+de_List);  
  
 for(Diary_Entry__c d:de_List)
 {
  Unavailability_History_Tracker__c HistoryTracker = new Unavailability_History_Tracker__c(Id = d.Unavailability_History_Trackers__r[0].Id);
  HistoryTracker.Unavailability_Notes__c =d.Unavailability_Notes__c;
  HistoryTracker.Amendment_Reason__c =d.Amendment_Reason__c;
  HistoryTracker.Removal_Reason__c =d.Authoriser__c;
  HistoryTracker.Removed_By__c =UserInfo.getName();
  HistoryTracker.Removed_Time__c =system.now();
  HistoryTracker.Removed__c =true;
  
  HistoryTrackerList.add(HistoryTracker);

 }
  if(HistoryTrackerList.size()>0)
 update HistoryTrackerList;
 }
 
 
 
}