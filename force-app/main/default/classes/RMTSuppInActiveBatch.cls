global class RMTSuppInActiveBatch implements Database.Batchable<sObject> {

   global string RMTRecord;
   global Database.QueryLocator start(Database.BatchableContext BC){     
          string Active='Active';  
          Date TodayDate = Date.today();        
               
          string RMTRecord = 'select id,Name,Sub_status__c,Supplier_Status__c,GasSafe_Expiry_Date__c,P5_Health_and_Safety_Questionnaire__c,P5_Public_Liability_to_Date__c,P5_Employee_Liability_to_Date__c,(select id,name,AutoInactiveUpdate__c,P5_Status__c,Sub_status__c,Resource_ID__c,CHI_Employee__c,lowest_date_on_end_date__c from Contractors__r where P5_Status__c=:Active) From RMT_Supplier__c'+
                            ' where'+' ('+'GasSafe_Expiry_Date__c'+'<='+':TodayDate'+' OR P5_Health_and_Safety_Questionnaire__c'+'<=:'+'TodayDate'+
                           ' OR P5_Public_Liability_to_Date__c'+'<=:'+'TodayDate'+' OR P5_Employee_Liability_to_Date__c'+'<=:'+'TodayDate'+')'+' AND Supplier_Status__c =:Active';
          system.debug('----->'+RMTRecord);
          return Database.getQueryLocator(RMTRecord);
    }   

     
   global void execute(Database.BatchableContext BC, List<RMT_Supplier__c> RMTSupplier){
     system.debug('+++++++++'+RMTSupplier);
     List<P5_RMT_Contractors__c> UpdateConRec = new List<P5_RMT_Contractors__c>();
     List<RMT_Supplier__c> UpdateRMTRec = new List<RMT_Supplier__c>();
     List<Employee__c> UpdateEmp = new List<Employee__c>();
     List<Employee__c> EmpQuery;
     List<Diary_Entry__c> DiaryQuery;
     List<Employee__c>  ResEmployees;
     List<Id> EmpIds = new List<Id>();
     List<Job__c> UpdateJobList = new List<Job__c>();
     //List<job__c> Job = new List<Job__c>();
     set<id> JobIds= new set<id>();
     //Map<id,List<Week__c>> weeks= new Map<id,List<Week__c>>();
     List<string> ResIDs = new List<string>();
     List<Date> RmtDates = new List<Date>();
     List<Week__c> UpdateWeekList = new List<Week__c>();
     List<P5_RMT_Contractors__c> RMTContractors = new List<P5_RMT_Contractors__c>();
     set<id> weekids = new set<id>();
     list<Diary_Entry__c> DiaryEntry = new List<Diary_Entry__c>();
     
      
      if(RMTSupplier.size()>0){
          for(RMT_Supplier__c processRMTSupp: RMTSupplier){
                
                processRMTSupp.Supplier_Status__c = 'Inactive';
                processRMTSupp.Sub_status__c = 'Deleted - Documents Expired';
                
                if(processRMTSupp.Contractors__r.size()>0){
                for(P5_RMT_Contractors__c RMTcont: processRMTSupp.Contractors__r)
                RMTContractors.add(RMTcont);
                }
                UpdateRMTRec.add(processRMTSupp);
              }
      
      }
      
      if(RMTContractors.size()>0){
          for(P5_RMT_Contractors__c processContractors: RMTContractors){
            //ProcessContractors.
            processContractors.P5_Status__c = 'Inactive';
            processContractors.Sub_status__c = 'Deleted - Documents Expired';
            processContractors.AutoInactiveUpdate__c = true;
            
            if(ProcessContractors.Resource_ID__c!=NULL){
               ResIds.add(ProcessContractors.Resource_ID__c);
            }
            updateConRec.add(processContractors);
          }
      }
     system.debug('RES IDS'+Resids);

      if(ResIds.size()>0){
       //EmpQuery= [select id,name,Resource_Id__c,Inactive__c,(select id,name,Named_Employee__c,autoInactiveUpdate__c,Installation_Date__c,Needs_Re_Planing__c,Sub_Status__c,Status__c from Jobs__r where Installation_Date__c =:Date.Today().adddays(1) order BY Installation_Date__c ASC ) from Employee__c where Resource_Id__c=:ResIds]; 
       EmpQuery= [select id,name,Resource_Id__c,Inactive__c,(select id,name,Employee__c,Week_Commencing__c,autoInactiveUpdate__c  from Weeks__r where week_Commencing__c=:Date.Today().toStartOfWeek()) from Employee__c where Resource_Id__c=:ResIds]; 
       
       system.debug(EmpQuery.size());
       for(Employee__c Emp: EmpQuery){
                
                    Emp.Inactive__c = True;
                    Emp.AutoInactiveUpdate__c = True;
                    Emp.Locked_By_Admin__c = TRUE;
                    updateEmp.add(Emp);
                
        system.debug('@@@@@'+Emp.weeks__r);
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
         system.debug('Diary Entrys'+DiaryQuery);
         if(DiaryQuery.size()>0){
            for(Diary_Entry__c DE: DiaryQuery){
              JobIds.add(DE.job__c);  
            }
          }
        }
        
        
           /* system.debug('@@@@@@'+EmpQuery[i].Jobs__r);
        if(EmpQuery[i].Jobs__r.size()>0){
           for(integer k=0;k<EmpQuery[i].Jobs__r.size();k++){
             Job.add(EmpQuery[k].Jobs__r);
           }
          }
          else{
            // if not met the criteria dont process it 
          }*/
      
      
      List<Job__c> Job=[select id,name,Named_Employee__c,autoInactiveUpdate__c,Installation_Date__c,Needs_Re_Planing__c,Sub_Status__c,Status__c from Job__c where id=:JobIds AND (Installation_Date__c <=:Date.Today().adddays(integer.valueof(System.Label.No_of_Days)) AND Installation_Date__c >=:Date.Today())];
       system.debug('--Job list-->'+Job);
       if(Job.size()>0){
           for(Job__c JobList: Job){
              JobList.Needs_Re_Planing__c = TRUE;
              JobList.Sub_Status__c='Deleted - Documents Expired';
              JobList.Status__c='Inactive';
              JobList.autoInactiveUpdate__c = TRUE;
              UpdateJobList.add(JobList);
           }
       }
       //savepoint sp = Database.setSavepoint();
        
        try{                
             if(UpdateRMTRec.size()>0) 
             Database.SaveResult[] srList = database.update(UpdateRMTRec,false);       
                          
             if(updateConRec.size()>0)
             Database.SaveResult[] srList = database.update(updateConRec,false);    
             
             if(updateEmp.size()>0)
             Database.SaveResult[] srList = database.update(updateEmp,false);
             
             if(updateWeekList.size()>0)
             Database.SaveResult[] srList = database.update(updateWeekList,false);
             
             if(UpdateJobList.size()>0)
             Database.SaveResult[] srList = database.update(UpdateJobList,false);
                
           }catch(Exception excp){
                    
              // Revert the database to the original state
             // Database.rollback(sp);
              
                    
           }    
        
  }
  
  global void finish(Database.BatchableContext BC){
  
  }
  
}