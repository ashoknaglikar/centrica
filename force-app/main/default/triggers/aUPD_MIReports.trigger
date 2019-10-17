trigger aUPD_MIReports on Commissioning_Report__c (after update) {
    
    if (cls_IsRun.isJobCompletion==false || test.isRunningTest()) 
    {
        
    ELESCSA__c ELESCSAobj=new ELESCSA__c();
    GasSafe_Report__c gasSafeReportObj = new GasSafe_Report__c();
    List<GasSafe_Report__c> gasSafeList = new List<GasSafe_Report__c>();
    List<Id> commIdList = new List<Id>();
    Id gasCommReportRecordTypeId = null;
    Id DiaryEntry = null;
    Id eleCommReportRecordTypeId = null;
    List<Id> IdList=new List<Id>();
    List<ELESCSA__c> ELESCSAlist = new List<ELESCSA__c>();
    Integer iCount = 0;
    
    //geting the recordtype for Gas Commissioning reports
    gasCommReportRecordTypeId = [Select r.Name, r.Id From RecordType r where 
    r.Name='Gas Installation Works' and SobjectType = 'Commissioning_Report__c' limit 1].Id;
    
       
    for(Integer i =0; i < Trigger.new.size(); i++)
    {
        if(Trigger.new[i].RecordTypeId == gasCommReportRecordTypeId)
        {
            //report records should get generated only for the completed commissioning documents
            if(Trigger.new[i].Status__c == 'Completed' && Trigger.old[i].Status__c != 'Completed')
            {
                Id jobId = Trigger.new[i].Job_Number__c;        
                Id jobCompReportId = Trigger.new[i].id;
                commIdList.add(jobCompReportId);
            }
        }        
    }
    if(commIdList.size() > 0)
    {
    //fetch the job and relaetd details
        for(Commissioning_Report__c jobCommObj : [Select Job_Number__r.Installation_Date__c,Job_Number__r.Named_Employee__c,
                                                  Job_Number__r.CHI_Lead__c, Job_Number__c,(Select Location__c, Serial_No__c, GC_Number__c From 
                                                  Appliances_at_Risk__r) From Commissioning_Report__c  where id IN : commIdList])
        {
            system.debug('Job_Number__c---'+jobCommObj.Job_Number__c);
            List<Diary_Entry__c> jobEntries = new List<Diary_Entry__c>([Select Week__c,Job__c,Sub_Type__c From Diary_Entry__c where job__c = :jobCommObj.Job_Number__c and Sub_Type__c ='Mechanical' limit 1]);
            system.debug('jobEntries---'+jobEntries);
            if(jobEntries.size() >0)
          {
               ID weekid= jobEntries[0].Week__c;
              System.debug('jobEntries---'+jobEntries);
              Week__c week = [Select Employee__c From Week__c where id =: weekid];
              system.debug('week---'+week);
              gasSafeReportObj.Employee__c = week.Employee__c;   
            }
           
            gasSafeReportObj.Job__c = jobCommObj.Job_Number__c;
            gasSafeReportObj.Job_Reference1__c = jobCommObj.Job_Number__r.CHI_Lead__c;
            
            system.debug('---jobCommObj.Job_Number__c:-' +jobCommObj.Job_Number__c);
            system.debug('--jobCommObj.Job_Number__r.CHI_Lead__c' +jobCommObj.Job_Number__r.CHI_Lead__c);
            
            //for each appliance details
            for(Appliance_at_Risk__c appObj : jobCommObj.Appliances_at_Risk__r)
            {
                system.debug('--appObj' +appObj);
                if(iCount ==0)
                {
                    gasSafeReportObj.Appliance__c = appObj.id;
                    gasSafeReportObj.Serial_Number_1__c = appObj.Serial_No__c ;
                    gasSafeReportObj.Location_1__c = appObj.Location__c;
                    gasSafeReportObj.GC_Number_1__c = appObj.GC_Number__c;
                }
                else if(iCount ==1)
                {   
                    gasSafeReportObj.Appliance_2__c = appObj.id;
                    gasSafeReportObj.Serial_Number_2__c = appObj.Serial_No__c ;
                    gasSafeReportObj.Location_2__c = appObj.Location__c;
                    gasSafeReportObj.GC_Number_2__c = appObj.GC_Number__c;  
                }
                else if(iCount ==2)
                {
                    gasSafeReportObj.Appliance_3__c = appObj.id;
                    gasSafeReportObj.Serial_Number_3__c = appObj.Serial_No__c ;
                    gasSafeReportObj.Location_3__c = appObj.Location__c;
                    gasSafeReportObj.GC_Number_3__c = appObj.GC_Number__c;  
                }  
                else if(iCount ==3)
                {
                    gasSafeReportObj.Appliance_4__c = appObj.id;
                    gasSafeReportObj.Serial_Number_4__c = appObj.Serial_No__c ;
                    gasSafeReportObj.Location_4__c = appObj.Location__c;
                    gasSafeReportObj.GC_Number_4__c = appObj.GC_Number__c;  
                } 
                else if(iCount ==4)
                {
                    gasSafeReportObj.Appliance_5__c = appObj.id;
                    gasSafeReportObj.Serial_Number_5__c = appObj.Serial_No__c ;
                    gasSafeReportObj.Location_5__c = appObj.Location__c;
                    gasSafeReportObj.GC_Number_5__c = appObj.GC_Number__c;  
                }
                else if(iCount ==5)
                {
                    gasSafeReportObj.Appliance_6__c = appObj.id;
                    gasSafeReportObj.Serial_Number_6__c = appObj.Serial_No__c ;
                    gasSafeReportObj.Location_6__c = appObj.Location__c;
                    gasSafeReportObj.GC_Number_6__c = appObj.GC_Number__c;  
                }             
            iCount = iCount + 1;  
            system.debug('---iCount:-' +iCount);         
            }
            
            gasSafeList.add(gasSafeReportObj);
            system.debug('--gasSafeList:-' +gasSafeList);
        }
    }
    
    //insert gas safe report object data
    if(gasSafeList.size() > 0)
    {
        try
        {
            insert gasSafeList;
        }
        catch(Exception ex)
        {
            system.debug('Exception while creating Gas safe report object:-' +ex);
        }
        
    } 
    //electrical reports
    if(gasSafeList.size() == 0)
        {
        //Getting Record Type For Elctrical installation at risk
        eleCommReportRecordTypeId = [Select r.Name, r.Id From RecordType r where 
        r.Name='Minor Electrical Installation' and SobjectType = 'Commissioning_Report__c' limit 1].Id;
        
        for(Integer i=0;i<trigger.new.size();i++)
        {
            if(trigger.new[i].status__c == 'Completed' && trigger.old[i].status__c != 'Completed' && trigger.new[i].RecordTypeId == eleCommReportRecordTypeId)
            {
                Id jobId = Trigger.new[i].Job_Number__c;        
                Id jobCompReportId = Trigger.new[i].id;
                IdList.add(jobCompReportId);
                system.debug('IdList---' +IdList);
            }
        }
        if(IdList.size() > 0)
        {       
       
        //fetching elements 
            for(Commissioning_Report__c crobj :[Select Job_Number__r.Contractor_Installation_Hours__c,Job_Number__r.Named_Employee__c, 
                                                      Job_Number__r.CHI_Lead__c,Job_Number__r.Installer_Notes__c,Job_Number__r.Named_Employee__r.Resource_Id__c,
                                                      Job_Number__r.Named_Employee__r.End_Date__c,Job_Number__c From Commissioning_Report__c  where id IN : IdList])
            {
                
                List<Diary_Entry__c> jobEntries = new List<Diary_Entry__c>([Select Week__c,Job__c,Sub_Type__c From Diary_Entry__c where job__c = :crobj.Job_Number__c and Sub_Type__c ='Electrical' limit 1]);
                if(jobEntries.size() >0)
            {
                 ID weekid= jobEntries[0].Week__c;
                System.debug('jobEntries---'+jobEntries);
                Week__c week = [Select Employee__c From Week__c where id =: weekid];
                system.debug('week---'+week);
                ELESCSAobj.Employee__c = week.Employee__c;   
              }
                ELESCSAobj.Job__c = crobj.Job_Number__c;
                ELESCSAobj.YourJobReference__c = crobj.Job_Number__r.CHI_Lead__c;
                system.debug('--crobj.Job_Number__r.Named_Employee__c' +crobj.Job_Number__r.Named_Employee__c);
                system.debug('--crobj.Job__r.CHI_Lead__c' +crobj.Job_Number__r.CHI_Lead__c);        
                ELESCSAlist.add(ELESCSAobj);    
            }
        }
        
        system.debug('List of ELESCSAlist-->' +ELESCSAlist);
        
        //inserting object
        if(ELESCSAlist.size()>0)
        {
            try{
                  insert ELESCSAlist;
               }
               catch(Exception ex)
               {
                system.debug('Exception while creating report object:-' +ex);
               }
            
        } 
        }

    }
}