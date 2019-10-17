global class  ofsLoadBatchClass  implements database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful{
	
	//public ofsLoadBatchClass(){}
	
	global OFS_Load__c ofsLoadObj;
	
	global id AppointmentId ;
	 
	
	
	global ofsLoadBatchClass(id  Appid, OFS_Load__c ofsLoad)
	{
		AppointmentId=Appid;
		ofsLoadObj=ofsLoad;
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	
    	date ofsStartDate =  ofsLoadObj.Request_Date__c;
    	date ofsEndDate =  ofsLoadObj.Request_Date__c.addDays(1);
    	decimal visitDayOfYear = ofsLoadObj.Request_Date__c.DayofYear();
    	if(AppointmentId ==null)
        return Database.getQueryLocator('Select id, Assigned_to__r.Primary_Role__c,	X18_Digit_App_Id__c, Visit_date__c from Appointment__c where Start__c>=:ofsStartDate and End__c <= :ofsEndDate and Status__c = \'Appointed\' and Visit_Day_Of_Year__c = :visitDayOfYear and OFS_Appointment__c =true' ); //  where OFS_Keys_Status__c =:status
        else
        return Database.getQueryLocator('Select id, Assigned_to__r.Primary_Role__c,	X18_Digit_App_Id__c, Visit_date__c from Appointment__c where Id =:AppointmentId' ); //  where OFS_Keys_Status__c =:status   
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords)
    {
    	list<Appointment__c> updateList = new list<Appointment__c>();
    	for(sobject s: lstRecords)
    	{
    		Appointment__c app = (Appointment__c)s;
    		
    		datetime date_x = datetime.newinstance(app.Visit_Date__c,  Time.newinstance(00,00,00,00));
    		
    		string searchString = 'searchInField=apptNumber&searchForValue='+app.X18_Digit_App_Id__c+'&dateFrom='+date_x.format('YYYY-MM-dd')+'&dateTo='+date_x.adddays(1).format('YYYY-MM-dd');
    		searchString+='&fields=apptNumber,resourceId,date_x,status,XA_eta&limit=10';
    		
    		system.debug('searchString -->'+searchString);
    		
    		string serachResponse  = new SubPatchUpadateInOFS_Rest().searchActivities(searchString);
    		
    		if(serachResponse!=null)
    		{
	    		getActivityJSON searchJSON = getActivityJSON.parse(serachResponse);
	    		
	    		if(searchJSON.items != null)
	    		{
	    			for(getActivityJSON.cls_items cItem : searchJSON.items)
	    			{
	    				if(cItem.apptNumber == app.X18_Digit_App_Id__c )
	    				{
		    				if(cItem.XA_eta!=null && (cItem.XA_eta.contains('AM') ||cItem.XA_eta.contains('PM')))
		    				{
		    					
		    						list<string>  slist= cItem.XA_eta.split(' ');
									
									string[]  dateStrings = slist[0].split('/');
									string[]  timeStings = slist[1].split(':');
									system.debug(dateStrings);
									
									system.debug(timeStings);
									integer hr = cItem.XA_eta.contains('PM') ? integer.valueof(timeStings[0])+12 : integer.valueof(timeStings[0]);
									app.ETA_After_Optimisation__c = Datetime.newinstance(integer.valueof('20'+dateStrings[2]),integer.valueof(dateStrings[0]),integer.valueof(dateStrings[1]),hr,integer.valueof(timeStings[1]),00);
		    						system.debug(app.ETA_After_Optimisation__c);
		    				}else if(IV_Vectors__c.getInstance('ETAWorkforce_Switch').Key__c != 'on'&& cItem.XA_eta!=null )
			    			app.ETA_After_Optimisation_Text__c = cItem.XA_eta;
			    			
			    			if(cItem.resourceId!=null)
			    			app.Assigned_To__c = cItem.resourceId;
			    			updateList.add(app);
	    				}
	    			}
	    			
	    			
	    		}
	    		
	    		system.debug('Search JSON-->'+searchJSON); 
    		}
    		
    	}
    	if(updateList.size()>0)
    	update updateList;
    }
    
    global void finish(Database.BatchableContext bc)
    {
    	if(ofsLoadObj.Id!=null)
    	{
	    	ofsLoadObj.Status__c = 'Complete';
	    	ofsLoadObj.Load_Finish_Time__c = system.now();
	    	update ofsLoadObj;
	    	
	    	CreateEmail.CretaeSendTextEmail(new list<string>{userinfo.getUserEmail()}, 'Appointent update batch is now complete for the day '+ofsLoadObj.Request_date__c.format(), 'OFS Batch Complete!');
    	}
    	
    	
    	
    
    }
    
    
    
}