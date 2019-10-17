global class ContSuppInActiveBatch implements Database.Batchable<sObject> {

   global string ContRecord;
   global Database.QueryLocator start(Database.BatchableContext BC){     
          string Active='Active'; 
          string Inactive = 'Inactive'; 
          Date TodayDate = Date.today();        
          string ContRecord = 'select id,name,AutoInactiveUpdate__c,P5_Status__c,Sub_status__c,Resource_ID__c,lowest_date_on_end_date__c,CHI_Employee__c from P5_RMT_Contractors__c'+
                            ' where'+' ('+'CRB_Expiry_Date__c'+'<='+':TodayDate'+' OR License_Expiry_Date__c'+'<=:'+'TodayDate'+' OR lowest_date_on_end_date__c'+'<=:'+'TodayDate'+')'+' AND '+'('+'P5_Status__c=:Active OR P5_Status__c=:Inactive'+')';
          //system.debug('----->'+ContRecord);
          return Database.getQueryLocator(ContRecord);
    }   

     
   global void execute(Database.BatchableContext BC, List<P5_RMT_Contractors__c> RMTContractors){
     List<P5_RMT_Contractors__c> UpdateConRec = new List<P5_RMT_Contractors__c>();
     //List<RMT_Supplier__c> UpdateRMTRec = new List<RMT_Supplier__c>();
     List<Employee__c> UpdateEmp = new List<Employee__c>();
     List<Employee__c> EmpQuery;
     List<Diary_Entry__c> DiaryQuery ;
     List<Employee__c>  ResEmployees;
     List<Id> EmpIds = new List<Id>();
     List<Job__c> UpdateJobList = new List<Job__c>();
     //Map<string,Employee__c> weeks= new Map<string,Employee__c>();
     List<string> ResIDs = new List<string>();
     List<Date> RmtDates = new List<Date>();
     List<Week__c> UpdateWeekList = new List<Week__c>();
     set<id> weekids = new set<Id>();
     set<id> JobIds = new Set<Id>();
     //List<P5_RMT_Contractors__c>RMTContractors = new List<P5_RMT_Contractors__c>();
     //system.debug('+++++++++'+RMTSupplier);
      
      
      if(RMTContractors.size()>0){
          for(P5_RMT_Contractors__c processContractors: RMTContractors){
            //ProcessContractors.
                
                processContractors.P5_Status__c = 'Inactive';
                processContractors.Sub_status__c = 'Deleted - Documents Expired';
                processContractors.AutoInactiveUpdate__c = true;
                updateConRec.add(processContractors);
            
            if(ProcessContractors.Resource_ID__c!=NULL)
            ResIds.add(ProcessContractors.Resource_ID__c);
            
            
          }
      }
     //system.debug('RES IDS'+Resids.size());
     
      if(ResIds.size()>0){
       EmpQuery= [select id,name,Resource_Id__c,Inactive__c,(select id,name,Employee__c,Week_Commencing__c,autoInactiveUpdate__c  from Weeks__r where week_Commencing__c=:Date.Today().toStartOfWeek()) from Employee__c where Resource_Id__c=:ResIds]; 
       
       system.debug('EMP SIZE'+EmpQuery.size());
       for(Employee__c Emp: EmpQuery){
                
                    Emp.Inactive__c = True;
                    Emp.AutoInactiveUpdate__c = True;
                    Emp.Locked_By_Admin__c = TRUE;
                    updateEmp.add(Emp);
                
        //system.debug('@@@@@'+Emp.weeks__r);
        if(Emp.weeks__r.size()>0){
         for(Week__c weeks:Emp.weeks__r){
             weekids.add(weeks.id);
             weeks.autoInactiveUpdate__c = TRUE;
             UpdateWeekList.add(weeks);
           }
         } 
         else{
            // Nothing ;
         } 
         }
         
         DiaryQuery =[select id,name,week__c,Job__c,start__c,End__c from Diary_Entry__c where week__c=:weekids ];
         system.debug('Diary Entrys'+DiaryQuery.size());
         if(DiaryQuery.size()>0){
            for(Diary_Entry__c DE: DiaryQuery){
              JobIds.add(DE.job__c);  
            }
          }
        }
       
       List<Job__c> Job=[select id,name,Named_Employee__c,autoInactiveUpdate__c,Installation_Date__c,Needs_Re_Planing__c,Sub_Status__c,Status__c from Job__c where id=:JobIds AND (Installation_Date__c <=:Date.Today().adddays(integer.valueof(System.Label.No_of_Days)) AND Installation_Date__c >=:Date.Today())];
       //system.debug('--Job list-->'+Job);
       system.debug('@@@Job size'+Job.size());
       if(Job.size()>0){
           for(Job__c JobList: Job){
              JobList.Needs_Re_Planing__c = TRUE;
              JobList.Sub_Status__c='Deleted - Documents Expired';
              JobList.Status__c='Inactive';
              JobList.autoInactiveUpdate__c = TRUE;
              UpdateJobList.add(JobList);
           }
       }
       
       system.debug('@@@UpdateJobList'+UpdateJobList);
       savepoint sp = Database.setSavepoint();
        
        try{                
             
             if(updateConRec.size()>0){
               Database.SaveResult[] srList = database.update(updateConRec,false);  
             }
             
             if(updateEmp.size()>0){
               Database.SaveResult[] srList = database.update(updateEmp,false);
             }
            
             if(updateWeekList.size()>0){
               Database.SaveResult[] srList = database.update(updateWeekList,false); 
             }
             
             if(UpdateJobList.size()>0){
               Database.SaveResult[] srList = database.update(UpdateJobList,false);
             }   
           }catch(Exception excp){
                    
              // Revert the database to the original state
              Database.rollback(sp);
              
                    
           }    
        
  }
  
  global void finish(Database.BatchableContext BC){
  
  }
  
}