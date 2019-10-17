public with sharing class JobNamedResourceController {

    public List<Job_Named_Skill_Resource__c> jobExistingNamedResourceRecordList{get;set;}
    public List<Job_Named_Skill_Resource__c> jobNewNamedResourceRecordList{get;set;}
    public List<Job_Named_Skill_Resource__c> jobCombinedNamedResourceRecordList{get;set;}
    public List<Job_Named_Skill_Resource__c> jobNamedResourceRecordListDelete{get;set;}
    public Job__c job{get;set;}
    public boolean renderPage{get;set;}
    public Map<String,Job_Named_Skill_Resource__c> skillNamedResourceMap{get;set;}

    public JobNamedResourceController(){
        
                // Do nothing
                
         }

    public JobNamedResourceController(ApexPages.StandardController controller) {
          
          job = (Job__c)controller.getRecord();
          renderPage = true;
          
          if(job.Id == null){
                 
                 renderPage = false;
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Invalid URL.'));
                
          }
          
          jobExistingNamedResourceRecordList = [Select j.Skill_Name__c, j.Name, j.Job__c, j.Id, j.Employee__c From Job_Named_Skill_Resource__c j where j.Job__c = :job.ID];
          
          jobNewNamedResourceRecordList = new List<Job_Named_Skill_Resource__c>();
          
          for(Integer i = 1; i<=(8-jobExistingNamedResourceRecordList.size()); i++){
                
                Job_Named_Skill_Resource__c j = new Job_Named_Skill_Resource__c();
                j.Job__c = job.Id;
                jobNewNamedResourceRecordList.add(j);
                
          }
          
          jobCombinedNamedResourceRecordList = new List<Job_Named_Skill_Resource__c>();
          jobCombinedNamedResourceRecordList.addAll(jobExistingNamedResourceRecordList);
          jobCombinedNamedResourceRecordList.addAll(jobNewNamedResourceRecordList);
          
          
    }
    
    
    public Integer confirm(){
        
        jobCombinedNamedResourceRecordList = new List<Job_Named_Skill_Resource__c>();
        skillNamedResourceMap = new Map<String,Job_Named_Skill_Resource__c>();
        jobNamedResourceRecordListDelete = new List<Job_Named_Skill_Resource__c>();
        
        for(Job_Named_Skill_Resource__c j : jobNewNamedResourceRecordList){
                
                if((j.Employee__c != null && j.Skill_Name__c == null) || (j.Employee__c == null && j.Skill_Name__c != null)){
                        
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please check the data.'));
                        return 0;
                        
                }else if(j.Employee__c != null && j.Skill_Name__c != null){
                        
                        if(skillNamedResourceMap.get(j.Skill_Name__c) == null){
                        
                           jobCombinedNamedResourceRecordList.add(j);
                           
                        }
                    
                    skillNamedResourceMap.put(j.Skill_Name__c,j);
                        
                }
                
        }
        
        for(Job_Named_Skill_Resource__c j : jobExistingNamedResourceRecordList){
                
                if((j.Employee__c != null && j.Skill_Name__c == null) || (j.Employee__c == null && j.Skill_Name__c != null)){
                        
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Please check the data.'));
                        return 0;
                        
                }else if(j.Employee__c != null && j.Skill_Name__c != null){
                        
                        if(skillNamedResourceMap.get(j.Skill_Name__c) == null){
                           
                           jobCombinedNamedResourceRecordList.add(j);
                           
                        }else if(skillNamedResourceMap.get(j.Skill_Name__c) != null){
                                
                                jobNamedResourceRecordListDelete.add(j);
                                
                        }
                        
                    skillNamedResourceMap.put(j.Skill_Name__c,j);
                    
                }
                
        }
        
        return 1;
        
    }
    
    public PageReference returnToJob() {
        
        PageReference pageRef; 
        pageRef = new PageReference('/'+job.ID);                                                
        pageRef.setRedirect(true);      
        return pageRef;
        
    }

   public Pagereference save(){
        
          Integer i = this.confirm();
          
          if(i == 0){
                
                return null;
                
          }
         
          if(jobNamedResourceRecordListDelete.size()>0){
                
                Database.delete(jobNamedResourceRecordListDelete);
                
          }
          
           if(jobCombinedNamedResourceRecordList.size()>0){
                
                Database.upsert(jobCombinedNamedResourceRecordList);
                
          }
        
          PageReference pageRef = new PageReference('/'+job.ID);                                                
      pageRef.setRedirect(true);
      return pageRef;  
          
   }
   
    public Pagereference back(){
         
          return null;  
          
   }
   
    public Pagereference clearAll(){
        
        jobExistingNamedResourceRecordList = [Select j.Skill_Name__c, j.Name, j.Job__c, j.Id, j.Employee__c From Job_Named_Skill_Resource__c j where j.Job__c = :job.ID];
        Database.delete(jobExistingNamedResourceRecordList,true); 
        PageReference pageRef = new PageReference('/apex/Named_Job_Skill_Field_Set?Id='+job.Id); 
        pageRef.setRedirect(true);              
        return pageRef;
        
    }

}