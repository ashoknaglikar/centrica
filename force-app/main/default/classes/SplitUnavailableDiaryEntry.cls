/*********************************************************************
  splits the unavailablities (Diary entries from unavailablity manager)
  into multiple diary entries..

**********************************************************************/

public class SplitUnavailableDiaryEntry{

   public static list<Diary_entry__c> splitDiaryEntry(datetime mydatetime,datetime myendtime,Diary_Entry__c doit){
                
      list<Diary_Entry__c> newsplitUnavailablitylist = new list<Diary_Entry__c>();
                
                string mystartday = myDateTime.format('EEEE');
                string starttime = string.valueof(mydatetime);
                string endtime = string.valueof(myendtime);
                system.debug('##endtime'+endtime);
                string starttimedate = starttime.substring(0,10);
                
                string stringdate = starttimedate.substring(8,10)+'/'+starttimedate.substring(5,7)+'/'+starttimedate.substring(0,4);
                string enddateofUnavailability= endtime.substring(0,10);
                string stringdate50 = enddateofUnavailability.substring(8,10)+'/'+enddateofUnavailability.substring(5,7)+'/'+enddateofUnavailability.substring(0,4);
                system.debug('##'+ starttimedate);
                         
                date starttimedate1 = date.parse(stringdate);
                date enddatetimeofunavailability1 = date.parse(stringdate50);
                date nextdate = starttimedate1.adddays(1);
                date nextnextdate = nextdate.adddays(1);
                date threedaysdate = nextnextdate.adddays(1);
                
                string endtimedate = string.valueof(nextdate);
                string endtimedate2 = string.valueof(nextnextdate);
                string endtimedate4 = string.valueof(threedaysdate);
                string endtimedate6 = string.valueof(threedaysdate.adddays(1));
                string endtimedate8 = string.valueof(threedaysdate.adddays(2));
                string endtimedate10 = string.valueof(threedaysdate.adddays(3));      
                
                integer p=starttimedate1.daysBetween(enddatetimeofunavailability1);
                week__c week=[Select Shift_Pattern__c,
                                    Shift_Pattern__r.Monday_Start_Time__c,Shift_Pattern__r.Monday_End_Time__c,
                                    Shift_Pattern__r.Tuesday_Start_Time__c,Shift_Pattern__r.Tuesday_End_Time__c,
                                    Shift_Pattern__r.Wednesday_Start_Time__c,Shift_Pattern__r.Wednesday_End_Time__c,
                                    Shift_Pattern__r.Thursday_Start_Time__c,Shift_Pattern__r.Thursday_End_Time__c,
                                    Shift_Pattern__r.Friday_Start_Time__c,Shift_Pattern__r.Friday_End_Time__c,
                                    Shift_Pattern__r.Saturday_Start_Time__c,Shift_Pattern__r.Saturday_End_Time__c,
                                    Shift_Pattern__r.Sunday_Start_Time__c,Shift_Pattern__r.Sunday_End_Time__c,
                                    Shift_Pattern__r.Unavailability_Reason__c from Week__c where Id=:doit.week__c];
           
         
           if(p==0){
               
                   diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = doit.End__c, RecordTypeId = doit.Recordtypeid, Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                Amendment_Reason__c = doit.Amendment_Reason__c);
                   newsplitUnavailablitylist.add(newentry);
               
           }
           else if(p==1){
                  if(mystartday == 'Monday'){
                      diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       if(myendtime > datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00')){
                           diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                            Amendment_Reason__c = doit.Amendment_Reason__c);
                           newsplitUnavailablitylist.add(newentry1);
                        }
                       
                    }
                  if(mystartday == 'Tuesday'){
                      diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       if(myendtime > datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00')){
                           diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                            Amendment_Reason__c = doit.Amendment_Reason__c);
                           newsplitUnavailablitylist.add(newentry1);
                        }
                       
                    }
                    if(mystartday == 'Wednesday'){
                      diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       if(myendtime > datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00')){
                           diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                            Amendment_Reason__c = doit.Amendment_Reason__c);
                           newsplitUnavailablitylist.add(newentry1);
                        }
                       
                    }
                    if(mystartday == 'Thursday'){
                      diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       if(myendtime > datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00')){
                           diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                            Amendment_Reason__c = doit.Amendment_Reason__c);
                           newsplitUnavailablitylist.add(newentry1);
                        }
                       
                    }
                    if(mystartday == 'Friday'){
                      diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       if(myendtime > datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00')){
                           diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                            Amendment_Reason__c = doit.Amendment_Reason__c);
                           newsplitUnavailablitylist.add(newentry1);
                        }
                       
                    }
                    if(mystartday == 'saturday'){
                      diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       if(myendtime > datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00')){
                           diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                            Amendment_Reason__c = doit.Amendment_Reason__c);
                           newsplitUnavailablitylist.add(newentry1);
                        }
                       
                    }
                    
                    
                  
                }
                else if(p==2){
                   if(mystartday == 'Monday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       if(myendtime > datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00')){
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                       }
                   }
                   
                   if(mystartday == 'Tuesday'){
                       
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00') , RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00') , End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       if(myendtime > datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00')){
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                       }
                   }
                   
                   if(mystartday == 'Wednesday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       if(myendtime > datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00')){
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                       }
                   }
                   
                   if(mystartday == 'Thursday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       if(myendtime > datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00')){
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                       }
                   }
                   
                   if(mystartday == 'Friday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       if(myendtime > datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00')){
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                       }
                    }
                }
                
                else if(p==3){
                   if(mystartday == 'Monday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       if(myendtime > datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00')){
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       }
                  } 
                  if(mystartday == 'Tuesday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       if(myendtime > datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00')){
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       }
                  }
                 if(mystartday == 'Wednesday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       if(myendtime > datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00')){
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       }
                  }
                  if(mystartday == 'Thursday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       if(myendtime > datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00')){
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       }
                  }
                }
                
                else if(p==4){
                
                   if(mystartday == 'Monday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       if(myendtime > datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00')){
                       diary_entry__c newentry4 = new diary_entry__c( start__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry4);
                       }
                  } 
                  if(mystartday == 'Tuesday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                       
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       if(myendtime > datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00')){
                       diary_entry__c newentry4 = new diary_entry__c( start__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry4);
                       }
                       
                  }
                  if(mystartday == 'Wednesday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       
                       if(myendtime > datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00')){
                       diary_entry__c newentry4 = new diary_entry__c( start__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry4);
                       }
                       
                  }
                     
                }
                else if(P==5){
                
                if(mystartday == 'Monday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       
                       diary_entry__c newentry4 = new diary_entry__c( start__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry4);
                       if(myendtime > datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00')){
                       diary_entry__c newentry5 = new diary_entry__c( start__c = datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry5);
                       }
                       
                  } 
                  if(mystartday == 'Tuesday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                       
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       
                       diary_entry__c newentry4 = new diary_entry__c( start__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry4);
                       if(myendtime > datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00')){
                       diary_entry__c newentry5 = new diary_entry__c( start__c = datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry5);
                       }
                       
                  }
                
                }
                else if(P==6){
                  
                    if(mystartday == 'Monday'){
                       diary_entry__c newentry = new diary_entry__c( start__c = doit.start__c, End__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry);
                       
                       diary_entry__c newentry1 = new diary_entry__c( start__c = datetime.valueof(endtimedate+' '+week.Shift_Pattern__r.Tuesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry1);
                       
                       diary_entry__c newentry2 = new diary_entry__c( start__c = datetime.valueof(endtimedate2+' '+week.Shift_Pattern__r.Wednesday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry2);
                        
                       diary_entry__c newentry3 = new diary_entry__c( start__c = datetime.valueof(endtimedate4+' '+week.Shift_Pattern__r.Thursday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry3);
                       
                       diary_entry__c newentry4 = new diary_entry__c( start__c = datetime.valueof(endtimedate6+' '+week.Shift_Pattern__r.Friday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry4);
                       
                       diary_entry__c newentry5 = new diary_entry__c( start__c = datetime.valueof(endtimedate8+' '+week.Shift_Pattern__r.Saturday_Start_Time__c+':00'), End__c = datetime.valueof(endtimedate10+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry5);
                       if(myendtime > datetime.valueof(endtimedate10+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00')){
                       diary_entry__c newentry6 = new diary_entry__c( start__c = datetime.valueof(endtimedate10+' '+week.Shift_Pattern__r.Sunday_Start_Time__c+':00'), End__c = doit.End__c, RecordTypeId = doit.Recordtypeid,Week__c = doit.Week__c, Sub_Type__c = doit.Sub_Type__c, Unavailability_Notes__c = doit.Unavailability_Notes__c, CHI_Lead_Number__c = doit.CHI_Lead_Number__c , Primary_Type__c = doit.Primary_Type__c, Create_History__c = doit.create_History__c,
                                                                        Amendment_Reason__c = doit.Amendment_Reason__c);
                       newsplitUnavailablitylist.add(newentry6);
                      }                    
                  }  
                
                }
            return newsplitUnavailablitylist;    
    }

}