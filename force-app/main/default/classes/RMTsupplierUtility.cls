public class RMTsupplierUtility{

    public static List<P5_RMT_Contractors__c> Contractors;
    Public static List<employee__c> employeeList;
    public static List<Job__c> JobList;
    public static List<id> EmpIds;
    public static List<string> ResIds;
    public static set<id> WeekIds;
    public static set<id> JobIds;
    public static list<week__c> updateWeekList;
    public static List<P5_Qualification__c> Qualifications;
    public static set<id> contIDS;
    
  
  public static void ActivateSupplier(string newStatus,Boolean newEmpStatus,List<id> RMTSupplier,string RMTStatus){
    
     EmpIds = new List<id>();
     ResIds = new List<string>();
     WeekIds = new set<id>();
     JobIds = new set<id>();
     updateWeekList= new list<week__c>();
     
     system.debug(''+newStatus+' '+RMTSupplier+' '+newEmpStatus);
     
     
     
     Contractors = [SELECT id, autoInactiveUpdate__c,P5_Status__c,Resource_Id__c FROM P5_RMT_Contractors__c 
                    WHERE P5_Status__c !=: newStatus AND Supplier__c in :RMTSupplier];  
     system.debug('call to Activate'+Contractors.size()); 
     
     if(newStatus == 'Active')
        {
         for (P5_RMT_Contractors__c childContractor: Contractors)
         {
             If(childContractor.AutoInactiveUpdate__c == true)
             {
                 childContractor.P5_Status__c = 'Active';
                 childContractor.AutoInactiveUpdate__c = false;
                 childContractor.Sub_status__c = '';
                 
                 if(childContractor.Resource_Id__c!=NULL)
                 ResIds.add(childContractor.Resource_Id__c);
             }
         }
    }
     
     if(contractors !=NULL && Contractors.size()>0){      
     Database.SaveResult[] srList = database.update(Contractors,false); 
     //update Contractors;     // Set all contractors to inactive status.
     }
     //CODE TO ACTIVATE JOBS 
     
     if(string.valueof(System.Label.RMT_Supplier_Activate)== 'yes'){
     
         List<Note> empNotes = new List<Note> ();
         system.debug('');
         if(ResIds.size() > 0){     
             if(rmtStatus == 'Active'){
             // Active
             EmployeeList = [   SELECT id,name,Resource_Id__c,autoInactiveUpdate__c,inactive__c,(select id,name,Employee__c,AutoInactiveUpdate__c,Week_Commencing__c from Weeks__r where AutoInactiveUpdate__c=TRUE) FROM employee__c 
                                WHERE inactive__c !=: newEmpStatus 
                                AND employee__c.autoInactiveUpdate__c = true  
                                AND Resource_Id__c in :ResIds];
             if(EmployeeList != NULL){
                 for (employee__c childEmployee: EmployeeList){
                     Note note = new Note();
                     childEmployee.inactive__c = newEmpStatus;
                     childEmployee.Locked_By_Admin__c = newEmpStatus;
                     //childEmployee.RMT_Suspended_Date__c = null;
                     childEmployee.autoInactiveUpdate__c = false;
                     //childEmployee.RMT_Suspended_Reason__c = '';
                     note.Title = 'Made active';
                     note.ParentId = childEmployee.id; 
                     if(childEmployee.weeks__r!=NULL){
                         for(Week__c week: childEmployee.weeks__r){
                           WeekIds.add(week.id);
                           week.autoInactiveUpdate__c = false;
                           updateWeekList.add(week);
                         }
                     }
                     EmpIds.add(childEmployee.id);
                     empNotes.add(note);
                 }    
                 }
             }
            }
            
            List<Diary_Entry__c> DE= [select id,name,week__c,Job__c from Diary_Entry__c where week__c in:WeekIds AND job__r.autoInactiveUpdate__c=TRUE];
            if(DE!=NULL){
                for(Diary_Entry__c DE1: DE){
                     JobIds.add(DE1.Job__c);
                }
            }
            if(EmployeeList != NULL){
             Database.SaveResult[] srList = database.update(EmployeeList,false); 
            //update EmployeeList;
            }
            If(UpdateWeekList.size()>0){
            Database.SaveResult[] srList = database.update(UpdateWeekList,false); 
            //update UpdateWeekList;
            } 
            if(empNotes != NULL){insert empNotes;}
            
            JobList= [select id,name,autoInactiveUpdate__c,Named_Employee__c,Installation_Date__c,Needs_Re_Planing__c,Sub_Status__c,Status__c
                      from Job__c where Id in :JobIds
                                  AND autoInactiveUpdate__c = true];
            
            if(JobList!=NULL){
               for(Job__c job: JobList){
                  job.Needs_Re_Planing__c = false;
                  job.Sub_Status__c='Planned';
                  job.Status__c='Planned';
                  job.autoInactiveUpdate__c = false;
               
               }       
            } 
            
            if(JobList!=NULL){
            Database.SaveResult[] srList = database.update(JobList,false);
            //update JobList;
            }
        }
  }
  
  public static void RunEmailChange(list<Id> RMTSupplier,Map<id,string> RMTMap){
    
    contIDS = new set<id>();
    
    system.debug('------------------>'+RMTSupplier.size());
    //system.debug('%%%%%%%%%%%%%%%%%'+RMTMap.size());  
    if(contractors != null && Contractors.size()>0)
    Contractors.clear();
    
    if(RMTSupplier.size()>0){
     
     Contractors = [SELECT id, P5_Status__c,RMT_Supplier_Email__c,Supplier__c FROM P5_RMT_Contractors__c 
                    WHERE Supplier__c in :RMTSupplier]; 
     //system.debug('------------->'+contractors.size());               
    }  
                  
    if(Contractors!= null && contractors.size()>0){
        for(P5_RMT_Contractors__c updateEmail: Contractors){
           contIDS.add(updateEmail.id);
           if(RMTMap.containskey(updateEmail.Supplier__c)){ 
                     
            UpdateEmail.RMT_Supplier_Email__c = RMTMap.get(updateEmail.id);
            //updateCont.add(updateEmail);
           } 
           
        }
      //update Contractors;  
      
      Qualifications = [select id,Contractor__c,Contractor__r.Supplier__c,Email_to_Notify__c from P5_Qualification__c where Contractor__c=:contIDS ];
      
      if( Qualifications!= null && Qualifications.size()>0){
        for(P5_Qualification__c updateEmail: Qualifications){
           if(RMTMap.containskey(UpdateEmail.Contractor__r.Supplier__c)){
              updateEmail.Email_to_Notify__c = RMTMap.get(updateEmail.COntractor__r.Supplier__c);
              
           }
        }
      }
      
      try{
          if(Contractors != null)          
          update Contractors;
          
          if(Qualifications != null)
          Update Qualifications;
          
      }catch(Exception e){
          
      }
        
     } 
  }

  public static void RunInactiveSupplier(string newStatus,string newSubstatus,List<id> RMTSupplier){
  
     if(Contractors !=null && Contractors.size()>0)
     Contractors.clear();
     
     Contractors = [SELECT id, autoInactiveUpdate__c,P5_Status__c,Resource_Id__c FROM P5_RMT_Contractors__c 
                    WHERE P5_Status__c !=: newStatus AND Supplier__c in :RMTSupplier];  
     //system.debug('call to INActivate'+Contractors.size()+' '+newStatus); 
     
      if(newStatus == 'Inactive' && Contractors != null)
        {    
             
             for (P5_RMT_Contractors__c childContractor: Contractors)
             {
                     childContractor.P5_Status__c = 'Inactive';
                     childContractor.AutoInactiveUpdate__c = true;
                     childContractor.Sub_status__c = newSubstatus;
                     
              }
              update Contractors; //Update Status to Inactive
         }
    
  }

  public static void updateRiskCategory(map<string, string>  riskCategoryMap)
  {
    list<Supplier__c> suppList = [Select id,Vendor_Number__c from Supplier__c where Vendor_Number__c in : riskCategoryMap.keyset()] ;
    for(Supplier__c s: suppList)
    {
        s.Risk_Category__c = riskCategoryMap.get(s.Vendor_Number__c);
    }

    if(suppList.size()>0)
    {
      update suppList;
    }

  }
  

}