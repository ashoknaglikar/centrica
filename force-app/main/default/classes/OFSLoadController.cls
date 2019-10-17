public with sharing class OFSLoadController {
	
	public OFS_Load__c ofsLoad {get;set;}
	
	public integer totalAppointmentOnDay;
	
	public integer totalAppointmentsOnBucket;
	
	public integer totalAppointmentsToHA;
	
	list<Appointment__c> appointmentList = new List<Appointment__c>();
	
	public list<OFS_Load__c> previousRuns{get;set;}
	
	public boolean ofsButton{get;set;}
	
	public list<string> appointmentNumbers {get;set;}
	
	public boolean loadPoller{get;set;}
	
	Utilities util = new Utilities();
	
	public boolean buttonBlock {get;set;}
	
	//public string loadfromOFS{get;set;}
	
	public boolean abortButton {get;set;}
	
	//public string abortLoad {get;set;}
	
	public boolean checkBox {get;Set;}
	
	public boolean queryFromBtn {get;set;}
	
	public id batchId {get;set;} 
	
	
	ApexPages.StandardController pageConroller ; 
	
	
	
	public OFSLoadController(ApexPages.StandardController controller)
	{
		queryFromBtn = true;
		pageConroller = controller;
		ofsLoad = (OFS_Load__c)controller.getrecord();
		checkBox = false;
		buttonBlock = true;
		
		//loadfromOFS = 'Load From OFS';
		
		abortButton = false;
		//abortLoad = 'Abort Load';
		
		list<OFS_Load__c> preExisitng  = [select id ,Name, Status__c, Request_Date__c,CreatedById, CreatedDate from OFS_Load__c where Status__c = 'In Progress' order by Request_Date__c Desc];
		
		if(preExisitng.size()>0)
		{
			buttonBlock= false;
			util.setErrorMsg(false, 'System is currently working updating appointments for '+preExisitng[0].Request_Date__c.format());
			ofsLoad = preExisitng[0];
			loadPoller = true;
			loadAppointmentCount();
		}
		
		
		
		try{
		previousRuns = new list<OFS_Load__c>([Select id, Name, Status__c,Request_Date__c, Load_Finish_Time__c, CreatedById, CreatedDate,Duration__c,Total_Appts__c  from OFS_Load__c order by Load_Finish_Time__c DESC limit 5 ]);
		}catch(exception e)
		{
			
		}
		
		appointmentNumbers = new list<string> {'0', '0','0'};
		
		//loadAppointmentCount();
		
	}
	
	public void querySalesforce()
	{
		
		loadAppointmentCount();
		
		if(totalAppointmentOnDay>0 && totalAppointmentsOnBucket >0 )
		{
		
			//insert ofsLoad;
			ofsButton = true;
		}else
		{
			util.setErrorMsg(true, 'No valid appointments available in bucket for requested date to fetch the details.');
		}
	}
	
	
	
	
	public void loadAppointmentCount()
	{
		totalAppointmentOnDay = 0;
		totalAppointmentsOnBucket = 0;
		totalAppointmentsToHA = 0;
		
		decimal visitDayOfYear = ofsLoad.Request_Date__c.DayofYear();
		
		
		
		appointmentList = [Select id, Assigned_to__r.Primary_Role__c from Appointment__c where OFS_Appointment__c = true and 
																					Start__c>=:ofsLoad.Request_Date__c and 
																					End__c <= :ofsLoad.Request_Date__c.adddays(1) and
																					Status__c = 'Appointed' and
																					Visit_Day_Of_Year__c = :visitDayOfYear and
																					OFS_Appointment__c = true
																					];
		totalAppointmentOnDay =  appointmentList.size();
		for(Appointment__c app: appointmentList)
		{
			if(app.Assigned_to__r.Primary_Role__c == 'OFS Bucket')
			{
				totalAppointmentsOnBucket++;
			}else{
				totalAppointmentsToHA ++;
			}
		}
		
		appointmentNumbers = new list<string> {string.valueof(totalAppointmentOnDay), string.valueof(totalAppointmentsOnBucket),string.valueof(totalAppointmentsToHA)};
		
		queryRecord();
		
		if(ofsLoad.Status__c == 'Complete')
		{
			loadPoller = false;
			util.setErrorMsg(false, 'Load is now complete.');
		}
		
	}
	
	
	public void invokeBatch()
	{
		/*if(!buttonBlock && !checkBox)
		{
			util.setErrorMsg(true, 'Please confirm by checking the confrim checkbox & then click Load From OFS button.');
		}*/
		
		//else 
		if( checkBox)
		{
			try{
				util.setErrorMsg(false, 'System is now updating appointments. You will see the progress below..');
				loadPoller = true;
				buttonBlock = false;
				ofsLoad.Total_Appts__c = totalAppointmentOnDay;
				ofsLoad.Total_In_Bucket__c= totalAppointmentsOnBucket;
				ofsLoad.Total_Appts_To_HA__c = totalAppointmentsToHA;
				
				pageConroller.save();
				
				ofsLoad = (OFS_Load__c)pageConroller.getRecord();
				
				queryRecord();
				
				ofsLoadBatchClass objLoad = new ofsLoadBatchClass(null, ofsLoad);
				//ofsLoadBatchClass objLoad = new ofsLoadBatchClass('a0B7E000001vaUSUAY', ofsLoad);
				batchId = Database.executeBatch(objLoad,10);
				
				//abortLoad = 'Abort Load';
				abortButton = true;
				ofsButton = false;
				}catch (exception e)
				{
					loadPoller = false;
				}
		}else if(!checkBox)
		{
			Time myTime = Time.newInstance(0, 0, 0, 0);

			DateTime dt = DateTime.newInstanceGMT(ofsLoad.Request_Date__c, myTime);
			String Day = dt.format('EEEE');
			//loadfromOFS = 'Start the load For '+Day+' the '+ofsLoad.Request_Date__c.format();
			buttonBlock = false;
			ofsButton = true;
			//abortButton = true;
			queryFromBtn = false;
			util.setErrorMsg(true, 'You are trying to load the Appointments for '+Day+' the '+ofsLoad.Request_Date__c.Format()+'!   Please confirm my checking the confirm checkbox below & click button Load from OFS button.');
			
		}	
	}
	
	public void queryRecord()
	{
		if(ofsLoad.Id!=null)
		ofsLoad = [Select id, Name, Status__c,Request_Date__c, Load_Finish_Time__c, CreatedById, CreatedDate, Duration__c from OFS_Load__c Where id = :ofsLoad.Id];
	}
	
	boolean abortCheck = false;
	public void abortBatch()
	{
		
		if(!abortCheck)
		{
			util.setErrorMsg(true, 'Note! are you Sure? Beaware any updates already  made will not be rolled back. Click Abort button again to abort the load.');
			
			//abortLoad = 'Yes! I want to Abort & I understand that updates already made to Appointments will not be rolled back.';
			
			abortCheck = true;
			
		}else if(abortCheck){
			try{
			
				if(batchId!=null)
				{
					system.abortJob(batchId);
					loadPoller = false;
					
					ofsLoad.Status__c = 'Cancelled';
					update ofsLoad;
					util.setErrorMsg(true, 'Sucessfully Aborted!');
					abortButton = false;
				}
				
			}catch (Exception e)
			{
				
			}
			
		}
		
		
		
		
	}
	
	public pagereference backBtn()
	{
		pagereference p  = new pagereference ('/apex/ofsLoadPage');
		p.setredirect(true);
		return p;
	}
	
	
    
}