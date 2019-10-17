/* Class Name:RegenrateAvailabilty
   Author : Ashok (CTS)
   Description: This is calss is used to Implement CR-003. I.e. Regenrate Availabilty 
   Created Date: 07/19/10
*/
global class RegenrateAvailabilty{
    // on clicking "check Impact button" it will store dairy entries of type unavailbilty and job bookings in Entries To Plan. 
    public static Savepoint  sp;
    public static set<Id> employeeId = new set<Id> ();
    webservice static String StoreDairyEntires(ID[] workCycleID){
            Work_Cycle__c workCycle=RetrieveWorkCycle(workCycleID[0]);
            RegenrateAvailabilty obj = new RegenrateAvailabilty(); 
            // code fix starts - for Unable to create group work cycles - PRB00013737
            employeeId = obj.retrieveEmployee(workCycle.Group__c,workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c);
            // code fix ends - for Unable to create group work cycles - PRB00013737
            boolean CheckDate; //= obj.DateValidation(workCycle);
            if (CheckDate == true)
            {
              return ('Start date of the work cycle should be in future and it should be Monday.');
            }

            if(obj.invaild(workCycle))
            {
                return('Group and Employee fields can not be populated at the same time.');
            }
            system.debug('workCycle.Group__c -->'+workCycle.Group__c );
                       
                Integer numberOfWeeks = (workCycle.Number_of_Weeks__c).intValue();
                    
                String status = checkExistingWeeks(workCycle,numberOfWeeks);
            
                          if(status.length()>5)
                          {
                                return status;
                          } 
              return status;
               
     
     }
     public set<Id> retrieveEmployee (id GroupId, boolean pool)
     {
        set<Id> employeeids = new set<Id>();
        for (Employee_Group__c e : [select Employee__c,Employee__r.Pool_Diary__c  from Employee_Group__c where Group__c = :GroupId])
        {
            if(e.Employee__r.Pool_Diary__c == pool)
            employeeids.add(e.Employee__c);
        }
        return employeeids;
     }
     private boolean invaild(Work_Cycle__c wc)
     {  
        if(wc.Group__c != null && wc.Employee__c != null)
        {
            return true;
        }
        return false;
     }
     
     private boolean DateValidation(Work_Cycle__c workCycle)
     {
        
        if (workCycle.Start_Date__c < system.today().toStartOfWeek().addDays(7))
        {
            return true;
            
        }else if(workCycle.Start_Date__c != workCycle.Start_Date__c.toStartOfWeek()){
            
            return true;
            
        }
        
        return false;
            
     }  
        
     // to check if there are any previous week entries present      
    public static String checkExistingWeeks(Work_Cycle__c workCycle, Integer numOfWeeks){
    
            String status='';
            List<Week__c> Weeks  = RetrieveWeeks(workCycle);
            list<Id> WcId= new List<Id>();
            system.debug('workCycle.Id'+workCycle.Id);
            WcId.add(workCycle.Id); 
            if (weeks.size()==0)
            {
                status = 'No previous weeks present for this Period.Go ahead with applying new shift pattern'; 
            } else
              {
                integer flag = insertentries(weeks);
                boolean ReportCheck = CheckEntries(workCycle);
                if (flag == 1 && ReportCheck == true  )
                {
                    status = 'No entries of type unavailability or job booking are found for this employee to store in the report. Report is already loaded so please check the jobs or unavailabilityâ€™s affected. ';
                }
                else if(flag == 1)
                {
                    status='No entries of type unavailability or job booking are found for this employee to store in the report.';
                }
                else if(flag == 2)
                { 
                    status= 'All the affected job bookings and unavailability\'s have been stored in the report.';
                    if(workCycle.Impact_Checked__c == false){
                    workCycle.Impact_Checked__c = true;
             try{
                 update workCycle;
                 }catch(DMLException e){
                         system.debug('----- Exception-----'+e);
                     }
                }
                
        }else if(flag == 3){
                status = 'Please clear the jobs & unavailabilityâ€™s affected report first and then click on check impact to refresh the report again.';
        }   
    }
    return (status);
    }  
  
    webservice static string deleteExistingWeeks(Id[]workCycleID){
              string status ='';
              List<week__c> Weeks = null;
              
              Work_Cycle__c workCycle=RetrieveWorkCycle(workCycleID[0]);
              RegenrateAvailabilty obj = new RegenrateAvailabilty(); 
              boolean CheckDate ;//= obj.DateValidation(workCycle);
              if (CheckDate == true)
              {
                return ('Start date of the work cycle should be in future and it should be Monday.');
              }
             
              if(workCycle.Group__c != null)
            {
                GroupAvailabilityGeneration groupObj = new GroupAvailabilityGeneration();
                employeeId = obj.retrieveEmployee(workCycle.Group__c,workCycle.Shift_Pattern__r.Pool_Shift_Pattern__c);
                
                list <Week__c> weekLst = new List<Week__c>();
                //
                set<string> nameStr = new set<string>();
                nameStr = GroupAvailabilityGeneration.checkWeeks(workCycle,employeeId,false);
                
                //PRB00032576 - added workCycle.Apply_Directly__c == false
                
                if(nameStr.size()>0 && workCycle.Apply_Directly__c == false)
                {
                    String EmpName= '';
                    
                    for(string s: nameStr)
                    {
                        EmpName = EmpName + S + '\n';
                            
                    }
                    return('Shift pattern can not be applied to the Group as following Employees have weeks in future.\n'+EmpName+' \n You can not apply new shift pattern directly without dealing with them.To do so please check the â€˜Apply Directlyâ€™ checkbox on this work cycle.');
                    
                }else if(employeeId.size()>40 && system.label.GroupBatchSwitch == 'true')
                {
                    status = groupObj.createWorkcycle(workCycle,employeeId);
                    return('Very huge group this needs to be processed by Batch. You will be intimated by mail once the Job is complete');
                }else
                {
                    weekLst = RetrieveWeeks(workCycle);
                    delete weekLst;
                    GroupAvailabilityGeneration.Start(workCycle.Id,employeeId);
                    return('Please Wait for Email for the results. As its very Bulk Process.');
                }
                
            } else
             
                        //if(workCycle.Impact_Checked__c == true)
                        {
                             Weeks  = RetrieveWeeks(workCycle);
                             system.debug('----- Weeks-----'+Weeks);
                             system.debug('----- Weeks.size-----'+Weeks.size());
                             List<Diary_Entry__c> diaries = RetrieveEntries(Weeks); 
                             system.debug('----- diaries-----'+diaries);
                             system.debug('----- diaries.size-----'+diaries.size());
                             if(diaries.size() > 0 && workCycle.Apply_Directly__c == false)
                             {
                                return('There are one or more job bookings or unavailability\'s in this period.You can not apply new shift pattern directly without dealing with them.To do so please check the â€˜Apply Directlyâ€™ checkbox on this work cycle.'); 


                             }else if(diaries.size() == 0 || (workCycle.Apply_Directly__c == true && workCycle.Impact_Checked__c == true))
                             { // code fix starts - on 20th July,2011 for Installers being active -PRB00002275
                              if (diaries.size() > 0)
                              {
                              system.debug('----- diaries.size-----'+diaries.size());
                              delete diaries;
                              
                              } // code fix starts - on 20th July,2011 for Installers being active -PRB00002275
                              if(Weeks.size()>0)
                              {
                              system.debug('----- Weeks.size-----'+Weeks.size());
                              delete Weeks;
                              }
                             }else
                             {
                                return('Please click On Check Impact Button first');
                             }
                             
                             workCycle.Impact_Checked__c = false;
                             update workCycle;
                        }
                
      status = GenerateAvailability.createAvailability(workCycleID); 
      return status;   
                                 
   }
public static Work_Cycle__c RetrieveWorkCycle(Id workCycleID)
{
     Work_Cycle__c workCycle=[Select Id,Group__c,Employee__c,CreatedById,Shift_Pattern__r.Pool_Shift_Pattern__c,CreatedBy.Email,Start_Date__c,Number_of_Weeks__c,Impact_Checked__c,Apply_Directly__c,Shift_Pattern__c,Batch_Status__c,Work_Cycle__c,Name from Work_Cycle__c where Id=:workCycleID];
     return workCycle;
} 
  
public static List<Week__c> RetrieveWeeks(Work_Cycle__c workCycle) 
{
     Integer numberOfWeeks = (workCycle.Number_of_Weeks__c).intValue();
     Date workCycleEndDate = workCycle.Start_Date__c.addDays((numberOfWeeks*7)-1);
     List<Week__c> Weeks = new List<Week__c> ();
     if(workCycle.Group__c != null)
         {
             Weeks  = [Select Name, Week_Commencing__c,Employee__r.Name from Week__c where 
                                               (Week_Commencing__c >= :(workCycle.Start_Date__c) 
                                               and Week_Commencing__c < :workCycleEndDate)
                                               and Employee__c in :employeeId]; 
         }
         else{
            Weeks  = [Select Name, Week_Commencing__c from Week__c where 
                                               (Week_Commencing__c >= :(workCycle.Start_Date__c) 
                                               and Week_Commencing__c < :workCycleEndDate)
                                               and Employee__c = :workCycle.Employee__c];
         } 
    return Weeks;                                      
}  
public static List<Diary_Entry__c> RetrieveEntries(List<Week__c> weeks)
{
    List<Diary_Entry__c> diaries = [Select d.Id,d.Type__c, d.Sub_Type__c, d.Start__c, d.Record_Type__c,Week__c,
                                     d.Job__c, d.End__c,d.Unavailability_Reason__c,Employee_ID_18__c,Employee_Name__c From Diary_Entry__c
                                      d where d.Week__c in : weeks and(d.Type__c= 'Unavailability' or d.Type__c= 'Job Booking')];
   
    return diaries;                                 
}
public static boolean  CheckEntries(Work_Cycle__c workcycle)
{   
    Integer numberOfWeeks = (workcycle.Number_of_Weeks__c).intValue();
    Date workCycleEndDate = workcycle.Start_Date__c.addDays((numberOfWeeks*7)-1);
    integer count = [Select count() from Entries_To_Plan__c where 
                        Start__c>= :(workcycle.Start_Date__c) 
                        and End__c < :workCycleEndDate and Employee__c= :workcycle.Employee__c];
    if(count > 0)
    {
        return true;
    }else
    {
        return false;
    }                   
}
   
   // this method wll insert diary entries of type Unavailability and job bookings into new object "Entires to Plan".
      
public static integer insertentries(List<Week__c> weeks){
    
   
   map<Id,Unavailability__c> diaryUnavailabilityMap = new map<Id,Unavailability__c>();
                             
   List<Unavailability__c> Unavalist = new   List<Unavailability__c>();
   List<Diary_Entry__c> diaries = RetrieveEntries(weeks);
   List<Diary_Entry__c> unavDiary = new List<Diary_Entry__c>();
   
   set<Id>jobIds = new set<Id>();
   for(Diary_Entry__c e : diaries){
    
    if(e.Type__c == 'Unavailability')
    unavDiary.add(e);
            
    }
   Unavalist = retriveunavailability(unavDiary);
   system.debug('Unavalist.size()----->'+Unavalist.size()); 
   if(unavDiary.size()>0)
   {
       for (integer i=0; i < unavDiary.size(); i++)
          {
            for(integer j=0; j < Unavalist.size(); j++ )
            {
                system.debug('unavDiary[i].Start__c'+unavDiary[i].Start__c+'Unavalist[j].Start_Date_Time__c'+Unavalist[j].Start_Date_Time__c);
                system.debug('unavDiary[i].End__c'+unavDiary[i].End__c+'Unavalist[j].End_Date_Time__c'+Unavalist[j].End_Date_Time__c);
                
                if(unavDiary[i].Start__c == Unavalist[j].Start_Date_Time__c && unavDiary[i].End__c == Unavalist[j].End_Date_Time__c /*&& unavDiary[i].Sub_Type__c == Unavalist[i].Unavailability_Reason__c*/)               {
                    diaryUnavailabilityMap.put(unavDiary[i].Id,Unavalist[j]);
                    break;
                }
                    
                }
          }
   } 
 
 if(diaries.size()==0 )
 {
    return (1);
 }
    
       
integer sizeDiary =     diaries.size();                           
Datetime startdate = diaries[0].Start__c; 
Datetime Endtdate = diaries[sizeDiary -1].End__c; 
    
if(diaries.size()>0){   
            
                    
for (integer i=1 ;i<sizeDiary ;i++){

       if(startdate > diaries[i].Start__c)
               {
                 startdate= diaries[i].Start__c;
               }
       if(Endtdate < diaries[i].End__c)
               {
                  Endtdate = diaries[i].End__c;
               }                        
 }
}                                           
    
   
    // check if there are any previous entries are present for this employee if yes then show him a validation. 
    integer CountofEntries = [Select count() from Entries_To_Plan__c where Employee__c = :(diaries[0].Employee_ID_18__c)
                              and Start__c >= : startdate and End__c <=: Endtdate];                            
     if(CountofEntries != 0){
            return(3);
            
        }else{
                 sp = Database.setSavepoint();
                 List<Entries_To_Plan__c> Entries = new List<Entries_To_Plan__c> ();
                 for(integer i=0;i<diaries.size();i++){
                Entries_To_Plan__c Entry = new Entries_To_Plan__c();
                Unavailability__c unavail= diaryUnavailabilityMap.get(diaries[i].Id);
                system.debug('unavail----->'+unavail);
                if(unavail != null)
                    {
                        Entry.Opportunity__c = unavail.Opportunity__c;
                        Entry.Unavailability__c = unavail.Id;
                    }else {
                            Entry.Opportunity__c = null;
                            }
                Entry.Employee__c =  diaries[i].Employee_ID_18__c;
                Entry.Job__c =  diaries[i].Job__c;
                if(diaries[i].Job__c!=null)
                {
                    jobIds.add(diaries[i].Job__c);
                }
                Entry.Diary_ID__c =  diaries[i].Id;
                Entry.Record_Type__c =  diaries[i].Type__c;
                if(diaries[i].Sub_Type__c!=null && diaries[i].Sub_Type__c.length()>35)
                Entry.Sub_Type__c =  diaries[i].Sub_Type__c.substring(0,34);
                else
                Entry.Sub_Type__c =  diaries[i].Sub_Type__c;
                Entry.End__c =  diaries[i].End__c;
                Entry.Start__c =  diaries[i].Start__c;
               
                     Entries.add(Entry);         
                 }
                system.debug('Entries----->'+Entries); 
                if(Entries.size()>0){
                    try{                
                   Database.insert(Entries);
                   if(jobIds.size()>0)
                   {
                    list<Job__c> updatejobs = [select Id, Needs_Re_Planing__c from Job__c where id in : jobIds];
                    for(Job__c j:updatejobs)
                    {
                        j.Needs_Re_Planing__c= true;
                    }
                    update updatejobs;
                   }
                
                }catch(Exception excp){
                    
                    // Revert the database to the original state
                    Database.rollback(sp);
                    
                    
                }           
                 return(2);
     
            }
            return (3);
     }
     
   }    
public static list<Unavailability__c> retriveunavailability(List<Diary_Entry__c> unavDiary){
list<Unavailability__c> unAvail= new list<Unavailability__c>();     
/*List<Diary_Entry__c> unavDiary = new List<Diary_Entry__c>();  
    for(Diary_Entry__c e : Entries){
    
    if(e.Type__c == 'Unavailability')
    unavDiary.add(e);
            
    }*/

if(unavDiary.size()>0){ 
List<Unavailability__c> UpadatingEntries = new List<Unavailability__c>();  
                         
integer sizeunavDiary =     unavDiary.size();                           
Datetime startdate = unavDiary[0].Start__c; 
Datetime Endtdate = unavDiary[sizeunavDiary -1].End__c;                     
for (integer i=1 ;i<sizeunavDiary ;i++){

       if(startdate > unavDiary[i].Start__c)
               {
                 startdate= unavDiary[i].Start__c;
               }
       if(Endtdate < unavDiary[i].End__c)
               {
                  Endtdate = unavDiary[i].End__c;
               }                        
}
system.debug('startdate'+startdate+'------Endtdate'+Endtdate+'unavDiary[0].Employee__c'+unavDiary[0].Employee_ID_18__c);
        // Retrieve the Unavailability records against the Employee
       unAvail = [select id, u.Start_Date_Time__c, u.Remove_Unavailability__c, u.Quote_number__c, 
                  u.Opportunity__c, u.End_Date_Time__c, u.Employee__c, u.Unavailability_Reason__c From Unavailability__c u
                  where  Start_Date_Time__c >= : startdate and End_Date_Time__c <=: Endtdate and
                   Employee__c = : unavDiary[0].Employee_ID_18__c];
    
}

return(unAvail);    
}

}