/*
	Author: Cognizant Oct-2013
	Description: This class is controller for Week Reserve Page. It is used to update weeks 
	with locking category & Release Date. Puprpose of this is to reserve some engineers diary to 
	be available for only certain category of Leads. 
	
	This class done hold the logic to job booking, this class just updates the Week. 

*/

public with sharing class WeekReserver {
	
	
	//public list <weekClass> unReservedWeeksCls {get;set;}
	//public list <weekClass> reserevedWeeksCls {get;set;}
	public list <Week__c> unReservedWeeks {get;set;}
	public list <Week__c> reserevedWeeks {get;set;}
	public boolean resr{get;set;}
	public boolean Unresr{get;set;}
	public boolean erBln {get;set;}
	public Week__c wk{get;set;}
	public string districtId {get;set;}
	list<Id> EmployeeIds = new list<Id>();
	Utilities util = new Utilities();
	public Date weekCommencing{get;set;}
	public boolean shwSave{get;set;}
	public boolean confirm {get;set;}  
    public boolean showConfirm {get;set;}
    
    
	//Load Installtion Disctricts.
	public List<SelectOption> getAreaItems() {
	    List<SelectOption> options = new List<SelectOption>();
	    options.add(new SelectOption('','--None--'));
	    for (District__c d: [Select Id, Name from District__c where Type__c ='Installation' order by Name])
	    {                             
	        options.add(new SelectOption(d.Id,d.Name));
	    }                                               
	    return options;
    }
  
	public WeekReserver()
	{
		//unReservedWeeksCls = new list<weekClass>();
		//reserevedWeeksCls = new list<weekClass>();
		resr=false;
		Unresr=false;
		erBln = false;
		unReservedWeeks = new list<Week__c>();
		wk = new Week__c();
		reserevedWeeks = new list<Week__c>();
		confirm =false;
		showConfirm = false;
		id District = ApexPages.currentPage().getParameters().get('area');
        string weekComm = ApexPages.currentPage().getParameters().get('wkComm');
        
        if(weekComm!=null)
        {
        	string[] temp = weekComm.split('/');
        	weekCommencing= (date.valueof(temp[2]+'-'+temp[1]+'-'+temp[0])).tostartofweek();
        	wk.Week_Commencing__c = weekCommencing;
        }else if(wk.Week_Commencing__c!=null)
        {
        	weekCommencing = wk.Week_Commencing__c.toStartOfWeek();
        }else
        {
        	weekCommencing = system.today().toStartOfWeek();
        	wk.Week_Commencing__c = weekCommencing;
        	
        }
        system.debug('District--->'+districtId +District);
        if(districtId!='' && District!=null)
        {
        	DistrictId = District;
        	
        }else
        {
        	util.setErrorMsg(true, 'Please Select a District & click refresh.');
        }
        //wk.Week_Commencing__c = system.today().toStartOfWeek();
        //weekCommencing = system.today().toStartOfWeek();
        if(weekCommencing!=null && DistrictId!=null)
        {
        	
        	for(Employee__c e : [Select Id from Employee__c where District__c =:DistrictId AND Inactive__c != true AND Works_Anywhere_in_District__c = true])
        	{
        		EmployeeIds.add(e.id);
        	}
        	
        	Date startDT = weekCommencing.toStartOfWeek();
        	Date endDT = startDT.addDays(7);
        	
        	for(Employee_Postcode_Sectors__c epcs : [Select ID, Employee__c,Name 
                                                            from Employee_Postcode_Sectors__c 
                                                            where Postcode_Sector__r.Sub_Patch__r.District__c = :districtID
                                                                    and Start_Date__c < :endDT
                                                                    and End_Date__c > :startDT]) 
	        {
	            EmployeeIds.add(epcs.Employee__c);
	        }   
        	
        	
        	for(Week__c w: [Select id,Name, Locking_Category__c, Release_Date__c, Employee__r.Name from Week__c where Week_Commencing__c = :weekCommencing and Employee__c in:EmployeeIds order by Employee__r.sortemployee__c])
        	{
        		if(w.Locking_Category__c!=null)
        		{
        			//unReservedWeeksCls.add(new weekClass(w));
        			reserevedWeeks.add(w);
        			resr=true;
        		}else
        		{
        			//unReservedWeeksCls.add(new weekClass(w));
        			unReservedWeeks.add(w);
        			Unresr=true;
        		}
        		
        	}
        	if(reserevedWeeks.size()>0 || unReservedWeeks.size()>0)
        	shwSave = true;
        	
        }
        
	}
	
	// Updates Weeks with relavent changes
	public void saveWeeks()
	{
		list<Week__c> updatingWeeks = new list<Week__c>();
		list<Week__c> nonUpdatedWeeks = new list<Week__c>();
		list<Week__c> nonUpdatedTemp1 = new list<Week__c>();
		for(Week__c w: unReservedWeeks)
		{
			if(w.Locking_Category__c!=null)
			{
				updatingWeeks.add(w);
				nonUpdatedTemp1.add(w);
				
				if(!confirm && w.Release_Date__c==null)
				{
					w.Release_Date__c = weekCommencing.addDays(365);
					util.setErrorMsg(false, 'One or more Weeks hasnt got the Release Date. That Week will be locked for an Year! Please confirm.');
					showConfirm =true;
					//return;
				}
				if(w.Release_Date__c<system.today())
				{
					util.setErrorMsg(true, 'Release Date can not be in past.');
					return;
				}
			}else
			{
				resr=true;
				nonUpdatedWeeks.add(w);
			}
		}
		if(showConfirm && !confirm)
		{
			return;
		}
		
		
		list<week__c> reseTemp1= new list<Week__c>();
		list<week__c> reseTemp2 = new list<Week__c>();
		if(reserevedWeeks.size()>0)
		{
			for(Week__c w: reserevedWeeks)
			{
				
				if(w.Locking_Category__c==null)
				{
					w.Release_Date__c = null;
					reseTemp1.add(w);
				}else
				{
					reseTemp2.add(w);
				}
				
			}
			updatingWeeks.addall(reserevedWeeks);
			
		}
		
		if(updatingWeeks.size()>0)
		{
			try{
				update updatingWeeks;
				confirm =false;
				showConfirm =false;
				unReservedWeeks = new list<Week__c>();
				unReservedWeeks.addall(nonUpdatedWeeks);
				unReservedWeeks.addall(reseTemp1);
				reserevedWeeks = new list<Week__c>();
				reserevedWeeks.addall(reseTemp2);
				reserevedWeeks.addall(nonUpdatedTemp1);
				
				if(reserevedWeeks.size()==0)
				resr =false;
				
				if(unReservedWeeks.size()==0)
				Unresr =false;
				
				util.setErrorMsg(false, 'Sucessfully Saved!');
			}catch (Exception e)
			{
				System.debug('*** Exception while Saving Weeeks'+e.getmessage());
				util.setErrorMsg(true, 'Error while updating Weeks.'+e.getmessage());
			}
		}else
		{
			util.setErrorMsg(true, 'No weeks have been changed to update.');
		}
	}
	
	// Reloads the page with fresh values.
	public pagereference refersh()
	{
		if(districtId!=null && wk.Week_Commencing__c!=null)
		{
			pagereference p = new pagereference('/apex/WeekReserver?area='+districtId+'&wkComm='+wk.Week_Commencing__c.format());
			p.setRedirect(true);
			return p;
		}
		else
		{
			util.setErrorMsg(true, 'District or Week Commencing cannot be blank.');
			return null;
		}
	}
	

	// Diary View Page
	
	public pagereference openDiary()
	{
		string weeks = weekCommencing.toStartofWeek().format();
		return (new pagereference ('/apex/DiaryDisplay?week='+weeks+'&area='+DistrictId));
	}
	
		
}