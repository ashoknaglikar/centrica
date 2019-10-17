public with sharing class UnavailabilityManager {
    
    /**************************************************************************
    * method name:  removeUnavailability
    * purpose:      given a list of unavailability records, delete the records
    *               from the database and manage the Availability gaps
    * return:       void
    * parameter(s): List<Diary_Entry__c> unavsToDelete - The Diary Entry Records
    *               that need to be deleted
    * exception(s):
    *
    **************************************************************************/
    public static void removeUnavailability(List<Diary_Entry__c> unavsToDelete)
    {
        JobBookingManager.removeMultipleDiaryEntries(unavsToDelete, false);
    }
    /**************************************************************************
    * method name:  createUnavailability
    * purpose:      given a list of diary entries of type unavailability, 
    *               create the records in the database and manage the 
    *               Availability gaps
    * return:       void
    * parameter(s): List<Diary_Entry__c> unavsToCreate - The Diary Entry Records
    *               that need to be created
    * exception(s):
    *
    **************************************************************************/
    public static void createUnavailability(List<Diary_Entry__c> unavsToCreate) 
    {
        system.debug('##Unavalability list##'+unavsToCreate);
        Map<Id, List<Diary_Entry__c>> newUnavsByWeek = new Map<Id, List<Diary_Entry__c>>();
        
        for(Diary_Entry__c unavToCreate : unavsToCreate)
        {
            if(newUnavsByWeek.containsKey(unavToCreate.week__c))
            {
                newUnavsByWeek.get(unavToCreate.week__c).add(unavToCreate);
            }
            else
            {
                List<Diary_Entry__c> unavs = new List<Diary_Entry__c>();
                unavs.add(unavToCreate);
                newUnavsByWeek.put(unavToCreate.week__c, unavs);
            }
        }
        system.debug('##newUnavs'+newUnavsByWeek );
        //query to get all diary entries for every week obtained above
        Map<Id, Week__c> allEntriesByWeek = new Map<Id, Week__c>();
        allEntriesByWeek = JobBookingManager.getDiaryEntryDataForWeeks(newUnavsByWeek.keySet());
        
        List<Week__c> weeksList = new List<Week__c>(allEntriesByWeek.values());
        
        //lists to hold the enries for upsert and deletion
        List<Diary_Entry__c> entriesForDeletion = new List<Diary_Entry__c>();
        List<Diary_Entry__c> entriesForUpsert = new List<Diary_Entry__c>();
        
       // list<Diary_Entry__c> newsplitUnavailablitylist= new list<Diary_Entry__c>();
        if(unavsToCreate[0].sub_Type__c == 'NWD - Working' || unavsToCreate[0].sub_Type__c == 'NWD - Non Working') 
        {  
            list<Diary_Entry__c> newsplitUnavailablitylist1 = new list<Diary_Entry__c>();
            
            //create a week manager for each week
            for(Id weekId : newUnavsByWeek.keySet())
            {
                system.debug('I am Inside');
                Week__c week = allEntriesByWeek.get(weekId);
                list<diary_entry__c> EntrytoSplit= new list<diary_entry__c>();
                for(diary_entry__c a1: newUnavsByWeek.get(weekid))
                {
                    EntrytoSplit.add(a1);
                }
                system.debug('##abcd'+EntrytoSplit);
                for(diary_entry__c doit: EntrytoSplit){
                    system.debug('I am inside EntrytoSplit');
                   
                    if((doit.start__c).date().tostartofweek() == (doit.end__c).date().tostartofweek()){
                       DateTime myDateTime = (DateTime) doit.start__c;
                       datetime myendtime = (datetime) doit.end__c; 
                       //SplitUnavailableDiaryEntry class splits the Unavailablities into multiple entries 
                       //expecting to have start datetime and end datetime along with the diaryentry as parmeters.
                       //And returns List of diary entries..
                       newsplitunavailablitylist1.addAll(SplitUnavailableDiaryEntry.splitDiaryEntry(myDateTime,myendtime,doit)); 
                        
                    }
                         
                   }
             }
            system.debug('-------->newlist'+newsplitunavailablitylist1);
            //system.debug('##allentriesbyweek'+allentriesbyweek1);
            //map to hold the list of entry details for each week
            Map<Id, List<Diary_Entry__c>> newUnavsByWeek1 = new Map<Id, List<Diary_Entry__c>>();
            //map to hold the list of all diary entries for each week
            //Map<Id, List<Diary_Entry__c>> allEntriesByWeek = new Map<Id, List<Diary_Entry__c>>();
            
            //group the unavailability data by week
            for(Diary_Entry__c unavToCreate : newsplitUnavailablitylist1)
            {   
                system.debug('##Inside of new list');
                if(newUnavsByWeek1.containsKey(unavToCreate.week__c))
                {
                    newUnavsByWeek1.get(unavToCreate.week__c).add(unavToCreate);
                }
                else
                {
                    List<Diary_Entry__c> unavs1 = new List<Diary_Entry__c>();
                    unavs1.add(unavToCreate);
                    newUnavsByWeek1.put(unavToCreate.week__c, unavs1);
                }
            }
    
            //query to get all diary entries for every week obtained above
           //Map<Id, Week__c> allEntriesByWeek = new Map<Id, Week__c>();
            //allEntriesByWeek = JobBookingManager.getDiaryEntryDataForWeeks(newUnavsByWeek.keySet());
            
            Map<Id, Week__c> allEntriesByWeek1 = new Map<Id, Week__c>();
            allEntriesByWeek1 = JobBookingManager.getDiaryEntryDataForWeeks(newUnavsByWeek1.keySet());
            
            List<Week__c> weeksList1 = new List<Week__c>(allEntriesByWeek1.values());
            
                   
            //create a week manager for each week
               for(Id weekId : newUnavsByWeek1.keySet())
                {
                    system.debug('##insideof new list keyset');
                    Week__c week = allEntriesByWeek.get(weekId);
                    system.debug('diaryentriesByweek'+week.diary_entries__r);
                    
                    WeekManager wm = new WeekManager(weekId, week.Diary_Entries__r, week);
                    
                    //create the diary entries
                    wm.createUnavailability(newUnavsByWeek1.get(weekId)); //todo
                    //collect the list of updated / new entries
                    //collect the list of entries for deletion
                    
                    //entriesForUpsert.addAll(wm.getWeeksEntriesList(true));
                    // gjb 2010-02-09 changing the boolean parameter in this call. This will stop 
                    entriesForUpsert.addAll(wm.getWeeksEntriesList(false));         
                    entriesForDeletion.addAll(wm.getWeeksEntriesForDeletion());
                } 
            
              
            //do the DML
            system.debug('##entriesForDeletion :' + entriesForDeletion);
            system.debug('##entriesForUpsert :' + entriesForUpsert);
            // PRB00030471
            for(Integer i= (entriesForUpsert .size()-1) ; i>= 0 ; i--){
            if(entriesForUpsert[i].sub_Type__c == 'NWD - Non Working' && entriesForUpsert[i].Hours__c == 0.0){            
            System.debug(LoggingLevel.INFO, 'entered the loop to delete unavailability with 0 hours '+entriesForUpsert[i]);
            entriesForUpsert.remove(i);
            }
            }
            //PRB00030471
            System.debug(LoggingLevel.INFO, 'entriesForUpsert updated '+entriesForUpsert);
        }
        else
        {
            //create a week manager for each week
            for(Id weekId : newUnavsByWeek.keySet())
            {
                Week__c week = allEntriesByWeek.get(weekId);
                WeekManager wm = new WeekManager(weekId, week.Diary_Entries__r, week);
                
                //create the diary entries
                wm.createUnavailability(newUnavsByWeek.get(weekId)); //todo
                //collect the list of updated / new entries
                //collect the list of entries for deletion
                
                //entriesForUpsert.addAll(wm.getWeeksEntriesList(true));
                // gjb 2010-02-09 changing the boolean parameter in this call. This will stop 
                entriesForUpsert.addAll(wm.getWeeksEntriesList(false));         
                entriesForDeletion.addAll(wm.getWeeksEntriesForDeletion());
            }       
        
        }
        List<Diary_Entry__c> NewEntriesForDeletion = new List<Diary_Entry__c>();
        if(entriesForDeletion.size()>0){
           for(Diary_Entry__c rmvEntryNotHavingID: entriesForDeletion){
              if(rmvEntryNotHavingID.ID == NULL || rmvEntryNotHavingID.Name == NULL){
                //skip the entry from deletion
              }
              else{
                 NewEntriesForDeletion.add(rmvEntryNotHavingID);
              }
           }
        }
        
        delete NewEntriesForDeletion ;
        upsert entriesForUpsert;
    }
    
    public static void StackUnavailability(List<Diary_Entry__c> consolidatedLst)    
    {
        List<Diary_Entry__c> UpdatingLst;
        list<id> weekids = new list<Id>();
        list<Diary_Entry__c> deList2;
        Map<Id,list<Diary_Entry__c>> stack_WeekMap = new Map<Id, list<Diary_Entry__c>>();
        
        Map<Id, list<Diary_Entry__c>> weekMap;
        for(Diary_Entry__c de : consolidatedLst)
        {
            weekids.add(de.Week__c);
        }
        system.debug('weekids--->'+weekids);
        list<Diary_Entry__c> preStackedEntries = new list<Diary_Entry__c>();
        preStackedEntries = [Select d.Week__c, d.Start__c, d.Id, d.End__c,Record_Type__c,IsStackable__c From Diary_Entry__c d where Week__c in:weekids and Record_Type__c = 'Unavailability' and Stackable__c = 'Yes' order by Start__c];
        for(Diary_Entry__c de : preStackedEntries)
        {
            list<Diary_Entry__c> templst = new list<Diary_Entry__c>();
            if(!stack_WeekMap.containskey(de.Week__c))
            {
                templst.add(de);
            }
            else
            {
            templst= stack_WeekMap.get(de.Week__c);
            templst.add(de);
            }
            stack_WeekMap.put(de.Week__c, templst);
            
        }
        system.debug('stack_WeekMap--->'+stack_WeekMap);
        deList2 = new list<Diary_Entry__c>();
        if(stack_WeekMap.size()>0)
        {
            
            deList2 = [Select d.Week__c, d.Start__c, d.Id, d.End__c,Record_Type__c,IsStackable__c From Diary_Entry__c d where ((Record_Type__c = 'Unavailability' and Stackable__c = 'No') or Record_Type__c = 'Job Booking') and Week__c in:stack_WeekMap.keyset()order by Start__c];
        }
        weekMap = new Map<Id, list<Diary_Entry__c>>();
        UpdatingLst = new List<Diary_Entry__c>();
        if(deList2.size()==0 )
        {
            for(id i : stack_WeekMap.keyset())
            {
                
                if(stack_WeekMap.get(i).size()==1)
                {
                    if(stack_WeekMap.get(i)[0].IsStackable__c == true)
                    {
                        stack_WeekMap.get(i)[0].IsStackable__c = false;
                        UpdatingLst.add(stack_WeekMap.get(i)[0]);
                    }   
                }
                else
                {
                    for(integer j=0 ; j<stack_WeekMap.get(i).size();j++)
                    {
                        for(integer k=j+1;k<stack_WeekMap.get(i).size();k++)
                        {
                            if(stack_WeekMap.get(i)[k].Start__c<stack_WeekMap.get(i)[j].End__c && stack_WeekMap.get(i)[k].End__c>stack_WeekMap.get(i)[j].Start__c)
                            {
                                continue;
                            }else
                            {
                                if(stack_WeekMap.get(i)[j].IsStackable__c == true)
                                    {
                                        stack_WeekMap.get(i)[j].IsStackable__c = false;
                                        UpdatingLst.add(stack_WeekMap.get(i)[j]);
                                    }   
                            }
                        }
                    }
                }
            }
        }
        else{
            for(Diary_Entry__c de : deList2)
            {
                list<Diary_Entry__c> templst = new list<Diary_Entry__c>();
                if(!weekMap.containskey(de.Week__c))
                {
                    templst.add(de);
                }
                else
                {
                templst= weekMap.get(de.Week__c);
                templst.add(de);
                }
                weekMap.put(de.Week__c, templst);
                
            }
        
            system.debug('weekMap--->'+weekMap);
            if(weekMap.size()>0)
            {
                
                for(id i: weekMap.keyset())
                {
                    
                    for(Diary_Entry__c d: stack_WeekMap.get(i))
                    {
                        boolean flag;
                        for(Diary_Entry__c de: weekMap.get(i))
                        {
                            system.debug('outside if---->>O');
                            if(de.Start__c<d.End__c && de.End__c>d.Start__c)
                            {
                                flag = false;
                            }else
                            {
                                flag= true;
                            }   
                        }
                        if(flag ==true)
                        {
                            d.IsStackable__c= false;
                            UpdatingLst.add(d);
                        }
                    }
                }
            }
        }
        
        if(UpdatingLst.size()>0)
        {
            
            update UpdatingLst;
        }   
        
    }
    
    public static void markStackableUnavailability(List<Diary_Entry__c> unavsToCreate)  
    {
        List<Diary_Entry__c> UpdatingLst;
        Map<Id, list<Diary_Entry__c>> weekMap;
        Map<Id, list<Diary_Entry__c>> stack_WeekMap = new Map<Id, list<Diary_Entry__c>>();
        for(Diary_Entry__c de : unavsToCreate)
        {
            list<Diary_Entry__c> templst = new list<Diary_Entry__c>();
            if(!stack_WeekMap.containskey(de.Week__c))
            {
                templst.add(de);
            }
            else
            {
            templst= stack_WeekMap.get(de.Week__c);
            templst.add(de);
            }
            stack_WeekMap.put(de.Week__c, templst);
            
        }
        
        
        weekMap = new Map<Id, list<Diary_Entry__c>>();
        list<Diary_Entry__c> deList= [Select d.Week__c, d.Start__c, d.Id, d.End__c,Record_Type__c,IsStackable__c From Diary_Entry__c d where Week__c in :stack_WeekMap.keyset() and (Record_Type__c='Unavailability' or Record_Type__c='Job Booking')order by Start__c];
        for(Diary_Entry__c de : deList)
        {
            list<Diary_Entry__c> templst = new list<Diary_Entry__c>();
            if(!weekMap.containskey(de.Week__c))
            {
                templst.add(de);
            }
            else
            {
            templst= weekMap.get(de.Week__c);
            templst.add(de);
            }
            weekMap.put(de.Week__c, templst);
            
        }
        system.debug('weekMap--->'+weekMap);
        if(weekMap.keyset().size()>0)
        {
            UpdatingLst = new List<Diary_Entry__c>();
            for(id i: weekMap.keyset())
            {
                
                for(Diary_Entry__c d: stack_WeekMap.get(i))
                {
                    for(Diary_Entry__c de: weekMap.get(i))
                    {
                        if(de.Start__c<d.End__c && de.End__c>d.Start__c)
                        {
                            d.IsStackable__c = true;
                            UpdatingLst.add(d);
                            break;
                        }
                    }
                }
            }
        }
        
        
    }
    
}