/*
     This class is used for creating unavailability for pool as well as non-pool employees.
     This class is invoked when we click on create unavailability button on Unavailability details page.
*/

global class CreateUnavailability {
    
    public static List<Diary_Entry__c> unAvailabilities = new List<Diary_Entry__c>();
    public static String poolDiariesMessage = '';
    public static Savepoint  sp;
    public static boolean stackableUnavailability = false;
    public static boolean redirectPage = false;
    public static string HistoryTrackId;
    public static string UnavailMode;
    /*
       This method is invoked from java script on click of create unavailability button.
       This method is used for creating unavailability.
    */
    
    webservice static String generateUnavailability(ID[] unavailabilityID ,String mode){
        system.debug('----->'+mode);
        Unavailability__c unavailabiltyRecord = [Select Employee__c,Group__c,Start_Date_Time__c,opportunity__r.CHI_Lead_Id__c,
                                                        End_Date_Time__c,Unavailability_Reason__c,Generated_Unavailability__c,History_Track__c,
                                                        Unavailability_Notes__c,Type__c,Amendment_Reason__c,Labour_Type__c from Unavailability__c where ID in :unavailabilityID limit 1];
                                                                            
         if(unavailabiltyRecord.Start_Date_Time__c >= unavailabiltyRecord.End_Date_Time__c){
            
            return 'Unavailability start time should be less than end time.';
            
        }
        
        
        if(mode!=null)
        
        UnavailMode = mode;
        
        else
        
        UnavailMode = 'new';
        
        poolDiariesMessage = '';
        
        
        if(unavailabiltyRecord.Generated_Unavailability__c){
            
         return 'This unavailability record has already been used. Please uncheck the Generated Unavailability checkbox, modify this record as required and try again.';
            
        }
        
        /*
        Stacked Unavailability Changes : Start
        
        Before generating the Unavailability check during this period if there are any previous Unavailabilities or Job Planned.
        Call SegregateEntries method. This method will return two list. one conatining Unavailabilities and other containing Job Bookings.
        If Enntries present then show them in Job_UnavailabilityDisplay.page
        */
        
        list<list<Diary_Entry__c>> consolidatedsList  = segregateEntries(unavailabiltyRecord);
        if(consolidatedsList[0].size()>0 ||consolidatedsList[1].size()>0){
            
            return 'Display Job_Unavailability page';
        }
        //Stacked Unavailability Changes : end
                                                         
        Map<ID,List<Diary_Entry__c>> weekEntry = getWeekEntries(unavailabiltyRecord);
        
        if(weekEntry.size()==0){
            
            return 'Unavailability not generated as there are no weeks existing between mentioned duration for unavailability OR you are trying to generate unavailability for pool employees.';
            
        }
        
                
        weekEntry = mergeGapJobBookings(unavailabiltyRecord,weekEntry);
        
        unAvailabilities = generateUnavailabilities(unavailabiltyRecord,weekEntry);
        
        // Create a savepoint because the data should not be committed to the database in case of failure
        
        sp = Database.setSavepoint();
        
        try{                
                   // Calling Ray Holder's Code Here.
                   UnavailabilityManager.createUnavailability(unAvailabilities);
                
           }catch(Exception excp){
                    
              // Revert the database to the original state
              Database.rollback(sp);
              return 'Error occured while generating unavailability.';
                    
           }       
         
        unavailabiltyRecord.Generated_Unavailability__c = true;
        System.debug('unavailabiltyRecord: '+ unavailabiltyRecord+ unAvailabilities);
        update unavailabiltyRecord;
        
         if(unavailabiltyRecord.History_Track__c == 'Yes')
        {
            system.debug('*********In  History*********'+UnavailMode+HistoryTrackId);
            UnavailabilityHistoryHelper historyHelper = new UnavailabilityHistoryHelper();
            if(UnavailMode =='new')
            {
                system.debug('*********In  New*********');
                //historyHelper.createHistoryRecords(unAvailabilities);
                
            }else if( HistoryTrackId != null && UnavailMode == 'edit')
            {
                system.debug('*********In  Edit*********'+HistoryTrackId);
                historyHelper.Createhistorychildrecords(unAvailabilities, HistoryTrackId);
            }
        }
        
        
        if(poolDiariesMessage.length()>10){
            
            return poolDiariesMessage;
            
        }
       
        return 'Unavailabilty generated succesfully.';
        
    }
    
   // This method ends here.
    
    /*
       This method is used for computing weeks and diary entries which are falling under specified unavailability duration.
       It returns map containnig week id as key and corresponding array list of diary entries as value.
    */

   public static Map<ID,List<Diary_Entry__c>> getWeekEntries(Unavailability__c unavailabiltyRecord){

          List<ID> empList = new List<ID>();
          List<ID> weekList = new List<ID>();
          Map<ID,List<Diary_Entry__c>> weekEntry = new Map<ID,List<Diary_Entry__c>>();  
          Date unavailabilityStartDate = (unavailabiltyRecord.Start_Date_Time__c).date();
          Date unavailabilityEndDate =   (unavailabiltyRecord.End_Date_Time__c).date();
          List<Diary_Entry__c> entryList = new List<Diary_Entry__c>();
          List<Employee_Group__c> employeeGroups = new List<Employee_Group__c>();
          List<Week__c> weekRecords = new List<Week__c>();
          
          if(unavailabiltyRecord.Group__c!=null)
          employeeGroups = [Select Employee__c from Employee_Group__c where Group__c = :unavailabiltyRecord.Group__c];
        
        if(employeeGroups.size()>0){
            
           for(Employee_Group__c empGroup:employeeGroups){
            
              empList.add(empGroup.Employee__c);
              
             } 
             
        } else {
            
                 empList.add(unavailabiltyRecord.Employee__c);
                 
        }
                                                                                                  
        for(Week__c wk : [Select ID,Employee__c,Week_Commencing__c,Employee__r.Pool_Diary__c,Shift_Pattern__r.Pool_Shift_Pattern__c from Week__c 
                                     where Employee__c in :empList and
                                     (Week_Commencing__c >= :unavailabilityStartDate.toStartOfWeek()) and
                                     (Week_Commencing__c <=:unavailabilityEndDate.toStartOfWeek())
                                       order by Week_Commencing__c])
       {
           if(checkWeekRecord(unavailabiltyRecord, wk))
           
           {        
               
             weekRecords.add(wk);
             
           }
       
       }
                                                      
        weekRecords = checkWeekUnavailabilityDuration(unavailabiltyRecord,weekRecords);
        
        for(Week__c weekInstance:weekRecords){
            
            weekList.add(weekInstance.ID);
            
        }  
        System.debug('WeekList: ' + weekList);
        
        Diary_Entry__c[] diaryEntries = [Select ID,Week__c,Start__c,End__c,Record_Type__c  from Diary_Entry__c where Week__c in :weekList
                                                                                                                          order by Start__c];
        for(Week__c weekInstance:weekRecords){
            
            Integer count = 0;
            
            if(weekInstance.Employee__r.Pool_Diary__c || weekInstance.Shift_Pattern__r.Pool_Shift_Pattern__c){
                
                poolDiariesMessage = 'There are one or more pool diaries included in this unavailability generation. '; 
                poolDiariesMessage = poolDiariesMessage + 'We do not generate unavailability for pool diaries. '; 
                poolDiariesMessage = poolDiariesMessage + 'For rest of the employees, unavailability has been generated successfully.';
                continue;
                
            }
            
            
            for(Diary_Entry__c diaryInstance:diaryEntries){
                if(count==0){
                    
                    weekEntry.put(weekInstance.ID, new List<Diary_Entry__c>());
                    
                }
                
                if(diaryInstance.Week__c == weekInstance.Id){
                    
                    weekEntry.get(weekInstance.ID).add(diaryInstance);
                    
                    }
                    
               count++;
              
            }
        }
        System.Debug('weekEntry: ' + weekEntry);
        return weekEntry;
   }
   
  //  This method ends here.
    
  
  /*
      This method is used for merging gaps, job bookings and unavailabilities in the same week.
      This is done because gaps, job bookings and unavailabilities are considered similar when we generate unavailability.
  */ 
  
  public static Map<ID,List<Diary_Entry__c>> mergeGapJobBookings (Unavailability__c unavailabiltyRecord,
                                                                              Map<ID,List<Diary_Entry__c>> weekEntry){
                                                                                
       System.debug('BEFORE MERGE: '+weekEntry);
       List<Diary_Entry__c> mergedEntryList = new List<Diary_Entry__c>();
       Map<ID,List<Diary_Entry__c>> mergedMap = new Map<ID,List<Diary_Entry__c>>();
       
       for(ID weekID:weekEntry.keySet()){
            
          mergedEntryList = mergeGapJobBookingsForSameWeek(unavailabiltyRecord,weekEntry.get(weekID));
          mergedMap.put(weekID,mergedEntryList);
                
            }
      System.debug('AFTER MERGE: '+mergedMap);
    return mergedMap;
    
  }
  
 //  This method ends here.
 
   /*
     This method is used for merging diary entries of type gaps, job bookings and unavailabilities which are under the same week. 
     It recieves Diary Entry List as an argument and returns merged array list.
   */
 
 
 public static List<Diary_Entry__c> MergeGapJobBookingsForSameWeek(Unavailability__c unavailabiltyRecord,List<Diary_Entry__c> diaryList){
    
    //sort entries by start date
    Diary_Entry__c tmp;
    List<Diary_Entry__c> mergedEntries = new List<Diary_Entry__c>();
    boolean changed = true;
    while(changed){
        changed=false;
        for(integer i=1; i<diaryList.size() ; i++){
            if(diaryList[i-1].Start__c > diaryList[i].Start__c){
                tmp = diaryList[i-1];
                diaryList[i-1] = diaryList[i];
                diaryList[i] = tmp;
                changed = true;
            }
        }
    }
    System.debug('SORTED ENTRIES: ' +diaryList);
    //now merge the entries
    tmp = null;
    for(integer i=0; i<diaryList.size();i++){
        if(tmp == null){
            tmp = diaryList[i];
            System.debug('tmp:'+tmp);
            continue;
        }
        
        //create a new entry if there is no overlap
        if(tmp.End__c < diaryList[i].Start__c){
            Diary_Entry__c newDE = new Diary_Entry__c(Start__c = tmp.Start__c, End__c = tmp.End__c, Week__c = tmp.Week__c);
            mergedEntries.add(newDE);
            System.debug('adding:'+newDe);
            tmp = diaryList[i];
            System.debug('tmp:'+tmp);
            continue;
        }else{
            if(diaryList[i].End__c > tmp.End__c)
                tmp.End__c = diaryList[i].End__c;
                System.debug('tmp:'+tmp);
        }
        //add the last entry if we reach the end if the list
        if(i == (diaryList.size()-1)){
            if(diaryList[i].End__c > tmp.End__c)
                tmp.End__c = diaryList[i].End__c;
            Diary_Entry__c newDE = new Diary_Entry__c(Start__c = tmp.Start__c, End__c = tmp.End__c, Week__c = tmp.Week__c);
            mergedEntries.add(newDE);
            System.debug('adding:'+newDe);
        }
    }
    //just check that the last entry has been added to the list.
    if(mergedEntries.size() > 0){
        if(mergedEntries[mergedEntries.size()-1].End__c != tmp.End__c && mergedEntries[mergedEntries.size()-1].Start__c != tmp.Start__c){
            Diary_Entry__c newDE = new Diary_Entry__c(Start__c = diaryList[diaryList.size()-1].Start__c, End__c = diaryList[diaryList.size()-1].End__c, Week__c = diaryList[diaryList.size()-1].Week__c);
                mergedEntries.add(newDE);
                System.debug('adding:'+newDe);
        }
    }else{
        // Added extra checks to fix the issue in generating unavailability for groups.
        if(diaryList.size()>0){
        Diary_Entry__c newDE = new Diary_Entry__c(Start__c = diaryList[0].Start__c, End__c = diaryList[0].End__c, Week__c = diaryList[0].Week__c);
                mergedEntries.add(newDE);
           }
    }
    return mergedEntries;
            
 }
 /*
 public static List<Diary_Entry__c> oldMergeGapJobBookingsForSameWeek(Unavailability__c unavailabiltyRecord,List<Diary_Entry__c> diaryList){
    
     List<Diary_Entry__c> mergedEntryList = new List<Diary_Entry__c>();
     List<Diary_Entry__c> groupedEntryList = new List<Diary_Entry__c>();
     Integer count = 0;
     Integer mergeCode = 0;
     
     for(Diary_Entry__c entryInstance:diaryList){
        
          if(count == 0){
            
            entryInstance.Merge_Code__c = mergeCode;
            
            }

                if(count>0) {
                
                   if(((((diaryList.get(count-1)).End__c).date()).daysBetween((entryInstance.Start__c).date()))<=1){
                    
                         entryInstance.Merge_Code__c = (diaryList.get(count-1)).Merge_Code__c;
                
                       } else{
        
                                mergeCode++;
                                entryInstance.Merge_Code__c = mergeCode;
                            
                              }
                     
                        }

         count++;
   
     }
     System.debug('diaryList : ' + diaryList);
     mergedEntryList.clear();
     
     // This logic is used for grouping the merged diary entries
             
    Integer j=0;
    
    for(Integer i=0;i<=diaryList.size();i++){
        
          j=0;
        
          for(j=0;j<diaryList.size();j++){
            
             if(diaryList[j].Merge_Code__c.intValue()==i){
                
                 groupedEntryList.add(diaryList[j]);
                 
            }

            if(diaryList.size()==j+1 && groupedEntryList.size()>0){
                
                 mergedEntryList.add(groupEntries(groupedEntryList));
                 groupedEntryList.clear();
                 
            }
            
        }
        
    }
            
     return mergedEntryList;
  }
 
 //  This method ends here.
 */
 /*
 
  This method is used for generating one diary entry for the list of diary entries with same merge code.
  
 */
 
  public static Diary_Entry__c groupEntries(List<Diary_Entry__c> groupedEntrylist){
    
    Diary_Entry__c entryInstance=new Diary_Entry__c();
    entryInstance.Start__c = groupedEntrylist[0].Start__c;
    entryInstance.End__c =  groupedEntrylist[groupedEntrylist.size()-1].End__c;
    entryInstance.RecordTypeId = groupedEntrylist[0].RecordTypeID;
    entryInstance.Week__c = groupedEntrylist[0].Week__c;
    return entryInstance;
    
  }
 
 // Method for generating one diary entry for the list of diary entries with same merge code ends here.
 
  /*
      This method is used for generating unavailability records. 
      These records will not be saved in database but passed for further manupulation.
  */ 
  
  public static List<Diary_Entry__c> generateUnavailabilities (Unavailability__c unavailabiltyRecord,
                                                                              Map<ID,List<Diary_Entry__c>> weekEntry){
       List<Diary_Entry__c> unAvailabilityList = new List<Diary_Entry__c>();
       Diary_Entry__c unAvailability = new Diary_Entry__c();
       Diary_Entry__c unAvailabilityPartInstance = new Diary_Entry__c();
       unAvailability.Start__c = unavailabiltyRecord.Start_Date_Time__c;
       unAvailability.End__c = unavailabiltyRecord.End_Date_Time__c;
       String unAvailableEntryType = Utilities.getRecordTypeId('Unavailability', 'Diary_Entry__c');
       Integer count = 0;
       System.debug('weekEntry : '+weekEntry);
       for(ID weekID:weekEntry.keySet()){
           
            count = 0;
            unAvailability.Start__c = unavailabiltyRecord.Start_Date_Time__c;
            unAvailability.End__c = unavailabiltyRecord.End_Date_Time__c;
        
            for(Diary_Entry__c entryInstance:weekEntry.get(weekID)){
 
                unAvailabilityPartInstance = devideUnavailabilityLogically(entryInstance,unAvailability); 
                
                if(unAvailabilityPartInstance != null) {
                    
                     unAvailabilityPartInstance.RecordTypeId = unAvailableEntryType;
                     unAvailabilityPartInstance.Week__c = entryInstance.Week__c;
                     unAvailabilityPartInstance.Labour_Type__c = unavailabiltyRecord.Labour_Type__c;
                     unAvailabilityPartInstance.Sub_Type__c = unavailabiltyRecord.Unavailability_Reason__c;
                     unAvailabilityPartInstance.Unavailability_Notes__c = unavailabiltyRecord.Unavailability_Notes__c;
                     unAvailabilityPartInstance.CHI_Lead_Number__c = unavailabiltyRecord.opportunity__r.CHI_Lead_Id__c;
                     unAvailabilityPartInstance.Primary_Type__c = unavailabiltyRecord.Type__c;
                     if(UnavailMode == 'new' && unavailabiltyRecord.History_Track__c == 'yes')
                     unAvailabilityPartInstance.Create_History__c = true;
                     unAvailabilityPartInstance.Amendment_Reason__c = unavailabiltyRecord.Amendment_Reason__c;
                     unAvailabilityList.add(unAvailabilityPartInstance);    
                
                }
                
                count++;
                
              } 
          
                
           }
      
    return unAvailabilityList;
    
  }
  
 //  This method ends here.
 
  /*
 
       This method is used for deviding unavailabilities logically using existing entries in a week.
 
  */
  
  public static Diary_Entry__c devideUnavailabilityLogically(Diary_Entry__c entryInstance,Diary_Entry__c unAvailability) {
    
     Diary_Entry__c unAvailabilityPartInstance = new Diary_Entry__c();
     System.debug('entryInstance :: unAvailability# ' + entryInstance+' :: '+ unAvailability);
     // This is the scenario where unavailability does not intercept diary entry being considered at all.
     
     if( (entryInstance.End__c <= unAvailability.Start__c) 
          ||
         (entryInstance.Start__c >= unAvailability.End__c) ){
        
        return null;
            
     }
     
     // This is the scenario where unavailability fully shadows diary entry being considered.
     
     else if(entryInstance.Start__c >= unAvailability.Start__c && entryInstance.End__c <= unAvailability.End__c){
        
        unAvailabilityPartInstance.Start__c = entryInstance.Start__c;
        unAvailabilityPartInstance.End__c = entryInstance.End__c;
        return unAvailabilityPartInstance;
        
     }
     
     // This is the scenario where unavailability is behind diary entry and partially overlaps it.
     
     else if(entryInstance.Start__c < unAvailability.End__c && entryInstance.End__c >= unAvailability.End__c 
        && entryInstance.Start__c > unAvailability.Start__c){
        
        unAvailabilityPartInstance.Start__c = entryInstance.Start__c;
        unAvailabilityPartInstance.End__c = unAvailability.End__c;
        return unAvailabilityPartInstance;
        
     }
     
     // This is the scenario where unavailability is ahead of diary entry and partially overlaps it.
     
     else if(entryInstance.Start__c <= unAvailability.Start__c && entryInstance.End__c > unAvailability.Start__c
        && entryInstance.End__c < unAvailability.End__c){
        
        unAvailabilityPartInstance.Start__c = unAvailability.Start__c;
        unAvailabilityPartInstance.End__c = entryInstance.End__c;
        return unAvailabilityPartInstance;
        
     }
     
      // This is the scenario where unavailability is between given diary entry.
     
     else if(entryInstance.Start__c <= unAvailability.Start__c && entryInstance.End__c >= unAvailability.End__c){
        
        unAvailabilityPartInstance.Start__c = unAvailability.Start__c;
        unAvailabilityPartInstance.End__c = unAvailability.End__c;
        return unAvailabilityPartInstance;
        
     }
     
     return null;
  }
  
 /*
    This method is used for checking whether perticular week falls under unavailability being created.
    If it does then we add it to list and we return the final list in the end.
 */
 
   public static List<Week__c> checkWeekUnavailabilityDuration(Unavailability__c unavailabiltyRecord,Week__c[] weekRecords){
    
    List<Week__c> weekList = new List<Week__c>();
    Date startOfWeek;
    Date endOfWeek;
    
    for(Week__c weekInstance:weekRecords){
        
        startOfWeek = weekInstance.Week_Commencing__c;
        endOfWeek = startOfWeek.addDays(7);
        
        if(
        
               (startOfWeek >= unavailabiltyRecord.Start_Date_Time__c.date() && endOfWeek <= unavailabiltyRecord.End_Date_Time__c.date())
        
           ||  (startOfWeek <= unavailabiltyRecord.End_Date_Time__c.date() && endOfWeek >= unavailabiltyRecord.End_Date_Time__c.date() 
                                                               && startOfWeek > unavailabiltyRecord.Start_Date_Time__c.date()) 
        
           ||  (startOfWeek <= unavailabiltyRecord.Start_Date_Time__c.date() && endOfWeek >= unavailabiltyRecord.Start_Date_Time__c.date()
                                                                   && endOfWeek < unavailabiltyRecord.End_Date_Time__c.date())
        
           ||  (startOfWeek <= unavailabiltyRecord.Start_Date_Time__c.date() && endOfWeek >= unavailabiltyRecord.End_Date_Time__c.date())  
           
         ){
            
            weekList.add(weekInstance);
            
        }
        
    }
    
    return weekList;
    
   }
 
 
 // This method ends here.
 
 /*
      This method is used for determining whether we should consider perticular 
      week record assigned to an employee for generating unavailability or not.
 */ 
  
  public static Boolean checkWeekRecord(Unavailability__c unavailabiltyRecord,Week__c wk){
    
    Boolean considerWeekRecord = true;
    
    Date unavailabilityStartDate = (unavailabiltyRecord.Start_Date_Time__c).date();
    Date unavailabilityEndDate =  (unavailabiltyRecord.End_Date_Time__c).date();
    
    if(wk.Week_Commencing__c>unavailabilityEndDate){
        
        considerWeekRecord = false;
        
    }else if(wk.Week_Commencing__c.addDays(7)<unavailabilityStartDate){
        
        considerWeekRecord = false;
        
    }  
     
    return considerWeekRecord;
    
  }
  
 //  This method ends here.
 
 /*
        Stacked Unavailability Changes : Start
        method name:segregateEntries.
        same method is used in Job_UnavailabilityDisplay.Page 
        Before generating the Unavailability check during this period if there are any previous Unavailabilities or Job Planned.
        Call SegregateEntries method. This method will return two list. one conatining Unavailabilities and other containing Job Bookings.
        If Enntries present then show them in Job_UnavailabilityDisplay.page
 */
 
 public static list<list<Diary_Entry__c>> segregateEntries(Unavailability__c unavailabiltyRecord){
        
        

          List<ID> empList = new List<ID>();
          List<ID> weekList = new List<ID>();
          
          list<list<Diary_Entry__c>> consolidatedsList;
          Date unavailabilityStartDate = (unavailabiltyRecord.Start_Date_Time__c).date();
          Date unavailabilityEndDate =   (unavailabiltyRecord.End_Date_Time__c).date();
          List<Diary_Entry__c> entryList = new List<Diary_Entry__c>();
          List<Employee_Group__c> employeeGroups = new List<Employee_Group__c>();
          List<Week__c> weekRecords = new List<Week__c>();
          
          employeeGroups = [Select Employee__c from Employee_Group__c where Group__c = :unavailabiltyRecord.Group__c];
        
        if(employeeGroups.size()>0){
            
           for(Employee_Group__c empGroup:employeeGroups){
            
              empList.add(empGroup.Employee__c);
              
             } 
             
        } else {
            
                 empList.add(unavailabiltyRecord.Employee__c);
                 
        }
                                                                                                  
        for(Week__c wk : [Select ID,Employee__c,Week_Commencing__c,Employee__r.Pool_Diary__c,Shift_Pattern__r.Pool_Shift_Pattern__c from Week__c 
                                     where Employee__c in :empList and
                                     (Week_Commencing__c >= :unavailabilityStartDate.toStartOfWeek()) and
                                     (Week_Commencing__c <=:unavailabilityEndDate.toStartOfWeek())
                                       order by Week_Commencing__c])
       {
           if(CreateUnavailability.checkWeekRecord(unavailabiltyRecord, wk))
           
           {        
               
             weekRecords.add(wk);
             
           }
       
       }
                                                      
        for(Week__c weekInstance:weekRecords){
            
            weekList.add(weekInstance.ID);
            
        }  
        System.debug('WeekList: ' + weekList);
        Diary_Entry__c[] diaryEntries = [Select ID,Name ,Job__c,Week__c,Start__c,End__c,Record_Type__c,Sub_Type__c,Stackable__c,Employee_ID_18__c,IsStackable__c,Employee_Name__c,Employee__c,Needs_Removal_Reason__c,(Select id from Unavailability_History_Trackers__r)  from Diary_Entry__c where Week__c in :weekList and(Record_Type__c!='Availability') 
                                         and Start__c < :unavailabiltyRecord.End_Date_Time__c and End__c > :unavailabiltyRecord.Start_Date_Time__c  order by Start__c];
        
        list<Diary_Entry__c> unava_Lst =new list<Diary_Entry__c>();
        list<Diary_Entry__c> jobentriesLst =new list<Diary_Entry__c>();
        
        for(Week__c weekInstance:weekRecords){
            
            Integer count = 0;
             
            for(Diary_Entry__c diaryInstance:diaryEntries){
                
                if(diaryInstance.Record_Type__c == 'Job Booking')
                {
                    jobentriesLst.add(diaryInstance);
                }else if(diaryInstance.Record_Type__c == 'Unavailability')
                {
                    unava_Lst.add(diaryInstance);
                }
            }
        }
        consolidatedsList = new list<list<Diary_Entry__c>>();
        consolidatedsList.add(unava_Lst);
        consolidatedsList.add(jobentriesLst);
        System.Debug('consolidatedsList-->: ' + consolidatedsList);
        return consolidatedsList;
   
    }
    
    public string editUnavailability(ID[] unavailabilityID ,String HistoryRecordId)
    {
        HistoryTrackId = HistoryRecordId;
        system.debug('before editing ---> +'+HistoryTrackId);
        return (CreateUnavailability.generateUnavailability(unavailabilityID, 'edit'));
    }
    
 
}