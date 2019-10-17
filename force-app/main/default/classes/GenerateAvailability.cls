/*
   This class is used for generating gaps for pool & non-pool employees.
   This is not used by any other part of application apart from generating 
   gaps using native salesforce.
   We consider employee,work cycle,shift pattern,week & diary entry objects while 
   generating gaps.
*/

global class GenerateAvailability {
  
   public static Map<String, String> maxHourMap = new Map<String, String>();
   public static Map<String, String> UnavHourMap = new Map<String, String>();
   public static Map<String, String> UnavHourMapNWD = new Map<String, String>();
   public static Savepoint  sp;
   public static List<Diary_Entry__c> nonPoolDiaryEntries=new List<Diary_Entry__c>();
   public static List<Diary_Entry__c> poolDiaryEntries = new List<Diary_Entry__c>();
   public static String availableEntryType = Utilities.getRecordTypeId('Availability', 'Diary_Entry__c');
   public static String unavailableEntryType = Utilities.getRecordTypeId('Unavailability', 'Diary_Entry__c');   
   
   /*
    This method is invoked when we click generate availabilty button on work cycle detail page.
    This method is used for generating weeks & entries for pool as well as normal employees. 
   */   
    
    webservice static String createAvailability(ID[] workCycleID){

        Work_Cycle__c workCycle = [Select Employee__c,Employee__r.Pool_Diary__c,Number_of_Weeks__c,Shift_Pattern__c,Morning_Start_Time__c,Midday_Start_Time__c,
        Shift_Pattern__r.Monday_Start_Time__c,Shift_Pattern__r.Monday_End_Time__c,Shift_Pattern__r.Monday_Max_Hours__c,
        Shift_Pattern__r.Tuesday_Start_Time__c,Shift_Pattern__r.Tuesday_End_Time__c,Shift_Pattern__r.Tuesday_Max_Hours__c,
        Shift_Pattern__r.Wednesday_Start_Time__c,Shift_Pattern__r.Wednesday_End_Time__c,Shift_Pattern__r.Wednesday_Max_Hours__c,
        Shift_Pattern__r.Thursday_Start_Time__c,Shift_Pattern__r.Thursday_End_Time__c,Shift_Pattern__r.Thursday_Max_Hours__c,
        Shift_Pattern__r.Friday_Start_Time__c,Shift_Pattern__r.Friday_End_Time__c,Shift_Pattern__r.Friday_Max_Hours__c,
        Shift_Pattern__r.Saturday_Start_Time__c,Shift_Pattern__r.Saturday_End_Time__c,Shift_Pattern__r.Saturday_Max_Hours__c,
        Shift_Pattern__r.Sunday_Start_Time__c,Shift_Pattern__r.Sunday_End_Time__c,Shift_Pattern__r.Sunday_Max_Hours__c,
        Start_Date__c,Shift_Pattern__r.Pool_Shift_Pattern__c, Shift_Pattern__r.Sun_Unav_End_Time__c,
        Shift_Pattern__r.Sat_Unav_End_Time__c, Shift_Pattern__r.Fri_Unav_End_Time__c, Shift_Pattern__r.Thu_Unav_End_Time__c,
        Shift_Pattern__r.Wed_Unav_End_Time__c, Shift_Pattern__r.Tue_Unav_End_Time__c, Shift_Pattern__r.Mon_Unav_End_Time__c,
        Shift_Pattern__r.Sun_Unav_Start_Time__c, Shift_Pattern__r.Sat_Unav_Start_Time__c, Shift_Pattern__r.Fri_Unav_Start_Time__c,
        Shift_Pattern__r.Thu_Unav_Start_Time__c, Shift_Pattern__r.Wed_Unav_Start_Time__c, Shift_Pattern__r.Tue_Unav_Start_Time__c,
        Shift_Pattern__r.Mon_Unav_Start_Time__c,Shift_Pattern__r.Unavailability_Reason__c from Work_Cycle__c where Id=:workCycleID[0]];
        
        Integer numberOfWeeks = (workCycle.Number_of_Weeks__c).intValue();
        List<Week__c> weeks = new List<Week__c>();
        Week__c weekInstance;
        workCycle.Start_Date__c = workCycle.Start_Date__c.toStartOfWeek(); 
        Date startDateNextOfWeek = workCycle.Start_Date__c;
        
        if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c && !workCycle.Employee__r.Pool_Diary__c){
            
            return 'Both Employee as well as Shift Pattern must be of same type. (Pool / Non-Pool.)';
    
        }else if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c && workCycle.Employee__r.Pool_Diary__c){
            
            return 'Both Employee as well as Shift Pattern must be of same type. (Pool / Non-Pool.)';
            
        }
              
        String status = checkExistingWeeks(workCycle,numberOfWeeks);
        if(status.length()>5){
            return status;
        }
        
       // Create a savepoint because the data should not be committed to the database in case of failure
        sp = Database.setSavepoint();
        
       // Calculate max hours on week
       
            maxHourMap = calculateMaxHours(workCycle);
            if(!workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c)
            UnavHourMap = calculateUnavailaHours(workCycle);
            
            if(maxHourMap.get('validationErrorNegative')!=null || UnavHourMap.get('validationErrorNegative')!=null){
                return (maxHourMap.get('validationErrorNegative')+UnavHourMap.get('validationErrorNegative'));
            }
            
            Double totalHours = populateMaxHoursOnWeek(maxHourMap);
        
        for(Integer i=0;i<numberOfWeeks;i++){
            
            weekInstance = new Week__c();
            weekInstance.Employee__c = workCycle.Employee__c;
            weekInstance.Shift_Pattern__c = workCycle.Shift_Pattern__c;
            weekInstance.Week_Commencing__c = startDateNextOfWeek;
            weekInstance.Total_Hours__c = totalHours;
            weekInstance.Mid_day_Start_Time__c = workCycle.Midday_Start_Time__c; //Populate the values in the Week
            weekInstance.Morning_Start_Time__c = workCycle.Morning_Start_Time__c;//Populate the start Time in the week;
            // This part of code checks if shift pattern is pool.
            // If yes then we populate mx hours on week record. (monday till sunday)
            
         if(workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c){
            
             if((maxHourMap.get('Mon')).length() > 0){
                  weekInstance.Monday_Max_Hours__c = Double.valueOf(maxHourMap.get('Mon'));
               }
             if((maxHourMap.get('Tue')).length() > 0){
                  weekInstance.Tuesday_Max_Hours__c = Double.valueOf(maxHourMap.get('Tue'));
               }
             if((maxHourMap.get('Wed')).length() > 0){
                  weekInstance.Wednesday_Max_Hours__c = Double.valueOf(maxHourMap.get('Wed'));
               }
             if((maxHourMap.get('Thu')).length() > 0){
                  weekInstance.Thursday_Max_Hours__c = Double.valueOf(maxHourMap.get('Thu'));
              }
             if((maxHourMap.get('Fri')).length() > 0){
                 weekInstance.Friday_Max_Hours__c = Double.valueOf(maxHourMap.get('Fri'));
             }
             if((maxHourMap.get('Sat')).length() > 0){
                 weekInstance.Saturday_Max_Hours__c = Double.valueOf(maxHourMap.get('Sat'));
            }
             if((maxHourMap.get('Sun')).length() > 0){
                weekInstance.Sunday_Max_Hours__c = Double.valueOf(maxHourMap.get('Sun'));
            }   
                                          
        }
        
        // Part of the code for populating max hours ends here.
            
            
            weeks.add(weekInstance);            
            startDateNextOfWeek = (startDateNextOfWeek.toStartOfWeek()).addDays(7);
            
         }
        
        if(weeks.size()>0){
            
            try{                
                   Database.insert(weeks);
                
                }catch(Exception excp){
                    
                    // Revert the database to the original state
                    Database.rollback(sp);
                    return 'Error in inserting weeks and gaps.';
                    
                }           
                    
        }
       
       for(Week__c weekRecord:weeks){ 
        
         // Change request for pool diaries starts
         
            if(workCycle.Employee__r.Pool_Diary__c){
                
                    generatePoolDiary(workCycle,weekRecord);
                    
            } else {
                 
                 generateEntries(workCycle,weekRecord);
                 
            }
            
        // Change request for pool diaries ends
        
        }
        
     if(nonPoolDiaryEntries.size()>0)   {
            
            try{
                system.debug('nonPoolDiaryEntries-->'+nonPoolDiaryEntries);
                nonPoolDiaryEntries = splitAvailabilty(nonPoolDiaryEntries,workCycle);
                
                Database.insert(nonPoolDiaryEntries);               
               }catch(Exception excp){
                      // Revert the database to the original state
                      Database.rollback(sp);
                      return status = 'Error in generating weeks & gaps.';
                 }
                 
     }
        
     // Change request for pool diaries starts
        
         if(poolDiaryEntries.size()>0){
            
            try{                
                   Database.insert(poolDiaryEntries);
                
                }catch(Exception excp){
                    
                    // Revert the database to the original state
                    Database.rollback(sp);
                    return 'Error in inserting weeks and gaps.';
                    
                }           
                    
        }
        
       // Change request for pool diaries ends
        
        return 'Diary has been generated succesfully.';
        
    }
    
  /* 
     This method is used for calculating maximum hours in case of pool as well as non-pool employees. 
     Maximum hours calculated are then stamped on corresponding week record.
     We use the same values while creating diary entries instead of calculating maximum hours again.
     It checks for different scenarios for shift patterns.
  */
 
  public static Map<String,String> calculateMaxHours(Work_Cycle__c workCycle){
    
              maxHourMap.clear();
                                   
             // Check if start & end times are not empty. 
             // Then, calculate max hours difference & put it in map.
             // If start & end times are empty put empty string in map.
               
          if(!workCycle.Employee__r.Pool_Diary__c 
             && ((((String)workCycle.Shift_Pattern__r.Monday_Start_Time__c) != null)
             && (((String)workCycle.Shift_Pattern__r.Monday_End_Time__c) != null))){
                                    
                    maxHourMap.put('Mon',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                  (workCycle.Shift_Pattern__r.Monday_Start_Time__c,
                                   workCycle.Shift_Pattern__r.Monday_End_Time__c)));
                                                          
                                     }else if(workCycle.Employee__r.Pool_Diary__c
                                               && String.valueOf(workCycle.Shift_Pattern__r.Monday_Max_Hours__c)!= null){
                                    
                                           maxHourMap.put('Mon',String.valueOf(workCycle.Shift_Pattern__r.Monday_Max_Hours__c));
                                        
                                        }else{
                                    
                                           maxHourMap.put('Mon', '');
                                    
                                         }

          if(!workCycle.Employee__r.Pool_Diary__c
             &&((((String)workCycle.Shift_Pattern__r.Tuesday_Start_Time__c) != null)
             && (((String)workCycle.Shift_Pattern__r.Tuesday_End_Time__c) != null))){
                                    
                   maxHourMap.put('Tue',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                 (workCycle.Shift_Pattern__r.Tuesday_Start_Time__c,
                                  workCycle.Shift_Pattern__r.Tuesday_End_Time__c)));
                                                          
                                      }else if(workCycle.Employee__r.Pool_Diary__c
                                                  && String.valueOf(workCycle.Shift_Pattern__r.Tuesday_Max_Hours__c)!= null){
                                    
                                              maxHourMap.put('Tue',String.valueOf(workCycle.Shift_Pattern__r.Tuesday_Max_Hours__c));
                                        
                                         }else{
                                    
                                              maxHourMap.put('Tue', '');
                                    
                                             }
                                      
        if(!workCycle.Employee__r.Pool_Diary__c
           &&((((String)workCycle.Shift_Pattern__r.Wednesday_Start_Time__c) != null)
           && (((String)workCycle.Shift_Pattern__r.Wednesday_End_Time__c) != null))){
                                    
                                    maxHourMap.put('Wed',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Wednesday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Wednesday_End_Time__c)));
                                                          
                                 }else if(workCycle.Employee__r.Pool_Diary__c
                                           && String.valueOf(workCycle.Shift_Pattern__r.Wednesday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Wed',String.valueOf(workCycle.Shift_Pattern__r.Wednesday_Max_Hours__c));
                                        
                                      }else{
                                    
                                          maxHourMap.put('Wed', '');
                                    
                                       }

      if(!workCycle.Employee__r.Pool_Diary__c
         &&((((String)workCycle.Shift_Pattern__r.Thursday_Start_Time__c) != null)
         && (((String)workCycle.Shift_Pattern__r.Thursday_End_Time__c) != null))){
                                    
                                    maxHourMap.put('Thu',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Thursday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Thursday_End_Time__c)));
                                                          
                                 } else if(workCycle.Employee__r.Pool_Diary__c
                                             && String.valueOf(workCycle.Shift_Pattern__r.Thursday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Thu',String.valueOf(workCycle.Shift_Pattern__r.Thursday_Max_Hours__c));
                                        
                                      }else{
                                    
                                           maxHourMap.put('Thu', '');
                                    
                                       }
                                
    if(!workCycle.Employee__r.Pool_Diary__c
       && ((((String)workCycle.Shift_Pattern__r.Friday_Start_Time__c) != null)
       && (((String)workCycle.Shift_Pattern__r.Friday_End_Time__c) != null))){
                                    
                                     maxHourMap.put('Fri',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Friday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Friday_End_Time__c)));
                                                          
                                 }else if(workCycle.Employee__r.Pool_Diary__c
                                             && String.valueOf(workCycle.Shift_Pattern__r.Friday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Fri',String.valueOf(workCycle.Shift_Pattern__r.Friday_Max_Hours__c));
                                        
                                      }else{
                                    
                                          maxHourMap.put('Fri', '');
                                    
                                       }

  if(!workCycle.Employee__r.Pool_Diary__c 
     &&((((String)workCycle.Shift_Pattern__r.Saturday_Start_Time__c) != null)
     && (((String)workCycle.Shift_Pattern__r.Saturday_End_Time__c) != null))){
                                    
                                     maxHourMap.put('Sat',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Saturday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Saturday_End_Time__c)));
                                                          
                                 }else if(workCycle.Employee__r.Pool_Diary__c
                                            && String.valueOf(workCycle.Shift_Pattern__r.Saturday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Sat',String.valueOf(workCycle.Shift_Pattern__r.Saturday_Max_Hours__c));
                                        
                                      }else{
                                    
                                           maxHourMap.put('Sat', '');
                                    
                                       }
  if(!workCycle.Employee__r.Pool_Diary__c
     &&((((String)workCycle.Shift_Pattern__r.Sunday_Start_Time__c) != null)
     && (((String)workCycle.Shift_Pattern__r.Sunday_End_Time__c) != null))){
                                    
                                      maxHourMap.put('Sun',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Sunday_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Sunday_End_Time__c)));
                                                          
                                   }else if(workCycle.Employee__r.Pool_Diary__c 
                                                && String.valueOf(workCycle.Shift_Pattern__r.Sunday_Max_Hours__c)!= null){
                                    
                                      maxHourMap.put('Sun',String.valueOf(workCycle.Shift_Pattern__r.Sunday_Max_Hours__c));
                                        
                                      }else{
                                    
                                            maxHourMap.put('Sun', '');
                                    
                                       }

             if((maxHourMap.get('Mon').indexOf('-') ==  0) || (maxHourMap.get('Tue').indexOf('-') ==  0) ||
                (maxHourMap.get('Wed').indexOf('-') ==  0) || (maxHourMap.get('Thu').indexOf('-') ==  0) ||
                (maxHourMap.get('Fri').indexOf('-') ==  0) || (maxHourMap.get('Sat').indexOf('-') ==  0) ||
                (maxHourMap.get('Sun').indexOf('-') ==  0)){
                    maxHourMap.clear();
                    maxHourMap.put('validationErrorNegative', 'Shift pattern is invalid. Please modify the corresponding shift pattern.');
             }
             
             return maxHourMap;
             
    }
 
 // Method for calculating maximum hours for week objects finishes here.
 
 
 
 /*
      This method is used to populate maximum hours on week object.
      These values are copied from the maximum hour map which is populated in previous method.
 */
 
 public static Double populateMaxHoursOnWeek(Map<String,String> maxHours){
     
     Double totalHours = 0.0;
     
     if((maxHours.get('Mon')).length() > 0){
     totalHours = totalHours+Double.valueOf(maxHours.get('Mon'));
     } 
      
     if((maxHours.get('Tue')).length() > 0){
     totalHours = totalHours+Double.valueOf(maxHours.get('Tue'));
     }
      
     if((maxHours.get('Wed')).length() > 0){
     totalHours = totalHours+Double.valueOf(maxHours.get('Wed'));
     } 
     
     if((maxHours.get('Thu')).length() > 0){
     totalHours = totalHours+Double.valueOf(maxHours.get('Thu'));
     } 
     
     if((maxHours.get('Fri')).length() > 0){
     totalHours = totalHours+Double.valueOf(maxHours.get('Fri'));
     } 
     
     if((maxHours.get('Sat')).length() > 0){
     totalHours = totalHours+Double.valueOf(maxHours.get('Sat'));
     } 
     
     if((maxHours.get('Sun')).length() > 0){
     totalHours = totalHours+Double.valueOf(maxHours.get('Sun'));
     }                                    

     return totalHours;
     
   }
   
 // Method for populating maximum hours on week object ends here.
 
 /*
  This method is used to check existing weeks between the current work cycle period for which we are going to generate gaps.
  If it is present then we need to handle existing weeks first.
 */
 
 public static String checkExistingWeeks(Work_Cycle__C workCycle, Integer numOfWeeks){
    
    String status='';
    
    Date workCycleEndDate = workCycle.Start_Date__c.addDays((numOfWeeks*7)-1);
    
    Integer countOfWeeks = [Select count() from Week__c where 
                                   (Week_Commencing__c >= :(workCycle.Start_Date__c) 
                                   and Week_Commencing__c < :workCycleEndDate)
                                   and Employee__c = :workCycle.Employee__c];
    
    if (countOfWeeks>0){
        
        status = 'Please delete existing weeks & entries falling under this period and then generate availability.';
        
    } else {
        
        status = '';
    }  
    
    return status;                                
     
   }
 
 // Method to check existing weeks for the current work cycleends here.
 
 
 
/*
 
  This method is used to generate seperate entry records for the week under consideration.
  These records are not inserted in database, but used for generating merged diary entries
  which are ultimately inserted in database. We are using record type field instead of relying
  type field.
*/
 
 public static void generateEntries(Work_Cycle__c workCycle,Week__c weekInstance){
    /*Change : WeekendAvailability
        
    */
    List<Diary_Entry__c> entryList = new List<Diary_Entry__c>();
    Diary_Entry__c diaryInstance;
    
    if(workCycle.Shift_Pattern__r.Monday_Start_Time__c != null 
                                          && workCycle.Shift_Pattern__r.Monday_End_Time__c != null){
        diaryInstance = new Diary_Entry__c();
        diaryInstance.RecordTypeId = availableEntryType;
        diaryInstance.Week__c = weekInstance.Id;
        diaryInstance.Start__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Monday_Start_Time__c,0);
        diaryInstance.End__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Monday_End_Time__c,0);
        system.debug('Test--->'+maxHourMap.get('Mon'));
        system.debug('Test--->'+Double.valueOf(maxHourMap.get('Mon')));
        diaryInstance.Hours__c = Double.valueOf(maxHourMap.get('Mon'));
        entryList.add(diaryInstance);
                
    }
    
    if(workCycle.Shift_Pattern__r.Tuesday_Start_Time__c != null 
                                           && workCycle.Shift_Pattern__r.Tuesday_End_Time__c != null){
           diaryInstance = new Diary_Entry__c();
           diaryInstance.RecordTypeId = availableEntryType;
           diaryInstance.Week__c = weekInstance.Id;
           diaryInstance.Start__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Tuesday_Start_Time__c,1);
           diaryInstance.End__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Tuesday_End_Time__c,1);
           diaryInstance.Hours__c = Double.valueOf(maxHourMap.get('Tue'));
           entryList.add(diaryInstance);
    }
    
    if(workCycle.Shift_Pattern__r.Wednesday_Start_Time__c != null 
                                             && workCycle.Shift_Pattern__r.Wednesday_End_Time__c != null){
        diaryInstance = new Diary_Entry__c();
        diaryInstance.RecordTypeId = availableEntryType;
        diaryInstance.Week__c = weekInstance.Id;
        diaryInstance.Start__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Wednesday_Start_Time__c,2);
        diaryInstance.End__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Wednesday_End_Time__c,2);
        diaryInstance.Hours__c = Double.valueOf(maxHourMap.get('Wed'));
        entryList.add(diaryInstance);
    }
    
    if(workCycle.Shift_Pattern__r.Thursday_Start_Time__c != null 
                                            && workCycle.Shift_Pattern__r.Thursday_End_Time__c != null){
            diaryInstance = new Diary_Entry__c();
            diaryInstance.RecordTypeId = availableEntryType;
            diaryInstance.Week__c = weekInstance.Id;
            diaryInstance.Start__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Thursday_Start_Time__c,3);
            diaryInstance.End__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Thursday_End_Time__c,3);
            diaryInstance.Hours__c = Double.valueOf(maxHourMap.get('Thu'));
            entryList.add(diaryInstance);
        }
        
    
     if(workCycle.Shift_Pattern__r.Friday_Start_Time__c != null 
                                             && workCycle.Shift_Pattern__r.Friday_End_Time__c != null){
          diaryInstance = new Diary_Entry__c();
          diaryInstance.RecordTypeId = availableEntryType;
          diaryInstance.Week__c = weekInstance.Id;
          diaryInstance.Start__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Friday_Start_Time__c,4);
          diaryInstance.End__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Friday_End_Time__c,4);
          diaryInstance.Hours__c = Double.valueOf(maxHourMap.get('Fri'));
          entryList.add(diaryInstance);
        }
        
    
     if(workCycle.Shift_Pattern__r.Saturday_Start_Time__c != null 
                                             && workCycle.Shift_Pattern__r.Saturday_End_Time__c != null){
           diaryInstance = new Diary_Entry__c();
           diaryInstance.RecordTypeId = availableEntryType;
           diaryInstance.Week__c = weekInstance.Id;
           diaryInstance.Start__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Saturday_Start_Time__c,5);
           diaryInstance.End__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Saturday_End_Time__c,5);
           diaryInstance.Hours__c = Double.valueOf(maxHourMap.get('Sat'));
           entryList.add(diaryInstance);
        }
    
       if(workCycle.Shift_Pattern__r.Sunday_Start_Time__c != null 
                                                && workCycle.Shift_Pattern__r.Sunday_End_Time__c != null){
           diaryInstance = new Diary_Entry__c();
           diaryInstance.RecordTypeId = availableEntryType;
           diaryInstance.Week__c = weekInstance.Id;
           diaryInstance.Start__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Sunday_Start_Time__c,6);
           diaryInstance.End__c = getDiaryStartEndTime(weekInstance,workCycle.Shift_Pattern__r.Sunday_End_Time__c,6);
           diaryInstance.Hours__c = Double.valueOf(maxHourMap.get('Sun'));
           entryList.add(diaryInstance);
       }
       
    
       if(entryList.size()>0){
             populateMergeCode(entryList);
             groupMergedDiaryEntries(entryList);    
             }
    system.debug('---from entryList--'+nonPoolDiaryEntries);
  }
 
 
 // Method  to generate seperate entry records is ends here.
 
 /*
 
  This method is used for returning datetime instance for start and endtime of diary entry.
    
 */
 
 public static Datetime getDiaryStartEndTime(Week__c weekInstance,String timeOfDay,Integer offset){
    
    Time timeInstance = Time.newInstance(Integer.valueOf(timeOfDay.subString(0, timeOfDay.indexOf(':'))), 
                                            Integer.valueOf(timeOfDay.subString(timeOfDay.indexOf(':')+1, timeOfDay.length())), 
                                            0, 0);
                                            
    System.debug ('++++++++++' +timeInstance);
                                            
   return  Datetime.newInstance(weekInstance.Week_Commencing__c.toStartOfWeek().addDays(offset), timeInstance);
    
 }
 
 // This method is used for returning datetime instance for start and endtime of diary entry ends here.
 
/*
  This method is used for Populating merge code on diary entries.
  Merge code is a dummy field on diary entry object.
  It is used for grouping all the diary entries with same merge code & insert then in database.
*/
 
  public static void populateMergeCode(List<Diary_Entry__c> entryList){
    
       Integer i=0;
       Integer mergeCode = 0;
       
       for(Diary_Entry__c diaryInstance:entryList){
        
              if(i==0){
            
                    diaryInstance.Merge_Code__c = 0;
            
                 }else if(((getOffsetFromStartOfWeek(entryList[i-1].Start__c))+1)==(getOffsetFromStartOfWeek(entryList[i].Start__c))){
        
                                entryList[i].Merge_Code__c = entryList[i-1].Merge_Code__c;
        
                     }else{
        
                            mergeCode++;
                            entryList[i].Merge_Code__c = mergeCode;
                            
                          }
              i++;
              
       }
    
  } 
 
 //  Method for Populating merge code on diary entries ends here.
 
 /*
  This method is used for merging diary entries based on their merge code.
  It inserts list of diary entries at once corresponding to a week in order to avoid salesforce governor limits.
 */
  
  public static void groupMergedDiaryEntries(List<Diary_Entry__c> entryList){
    
    Integer j = 0;
    String status = '';
    List<Diary_Entry__c> groupedEntryList=new List<Diary_Entry__c>();
    
    for(Integer i=0;i<=entryList.size();i++){
        
        j=0;
        
        for(j=0;j<entryList.size();j++){
            
            if(entryList[j].Merge_Code__c.intValue()==i){
                
                groupedEntryList.add(entryList[j]);
            }

            if(entryList.size()==j+1 && groupedEntryList.size()>0){
                
                nonPoolDiaryEntries.add(groupEntries(groupedEntryList));
                groupedEntryList.clear();
            }
            
        }
        
    }
    
 }
 
 //  Method for merging diary entries based on their merge code ends here.
 
 /*
  This method is used for generating one diary entry for the list of diary entries with same merge code.
 */
 
  public static Diary_Entry__c groupEntries(List<Diary_Entry__c> groupedEntrylist){
    
    Diary_Entry__c entryInstance=new Diary_Entry__c();
    Double hoursAvailable=0.0;
    for(Integer i =0;i<groupedEntrylist.size();i++){
        
        if(groupedEntrylist[i].Hours__c != null){
            
            hoursAvailable = hoursAvailable+groupedEntrylist[i].Hours__c;
        }
        
    }
    entryInstance.Start__c = groupedEntrylist[0].Start__c;
    entryInstance.End__c =  groupedEntrylist[groupedEntrylist.size()-1].End__c;
    entryInstance.Hours__c = hoursAvailable;
    entryInstance.RecordTypeId = groupedEntrylist[0].RecordTypeId;
    entryInstance.Week__c = groupedEntrylist[0].Week__c;
    
    return entryInstance;
    
  }
  
  public static list<Diary_Entry__c> splitAvailabilty(List<Diary_Entry__c> availBars,Work_Cycle__c workCycle )
  { 
    system.debug('@@UnavHourMap'+UnavHourMap);
    
    list<Diary_Entry__c> deList = new list<Diary_Entry__c>();
    for(Diary_Entry__c availBar: availBars)
    {
         Week__c w = new Week__c(Week_Commencing__c= availBar.Start__c.date().tostartofweek());
         List<List<String>> shifts = new List<List<String>>{
                                        new List<String>{workCycle.Shift_Pattern__r.Monday_Start_Time__c, workCycle.Shift_Pattern__r.Monday_End_Time__c},
                                        new List<String>{workCycle.Shift_Pattern__r.Tuesday_Start_Time__c, workCycle.Shift_Pattern__r.Tuesday_End_Time__c},
                                        new List<String>{workCycle.Shift_Pattern__r.Wednesday_Start_Time__c, workCycle.Shift_Pattern__r.Wednesday_End_Time__c},
                                        new List<String>{workCycle.Shift_Pattern__r.Thursday_Start_Time__c, workCycle.Shift_Pattern__r.Thursday_End_Time__c},
                                        new List<String>{workCycle.Shift_Pattern__r.Friday_Start_Time__c, workCycle.Shift_Pattern__r.Friday_End_Time__c},
                                        new List<String>{workCycle.Shift_Pattern__r.Saturday_Start_Time__c, workCycle.Shift_Pattern__r.Saturday_End_Time__c},
                                        new List<String>{workCycle.Shift_Pattern__r.Sunday_Start_Time__c, workCycle.Shift_Pattern__r.Sunday_End_Time__c}};
        system.debug('availBar.Start__c.date()===='+availBar.Start__c.date());
            
            Diary_Entry__c unavDiaryInstance;
            Diary_Entry__c diaryInstance; 
            if(UnavHourMap.get('Mon')!='')
            {   
                system.debug('@@entered mon');
                datetime start = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Mon_Unav_Start_Time__c,0);
                datetime Endtime = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Mon_Unav_End_Time__c,0);
                if(start<EndTime && start < availBar.End__c && EndTime >availBar.Start__c)
                {
                    unavDiaryInstance = new Diary_Entry__c();
                    unavDiaryInstance.RecordTypeId = unavailableEntryType;
                    unavDiaryInstance.Week__c = availBar.Week__c;
                    unavDiaryInstance.Start__c = start;
                    unavDiaryInstance.End__c = Endtime;
                    unavDiaryInstance.Hours__c = Double.valueOf(UnavHourMap.get('Mon'));
                    unavDiaryInstance.Sub_Type__c = workCycle.Shift_Pattern__r.Unavailability_Reason__c;
                    
                    /*if(unavDiaryInstance.Start__c > availBar.Start__c && unavDiaryInstance.End__c == availBar.End__c)
                    {
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Tuesday_Start_Time__c,1);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        deList.add(diaryInstance);
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (Double.valueOf(UnavHourMap.get('Mon'))+diaryInstance.Hours__c);
                    }
                    else if(unavDiaryInstance.Start__c == availBar.Start__c && unavDiaryInstance.End__c < availBar.End__c)
                    {
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (unavDiaryInstance.Hours__c);
                    }
                    else*/ if(start < availBar.End__c && EndTime >availBar.Start__c && unavDiaryInstance.Sub_Type__c!='NWD - Working')
                    {
                        if(unavDiaryInstance.End__c < getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Monday_End_Time__c,0))
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        else
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Tuesday_Start_Time__c,1);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        
                        availBar.Start__c = unavDiaryInstance.End__c;
                        availBar.Hours__c = availBar.Hours__c-(diaryInstance.Hours__c+unavDiaryInstance.Hours__c);
                        
                    }
                    deList.add(unavDiaryInstance);
                }
            }           
            if(UnavHourMap.get('Tue')!='')
            {
                datetime start = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Tue_Unav_Start_Time__c,1);
                datetime Endtime = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Tue_Unav_End_Time__c,1);
                if(start<EndTime && start < availBar.End__c && EndTime >availBar.Start__c)
                {
                    unavDiaryInstance = new Diary_Entry__c();
                    unavDiaryInstance.RecordTypeId = unavailableEntryType;
                    unavDiaryInstance.Week__c = availBar.Week__c;
                    unavDiaryInstance.Start__c = start;
                    unavDiaryInstance.End__c = Endtime;
                    unavDiaryInstance.Hours__c = Double.valueOf(UnavHourMap.get('Tue'));
                    unavDiaryInstance.Sub_Type__c = workCycle.Shift_Pattern__r.Unavailability_Reason__c;
                    
                    /*if(unavDiaryInstance.Start__c > availBar.Start__c && unavDiaryInstance.End__c == availBar.End__c)
                    {
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Wednesday_Start_Time__c,2);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c =DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        deList.add(diaryInstance);
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (Double.valueOf(UnavHourMap.get('Tue'))+diaryInstance.Hours__c);
                    }
                    else if(unavDiaryInstance.Start__c == availBar.Start__c && unavDiaryInstance.End__c < availBar.End__c)
                    {
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (unavDiaryInstance.Hours__c);
                    }
                    else*/ if(start < availBar.End__c && EndTime >availBar.Start__c && unavDiaryInstance.Sub_Type__c!='NWD - Working')
                    {
                        if(unavDiaryInstance.End__c < getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Tuesday_End_Time__c,1))
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        else
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Wednesday_Start_Time__c,2);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        
                        availBar.Start__c = unavDiaryInstance.End__c;
                        availBar.Hours__c = availBar.Hours__c-(diaryInstance.Hours__c+unavDiaryInstance.Hours__c);
                        
                    }
                    deList.add(unavDiaryInstance);      
                }
            }
            if(UnavHourMap.get('Wed')!='')
            {
                datetime start = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Wed_Unav_Start_Time__c,2);
                datetime Endtime = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Wed_Unav_End_Time__c,2);
                if(start<EndTime && start < availBar.End__c && EndTime >availBar.Start__c)
                {
                    unavDiaryInstance = new Diary_Entry__c();
                    unavDiaryInstance.RecordTypeId = unavailableEntryType;
                    unavDiaryInstance.Week__c = availBar.Week__c;
                    unavDiaryInstance.Start__c = start;
                    unavDiaryInstance.End__c = Endtime;
                    unavDiaryInstance.Hours__c = Double.valueOf(UnavHourMap.get('Wed'));
                    unavDiaryInstance.Sub_Type__c = workCycle.Shift_Pattern__r.Unavailability_Reason__c;
                    
                    /*if(unavDiaryInstance.Start__c > availBar.Start__c && unavDiaryInstance.End__c == availBar.End__c)
                    {
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Thursday_Start_Time__c,3);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        deList.add(diaryInstance);
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (Double.valueOf(UnavHourMap.get('Wed'))+diaryInstance.Hours__c);
                    }
                    else if(unavDiaryInstance.Start__c == availBar.Start__c && unavDiaryInstance.End__c < availBar.End__c)
                    {
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (unavDiaryInstance.Hours__c);
                    }
                    else*/ if(start < availBar.End__c && EndTime >availBar.Start__c && unavDiaryInstance.Sub_Type__c!='NWD - Working')
                    {
                        if(unavDiaryInstance.End__c < getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Wednesday_End_Time__c,2))
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        else
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Thursday_Start_Time__c,3);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        
                        availBar.Start__c = unavDiaryInstance.End__c;
                        availBar.Hours__c = availBar.Hours__c-(diaryInstance.Hours__c+unavDiaryInstance.Hours__c);
                        
                    }
                    deList.add(unavDiaryInstance);      
                }
            }
            if(UnavHourMap.get('Thu')!='')
            {
                datetime start = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Thu_Unav_Start_Time__c,3);
                datetime Endtime = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Thu_Unav_End_Time__c,3);
                if(start<EndTime && start < availBar.End__c && EndTime >availBar.Start__c)
                {
                    unavDiaryInstance = new Diary_Entry__c();
                    unavDiaryInstance.RecordTypeId = unavailableEntryType;
                    unavDiaryInstance.Week__c = availBar.Week__c;
                    unavDiaryInstance.Start__c = start;
                    unavDiaryInstance.End__c = Endtime;
                    unavDiaryInstance.Hours__c = Double.valueOf(UnavHourMap.get('Thu'));
                    unavDiaryInstance.Sub_Type__c = workCycle.Shift_Pattern__r.Unavailability_Reason__c;
                    
                    /*if(unavDiaryInstance.Start__c > availBar.Start__c && unavDiaryInstance.End__c == availBar.End__c)
                    {
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Friday_Start_Time__c,4);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        deList.add(diaryInstance);
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (Double.valueOf(UnavHourMap.get('Thu'))+diaryInstance.Hours__c);
                    }
                    else if(unavDiaryInstance.Start__c == availBar.Start__c && unavDiaryInstance.End__c < availBar.End__c)
                    {
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (unavDiaryInstance.Hours__c);
                    }
                    else */if(start < availBar.End__c && EndTime >availBar.Start__c && unavDiaryInstance.Sub_Type__c!='NWD - Working')
                    {
                        if(unavDiaryInstance.End__c < getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Thursday_End_Time__c,3))
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        else
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Friday_Start_Time__c,4);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        
                        availBar.Start__c = unavDiaryInstance.End__c;
                        availBar.Hours__c = availBar.Hours__c-(diaryInstance.Hours__c+unavDiaryInstance.Hours__c);
                        
                    }
                    deList.add(unavDiaryInstance);
            }
            }               
            if(UnavHourMap.get('Fri')!='')
            {
                datetime start = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Fri_Unav_Start_Time__c,4);
                datetime Endtime = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Fri_Unav_End_Time__c,4);
                if(start<EndTime && start < availBar.End__c && EndTime >availBar.Start__c)
                {
                    unavDiaryInstance = new Diary_Entry__c();
                    unavDiaryInstance.RecordTypeId = unavailableEntryType;
                    unavDiaryInstance.Week__c = availBar.Week__c;
                    unavDiaryInstance.Start__c = start;
                    unavDiaryInstance.End__c = Endtime;
                    unavDiaryInstance.Hours__c = Double.valueOf(UnavHourMap.get('Fri'));
                    unavDiaryInstance.Sub_Type__c = workCycle.Shift_Pattern__r.Unavailability_Reason__c;
                    
                    /*if(unavDiaryInstance.Start__c > availBar.Start__c && unavDiaryInstance.End__c == availBar.End__c)
                    {
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Saturday_Start_Time__c,5);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        deList.add(diaryInstance);
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (Double.valueOf(UnavHourMap.get('Fri'))+diaryInstance.Hours__c);
                    }
                    else if(unavDiaryInstance.Start__c == availBar.Start__c && unavDiaryInstance.End__c < availBar.End__c)
                    {
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (unavDiaryInstance.Hours__c);
                    }
                    else*/ if(start < availBar.End__c && EndTime >availBar.Start__c && unavDiaryInstance.Sub_Type__c!='NWD - Working')
                    {
                        if(unavDiaryInstance.End__c < getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Friday_End_Time__c,4))
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        else
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Saturday_Start_Time__c,5);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        
                        availBar.Start__c = unavDiaryInstance.End__c;
                        availBar.Hours__c = availBar.Hours__c-(diaryInstance.Hours__c+unavDiaryInstance.Hours__c);
                        
                    }
                    deList.add(unavDiaryInstance);
                }           
            }   
            if(UnavHourMap.get('Sat')!='')
            {
                system.debug('@@entered sat');
                datetime start = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Sat_Unav_Start_Time__c,5);
                datetime Endtime = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Sat_Unav_End_Time__c,5);
                //datetime startAva = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Saturday_Start_Time__c,5);
                //datetime endtimeAva = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Saturday_End_Time__c,5);
                system.debug('@@start and endtime'+start+' '+endtime+' '+availBar.End__c+' '+availBar.start__c);
                if(start<EndTime && start < availBar.End__c && EndTime >availBar.Start__c)
                {
                    unavDiaryInstance = new Diary_Entry__c();
                    unavDiaryInstance.RecordTypeId = unavailableEntryType;
                    unavDiaryInstance.Week__c = availBar.Week__c;
                    unavDiaryInstance.Start__c = start;
                    unavDiaryInstance.End__c = Endtime;
                    unavDiaryInstance.Hours__c = Double.valueOf(UnavHourMap.get('Sat'));
                    unavDiaryInstance.Sub_Type__c = workCycle.Shift_Pattern__r.Unavailability_Reason__c;
                    unavDiaryInstance.End__c =EndTime;
                    system.debug('in correct if'+unavDiaryInstance.Start__c+' '+availBar.Start__c+' '+unavDiaryInstance.End__c+' '+availBar.End__c);
                    /*if(unavDiaryInstance.Start__c > availBar.Start__c && unavDiaryInstance.End__c == availBar.End__c)
                    {
                        system.debug('in correct if1');
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Sunday_Start_Time__c,6);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (Double.valueOf(UnavHourMap.get('Sat'))+diaryInstance.Hours__c);
                    }
                    else if(unavDiaryInstance.Start__c == availBar.Start__c && unavDiaryInstance.End__c < availBar.End__c)
                    {
                        system.debug('in correct if2');
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (unavDiaryInstance.Hours__c);
                    }
                    else*/ 
                    if(start < availBar.End__c && EndTime >availBar.Start__c && unavDiaryInstance.Sub_Type__c!='NWD - Working')
                    {
                        system.debug('in correct if3');
                        if(unavDiaryInstance.End__c < getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Saturday_End_Time__c,5))
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        else
                        unavDiaryInstance.End__c = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Sunday_Start_Time__c,6);
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        
                        availBar.Start__c = unavDiaryInstance.End__c;
                        availBar.Hours__c = availBar.Hours__c-(diaryInstance.Hours__c+unavDiaryInstance.Hours__c);
                        system.debug('@@avail start'+availBar.start__c+' '+availBar.Hours__c);
                    }
                    
                    deList.add(unavDiaryInstance);
                }           
            }
            if(UnavHourMap.get('Sun')!='')
            {   
                system.debug('@@entered sun');
                datetime start = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Sun_Unav_Start_Time__c,6);
                datetime Endtime = getDiaryStartEndTime(w,workCycle.Shift_Pattern__r.Sun_Unav_End_Time__c,6);
                system.debug('@@start and endtime of sun'+start+' '+endtime+' '+availBar.start__c+' '+availBar.end__c);
                if(start<EndTime && start < availBar.End__c && EndTime >availBar.Start__c)
                {
                    unavDiaryInstance = new Diary_Entry__c();
                    unavDiaryInstance.RecordTypeId = unavailableEntryType;
                    unavDiaryInstance.Week__c = availBar.Week__c;
                    unavDiaryInstance.Start__c = start;
                    unavDiaryInstance.Hours__c = Double.valueOf(UnavHourMap.get('Sun'));
                    unavDiaryInstance.End__c = Endtime;
                    unavDiaryInstance.Sub_Type__c = workCycle.Shift_Pattern__r.Unavailability_Reason__c;
                    
                    /*if(unavDiaryInstance.Start__c > availBar.Start__c && unavDiaryInstance.End__c == availBar.End__c)
                    {
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (Double.valueOf(UnavHourMap.get('Sun'))+diaryInstance.Hours__c);
                    }
                    else if(unavDiaryInstance.Start__c == availBar.Start__c && unavDiaryInstance.End__c < availBar.End__c)
                    {
                        unavDiaryInstance.End__c = unavDiaryInstance.End__c;
                        availBar.Start__c=unavDiaryInstance.End__c; 
                        availBar.Hours__c = availBar.Hours__c - (unavDiaryInstance.Hours__c);
                    }
                    else*/ if(start < availBar.End__c && EndTime >availBar.Start__c && unavDiaryInstance.Sub_Type__c!='NWD - Working')
                    {
                        diaryInstance = new Diary_Entry__c();
                        diaryInstance.RecordTypeId = availableEntryType;
                        diaryInstance.Week__c = availBar.Week__c;
                        diaryInstance.Start__c = availBar.Start__c;
                        diaryInstance.End__c = unavDiaryInstance.Start__c;
                        diaryInstance.Hours__c = DateTimeHelper.calculateHours(availBar.Start__c,unavDiaryInstance.Start__c,shifts);
                        system.debug('@@sunday'+diaryInstance.Hours__c);
                        if(diaryInstance.Hours__c!=0)
                        deList.add(diaryInstance);
                        
                        availBar.Start__c = unavDiaryInstance.End__c;
                        availBar.Hours__c = availBar.Hours__c-(diaryInstance.Hours__c+unavDiaryInstance.Hours__c);
                         system.debug('@@avail start'+availBar.start__c+' '+availBar.Hours__c);
                    }
                    
                    deList.add(unavDiaryInstance);
                }           
            }
            
            
        system.debug('availBar.Start__c3'+availBar.Start__c+' availBar.End__c3'+ availBar.End__c);
        if(availBar.Start__c != availBar.End__c ||availBar.Hours__c != 0)
        deList.add(availBar);
        system.debug('###################'+deList);
    }
    
    return deList;
  }
 
 // Method for generating one diary entry for the list of diary entries with same merge code ends here.
 
 /*
  This method is used for returning difference between current date & start of week for that date.
 */
 
 public static Integer getOffsetFromStartOfWeek(Datetime dt){
    
    return ((dt.date().toStartOfWeek()).toStartOfWeek()).daysBetween(dt.date());
    
  }
  // This method ends here.
  
  // Change request for pool employees starts here
  
  public static void generatePoolDiary(Work_Cycle__c workCycle,Week__c weekInstance){
    
    Diary_Entry__c diaryInstance = new Diary_Entry__c();
    Date startOfWeek = weekInstance.Week_Commencing__c;
    Date endOfWeek = weekInstance.Week_Commencing__c.addDays(6);
    diaryInstance.RecordTypeId = availableEntryType;
    diaryInstance.Week__c = weekInstance.Id;
    diaryInstance.Start__c = datetime.newInstance((startOfWeek.year()),(startOfWeek.month()),
                                                                            (startOfWeek.day()), 8, 0, 0);
    diaryInstance.End__c = datetime.newInstance((endOfWeek.year()),(endOfWeek.month()),
                                                                              (endOfWeek.day()), 18, 0, 0);
    diaryInstance.Hours__c = weekInstance.Total_Hours__c;
    poolDiaryEntries.add(diaryInstance);
    
  }

  // Change request for pool employees ends here
  
    public static Map<String,String> calculateUnavailaHours(Work_Cycle__c workCycle){
    
              UnavHourMap.clear();
                                 
             // Check if start & end times are not empty. 
             // Then, calculate max hours difference & put it in map.
             // If start & end times are empty put empty string in map.
               
          if(!workCycle.Employee__r.Pool_Diary__c 
             && ((((String)workCycle.Shift_Pattern__r.Mon_Unav_Start_Time__c) != null)
             && (((String)workCycle.Shift_Pattern__r.Mon_Unav_End_Time__c) != null))){
                               
                    UnavHourMap.put('Mon',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                  (workCycle.Shift_Pattern__r.Mon_Unav_Start_Time__c,
                                   workCycle.Shift_Pattern__r.Mon_Unav_End_Time__c)));
                                                          
                                     }else{
                                    
                                           UnavHourMap.put('Mon', '');
                                           
                                    
                                         }

          if(!workCycle.Employee__r.Pool_Diary__c
             &&((((String)workCycle.Shift_Pattern__r.Tue_Unav_Start_Time__c) != null)
             && (((String)workCycle.Shift_Pattern__r.Tue_Unav_End_Time__c) != null))){
                                 
                   UnavHourMap.put('Tue',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                 (workCycle.Shift_Pattern__r.Tue_Unav_Start_Time__c,
                                  workCycle.Shift_Pattern__r.Tue_Unav_End_Time__c)));
                                                          
                                      }else{
                                    
                                              UnavHourMap.put('Tue', '');
                                             
                                    
                                             }
                                      
        if(!workCycle.Employee__r.Pool_Diary__c
           &&((((String)workCycle.Shift_Pattern__r.Wed_Unav_Start_Time__c) != null)
           && (((String)workCycle.Shift_Pattern__r.Wed_Unav_End_Time__c) != null))){
                 
                      UnavHourMap.put('Wed',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                       (workCycle.Shift_Pattern__r.Wed_Unav_Start_Time__c,
                                         workCycle.Shift_Pattern__r.Wed_Unav_End_Time__c)));
                                                          
                                 }else{
                                          UnavHourMap.put('Wed', '');
                                          
                                     }

      if(!workCycle.Employee__r.Pool_Diary__c
         &&((((String)workCycle.Shift_Pattern__r.Thu_Unav_Start_Time__c) != null)
         && (((String)workCycle.Shift_Pattern__r.Thu_Unav_End_Time__c) != null))){
                   
                       unavHourMap.put('Thu',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Thu_Unav_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Thu_Unav_End_Time__c)));
                                                          
                                 }else{
                                    
                                           UnavHourMap.put('Thu', '');
                                           
                                    
                                       }
                                
    if(!workCycle.Employee__r.Pool_Diary__c
       && ((((String)workCycle.Shift_Pattern__r.Fri_Unav_Start_Time__c) != null)
       && (((String)workCycle.Shift_Pattern__r.Fri_Unav_End_Time__c) != null))){
                  
                       UnavHourMap.put('Fri',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Fri_Unav_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Fri_Unav_End_Time__c)));
                                                          
                                 }else{
                                    
                                          UnavHourMap.put('Fri', '');
                                          
                                    
                                       }

  if(!workCycle.Employee__r.Pool_Diary__c 
     &&((((String)workCycle.Shift_Pattern__r.Sat_Unav_Start_Time__c) != null)
     && (((String)workCycle.Shift_Pattern__r.Sat_Unav_End_Time__c) != null))){
                   
                      UnavHourMap.put('Sat',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Sat_Unav_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Sat_Unav_End_Time__c)));
                                                          
                                 }else{
                                    
                                           UnavHourMap.put('Sat', '');
                                           
                                       }
  if(!workCycle.Employee__r.Pool_Diary__c
     &&((((String)workCycle.Shift_Pattern__r.Sun_Unav_Start_Time__c) != null)
     && (((String)workCycle.Shift_Pattern__r.Sun_Unav_End_Time__c) != null))){
                   
                       UnavHourMap.put('Sun',String.valueOf(DateTimeHelper.hoursBetweenStartEndHours
                                                (workCycle.Shift_Pattern__r.Sun_Unav_Start_Time__c,
                                                          workCycle.Shift_Pattern__r.Sun_Unav_End_Time__c)));
                                                          
                                   }else{
                                    
                                            UnavHourMap.put('Sun', '');
                                            
                                    
                                       }

             if((UnavHourMap.get('Mon').indexOf('-') ==  0) || (UnavHourMap.get('Tue').indexOf('-') ==  0) ||
                (UnavHourMap.get('Wed').indexOf('-') ==  0) || (UnavHourMap.get('Thu').indexOf('-') ==  0) ||
                (UnavHourMap.get('Fri').indexOf('-') ==  0) || (UnavHourMap.get('Sat').indexOf('-') ==  0) ||
                (UnavHourMap.get('Sun').indexOf('-') ==  0)) {
                    system.debug('UnavHourMap----->'+UnavHourMap);
                    UnavHourMap.clear();
                    //UnavHourMapNWD.Clear();
                    UnavHourMap.put('validationErrorNegative', 'Shift pattern is invalid. Please modify the corresponding shift pattern.');
             }
             system.debug('UnavHourMap----->'+UnavHourMap);
             return UnavHourMap;
             
    }
 
 // Method for calculating maximum hours for week objects finishes here.
  
 
}