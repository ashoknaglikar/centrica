/*
Class to handle the updation of diary records from the return/transfer work functionality.
*/

public without sharing class InstallPlanningRTHelper {
    /*
        Method to reduce the diary entry duration by the given reduction. Reduction will be a positive floating number.
        e.g. 12:00 - 14:00 = 2hrs duration; reduction = 1.5 ==> 12:00 - 12:30
        need to shift all subsequent diary entries by the same reduction.
        EXCEPT: if the diary entry has overbookedhours then reduce this first by the reduction amount.
        
        Once the value matching the skill is found
        1. Update the items end__c value by the reduction amount
        2. Update subsequent entries start__c and end__c by the reduction amount
        3. Stop if an availability is found; extend as necessary
        4. Stop if a new job is found
        5. Stop if an unavailability is found
    
        for 4 and 5; create an availability item that fills any gaps

    */
    
    
    //map of form employee__c, week
    Map<Id, Week> weeks;
    Map<Id, List<Diary_Entry__c>> DEs;
    Job__c theJob;
    Map<Id, double> totalOverbookHours;
    //Integer num_diary_entry; //code fix done as a part of PRB00005292 by BGSAMS Support on 12/01/2012
    public void updateDiaryEntries(Job__c theJob, Map <string, InstallPlanningReturnTransferController.HoursInformation> his){
        this.theJob = theJob;
        weeks = new Map<Id, Week>();
        DEs = new Map<Id,List<Diary_Entry__c>>();
        totalOverbookHours = new Map<Id,double>();
        //1. build a list of weeks 
        List<Id> tmpWeeks = new List<Id>();
        for(InstallPlanningReturnTransferController.HoursInformation hi : his.values()){
            for(InstallPlanningReturnTransferController.EntryRecord er : hi.entries){
            //only do something if the reduction value has been set greater than 0.
                if(er.reduction > 0){
                    tmpWeeks.add(er.ent.week__c);
                }
            }
        }
        //2. get week entries (children of week)
        // Fix for transfer work for pool resources - Cognizant Support - Added few more fields in below SOQL
        List<Week__c> myWeeks = [Select w.Week_Commencing__c, w.Wednesday_Start_Time__c, w.Wednesday_End_Time__c, w.Tuesday_Start_Time__c, 
                                w.Tuesday_End_Time__c, w.Thursday_Start_Time__c, w.Thursday_End_Time__c, w.Sunday_Start_Time__c, 
                                w.Sunday_End_Time__c, w.Monday_Booked_Hours__c,w.Tuesday_Booked_Hours__c,w.Wednesday_Booked_Hours__c,
                                w.Thursday_Booked_Hours__c,w.Friday_Booked_Hours__c,w.Saturday_Booked_Hours__c,w.Sunday_Booked_Hours__c,
                                w.Shift_Pattern__c, w.Saturday_Start_Time__c, w.Saturday_End_Time__c, w.Monday_Start_Time__c, 
                                w.Monday_End_Time__c, w.Id, w.Friday_Start_Time__c, w.Friday_End_Time__c, w.Employee__c, w.Employee__r.Name,w.Employee_Is_Pool_Diary__c, 
                                (Select Id, Week__c, Job__c, Record_Type__c, OverBooked_Hours__c, RecordTypeId, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c From Diary_Entries__r 
                                    order by Start__c, End__c) 
                                From Week__c w where id in :tmpWeeks ];
        system.debug( LoggingLevel.INFO, 'my weeks : '+ myWeeks);
        
        
        for(Week__c w : myWeeks){
            //just incase check for duplicate entry
            if(!weeks.containsKey(w.Employee__c)){
                weeks.put(w.Employee__c, new Week(w));

                              
            }
            //Added By Ashok G
            List<Diary_Entry__c> DEList = new List<Diary_Entry__c>();    
            for(Diary_Entry__c de : w.Diary_Entries__r){
                system.debug(LoggingLevel.INFO, 'before : '+ de);
                if(theJob.id == de.Job__c){
                  DEList.add(de);
                }
            }
            if(DEList.size()>0 && !DEs.containsKey(w.Employee__c)){
              DEs.put(w.Employee__c,DElist);
            }
         }
    
        //A new variable to hold the overbooking Hours.
        if(theJob.Diary_Entries__r.size()>0){
            for(Diary_Entry__c jDe: theJob.Diary_Entries__r ){
               if(!totalOverbookHours.containsKey(jDe.week__r.Employee__c)){               
               totalOverbookHours.put(jDe.Week__r.Employee__c,jDe.OverBooked_Hours__c);
               }else{
                 double OB =jDe.OverBooked_Hours__c+totalOverbookHours.get(jDe.week__r.Employee__c);
                 totalOverbookHours.put(jDe.Week__r.Employee__c,OB);
               }
            }
        }
        
            
        for(InstallPlanningReturnTransferController.HoursInformation hi : his.values()){
            for(InstallPlanningReturnTransferController.EntryRecord er : hi.entries){
                //only do something if the reduction value has been set greater than 0.
                if(er.reduction > 0){
                    updateDiaryEntries(er.ent.week__r.Employee__c, er.reduction, hi.skill, er);
                }
            }
            
        }
        
        //Insert availability entries in the gaps for these weeks
        Diary_Entry__c previousDE;
        List<Diary_Entry__c> deEntries = new List<Diary_Entry__c>();
        //loop around all diary entries and fill gaps with availability records.
        //if the next entry is an availability then extend this record.
        //presume that the first entry always starts at the week start datetime.
        for(week w : weeks.values()){
            
            previousDE = null;
            // gjb - Build up a list of unavailability start and end times
            Map<DateTime, DateTime> unavStartAndEnd = new Map<DateTime, DateTime>();
            for(Diary_Entry__c de : w.week.Diary_Entries__r){
                if(de.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability') && (de.Sub_Type__c != 'NWD - Working')) {
                    if(unavStartAndEnd.containsKey(de.Start__c)) {
                        if(de.End__c > unavStartAndEnd.get(de.Start__c))
                            unavStartAndEnd.put(de.Start__c, de.End__c);
                    } else {
                        unavStartAndEnd.put(de.Start__c, de.End__c);
                    }
                }
            }
      
            system.debug(LoggingLevel.INFO, 'unavStartAndEnd'+unavStartAndEnd);// end g
             //code fix done as a part of PRB00005292 by BGSAMS Support on 12/01/2012 -starts
             //num_diary_entry=w.week.Diary_Entries__r.size();
             //system.debug('num_diary_entry'+num_diary_entry);
             //system.debug('de in week'+w.week.Diary_Entries__r);
            // Integer num_looped=0;
             Diary_Entry__c ActualPreviousDE = null;
             //Diary_Entry__c de_new; 
            for(Diary_Entry__c de : w.week.Diary_Entries__r){
                                 
                if(de.Sub_Type__c == 'NWD - Working')
                continue;
                // gjb - adding this to handle unavailability 
                //num_looped++;
                if(de.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability'))//&& (num_looped<num_diary_entry)) 
                {
                    // Note that we do not set previousDE at this stage!
                  //de_new = de; //code fix done as a part of PRB00006560 by BGSAMS Support on 22/03/2012 - starts
                                
                  system.debug(LoggingLevel.INFO, 'previousDE inside unavail loop'+previousDE);
                  system.debug(LoggingLevel.INFO, 'ActualPreviousDE inside unavail loop'+deEntries);
                  if(previousDE != null && ActualPreviousDE != null)
                  {
                      if(previousDE.End__c!=de.Start__c && ActualPreviousDE.RecordTypeId!=RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability') )  
                        {
                        system.debug(LoggingLevel.INFO, 'came inside if previousDE.End__c!=de.Start__c && ActualPreviousDE= unavailability');
                        Diary_Entry__c newDE = new Diary_Entry__c(
                                                Week__c = w.week.Id,
                                                Hours__c = DateTimeHelper.calculateHours(previousDE.End__c, de.Start__c, w.week),
                                                Start__c = previousDE.End__c,
                                                End__c = de.Start__c,
                                                Sub_Type__c = 'Availability',
                                                RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
                                                );
                        deEntries.add(newDE);
                        previousDE = newDE;
                        system.debug(LoggingLevel.INFO, 'availability created in previousDE != null && ActualPreviousDE != null loop for unavailability'+newDE);
                        }
                    }
                    ActualPreviousDE = de; 
                    continue;
                    }
                   ActualPreviousDE = de;
                   //code fix done as a part of PRB00006560 by BGSAMS Support on 22/03/2012 - ends
                   // end gjb
                              
                if(w.week.Employee_Is_Pool_Diary__c == 'Y'){
                    deEntries.add(de);
                    continue;
                }
                if(previousDE == null){
                    previousDE = de;
                    deEntries.add(de);
                    continue;
                }
               //system.debug(LoggingLevel.INFO, 'de_new'+de_new);
                system.debug(LoggingLevel.INFO, 'previous de '+previousDE);
                system.debug(LoggingLevel.INFO, 'Current diary entry'+de);
            if(previousDE.End__c != de.Start__c){//found a gap
                    system.debug(LoggingLevel.INFO, 'came inside the loop to create availability');
                    if(de.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')){
                   /* if (de_new.End__c==de.Start__c)//code fix done as a part of PRB00005292 by BGSAMS Support on 12/01/2012 -starts
                        {
                        system.debug(LoggingLevel.INFO, 'came inside if de_new.End__c==de.Start__c');
                        Diary_Entry__c newDE = new Diary_Entry__c(
                                                        Week__c = w.week.Id,
                                                        Hours__c = DateTimeHelper.calculateHours(previousDE.End__c, de_new.Start__c, w.week),
                                                        Start__c = previousDE.End__c,
                                                        End__c = de_new.Start__c,
                                                        Sub_Type__c = 'Availability',
                                                        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
                        );
                        deEntries.add(newDE);
                        system.debug(LoggingLevel.INFO, 'availability created in de_new.End__c==de.Start__c loop'+newDE);
                         }   //code fix done as a part of PRB00005292 by BGSAMS Support on 12/01/2012 -ends */
                         //To extend availability if gap is immediately followed by Availability
                        de.Hours__c += DateTimeHelper.calculateHours(previousDE.End__c, de.Start__c, w.week);
                        de.Start__c = previousDE.End__c;
                        previousDE = de;
                        system.debug( LoggingLevel.INFO,'previousDE is '+previousDE);
                        break;
                    }
                    else{
                        // gjb - added if/else statement to handle situations where there is unavailability so that availability
                        // is correctly created with respect to unavailability.
                        if(unavStartAndEnd.isEmpty()) { 
                             // j11-j12-j13-j21-j22-j23-A transfer j13
                            Diary_Entry__c newDE = new Diary_Entry__c(
                                                        Week__c = w.week.Id,
                                                        Hours__c = DateTimeHelper.calculateHours(previousDE.End__c, de.Start__c, w.week),
                                                        Start__c = previousDE.End__c,
                                                        End__c = de.Start__c,
                                                        Sub_Type__c = 'Availability',
                                                        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
                                                    );
                            system.debug(LoggingLevel.INFO, 'availability created in unavStartAndEnd.isEmpty() loop'+newDE);
                            deEntries.add(newDE);
                        } else {
                        system.debug( LoggingLevel.INFO, 'unavail not null!!!!');
                            DateTime currentStart = previousDE.End__c;
                            DateTime latestEnd = null;                          
                            for(DateTime unavStartDT : unavStartAndEnd.keySet()) {
                                DateTime unavEndDT = unavStartAndEnd.get(unavStartDT);
                                system.debug(LoggingLevel.INFO, 'unavStartAndEnd'+unavStartAndEnd);
                                
                                // PRB00003771 starts-- The below fix has been done for the availability not created issue in transfer work
                                //the below loop is used to exclude all the unavailabilities before the GAP is found (GAP is between previousDE.End__c and de.Start__c) 
                                //or after the GAP is found (i.e after the current diary entry de)
                                if(unavEndDT <= currentStart ||unavStartDT > de.Start__c)
                                    continue;
                                // PRB00003771 starts-- The below fix has been done for the availability not created issue in transfer work
                                system.debug(LoggingLevel.INFO, 'Inside loop- unavstartdt :'+unavstartDT);
                                system.debug(LoggingLevel.INFO, 'Inside loop- unavEndDT :'+unavEndDT);
                                system.debug(LoggingLevel.INFO, 'Inside loop- currentstart :'+currentstart);
                                system.debug(LoggingLevel.INFO, 'Inside loop- de'+de);
                                 // to create availability where the transfer work gap is followed by an  Unavailability and then a job booking(j11-j12-j13-U-J21   transfer j13)
                                 //But currently code fix for PRB00006560 handles if there is a gap before any unavailability. 
                            if(unavStartDT >currentStart && unavStartDT <= de.Start__c) {
                                    // create gap between currentStart and planAround
                                    Diary_Entry__c newDE = new Diary_Entry__c(
                                                        Week__c = w.week.Id,
                                                        Hours__c = DateTimeHelper.calculateHours(currentStart, unavStartDT, w.week),
                                                        Start__c = currentStart,
                                                        End__c = unavStartDT,
                                                        Sub_Type__c = 'Availability',
                                                        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
                                                    );
                                system.debug(LoggingLevel.INFO, 'availability created in unavStartDT >currentStart && unavStartDT <= de.Start__c:second if'+newDE);
                                deEntries.add(newDE);
                                 }
                                //the below loop will be executed if there is an unavailability between the previous de and de before or after the gap
                                if(latestEnd == null || latestEnd < unavEndDT) {
                                    currentStart = unavEndDT;
                                    latestEnd = unavEndDT;
                                     system.debug( LoggingLevel.INFO, 'latest end & currentStart '+latestEnd+' '+currentStart);    
                                     }                

                            }
                            // create after last item to plan around, if necessary
                            // the below loop will be executed if no unavailabilities are present between the previous de and de before or after the gap and transfer work done in case of two job bookings.
                            if(latestEnd == null) {
                                // None of the unavailabilities affect what we need to create, so create as before
                                Diary_Entry__c newDE = new Diary_Entry__c(
                                                        Week__c = w.week.Id,
                                                        Hours__c = DateTimeHelper.calculateHours(previousDE.End__c, de.Start__c, w.week),
                                                        Start__c = previousDE.End__c,
                                                        End__c = de.Start__c,
                                                        Sub_Type__c = 'Availability',
                                                        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
                                                    );
                            system.debug(LoggingLevel.INFO, 'availability created in latestEnd == null : third if'+newDE);
                            deEntries.add(newDE);
                            } 
                            // to create availability where the Unavailability is followed by transfer work gap (j11-j12-j13-U-J21-j22-j23  transfer j21)
                            else if(latestEnd != null && latestEnd < de.Start__c) {
                                // There's a gap between the last unavailability and the start time of this diary entry
                                Diary_Entry__c newDE = new Diary_Entry__c(
                                                        Week__c = w.week.Id,
                                                        Hours__c = DateTimeHelper.calculateHours(latestEnd, de.Start__c, w.week),
                                                        Start__c = latestEnd,
                                                        End__c = de.Start__c,
                                                        Sub_Type__c = 'Availability',
                                                        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
                                                    );
                            system.debug(LoggingLevel.INFO, 'availability created in latestEnd != null && latestEnd < de.Start__c fourth if'+newDE);
                            deEntries.add(newDE);
                            }
                  } // end gjb*/
                  }
                  }             
                previousDE = de;
                
                deEntries.add(de);
                system.debug(LoggingLevel.INFO, 'deEntries_latest'+deEntries);
            }
                   
                        
            /* RJD - 03-12-2009 - Not sure this is required...
            //Add a new entry to the end of the week or the start of the next job...
            
            boolean start = false;
            DateTime endDt = w.endDT;
            for(Diary_Entry__c de : deEntries){
                if(de.Week__c == w.week.id){
                    if(de != previousDE || !start){
                        continue;
                    }
                    if(de == previousDE){
                        start = true;
                        continue;
                    }
                    //only here if the de is after the previousDE 
                    if(de.Job__c != theJob.Id){
                        endDt = de.Start__c;
                        break;
                    }
                }
            }
                    
            if(previousDE.End__c != endDt){
                if(previousDE.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')){
                        previousDE.End__c = endDt;
                        previousDE.Hours__c += DateTimeHelper.calculateHours(previousDE.End__c, endDt, previousDE);
                }else{
                    
                    Diary_Entry__c newDE = new Diary_Entry__c(
                                                    Week__c = w.week.Id,
                                                    Hours__c = DateTimeHelper.calculateHours(previousDE.End__c, w.endDT, w.week),
                                                    Start__c = previousDE.End__c,
                                                    End__c = endDt,
                                                    Sub_Type__c = 'Availability',
                                                    RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
                                                );
                    deEntries.add(newDE);
                }
                
            }
            */
        }
        
        List<Diary_Entry__c> delEntries = new List<Diary_Entry__c>();
        List<Diary_Entry__c> updtEntries = new List<Diary_Entry__c>();
        
        
        for(Diary_Entry__c de : deEntries){
        //System.debug('inside loop to delete dairy');

            //if(de.Hours__c >= 0.01 && de.Start__c != de.End__c) {
        if((de.Hours__c >= 0.01 && de.Start__c != de.End__c) || (de.Hours__c == 0.01 && de.Start__c == de.End__c)){
                updtEntries.add(de);
                system.debug(LoggingLevel.INFO, 'update: '+de);
        }
        //fix for PRB00010117 starts
        else if(de.Sub_Type__c =='Electrical' && de.Hours__c >= 0.01 && de.Start__c == de.End__c)
        {
            updtEntries.add(de);
        } 
        //fix for PRB00010117 ends
        else{
            if(de.Id != null)
                delEntries.add(de);
            system.debug(LoggingLevel.INFO, 'delete: '+de);

            }
        }
      

        delete delEntries;
        delEntries.clear();
        upsert updtEntries;
        
        //get the data back out again and check for sequential availability records.
        weeks.clear();
        myWeeks = [Select w.Week_Commencing__c, w.Wednesday_Start_Time__c, w.Wednesday_End_Time__c, w.Tuesday_Start_Time__c, 
                                w.Tuesday_End_Time__c, w.Thursday_Start_Time__c, w.Thursday_End_Time__c, w.Sunday_Start_Time__c, 
                                w.Sunday_End_Time__c, w.Shift_Pattern__c, w.Saturday_Start_Time__c, w.Saturday_End_Time__c, w.Monday_Start_Time__c, 
                                w.Monday_End_Time__c, w.Id, w.Friday_Start_Time__c, w.Friday_End_Time__c, w.Employee__c, w.Employee__r.Name,w.Employee_Is_Pool_Diary__c, 
                                (Select Id, Job__c, Record_Type__c, RecordTypeId, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c From Diary_Entries__r 
                                    order by Start__c, End__c) 
                                From Week__c w where id in :tmpWeeks ];
        

        system.debug(Logginglevel.INFO,''+myWeeks+' '+myWeeks[0].Diary_Entries__r);
        for(Week__c w : myWeeks){
            //just incase check for duplicate entry
            if(!weeks.containsKey(w.Employee__c))
                weeks.put(w.Employee__c, new Week(w));
        }
        
        
        
        List<Diary_Entry__c> toUpdate = new List<Diary_Entry__c>();
        List<Diary_Entry__c> toDelete = new List<Diary_Entry__c>();
            
        for(Week__c w : myWeeks){
            mergeAvailabilityRecords(w.Diary_Entries__r, toDelete);
        }
            
            for(Week__c w : myWeeks){
                for(Diary_Entry__c de : w.Diary_Entries__r){
                     toUpdate.add(de);
                }
            }
            
            updtEntries.clear();
            for(Diary_Entry__c de : toUpdate){
                //if(de.Hours__c >= 0.01)
                if((de.Hours__c >= 0.01 && de.Start__c != de.End__c) || (de.Hours__c == 0.01 && de.Start__c == de.End__c))
                    updtEntries.add(de);
                //fix for PRB00010117 starts
                else if((de.Hours__c >= 0.01 && de.Start__c == de.End__c)&& de.Sub_Type__c == 'Electrical')
                {
                     updtEntries.add(de);
                } 
                //fix for PRB00010117 ends
                else{
                    toDelete.add(de);
                }
            }
            
            upsert updtEntries;
           delete toDelete;
            
            toDelete.clear();
            //Delete any zero length items
            myWeeks = [Select 
                            (Select Id, Job__c, Record_Type__c, RecordTypeId, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c From Diary_Entries__r order by Start__c) 
                        From Week__c w where id in :tmpWeeks ];
            
            for(Week__c week : myWeeks){
                for(Diary_Entry__c de : week.Diary_Entries__r){
                    // brm - 07-01-2010 - now delete entries that have (effectively) zero hours
                    //if((de.Start__c == de.End__c || de.Hours__c < 0.01) && de.Id != null)
                    if(((de.Start__c == de.End__c && de.Hours__c < 0.01) || de.Hours__c < 0.01) && de.Id != null)
                        toDelete.add(de);
                }
                
            }
            //delete it any have been added to list
            if(toDelete.size() > 0)
                delete (toDelete);
    }
    
    /*
    Merge consecutive availability records. 
    */
    private void mergeAvailabilityRecords(List<Diary_Entry__c> entries, List<Diary_Entry__c> toDelete){
        boolean doneMerge = false;
        //look for any 2 availability records that are next to each other and merge
        
        for(Integer i=0; i< entries.size(); i++){
            Diary_Entry__c de = entries.get(i);
        
            if(i==0 || de.RecordTypeId != RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability') || i==entries.size()-1){
                    continue;
                }
                
            if(de.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability') && entries.get(i+1).RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')){
                
                entries.get(i).End__c = entries.get(i+1).End__c;
                entries.get(i).Hours__c += entries.get(i+1).Hours__c;
                doneMerge = true;
                toDelete.add(entries.get(i+1));
                entries.remove(i+1);
                break;
            }
            
        }
        if(doneMerge)
            mergeAvailabilityRecords(entries, toDelete);
    }
    
    
    
    private void updateDiaryEntries(Id EmployeeId, double reduction, string skill, InstallPlanningReturnTransferController.EntryRecord er){
        
        boolean found = false;
        
        List<Diary_Entry__c> entries = weeks.get(EmployeeId).week.Diary_Entries__r;

        List<Diary_Entry__c> MatchedEntries = DEs.get(EmployeeId);
        Double TotOBHours = totalOverbookHours.get(EmployeeId);
        system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-->'+MatchedEntries);
        // Fix for transfer work for pool resources - Cognizant Support
        // This method and subsequent code in this class is handling pool as well as non pool diaries in similar way.
        // We are diverting the code so that logic for pool diaries is kept separate from non-pool diaries.

        Week__c thisWeek = weeks.get(EmployeeId).week;
        Boolean isPoolDiary = thisWeek.Employee_Is_Pool_Diary__c == 'Y' ? true : false ; 
        List<Diary_Entry__c> poolDiaryEntries = new List<Diary_Entry__c>();
        DateTime adj_date;
        Double adj_hours;
        Double adj_de_endhrs;
        
        for(Diary_Entry__c de : entries){
            
            //don't do anything after an unavailability record is found after the 
            //diary entry has been moved.
            if(de.Sub_Type__c == 'NWD - Working')
            continue;
            
            if(de.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability') && found)
                break;
            //if the entry is for a different job
            // Fix for transfer work for pool resources - Cognizant Support
            if(isPoolDiary && de.Sub_Type__c == 'Availability'){
                   poolDiaryEntries.add(de);
            }
            // PRB00003771 starts-- The below fix has been done for the list index out of bounds issue which occurs when two jobs are booked continuously and we transfer the first job
            if((de.Job__c != theJob.Id) && (de.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'))&& found )
                break;
            // PRB00003771 ends-- The below fix has been done for the list index out of bounds issue which occurs when two jobs are booked continuously and we transfer the first job
            if(de.Sub_Type__c == skill && !found && de.Id == er.ent.Id ){
                found = true;
                // Fix for transfer work for pool resources - Cognizant Support
                if(isPoolDiary){
                    poolDiaryEntries.add(de);
                    continue;
                }
                system.debug(LoggingLevel.INFO,'before Reduction:'+de);               
                //move the end datetime only
                //reduce the reduction by any overbooked_hours value
                if(de.OverBooked_Hours__c != null){
                    if(de.OverBooked_Hours__c >= reduction){
                        de.Overbooked_Hours__c -= reduction;
                        return;
                    }else{
                        reduction -= de.Overbooked_Hours__c;
                        TotOBHours -= de.Overbooked_Hours__c; //Added By AshoK G
                        de.Overbooked_Hours__c = 0;
                    }
                }
                buildDiaryEntry(EmployeeId, de, reduction, false);
                system.debug(LoggingLevel.INFO,'de.start__c + de.end__c + de.hours_c'+de.Start__c+' '+de.End__c+' '+de.Hours__c);
                //PRB00033760
                if(system.label.Transfer_hours_reduction == 'on'){
                adj_hours = DateTimeHelper.subtractDate(de.End__c,de.Start__c);
                adj_de_endhrs = de.Hours__c;

                system.debug(LoggingLevel.INFO,'adj_date + adj_hours + adj_de_endhrs'+adj_date+' '+adj_hours+' '+adj_de_endhrs);
                
                if((de.Hours__c != adj_hours) && (adj_hours - de.Hours__c == 0.01) && (de.End__c != DateTimeHelper.addHoursToDT(de.start__c,adj_de_endhrs))){
                adj_date = DateTimeHelper.addHoursToDT(de.start__c,adj_de_endhrs);
                system.debug(LoggingLevel.INFO,'adj_date + adj_hours + adj_de_endhrs loop'+adj_date+' '+adj_hours+' '+adj_de_endhrs);
                de.End__c = adj_date;
                reduction = reduction+0.01;
                }
                }
                system.debug(LoggingLevel.INFO,'after Reduction:'+de);
                system.debug(LoggingLevel.INFO,'TotalOBHours+Reduction:'+totOBHours+' '+reduction);
               
                system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=561:'+reduction);
                
                //buildDiaryEntry(EmployeeId, de, reduction1, false);
            }else if(found){ //move any subsequent entries by the reduction amount if a match has been found
                    
                    // Fix for transfer work for pool resources - Cognizant Support
                       if(isPoolDiary){
                          continue;
                         }
                    //move start and end datetimes by reduction
                    //only allow 'full' movement of job items. If availability, just move start...
                    if(de.Job__c != null || de.Sub_Type__c == 'Availability'){
                    
                        buildDiaryEntry(EmployeeId, de, reduction, true);
                        //if an availability item is found stop processing diary entries as availability
                        // will be extended to match reduced hours
                        if(de.Sub_Type__c == 'Availability'){
                            //rjd - 2010-01-03 - surely this isn't required?? - See defect 359
                            //de.hours__c += reduction;
                            break;
                        }
                    }
                    if(de.Job__c != null)// move the end datetime if its a job element item
                        buildDiaryEntry(EmployeeId, de, reduction, false);

            }
            else{
//              if(debug)
 //                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'no match:-'+de.Sub_Type__c));
            }
        
        }

        //Added By Ashok G to adjust the overbooking hours gap.
        if(reduction > 0){
        
        System.debug(Logginglevel.info,'adj_date '+adj_date);
        System.debug(Logginglevel.info,'reduction within loop'+reduction);
        //PRB00033760
        if(system.label.Transfer_hours_reduction == 'on'){
        if(adj_date != null){
        System.debug(Logginglevel.info,'adj_date '+adj_date);
        reduction = reduction - 0.01;
        System.debug(Logginglevel.info,'reduction +totOBHours loop'+reduction+' '+totOBHours);
        }
        }
        updateDiaryEntry(EmployeeId,reduction,totOBHours);
        }
      // Fix for transfer work for pool resources - Cognizant Support
      
      if(poolDiaryEntries.size()>0){
        
         buildDiaryEntryForPool(EmployeeId, poolDiaryEntries, reduction);
        
      }

      system.debug(LOGGINGLEVEL.INFO,'-=-=-=-=-=645:'+entries);
    }
    /*
    Update the provided Diary Entry by the reduction amount.
    Boolean switch to set whether to update the start or end value
    */
    private void buildDiaryEntry(Id employeeId, Diary_Entry__c de, double reduction, boolean updateStart){
        DateTime dtNew;
        Week w = weeks.get(employeeId);
        DateTime dtOrig = updateStart ? de.Start__c : de.End__c;

        system.debug(LoggingLevel.INFO,'dtOrig' + dtOrig);
        Date theDate = Date.valueOf(dtOrig.format('yyyy-MM-dd'));
        Day currentDay = w.data.get(theDate);
        double redOrig = reduction;
        system.debug(LoggingLevel.INFO,'redOrig' + redOrig+' '+currentDay);
    
        system.debug(LoggingLevel.INFO, 'buildDiaryEntry: '+ de+'____reduction:'+reduction+'____updateStart:'+updateStart);
        //system.debug(LoggingLevel.INFO, '---------------------------DtOrig: ' + dtOrig);
        //system.debug(LoggingLevel.INFO, '---------------------------current day st: ' + currentDay.st);
        //system.debug(LoggingLevel.INFO, '---------------------------reduction: ' + reduction);
        //system.debug(LoggingLevel.INFO, '---------------------------subtract date: ' + DateTimeHelper.subtractDate(dtOrig,currentDay.st));
        
        //if the reduction is less than the working hours in the current day - no probs
        //system.debug('reduction11'+ reduction);

        system.debug(LoggingLevel.INFO,'DateTimeHelper.subtractDate(dtOrig,currentDay.st)' +currentDay.st+' '+ DateTimeHelper.subtractDate(dtOrig,currentDay.st));
        //To avoid null pointer exceptions-- Added By Ashok G
        double StartEndDiff = DateTimeHelper.subtractDate(dtOrig,currentDay.st);
        double diff = reduction-StartEndDiff;
        
        if(diff == 0.01 || diff == 0.02)
        StartEndDiff = reduction;
        
        if(reduction <= StartEndDiff){ //DateTimeHelper.subtractDate(dtOrig,currentDay.st)
            dtNew = DateTimeHelper.removeHoursFromDT(dtOrig, reduction );
            //system.debug('dtNew' + dtNew);
            if(updateStart){
                de.Start__c = dtNew;
                //system.debug('de.Start__cnew' + de.Start__c);
                //system.debug('reductionnew' + reduction);
                //need to extend the total hours accordingly
                //system.debug('de.Hours__c before' + de.Hours__c);
                de.Hours__c += reduction;
                //system.debug('de.Hours__c after' + de.Hours__c );
            }
            else{
                de.End__c = dtNew;
                //system.debug('de.End__c' + de.End__c);
                //need to reduce the total hours accordingly
                //system.debug('reduction2' + reduction);
                de.Hours__c -= reduction;
                //system.debug('de.Hours__c 2' + de.Hours__c);
            }
            system.debug(LoggingLevel.INFO, '1.return from buildDiaryEntry: '+ de);
            return;
        }
        //remove working hours of current day from reduction
        //system.debug('reduction12'+reduction);
        reduction -= DateTimeHelper.subtractDate(dtOrig,currentDay.st);
        //go to yesterday
        theDate = theDate.addDays(-1);
        currentDay = w.data.get(theDate);
        system.debug(LoggingLevel.INFO, 'week:'+w.data);
        system.debug(LoggingLevel.INFO, 'theDate:'+theDate);
        system.debug(LoggingLevel.INFO, 'currentDay:'+currentDay);
        //system.debug(LoggingLevel.INFO, 'currentDay.hoursInDay:'+currentDay.hoursInDay);
        system.debug(LoggingLevel.INFO, 'reduction:'+reduction);
        
        while (currentDay!= null && reduction > currentDay.hoursInDay){
            //take off the morning value for the start day
            // take off the evening value for the previous day
            // PRB00003771 starts-- The below fix has been done for the current day null issue in transfer work
            reduction -= currentDay.hoursInDay;
            //system.debug('reduction33' + reduction);
            theDate = theDate.addDays(-1);
            currentDay = w.data.get(theDate);
            // PRB00003771 starts-- The below fix has been done for the current day null issue in transfer work
        }
        
        //final datetime should be the end datetime - reduction...
        System.debug(LoggingLevel.INFO,currentDay+'######'+reduction);
        dtNew = DateTimeHelper.removeHoursFromDT(currentDay.en, reduction);
        system.debug('redOrig' + redOrig);
        if(updateStart){
            de.Start__c = dtNew;
            System.debug(currentDay+'######'+reduction);
            de.Hours__c += redOrig;
            system.debug(LoggingLevel.INFO,'de.Hours__c12' + de.Hours__c);
        }
        else{
            de.End__c = dtNew;
            de.Hours__c -= redOrig;
            system.debug(LoggingLevel.INFO,'de.Hours__c13' + de.Hours__c);
        }
        
        system.debug(LoggingLevel.INFO, '2.return from buildDiaryEntry: '+ de);
        return;
        
    }
   
   
   //Update the provided Diary Entry by the added amount.
    //Boolean switch to set whether to update the start or end value
   /*
    Update the provided Diary Entry by the reduction amount.
    Boolean switch to set whether to update the start or end value
    */
    private void buildDiaryEntry1(Id employeeId, Diary_Entry__c de, double reduction, boolean updateStart){
        DateTime dtNew;
        Week w = weeks.get(employeeId);
        DateTime dtOrig = updateStart ? de.Start__c : de.End__c;
        //system.debug('dtOrig' + dtOrig);
        Date theDate = Date.valueOf(dtOrig.format('yyyy-MM-dd'));
        Day currentDay = w.data.get(theDate);
        double redOrig = reduction;
        system.debug(LoggingLevel.INFO,'redOrig' + redOrig+' '+currentDay);
    
        system.debug(LoggingLevel.INFO, 'buildDiaryEntry: '+ de+'____reduction:'+reduction+'____updateStart:'+updateStart);
        //system.debug(LoggingLevel.INFO, '---------------------------DtOrig: ' + dtOrig);
        //system.debug(LoggingLevel.INFO, '---------------------------current day st: ' + currentDay.st);
        //system.debug(LoggingLevel.INFO, '---------------------------reduction: ' + reduction);
        //system.debug(LoggingLevel.INFO, '---------------------------subtract date: ' + DateTimeHelper.subtractDate(dtOrig,currentDay.st));
        
        //if the reduction is less than the working hours in the current day - no probs
        //system.debug('reduction11'+ reduction);
        //system.debug('DateTimeHelper.subtractDate(dtOrig,currentDay.st)' + DateTimeHelper.subtractDate(dtOrig,currentDay.st));
        if(reduction <= DateTimeHelper.subtractDate(currentDay.en,dtOrig)){
            dtNew = DateTimeHelper.addHoursToDT(dtOrig, reduction );
            //system.debug('dtNew' + dtNew);
            if(updateStart){
                de.Start__c = dtNew;
                //system.debug('de.Start__cnew' + de.Start__c);
                //system.debug('reductionnew' + reduction);
                //need to extend the total hours accordingly
                //system.debug('de.Hours__c before' + de.Hours__c);
                de.Hours__c -= reduction;
                //system.debug('de.Hours__c after' + de.Hours__c );
            }
            else{
                de.End__c = dtNew;
                //system.debug('de.End__c' + de.End__c);
                //need to reduce the total hours accordingly
                //system.debug('reduction2' + reduction);
                de.Hours__c += reduction;
                //system.debug('de.Hours__c 2' + de.Hours__c);
            }
            system.debug(LoggingLevel.INFO, '1.return from buildDiaryEntry1: '+ de);
            return;
        }
        //remove working hours of current day from reduction
        //system.debug('reduction12'+reduction);
        reduction -= DateTimeHelper.subtractDate(currentDay.en,dtOrig);
        //go to yesterday
        theDate = theDate.addDays(1);
        currentDay = w.data.get(theDate);
        system.debug(LoggingLevel.INFO, 'week:'+w.data);
        system.debug(LoggingLevel.INFO, 'theDate:'+theDate);
        system.debug(LoggingLevel.INFO, 'currentDay:'+currentDay);
        //system.debug(LoggingLevel.INFO, 'currentDay.hoursInDay:'+currentDay.hoursInDay);
        system.debug(LoggingLevel.INFO, 'reduction:'+reduction);
        
        while (currentDay!= null && reduction > currentDay.hoursInDay){
            //take off the morning value for the start day
            // take off the evening value for the previous day
            // PRB00003771 starts-- The below fix has been done for the current day null issue in transfer work
            reduction -= currentDay.hoursInDay;
            //system.debug('reduction33' + reduction);
            theDate = theDate.addDays(1);
            currentDay = w.data.get(theDate);
            // PRB00003771 starts-- The below fix has been done for the current day null issue in transfer work
        }
        
        //final datetime should be the end datetime - reduction...
        System.debug(LoggingLevel.INFO,currentDay+'######'+reduction);
        dtNew = DateTimeHelper.addHoursToDT(currentDay.st, reduction);
        system.debug('redOrig' + redOrig);
        if(updateStart){
            de.Start__c = dtNew;
            System.debug(currentDay+'######'+reduction);
            de.Hours__c -= redOrig;
            system.debug(LoggingLevel.INFO,'de.Hours__c12' + de.Hours__c);
        }
        else{
            de.End__c = dtNew;
            de.Hours__c += redOrig;
            system.debug(LoggingLevel.INFO,'de.Hours__c13' + de.Hours__c);
        }
        
        system.debug(LoggingLevel.INFO, '2.return from buildDiaryEntry: '+ de);
        return;
        
    }
   //By Ashok G
   private void updatediaryEntry(Id EmployeeId,double rd,double totOb){
      Diary_Entry__c pDE;
      boolean found = false;
      List<Diary_Entry__c> entries = weeks.get(EmployeeId).week.Diary_Entries__r;
      system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=-=835:'+entries);
      double actrd = rd;
      double adj_hours_1;
      Double adj_de_endhrs_1;
      
      
      for(Diary_Entry__c det: entries){
      
      
          //don't do anything after an unavailability record is found after the 
            //diary entry has been moved.
            if(det.Sub_Type__c == 'NWD - Working')
            continue;
            
            if(det.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability') && found)
                break;
            
            // PRB00003771 starts-- The below fix has been done for the list index out of bounds issue which occurs when two jobs are booked continuously and we transfer the first job
            if((det.Job__c != theJob.Id) && (det.RecordTypeId == RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking'))&& found )
                break;
         
          if(det.overbooked_Hours__c !=null && det.Job__c == theJob.Id){
          system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=-=->854:'+det);
             if(rd>0 && det.overBooked_Hours__c >0){
                 if(det.overbooked_Hours__c >= rd){
                       //det.end__c = DateTimeHelper.addHoursToDT(det.end__c,reduction);
                       system.debug(LoggingLevel.INFO,'-=-=-=-=-=--=-=line 840:'+det.end__c);
                       system.debug(LoggingLevel.INFO,'-=-=-=-=-=--=-=line 839:'+rd+' '+det+' '+PDE+' '+actrd);      
                        //det.hours__c = det.Hours__c + rd;
                        det.OverBooked_Hours__c -= rd;
                        totOb -= rd;
                        if(pDE !=null){
                        buildDiaryEntry1(EmployeeId, det, actrd, true);
                        buildDiaryEntry1(EmployeeId, det, (actrd+rd), false);
                        
                        if(system.label.Transfer_hours_reduction == 'on')
                        actrd = actrd+rd;
                        
                        }else{
                        buildDiaryEntry1(EmployeeId, det, rd, false);
                        }
                        rd = 0; 
                        found = true;
                 }else{
                     double deOBHours = det.OverBooked_Hours__c;
                     rd -= det.Overbooked_Hours__c;
                     TotOB -= det.Overbooked_Hours__c; 
                     det.Overbooked_Hours__c = 0;
                     found = true;
                    if(pDE !=null){
                        system.debug(LoggingLevel.INFO,'-=-=-=-=-=--=-=line 805:'+det+' '+actrd);
                        buildDiaryEntry1(EmployeeId, det, actrd, true); //Adjust the StartTime with the end time of previous Entry.
                        buildDiaryEntry1(EmployeeId, det, (actrd+deOBHours), false); //Add OverBooking Hours to the Det.
                        //PRB00033760
                        if(system.label.Transfer_hours_reduction == 'on'){
                        actrd = actrd + deOBHours;
                        system.debug(LoggingLevel.info,'actrd changed '+actrd);
                        }else
                        actrd = deOBHours;
                     }else{
                        system.debug(LoggingLevel.INFO,'-=-=-=-=-=--=-=line 808:'+det);
                        actrd = deOBHours;
                        buildDiaryEntry1(EmployeeId, det, deOBHours, false);
                        system.debug(LoggingLevel.INFO,'-=-=-=-=-=--=-=line 808:'+det);
                     }
                 }
                 pDE = det;
             }else if(found){
                 system.debug(LoggingLevel.INFO,'-=-=-=-=-=-=>+I am Inside');
                 if(det.Job__c != null || det.Sub_Type__c == 'Availability'){
                        
                        buildDiaryEntry1(EmployeeId, det, actrd, true);
                        //if an availability item is found stop processing diary entries as availability
                        // will be extended to match reduced hours
                        if(det.Sub_Type__c == 'Availability'){
                            //rjd - 2010-01-03 - surely this isn't required?? - See defect 359
                            //de.hours__c += reduction;
                            break;
                        }
                    }
                    if(det.Job__c != null)// move the end datetime if its a job element item
                     buildDiaryEntry1(EmployeeId, det, actrd, false);
             
             }
             
          }else if(found){
          
                    
                    //move start and end datetimes by reduction
                    //only allow 'full' movement of job items. If availability, just move start...
                    if(det.Job__c != null || det.Sub_Type__c == 'Availability'){
                    
                        buildDiaryEntry1(EmployeeId, det, actrd, true);
                        //if an availability item is found stop processing diary entries as availability
                        // will be extended to match reduced hours
                        if(det.Sub_Type__c == 'Availability'){
                            //rjd - 2010-01-03 - surely this isn't required?? - See defect 359
                            //de.hours__c += reduction;
                            break;
                        }
                    }
                    if(det.Job__c != null)// move the end datetime if its a job element item
                     buildDiaryEntry1(EmployeeId, det, actrd, false);
             
          }
          //PRB00033760
          if(system.label.Transfer_hours_reduction == 'on'){
          adj_hours_1 = 0.000;
          adj_de_endhrs_1 = 0.000;
          adj_hours_1 = DateTimeHelper.subtractDate(det.End__c,det.Start__c);
          adj_de_endhrs_1 = det.Hours__c;
          system.debug(LoggingLevel.INFO,'adj_hours_1 + adj_de_endhrs_1'+' '+adj_hours_1+' '+adj_de_endhrs_1);
          if((det.Hours__c != adj_hours_1) && ((adj_hours_1 - det.Hours__c == 0.01)||(adj_hours_1 - det.Hours__c == -0.01)) && (det.End__c != DateTimeHelper.addHoursToDT(det.start__c,adj_de_endhrs_1))){
          det.End__c = DateTimeHelper.addHoursToDT(det.start__c,adj_de_endhrs_1);
          actrd = actrd - (adj_hours_1 - det.Hours__c);
          system.debug(LoggingLevel.INFO,'reduction changed within loop '+det.start__c+' '+det.End__c+' '+actrd);
          }}
         }
      
   
   }
   
    // Fix for transfer work for pool resources - Cognizant Support
    // This method and subsequent code in this class is handling pool as well as non pool diaries in similar way.
    // We are diverting the code so that logic for pool diaries is kept separate from non-pool diaries. 
        
     private void buildDiaryEntryForPool(Id employeeId, List<Diary_Entry__c> poolDiaryEntries, double reduction){
            
        DateTime dtNew;
        Week w = weeks.get(employeeId);
        Week__c week = w.week;
        DateTime dtOrig;
        Date theDate;
        Day currentDay;
        double redOrig = reduction;

        for(Diary_Entry__c de:poolDiaryEntries){
            
            dtOrig = de.End__c;
            system.debug(LoggingLevel.INFO,'dtOrig'+dtOrig);
            theDate = Date.valueOf(dtOrig.format('yyyy-MM-dd'));
            system.debug(LoggingLevel.INFO,'theDate'+theDate);
            currentDay = w.data.get(theDate);
            system.debug(LoggingLevel.INFO, 'Pool diary entry info: '+ de+'____reduction:'+reduction);
            system.debug(LoggingLevel.INFO, 'Pool diary entry info: '+ de+'---currentDay'+currentDay);
            
           if(de.Sub_Type__c == 'Availability'){
              de.Hours__c += reduction;
              system.debug(LoggingLevel.INFO,'de.Hours__c--'+de.Hours__c);
              continue;
           }
           system.debug('reduction --'+reduction);
           system.debug('DateTimeHelper.subtractDate(dtOrig,currentDay.st)--'+DateTimeHelper.subtractDate(dtOrig,currentDay.st));
         
           //if the reduction is less than the working hours in the current day - no probs
           if(reduction <= DateTimeHelper.subtractDate(dtOrig,currentDay.st)){
               dtNew = DateTimeHelper.removeHoursFromDT(dtOrig, reduction );
               if (dtNew > de.Start__c) // BGSAMS support on 21-10-2011 to prevent the validation failure while transferring work from pooled employees
               {
               de.End__c = dtNew;
               
               }
               system.debug('de.End__c--'+de.End__c);
               de.Hours__c -= reduction;
               system.debug('de.Hours__c1--'+de.Hours__c);
            }else{
               de.Hours__c -= reduction;
               system.debug('de.Hours__c2--'+de.Hours__c);
            }
            
            if(getOffsetFromStartOfWeek(de.Start__c)==0){
                    week.Monday_Booked_Hours__c -= reduction; 
            }else if(getOffsetFromStartOfWeek(de.Start__c)==1){
                    week.Tuesday_Booked_Hours__c -= reduction; 
            }else if(getOffsetFromStartOfWeek(de.Start__c)==2){
                    week.Wednesday_Booked_Hours__c -= reduction; 
            }else if(getOffsetFromStartOfWeek(de.Start__c)==3){
                    week.Thursday_Booked_Hours__c -= reduction; 
            }else if(getOffsetFromStartOfWeek(de.Start__c)==4){
                    week.Friday_Booked_Hours__c -= reduction; 
            }else if(getOffsetFromStartOfWeek(de.Start__c)==5){
                    week.Saturday_Booked_Hours__c -= reduction; 
            }else if(getOffsetFromStartOfWeek(de.Start__c)==6){
                    week.Sunday_Booked_Hours__c -= reduction; 
            }
            
        }
        
        update week;
        
    }   
    
  
  // This method is used for returning difference between current date & start of week for that date.
 
  public static Integer getOffsetFromStartOfWeek(Datetime dt){
    
     return ((dt.date().toStartOfWeek()).toStartOfWeek()).daysBetween(dt.date());
    
  }
  
  // This method ends here. 
    
    /*
    This holds the start and end dates for the provided ShiftPatterns
    data hold day objects for each day with the actual date being the key to allow lookup of day object
    Each week object maps to a supplied Week__c object which is stored against the week object for reference
    */
    public class Week{
        public Week__c week{get; set;}
        Map<Date,day> data{get; set;}
        DateTime startDT{get; set;}
        DateTime endDT{get; set;}
    
        public Week(Week__c week){
            this.week = week;
            data = new Map<Date,day>();
            buildDates();
        }
        
        private void buildDates(){
            data.put(week.Week_Commencing__c, buildDateEntry(week.Week_Commencing__c, week.Monday_Start_Time__c, week.Monday_End_Time__c));
            data.put(week.Week_Commencing__c+1, buildDateEntry(week.Week_Commencing__c+1, week.Tuesday_Start_Time__c, week.Tuesday_End_Time__c));
            data.put(week.Week_Commencing__c+2, buildDateEntry(week.Week_Commencing__c+2, week.Wednesday_Start_Time__c, week.Wednesday_End_Time__c));
            data.put(week.Week_Commencing__c+3, buildDateEntry(week.Week_Commencing__c+3, week.Thursday_Start_Time__c, week.Thursday_End_Time__c));
            data.put(week.Week_Commencing__c+4, buildDateEntry(week.Week_Commencing__c+4, week.Friday_Start_Time__c, week.Friday_End_Time__c));
            data.put(week.Week_Commencing__c+5, buildDateEntry(week.Week_Commencing__c+5, week.Saturday_Start_Time__c, week.Saturday_End_Time__c));
            data.put(week.Week_Commencing__c+6, buildDateEntry(week.Week_Commencing__c+6, week.Sunday_Start_Time__c, week.Sunday_End_Time__c));
            
            startDT = data.get(week.Week_Commencing__c).st;
            
            if(week.Sunday_End_Time__c != null)
                endDT = data.get(week.Week_Commencing__c+6).en;
            else if(week.Saturday_End_Time__c != null)
                endDT = data.get(week.Week_Commencing__c+5).en;
            else if(week.Friday_End_Time__c != null)
                endDT = data.get(week.Week_Commencing__c+4).en;
            else if(week.Thursday_End_Time__c != null)
                endDT = data.get(week.Week_Commencing__c+3).en;
            else if(week.Wednesday_End_Time__c != null)
                endDT = data.get(week.Week_Commencing__c+2).en;
            else if(week.Tuesday_End_Time__c != null)
                endDT = data.get(week.Week_Commencing__c+1).en;
            else
                endDT = data.get(week.Week_Commencing__c).en;
            
        }
        
        private day buildDateEntry(Date theDate, string theStart, string theEnd){
            //if a gap in the shift pattern then create a day of 0 length
            if(theStart == null && theEnd == null){
                theStart = theEnd = '00:00';
            }
            else{
                if(theStart == null || theStart == '')
                    theStart = '00:00';
                if(theEnd == null || theEnd == '')
                    theEnd = '23:59';
            }
            return new Day(
            DateTime.parse(theDate.format().split(' ')[0]+' '+theStart),
            DateTime.parse(theDate.format().split(' ')[0]+' '+theEnd)
            );
        }
        
    }
    /*
    Class holds the day information for each day of the week.
    st = Start dateTime
    en = End dateTime
    hoursinDay = Working hours in the day (e.g. 09:00-->18:00 = 9)
    morningGap = Time from midnight to day start
    eveningGap = Time from day end to midnight
    */
    public class day{
        public DateTime st{get; private set;}
        public DateTime en{get; private set;}
        public Double hoursInDay{get; private set;}
        public Double morningGap{get; private set;}
        public Double eveningGap{get; private set;}
        
        public day(DateTime st, DateTime en){
            this.st = st;
            this.en = en;
            //en = en.addSeconds(59);
            hoursInDay = DateTimeHelper.subtractDate(en, st);
            morningGap = DateTimeHelper.subtractDate(st, DateTime.valueOf(st.format('yyyy-MM-dd 00:00:00')));
            eveningGap = DateTimeHelper.subtractDate(DateTime.valueOf((st+1).format('yyyy-MM-dd 00:00:00')), en);
        }       
    
    }

   
    
    ////////////////////////
    //                    //
    //    Test Methods    //
    //                    //
    ////////////////////////
    
   @isTest
    private static ID TestScenarioCreateDistrict(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        return district.ID;
    }
    
         
    public static Account TestScenarioCreateAccount(Id districtID){
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=districtID, Code__c='yyyyyyyy');             
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        return Acc;
    }
    
            
    public static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }         
    //Test class to ensure the page renders as expected
   public static TestMethod void tester(){
    
    //create a new job
    //mechhours = 12
    //only assign 2.8 hours to employee
    ID districtID = TestScenarioCreateDistrict();
    Account Acc = TestScenarioCreateAccount(districtID);
    Opportunity chi = TestScenarioCreateOppty(Acc);
   
    Job__c j = new Job__c();
    j.CHI_Lead__c = chi.Id;
    j.Status__c = 'Planned';
    j.Mechanical_Hours__c = 12;
    j.Customer_Preferred_Date__c = System.today();
    insert j;
    
    
    List<Employee_Skills__c> skills = [Select e.Skill_Name__c, e.Employee__c, e.Employee__r.Supplier__c From Employee_Skills__c e where skill_Name__c= 'Mechanical' and e.Employee__r.Supplier__c!= null limit 1];
    Shift_Pattern__c shift = new Shift_Pattern__c(Name='Testing Shift Pattern1', Pool_Shift_Pattern__c = false, Total_Hours__c = '45',
                                                    Monday_Start_Time__c = '08:00', Monday_End_Time__c = '17:00',
                                                    Tuesday_Start_Time__c = '08:00', Tuesday_End_Time__c = '17:00',
                                                    Wednesday_Start_Time__c = '08:00', Wednesday_End_Time__c = '17:00',
                                                    Thursday_Start_Time__c = '08:00', Thursday_End_Time__c = '17:00',
                                                    Friday_Start_Time__c = '08:00', Friday_End_Time__c = '17:00',
                                                    Saturday_Start_Time__c = null, Saturday_End_Time__c = null,
                                                    Sunday_Start_Time__c = null, Sunday_End_Time__c = null);
    Database.insert(shift);
    
    Supplier__c supplier = new supplier__c(Name='Test supplier',Type__c='Resource',Supplier_Num__c='A1234',Resource_Type__c='Resource');
    insert supplier;
          
    Employee__c e = new Employee__c(
        Name='rjd Test', 
        First_Name__c='rjd', 
        Last_Name__c='Test', 
        Employee_Number__c='abc123', 
        Resource_Type__c='Installer',
        Pool_Diary__c = false,
        Supplier__c=supplier.Id);
    insert e;
    
    Employee_Skills__c es = new Employee_Skills__c(Employee__c = e.Id, Skill_Name__c='Mechanical');
    insert es; 
    
    Week__c wk;
    //add Mechanical entries
  
            wk = new Week__c(
                Employee__c = e.Id,
                Week_Commencing__c = System.today().addDays(20).toStartOfWeek(),
                Shift_Pattern__c = shift.Id,
                Monday_Max_Hours__c = 9.0,
                Tuesday_Max_Hours__c = 9.0,
                Wednesday_Max_Hours__c = 9.0,
                Thursday_Max_Hours__c = 9.0,
                Friday_Max_Hours__c = 9.0,
                Saturday_Max_Hours__c = 9.0,
                Sunday_Max_Hours__c = 9.0
            );
    
    insert wk;
    
    List<Diary_Entry__c> diaryEntries = new List<Diary_Entry__c>();
    DateTime dt;
    dt = DateTime.parse(wk.Week_Commencing__c.format()+' '+ shift.Monday_Start_Time__c);
    diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Mechanical',
        Job__c = j.Id,
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 27),//adding a bit more to allow move overnight
        Hours__c = 12,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking')
    ));
    
    dt = DateTimeHelper.addHoursToDT(dt, 27);
 
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = DateTimeHelper.addHoursToDT(dt, 0) ,
        End__c = DateTimeHelper.addHoursToDT(dt, 1.5),
        Hours__c = 1.5,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, 1.5);
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Unavailability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 0.5),
        Hours__c = 0.5,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability')
    ));
   
   dt = DateTimeHelper.addHoursToDT(dt, 0.5);
   
   diaryEntries.add(new Diary_Entry__c(
        Week__c = wk.Id,
        Sub_Type__c = 'Availability',
        Start__c = dt ,
        End__c = DateTimeHelper.addHoursToDT(dt, 2),
        Hours__c = 2.0,
        RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability')
    ));
   
   insert diaryEntries;
   
    
    
    List<Job_Element__c> elements = new List<Job_Element__c>(); 
    elements.add(new Job_Element__c(
        Type__c = 'Work',
        Status__c = 'Active',
        Units__c = 3.6,
        Skill__c = 'Mechanical',
        Line_Item_Id__c = 'abc123',
        Product_Id__c = 'abc123',
        Job__c = j.Id,
        Current_Supplier__c = 'ABC',
        Current_Supplier_Number__c = '123'
    
    ));
    
    insert elements;
    
    diaryEntries = [Select Id, Job__c, RecordTypeId, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where  Week__c =: wk.Id];
    
   
    
    
    //now do the test
    //start with return work
    
    //invalid standard controller
    InstallPlanningReturnTransferController con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(wk));
    ApexPages.CurrentPage().getParameters().put('type','Transfer');
    con = new InstallPlanningReturnTransferController(new ApexPages.Standardcontroller(j));
    
    
    System.assertEquals(null, con.userMessage);
    System.assertEquals(null, con.showUserMessage);
    System.assertEquals(false, con.isAvailabilityRendered);
    System.AssertEquals(1, con.Items.size());
    System.AssertEquals(0, con.selectedItems.size());
    System.AssertEquals('start', con.stepIndex);
    System.AssertEquals('Transfer', con.wizardType);
    
    
    System.AssertEquals(0, con.getBreakdown().size());
    con.returnToDefine();
    System.AssertEquals('define', con.stepIndex);
    con.returnToStart();
    System.AssertEquals('start', con.stepIndex);
    con.returnToJob();
    
    con.defineWork();
    
    //select a job element to return
    for(InstallPlanningReturnTransferController.JobElementItem je : con.Items){
        je.isSelected = true;
    }
    con.defineWork();
    System.AssertEquals('Mechanical', con.getHoursIds());
    
    
    System.AssertEquals('define', con.stepIndex);
    System.AssertEquals(1, con.selectedItems.size());
    
    InstallPlanningReturnTransferController.HoursInformation hi = con.getBreakdown().get(0);
   List<InstallPlanningReturnTransferController.EntryRecord> records= hi.entries;
    //System.AssertEquals(1, records.size());
    //records.get(0).reduction = 1.3;
    //con.confirm();
    
    //con.confirmTransfer();
    
    records.get(0).reduction = 10;
        diaryEntries = [Select Id, Job__c, Record_Type__c, Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where Week__c =: wk.Id];
    
  /*    
    system.debug(LoggingLevel.INFO, 'Old Diary Entries-');
    for(Diary_Entry__c en : diaryEntries){
        system.debug(LoggingLevel.INFO, 'Start'+en.Start__c);
        system.debug(LoggingLevel.INFO, 'End'+en.End__c);
        system.debug(LoggingLevel.INFO, 'Hours'+en.Hours__c);
        system.debug(LoggingLevel.INFO, 'Type'+en.Record_Type__c);
        
    }
    
    
        diaryEntries = [Select Id, Job__c, RecordTypeId, d.Record_Type__c , Sub_Type__c, Start__c, End__c, Hours__c, Employee_Name__c 
            From Diary_Entry__c d where Week__c =: wk.Id];
        system.debug(LoggingLevel.INFO, 'New Diary Entries-');
        for(Diary_Entry__c en : diaryEntries){
            system.debug(LoggingLevel.INFO, 'Start'+en.Start__c);
            system.debug(LoggingLevel.INFO, 'End'+en.End__c);
            system.debug(LoggingLevel.INFO, 'Hours'+en.Hours__c);
            system.debug(LoggingLevel.INFO, 'Type'+en.Record_Type__c);
            
        }
  */ 
       Map<String, InstallPlanningReturnTransferController.HoursInformation> tData = new Map<String, InstallPlanningReturnTransferController.HoursInformation>();
       
       for(InstallPlanningReturnTransferController.HoursInformation h : con.getBreakdown()){
        h.Job.Installation_Date__c = System.today().addDays(20).toStartOfWeek();
        h.Job.Named_Employee__c = wk.Employee__c;
        tData.put(h.skill, h);
       }
   
        //InstallPlanningRTHelper help = new InstallPlanningRTHelper();
        //help.updateDiaryEntries(j, tData);
    
    

  //    con.checkAvailability();
  //    con.confirmTransfer();
    
  //    hi.RemoveDiaryEntry(diaryEntries[0]);
        
        
        
    
   }

  public map<string, list<string>> calculateIndayTravel(Diary_Entry__c Availability, Job__c job, double hours)
  {
    list<string> direction = new list<string>();
    map<string, list<string>> indayTravel = new map<string, list<string>>();
    //check is this employee is already travelling for this job in the same day?
    {
        for(Diary_Entry__c travelEntry : [select id, Start__c, End__c from Diary_Entry__c where Week__c =: Availability.Week__c and Sub_type__c = 'Travel Time' and (Job__c =:job.Id or Travel_Job__c = :job.Id)])
        {
            return indayTravel;
        }
        
    }
    Search_Result__c sr = new Search_Result__c();
    sr.Start_Date_Time__c = Availability.Start__c;
    sr.Diary_Entry_ID__c= Availability.id;
    sr.End_Date_Time__c = DateTimeHelper.addWorkingHoursToDateTime(sr.Start_Date_Time__c, hours, Availability);
    //sr.Job__c = job.Id;
    if(sr.End_Date_Time__c > Availability.End__c)
    {
        sr.End_Date_Time__c = Availability.End__c;
    }
    
    String jobPostCode = job.Install_Postcode__c;
       if(system.label.Bing_Google_API=='Bing'&&job.latitude__latitude__s!=null)
       JobPostCode = String.valueof(job.latitude__latitude__s)+','+string.valueof(job.latitude__longitude__s);
          
   indayTravel = Utilities.calcluateIndayJobTime(new list<Search_Result__c>{sr}, jobPostCode, Availability.Week__c);      
    return indayTravel;
  }

}