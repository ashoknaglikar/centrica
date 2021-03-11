public class GetUnavailabilityController
{
	
	public list<Employee__c> empList
	{
		get;set;
	}
	
	public list<Employee_Group__c> empGroupList
	{
		get;set;
	}
	public list<UnavailWrapper> unavailWrapList
	{
		get;set;
	}
	public List<HSA_Unavailability__c> unavailOFSList
	{
		get;set;
	}
	
	public integer total_size {get;set;}
	
	public List<string> empIdList
	{
		get;set;
	}
	public HSA_Unavailability__c hsaUnavailRecord
	{
		get;set;
	}
	
	Utilities util = new Utilities();
	
	ApexPages.StandardController stdController;
	
	string mode;
	
	boolean largeMode = false;
	
	public set<string> dateStrings = new  set<string>();
    
	
	public GetUnavailabilityController(ApexPages.StandardController controller)
	{
		total_size = 0;
		hsaUnavailRecord = (HSA_Unavailability__c)controller.getRecord();
		
		stdController = controller;
		
		mode  =System.currentPageReference().getParameters().get('mode');
		
		if(hsaUnavailRecord.Status__c != 'Open' && mode != 'remove')
		{
			util.setErrorMsg(true, 'This unavailability is already applied.');
			return;
		}
		
		if(mode!=null && mode == 'remove')
		buildEmpoloyeeGroupsForSearch('remove');
		else
		buildEmpoloyeeGroupsForSearch('search');
		
		
	}
	
	public void buildEmpoloyeeGroupsForSearch(string mode)
	{
		empIdList = new  List<string>();
		unavailWrapList = new  list<UnavailWrapper>();
		
		if(hsaUnavailRecord.Employee_Group__c != null)
		{
			empGroupList = [SELECT
				id, 
				name, 
				employee__r.id, 
				employee__r.X18_Digit_Emp_Id__c, 
				Group__r.id
			FROM
				Employee_Group__c
			WHERE
				Group__c= : hsaUnavailRecord.Employee_Group__c];
				
			for(Employee_Group__c empGroup: empGroupList)
			{
				empIdList.add(empGroup.employee__r.X18_Digit_Emp_Id__c);
			}
		}
		
		
		if(hsaUnavailRecord.Employee__c != null)
		{
			
			empIdList.add([Select Id,X18_Digit_Emp_Id__c from Employee__c where Id =:hsaUnavailRecord.Employee__c ].X18_Digit_Emp_Id__c);
			
		}
		System.debug('Received the following :' + empIdList);
		string url ='searchInField=XA_SF_HSA_Record_Id&searchForValue='+hsaUnavailRecord.Name;
		
		integer empSize = empIdList.size();
		integer daysBetween = hsaUnavailRecord.Work_Time_Start__c.date().daysBetween(hsaUnavailRecord.Work_Time_End__c.date());
		
		integer numberOfCallouts= empSize*daysBetween;
		
		if(numberOfCallouts>=100)
		{
			util.setErrorMsg(true, 'Unavailability records exceed 100. Please either reduce the number of Employees within the group  or reduce the number of days within the unavailability window.');
			hsaUnavailRecord.Status__c ='Too Big';
			
			return;
		}
		
	
		if(empIdList.size() > 0 )
		{
			
			if(mode == 'search')
			{
				for(string empId: empIdList)
				{
					
					url = 'searchInField=XA_Resource_ID&searchForValue='+empId;
					searchUnavailability(empId, hsaUnavailRecord, url);
				}
			}else if(mode == 'remove')
			searchUnavailability(null, hsaUnavailRecord, url);
			
			total_size = unavailWrapList.size();
			
			
			unavailWrapList.sort();
			if(total_size>=100)
			{
				util.setErrorMsg(true, 'Only 100 unavailabilites are shown below');  
			}
		}
		
		
		
		
	}
	
	list<list<datetime>> startandEndtime;
	
	public void searchUnavailability(string empId, HSA_Unavailability__c hsaUnavailability, string url)
	{
		string dateFrom = hsaUnavailability.Work_Time_Start__c.format('yyyy-MM-dd');
		string dateTo = hsaUnavailability.Work_Time_End__c.format('yyyy-MM-dd');
		UnavailUpadateInOFS_Rest unavailRest = new  UnavailUpadateInOFS_Rest();
		string jSonList = unavailRest.searchUnavail(null, dateFrom, dateTo, url);
		UnavailWrapResp uWrapList = (UnavailWrapResp)JSON.deserialize(jSonList, UnavailWrapResp.Class);
		total_size = 0;
		
		startandEndtime = new List<list<datetime>>();
		map<string, integer> dayMap = new map<string, integer>{'Mon' => 0,'Tue'=>1, 'Wed'=>2, 'Thu'=>3, 'Fri'=>4, 'Sat'=>5, 'Sun'=>6 };
		
		if(hsaUnavailability.Type__c == 'Recurring')
		{
			date start = hsaUnavailability.Work_Time_Start__c.date().tostartofweek();
			time startTime = hsaUnavailability.Work_Time_Start__c.time();	
			time endTime = hsaUnavailability.Work_Time_End__c.time();	
			while(start<=hsaUnavailability.Work_Time_End__c)
			{
				for(string s: hsaUnavailability.Day__c.split(';'))
				{
					datetime st = datetime.newinstance(start.adddays(dayMap.get(s.trim())),startTime);
					datetime ed =datetime.newinstance(start.adddays(dayMap.get(s.trim())),endTime);
					startandEndtime.add(new List<datetime>{st, ed});
					dateStrings.add(st.format('yyyy-MM-dd'));
				}
				
				start= start.adddays(integer.valueof(7*hsaUnavailability.Weeks_Between_Occurences__c));
				
					
			}
		}
		else
		{
			integer i = 0;
			integer daysInbetween = hsaUnavailRecord.Work_Time_Start__c.date().daysBetween(hsaUnavailRecord.Work_Time_End__c.date());
			while (i <= daysInbetween)
			{
				//system.debug(hsaUnavailRecord.Work_Time_Start__c.adddays(i).format('yyyy-MM-dd'));
				dateStrings.add(hsaUnavailRecord.Work_Time_Start__c.adddays(i).format('yyyy-MM-dd'));
				i++;
			}
			startandEndtime.add(new List<datetime>{ hsaUnavailability.Work_Time_Start__c ,  hsaUnavailability.Work_Time_End__c});
		}
		
		if(uWrapList != null && uWrapList.items != null)
		{
			
			for(UnavailWrap unavailWrap: uWrapList.items)
			{
				if(unavailWrap.status == 'pending')
				{
				
					datetime unavailStart; 
					try{
						if(unavailWrap.startTime!=null)
						unavailStart = Datetime.valueOf(unavailWrap.startTime);
					}catch (Exception e)
					{
						
					}
					datetime unavailEnd;
					try{
						if(unavailWrap.endTime!=null)
							unavailEnd = Datetime.valueOf(unavailWrap.endTime);
						}catch(exception e){ 
							unavailEnd=  unavailWrap.endTime.contains(':')?null : Datetime.valueOf(unavailWrap.endTime+ ' 00:00:00');
							}
					
					for(list<datetime> datelist : startandEndtime)
					{
						if(unavailStart == null || unavailEnd== null  ||(unavailStart<=datelist[1] && unavailEnd>=datelist[0]))
						{
							UnavailWrapper availObj = new  UnavailWrapper(false, unavailWrap.activityType, unavailStart, unavailEnd, unavailWrap.activityId, unavailWrap.status, unavailWrap.resourceId);
							unavailWrapList.add(availObj);
						}
					}
					
				}
			
			}
			
		}
	}
	
	
	public void RemoveUnavail()
	{
		list<UnavailWrapper> unavailWrapLRem = new  list<UnavailWrapper>();
		unavailWrapLRem = unavailWrapList.clone();
		system.debug('*unavailWrapLRem' + unavailWrapLRem);
		for(Integer count = 0; count < unavailWrapLRem.size(); count++)
		{
			//unavailWrapLRem.add(unavailWrapLRem[count]);
			if(unavailWrapLRem[count].selectAct)
			{
				system.debug('**unavailWrapLRem[count]' + unavailWrapLRem[count]);
				UnavailUpadateInOFS_Rest unavailRest = new  UnavailUpadateInOFS_Rest();
				Integer statusCode = unavailRest.deleteActivity(string.valueOf(unavailWrapLRem[count].activityId));
				//try
				{
					if(statusCode == 204)
					{
						//unavailWrapList.remove(count);
						//total_size = unavailWrapList.size();
					}
					else{
						system.debug('error');
						util.setErrorMsg(true,'Error: Something went wrong please refer this to admin team.');
						return;
					}
				}
				//catch(Exception e)
				{
				}
			}
		}
		
		// re-search the Unavailabilites.
		buildEmpoloyeeGroupsForSearch('search');
		
		if(mode == 'remove')
		{
			hsaUnavailRecord.Status__c = 'Removed';
			stdController.save();
			
		}
		system.debug('*unavailWrapList' + unavailWrapList);
	}
	
	
	public Map<string, GetCalanders> calanderMap;
	public void createUnavailability()
	{
		UnavailUpadateInOFS_Rest unavailRest = new  UnavailUpadateInOFS_Rest();
	   
	    calanderMap = new  map<string, GetCalanders>();
	    integer daysInbetween = hsaUnavailRecord.Work_Time_Start__c.date().daysBetween(hsaUnavailRecord.Work_Time_End__c.date());
	    system.debug('I am out for Loop');  		
		for(string empId: empIdList)
		{
			system.debug('I am in for Loop');
			string jSonList;
			//if(hsaUnavailRecord.Type__c == 'Recurring')
			{
				datetime start= hsaUnavailRecord.Work_Time_Start__c;
				while(start<=hsaUnavailRecord.Work_Time_End__c)
				{
					datetime enddate = start.adddays(30);
					
					if(enddate>hsaUnavailRecord.Work_Time_End__c)
					enddate = hsaUnavailRecord.Work_Time_End__c.adddays(1);
					system.debug('-->'+start+' '+start.format('yyyy-MM-dd'));
					system.debug('-->'+enddate+' '+enddate.format('yyyy-MM-dd'));
					jSonList = unavailRest.getCalendars(empId, start.format('yyyy-MM-dd'), enddate.format('yyyy-MM-dd'));
					if(jSonList != null)
					calanderMap.putall(createCalanderMap(jSonList));
					
					start =start.adddays(30); //=enddate;;//>hsaUnavailRecord.Work_Time_End__c?hsaUnavailRecord.Work_Time_End__c:start.adddays(30);
					system.debug('-->'+start);
				}
				
			}
			
			system.debug('-->'+calanderMap);
			/*else
			{
				integer i = 0;
				
				while (i <= daysInbetween)
				{
					//system.debug(hsaUnavailRecord.Work_Time_Start__c.adddays(i).format('yyyy-MM-dd'));
					dateStrings.add(hsaUnavailRecord.Work_Time_Start__c.adddays(i).format('yyyy-MM-dd'));
					i++;
				}
				jSonList = unavailRest.getCalendars(empId, hsaUnavailRecord.Work_Time_Start__c.format('yyyy-MM-dd'), hsaUnavailRecord.Work_Time_End__c.format('yyyy-MM-dd'));
				
				
				if(jSonList == null)
				{
					util.setErrorMsg(true,'Error while applying unavailabulity. Please Riase I need Help;');
				}else{
				
					calanderMap = createCalanderMap(jSonList);
				}	
			}	*/
				
			integer i = 0;
			while (i <= daysInbetween)
			{
				string startString = hsaUnavailRecord.Work_Time_Start__c.adddays(i).format('yyyy-MM-dd');
				if(calanderMap.containskey(startString))
				{
					string position = 'byServiceWindow';
					string startTime;
					string endTime;
					datetime unavailStart;
					datetime unavailEnd;
					datetime calStart = datetime.valueof(startString + ' ' + calanderMap.get(startString).workTimeStart + ':00');
					datetime calEnd = datetime.valueof(startString + ' ' + calanderMap.get(startString).workTimeEnd + ':00');
					datetime recururringStart = datetime.valueof(startString + ' ' + hsaUnavailRecord.Work_Time_Start__c.format('kk:mm:ss'));
					datetime recururringEnd = datetime.valueof(startString + ' ' + hsaUnavailRecord.Work_Time_End__c.format('kk:mm:ss'));
					string endTime_new;
					
					if((hsaUnavailRecord.Type__c != 'Recurring'  && hsaUnavailRecord.Work_Time_Start__c < calEnd && hsaUnavailRecord.Work_Time_Start__c > calStart )|| (hsaUnavailRecord.Type__c == 'Recurring'  && recururringStart< calEnd && recururringStart>calStart))
					{
						startTime = hsaUnavailRecord.Work_Time_Start__c.format('kk:mm:ss');
					}
					else if((hsaUnavailRecord.Type__c != 'Recurring' && hsaUnavailRecord.Work_Time_Start__c < calEnd && hsaUnavailRecord.Work_Time_Start__c <= calStart) || (hsaUnavailRecord.Type__c == 'Recurring'  && recururringStart< calEnd && recururringStart<=calStart))
					{
						
						startTime = calanderMap.get(startString).workTimeStart + ':00';
						
						position = 'first';
					}
					if(startTime != null)
					{
						unavailStart = datetime.valueof(startString + ' ' + startTime + ':00');
						
						endTime_new= unavailStart.addminutes(5).format('kk:mm:ss');
					}
					system.debug(hsaUnavailRecord.Work_Time_End__c);
					system.debug(calStart);
					system.debug(calEnd);
					if((hsaUnavailRecord.Type__c != 'Recurring'  && hsaUnavailRecord.Work_Time_End__c > calStart && hsaUnavailRecord.Work_Time_End__c < calEnd) ||(hsaUnavailRecord.Type__c == 'Recurring'  && recururringEnd> calStart && recururringEnd<calEnd))
					{
						endTime = hsaUnavailRecord.Work_Time_End__c.format('kk:mm:ss');
						
					}
					else if((hsaUnavailRecord.Type__c != 'Recurring'  && hsaUnavailRecord.Work_Time_End__c > calStart && hsaUnavailRecord.Work_Time_End__c >= calEnd) || (hsaUnavailRecord.Type__c == 'Recurring'  && recururringEnd> calStart && recururringEnd>=calEnd))
					{
						endTime = calanderMap.get(startString).workTimeEnd + ':00';
						if(position != 'first')
						position = 'last';
						//endTime = hsaUnavailRecord.Work_Time_Start__c.addMinutes(2).format('kk:mm:ss');
					}
					if(endTime != null)
					{
						unavailEnd = datetime.valueof(startString + ' ' + endTime + ':00');
					}
					system.debug(unavailEnd);
					system.debug(unavailStart);
					
					if(unavailStart<=system.now())
					unavailStart = system.now().addminutes(1);
					
					
					if(unavailStart != null && unavailEnd!=null)
					{
					
					system.debug('-->'+position);
					Integer duration = Integer.valueof((decimal.valueOf(unavailEnd.getTime() - unavailStart.getTime())) / 1000 / 60);
					
					
					UnavailWrap ofsUnavailRecord = new  UnavailWrap(empId, startTime, endTime, duration, endTime_new, startTime, startString, hsaUnavailRecord.Activity_Type__c,hsaUnavailRecord.Name, hsaUnavailRecord.Notes__c, position);
					try
					{
						unavailRest.createActivity(ofsUnavailRecord);
					}
					catch(exception e)
					{
						hsaUnavailRecord.Status__c = 'Errored';
						util.setErrorMsg(false, 'Something went Wrong. Please riase an I Need Help.');
					}
					}else
					{
						hsaUnavailRecord.Status__c = 'Closed';
						util.setErrorMsg(false, 'Please check the start and end time as there is no valid Shifts to apply!');
					}
				}
				
				i++;
				
				hsaUnavailRecord.Status__c = 'Closed';
				util.setErrorMsg(false, 'Unavilability is Sucessfully Applied.');
			}
			
		}
		
		stdController.save();
	}
	
	
	public Map<string, GetCalanders> createCalanderMap(string jSonList)
	{
        
		Map<string, GetCalanders> calanderMap = new  map<string, GetCalanders>();
         GetCalanders calanderObj = null;
		JSONParser parser = JSON.createParser(jSonList);
			 
             
        while (parser.nextToken() != null)
        {                   
            
            system.debug('Parsing first step---' + parser.getCurrentToken() + parser.getText());            
            
            if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (dateStrings.contains(parser.getText())))
            {
                
                string dateString=null;
                while(parser.getText() != 'workTimeStart') {
                    
                    if(dateStrings.contains(parser.getText()))
                    {
                        dateString = parser.getText();
                        
                    }
                    parser.nextToken();
                }
                if(parser.getText()== 'workTimeStart'){                	
                    parser.nextToken();
                    calanderObj = new GetCalanders();
                    calanderObj.workTimeStart = parser.getText();
                    calanderObj.date_x = date.valueof(dateString);
                }               
                
                while(parser.getText()!= 'workTimeEnd') {
                    parser.nextToken();                           
                }
                
                if(parser.getText()== 'workTimeEnd'){                
                    parser.nextToken();
                    calanderObj.workTimeEnd = parser.getText();                      
                }                
                calanderMap.put(dateString, calanderObj);                
            }
        }
        system.debug('calendar'+calanderMap);
		return calanderMap;
		
	}
	
	public class UnavailWrapper implements Comparable
	{
		public HSA_Unavailability__c hsaUnavailability{get;set;}
		
		public boolean selectAct{get;set;}
		
		public string activityType;
		
		public datetime startTime;		
		public datetime endTime;
		
		public Integer activityId;
		
		public string status{get;set;}
		
		
		public UnavailWrapper(boolean selectAct, string activityType, datetime startTime, datetime endTime, Integer activityId, string status, string resourceId)
		{
			this.selectAct = selectAct;
			this.activityType = activityType;
			this.startTime = startTime;
			this.endTime = endTime;
			this.activityId = activityId;
			this.status = status;
			this.hsaUnavailability = new  HSA_Unavailability__c(Work_Time_Start__c = startTime, Work_Time_End__c = endTime, Activity_Type__c = activityType, Employee__c =resourceId );
		}
		
		public Integer compareTo(Object compareTo) 
    	{
    		UnavailWrapper obj = (UnavailWrapper) compareTo;
    		
    		if(hsaUnavailability.Work_Time_Start__c <obj.startTime)
    		return(-1);
    		else
    		return(1);
    	}
	}
	
	public class UnavailWrap
	{
		public Integer activityId;
		public string resourceId;
		public string activityType;
		public string startTime;
		public string endTime;
		public string status;
		public Integer duration;
		public string serviceWindowEnd;
		public string serviceWindowStart;
		public string date_x;
		public string XA_SF_HSA_Record_Id;
		public string XA_NOTES_INTERNAL;
		public string XA_Applied_By;
		public setPositionInRouteClass setPositionInRoute;
		public UnavailWrap(string resourceId, string startTime, string endTime, integer duration, string serviceWindowEnd, string serviceWindowStart, string date_x, string activityType, string XA_SF_HSA_Record_Id, string XA_NOTES_INTERNAL , string setPositionInRoute)
		{
			this.resourceId = resourceId;
			this.startTime = startTime;
			this.endTime = endTime;
			this.duration = duration;
			this.startTime = this.serviceWindowEnd = serviceWindowEnd;
			this.endtime = this.serviceWindowStart = serviceWindowStart;
			this.date_x = date_x;
			this.activityType = activityType;
			this.XA_SF_HSA_Record_Id = XA_SF_HSA_Record_Id;
			this.XA_NOTES_INTERNAL = XA_NOTES_INTERNAL;
			this.XA_Applied_By = Userinfo.getName();
			
			this.setPositionInRoute = new setPositionInRouteClass(setPositionInRoute);
		}
	}
	public class UnavailWrapResp
	{
		public Integer totalResults
		{
			get;set;
		}
		/*public Integer limit
		{
		get;set;
		}*/
		public Integer offset
		{
			get;set;
		}
		public List<UnavailWrap> items;
		public UnavailWrapResp()
		{
		}
		
		
	}
	
	public class setPositionInRouteClass{
		public setPositionInRouteClass(string s)
		{
			this.position = s;
		}
		public string position;
	}
	//This is class to hold the status and type of each response from OFS for POST/PUT/GET call
	public class unavailRestresponseObj
	{
		public string type
		{
			get;set;
		}
		public string status
		{
			get;set;
		}
		public string title
		{
			get;set;
		}
		public string detail
		{
			get;set;
		}
	}
	// Calander REST JSON Apex class
	public class GetCalanders
	{
		public date date_x;
		public string workTimeStart;
		public string workTimeEnd;
		public string comments;
	}
	
	
	public void extractUnavailabilities()
	{
		buildEmpoloyeeGroupsForSearch('remove');
	}
}