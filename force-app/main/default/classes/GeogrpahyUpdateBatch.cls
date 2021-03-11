/*
	Author: Cognizant (01/12/2011)
	description: This class is used for Updating geogrpahy for Brook project in dec 2011. In future if there are any future geography changes then this  
	class needs to updated.
	
	This class has 4 different methods to take back up and reclaculate New geography.
	 
	This class fetches all the work in progress jobs and accounts with future appointments. It copies present district and region from Account to 
	Old Region Id and Old District Id and calcluates the new geography.
	********************* VERY IMPORTANAT***********************************************************
	Please note to follow these steps to carry out the geography change in the same order :
	1) set GeographyBatchContext to "Job BackUP" and run the batch to copy the present geography for work in progress Jobs.
	2) set GeographyBatchContext to "Appointment BackUp" and run the batch to copy present geo for accounts with future appointments.
	3) set GeographyBatchContext to "Job Derive" and run the batch to drieve the new geography for Work in Progress jobs,Accounts and leads .
	4) set GeographyBatchContext to "Appointment Derive" and run the batch to drieve the new geography for Accounts and CHI leads where there are future Appointments 
*/
global class GeogrpahyUpdateBatch implements Database.Batchable<sObject> {
	
	public string qurey='';
	//This class was commented as this was used only once and never used again. This class was delaying deployement process.
	public static void createGeogrpahyUpdateBatch()
    {
        GeogrpahyUpdateBatch objGeoUpd = new GeogrpahyUpdateBatch();
        ID batchprocessid = Database.executeBatch(objGeoUpd,integer.valueof(system.label.GeoGraphy_batch_Size));
    }
    // different variables used to quey correct data.
    string CreatedDateStrng = system.label.Created_Date;
    Date StartDate = date.valueOf(CreatedDateStrng);  
    string visitDateStrng = system.label.GeoBatchVisitDate;
    Date EndDate = date.valueOf(visitDateStrng);
    
	// custom label GeographyBatchContext is used to run the same class in differnt context. this can be further used in fuftuer if there are any.
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	 //string qurey='';
    	 if(system.label.GeographyBatchContext == 'none')
    	 qurey = 'Select o.StageName, o.Last_Installation_Date__c, o.Id,DistrictName_Sales__c, o.CreatedDate, o.Account.Old_District_ID__c, o.Account.Old_Region_ID__c, o.Account.Sales_Subpatch__c, o.Account.Sales_Region__c, o.Account.Sales_District__c, o.Account.ShippingPostalCode, o.Account.Id, o.AccountId, Account.BillingPostalCode From Opportunity o limit 1';
         else if(system.label.GeographyBatchContext == 'Appointment BackUp' || system.label.GeographyBatchContext == 'Appointment Derive')
         qurey = 'Select o.StageName, o.Last_Installation_Date__c, o.Id, o.CreatedDate, o.Account.Old_District_ID__c, o.Account.Old_Region_ID__c, o.Account.Sales_Subpatch__c, o.Account.Sales_Region__c, o.Account.Sales_District__c, o.Account.ShippingPostalCode, o.Account.Id, o.AccountId, Account.BillingPostalCode From Opportunity o where StageName != \'Closed Lost\' AND StageName != \'Closed Won\' AND StageName != \'Expired\' AND CreatedDate >= :StartDate And CreatedDate <= :EndDate';
         else if(system.label.GeographyBatchContext == 'Job BackUP' || system.label.GeographyBatchContext == 'Job Derive')
         qurey='Select District__c, District_Name__c,Region__c,Install_Postcode__c,CHI_Lead__c, Account_Id__c From Job__c '+label.jobGeogrphyQuery+' CreatedDate >= :StartDate And CreatedDate <= :EndDate and Install_Postcode__c != null';
         if(system.label.GeographyBatchContext == 'Appointment BackUp' || system.label.GeographyBatchContext == 'Appointment Derive')
         {
	     	 if(system.label.inculdePreDerived == 'yes')
	         qurey+=' And Account.Geography_Derived__c=true';
	         else if(system.label.inculdePreDerived == 'no')
	         qurey+=' And Account.Geography_Derived__c=false';
	         if(system.label.inculdePBackup == 'yes')
	         qurey+=' And Account.Geography_Backup__c=true'; 
	         else if(system.label.inculdePBackup == 'no')
	         qurey+=' And Account.Geography_Backup__c=false';
    	}else if(system.label.GeographyBatchContext == 'Job BackUP' || system.label.GeographyBatchContext == 'Job Derive')
    	{
	    	 if(system.label.inculdePreDerived == 'yes')
			 qurey+=' And CHI_Lead__r.Account.Geography_Derived__c=true';
	         else if(system.label.inculdePreDerived == 'no')
	         qurey+=' And CHI_Lead__r.Account.Geography_Derived__c=false';
	         if(system.label.inculdePBackup == 'yes')
	         qurey+=' And CHI_Lead__r.Account.Geography_Backup__c=true'; 
	         else if(system.label.inculdePBackup == 'no')
	         qurey+=' And CHI_Lead__r.Account.Geography_Backup__c=false';
    		
    	}
         return Database.getQueryLocator(qurey);
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> contextRecord)
    {
    	cls_IsRun.setgeneralTriggerSwitch();
    	list<Job__c> updatingJobs = new list<Job__c>();
    	list<Opportunity> updatingAccounts = new list<Opportunity>();
    	for(sObject sObj : contextRecord)
        {
        	if(system.label.GeographyBatchContext == 'Job BackUP' || system.label.GeographyBatchContext == 'Job Derive')
        	{
        		Job__c j = (Job__c)sObj;
        		updatingJobs.add(j);
        	}
        	else if(system.label.GeographyBatchContext == 'Appointment BackUp' || system.label.GeographyBatchContext == 'Appointment Derive')
        	{
        		Opportunity a = (Opportunity)sObj;
        		updatingAccounts.add(a);
        	}
        }
        if(system.label.GeographyBatchContext == 'Job BackUP')
        {
        	takeGeogrphyJobbackup(updatingJobs);
        }else if(system.label.GeographyBatchContext == 'Appointment BackUp')
        {
        	takeAppointmentBackup(updatingAccounts);
        	
        }else if (system.label.GeographyBatchContext == 'Job Derive')
        {
        	deriveNewGeoforJob(updatingJobs);
        }else if(system.label.GeographyBatchContext == 'Appointment Derive')
        {
        	deriveNewGeoforAcc(updatingAccounts);
        }
    	
    }
    // Copies the old geogrphy for Work In Progress jobs
    public void takeGeogrphyJobbackup(list<Job__c> updatingJobs)
    {
    	set<Account> updatingAccount = new set<Account>(); 	
    	list<Opportunity> updatingOppos = new list<Opportunity>(); 	
    	for(Job__c j: updatingJobs)
		{
			if(j.Account_Id__c != null)
			{
			    Account a = new Account (id = j.Account_Id__c,Old_District_ID__c = j.District_Name__c,Old_Region_ID__c = j.Region__c,Geography_Backup__c=true);
			    updatingAccount.add(a);
			}
		   	
		}
		try{
			if(updatingAccount.size()>0)
			{
				update (new list<Account>(updatingAccount));
			}
		}catch(Exception e)
		{
			system.debug('Exception occured in Taking job Backup :'+e);
			CreateEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'}, e.getMessage(), 'Exception in '+system.label.GeographyBatchContext);
		}
    }
    
    public void DeriveNewGeoforJob(list<Job__c> updatingJobs)
    {
    	set<Account> updatingAccount = new set<Account>(); 	
    	set<Opportunity> updatingOppos = new set<Opportunity>(); 	
    	Map<string, id> postcodeDistrictId = new Map<string, id>();
		//map<string, id> postcodeSunptchId = new map<string, id>();
		list<string> postcodesector = new list<string>();
		
		for(Job__c j: updatingJobs)
		{
		    system.debug('---->'+j.Install_Postcode__c+ j.id);
		    postcodesector.add(j.Install_Postcode__c.substring(0,j.Install_Postcode__c.length()-2));
		}  
		list<Postcode_Sector__c> plist =  [Select Name,p.Type__c, p.Sub_Patch__r.District__c, p.Sub_Patch__c, p.Code__c From Postcode_Sector__c p where Name in : postcodesector and  Type__c ='Installation'];
		for(Postcode_Sector__c p :plist)
		{
		    if(p.Type__c == 'Installation')
		    {
		        if(!postcodeDistrictId.containsKey(p.Name))
		        {
		            postcodeDistrictId.put(p.Name,p.Sub_Patch__r.District__c);
		        }
		    } 
		}    
		for(Job__c j: updatingJobs)
		{
		    
		    if(j.Account_Id__c!=null)
		    {
				Account a = new Account (id = j.Account_Id__c,Patch_ID__c =null,Water_Hardness__c =null,Sales_Subpatch__c =null,Geography_Derived__c= true);
				updatingAccount.add(a);
		    }
		    if(j.CHI_Lead__c != null)
		    {
		    	Opportunity o = new Opportunity(id = j.CHI_Lead__c);
		   		updatingOppos.add(o);	
		    }	
		    j.District__c = postcodeDistrictId.get(j.Install_Postcode__c.substring(0,j.Install_Postcode__c.length()-2));
		}
		try{
			if(updatingJobs.size()>0)
				database.update( updatingJobs,false);
			if(updatingAccount.size()>0)	
				database.update (new list<Account>(updatingAccount),false);
			if(updatingOppos.size()>0)	
				database.update (new list<Opportunity>(updatingOppos),false);
		}catch(Exception e)
		{
			system.debug('Exception occured in updating job with new geo  :'+e);
			CreateEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'}, e.getMessage(), 'Exception in '+system.label.GeographyBatchContext);
		}
    	
    }
    
    public void takeAppointmentBackup(list<Opportunity> updatingAccounts )
    {
    	set<Account> updatingAccount = new set<Account>(); 	
    	for(Opportunity ap: updatingAccounts)
		{
			if(ap.AccountId != null)
			{
			    Account a = new Account (id = ap.AccountId );
			    a.Old_District_ID__c = ap.Account.Sales_District__c;
			   	a.Old_Region_ID__c = ap.Account.Sales_Region__c;
			   	a.Geography_Backup__c = true;
			   	updatingAccount.add(a);
			}
		   	
		}
		try{
			if(updatingAccount.size()>0)
			{
				update (new list<Account>(updatingAccount));
			}
		}catch(Exception e)
		{
			system.debug('Exception occured in Taking Appointment backup :'+e);
			CreateEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'}, e.getMessage(), 'Exception in '+system.label.GeographyBatchContext);
		}
    }
    
    public void deriveNewGeoforAcc(list<Opportunity> updatingAccounts )
    {
        set <Account> updatingAccount = new set<Account>(); 	
    	set <Opportunity> updatingOppos = new set<Opportunity>(); 	
    	Map<string, id> postcodeDistrictId = new Map<string, id>();
		list<string> postcodesector = new list<string>();
		for(Opportunity ap: updatingAccounts)
		{
			postcodesector.add(ap.Account.BillingPostalCode.substring(0,ap.Account.BillingPostalCode.length()-2));
		}  
		list<Postcode_Sector__c> plist =  [Select Name,p.Type__c, p.Sub_Patch__r.District__c, p.Sub_Patch__c, p.Code__c From Postcode_Sector__c p where Name in : postcodesector and Type__c ='Installation'];
		for(Postcode_Sector__c p :plist)
		{
		    if(p.Type__c == 'Installation')
		    {
		        if(!postcodeDistrictId.containsKey(p.Name))
		        {
		            postcodeDistrictId.put(p.Name,p.Sub_Patch__r.District__c);
		        }
		    }  
		}    
		for(Opportunity ap: updatingAccounts)
		{
		    if(ap.AccountId!=null)
		    {
				Account a = new Account (id = ap.AccountId,Patch_ID__c =null,Water_Hardness__c =null,Sales_Subpatch__c =null,Geography_Derived__c = true );
				a.Old_District_ID__c = ap.Account.Sales_District__c;
			   	a.Old_Region_ID__c = ap.Account.Sales_Region__c;
			    updatingAccount.add(a);
		    }
		    if(ap.Id != null)
		    {
		    	Opportunity o = new Opportunity(id = ap.Id);
		   		updatingOppos.add(o);	
		    }	
		}
		try{
			if(updatingAccount.size()>0)	
				database.update (new list<Account>(updatingAccount), false);
			if(updatingOppos.size()>0)	
				database.update (new list<Opportunity>(updatingOppos), false);
		}catch(Exception e)
		{
			system.debug('Exception occured in deriving new geo for Appt  :'+e);
			CreateEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'}, e.getMessage(), 'Exception in '+system.label.GeographyBatchContext);
		}
    	
    	
    }
    global void finish(Database.BatchableContext bc){
    	
        CreateEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@yahoo.com'}, 'Complete', system.label.GeographyBatchContext+ ': Batch is complete');
       
    }
	
}