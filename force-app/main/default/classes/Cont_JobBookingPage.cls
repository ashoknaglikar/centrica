public class Cont_JobBookingPage {
public  List<Entries_To_Plan__c> JobEntries = new List<Entries_To_Plan__c> ();
public  List<Entries_To_Plan__c> UniqueJobEntries = new List<Entries_To_Plan__c> ();
Work_Cycle__c wc;
//PRB00013737 - Unable to Create Group Work Cycles -- added this (employeeids) object
public set<Id> employeeids = new set<Id>();
public  List<Entries_To_Plan__c> UpdateEntries = new List<Entries_To_Plan__c> ();
public set<string> Jobids = new set<string> ();
public Boolean IsData {get; set;}
public Id jobId{get;set;}
public Map<Id, Entries_To_Plan__c> JobIdETP = new Map<Id, Entries_To_Plan__c>();


public Cont_JobBookingPage(){
    // code fix starts - for Unable to create group work cycles - PRB00013737
            wc =[Select Employee__c, Group__c, Shift_Pattern__r.Pool_Shift_Pattern__c, Start_Date__c, Number_of_Weeks__c   from Work_Cycle__c where id=:ApexPages.currentPage().getParameters().get('s')];

    if(wc.Group__c != null)
    {
        for (Employee_Group__c e : [select Employee__c,Employee__r.Pool_Diary__c  from Employee_Group__c where Group__c = :wc.Group__c])
        {
                      employeeids.add(e.Employee__c);
        }
    }
    else
    {
        employeeids.add(wc.Employee__c);
    }
   
  // code fix ends - for Unable to create group work cycles - PRB00013737 
Integer numOfWeeks = (wc.Number_of_Weeks__c).intValue();

            Datetime workCycleEndDate = wc.Start_Date__c.addDays((numOfWeeks * 7));
           // code fix starts - for Unable to create group work cycles - PRB00013737 
            JobEntries = [Select e.Name,e.Start__c, e.End__c, e.Employee_Name__c,e.Job__c, e.Job_Number__c,
                         e.Sub_Type__c,e.Job_Status__c,e.IsSuspended__c,e.IsUnsuspended__c,e.Installation_Date__c
                         From Entries_To_Plan__c e  where e.Record_Type__c ='Job Booking' and e.Employee__c IN :employeeids
                         and Start__c >= :wc.Start_Date__c and  End__c < :workCycleEndDate order by Installation_Date__c];                 
// code fix ends - for Unable to create group work cycles - PRB00013737 
            if(JobEntries.size() == 0)
                {
                    IsData = false;
                }
                else
                {
                    IsData = true;
                }                               
    
}

public List<Entries_To_Plan__c> getJobEntries() {
    

    for(Entries_To_Plan__c e : JobEntries )
    {
        Jobids.add(e.Job__c);
        
        if(!JobIdETP.containsKey(e.Job__c))
        {
            JobIdETP.put(e.Job__c, e);
        }       
    }
    
    system.debug('JobEntries --->'+JobEntries);
    system.debug('JobIdETP --->'+JobIdETP.size());
    //JobEntries.clear();
    UniqueJobEntries = JobIdETP.values();   
    system.debug('UniqueJobEntries --->'+UniqueJobEntries);
    //return (JobIdETP.values());
    return qSort(UniqueJobEntries);
    //return JobEntries;
}


public Pagereference deleterecords(){
 try{
    delete JobEntries;
    } 
    catch (Exception e){
        
     }
    return null;
 }
 
 
/*public Pagereference suspendrecords(){
         List<Job__c> jobList = [Select j.Suspend_Job__c, sub_Status__c,Suspension_Reason__c,Suspension_Reason_List__c,Cancel_Merchant_Orders__c,j.Status__c, 
                                (Select Name,id,Status__c,sub_status__c,Type__c From Job_Elements1__r where Status__c  != 'Suspended'),
                                (Select d.Id,d.Week__r.Employee__c, d.Start__c, d.Record_Type__c, d.RecordTypeId, d.Job__c, d.End__c, Hours__c From Diary_Entries__r d )
                                 From Job__c j where j.id in :Jobids and Status__c not in ('Suspended','Cancelled','Installed')];     
         system.debug('Joblist>>>>'+jobList );
         if(jobList.size() != 0){
         SuspendMulitpleJobs obj = new SuspendMulitpleJobs();
         String result=obj.SuspendAllJobs(jobList);
         system.debug('Result>>>>>');
         }
         
         return null;   
 }*/  
public Pagereference Suspended()
    {
        system.debug('Job Id--->'+jobId);
        //Job__c job = [Select Suspend_Job__c,previous_resources__c, Cancel_Merchant_Orders__c,Status__c from Job__c where Id=:jobId];
        //UpdateEntries = [select IsSuspended__c from Entries_To_Plan__c where Job__c =:jobId ];
        Job__c job = fetchJob(jobId);
        list<Job_Booking_History__c> BookingHistory = new list<Job_Booking_History__c>();  
        for(Job_Booking_History__c jb : job.Job_Booking_History__r )
        {
            BookingHistory.add(jb);
        }
        if(BookingHistory.size()>0)
        {
            delete BookingHistory;
        }
        UpdateEntries = fetchJobEntries(jobId);
        
        if(UpdateEntries.size()>0){
            for(Entries_To_Plan__c e : UpdateEntries)
            {
                e.IsSuspended__c=true;
            }
        }
        job.Suspend_Job__c=true;
        // Suspend material orders if planner chooses to do so.
        job.Cancel_Merchant_Orders__c = 'No';
        job.Suspension_Reason__c = 'Shift Regenrated';
        job.Suspension_Reason_List__c = 'Shift Regenrated';
        // Generate previous resource details before we delete the diary entries.
        job.previous_resources__c = JobBookingManager.generateEmployeeDetails(job.ID);
        JobBookingManager.suspendJob(job);
        // Now call the job sharing again to remove the resources from sharing table.
        System.debug(LoggingLevel.Info,'Create new sharing for job and job documents.');
        JobSharingCls.createJobSharing(new List<String>{job.Id});
        update job;
        job = [select Status__c,previous_resources__c, Cancel_Merchant_Orders__c, Suspend_Job__c, sub_status__c, 
                          suspension_Reason__c,Suspension_Reason_List__c from job__c where id = :jobId];
        job.Status__c = 'Suspended';
        job.Sub_Status__c = 'Suspended';
        job.Suspension_Reason__c = 'Shift Regenrated';
        job.Suspension_Reason_List__c = 'Shift Regenrated';
        job.Suspend_Job__c=false;
        job.Cancel_Merchant_Orders__c = '';
        System.debug(LoggingLevel.Info,'Updating the job after doing entire process of suspension.');
        update job;
             // Calling the future method which exceutes in after some delay.
        UpdateJobElements.suspendJobElementsFuture(job.ID, false);
        update UpdateEntries;
        return null;    
    }
public Pagereference UnSuspended()
{
    system.debug('Job Id--->'+jobId);
    Job__c Job = fetchJob(jobId);
    Job.Unsuspend_Job__c = true;
    list<Job_Booking_History__c> BookingHistory = new list<Job_Booking_History__c>();  
        for(Job_Booking_History__c jb : job.Job_Booking_History__r )
        {
            BookingHistory.add(jb);
        }
        if(BookingHistory.size()>0)
        {
            delete BookingHistory;
        }
        UpdateEntries = fetchJobEntries(jobId);
        
        if(UpdateEntries.size()>0){
            for(Entries_To_Plan__c e : UpdateEntries)
            {
                e.IsUnsuspended__c=true;
            }
        }
    update Job;
    update UpdateEntries;
    return null;
}
private Job__c fetchJob(Id jobId)
{
    Job__c job = [Select Suspend_Job__c,previous_resources__c, Cancel_Merchant_Orders__c,Status__c,(Select Id, Interface_Status__c From Job_Booking_History__r where Interface_Status__c = 'Awaiting Integration') from Job__c where Id=:jobId];
    return job;
}
private List<Entries_To_Plan__c> fetchJobEntries(Id jobId)
{
    UpdateEntries = [select IsSuspended__c,IsUnsuspended__c from Entries_To_Plan__c where Job__c =:jobId ];
    return UpdateEntries;
}

 // This is the quick sort algorithm to sort the list of Entries_To_Plan__c 
 // in ascending order of installation date.

 private List<Entries_To_Plan__c> qSort(List<Entries_To_Plan__c> entriesToPlan) {
           
            if(entriesToPlan.isEmpty() || entriesToPlan.size() == 1)
                  return entriesToPlan;
                  
            // Pick the entriesToPlan from the end of the list - this will act as the 
            // "pivot". All other entriesToPlan will be compared to this one.
            Entries_To_Plan__c middle = entriesToPlan.remove(entriesToPlan.size()-1);

            // We create two lists, "left" and "right" - left holds entriesToPlan smaller
            // than the pivot, right holds the ones the same or bigger than the pivot

            List<Entries_To_Plan__c> left = new List<Entries_To_Plan__c>();
            List<Entries_To_Plan__c> right = new List<Entries_To_Plan__c>();

            // Loop over the remaining options and store each one in the appropriate list, left
            // if it is "better than" the pivot, right if it is the same or worse. The 
            // "betterThan" method is used to determine which list it should go into

            for(Entries_To_Plan__c entToPan : entriesToPlan) {
                  if(betterThan(entToPan, middle)) { // better = left, same or worse = right
                        left.add(entToPan);
                  } else {
                        right.add(entToPan);
                  }
            }

            // We now call this method again for each of the lists we have created above

            left = qSort(left);
            right = qSort(right);

            // We now store all options in the one list (including the pivot), in order
            left.add(middle);
            left.addAll(right);
            return left;
      } 

 // Since we are sorting in ascending order of installtion date we return true if the first is "better than"
 // the second, meaning installation date of fisrt is less than second.
 // We return false if the first is "worse than" or "equal to"
 // the second, meaning installation date of fisrt is greater than second.

 private Boolean betterThan(Entries_To_Plan__c first, Entries_To_Plan__c second) {
            
            if(first.Installation_Date__c == null)
                 return false;
            else if(second.Installation_Date__c == null)
                 return true;
            else if(first.Installation_Date__c == null && second.Installation_Date__c == null)
                 return false;
            else if(first.Installation_Date__c<second.Installation_Date__c)
                  return true;
            else if(first.Installation_Date__c>second.Installation_Date__c)
                  return false;
            else if(first.Installation_Date__c==second.Installation_Date__c)
                  return false;
           
           return false;
                  
         }

}