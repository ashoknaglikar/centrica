trigger populate_Installer_and_Create_Event on Diary_Entry__c (after insert, after update, after delete) 
{
    map<string, list<Diary_Entry__c>> weekIdDiaryEntryMap = new map<string, list<Diary_Entry__c>>();
    if(trigger.isInsert || trigger.isUpdate)
    {
        
        UnavailabilityHistoryHelper uht = new UnavailabilityHistoryHelper();
        list <Diary_Entry__c> dList = new list <Diary_Entry__c>();
        List<Installer__c> lst_Installer= new List<Installer__c> ();
        List<Event> lst_eve= new List<Event> ();
        if(trigger.isinsert)
        {
        String InsId = RecordTypeIdHelper.getRecordTypeId('Event', 'Installation');
        String unavId = RecordTypeIdHelper.getRecordTypeId('Event', 'Unavailable');
        Set<String> jobId=new Set<String>{};
        uht.Createhistoryrecords(trigger.new);
        
       
        for(Diary_Entry__c d: Trigger.New)
        {
            // Workday Changes start *** cognizant
            // date: 19/07/2016
            
            if(weekIdDiaryEntryMap.containskey(d.Week__c))
            {
                for(Diary_Entry__c  temp : weekIdDiaryEntryMap.get(d.Week__c))
                {
                    if(temp.Start__c>d.Start__c)
                    {
                        weekIdDiaryEntryMap.get(d.Week__c)[0] = d;
                    }
                    if(temp.End__c<d.End__c)
                    {
                        weekIdDiaryEntryMap.get(d.Week__c)[1] = d;
                    }
                }
                
            }else
            {
                weekIdDiaryEntryMap.put(d.Week__c,  new list<Diary_Entry__c>{d,d});
            }
            // Workday code changes ----- End
            
            
            if(d.Check_Job_Number__c =='False' && d.Check_Installer_type__c=='true' )
    
            {
                Installer__c obj_Installer= new Installer__c();
                obj_Installer.Job__c= d.Job__c;
                obj_Installer.User__c= d.Employee_Salesforce1_ID__c;
                obj_Installer.Type__c= d.Type__c;
                obj_Installer.Sub_Type__c= d.Sub_Type__c;
                obj_Installer.Name = d.Sub_Type__c;
                obj_Installer.Diary_Entry__c = d.Id;
                //Added as a part of Phase 5
                obj_Installer.Installer_Status__c='Active';
                obj_Installer.Start_Date__c=d.Start__c;
                obj_Installer.End_Date__c=d.End__c;
                if(d.Own_Labour__c >0.0)
                obj_Installer.Own_Labour__c=true;
                //---------------------------
                System.debug('obj_Installer: '+obj_Installer);    
                lst_Installer.add(obj_Installer);
                Event obj_eve= new Event();
                obj_eve.recordtypeId= InsId;
                String Sub = d.Job_Account_Name__c+':'+d.Customer_Telephone_Number__c+':'+'['+d.Sub_Type__c +':'+d.Job_Time_Break_down__c+']';
                String Sub1;
                if (Sub.length()>80) {
                    Sub1=Sub.substring(0,79);
                } else {
                    Sub1=Sub;
                }
                obj_eve.Subject = Sub1 ;
                obj_eve.Whatid = d.Job__c;
                obj_eve.OwnerId= d.Employee_Salesforce1_ID__c;
                obj_eve.Type__c= d.Type__c;
                obj_eve.Skill__c = d.Sub_Type__c;
                obj_eve.whoid = d.Customer_Name__c;
                obj_eve.StartDateTime= d.Start__c;
                obj_eve.EndDateTime= d.End__c;
                obj_eve.status__c = 'Appointed';
                obj_eve.Diary_Entry_ID__c = d.Id;
                System.debug('obj_eve: '+obj_eve);    
                lst_eve.add(obj_eve);
               
                
            }
           
            /*if(d.Record_Type__c == 'Unavailability' && d.Sub_Type__c!='Weekend unavailability' && d.Employee_Salesforce1_ID__c!='0')
            {
                Event obj_eve= new Event();
                obj_eve.recordtypeId= unavId;
                obj_eve.Subject = 'Unavailability' ;
                obj_eve.Whatid = d.Id;
                obj_eve.OwnerId= d.Employee_Salesforce1_ID__c;
                obj_eve.Type__c= d.Type__c;
                //obj_eve.whoid = d.Employee_Salesforce1_ID__c;
                obj_eve.Skill__c = d.Sub_Type__c;
                obj_eve.StartDateTime= d.Start__c;
                obj_eve.EndDateTime= d.End__c;
                obj_eve.status__c = 'New';
                obj_eve.Diary_Entry_ID__c = d.Id;
                System.debug('obj_eve: '+obj_eve);    
                lst_eve.add(obj_eve);
            }*/
        }
        }
         if(trigger.isupdate)
         {
         	for(Diary_Entry__c d: trigger.new) 
         	{
    	     	if(d.Create_History__c == true && trigger.oldmap.get(d.Id).Create_History__c == false)
    	        {
    	        	dList.add(d);
    	        }
    	        // Workday Changes start *** cognizant
                // date: 19/07/2016
            
                if(weekIdDiaryEntryMap.containskey(d.Week__c))
                {
                    for(Diary_Entry__c  temp : weekIdDiaryEntryMap.get(d.Week__c))
                    {
                        if(temp.Start__c>d.Start__c)
                        {
                            weekIdDiaryEntryMap.get(d.Week__c)[0] = d;
                        }
                        if(temp.End__c<d.End__c)
                        {
                            weekIdDiaryEntryMap.get(d.Week__c)[1] = d;
                        }
                    }
                    
                }else
                {
                    weekIdDiaryEntryMap.put(d.Week__c,  new list<Diary_Entry__c>{d,d});
                }
                // Workday code changes ----- End
             	}
        }
       
        try
        {
            if(lst_eve!= null)
                insert lst_eve;
            System.debug('lst_eve: '+lst_eve);  
            if(lst_Installer!= null)
                insert lst_Installer;
            if(dList.size()>0)
              uht.Createhistoryrecords(dList);
            System.debug('obj_Installer: '+lst_Installer); 
        }
        catch(Exception exp)
        {
            System.debug('Exception'+ exp);
        }
    }else if(trigger.isDelete)
    {
        for(Diary_Entry__c d: Trigger.old)
        {
            // Workday Changes start *** cognizant
            // date: 19/07/2016
            
            if(weekIdDiaryEntryMap.containskey(d.Week__c))
            {
                for(Diary_Entry__c  temp : weekIdDiaryEntryMap.get(d.Week__c))
                {
                    if(temp.Start__c>d.Start__c)
                    {
                        weekIdDiaryEntryMap.get(d.Week__c)[0] = d;
                    }
                    if(temp.End__c<d.End__c)
                    {
                        weekIdDiaryEntryMap.get(d.Week__c)[1] = d;
                    }
                }
                
            }else
            {
                weekIdDiaryEntryMap.put(d.Week__c,  new list<Diary_Entry__c>{d,d});
            }
        }
        
    }
    
    if(weekIdDiaryEntryMap.size()>0) {//&& !lock.workday){
        
        diaryEntryTriggerHelper.processDiaryEntry(weekIdDiaryEntryMap);
        
        
    }
    
     
}