global class InstallerUpdateBatch implements Database.Batchable<sObject> {
  public string query='';

  global Database.QueryLocator start(Database.BatchableContext BC)
    {
         query = 'Select id,'+system.label.InstallerBatchQuery+' from Job__c where id!=null and Is_Remedial_Job__c=false AND Is_Downtime_Job__c=false '+system.label.InstallerBatchWhereClause;
         return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<job__c> joblist)
    {
        Lock.jobTriggerSwitch =true;
        cls_IsRun.generalTriggerSwitch =true;
      if(system.label.installerSwitch=='Both')
      {
          updateL6Manager(joblist);
          updateInstaller(joblist);
      }
      else if(system.label.installerSwitch=='L6 PostCode Manager')
      {
          updateL6Manager(joblist);
      }
      else if(system.label.installerSwitch=='Installer')
      {
          updateInstaller(joblist);
      }
    }
    
    public void updateL6Manager(list<Job__c> joblist)
    {
        set<job__c> updateJobs = new set<Job__c>();
      set<string> postcodesector = new set<string>();
      for(job__c jb: joblist)
    {
        if(jb.Install_Postcode__c!=null)
      postcodesector.add(jb.Install_Postcode__c.substring(0,jb.Install_Postcode__c.length()-2));
    }  
    
    map<string, string> postCodeManagerMap = new map<string, string>();
    map<string, string> areaGroupEmpMap  = new map<string, string>();
        for(PostCode_Sector__c pc : [select Name, Area_Group__c from PostCode_Sector__c where Name in :postcodesector and Type__c = 'Installation' ])
        {
            postCodeManagerMap.put(pc.name, pc.Area_Group__c);
            areaGroupEmpMap.put(pc.Area_Group__c, null);
        }
        
        for(Employee__c emp : [Select id, Area_Group__c from Employee__c where Area_Group__c in:areaGroupEmpMap.keySet() and Area_Group__c!=null])
        {
            areaGroupEmpMap.put(emp.Area_Group__c, emp.Id);
        }
        
        for(job__c job : joblist)
        {   
            if(job.Install_Postcode__c!=null)
            {
                 string sector = job.Install_Postcode__c.substring(0,job.Install_Postcode__c.length()-2);
               if(postCodeManagerMap.containsKey(sector))
               {
                    string area = postCodeManagerMap.get(sector);
                    if(areaGroupEmpMap.containskey(area))
                    job.L6_PC_Manager__c = areaGroupEmpMap.get(area);
                    updateJobs.add(job);
               }
            }
        }
    
        if(updateJobs.size()>0)
        Database.update(new List<Job__c>(updateJobs),false);
    
    }
    
    
    public void updateInstaller(list<Job__c> joblist)
    {
        list<Opportunity> updateOpportunities = new list<Opportunity>();
        set<id> jobIds = new set<id>();
      for(job__c jb: joblist)
    {
      jobIds.add(jb.id);
    } 
    
    Map<id,List<Diary_Entry__c>> jobDiaryEntryMap = new Map<id,List<Diary_Entry__c>>();
        for(Diary_Entry__c de: [select id,Overbooked_Hours__c,Hours__c,Week__r.Employee__c,job__c from Diary_Entry__c where job__c=:jobIds and Sub_Type__c='Mechanical' order by Hours__c desc])
    {
        if(jobDiaryEntryMap.containsKey(de.job__c))
        {
            List<Diary_Entry__c> delist = jobDiaryEntryMap.get(de.job__c);
            delist.add(de);
            jobDiaryEntryMap.put(de.job__c,delist);
        }
        else
        {
            jobDiaryEntryMap.put(de.job__c,new list<Diary_Entry__c>{de});
        }
    }
    
    Map<String,opportunity> oppInstallerMap = new map<String,opportunity>();
    
    for(job__c job : joblist){
            if(jobDiaryEntryMap.containskey(job.id) )
            {
                List<Diary_Entry__c> DEs= jobDiaryEntryMap.get(job.id);
                String payNum;
              if(DEs.size()>0)
              {
                 Decimal mechhours =0;
                 for(Diary_Entry__c de: DEs)
                 {
                   de.Overbooked_Hours__c = de.Overbooked_Hours__c!=null?de.Overbooked_Hours__c:0;
                   de.hours__c = de.hours__c!=null?de.hours__c:0;
                   if((de.hours__c+de.Overbooked_Hours__c)>mechhours)
                   {
                      mechhours = de.hours__c+de.Overbooked_Hours__c;
                      payNum =de.Week__r.Employee__c;
                   }
                   
                }
               
               Opportunity o= new Opportunity(id=job.CHI_Lead__c ,installer__c=payNum);
               oppInstallerMap.put(job.CHI_Lead__c,o);
               //updateOpportunities.add(o);
            }
            }
        }
        
        updateOpportunities = oppInstallerMap.values();
        if(updateOpportunities.size()>0)
        Database.update(updateOpportunities,false);        
    }
    
    global void finish(Database.BatchableContext bc){
    }
    
   
  
}