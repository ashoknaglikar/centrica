public with sharing class DiaryEntryManager 
{
    //some constants
    public static final String ENTRY_RECTYPE_BOOKING = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking');
    public static final String ENTRY_RECTYPE_AVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Availability');
    public static final String ENTRY_RECTYPE_UNAVAIL = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');  
    
    public static WeekManager.CreateEntryResult insertBooking(Id jobId, Diary_Entry__c gap, String entryType, Datetime startTime, Datetime endTime, Double hours, String skill, Boolean isPool, Double overBookedHours)
    {
        //find the relevant data about the existing gap

        
        //create the job booking from the parameters
        Diary_Entry__c newBooking = new Diary_Entry__c(Week__c = gap.Week__c, 
                                                RecordTypeId = entryType, 
                                                Start__c = startTime, 
                                                Hours__c = hours,
                                                Job__c = jobId, 
                                                End__c = endTime,
                                                Sub_type__c = skill,
                                                Overbooked_Hours__c = overBookedHours);
        WeekManager.CreateEntryResult result = new WeekManager.CreateEntryResult(newBooking);

        if(!isPool)//if not a pool diary
        {
            manageGapsOnInsert(newBooking, gap, result);
        }   
        else //is a pool diary
        {
            //create the new booking. 
            result.addModEntry(newBooking);
            //modify the existing gaps hours
            managePoolEntryOnInsert(gap, hours, result);
            //next gap is the same as this gap as pool diary has only 1 availability record
            result.nextGap = gap;
        }
        
        return result;  
    }
    // Travel Time Changes
    
    public static WeekManager.CreateEntryResult insertTravelBooking(Id jobId, Diary_Entry__c gap, String entryType, Datetime startTime, Datetime endTime, Double hours, String skill, Boolean isPool, Double overBookedHours, Id TravelJobId)
    {
        //find the relevant data about the existing gap

        
        //create the job booking from the parameters
        Diary_Entry__c newBooking = new Diary_Entry__c(Week__c = gap.Week__c, 
                                                RecordTypeId = entryType, 
                                                Start__c = startTime, 
                                                Hours__c = hours,
                                                Job__c = jobId, 
                                                End__c = endTime,
                                                Sub_type__c = skill,
                                                Overbooked_Hours__c = overBookedHours,
                                                Travel_Job__c = TravelJobId);
        WeekManager.CreateEntryResult result = new WeekManager.CreateEntryResult(newBooking);

        if(!isPool)//if not a pool diary
        {
            manageGapsOnInsert(newBooking, gap, result);
        }   
        else //is a pool diary
        {
            //create the new booking. 
            result.addModEntry(newBooking);
            //modify the existing gaps hours
            managePoolEntryOnInsert(gap, hours, result);
            //next gap is the same as this gap as pool diary has only 1 availability record
            result.nextGap = gap;
        }
        
        return result;  
    }
    
    public static WeekManager.CreateEntryResult insertUnavailability(Diary_Entry__c newUnav, List<Diary_Entry__c> allWeeksEnts)
    {
        //create the Unavailability from the parameters

        
        //outputDiary2(allWeeksEnts, 'All weeks entries for DEMgr insertUNav');
        
        WeekManager.CreateEntryResult result = new WeekManager.CreateEntryResult();
        
        manageGapsOnInsertUnavailability(newUnav, allWeeksEnts, result);
        return result;
    }
    
    public static WeekManager.RemoveEntryResult removeDiaryEntry(Diary_Entry__c diaryEntryId, List<Diary_Entry__c> allWeeksEntries, Boolean isPool)
    {

        WeekManager.RemoveEntryResult result;
        if(isPool)
        {
            result = new WeekManager.RemoveEntryResult();
            result.addDelEntry(diaryEntryId);
            //modify the existing gaps hours (i.e. add hours due to removal of booking)
            Diary_Entry__c gap;
            for(Diary_Entry__c possGap : allWeeksEntries)
            {
//              System.debug(LoggingLevel.INFO, 'possi ble gap: ' + possGap);
                if(possGap.RecordTypeId == ENTRY_RECTYPE_AVAIL)// && possGap.End__c > diaryEntryId.Start__c && possGap.Start__c < diaryEntryId.End__c)
                {
                    gap = possGap;
                    System.debug(LoggingLevel.INFO, 'possible gap id: ' + possGap.ID);
                    break;
                }
            }
            managePoolEntryOnRemove(gap, diaryEntryId.hours__c, result);        
        }
        else
        {
            result = manageGapsOnRemoval(diaryEntryId, allWeeksEntries);            
        }
        
        return result; 
    }
    
    //Manage the gaps for when a diary entry is inserted
    //results are returned via the supplied results parameter
    //private static List<Diary_Entry__c> manageGapsOnInsert(Diary_Entry__c insertEntryId, Diary_Entry__c existingGap, WeekManager.CreateEntryResult result)
    private static void manageGapsOnInsert(Diary_Entry__c insertEntryId, Diary_Entry__c existingGap, WeekManager.CreateEntryResult result)
    {       
        //save the original gap start and end for debugging
        Datetime origStart = existingGap.Start__c;
        Datetime origEnd = existingGap.End__c;
        
        //take a copy of the gap so that the copy can be modified and the original
        //gap left in tact so we know how to modify the gaps later
        Diary_Entry__c copyGap = existingGap.clone(false,true);
        
        //create a diary entry object which will allow us to modify the gap
        //as required
        //DiaryEntry gap = new DiaryEntry(copyGap);
        DiaryEntry gap = new DiaryEntry(existingGap);
        
        //may need a new gap if the original gap is split
        Diary_Entry__c newGap;
        
        Boolean deleteExistingGap = false;
      
        // Added few debug statements to check start and end times.
        
        System.debug(LoggingLevel.INFO,'existing gap details' + existingGap.Start__c + ' ' + existingGap.End__c);
        System.debug(LoggingLevel.INFO,'gap being inserted gap details' + insertEntryId.Start__c + ' ' + insertEntryId.End__c);
        

        //-----------
        //Data is now all set up, decide what to do with the gaps...

        //job Booking is the same size as the gap
        //so the gap is deleted
        if(DateTimeHelper.dateEquals(insertEntryId.Start__c, existingGap.Start__c) && DateTimeHelper.dateEquals(insertEntryId.End__c, existingGap.End__c))
        {
            //removeEntry(existingGap);
            
            deleteExistingGap = true;
        }       
        else
        {
            //Job Booking is shorter than the gap and ends at the end of the gap
            if(DateTimeHelper.dateGreaterThan(insertEntryId.Start__c, existingGap.Start__c) && DateTimeHelper.dateEquals(insertEntryId.End__c, existingGap.End__c))
            {
                gap.shrinkLeft(insertEntryId.Start__c);
            }
            //Job booking is shorter than the gap and starts at the beginning of the gap
            else if(DateTimeHelper.dateEquals(insertEntryId.Start__c, existingGap.Start__c) && DateTimeHelper.dateLessThan(insertEntryId.End__c, existingGap.End__c))
            {
                gap.shrinkRight(insertEntryId.End__c);
            }
            //Job booking starts after and ends before the gap
            else if(DateTimeHelper.dateGreaterThan(insertEntryId.Start__c, existingGap.Start__c) && DateTimeHelper.dateLessThan(insertEntryId.End__c, existingGap.End__c))
            {
                gap.shrinkLeft(insertEntryId.Start__c);
                //create a new gap after the booking
                newGap = gap.newGap(insertEntryId.End__c, copyGap.End__c);              
            }
            else
            {
              System.debug(LoggingLevel.INFO, 'Gap details: ' + existingGap.Start__c + ' ' + existingGap.End__c);
              System.debug(LoggingLevel.INFO, 'inser entry details: ' + insertEntryId.Start__c + ' ' + insertEntryId.End__c);
                throw new myException('The Booking Doesnt fit in to the Availability Gap');
            }
            //now update the original gap
            //existingGap = gap.getDiaryEntry();            
        }
        
        List<Diary_Entry__c> results = new List<Diary_Entry__c>();
        
        
        if(newGap != null) 
        {
            result.nextGap = newGap;
            result.addModEntry(newGap);
            result.addModEntry(existingGap);
        }
        else if(existingGap != null && !deleteExistingGap)
        {
            result.nextGap = existingGap;
            result.addModEntry(existingGap);
        }
        
        if(deleteExistingGap)
        {
            result.addDelEntry(existingGap);
        }
        
//      System.debug(LoggingLevel.INFO, '*** result: '+ result);
        /*
        if(existingGap != null)
        {
            result.addModEntry(existingGap);
        }
        */
        //return newGap;
        //if(existingGap != null) results.add(existingGap);
        //
        //return results;
        //if(existingGap != null)upsert existingGap;    
        //if(newGap != null)upsert newGap;
        
        
        
        //return '##Original Gap: ' + existingGap + ' ##Booking: ' + insertEntryId + ' ##New Gap: ' + newGap;
        //List<Diary_Entry__c> entriesToDisplay = new List<Diary_Entry__c>();
        //entriesToDisplay.add(existingGap);
        //entriesToDisplay.add(insertEntryId);
        //entriesToDisplay.add(newGap);
        //System.debug(LoggingLevel.INFO, 'Entries to display: ' + entriesToDisplay);
        //return outputDiary(entriesToDisplay, origStart, origEnd); 
    }
    
    private static void manageGapsOnInsertUnavailability(Diary_Entry__c entryToInsert, List<Diary_Entry__c> allWeeksEnts, WeekManager.CreateEntryResult result)
    {
        //The diary entries that have been modified as a result of the insert,
        //there may be multiple gaps if an overlapping unavalability is inserted
        List<Diary_Entry__c> entriesToReturn = new List<Diary_Entry__c>();
        
        //find all of the diary entries for the week of the entry that we are inserting
        
        List<Diary_Entry__c> allWeeksGaps = new List<Diary_Entry__c>();
        for(Diary_Entry__c weekDE : allWeeksEnts)
        {
            if(weekDE.RecordTypeId == ENTRY_RECTYPE_AVAIL)
            {
                allWeeksGaps.add(weekDE);
            }
        }
        //outputDiary2(allWeeksGaps, 'All the gaps that are candidates for unav insert');
        //System.debug(LoggingLevel.INFO, 'allWeeksGaps: ' + allWeeksGaps);
        //to store diary entries that are relevant on insertion (adjacent or overlapping)
        List<Diary_Entry__c> associatedGaps = new List<Diary_Entry__c>();               
        //find all associated entries, this works because they are ordered by start date
        for(Diary_Entry__c entry : allWeeksGaps)
        {   
                if(entryToInsert.sub_type__c=='NWD - Working') break;            
                if(DateTimeHelper.dateGreaterThanOrEqual(entry.End__c, entryToInsert.Start__c) && 
                    DateTimeHelper.dateLessThanOrEqual(entry.Start__c, entryToInsert.End__c))
                {
                    if(entry.Id == null || entry.Id != entryToInsert.Id)associatedGaps.add(entry);
                }
            
        }
        //outputDiary2(associatedGaps, 'Gaps effected by unav insert');
        Integer associatedGapsSize = associatedGaps.size();
        Integer lastItemIndex = associatedGapsSize - 1;
        
        //if there is 1 associated gap then it might be big enough for the unavailability
        //to fit in
        /*if(associatedGapsSize == 1)
        {
            //try to fit the unavailability in the gap, if an exception is thrown
            //the unavailability does not fit
            try
            {
                manageGapsOnInsert(entryToInsert, associatedGaps[0]);
            }
            catch(MyException e)
            {
                //don't want to do anything if it doesn't work, just carry on...
            }
            
        }
        else //more complex scenario with overlapping unavailability*/
        {
            //System.debug(LoggingLevel.INFO, 'There are ' + associatedGapsSize +  ' associated Gaps');
            //loop through all of the associated Gaps. Gaps will either need to be shortened
            //of removed depending on the overlap with the unavailability
            List<Diary_Entry__c> entriesToUpdate = new List<Diary_Entry__c>();
            Integer k = 0;
            for(Diary_Entry__c gap : associatedGaps)
            {
                //if the unavailability completely overlaps the gap, the gap can be deleted
                if(DateTimeHelper.dateGreaterThanOrEqual(gap.start__c, entryToInsert.start__c) &&
                    DateTimeHelper.dateLessThanOrEqual(gap.end__c, entryToInsert.end__c))
                {
                    //removeEntry(gap);
                    result.addDelEntry(gap);
                }               
                //unavailability starts after and ends before the gap
                else if(DateTimeHelper.dateGreaterThan(entryToInsert.Start__c, gap.Start__c) && DateTimeHelper.dateLessThan(entryToInsert.End__c, gap.End__c))
                {
                    Datetime gapOldEnd = gap.End__c;
                    DiaryEntry myGap = new DiaryEntry(gap);
                    //System.debug(LoggingLevel.INFO, 'gap before shrink: ' + gap);
                    myGap.shrinkLeft(entryToInsert.Start__c);
                    //System.debug(LoggingLevel.INFO, 'gap after shrink: ' + gap);
                    //create a new gap after the booking
                    Diary_Entry__c newGap = myGap.newGap(entryToInsert.End__c, gapOldEnd);
                    entriesToUpdate.add(gap);
                    entriesToUpdate.add(newGap);        
                }
                //if the unavailability partially overlaps the gap, it should be reduced in size
                else
                {
                    DiaryEntry gapToModify = new DiaryEntry(gap);
                    //System.debug(LoggingLevel.INFO, 'Gap before: ' + gap);
                    if(DateTimeHelper.dateLessThanOrEqual(entryToInsert.Start__c, gap.Start__c) && DateTimeHelper.dateLessThanOrEqual(entryToInsert.End__c, gap.End__c))
                    {
                        gapToModify.shrinkRight(entryToInsert.End__c);
                    }
                    else if(DateTimeHelper.dateGreaterThanOrEqual(entryToInsert.Start__c, gap.Start__c) && DateTimeHelper.dateGreaterThanOrEqual(entryToInsert.End__c, gap.End__c))
                    {
                        gapToModify.shrinkLeft(entryToInsert.Start__c);
                    }
                    else
                    {
                        throw new myException('Expected unavailability insert to modify Availability but it did not');
                    }
                    //System.debug(LoggingLevel.INFO, 'Gap after: ' + gap);
                    entriesToUpdate.add(gap);
                }
            }
            if (entriesToUpdate != null) 
            {
                //upsert entriesToUpdate;
                result.addModEntry(entriesToUpdate);
            }
        }
    }
    
    private static WeekManager.RemoveEntryResult manageGapsOnRemoval(Diary_Entry__c entryToRemove, List<Diary_Entry__c> allWeeksEntries)
    {
        WeekManager.RemoveEntryResult result = new WeekManager.RemoveEntryResult();
        //The diary entry (gap) that has replaced the removed Entry
        Diary_Entry__c entryToReturn;
        //find all of the diary entries for the week of the entry that we are removing
        system.debug('@@entry to remove'+entrytoremove);        
        //entries that will be returned for DML
        List<Diary_Entry__c> entriesToUpsert = new List<Diary_Entry__c>();
        //to store diary entries that are relevant on removal (adjacent or overlapping)
        List<Diary_Entry__c> associatedEntries = new List<Diary_Entry__c>();        
        
        // gjb 2010-02-16 - a list to hold unavailability.
        List<Diary_Entry__c> associatedUnavs = new List<Diary_Entry__c>();
        
        //find all associated entries, this works because they are ordered by start date
        for(Diary_Entry__c entry : allWeeksEntries)
        {
            
            if(DateTimeHelper.dateGreaterThanOrEqual(entry.End__c, entryToRemove.Start__c) && 
                DateTimeHelper.dateLessThanOrEqual(entry.Start__c, entryToRemove.End__c))
            {
                if(entry.RecordTypeId != ENTRY_RECTYPE_UNAVAIL) {
                    if(entry.Id != entryToRemove.Id) {
                        System.debug(LoggingLevel.INFO, 'entry: ' + entry);
                        associatedEntries.add(entry);
                    }
                } else if(entry.RecordTypeId == ENTRY_RECTYPE_UNAVAIL) {
                   // Ashok code Change 
                    if(entry.Id != entryToRemove.Id && entry.sub_type__c!='NWD - Working'){
                        system.debug(LoggingLevel.INFO, 'entry unavs: ' + entry);
                        associatedUnavs.add(entry);
                    }
                }
                
            }
        }
        //system.debug('@@associatedEntriessize'+associatedEntries.size()+' '+associatedEntries);
        //system.debug('@@associatedUnavs'+associatedUnavs.size()+' '+associatedUnavs);
        
        Integer associatedEntriesSize = associatedEntries.size();
        Integer lastItemIndex = associatedEntriesSize - 1;
        boolean isFirst = false;
        boolean isLast = false;
        /*for(Diary_Entry__c ent : associatedEntries)
        {       
            system.debug(LoggingLevel.INFO, 'associatedEntries: '+ent);
        }
        for(Diary_Entry__c ent : associatedUnavs)
        {       
            system.debug(LoggingLevel.INFO, 'associatedUnavs: '+ent);
        }*/
        //find out if the entry to remove is the first or the last of the week (or both)
        
        
        //in a basic scenario there will be 0, 1 or 2 associated entries
        
        if(associatedEntriesSize == 0) //entry removed is the only entry for the week (e.g. unavailability for the whole week)
        {
            //result = extractEntry(null, entryToRemove, null);
            
            // gjb 2010-02-22 Create a new availability to replace entryToRemove
            result = processEntryToRemove(entryToRemove, associatedUnavs, null, null);
        }
        else if(associatedEntriesSize > 0)
        {       
            //if there are 2 associated entries we want to make sure that they are in
            //the correct order so that we can work out if the entry to be removed is
            //the first and/or last of the week
            if(associatedEntriesSize == 2)//order correctly
            {
//              System.debug(LoggingLevel.INFO, 'Before poss reorder: ' + associatedEntries);
                if(associatedEntries[0].start__c > associatedEntries[1].start__c)
                {
                    //they are in the wrong order
                    Diary_entry__c tempEntry0 = associatedEntries[0];
                    Diary_entry__c tempEntry1 = associatedEntries[1];
                    associatedEntries.clear();
                    associatedEntries.add(tempEntry1);
                    associatedEntries.add(tempEntry0);
                }
              System.debug(LoggingLevel.INFO, 'After poss reorder: ' + associatedEntries);
            } 
            
//          System.debug(LoggingLevel.INFO, 'DateTimeHelper.dateGreaterThanOrEqual(associatedEntries[0].start__c, entryToRemove.Start__c)');
//          System.debug(LoggingLevel.INFO, 'associatedEntries[0].start__c: ' + associatedEntries[0].start__c);
//          System.debug(LoggingLevel.INFO, 'entryToRemove.Start__c: ' + entryToRemove.Start__c);
//          System.debug(DateTimeHelper.dateGreaterThanOrEqual(associatedEntries[0].start__c, entryToRemove.Start__c));     
            if(DateTimeHelper.dateGreaterThanOrEqual(associatedEntries[0].start__c, entryToRemove.Start__c))//removing first entry of the week
            {
                isFirst = true;
            }
            if(DateTimeHelper.dateLessThanOrEqual(associatedEntries[lastItemIndex].End__c, entryToRemove.End__c))
            {
                isLast = true;
            }
            
            if(associatedEntriesSize == 1)
            {
                // gjb - as associatedEntries can only contain Job Bookings, these situations should only apply
                // when removing unavailability (because JB's cant run in paralell, and Unavailabilities aren't
                // stored in the associated entries list.)
                
              System.debug(LoggingLevel.INFO, '1 *&*& associatedEntries' + associatedEntries);
              System.debug(LoggingLevel.INFO, 'isfirst: ' + isfirst);
              System.debug(LoggingLevel.INFO, 'isLast: ' + isLast);
                
                //if we are removing an entry that has only one associate and that associate
                //starts before and finished after the one we are removing then there are
                //no gaps to deal with
                if(!isFirst && !isLast)
                {
                    // gjb 2010-02-22
                    // An unav is being removed and it is surrounded by a job booking. We don't want availability 
                    // created in this instance. Just add the removed entry for deletion
                    result.addDelEntry(entryToRemove);
                }
                else
                {
                    Diary_Entry__c returnedGap;
                    //entry to remove completely overlaps the 1 associated entry
                    if(isFirst && isLast)
                    {
                        // Old code
                        /*WeekManager.RemoveEntryResult tempResult = new WeekManager.RemoveEntryResult();
                        //bit of a fudge to get the 2 gaps that are required in this situation
                        result = extractEntry(associatedEntries[0], entryToRemove, null);
                        //result has 1 of the gaps, now for the cheating bit...
                        tempResult = extractEntry(null, entryToRemove, associatedEntries[0]);
                        //tempResult has the second gap - add it to result
                        result.addModEntry(tempResult.modifiedEntries);*/

                        // gjb 2010-02-22
                        // Need to create gaps AROUND the associated diary entry. This needs to respect
                        // other unavailability that may be in place. This should only be creating gaps around
                        // a job booking when removing an unavailability.
                        List<Diary_Entry__c> toPlanAround = associatedUnavs.deepClone(true);
                        system.debug(LoggingLevel.INFO, 'toPlanAround ' + toPlanAround );
                        toPlanAround.add(associatedEntries[0]);
                        system.debug(LoggingLevel.INFO, 'toPlanAround1 ' + toPlanAround );
                        result = processEntryToRemove(entryToRemove, toPlanAround, null, null);
                    }
                    else if(isFirst)
                    {
//                      System.debug(LoggingLevel.INFO, 'it is first and extracting on that basis: ' + entryToRemove);
                        // Old code
                        //result = extractEntry(null, entryToRemove, associatedEntries[0]);
                    
                        // gjb 2010-02-22
                        // Need to create a gap between the entryToRemove's start and associated entry's
                        // start, respecting other unavailabilities that may also be present. The associated
                        // entry may be an adjacent availability.
                        List<Diary_Entry__c> toPlanAround = associatedUnavs.deepClone(true);
                        toPlanAround.add(associatedEntries[0]);
                        result = processEntryToRemove(entryToRemove, toPlanAround, null, associatedEntries[0]);
                                                                
                    }
                    else if(isLast)//is last
                    {
                        // old code
                        //result = extractEntry(associatedEntries[0], entryToRemove, null);
                        
                        // gjbTODO - like the above, need to create a gap between entryToRemove's end and
                        // associated entry's end. This also needs to respect other unavailabilities. The associated
                        // entry may be an adjacent availability.
                        List<Diary_Entry__c> toPlanAround = associatedUnavs.deepClone(true);
                        toPlanAround.add(associatedEntries[0]);
                        result = processEntryToRemove(entryToRemove, toPlanAround, associatedEntries[0], null);
                    }

                    entryToReturn = returnedGap;
                }
            }
            
            else if(associatedEntriesSize == 2 && !isFirst && !isLast)//typical scenario of removing a booking from between 2 gaps for example
            {
                System.debug(LoggingLevel.INFO, 'associatedEntries[0], entryToRemove, associatedEntries[1]:\n ' + 
                                associatedEntries[0] + ',\n ' + entryToRemove + ',\n '+ associatedEntries[1]);
                // Old code
                //result = extractEntry(associatedEntries[0], entryToRemove, associatedEntries[1]); 
                
                // gjbTODO - there's a diary entry on either side of the entry we're removing. This may be adjacent 
                // job bookings, or job bookings that finish/start after an unavailability starts/finishes. Again,
                // associated entries should only be job bookings, where the entry to remove is an unav.
                // We need to create a gap between the associated entries, however we need to respect other unavs.
                
                // Once again, above is incorrect, we may have adjacent availabilities on either (or both!) sides.
                // So we may have situations where we are removing job bookings or unavailabilities. Still need
                // to create a gap but it may mean stretching an existing gap. Also needs to respect unavs.
                
                List<Diary_Entry__c> toPlanAround = associatedUnavs.deepClone(true);
                //system.debug(LoggingLevel.INFO, 'toPlanAround ' + toPlanAround );
                toPlanAround.add(associatedEntries[0]);
                toPlanAround.add(associatedEntries[1]);
                //system.debug(LoggingLevel.INFO, 'toPlanAround ' + toPlanAround );
                result = processEntryToRemove(entryToRemove, toPlanAround, associatedEntries[0], associatedEntries[1]);             
            }           
            else //more complex scenario with overlapping entries due to unavailability
            
            {
                List<Diary_Entry__c> toPlanAround = associatedUnavs.deepClone(true);
                toPlanAround.addAll(associatedEntries);
                result = processEntryToRemove(entryToRemove, toPlanAround);
//              System.debug(LoggingLevel.INFO, 'there are ' + associatedEntriesSize + ' assoc entries:  ' + associatedEntries);
//              System.debug(LoggingLevel.INFO, 'isFirst:  ' + isFirst);
//              System.debug(LoggingLevel.INFO, 'isLast:  ' + isLast);
                
                /*result.addDelEntry(entryToRemove);
                //System.debug(LoggingLevel.INFO, 'There are ' + associatedEntriesSize +  ' associated entries');
                //loop through all of the associated entries. The same rules apply as when
                //there are just 2 associated entries, but here we take each pair of
                //associated entries in turn to process the removal of the unwanted entry
                List<Diary_Entry__c> entriesToUpdate = new List<Diary_Entry__c>(); //there may be several gaps to update
                
                Integer k = 0;
                List<String> allTimes = new List<String>();
                String entryChar;
                String timeStr;
                Integer g = 0;
                for(Diary_Entry__c entry : associatedEntries)
                {
                    if(entry.RecordTypeId == ENTRY_RECTYPE_AVAIL) {entryChar = 'A';} 
                    else if(entry.RecordTypeId == ENTRY_RECTYPE_UNAVAIL) {entryChar = 'U';}
                    else {entryChar = 'B';}
                    timeStr = removeSecs(entry.Start__c).getTime() + ',' + entryChar + ',S' + ',' + g;
                    allTimes.add(timeStr);
                    timeStr = removeSecs(entry.End__c).getTime() + ',' + entryChar + ',E' + ',' + g;
                    allTimes.add(timeStr);  
                    g++;    
                }
                allTimes.sort();
//              System.debug(LoggingLevel.INFO, 'Sorted all times: ' + allTimes);
                
                Diary_Entry__c nextEntry;
                Diary_Entry__c thisEntry;
                List<String> timeAndLetters = new List<String>();
                Integer aCounter = 0;
                Integer ubCounter = 0;
                Boolean ubFlag = false;
                Boolean aFlag = false;      
                //don't need to worry about the last time because nothing changes after this
                //allTimes.remove(allTimes.size() - 1);
                Integer f = 0;
                for(String oneTime : allTimes)//for every start and end time of diary entries
                {
                    //System.debug(LoggingLevel.INFO, '--------------');
                    //System.debug(LoggingLevel.INFO, 'aCounter: ' + aCounter);
                    //System.debug(LoggingLevel.INFO, 'ubCounter: ' + ubCounter);
                    //System.debug(LoggingLevel.INFO, 'ubFlag: ' + ubFlag);
                    //System.debug(LoggingLevel.INFO, 'aFlag: ' + aFlag);
                    //System.debug(LoggingLevel.INFO, '@@@@@@@@@@@@@@');
                    //split out the elements of the string that we encoded earlier,
                    //time, entry type, start/end and index of diary entry in associated entries
                    timeAndLetters = oneTime.split(','); 
                    //looping through each start/end time working out where a gap is needed
                    if(timeAndLetters[1] == 'A')//gap
                    {
                        if(timeAndLetters[2] == 'S')
                        {
                            
                            aCounter++; 
                            aFlag = true;
                            //System.debug(LoggingLevel.INFO, 'just added one to a counter and set aFlaf: ' + aFlag + ' ' + aCounter);
                        }
                        else 
                        {
                            aCounter--;
                        }
                    }                                       
                    else//booking or unavailability
                    {
                        if(timeAndLetters[2] == 'S')
                        {
                            ubCounter++; 
                            ubFlag = true;
                        }
                        else 
                        {
                            ubCounter--;
                        }
                    }                   
                    //System.debug(LoggingLevel.INFO, '--------------');
                    //System.debug(LoggingLevel.INFO, 'just before ubFlag && (ubCounter == 0)');
                    //System.debug(LoggingLevel.INFO, 'aCounter: ' + aCounter);
                    //System.debug(LoggingLevel.INFO, 'ubCounter: ' + ubCounter);
                    //System.debug(LoggingLevel.INFO, 'ubFlag: ' + ubFlag);
                    //System.debug(LoggingLevel.INFO, 'aFlag: ' + aFlag);
                    //System.debug(LoggingLevel.INFO, '@@@@@@@@@@@@@@');                                        
                    if((ubFlag || aFlag) && (ubCounter + aCounter) == 0)
                    {
                        //dont want to work any more if we have hit the end of the last entry
                        if(f == allTimes.size() - 1) continue;
                        
                        List<String> firstDateStrs = oneTime.split(',');
                        Datetime firstDate = Datetime.newInstance(Long.valueOf(firstDateStrs[0]));
                        ubFlag = false;
                        aFlag = false;
                        //there is space for a gap, need to work out if to create a new one or extend existing one
                        Datetime thisDate = Datetime.newInstance(Long.valueOf(timeAndLetters[0]));  
                        String thisType = timeAndLetters[1];    
                        thisEntry = associatedEntries[Integer.valueOf(timeAndLetters[3])];
                        List<String> nextItems = allTimes[f + 1].split(',');
                        Datetime nextDate = Datetime.newInstance(Long.valueOf(nextItems[0]));
                        String nextType = nextItems[1];
                        nextEntry = associatedEntries[Integer.valueOf(nextItems[3])];
                        
                        
                        //if this one is an end of a gap then we may need to extend the gap
                        //to nextDate depending on when the next date is
                        if(thisType == 'A' && DateTimeHelper.dateGreaterThan(nextDate, thisDate))
                        {
//                          System.debug(LoggingLevel.INFO, '###Need to extend this gap right!!');
                            DiaryEntry leftGap = new DiaryEntry(thisEntry);
                            leftGap.growRight(nextDate);
                            entriesToUpsert.add(thisEntry);
                        }
                        //if the next time is the start of a gap then we may need to extend
                        //that gap back to thisDate
                        else if(nextType == 'A' && DateTimeHelper.dateGreaterThan(nextDate, thisDate))
                        {
//                          System.debug(LoggingLevel.INFO, '###Need to extend this gap left!!');
                            DiaryEntry rightGap = new DiaryEntry(nextEntry);
                            rightGap.growLeft(thisDate);
                            entriesToUpsert.add(nextEntry);
                        }
                        // brm - 08-01-2010 - Make sure we need a gap before trying to create one
                        else if (thisDate != nextDate)
                        {
//                          System.debug(LoggingLevel.INFO, '###Need a brand new gap!!');
                            DiaryEntry newGap = new DiaryEntry(nextEntry);
                            //System.debug(LoggingLevel.INFO, '------------ this date: ' + thisDate);   
                            //System.debug(LoggingLevel.INFO, '------------ next date: ' + nextDate);   
                            //System.debug(LoggingLevel.INFO, '------------ new gap: ' + newGap.newGap(thisDate, nextDate));        
                            Diary_Entry__c newEntry = newGap.newGap(thisDate, nextDate);
                            entriesToUpsert.add(newEntry);
                        }                                   
                    }   
                    f++;
                    
                }
                //if the one being removed is the first of the week there may be space
                //for a gap. If the first associated entry starts later than the
                //start of the entry being removed, there needs to be a gap starting 
                //at the entry to be removed start and ending at the start of the first
                //associated entry. There is the eqivilent if the one being removed is
                //the last of the week.
                
                
                List<String> firstDateStrs = allTimes[0].split(',');
                Datetime firstDate = Datetime.newInstance(Long.valueOf(firstDateStrs[0]));
                String firstType = firstDateStrs[1];
                List<String> secondDateStrs = allTimes[1].split(',');
                Datetime secondDate = Datetime.newInstance(Long.valueOf(secondDateStrs[0]));                
                List<String> secondLastDateStrs = allTimes[allTimes.size() - 2].split(',');
                Datetime secondLastDate = Datetime.newInstance(Long.valueOf(secondLastDateStrs[0]));
                List<String> lastDateStrs = allTimes[allTimes.size() - 1].split(',');
                Datetime lastDate = Datetime.newInstance(Long.valueOf(lastDateStrs[0]));
                String lastType = lastDateStrs[1];
                
                if(DateTimeHelper.dateLessThan(entryToRemove.Start__c, firstDate))
                {
//                  System.debug(LoggingLevel.INFO, 'DateTimeHelper.dateLessThan(entryToRemove.Start__c, firstDate)');
//                  System.debug(LoggingLevel.INFO, 'entryToRemove.Start__c' + entryToRemove.Start__c);
//                  System.debug(LoggingLevel.INFO, 'firstDate' + firstDate);
//                  System.debug(LoggingLevel.INFO, '###Need to create a new first gap!');
                    DiaryEntry newGap = new DiaryEntry(entryToRemove);
//                  System.debug(LoggingLevel.INFO, 'thisEntry: ' + thisEntry);
                    Diary_Entry__c newEntry = newGap.newGap(entryToRemove.Start__c, firstDate);
                    entriesToUpsert.add(newEntry);
                    
                }
                if(DateTimeHelper.dateGreaterThan(entryToRemove.End__c, lastDate))
                {
                    
//                  System.debug(LoggingLevel.INFO, 'DateTimeHelper.dateGreaterThan(entryToRemove.End__c, lastDate');                   
//                  System.debug(LoggingLevel.INFO, 'entryToRemove.End__c' + entryToRemove.End__c);
//                  System.debug(LoggingLevel.INFO, 'lastDate' + lastDate);                 
//                  System.debug(LoggingLevel.INFO, '###Need to create a new last gap!');
                    DiaryEntry newGap = new DiaryEntry(entryToRemove);
                    Diary_Entry__c newEntry = newGap.newGap(lastDate, entryToRemove.End__c);
                    entriesToUpsert.add(newEntry);
                }*/
            }
        }
        
        if(entryToReturn != null){
            entriesToUpsert.add(entryToReturn);
        }
        //return entriesToUpsert; 
//      system.debug(entriesToUpsert);
        if(entriesToUpsert != null && !entriesToUpsert.isEmpty()){
            result.addModEntry(entriesToUpsert);
        }
        
        return result;
        
    }
    
    //can return null if no gap was modified or created
    private static WeekManager.RemoveEntryResult extractEntry(Diary_Entry__c eLeft, Diary_Entry__c eToRemove, Diary_Entry__c eRight)
    {
//      System.debug(LoggingLevel.INFO, '(*(*left remove right : \n' + eLeft + '\n' + eToRemove + '\n' + eRight);
        WeekManager.RemoveEntryResult result = new WeekManager.RemoveEntryResult(eToRemove);
        //add the entry that we are removing to the deletion list
        result.addDelEntry(eToRemove);
        //new gap in case one is created
        Diary_Entry__c newGap;
        
        Boolean leftIsGap = (eLeft != null && eLeft.RecordTypeId == ENTRY_RECTYPE_AVAIL);
        Boolean rightIsGap = (eRight != null && eRight.RecordTypeId == ENTRY_RECTYPE_AVAIL);
        /*System.debug(LoggingLevel.INFO, 'eLeft' + eLeft);
        System.debug(LoggingLevel.INFO, 'eRight' + eRight);     
        System.debug(LoggingLevel.INFO, 'leftIsGap' + leftIsGap);
        System.debug(LoggingLevel.INFO, 'rightIsGap' + rightIsGap);*/
        //if there are no gaps, we need to create a new one to relace the entry to be removed
        if(!leftIsGap && !rightIsGap)
        {
            Datetime myStart = eToRemove.Start__c;
            Datetime myEnd = eToRemove.End__c;
            if(eLeft != null){myStart = eLeft.End__c;}
            if(eRight != null){myEnd = eRight.Start__c;}
            
            DiaryEntry removeEntry = new DiaryEntry(eToRemove);
            newGap = removeEntry.newGap(myStart, myEnd);
            result.addModEntry(newGap);
        }   
        //if there is a second gap, it needs to be extended and the first gap removed       
        else if(leftIsGap && rightIsGap)
        {
            DiaryEntry rightGap = new DiaryEntry(eRight);
            rightGap.growLeft(eLeft.Start__c);
            result.addDelEntry(eLeft);
            result.addModEntry(eRight);
        }
        //if there is just a gap to the right, we need to make its start date earlier
        else if(!leftIsGap && rightIsGap)
        {
            Datetime newStartTime;
            if(eLeft == null){newStartTime = eToRemove.Start__c;}
            else{newStartTime = eLeft.End__c;}
//          System.debug(LoggingLevel.INFO, '~~gap should have a old start time of : ' + eRight.Start__c);          
            DiaryEntry rightGap = new DiaryEntry(eRight);
            rightGap.growLeft(newStartTime);
            result.addModEntry(eRight);
//          System.debug(LoggingLevel.INFO, '~~gap should have a start time of : ' + eRight.Start__c);
        }
        //if there is just a gap to the left, we need to make its end date later
        else if(leftIsGap && !rightIsGap)
        {
            Datetime newEndTime;
            if(eRight == null){newEndTime = eToRemove.End__c;}
            else{newEndTime = eRight.Start__c;}         

            DiaryEntry leftGap = new DiaryEntry(eLeft);
            leftGap.growRight(newEndTime);
            result.addModEntry(eLeft);
        }
        else
        {
            throw new myException('System Error - Invalid data provided for Diary Entry Removal');
            return null;
        }
        return result;
    }

    public class MyException extends Exception{}
    
    private static Map<DateTime, DateTime> getStartAndEndTimes(List<Diary_Entry__c> entries) {
        Map<DateTime, DateTime> startAndEndTimes = new Map<DateTime, DateTime>(); 
        
        for(Diary_Entry__c ignore: entries) {
        
        //PRB00029837
        System.debug(LoggingLevel.INFO, 'ignore entered ' + ignore);
        
        if(ignore.Record_Type__c =='Non Productive Job Booking')
        continue;
        
        //PRB00029837
        
            if(startAndEndTimes.containsKey(ignore.Start__c)) {
                if(startAndEndTimes.get(ignore.Start__c) < ignore.End__c) {
                    startAndEndTimes.put(ignore.Start__c, ignore.End__c);
                }
            } else {
                startAndEndTimes.put(ignore.Start__c, ignore.End__c);
            }
        }
        
        return startAndEndTimes;
    }   

    private static WeekManager.RemoveEntryResult processEntryToRemove(Diary_Entry__c entryToRemove, List<Diary_Entry__c> itemsToPlanAround) {
        Diary_Entry__c left = null;
        Diary_Entry__c right = null;
        
        for(Diary_Entry__c itemToPlanAround : itemsToPlanAround) {
            if(itemToPlanAround.RecordTypeID != ENTRY_RECTYPE_AVAIL)
                continue;
            
            if(DateTimeHelper.dateEquals(itemToPlanAround.End__c, entryToRemove.Start__c))
                left = itemToPlanAround;
            if(DateTimeHelper.dateEquals(itemToPlanAround.Start__c, entryToRemove.End__c))
                right = itemToPlanAround;
            
            if(left != null && right != null)
                break;
        }
        
        return processEntryToRemove(entryToRemove, itemsToPlanAround, left, right); 
    }

    private static WeekManager.RemoveEntryResult processEntryToRemove(Diary_Entry__c entryToRemove, List<Diary_Entry__c> itemsToPlanAround, 
                                                        Diary_Entry__c left, Diary_Entry__c right) {
        WeekManager.RemoveEntryResult result = new WeekManager.RemoveEntryResult(entryToRemove);
        result.addDelEntry(entryToRemove);
        List<Diary_Entry__c> newGaps = calculateGapsOnRemoval(entryToRemove, itemsToPlanAround);
        
        if((left == null || left.RecordTypeID != ENTRY_RECTYPE_AVAIL) && (right == null || right.RecordTypeID != ENTRY_RECTYPE_AVAIL)) {
            System.debug(LoggingLevel.INFO, 'Nothing to grow, newGaps size: ' + newGaps.size());        
            result.addModEntry(newGaps);
        } else if(newGaps == null || newGaps.isEmpty()) {
            System.debug(LoggingLevel.INFO, 'No gaps were created, just delete entry.');
            return result;
        } else {
            // handle shrinking/growing
            System.debug(LoggingLevel.INFO, 'newGaps size: ' + newGaps.size());
            result = growOrShrink(result, newGaps, entryToRemove, left, right);
        }
        return result;
    }

    private static List<Diary_Entry__c> calculateGapsOnRemoval(Diary_Entry__c entryToRemove, List<Diary_Entry__c> itemsToPlanAround) {
        
        List<Diary_Entry__c> result = new List<Diary_Entry__c>();
        
        if(itemsToPlanAround == null || itemsToPlanAround.isEmpty()) {
            // Create availability to replace entryToRemove
            DiaryEntry removeEntry = new DiaryEntry(entryToRemove);
            Diary_Entry__c newGap = removeEntry.newGap(entryToRemove.Start__c, entryToRemove.End__c);
            result.add(newGap);
            
            return result;
        }
        
        Map<DateTime, DateTime> startAndEndTimes = getStartAndEndTimes(itemsToPlanAround);
        List<DateTime> planAroundStartTimes = new List<DateTime>(startAndEndTimes.keySet());
        planAroundStartTimes.sort();
        
        DateTime currentStart = entryToRemove.Start__c;
        DateTime latestEnd = null;
        
        for(DateTime planAround : planAroundStartTimes) {
            System.debug(LoggingLevel.INFO, 'currentStart, planAround, entryToRemove.End__c: ' + currentStart + ', ' + planAround + ', ' + entryToRemove.End__c);
            if(planAround > currentStart && planAround <= entryToRemove.End__c) {
                // create gap between currentStart and planAround
                DiaryEntry removeEntry = new DiaryEntry(entryToRemove);
                Diary_Entry__c newGap = removeEntry.newGap(currentStart, planAround);
                result.add(newGap);
            }

            if(latestEnd == null || latestEnd < startAndEndTimes.get(planAround)) {
                currentStart = startAndEndTimes.get(planAround);
                latestEnd = startAndEndTimes.get(planAround);
            }
        }
        
        // create after last item to plan around, if necessary
        if(latestEnd < entryToRemove.End__c) {
            DiaryEntry removeEntry = new DiaryEntry(entryToRemove);
            Diary_Entry__c newGap = removeEntry.newGap(latestEnd, entryToRemove.End__c);
            result.add(newGap);
        }
        
        return result;
    }
    
    private static WeekManager.RemoveEntryResult growOrShrink(WeekManager.RemoveEntryResult result, List<Diary_Entry__c> gaps, 
                                                                Diary_Entry__c entryToRemove, Diary_Entry__c left, Diary_Entry__c right) {
        //System.debug(LoggingLevel.INFO, 'left, right, left RT, right RT: ' + left + ', ' + right + ', ' + left.RecordTypeID + ', ' + right.RecordTypeID);
        
        Boolean leftIsGap = (left != null && left.RecordTypeID == ENTRY_RECTYPE_AVAIL);
        Boolean rightIsGap = (right != null && right.RecordTypeID == ENTRY_RECTYPE_AVAIL);
        
        if(!leftIsGap && !rightIsGap) {
            // Nothing to grow or shrink, just add gaps
            result.addModEntry(gaps);
            return result;
            
        } else if(leftIsGap && rightIsGap) {
            // There's a gap to the right and to the left, need to grow some diary entries.
            // This case is the most complicated one as there may be a number of situations
            // we need to handle.
            
            // Firstly, loop over gaps to find the location in the list of the gaps of gaps
            // that are suitable for growing.
            
            Integer leftIndex = null;
            Integer rightIndex = null;
            
            for(integer i = 0;  i < gaps.size() ; i++) {
                Diary_Entry__c gap = gaps[i];

                System.debug(LoggingLevel.INFO, 'gap start and end: ' + gap.Start__c + ', ' + gap.End__c);
                System.debug(LoggingLevel.INFO, 'right start and left end: ' + right.Start__c + ', ' + left.End__c);

                if(DateTimeHelper.dateEquals(gap.End__c, right.Start__c)) {
                    // Right needs to be stretched to the start of this gap
                    rightIndex = i;
                }
                
                if(DateTimeHelper.dateEquals(gap.Start__c, left.End__c)) {
                    // Right needs to be stretched to the start of this gap
                    leftIndex = i;
                }
                
                if(leftIndex != null && rightIndex != null)
                    break;
            }

            if(leftIndex == null && rightIndex == null) {
                // There aren't any suitable gaps being created to stretch the left or right gaps   
                result.addModEntry(gaps);
                return result;
            } else if(leftIndex != null && rightIndex == null) {
                // Grow the left gap (grows to the right)
                DiaryEntry leftGap = new DiaryEntry(left);
                leftGap.growRight(gaps[leftIndex].End__c);
                result.addModEntry(left);
                
                gaps.remove(leftIndex);
                if(!gaps.isEmpty())
                    result.addModEntry(gaps);
                
                return result;
            } else if(leftIndex == null && rightIndex != null) {
                // Grow the right gap (grows to the left)
                DiaryEntry rightGap = new DiaryEntry(right);
                rightGap.growLeft(gaps[rightIndex].Start__c);
                result.addModEntry(right);
                
                gaps.remove(rightIndex);
                if(!gaps.isEmpty())
                    result.addModEntry(gaps);
                
                return result;
            } else if(leftIndex == rightIndex) {
                // One gap between two availabilities
                DiaryEntry rightGap = new DiaryEntry(right);
                System.debug(LoggingLevel.INFO, 'right: ' + right);
                System.debug(LoggingLevel.INFO, 'left.Start__c: ' + left.Start__c);
                rightGap.growLeft(left.Start__c);
                result.addDelEntry(left);
                result.addModEntry(right);
                System.debug(LoggingLevel.INFO, 'right again: ' + right);
                gaps.remove(leftIndex);
                if(!gaps.isEmpty())
                    result.addModEntry(gaps);
                
                return result;
            } else if(leftIndex != null && rightIndex != null) {
                // Grow the right gap (to the left) and the left gap (to the right)
                DiaryEntry rightGap = new DiaryEntry(right);
                rightGap.growLeft(gaps[rightIndex].Start__c);
                
                DiaryEntry leftGap = new DiaryEntry(left);
                leftGap.growRight(gaps[leftIndex].End__c);
                
                result.addModEntry(new List<Diary_Entry__c> {left, right});
                
                if(rightIndex > leftIndex) {
                    gaps.remove(rightIndex);
                    gaps.remove(leftIndex);
                } else {
                    gaps.remove(leftIndex);
                    gaps.remove(rightIndex);
                }
                
                if(!gaps.isEmpty())
                    result.addModEntry(gaps);
                    
                return result;
            } else {
                throw new myException('Encountered a problem, possibly due to invalid diary data. Please contact your administrator');
            }
        } else if(!leftIsGap && rightIsGap) {
            // grow the right gap to the left
            if(DateTimeHelper.dateEquals(gaps[gaps.size()-1].End__c, right.Start__c)) {
                DiaryEntry rightGap = new DiaryEntry(right);
                rightGap.growLeft(gaps[gaps.size()-1].Start__c);
                result.addModEntry(right);
                
                gaps.remove(gaps.size() - 1);
                if(!gaps.isEmpty())
                    result.addModEntry(gaps);
                
                return result;
            } else {
                result.addModEntry(gaps);
                return result;
            }
        } else if(leftIsGap && !rightIsGap) {
            // grow the left gap to the right
            if(DateTimeHelper.dateEquals(gaps[0].Start__c, left.End__c)) {
                DiaryEntry leftGap = new DiaryEntry(left);
                leftGap.growRight(gaps[0].End__c);
                result.addModEntry(left);
                
                gaps.remove(0);
                if(!gaps.isEmpty())
                    result.addModEntry(gaps);
                    
                return result;
            } else {
                result.addModEntry(gaps);
                return result;
            }
        } else {
            throw new myException('Encountered a problem, possibly due to invalid diary data. Please contact your administrator');
        }
    }

    private static void managePoolEntryOnInsert(Diary_Entry__c poolGap, Double hours, WeekManager.CreateEntryResult result)
    {
//      System.debug(LoggingLevel.INFO, 'poolGap (Insert): ' + poolGap);
        poolGap.Hours__c -= hours;
        result.addModEntry(poolGap);
    }
    
    private static void managePoolEntryOnRemove(Diary_Entry__c poolGap, Double hours, WeekManager.RemoveEntryResult result)
    {
//      System.debug(LoggingLevel.INFO, 'poolGap (remove): ' + poolGap);
        poolGap.Hours__c += hours;
//      System.debug(LoggingLevel.INFO, 'poolGap after hours mod (remove): ' + poolGap);
        result.addModEntry(poolGap);
    }   
    
    /*
    #######################################################################################
    Code after here is for outputting diary entries in a primative way for debugging
    #######################################################################################
    */

    public static String outputDiary2(List<Diary_Entry__c> outEntries, String mssg)
    {
        Datetime earliest;
        Datetime latest;
        String letter = '';
        //find earliest and latest date
        for(Diary_Entry__c outEntry : outEntries)
        {
            if(earliest == null || earliest > outEntry.Start__c)
            {
                earliest = outEntry.Start__c;
            }
            if(latest == null || latest < outEntry.End__c)
            {
                latest = outEntry.End__c;
            }           
        }
        String result = mssg;
        for(Diary_Entry__c outEntry : outEntries)
        {
            if(outEntry != null)
            {
                if(outEntry.RecordTypeId == ENTRY_RECTYPE_AVAIL){letter = 'G';}
                else if (outEntry.RecordTypeId == ENTRY_RECTYPE_UNAVAIL){letter = 'U';}
                else if (outEntry.RecordTypeId == ENTRY_RECTYPE_BOOKING){letter = 'B';}
                result += '\n' + 'Name: ' + outEntry.name + '\n' + 'Hours: ' + outEntry.Hours__c + '\n' + 'Record Type Id: ' + outEntry.RecordTypeId + '\n' + 'Skill: ' + outEntry.Sub_Type__c + '\n' + makeLetters(earliest, latest, outEntry.End__c, outEntry.Start__c,letter);
            }
        }
//      System.debug(result);
        return result;
    }
    
    public static String outputDiary2(Id week)
    {
        String result = '';
        String letter = '';

        List<Diary_Entry__c> entries = new List<Diary_Entry__c>([select Id, Start__c, End__c, RecordTypeId, Hours__c, Name, Sub_Type__c, Overbooked_hours__c from Diary_Entry__c where week__c = :week order by start__c asc]);
        List<Diary_Entry__c> lazyReverseEntries = new List<Diary_Entry__c>([select Id, Start__c, End__c, RecordTypeId, Hours__c from Diary_Entry__c where week__c = :week order by End__c desc]);
        
        if(entries.size() == 0) return '';
        Datetime earliest = entries[0].Start__c;
        Datetime latest = lazyReverseEntries[0].End__c;
        for(Diary_Entry__c outEntry : entries)
        {
            if(outEntry != null)
            {
                if(outEntry.RecordTypeId == ENTRY_RECTYPE_AVAIL){letter = 'G';}
                else if(outEntry.RecordTypeId == ENTRY_RECTYPE_UNAVAIL){letter = 'U';}
                else if(outEntry.RecordTypeId == ENTRY_RECTYPE_BOOKING){letter = 'B';}
                else{letter = '?';}
                //result += '\n' + entry.name + '\n' + 'Hours: ' + entry.Hours__c + '\n' + makeLetters(overallStart, overallEnd, entry.End__c, entry.Start__c,letter);
                result += '\n' + 'Name: ' + outEntry.name + '\n' + 'Hours: ' + outEntry.Hours__c + '\nOverBookedHours: ' + outEntry.Overbooked_Hours__c + '\n' + 'Record Type Id: ' + outEntry.RecordTypeId + '\n' + 'Skill: ' + outEntry.Sub_Type__c + '\n' + makeLetters(earliest, latest, outEntry.End__c, outEntry.Start__c,letter);
            }
        }
        
        result += ' \n';

        return result;
    }   
    
    private static String makeLetters(Datetime overallStart, Datetime overallEnd, DateTime endItem, DateTime startItem, String whatLetter)
    {
        String letterString = '';
        Long startToItem = SubtractDate(startItem, overallStart);       
        Long itemSize = SubtractDate(endItem, startItem);
        Long itemToEnd = SubtractDate(overallEnd,endItem);
        
        Integer i;
        
        for(i = 0; i < startToItem; i++)
        {
            letterString += '-';
        }       
        for(i = 0; i < itemSize; i++)
        {
            letterString += whatLetter;
        }
        for(i = 0; i < itemToEnd; i++)
        {
            letterString += '-';
        }
        //for debugging actual dates / times
        letterString+= '\nStart: ' + startItem + '\nEnd  : ' + endItem;     
        return letterString;
    }
    
    //get the number of hours difference between 2 dates
    private static Long SubtractDate(DateTime highDate, DateTime lowDate)
    {
        highDate = removeSecs(highDate);
        lowDate = removeSecs(lowDate);
        Long timeDiff = highDate.getTime() - lowDate.getTime();
        //System.debug(LoggingLevel.INFO, 'time difference: ' + timeDiff/(1000 * 60 * 60));
        return timeDiff/(1000 * 60 * 60); // 1000 milliseconds * 60 seconds * 60 Minutes
    }

    //remove the milliseconds and seconds
    public static Datetime removeSecs(Datetime secsDate)
    {
        return DateTimeHelper.removeSecs(secsDate);
    }   
}