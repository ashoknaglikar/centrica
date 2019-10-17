/*
Developer : CTS
Purpose: This is the controller of Job_UnavailabilirtDispay VF page. This was added as a part of Stacked Unavailability CR. in June 2011.

This mainly deals with Unavailabilty generation and their proper maintenence. As previously we can stack one unavailability on the other Unavailabilities
and job Bookings. SO from this CR we are preventing this whenever a new unavailability is generated. PLease also see the CreateUnavailabiliyt.cls as that is the trgigger 
point for this calss.

This page displays all the unavailabilities and Jobs conflicting with the new one. And alert users to deal with them first and then generate the new unavailability.

There are some Stackable unavailability which means these can go over other unavailability or job bookings.

*/

global class job_UnavailabilityCont {
	//list of variables used.
	//This is list of inner class containiing normal unavailabilities. i.e. where isStacakable__c = flase.
	public list<unavailSelectclass> unavaila_Records {get;set;}
	//This is list of inner class containiing normal unavailabilities. i.e. where isStacakable__c = true.
	public list<unavailSelectclass> unavailastack_Records {get;set;}
	//This is list of inner class containiing Jobs Affected. 
	public list<jobDisplayClass> jobDisplaylst{get;set;}
	public boolean showUnav{get;set;}
	public boolean showJobs{get;set;}
	public string message{get;set;}
	public boolean selectAll{get;set;}
	public boolean showApplyBtn{get;set;}
	public boolean showUnavStack{get;set;}
	public boolean alreadyused{get;set;}
	public Unavailability__c unavailabiltyRecord{get;set;}
	list<Job__c> Joblst;
	list<Diary_Entry__c> JobEntrylst;
	
	//public string AmmendmentReason {get;set;}
	 
     
    
	// controller
	 
	 
         
	public job_UnavailabilityCont()
	{
		List<SelectOption> options = new List<SelectOption>();
		
		id unavailabilityId= ApexPages.currentPage().getParameters().get('s');
		//Unavailability__c unavailabiltyRecord;
		if(unavailabilityId != null)
		unavailabiltyRecord = [Select Name,Employee__c,Group__c,Start_Date_Time__c,Stackable__c,Amendment_Reason__c,
	                            End_Date_Time__c,Unavailability_Reason__c,Generated_Unavailability__c,
	                            Unavailability_Notes__c from Unavailability__c where id=:unavailabilityId limit 1];
       
       
      
       if(unavailabiltyRecord != null)
	   {
	       if(unavailabiltyRecord.Generated_Unavailability__c)
	       {
		       	alreadyused= true;
		       	message = 'Unavailability is generated for this record!';
		       	setErrorMsg();
	       }else
	       {
	       		alreadyused =false;
	       }
	       /*
	        list of list of diary entries. consolidatesList[0] contains all Unavailabilities.
	        consolidatesList[1] contains all Job Bookings.
	       */
	       	list<list<Diary_Entry__c>> consolidatesList = new list<list<Diary_Entry__c>>();
	       	consolidatesList = CreateUnavailability.segregateEntries(unavailabiltyRecord);
	       	system.debug('consolidatesList--->'+consolidatesList);
	       	//Normal Unavailabilities
	       	unavaila_Records = new list<unavailSelectclass>();
	       	
	       	//Stacked Unavailabilities
	       	unavailastack_Records = new list<unavailSelectclass>();
	       	
	       	//set to remove dulictae entries.
	       	set<Diary_Entry__c> setUnavaLst = new set<Diary_Entry__c>();
	       	if(consolidatesList.size()>0)
	       	{
		       	if(consolidatesList[0].size()>0)
		       	{
			       	for(Diary_Entry__c u : consolidatesList[0])
			       	{	
			       		setUnavaLst.add(u);
			       	}
			       	consolidatesList[0] = new list<Diary_Entry__c>();
			       	consolidatesList[0].addall(setUnavaLst);
			       	//if(consolidatesList[0].size()>0)
			       	for(Diary_Entry__c u : consolidatesList[0])
			       	{
			       		system.debug('Just Before--->'+u);
			       		
			       		//Normal Unavailabilities.
			       		if(u.IsStackable__c == false)
			       		{ 
				       		unavailSelectclass tempRecord = new unavailSelectclass(u);
				            unavaila_Records.add(tempRecord);
				            
			       		}
			       		//Stacked Unavailabilities
			       		else if(u.IsStackable__c == true)
			       		{
			       			unavailSelectclass tempRecord = new unavailSelectclass(u);
				            unavailastack_Records.add(tempRecord);
			       		}   
			       	} 
		       	}
		       	// Different alert messages in different scenarios are handled below.
		       	if(unavaila_Records.size()>0 )
		       	showUnav = true;
		       	
		       	if(unavailastack_Records.size()>0)
		       	showUnavStack = true;
		       	
		       	if(consolidatesList[0].size()==0 ||unavailabiltyRecord.Stackable__c=='Yes'&& !alreadyused)
		       	showApplyBtn = true;
		       	
		       	if((consolidatesList[0].size()==0 && unavailabiltyRecord.Stackable__c=='Yes')&& consolidatesList[1].size()!=0 && !alreadyused)
		       	{
		       		message = 'This Unavailability will be stacked on the entries conflicting!';
		       		setErrorMsg();
		       		
		       	}
		       	else if(unavailabiltyRecord.Stackable__c=='Yes' && !alreadyused && (consolidatesList[0].size()>0||consolidatesList[1].size()>0))
		       	{
		       		message='Choosen Unavailability can be Stacked!';
		       		setErrorMsg();
		       	}
		       	else if(!alreadyused && consolidatesList[0].size()>0){
		       		message = 'Please Remove existing Unavailabilities before applying new Unavailability!';
		       		setErrorMsg();
		       	}
		       	if(consolidatesList[0].size()==0 && consolidatesList[1].size()==0 && !alreadyused)
		       	{
		       		message = 'You can now generate Unavailability.';
		       		setErrorMsg();
		       	}	
		       	
		       	if((consolidatesList[0].size()==0  && unavailabiltyRecord.Stackable__c=='No')&& consolidatesList[1].size()!=0 && !alreadyused)
		       	{
		       		message = 'You can now generate Unavailability but make sure that you replan the below Jobs.';
		       		setErrorMsg();
		       	}	
		       	// List of Job Entries and Jobs affected as diplayed.
		       	list<id> jobIds = new list<id>();
		       	list<id> entryId = new list<id>();
		       	JobEntrylst = new list<Diary_Entry__c>();
		       	
		       	//set to remove duplicates.
		       	set<Diary_Entry__c> setJeLst = new set<Diary_Entry__c>();
		       	if(consolidatesList[1].size()>0)
		       	{
			       	for(Diary_Entry__c j : consolidatesList[1])
			       	{	
			       		setJeLst.add(j);
			       	}
			       	consolidatesList[1] = new list<Diary_Entry__c>();
			       	consolidatesList[1].addall(setJeLst);
			       	
			       	for(Diary_Entry__c j : consolidatesList[1])
			       	{
			       		//JobEntrylst.add(j);
			       		jobIds.add(j.Job__c);
			       		entryId.add(j.Employee__c);
			       	}
		       	}
		       	
	       	Joblst =new list<Job__c>();
	       	// fetch job details for displaying.
	       	if(jobIds.size()>0)
	       	{
	       		Joblst= [Select j.Name, j.Id, j.Installation_Date__c,Needs_Re_Planing__c,Start_Data_Time__c,Maximum_End_Date__c,(select id, Name ,Job__c,Week__c,Start__c,End__c,Record_Type__c,Sub_Type__c,Stackable__c,Employee_ID_18__c,IsStackable__c,Employee_Name__c,Employee__c,Hours__c,Amendment_Reason__c from Diary_Entries__r where (Employee__c in:entryId or Travel_Job__c in:jobIds)) From Job__c j where id in:jobIds ];
	       	
	       		list<Diary_Entry__c > TravelEntries = [select id, Name ,Job__c,Week__c,Start__c,End__c,Record_Type__c,Sub_Type__c,Stackable__c,Employee_ID_18__c,IsStackable__c,Employee_Name__c,Employee__c,Hours__c,Amendment_Reason__c,Needs_Removal_Reason__c from Diary_Entry__c where  Travel_Job__c in:jobIds];
		       	if(Joblst.size()>0)
		       	{
		       		showJobs =true;
		       		jobDisplaylst = new list<jobDisplayClass>();
		       		for(integer j=0;j<Joblst.size();j++)
		       		{
		       			jobDisplayClass tempRecord = new jobDisplayClass(Joblst[j]);
		            	jobDisplaylst.add(tempRecord);
		            	for(Diary_Entry__c d : Joblst[j].Diary_Entries__r)
		            	{
		            		JobEntrylst.add(d);
		            	}
		       		}
		       	}
		       	set<Diary_Entry__c> setEntries = new set<Diary_Entry__c>();
		       	if(TravelEntries.size()>0)
		       	{
		       		JobEntrylst.addall(TravelEntries);
		       		for(Diary_Entry__c d: JobEntrylst)
		       		setEntries.add(d);
		       	}
		       
		       if(setEntries.size()>0)
		       {	
		       	//Make Unique list
		       	JobEntrylst = new list<Diary_Entry__c>();
		       	JobEntrylst.addall(setEntries);
		       }	
		       	
		 
		       	
	       	}
	       	}  	
	       }                                                  
	}
	/*
	Method Name :RemoveUnavilabilities()
	
	This method Removes the selectted unavailabilities and generates the required availability as per its week and shiftpattern. 
	This is sam e logic as presently in the system. 
	
	*/
	
	public pagereference RemoveUnavilabilities()
	{
		unavaila_Records.addall(unavailastack_Records);
		list<Diary_Entry__c> selectedUnav = new list<Diary_Entry__c>();
		set<Diary_Entry__c> selectedUnavSet = new set<Diary_Entry__c>();
	
		list<Diary_Entry__c> dList= new list<Diary_Entry__c>();
		
		
		
		
		for(unavailSelectclass u: unavaila_Records)
		{
			if(u.isSelected == true)
			{
			selectedUnav.add(u.unava_Entry);
			selectedUnavSet.add(u.unava_Entry);
			system.debug('Seleted Entry-- >'+u.unava_Entry+ u.unava_Entry.Unavailability_History_Trackers__r);
			if(u.unava_Entry.Unavailability_History_Trackers__r.size() > 0 && u.unava_Entry.Unavailability_History_Trackers__r[0].id!=null)
			{
				
				if(u.unava_Entry.Needs_Removal_Reason__c == 'Yes')
				{
					u.unava_Entry.Amendment_Reason__c = u.AmmendmentReason;
					dList.add(u.unava_Entry);
				}else
				{
					u.unava_Entry.Authoriser__c = u.AmmendmentReason;
					dList.add(u.unava_Entry);
				}
			}
			    
			}
		}
		list<Unavailability__c> unAvail = new list<Unavailability__c>();  
		if(selectedUnavSet.size()==0)
		{
			message= 'Please Select atleast one Entry.';
        	setErrorMsg();
        	return null;
		}
	    unAvail = RegenrateAvailabilty.retriveunavailability(selectedUnav);                                  
	    set<Unavailability__c> updateUnAvail = new set<Unavailability__c>();    
	                         
        for(Unavailability__c un : unAvail){
                
            un.Remove_Unavailability__c = true;
            updateUnAvail.add(un);
        }
        
        
        
        if(updateUnAvail.size()>0){
        try {
        	unAvail = new list<Unavailability__c>();  
        	unAvail.addall(updateUnAvail);
            update unAvail;
            }
        	catch(DMLexception e){
        
                system.debug('----EXCEPTION ----'+e);
          	}
        }
        if(selectedUnav.size()>0){
        try {
        	selectedUnav = new list<Diary_Entry__c>();
        	selectedUnav.addall(selectedUnavSet);
            delete selectedUnav;
            
            UnavailabilityHistoryHelper uht = new UnavailabilityHistoryHelper();
            system.debug('Dlist-->'+dList);
            uht.Removeunavailabilty(dList);
            
            }
            catch(DMLexception e){
        
                system.debug('----EXCEPTION ----'+e);
        
           		}
        	}
		
		return null;
	}
	/*
	method name:generateUnavailability()
	
	This method has logic to generate the new unavailability.This is same as class CreateUnavailability just a little diff before generaunting.
	It has two parts i.e. if the unavailability being generated is Stackable,then we just stack this Unavailability on all the present diary entries. 
	and we dont touch even the job bookings. we just generate as we used to do previosly.
	
	If the unavailability being generated is non stackable then, we ask user to first remove all of the unavaliabilities present and 
	then generate. but in this case we remove all Job Bookings present in our code  and we mark all these Jobs for replanning.
		
	*/
	 public pagereference generateUnavailability(){
	 		
    	string poolDiariesMessage;
    	List<Diary_Entry__c> unAvailabilities = new List<Diary_Entry__c>();
    	Savepoint  sp;
    	
    	 
    	if(unavailabiltyRecord.Start_Date_Time__c >= unavailabiltyRecord.End_Date_Time__c){
        	
        	message= 'Unavailability start time should be less than end time.';
        	setErrorMsg();
        	return null;
        }
        
        
        
        
        poolDiariesMessage = '';
        
        if(unavailabiltyRecord.Generated_Unavailability__c){
        	
         message= 'This unavailability record has already been used. Please uncheck the Generated Unavailability checkbox, modify this record as required and try again.';
         setErrorMsg();
         return null;	
        }
        // If non Stacakable the mark Jobs for replanning.
        if(unavailabiltyRecord.Stackable__c == 'No')
	       {
	       		boolean flag = markJobsForReporting(Joblst,JobEntrylst);
	       		if(flag == false)
	       		{
	       			message= 'Error while generating Unavailability';
	       			setErrorMsg();
	       			return null;
	       		}	
	       		
	       }
        
        unavailabiltyRecord = [Select Employee__c,Group__c,Start_Date_Time__c,opportunity__r.CHI_Lead_Id__c,
                                                        End_Date_Time__c,Unavailability_Reason__c,Generated_Unavailability__c,
                                                        Unavailability_Notes__c,Type__c,Amendment_Reason__c,History_Track__c,Labour_type__c  from Unavailability__c where ID = :unavailabiltyRecord.Id limit 1];
                                                                            
                                                    
        Map<ID,List<Diary_Entry__c>> weekEntry = CreateUnavailability.getWeekEntries(unavailabiltyRecord);
        
        if(weekEntry.size()==0){
        	
        	message = 'Unavailability not generated as there are no weeks existing between mentioned duration for unavailability OR you are trying to generate unavailability for pool employees.';
        	setErrorMsg();
        	return null;
        }
        
        CreateUnavailability.UnavailMode = 'new'; 
        weekEntry = CreateUnavailability.mergeGapJobBookings(unavailabiltyRecord,weekEntry);
        
        unAvailabilities = CreateUnavailability.generateUnavailabilities(unavailabiltyRecord,weekEntry);
        
        // Create a savepoint because the data should not be committed to the database in case of failure
      
        sp = Database.setSavepoint();
        
        try{      
        		
        	       // Calling Ray Holder's Code Here.
        	       UnavailabilityManager.createUnavailability(unAvailabilities);
            	
           }catch(Exception excp){
            		
              // Revert the database to the original state
              Database.rollback(sp);
              message = 'Error occured while generating unavailability.';
              setErrorMsg();
              return null;		
           }       
        
        unavailabiltyRecord.Generated_Unavailability__c = true;
      
        update unavailabiltyRecord;
        
        if(poolDiariesMessage.length()>10){
        	
        	message= poolDiariesMessage;
        	setErrorMsg();
        	return null;
        }
        
        message= 'Unavailabilty generated succesfully.';
        setErrorMsg();
        return null;
        
    }
    /* method name :markJobsForReporting
    
     method to convert the Job bookings in to Availability and Mark the Jobs which are being converted.
     
    */
    public boolean markJobsForReporting(list<Job__c> Jobslst, list<Diary_Entry__c> JobsEntrylst)
    {
    	for(Job__c j:Jobslst)
    	{
    		if(j.Needs_Re_Planing__c == false)
    		j.Needs_Re_Planing__c = true;
    	}
    	try{
    		update Jobslst;
    		if(unavailabiltyRecord.Group__c!=null)
    		{
    			id unavailId = RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Unavailability');
    			set<Diary_Entry__c> jeSet=new set<Diary_Entry__c>();
    			for(Diary_Entry__c d:JobsEntrylst)
    			{
    				d.RecordTypeId = unavailId;
    				jeSet.add(d);
    			}
    			JobsEntrylst =new list<Diary_Entry__c>();
    			JobsEntrylst.addall(jeSet);
    			update JobsEntrylst;
    			delete JobsEntrylst;
    			return true;
    		}else
    		{
	    		set<Diary_Entry__c> jeSet=new set<Diary_Entry__c>();
				for(Diary_Entry__c d:JobsEntrylst)
				{
					jeSet.add(d);
				}	
				JobsEntrylst =new list<Diary_Entry__c>();
				JobsEntrylst.addall(jeSet);
    		JobBookingManager.removeMultipleDiaryEntries(JobsEntrylst, false);
    		//delete JobsEntrylst;
    		return true;
    		}
    	}catch(Exception e)
    	{
    		system.debug('Exception while marking the Job'+e);
    		return false;
    	}
    	
    	
    }
    
	// Method which handles the select all checkbox of VF page. 
	
	public PageReference selectAll(){
        
        if(this.selectAll != null){
            for(unavailSelectclass u : unavaila_Records)
                u.isSelected = selectAll;
             for(unavailSelectclass u : unavailastack_Records)
                u.isSelected = selectAll;    
        }
        
        
        return null;      
    }
	// Inner class ro dislpay Unavailabilities.
	public class unavailSelectclass
    {	
    	
    	public string AmmendmentReason {get;set;}
    	
    
    	
    
  	List<selectoption> options = new List<selectoption>();
      
	public List<selectoption> getAuthoriserReasonOptions(){
		
		
         return options;
	 }
	 
        public Diary_Entry__c unava_Entry{get; set;}
        public Unavailability_History_Tracker__c uh{get;set;}
        public Boolean isSelected { get; set; }
        public boolean isDisabled {get; set;}
        
        public unavailSelectclass(Diary_Entry__c u) {
        	
        
        	
              unava_Entry= u;
              isSelected = false;
              isDisabled = true;
              
              
              if(u.Needs_Removal_Reason__c == 'Yes')
              {
              	
            	Schema.DescribeFieldResult AmmendmentField = Diary_Entry__c.Amendment_Reason__c.getDescribe();
          		List <Schema.PicklistEntry>  picklistskills = AmmendmentField.getPicklistValues();
         		for(Schema.PicklistEntry p : picklistskills)
		        {    
		            Options.add(new SelectOption(p.getLabel(),p.getLabel()));
		            
		        } 
		       
             }
             else
              {
	              	
			        Schema.DescribeFieldResult AuthoriserField = Diary_Entry__c.Authoriser__c.getDescribe();
			        List <Schema.PicklistEntry>  picklistskills = AuthoriserField.getPicklistValues();
			        for(Schema.PicklistEntry p : picklistskills)
			        {    
			            Options.add(new SelectOption(p.getLabel(),p.getLabel()));
			        } 
			        
			       
			         
              }

     }
     
     
    }
   
    // inner class to display Jobs.
    public class jobDisplayClass
    {
        public Job__c job{get; set;}
        public string startTime { get; set; }
        public string endTime {get; set;}
        public string instDate {get; set;}
        public string employeeName {get; set;}
        public jobDisplayClass(Job__c j) {
              job= j;
              if(job.Start_Data_Time__c!=null)
              startTime = job.Start_Data_Time__c.format();
              if(job.Maximum_End_Date__c!=null)
              endTime = job.Maximum_End_Date__c.format();
              instDate = job.Installation_Date__c.format();
              employeeName=job.Diary_Entries__r[0].Employee_Name__c;
              
        }           
        
    }
    // Method to set error message.
    public void setErrorMsg()
    {
        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.info, message);
        ApexPages.addMessage(msg);
    }

 

}