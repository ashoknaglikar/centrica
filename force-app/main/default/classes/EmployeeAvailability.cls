/* EmployeeAvailability
    A class that holds an employee's availability.
    
    Availability is made up of DiaryEntryCollection - there are two Lists within this
    class, one holds availability relating to the business best date, the other holds
    availability relating to the customer preferred date.
    
    There are also references to individual DiaryEntryCollections - these hold 
    references to the earliest DECs that an employee has that allows her to fulfil
    all the skills she can do on a job (if a large enough piece of availability 
    exists), and the largest availability an employee has. There are two of each of 
    these, one for business best date and one for customer preffered date. Helper
    methods (taking a boolean indicating whether business or customer availablity
    is required) are used to access the relevant availability.
*/
public with sharing class EmployeeAvailability {

    public EmployeeInformation parent = null;
    public List<DiaryEntryCollection> business = new List<DiaryEntryCollection>();
    public List<DiaryEntryCollection> customer = new List<DiaryEntryCollection>();
    public DiaryEntryCollection businessEarliest = null;
    public DiaryEntryCollection customerEarliest = null;
    public DiaryEntryCollection businessLargest = null;
    public DiaryEntryCollection customerLargest = null;
    
    public Map<Date, Date> awayGeographyStartEnd = new Map<Date, Date>();
    
    /* EmployeeAvailability(EmployeeInformation ei)
        Constructor. Takes an EmployeeInformation object.*/
    public EmployeeAvailability(EmployeeInformation ei) {
        parent = ei;
    }
    
    // Turns entries into DECs, taking into account whether they are adjacent, in the same week etc.
    /* addAvailability(List<Diary_Entry__c> entries, boolean isBusiness)
        Takes a list of diary entries and a boolean to create appropriate DiaryEntryCollections. 
        This is slightly more complicated due to the way availability is modelled. Diary Entries 
        are grouped by week and these are then used to create DiaryEntryCollections. */
    public void addAvailability(List<Diary_Entry__c> allEntries, boolean isBusiness) {
        // Defect 358
        // Loop over entries and remove unavailability into separate list
        List<Diary_Entry__c> entries = new List<Diary_Entry__c>(); // entries = availability (either Availability or Job Booking)
        List<Diary_Entry__c> unavailability = new List<Diary_Entry__c>();
        
        Datetime earliestDT = DiaryEntryCollection.getEarliestDT(isBusiness);
        System.debug(LoggingLevel.INFO, 'earliestDT: ' + earliestDT);
        
        for(Diary_Entry__c de : allEntries) {
            if(de.Record_Type__c == SearchBlackBox.UNAVAILABILITY_DIARY_ENTRY_TYPE) {
                unavailability.add(de); 
            } else if(de.Start__c < earliestDT && de.End__c < earliestDT){
               continue;
            } else {
                if(de.Record_Type__c == 'Non Productive Job Booking') continue; //PRB00029160
                else
                entries.add(de);
            }
        }
        // End Defect 358

        // If no entries passed in, nothing to do so return.
        if(entries.isEmpty())
            return;

        // Defect XXX
        // Create Unavailability Diary Entries for any period of time covered by away geographies
        if(!awayGeographyStartEnd.isEmpty()) {
            unavailability = handleAwayGeographies(unavailability);
           // system.debug(LoggingLevel.INFO,'Line 70:'+unavailability);

        }


        // If only one Diary Entry was passed in, only need to create the DEC, add it and return. 
        if(entries.size() == 1) {
            System.debug(LoggingLevel.INFO, 'Only one entry'+entries);
            // If the entry is not a gap, return.
            // No longer needed due to fix for defect 358 above!
            //if(entries[0].Record_Type__c == SearchBlackBox.UNAVAILABILITY_DIARY_ENTRY_TYPE)
            //  return;
            // Otherwise, create a DiaryEntryCollection, add it, and return.
           //system.debug(LoggingLevel.INFO,'Line 83:'+entries+' '+unavailability+' '+isBusiness+' '+parent+' '+earliestDT);

            List<DiaryEntryCollection> dec = DiaryEntryCollection.createDECs(entries, unavailability, isBusiness, parent, earliestDT);
            //system.debug(LoggingLevel.INFO,'Line 85:'+dec);
            addDECs(dec, isBusiness);
            
            return;
        }
        
        // More than one availability entry was passed in.
        // We loop over the entries and add to a list of diary entries that are in the same week
        // Once we find an entry that is in another week, we use the list to create a
        // DiaryEntryCollection, clear the list, add the new entry and continue. 
        
        //System.debug(LoggingLevel.INFO, 'More than one entry');
        Diary_Entry__c first = entries[0];
        Integer count = 1;
        List<Diary_Entry__c> currentColl = new List<Diary_Entry__c>();
        // By default, we add the first entry to the list.
        currentColl.add(first);

        // This loop looks at an element and the next one in the list. We have looked at the
        // first entry above, so we start with the next one.
        while(count < entries.size()) {
            Diary_Entry__c second = entries[count];
            
            if(DateTimeHelper.dateEquals(first.End__c, second.Start__c)) {
                // First finishes at the same time that second starts, these entries are adjacent and 
                // therefore should be treated as one. Add to the collection.
                //System.debug(LoggingLevel.INFO, 'Dates are equal');
                currentColl.add(second);
            } else if (!DateTimeHelper.sameWeek(first.End__c, second.Start__c)) {
                // First and second are in different weeks.
                //System.debug(LoggingLevel.INFO, 'Dates are not in same week');
//rjd - 2010-01-08 - bug testing - can remove (2 lines)
//              count++;
//              continue;
                //Create a new DEC out of the entries in the currentColl list 
                List<DiaryEntryCollection> dec = DiaryEntryCollection.createDECs(currentColl, unavailability, isBusiness, parent, earliestDT);
                // If a DEC was created (dec != null), add it to the object's lists
                if(dec != null)
                    addDECs(dec, isBusiness);
                
                // Now clear the list and add the second - we are starting the collection for the next week
                currentColl.clear();
                currentColl.add(second);
            } else {
                // Datetimes of first and second are not equal, but exist in the same week, therefore there
                // is a gap between them and they should be created as separate DECs.
                
                //System.debug(LoggingLevel.INFO, 'Dates are not equal and in same week');
                // Create a new DEC out of the entries in the currentColl list
                List<DiaryEntryCollection> dec = DiaryEntryCollection.createDECs(currentColl, unavailability, isBusiness, parent, earliestDT);
                // If a DEC was created (dec != null), add it to the object's lists
                if(dec != null)
                    addDECs(dec, isBusiness);
                // Now clear the list and add the second - we are starting the collection for the next week
                currentColl.clear();
                currentColl.add(second);
            }
            
            // Set first to be the next entry (second in this iteration of the loop) and increment count
            first = entries[count];
            count++;
        }
        
        // If there are any entries in currentColl, create a DEC and add it.
        if(!currentColl.isEmpty()) {
            List<DiaryEntryCollection> dec = DiaryEntryCollection.createDECs(currentColl, unavailability, isBusiness, parent, earliestDT);
            addDECs(dec, isBusiness);
        }
        
    }   

    /* getEarliest(Boolean getBusiness)
        Returns the earliest DEC that can fit all the employees skills for the job. If no such
        DEC exists, this method returns null. If getBusiness is true, businessEarliest is
        returned, otherwise customerEarliest is. */
    public DiaryEntryCollection getEarliest(Boolean getBusiness) {
        if(getBusiness) {
            return businessEarliest;
        } else {
            return customerEarliest;
        }
    }
    
    /* getLargest(Boolean getBusiness)
        Returns the employee's largest DEC. If getBusiness is true, businessLargest is
        returned, otherwise customerLargest is. */
    public DiaryEntryCollection getLargest(Boolean getBusiness) {
        if(getBusiness) {
            return businessLargest;
        } else {
            return customerLargest;
        }
    }
    
    /* getDECs(Boolean getBusiness)
        Returns all of an employee's DECs; if getBusiness is true, DECs relating to business
        best date are returned, otherwise, DECs relating to customer preferred date are returned.*/
    public List<DiaryEntryCollection> getDECs(Boolean getBusiness) {
        if(getBusiness) {
            return business;
        } else {
            return customer;
        }
    }
    
    /* addDECs(List<DiaryEntryCollection> addMe, boolean isBusiness)
        Adds DECs to this object's relevant DEC list, as determined by the isBusiness boolean
        passed into the method. This method also calculates if the DECs being added are suitable
        for the earliest/largest references and assigns them appropriately if necessary. */
    private void addDECs(List<DiaryEntryCollection> addMe, boolean isBusiness) {
        if(addMe == null || addMe.isEmpty())
            return;
        
        //System.debug(LoggingLevel.INFO, 'addMe: ' + addMe.size());
        for(DiaryEntryCollection dec : addMe) {
            //System.debug(LoggingLevel.INFO, 'Adding DiaryEntryCollection: ' + dec.print());
            if(isBusiness) {
                business.add(dec);
                //System.debug(LoggingLevel.INFO, 'dec is: ' + dec);
                if(businessEarliest == null && dec.numberOfHours >= parent.hoursAbleToFulfil)
                    businessEarliest = dec;
                if(businessLargest == null || dec.numberOfHours > businessLargest.numberOfHours)
                    businessLargest = dec;
            } else {
                customer.add(dec);
                //System.debug(LoggingLevel.INFO, 'dec is: ' + dec);
                if(customerEarliest == null && dec.numberOfHours >= parent.hoursAbleToFulfil)
                    customerEarliest = dec;
                if(customerLargest == null || dec.numberOfHours > customerLargest.numberOfHours)
                    customerLargest = dec;
            }
        }
    }

    public void print() {
        for(DiaryEntryCollection dec : customer) {
            System.debug(LoggingLevel.INFO, 'printing DiaryEntryCollection: ' + dec);
            dec.print();
        }
    }

    private List<Diary_Entry__c> handleAwayGeographies(List<Diary_Entry__c> unavailability) {
        Time dayStart = Time.newInstance(0,1,0,0);
        Time dayEnd = Time.newInstance(23,59,0,0);
        Map<Date, Diary_Entry__c> awayUnavsByStart = new Map<Date, Diary_Entry__c>();
        
        for(Date awayStart : awayGeographyStartEnd.keySet()) {
            Date awayEnd = awayGeographyStartEnd.get(awayStart);
            Diary_Entry__c awayUnav = new Diary_Entry__c(Start__c = DateTime.newInstance(awayStart, dayStart),
                                                        End__c = DateTime.newInstance(awayEnd, dayEnd));
            awayUnavsByStart.put(awayStart, awayUnav);

        }
        
        // sort the away unavs
        List<Date> startsSorted = new List<Date>(awayUnavsByStart.keySet());
        startsSorted.sort();
        List<Diary_Entry__c> awayUnavs = new List<Diary_Entry__c>();
        for(Date d : startsSorted) {
            awayUnavs.add(awayUnavsByStart.get(d));
        } 
        
        // now merge unavailability from the database with any unavailability created above
        if(unavailability.isEmpty()) {
            unavailability = awayUnavs;
        } else {
            // merge the two lists - this is based on a mergesort tutorial at http://www.java2s.com/Tutorial/Java/0140__Collections/Mergesortmergingtwoarraysintoathird.htm
            List<Diary_Entry__c> consolidatedUnavs = new List<Diary_Entry__c>();
            
            Integer awayCtr = 0;
            Integer unavCtr = 0;
            while(awayCtr < awayUnavs.size() && unavCtr < unavailability.size()) {
                if(awayUnavs[awayCtr].Start__c < unavailability[unavCtr].Start__c)
                    consolidatedUnavs.add(awayUnavs[awayCtr++]);
                else
                    consolidatedUnavs.add(unavailability[unavCtr++]);
            }
            
            while(awayCtr < awayUnavs.size())
                consolidatedUnavs.add(awayUnavs[awayCtr++]);
            
            while(unavCtr < unavailability.size())
                consolidatedUnavs.add(unavailability[unavCtr++]);
                
            unavailability = consolidatedUnavs;
        }
        
        return unavailability;
    }

}