public class BriefSearchController {
	
	public Mandatory_Briefing_Creator__c mbc {get; set;}
	public List<Mandatory_Briefings__c> briefList {get; set;}// list of all breif records retuned on search criterias
	public String mbcName {get; set;}
	User briefUser = new user(); // Current logged in user record
	// Set of Profile names for which Breif Search is enabled
	Set<String> profileNames = new Set<String> {'CHI Standard Installer' , 'CHI Agency Contractor' , 'CHI Agency Electrical' , 'CHI Contractor' , 'CHI Installation - DHM' , 'CHI Installation - AHM' , 'System Administrator'};
	public Boolean noBriefRecords {get ; set;} // boolean variable set as true if no brief records are found 
	public List<Mandatory_Briefing_Creator__c> briefCreatorList {get; set;}
	public Id mbcId {get; set;}
	public String mbName {get; set;}
	public ApexPages.StandardSetController con{get; set;}
	public List<Mandatory_Briefings__c> greenBriefs {get; set;}
	public List<Mandatory_Briefings__c> amberBriefs {get; set;}
	public List<Mandatory_Briefings__c> redBriefs {get; set;}
	public List<Mandatory_Briefings__c> blueBriefs {get; set;}
	public boolean noGreenBriefs {get; set;}
	public boolean noAmberBriefs {get; set;}
	public boolean noRedBriefs {get; set;}
	public boolean noBlueBriefs {get; set;}
	public string flagName {get; set;}  
	public List<Mandatory_Briefings__c> tempList
	{
		get  
        {  
            if(con != null)  
                return (List<Mandatory_Briefings__c>)con.getRecords();  
            else  
                return null ;  
        }  
        set;  
	}
	public BriefSearchController()
	{
		mbcName = '';
		noBriefRecords = false;
		mbc = new Mandatory_Briefing_Creator__c();
		briefList = new List<Mandatory_Briefings__c>();
		briefCreatorList = new List<Mandatory_Briefing_Creator__c>();
		String userId = Userinfo.getUserId();
		briefUser = [Select u.Profile.Name,u.Brief_User__c, u.ProfileId, u.Id From User u
		             where u.Id =: userId
		             and (u.Profile.Name in: profileNames OR u.Brief_User__c = true)];
		greenBriefs = new List<Mandatory_Briefings__c>();
		amberBriefs = new List<Mandatory_Briefings__c>();
		redBriefs = new List<Mandatory_Briefings__c>();
		noGreenBriefs = false;
		noAmberBriefs = false;
		noRedBriefs = false;
	}
	
	
	
	/*
	 Purpose : Method called when user click the respected header record on the screen. Returns the filterd brief records
	*/
	public void searchBriefs()
	{
		noGreenBriefs = false;
		noAmberBriefs = false;
		noRedBriefs = false;
		noBlueBriefs = false;
		Mandatory_Briefing_Creator__c briefHeader = new Mandatory_Briefing_Creator__c();
		briefHeader = [select id,Name__c from Mandatory_Briefing_Creator__c where id=: mbcId];
		if(briefHeader != null)
		{
			mbName = briefHeader.Name__c;
		}
		//if(!((String.valueOf(briefUser.Profile.Name).contains('AHM')) || (String.valueOf(briefUser.Profile.Name).contains('DHM')) || (String.valueOf(briefUser.Profile.Name).contains('System Administrator'))))
		//if(!((String.valueOf(briefUser.Profile.Name).contains('AHM')) || (String.valueOf(briefUser.Profile.Name).contains('DHM'))))
		if((!((String.valueOf(briefUser.Profile.Name).contains('AHM')) || (String.valueOf(briefUser.Profile.Name).contains('DHM')) || (String.valueOf(briefUser.Profile.Name).contains('System Administrator')))) && (briefUser.Brief_User__c == false))
		{
			briefList = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId  AND m.Completed_By__c =: briefUser.Id))
				                ORDER BY m.name ASC];
				                
			greenBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId  AND m.Completed_By__c =: briefUser.Id AND m.Over_All_Status_Text__c =: 'Green'))
				                ORDER BY m.name ASC];
			amberBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId  AND m.Completed_By__c =: briefUser.Id AND m.Over_All_Status_Text__c =: 'Amber'))
				                ORDER BY m.name ASC];
				                
			redBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId  AND m.Completed_By__c =: briefUser.Id AND m.Over_All_Status_Text__c =: 'Red'))
				                ORDER BY m.name ASC];
				                
			blueBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId  AND m.Completed_By__c =: briefUser.Id AND m.Over_All_Status_Text__c =: 'Blue'))
				                ORDER BY m.name ASC];
		 	
		}
		else if(String.valueOf(briefUser.Profile.Name).contains('DHM'))
		{
			Employee__c dhmEmployee = new Employee__c();
			dhmEmployee = [Select e.Salesforce_User__c, e.DHM_Full_Name__c From Employee__c e
			               where e.Salesforce_User__c =: briefUser.id];
			            
			briefList = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.DHM_Full_Name__c , m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.DHM_Full_Name__c =: dhmEmployee.DHM_Full_Name__c))
					         ORDER BY m.name ASC];
					         
			greenBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.DHM_Full_Name__c , m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.DHM_Full_Name__c =: dhmEmployee.DHM_Full_Name__c AND m.Over_All_Status_Text__c =: 'Green'))
					         ORDER BY m.name ASC];
					         
			amberBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.DHM_Full_Name__c , m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.DHM_Full_Name__c =: dhmEmployee.DHM_Full_Name__c AND m.Over_All_Status_Text__c =: 'Amber'))
					         ORDER BY m.name ASC];
					         
			redBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.DHM_Full_Name__c , m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.DHM_Full_Name__c =: dhmEmployee.DHM_Full_Name__c AND m.Over_All_Status_Text__c =: 'Red'))
					         ORDER BY m.name ASC];
					         
			blueBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.DHM_Full_Name__c , m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.DHM_Full_Name__c =: dhmEmployee.DHM_Full_Name__c AND m.Over_All_Status_Text__c =: 'Blue'))
					         ORDER BY m.name ASC];
			              
		}
		else if (String.valueOf(briefUser.Profile.Name).contains('AHM'))
		{
			Employee__c ahmEmployee = new Employee__c();
			ahmEmployee = [Select e.Salesforce_User__c, e.Region__c From Employee__c e
						   where e.Salesforce_User__c =: briefUser.id];
			briefList = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.Region__c ,m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.Region__c =: ahmEmployee.Region__c))
					         ORDER BY m.name ASC];
					         
			greenBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.Region__c ,m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.Region__c =: ahmEmployee.Region__c AND m.Over_All_Status_Text__c =: 'Green'))
					         ORDER BY m.name ASC];
					         
			amberBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.Region__c ,m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.Region__c =: ahmEmployee.Region__c AND m.Over_All_Status_Text__c =: 'Amber'))
					         ORDER BY m.name ASC];
					         
			redBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.Region__c ,m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.Region__c =: ahmEmployee.Region__c AND m.Over_All_Status_Text__c =: 'Red'))
					         ORDER BY m.name ASC];
					         
			blueBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
					         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
					         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
					         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.Employee__r.Region__c ,m.name , m.District__c , m.Region__c
					         From Mandatory_Briefings__c m 
					         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Employee__r.Region__c =: ahmEmployee.Region__c AND m.Over_All_Status_Text__c =: 'Blue'))
					         ORDER BY m.name ASC];
			
		}
		else if((briefUser.Brief_User__c == true) || (String.valueOf(briefUser.Profile.Name).contains('System Administrator')))
		{
			briefList = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId))
				                ORDER BY m.name ASC];
				                
			greenBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Over_All_Status_Text__c =: 'Green'))
				                ORDER BY m.name ASC];
			amberBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Over_All_Status_Text__c =: 'Amber'))
				                ORDER BY m.name ASC];
				                
			redBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Over_All_Status_Text__c =: 'Red'))
				                ORDER BY m.name ASC];
				                
			blueBriefs = [Select m.Over_All_Status_Text__c, m.Mandatory_Briefing_Creator__r.Name__c, m.Mandatory_Briefing_Creator__c, 
				         m.Completed_By__c, m.Briefing_Name__c, m.Actual_Start_Date_Time__c, m.Actual_End_Date_Time__c,
				         m.Mandatory_Briefing_Creator__r.Name , m.Employee__r.Name, m.Issued_Date_Time__c ,
				         m.Employee__r.District__r.Name , m.Status_Indicator__c , m.name , m.District__c , m.Region__c
				         From Mandatory_Briefings__c m 
				         where ((m.Mandatory_Briefing_Creator__c =: mbcId AND m.Over_All_Status_Text__c =: 'Blue'))
				                ORDER BY m.name ASC];
		}
		if(briefList.size() == 0)
		{
			noBriefRecords = true;
			con = null;  
		}
		else
		{
			con = new ApexPages.StandardSetController(briefList);
			con.setPageSize(25);
			noBriefRecords = false;
		}
		
	}
	
	public void searchCreator()
	{
		Boolean isLimit = false;
		briefList.clear();
		briefCreatorList.clear();
		if((mbc.Actual_Start_Date_Time__c != null && mbc.Actual_End_Date_Time__c != null) && (mbcName == null || mbcName == ''))
		{
			if(mbc.Actual_Start_Date_Time__c.date().daysBetween(mbc.Actual_End_Date_Time__c.date()) > 365)
			{
				isLimit = true;
				ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.INFO, 'Please search within one year range.');
  				ApexPages.addMessage(msg);
	    		//return null;
			}
			else
			{
				briefCreatorList = [Select m.Status_Indicator__c, m.Name__c, m.Name, m.Issued_Date_Time__c,
				                    m.Actual_End_Date_Time__c, m.Active_Count__c , m.Actual_Start_Date_Time__c 
				                    From Mandatory_Briefing_Creator__c m
				                    where m.Issued_Date_Time__c >: mbc.Actual_Start_Date_Time__c AND
							              m.Issued_Date_Time__c <: mbc.Actual_End_Date_Time__c AND m.Active_Count__c != null];
			}
			
		}
		else if((mbc.Actual_Start_Date_Time__c == null && mbc.Actual_End_Date_Time__c == null) && (mbcName != null))
		{
			briefCreatorList = [Select m.Status_Indicator__c, m.Name__c, m.Name, m.Issued_Date_Time__c, 
			                    m.Actual_End_Date_Time__c, m.Active_Count__c , m.Actual_Start_Date_Time__c 
			                    From Mandatory_Briefing_Creator__c m
			                    where m.Name__c =: mbcName AND m.Active_Count__c != null];
		}
		if(briefCreatorList.size() == 0 && isLimit == false)
		{
			noBriefRecords = true;
		}
		else
		{
			noBriefRecords = false;
		}
	}
	
	public void showBriefs()
	{
		if(flagName == 'Blue')
		{
			noGreenBriefs = false;
			noAmberBriefs = false;
			noRedBriefs = false;
			if(blueBriefs.size() == 0)
			{
				noBlueBriefs = true;
				con = null;  
			}
			else
			{
				con = new ApexPages.StandardSetController(blueBriefs);
				con.setPageSize(25);
				noBlueBriefs = false;
			}
		}
		else if(flagName == 'Green')
		{
			noAmberBriefs = false;
			noRedBriefs = false;
			noBlueBriefs = false;
			if(greenBriefs.size() == 0)
			{
				noGreenBriefs = true;
				con = null;  
			}
			else
			{
				con = new ApexPages.StandardSetController(greenBriefs);
				con.setPageSize(25);
				noGreenBriefs = false;
			}
		}
		else if(flagName == 'Amber')
		{
			noRedBriefs = false;
			noGreenBriefs = false;
			noBlueBriefs = false;
			if(amberBriefs.size() == 0)
			{
				noAmberBriefs = true;
				con = null;  
			}
			else
			{
				con = new ApexPages.StandardSetController(amberBriefs);
				con.setPageSize(25);
				noAmberBriefs = false;
			}
		}
		else if(flagName == 'Red')
		{
			noGreenBriefs = false;
			noAmberBriefs = false;
			noBlueBriefs = false;
			if(redBriefs.size() == 0)
			{
				noRedBriefs = true;
				con = null;  
			}
			else
			{
				con = new ApexPages.StandardSetController(redBriefs);
				con.setPageSize(25);
				noRedBriefs = false;
			}
		}
		else if(flagName == 'All')
		{
			noGreenBriefs = false;
			noAmberBriefs = false;
			noRedBriefs = false;
			noBlueBriefs = false;
			if(briefList.size() == 0)
			{
				noBriefRecords = true;
				con = null;  
			}
			else
			{
				con = new ApexPages.StandardSetController(briefList);
				con.setPageSize(25);
				noBriefRecords = false;
			}
		}
	}
	
	
}