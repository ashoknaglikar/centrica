global class GroupShiftPatternBatch implements Database.Batchable<sObject>{
    /*
        This class mainly caters to need of generating shifts for large number of workcycles:
        This class collects all the workcycles where Batch Status is 'Process' and generates the Weeks according to Shift pattern.
        The main basis of this class lies in the follwoing points:
        
        When we generate weeks for group, shift pattern is same for all the employees so in order to immprove the performance of the code. 
        1) We create one sample Week and a sample list of Diary enty. 
        2) We then just clone the above week and Diary enty to all other employees.
        
        for achieving this we follow:
        1) we create as many child work cycles as there employees in the group, which are same as parent cycles.(Each employee will have a individual Workcycle.)
        2) We set the batch status of these child Workcycles to 'Process'. 
        3) Above s are all done in GroupAvailabilityGeneration and RegenrateAvailabilty classes.
        4) In night we schedule this batch which then picks these individual Workcycles and generate the Weeks.
        5) If process is sucess then we Stamp 'Complete' on Batch status.
        6) In case of failure we stamp 'Error' and error msg on the respective Workcycles.
        7) after the completion of batch we send the email alerts to rspective creators of parent cycles. 
    */
    public static void createWrkCycleBatch(){
      GroupShiftPatternBatch objGrpSPAva = new GroupShiftPatternBatch();
      ID batchprocessid = Database.executeBatch(objGrpSPAva,40);
    } 
    set<string> parentId = new set<string>();
    global Database.QueryLocator start(Database.BatchableContext BC){
     
        return Database.getQueryLocator('Select Name,Error__c, Employee__c,Employee__r.Pool_Diary__c,Number_of_Weeks__c,Batch_Status__c, Shift_Pattern__c,Shift_Pattern__r.Monday_Start_Time__c,Shift_Pattern__r.Monday_End_Time__c,Shift_Pattern__r.Monday_Max_Hours__c,Shift_Pattern__r.Tuesday_Start_Time__c,Shift_Pattern__r.Tuesday_End_Time__c,Shift_Pattern__r.Tuesday_Max_Hours__c,Shift_Pattern__r.Wednesday_Start_Time__c,Shift_Pattern__r.Wednesday_End_Time__c,Shift_Pattern__r.Wednesday_Max_Hours__c,Shift_Pattern__r.Thursday_Start_Time__c,Shift_Pattern__r.Thursday_End_Time__c,Shift_Pattern__r.Thursday_Max_Hours__c,Shift_Pattern__r.Friday_Start_Time__c,Shift_Pattern__r.Friday_End_Time__c,Shift_Pattern__r.Friday_Max_Hours__c,Shift_Pattern__r.Saturday_Start_Time__c,Shift_Pattern__r.Saturday_End_Time__c,Shift_Pattern__r.Saturday_Max_Hours__c,Shift_Pattern__r.Sunday_Start_Time__c,Shift_Pattern__r.Sunday_End_Time__c,Shift_Pattern__r.Sunday_Max_Hours__c,Start_Date__c,Shift_Pattern__r.Pool_Shift_Pattern__c, Shift_Pattern__r.Sun_Unav_End_Time__c,Shift_Pattern__r.Sat_Unav_End_Time__c, Shift_Pattern__r.Fri_Unav_End_Time__c, Shift_Pattern__r.Thu_Unav_End_Time__c,Shift_Pattern__r.Wed_Unav_End_Time__c, Shift_Pattern__r.Tue_Unav_End_Time__c, Shift_Pattern__r.Mon_Unav_End_Time__c,Shift_Pattern__r.Sun_Unav_Start_Time__c, Shift_Pattern__r.Sat_Unav_Start_Time__c, Shift_Pattern__r.Fri_Unav_Start_Time__c,Shift_Pattern__r.Thu_Unav_Start_Time__c, Shift_Pattern__r.Wed_Unav_Start_Time__c, Shift_Pattern__r.Tue_Unav_Start_Time__c,Shift_Pattern__r.Mon_Unav_Start_Time__c,Shift_Pattern__r.Unavailability_Reason__c, CreatedBy.Email, Group__r.Name, Work_Cycle__c from Work_Cycle__c where Batch_Status__c = \'Process\'');
    }
  
    global void execute(Database.BatchableContext BC, List<Sobject> workCycles)
    {
        GroupAvailabilityGeneration grpObj = new GroupAvailabilityGeneration();
        map<string, list<Work_Cycle__c>> shiftPatternWcmap = new map<string, list<Work_Cycle__c>>();
        map<integer, list<Week__c>> sampleWeekWcmap = new  map<integer, list<Week__c>>();
        map<integer, list<Diary_Entry__c>> sampleDiaryWeekmap = new  map<integer, list<Diary_Entry__c>>();
        //set<id> parentId = new set<Id>();
        list<Week__c> weeksToIns = new list<Week__c>();
    
        map<string, Work_Cycle__c> empIdWcMap = new map<string, Work_Cycle__c>();
        list <Week__c> weekLst = new List<Week__c>();
        list<Work_Cycle__c> sucessWcs = new list<Work_Cycle__c>();
        for(Sobject wc : workCycles)
        {
            Work_Cycle__c w = (Work_Cycle__c)wc;
            
            if(!empIdWcMap.containsKey(w.Employee__c))
            {
                empIdWcMap.put(w.Employee__c, w);
            }
            parentId.add(w.Work_Cycle__c);
            Integer numberOfWeeks = (w.Number_of_Weeks__c).intValue();
            Date workCycleEndDate = w.Start_Date__c.addDays((numberOfWeeks*7)-1);
            weekLst.addall(RetrieveWeeks(empIdWcMap.Keyset(),workCycleEndDate,w.Start_Date__c));
            
        }
        system.debug('parentId--->'+parentId);
        try{
            if(weekLst.size()>0)
            {
                list<Work_Cycle__c> errorWc = new list<Work_Cycle__c>();
                set<string> errorEmps = new set<string>();
                for(Week__c w: weekLst)
                {
                    if(!errorEmps.contains(w.Employee__c))
                    {
                        errorEmps.add(w.Employee__c);
                        Work_Cycle__c errWc = empIdWcMap.get(w.Employee__c);
                        errWc.Batch_Status__c = 'Error';
                        errWc.Error__c = 'Future weeks present.Please deal them first';
                        errorWc.add(errWc);
                        empIdWcMap.remove(w.Employee__c);
                    }   
                }
                
                if(errorWc.size()>0)
                {
                    database.update(errorWc);
                }
                
            }
            
            
           
            if(empIdWcMap!= null)
            {
                for(string i : empIdWcMap.keyset())
                {
                    Work_Cycle__c newWc= empIdWcMap.get(i);
                    
                    newWc.Batch_Status__c = 'Complete';
                    sucessWcs.add(newWc);
                    //weeksToIns.addall(createWeeks(newWc));
                    list<Work_Cycle__c> lstWcs = new list<Work_Cycle__c>();
                    if(shiftPatternWcmap.containsKey(newWc.Shift_Pattern__c))
                    {
                        lstWcs.addall(shiftPatternWcmap.get(newWc.Shift_Pattern__c));
                        lstWcs.add(newWc);
                    }
                    else
                    {
                        lstWcs.add(newWc);
                    }
                    shiftPatternWcmap.put(newWc.Shift_Pattern__c, lstWcs);
                    
                }   
                system.debug('shiftPatternWcmap-->'+shiftPatternWcmap);
                integer num = 1;
                for(string s : shiftPatternWcmap.keyset())
                {
                    
                    Work_Cycle__c wcObj = shiftPatternWcmap.get(s)[0];
                    
                    Map<String, String> maxHourMap = new Map<String, String>();
                    Map<String, String> UnavHourMap = new Map<String, String>();
                    maxHourMap = GroupAvailabilityGeneration.calculateMaxHours(wcObj);
                    GenerateAvailability.maxHourMap = maxHourMap;
                    if(!wcObj.Shift_Pattern__r.Pool_Shift_Pattern__c)
                    UnavHourMap = GenerateAvailability.calculateUnavailaHours(wcObj);
                    Double totalHours = GenerateAvailability.populateMaxHoursOnWeek(maxHourMap);
                   
                    Week__c week = grpObj.createSampleWeek(wcObj, maxHourMap,totalHours);
                    
                    week.Week_Commencing__c = wcObj.Start_Date__c;
                    List<Diary_Entry__c> sampleEnt = grpObj.createSampleEntries(wcObj, week);
                    
                    sampleDiaryWeekmap.put(num,sampleEnt);
                    
                    
                    list<Week__c> weeksList = new list<Week__c>();
                    integer numberOfWeeks = (wcObj.Number_of_Weeks__c).intValue();
                    for(Work_Cycle__c w : shiftPatternWcmap.get(s))
                    {
                        Date startDateNextOfWeek = wcObj.Start_Date__c;
                        list<Week__c> innerLst = new list<Week__c>();
                        for(Integer j=0;j<numberOfWeeks;j++){
                             
                            Week__c nwWeek = week.clone(false,true);
                            nwWeek.Employee__c = w.Employee__c;
                            nwWeek.Week_Commencing__c = startDateNextOfWeek;
                            nwWeek.Merge_Num__c= j;
                            innerLst.add(nwWeek);
                                    
                            startDateNextOfWeek = (startDateNextOfWeek.toStartOfWeek()).addDays(7);
                            
                         }
                         weeksList.addall(innerLst); 
                    }
                    sampleWeekWcmap.put(num,weeksList);
                    num = num+1;
                    weeksToIns.addall(weeksList);
                    
                    
                }
                
                
                
                if(weeksToIns.size()>0)
                    insert weeksToIns;
                    
                list<Diary_Entry__c> entToIns = new list<Diary_Entry__c>();
                for(integer i : sampleWeekWcmap.keyset())   
                {
                    list<Diary_Entry__c> entPerWeek = new list<Diary_Entry__c>();
                    for(Week__c w: sampleWeekWcmap.get(i))
                    {
                        
                        list<Diary_Entry__c> deLst = new list<Diary_Entry__c>();
                        for(Diary_Entry__c d:sampleDiaryWeekmap.get(i))
                        {
                            
                            Diary_Entry__c de = d.clone(false,true);
                            de.Week__c = w.Id;
                            integer sd = (w.Merge_Num__c *7).intValue();
                           // de.Start__c = d.Start__c.adddays(sd);
                           // de.End__c = d.End__c.adddays(sd);
                           
                            // PRB00027154 fix starts  
                          de.Start__c = Datetime.newInstance(d.Start__c.Date().addDays(sd),d.Start__c.time());
                          de.End__c = Datetime.newInstance(d.End__c.Date().addDays(sd),d.End__c.time());                          
                          // PRB00027154 fix ends
                          
                            deLst.add(de);
                            
                        }
                        entPerWeek.addall(deLst);
                        
                        
                    }
                    entToIns.addall(entPerWeek);
                    
                }
                            
                if(entToIns.size()>0)
                {
                    insert entToIns;
                } 
                
                if(sucessWcs.size()>0)
                {
                    update sucessWcs;
                }
            }
        }catch (Exception e)
        {
            system.debug(e);
        }
        list<Work_Cycle__c> wcParent = new list<Work_Cycle__c>();
        for(Work_Cycle__c parentWC : [Select CreatedBy.Email,Group__r.Name,Name from Work_Cycle__c where id in:parentId and EmailSent__c = false])
        {
            parentWC.EmailSent__c = true;
            wcParent.add(parentWC);
            Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();      
            email1.setSubject('Workcycle: '+parentWC.Name+' is processed by Batch.');      
            String[] toAddresses = new String[] {parentWC.CreatedBy.Email};       
            email1.setToAddresses(toAddresses);      
            email1.setPlainTextBody('Workcycle: '+parentWC.Name+' is processed for the Group '+parentWC.Group__r.Name+'. Please check your workcycle after 4 hours. \n NOTE: There might be some exceptions or failures for One or more Employee.' );      
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});
        } 
        if(wcParent.size()>0)
        update wcParent;             
    }
    
    private list<Week__c> RetrieveWeeks(set<string> empId, date workCycleEndDate, date start)
    {
        list<Week__c> wkLst = [Select Name, Week_Commencing__c,Employee__r.Name from Week__c where 
                                               (Week_Commencing__c >= :(start) 
                                               and Week_Commencing__c < :workCycleEndDate)
                                               and Employee__c in :empId];  
       return wkLst;
    }
    
        
    
    global void finish(Database.BatchableContext bc){
        
        system.debug('parentId---->'+parentId);
        
    }

}