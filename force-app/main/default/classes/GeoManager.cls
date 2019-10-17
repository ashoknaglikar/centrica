global with sharing class GeoManager {
	
	
	public static string username = system.label.GeoManagerUserName ;
	public static string password=system.label.GeoManagerPassword;
	public static string basicUrl = system.label.GeoManagerUrl;
	public static string createLMK = 'CreateLMK?CC=GB';
	public static string editLMK = 'EditLMK?CC=GB';
	public static string deleteLMK = 'DeleteLMK?CC=GB';
	
	
	
	webservice static string sendSendSingleJob(list<string> JobIds)
	{
		Job__c[] JobList = [Select Id,Name,Install_Street__c,Install_City__c,Installation_County__c,Install_Postcode__c,District__r.GMFence_Limit__c, Start_Data_Time__c, 
							Status__c ,Installation_date__c,Maximum_End_Date__c,Latitude__Latitude__s,Longitude__Longitude__s,
							GMLoaded_Date__c,GM_Status__c,	GM_Status_Reason__c,Quote__r.Product_Type_ID__c   from Job__c where Id in :JobIds];
							
		string result;					
		if(JobList.size()>0)
		{
			GeoManager  gm = new GeoManager();
			result = GeoManager.sendJobToGeoManager(JobList[0], 2); 
		}
		return result;
		
	} 
	
	public static void fetchJobsbyQuery()
	{
		list<string> gmStatus = new list <string > {'In Progress'};
		list<string> jobStatus = new list <string > {'Planned', 'Cancelled'};
		datetime now = system.now();
		Job__c[] JobList = [Select Id,Name,Install_Street__c,Install_City__c,Installation_County__c,Install_Postcode__c,District__r.GMFence_Limit__c, Start_Data_Time__c, 
							Status__c ,Installation_date__c,Maximum_End_Date__c,Latitude__Latitude__s,Longitude__Longitude__s,
							GMLoaded_Date__c,GM_Status__c,	GM_Status_Reason__c, Quote__r.Product_Type_ID__c  from Job__c where Status__c in :jobStatus AND GM_Status__c IN :gmStatus 
							order by Installation_Date__c limit 1];
		
						
	    if(JobList.size()>0)
	    {
	    	sendJobToGeoManager(JobList[0], 1);
	    }							
		
	}
	
	
	public static string sendJobToGeoManager (Job__c Job, integer i)
	{
		string finalResult;
		if(Job!=null)
		{
			string[] result;
			cls_IsRun.generalTriggerSwitch = true;
			if(Job.GM_Status__c == 'Loaded')
			{
				return('Job is already integrated.');
			}
			if(Job.GM_Status__c == null)
			{
				return ('Job is not ready to be itegrated.');
			}
			 string mode;
			 string jobNameParm = '&Label='+Job.Name+'%20'+Job.Quote__r.Product_Type_ID__c;
			 string type_St =system.label.GMType; 
			 string houseNumber = '&Number=0';
			 string instStreet ='';
			 list<string> streetPiece = new list<String>();
			 if(Job.Install_Street__c!=null)
			 {
			 	streetPiece.addall(Job.Install_Street__c.split(' '));
			 	system.debug('streetPiece-->'+streetPiece);
			 	houseNumber = '&Number='+streetPiece[0].replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]|-', ' ');
			 	
			 }
			 string test = Job.Install_Street__c;
			 
			 instStreet = test.normalizeSpace();
			 system.debug('3----->'+instStreet);
			 instStreet = instStreet!=null ? '&Street='+instStreet.replaceall('\n','').trim().replaceAll('[|%20|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]|-', ' '):'';
			 string instCity = Job.Install_City__c!=null?'&City='+Job.Install_City__c.replaceall('\n','').trim().replaceAll('[|%20|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]|-', ' '):'';
			 string county = Job.Installation_County__c!=null?'&County='+Job.Installation_County__c.replaceall('\n','').trim().replaceAll('[|%20|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]|-', ' '):'';
			 string postcode = Job.Install_Postcode__c!=null?'&Zip='+Job.Install_Postcode__c.replaceall('\n','').trim().replaceAll('[|%20|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]|-', ' '):'';
			 string feetParam = '&Radius='+(Job.District__r.GMFence_Limit__c!=null?Job.District__r.GMFence_Limit__c:system.label.Geofence);
			 String Latitude;
			 string Longitude;
			 boolean withOutLatLang = false;
			 if(Job.Latitude__Latitude__s!=null && Job.Longitude__Longitude__s!=null)
			 {
				 Latitude = '&Lat='+Job.Latitude__Latitude__s;
				 Longitude = '&Lon='+Job.Longitude__Longitude__s;
			 }else
			 {
			 	withOutLatLang = true;
			 }
			 
			 string[] temp;
			 string startString ='';
			 string endString = '';
			 if(Job.Installation_Date__c!=null)
			 {
				 Date jobStartDate = Job.Start_Data_Time__c!=null ? Job.Start_Data_Time__c.date():Job.Installation_Date__c;
				 jobStartDate = jobStartDate.addDays(-2);
				 if(jobStartDate<=system.now())
				 {
				 	time  jobStartTime = system.now().addhours(1).time();
				 	Time midnightCheck = time.newInstance(23,00,00,00);
				 	if(jobStartTime>= midnightCheck)
				 	{
				 		temp = string.valueof(system.today().adddays(1)).split('-');
				 	}else
				 	{
				 		temp = string.valueof(system.today()).split('-');
				 	}
				 	startString = temp[1]+'/'+temp[2]+'/'+temp[0]+' '+string.valueof(jobStartTime).substring(0,8);
				 	
				 }else
				 {
					 temp = string.valueof(jobStartDate).split('-');
					 startString = temp[1]+'/'+temp[2]+'/'+temp[0]+' 00:00:00';
				 }
			 
			 	 Date jobEndDate =  Job.Maximum_End_Date__c!=null ? Job.Maximum_End_Date__c.date():Job.Installation_Date__c;	
			 	 jobEndDate = jobEndDate.toStartOfWeek().addDays(7);
			 	 temp = string.valueof(jobEndDate).split('-');
				 endString = temp[1]+'/'+temp[2]+'/'+temp[0]+' 00:00:00';
			 }	 
			 string startDate = '&StartDate='+startString;
			 String EndDate = '&EndDate='+endString;
			 string completeUrl='';
			 string requestURL='';
			 if(withOutLatLang)
			 {
			 	requestURL = jobNameParm+houseNumber+instStreet+instCity+county+postcode+feetParam+startDate+EndDate+type_St;
			 }else
			 {
				requestURL = jobNameParm+houseNumber+instStreet+instCity+county+postcode+Latitude+Longitude+feetParam+startDate+EndDate+type_St;
			 }	
			 requestURL = requestURL.replaceall(' ', '%20');
			 string gmStatus;
			 //completeUrl = basicUrl+createLMK+requestURL;
			 if(Job.GM_Status__c=='In Progress' && Job.GMLoaded_Date__c == null && Job.Status__c == 'Planned')
			 {
				//mode ='Create';
				completeUrl = basicUrl+createLMK+requestURL;
				completeUrl = completeUrl.replaceall(' ', '%20');
				gmStatus = 'Loaded';
			 }
			 else if(Job.GM_Status__c=='In Progress' && Job.Status__c == 'Planned' && Job.GMLoaded_Date__c!=null)
			 {
			 	
			 	//First Remove the Landmark
			 	completeUrl = basicUrl+deleteLMK+requestURL;
				completeUrl = completeUrl.replaceall(' ', '%20');
			 	if(i==2)
			 	{
				 	result = sendRequest(completeUrl);
				 	if(result[0] == '1')
					{
						// Create New with New Dates 
						completeUrl = basicUrl+EditLMK+requestURL;
						completeUrl = completeUrl.replaceall(' ', '%20');
						gmStatus = 'Loaded';
					}else
					{
						completeUrl = basicUrl+deleteLMK+requestURL;
						completeUrl = completeUrl.replaceall(' ', '%20');
						gmStatus = 'In Progress';
					}
			 	}
				mode =requestURL;
				
				
				
			 }
			 else if(Job.GM_Status__c=='In Progress' &&  Job.Status__c == 'Cancelled')
			 {
				//mode = 'Remove';
				completeUrl = basicUrl+deleteLMK+requestURL;
				completeUrl = completeUrl.replaceall(' ', '%20');
				gmStatus = 'Removed';
			 }
			 system.debug('Complete URL-->'+completeUrl);
			 if(i==2)
			 {
				 completeUrl = completeUrl.replaceall(' ', '%20');
				 result = sendRequest(completeUrl);
				 if(result!=null)
				 {
					 if(result[0] == '1')
					 {
					 	Job.GM_Status__c = gmStatus;
					 	Job.GM_Status_Reason__c = result[1];
					 	Job.GMLoaded_Date__c = system.now();
					 	finalResult = 'Successfully Loaded';
					 }else if(result[0] == '-12')
					 {
					 	Job.GM_Status__c = 'In Progress';
					 	Job.GM_Status_Reason__c =result[0]+'  '+ result[1];
					 	//Job.GMLoaded_Date__c = null;
					 	finalResult = 'Integration Failed';
					 }
					 	
					 else
					 {
					 	Job.GM_Status__c = 'Error';
					 	Job.GM_Status_Reason__c =result[0]+'  '+ result[1];
					 	//Job.GMLoaded_Date__c = null;
					 	finalResult = 'Integration Failed';
					 }
					 
					 try{
					 	system.debug('---->'+Job.GM_Status__c);
					 		update Job;
					 	}catch (Exception e)
					 	{
					 		system.debug('Exception in landmark Creation for Job'+Job.Name+'   '+e.getmessage());
					 	}
						 
					 }
			 }else if(i==1)
			 {
			 	Job.GM_Status__c ='Sent-Awaiting Resonse';
			 	update Job;
			 	completeUrl = completeUrl.replaceall(' ', '%20');
			 	sendRequestFuture(completeUrl, Job.Id, mode);
			 }	
	     
	     
		}
		return finalResult;
	}	
	
	public  static string[] sendRequest(string URL)
	{
		system.debug('URL---->'+URL);
		 HttpRequest req = new HttpRequest();
		 req.setEndpoint(URL);
	     req.setMethod('GET');
	     
	     // Specify the required user name and password to access the endpoint
	     // As well as the header and header information
	     Blob headerValue = Blob.valueOf(username + ':' + password);
	     String authorizationHeader = 'BASIC ' +
	     EncodingUtil.base64Encode(headerValue);
	     req.setHeader('Authorization', authorizationHeader);
	   
	     // Create a new http object to send the request object
	     // A response object is generated as a result of the request  
	  
	     Http http = new Http();
	     HTTPResponse res = http.send(req);
	     
	     System.debug('Response --->'+res.getBody());
	     string CODE = BGProductHoldingServiceHelper.readXML(res, 'CODE');
		 string Description = BGProductHoldingServiceHelper.readXML(res, 'DESCRIPTION');
		 
		 return (new string[]{CODE,Description});
		 
	}
	@future(callout=true)
	public  static void sendRequestFuture(string URL, string JobId, string mode)
	{
		system.debug('URL---->'+URL);
		
		 HttpRequest req = new HttpRequest();
		 req.setEndpoint(URL);
	     req.setMethod('GET');
	     
	     // Specify the required user name and password to access the endpoint
	     // As well as the header and header information
	     Blob headerValue = Blob.valueOf(username + ':' + password);
	     String authorizationHeader = 'BASIC ' +
	     EncodingUtil.base64Encode(headerValue);
	     req.setHeader('Authorization', authorizationHeader);
	   
	     // Create a new http object to send the request object
	     // A response object is generated as a result of the request  
	  
	     Http http = new Http();
	     HTTPResponse res = http.send(req);
	     system.debug('Response -->'+res);
	     string CODE = BGProductHoldingServiceHelper.readXML(res, 'CODE');
		 string Description = BGProductHoldingServiceHelper.readXML(res, 'DESCRIPTION');
		 
		 Job__c Job = new Job__c(Id = JobId);
		 string gmStatus = 'Loaded';
	     if(CODE!=null)
		 {
			 if(CODE == '1')
			 {
			 	
			 	
			 	if(mode != null)
			 	{
			 		
			 		Job.GMLoaded_Date__c = null;
			 		gmStatus = 'In Progress';
			 		
			 	}else if(URL.contains(deleteLMK))
    			{
    			 	gmStatus= 'Removed';
    			 	Description = 'SUCCESS';
    			}
			 	else
			 	{
			 		Job.GMLoaded_Date__c = system.now();
			 	}
			 	
			 	
			 	
			 }
			 
			 else 
			 {
			     gmStatus = 'In Progress';
			     Description =CODE+'  '+ Description;
    			 if( CODE == '-11'  && mode!=null)
    			 {
    			 	Job.GMLoaded_Date__c = system.now();
    			 	
    			 }else if(CODE == '-12'  && mode!=null)
    			 {
    			     Job.GMLoaded_Date__c = null;
    			     
    			 }else{
    			     gmStatus = 'Error';
    			 }
    			
			 }	 
			 
			 try{
			 	system.debug('---->'+Job.GM_Status__c);
			 	Job.GM_Status__c = gmStatus;
			 	Job.GM_Status_Reason__c = Description;
			 	
			 	if(URL.contains(deleteLMK) && mode == null)
			 	{
			 		Job.GM_Status__c = 'Removed';
			 		Job.GMLoaded_Date__c = system.now();
			 	}
			 	cls_IsRun.generalTriggerSwitch = true;
		 		update Job;
			 	}catch (Exception e)
			 	{
			 		system.debug('Exception in landmark Creation for Job'+Job.Name+'   '+e.getmessage());
			 	}
				 
			 }
	   		
		 
	}
		
	

}