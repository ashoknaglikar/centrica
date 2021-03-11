@RestResource(urlMapping='/confirmJobBooking/*')
global class customerPortalBookJobAPI {
    
    @HttpPost    
    global static bookJobResponse bookJob(string leadId,
                                          string quoteId, 
                                          string jobId,
                                          date installDateSelected,
                                          String installTimeSelected,
                                          String optionIDSelected,
                                          boolean bringForwardJob,
                                          string deliveryNotes,
                                          string installNotes,
                                          boolean confirmFlag,
                                          date deliveryDate,
                                          string deliverySlot)
    {
        list<Diary_Entry__c> TravelDE= new list<Diary_Entry__c>();
        system.debug('installNotes'+installNotes);
        system.debug('installDateSelected'+installDateSelected);
        system.debug('installTimeSelected'+installTimeSelected);     
        String oppId = CustomerPortalHelper.getOpportunityId(leadId); 
        
        bookJobResponse objResponse = new bookJobResponse();
        
        map<string, Search_Result__c> engSearhResultMap = new  map<string, Search_Result__c>();
        string namedElectrician;
    
       Job__c jb = [Select id,CRD_Code__c,  (Select s.Start_Date_Time__c, s.Skill__c, s.Option_Identifier__c, s.Name, s.Job_ID__c, s.Id, 
                           s.Hours__c, s.End_Date_Time__c, s.Diary_Entry_ID__c, s.Diary_Entry_ID__r.Week__r.Employee__r.Name,
                           s.Diary_Entry_ID__r.Hours__c, Own_Labour__c,s.Diary_Entry_ID__r.End__c,s.Diary_Entry_ID__r.Name, s.Diary_Entry_ID__r.Week__r.Employee__r.Postcode__c
                           ,s.Diary_Entry_ID__r.Week__r.Employee__r.Supplier_Branch_Num__c,s.Diary_Entry_ID__r.Type__c,s.Diary_Entry_ID__r.Week__r.Employee__r.Id,
                           s.Diary_Entry_ID__r.Week__r.Monday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Monday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Tuesday_Start_Time__c,
                           s.Diary_Entry_ID__r.Week__r.Tuesday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Wednesday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Wednesday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Thursday_Start_Time__c,
                           s.Diary_Entry_ID__r.Week__r.Thursday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Friday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Friday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Saturday_Start_Time__c,
                           s.Diary_Entry_ID__r.Week__r.Saturday_End_Time__c,s.Diary_Entry_ID__r.Week__r.Sunday_Start_Time__c,s.Diary_Entry_ID__r.Week__r.Sunday_End_Time__c,s.Diary_Entry_ID__r.Week__c
                           From SearchResults__r s where Option_Identifier__c = :optionIDSelected 
                           order by s.Start_Date_Time__c ASC,s.Diary_Entry_ID__r.Week__r.Employee__c, s.Skill__c), CHI_Lead__r.Install_Postcode__c,latitude__latitude__s,latitude__longitude__s from Job__c where id = :jobId];



      for(Search_Result__c s: jb.SearchResults__r)
      {                     
        if(s.Diary_Entry_ID__r.Week__r.Employee__r.Supplier_Branch_Num__c=='2017')
        {
          string EngName = s.Diary_Entry_ID__r.Week__r.Employee__r.Name;
          if(engSearhResultMap.containskey(EngName))
          {
            if(engSearhResultMap.get(EngName).Diary_Entry_ID__r.End__c <s.Diary_Entry_ID__r.End__c)
             engSearhResultMap.put(EngName, s);
          }else
          engSearhResultMap.put(EngName, s);
        }
        
        system.debug('named Electrician'+s.Diary_Entry_ID__r.Week__r.Employee__r.Id);
        if(s.Skill__c.equalsIgnoreCase('ELECTRICAL'))
        {
          namedElectrician =s.Diary_Entry_ID__r.Week__r.Employee__r.Id;
        }
      }
     
     map<string, list<string>> indayJobTime;
      // Inday Engineer Travel Code
     if(system.label.JobPlan_Eng_Travel == 'on' )
     {  
      //system.debug(Logginglevel.INFO,'I am INSIDE');
       Set<string> TravelJob = new set<string>();
       
       String jobPostCode = jb.CHI_Lead__r.Install_Postcode__c;
       if(system.label.Bing_Google_API=='Bing'&&jb.latitude__latitude__s!=null)
       JobPostCode = String.valueof(jb.latitude__latitude__s)+','+string.valueof(jb.latitude__longitude__s);
       
        indayJobTime = Utilities.calcluateIndayJobTime(engSearhResultMap.values(),JobPostCode,null);
       //system.debug(Logginglevel.INFO,'Engineer in Day Travel -->'+indayJobTime);
       /*
             Map formet for indayJobTime:
             
             Employee Name----> connecting JOB ID/Travel Time/Direction
             
       */
       
       //map<string, datetime> engEndNew  = new map<string, datetime>();
       
       
       datetime endNew;
       for(string s : indayJobTime.keyset())
       {
           
          Search_Result__c src = engSearhResultMap.get(s);
          Diary_Entry__c de = src.Diary_Entry_ID__r ;
          
          for(string r: indayJobTime.get(s))
          {
                  
                 
                  string[] infoList = r.split('/');
                  
                  decimal ttime = decimal.valueof(infoList[1]).setscale(2);
                  
                  
                  endNew = DateTimeHelper.addWorkingHoursToDateTime(engSearhResultMap.get(s).Start_Date_Time__c, double.valueof(ttime), de);
                  
                  
                  if(!TravelJob.contains(infoList[0]+s+infoList[2]))
                  {
                    Search_Result__c sr = new Search_Result__c();
                    sr.Start_Date_Time__c = src.Start_Date_Time__c;
                    sr.Skill__c = 'Travel Time';
                    sr.Option_Identifier__c = src.Option_Identifier__c;
                    sr.Job_ID__c= src.Job_ID__c;
                    sr.Hours__c= decimal.valueof(infoList[1]);
                    sr.End_Date_Time__c= endNew;
                    sr.Diary_Entry_ID__c= src.Diary_Entry_ID__c;
                    sr.order__c = infoList[2];
                    sr.Travel_Job__c = infoList[0];
                  
                    if(sr.Hours__c>Decimal.valueof(system.label.SJR_Travel_Time_Tolerance))
                    TravelJob.add(infoList[0]+s+infoList[2]);
                    Diary_Entry__c TravDE = new Diary_Entry__c();
                    if(sr.Order__c == 'Front'){
                          
                          TravDE.End__c=DateTimeHelper.addWorkingHoursToDateTime(sr.Start_Date_Time__c,Double.valueof(sr.Hours__c),de);
                          TravDE.Start__c = sr.Start_Date_Time__c;
                         
                        
                    }else{
                      
                      TravDE.Start__c = sr.End_Date_Time__c;
                      TravDE.End__c=DateTimeHelper.addWorkingHoursToDateTime(TravDE.Start__c,Double.valueof(sr.Hours__c),de);
                     
                    }
                        
                      TravDE.Week__c = de.Week__c;
                      TravDE.Travel_Job__c = sr.Travel_Job__c;
                      TravDE.RecordTypeId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Non Productive Job Booking');
                      TravDE.Sub_Type__c = 'Travel Time';
                      TravDE.Job__c =sr.Job_ID__c;
                      TravDE.Hours__c = sr.Hours__c;
                      TravelDE.add(TravDE);
                  }
                  
                  //if(TravelDE.size()>0)
                  //insert TravelDE;
          }
        }   
        
    }   
                        
        objResponse.jobId=jobId;
        objResponse.leadId=oppId;         
        objResponse.quoteId=quoteId;
         
        job__c updateJob = new Job__c(id=jobId);  
        if(optionIDSelected!=null && jb.CRD_Code__c!='Portal Planned')
        {
            if(namedElectrician!=null)
            updateJob.Named_Electritian__c = namedElectrician; 
            
            JobBookingManager.planOrReplanJob(optionIDSelected);
            
            if(installDateSelected!=null)
            {
                updateJob.Installation_Date__c = installdateSelected;                
            }
            
            queueJobPlanningOrderGenerations planAndGenerateOrder = new queueJobPlanningOrderGenerations(oppId, optionIDSelected, updateJob, TravelDE);
            // enqueue the job for processing
            ID queueId = System.enqueueJob(planAndGenerateOrder);
            
            
            if(installTimeSelected!=null)   
            {         
                updateJob.Portal_Installation_Time__c=installTimeSelected; 
                //updateJob.Delivery_Date__c = installDateSelected; // Delivery Date is same as Installation date for job planning via portal.
                //updateJob.Delivery_Slot__c = CustomerPortalHelper.getdeliverySlot(installTimeSelected);    
                updateJob.Delivery_Date__c = deliveryDate; // Delivery Date is same as Installation date for job planning via portal.
                updateJob.Delivery_Slot__c = deliverySlot;  
                updateJob.Status__c ='Planned';
                updateJob.Sub_Status__c ='Planned';  
            }         
            if(bringForwardJob!=null)
            {
                updateJob.Bring_Forward_Job__c = bringForwardJob;
            }
            updateJob.Refused_Earlier_Date__c = (bringForwardJob ==null || bringForwardJob == false) ? true:false;
            if(deliveryNotes!=null)
                updateJob.Delivery_Notes__c =deliveryNotes;
            if(installNotes!=null)
                updateJob.Installation_Special_Instructions__c = installNotes;

            updateJob.Job_Reason__c = 'Customer Requested';
            updateJob.CRD_Code__c = 'Portal Planned'; 
            
            try{
                 if(confirmFlag)
                 {
                     update updateJob;                     
                 }
        
                
             objResponse.installDate = updateJob.Installation_Date__c;
             objResponse.installTime = updateJob.Portal_Installation_Time__c;
             objResponse.deliveryDate= updateJob.Delivery_Date__c;
             objResponse.deliverySlot =CustomerPortalHelper.getdeliverySlot(installTimeSelected);
                 system.debug('@@deliverySlot '+objResponse.deliverySlot);
            }catch(Exception e){ 
                
                objResponse.errorList.add(e.getMessage() + ' Line Number:' +e.getLineNumber()); 
            }
        }
        else
        {  
            objResponse.errorList.add('There is no selected Installation Date.');           
        }
        
       system.debug('@@book job respose '+objResponse);
       system.debug('@@JSONrespone  '+JSON.serialize(objResponse));
       
       String[] s= installTimeSelected.split(':');
       integer hour =Integer.valueOf(s[0].trim()); 
       integer minute= Integer.valueOf(s[1].trim());
       integer second= 0;
       integer millisecond = 0;
       time d = time.newInstance(hour, minute, second, millisecond);
       datetime installDatetime = datetime.newInstance(installDateSelected, d);

       update (new opportunity(id=oppId, Installation_Date_Time__c=installDatetime  ));
       if(objResponse.errorList.size()>0)
       CreateEmail.CretaeSendTextEmail(new list<string>{'ashokkumar.nagaleekar@centrica.com'},JSON.serialize(objResponse), 'Error in Job Plannging' );
       return objResponse; 
    }
    
    

}