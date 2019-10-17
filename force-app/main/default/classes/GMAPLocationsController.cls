public class GMAPLocationsController
{
    public List<LocationData> MyLocations {get; set;}
    public Boolean isDataPresent {get; set;}
    public Integer RecordCount {get; set;}
    public GMAPLocationsController()
    {
        isDataPresent = false;
        Integer dateTimeY = Integer.valueOf(System.currentPageReference().getParameters().get('y'));
        Integer dateTimeM = Integer.valueOf(System.currentPageReference().getParameters().get('m'));
        Integer dateTimeD = Integer.valueOf(System.currentPageReference().getParameters().get('d'));
        //DateTime startDate = DateTime.newInstance(dateTimeY, dateTimeM, dateTimeD,0,0,0);
        //DateTime endDate = startDate.AddDays(1);
        Date searchDate = Date.newInstance(dateTimeY, dateTimeM, dateTimeD);
        //MyEvents = [Select e.AccountId, e.Account.BillingCity, e.Account.BillingCountry, e.Account.BillingPostalCode, e.Account.BillingState, e.Account.BillingStreet, e.Account.Id, e.ActivityDate, e.ActivityDateTime, e.Description, e.Id from Event e where e.ActivityDate =:searchDate and e.OwnerId =:UserInfo.getUserId()];
        
        MyLocations = new List<LocationData>();
        
        Map<String, LocationData> mapLocationData = new Map<String, LocationData>();
        
        /*List<Installer__c> MyInstallers = [Select i.User__r.Id, i.User__c, i.Job__r.Name, 
            i.Job__r.Id, i.Job__c, i.Job__r.Account__r.BillingCountry, i.Job__r.Account__r.BillingPostalCode, 
            i.Job__r.Account__r.BillingState, i.Job__r.Account__r.BillingCity, i.Job__r.Account__r.BillingStreet, 
            i.Account__c, i.Diary_Entry__r.Start__c, i.User__r.LastName, i.User__r.FirstName, i.Diary_Entry__r.Job_Installation_Date__c
            From Installer__c i 
            where  i.Diary_Entry__r.Job_Installation_Date__c =:searchDate];*/
            
        
            //FOR MANAGER CODE:- i.User__r.ManagerId =:UserInfo.getUserId() and
        
        //appointment (events) data for subordinates according to role hierarchy
        
        List<UserRole> userRoles = [Select u.RollupDescription, u.Name, u.Id From UserRole u where u.ParentRoleId =:UserInfo.getUserRoleId()];
        if(userRoles != null && userRoles.size() > 0)
        {
            Map<ID, UserRole> mapUserRoles = new Map<ID, UserRole>();
            for(UserRole userRole :userRoles)
            {
                mapUserRoles.put(userRole.ID, userRole);
            }
            
            if(mapUserRoles.size() > 0)
            {
                List<Event> subEvents = [Select e.Owner.Name, e.Owner.FirstName, e.Owner.LastName, 
                    e.OwnerId, e.ActivityDateTime, e.Account.Primary_Contact_Last_Name__c, 
                    e.Account.Primary_Contact_First_Name__c, e.Account.BillingCountry, 
                    e.Account.BillingPostalCode, e.Account.BillingState, e.Account.BillingCity, 
                    e.Account.BillingStreet, e.Account.Id, e.AccountId, e.Account.Name
                    From Event e
                    where e.ActivityDate =: searchDate
                    and e.Owner.UserRoleId in :mapUserRoles.keySet()
                    order by e.ActivityDateTime];
                
                if(subEvents != null && subEvents.size() > 0) RecordCount = subEvents.size(); 
                
                MyLocations = new List<LocationData>();
                LocationData newLocationData;
                System.debug('------------------ Step 1');
                for(Event e :subEvents)
                {
                    try
                    {
                        String address = e.Account.BillingStreet.replace('\n',' ').replace('\r',' ') + ', ' + 
                                                e.Account.BillingCity + ', ' + 
                                                e.Account.BillingState +  ', ' +
                                                e.Account.BillingPostalCode + ', ' + 
                                                'United Kingdom';
                        String description = '<b>Installer:</b> ' + e.Owner.FirstName + ' ' + e.Owner.LastName + ' ' + '<br/><b>Account:</b> ' + e.Account.Name;
                        String activityDatetime = e.ActivityDateTime.format();
                        
                        if(!mapLocationData.containsKey(address + description + activityDatetime))
                        {
                            newLocationData = new LocationData();
                            newLocationData.Address = address;
                            newLocationData.Description = description; 
                            newLocationData.ActivityDateTime = activityDatetime;
                            mapLocationData.put(address + description + activityDatetime, newLocationData);
                        }
                    }
                    catch(Exception ex)
                    {
                        System.debug('error: ' + ex);       
                    }
                }
                MyLocations = mapLocationData.values();
                if(MyLocations != null && MyLocations.size() > 0)
                {
                    isDataPresent = true;   
                }
            }
        }
    }
    
    public class LocationData
    {
        public String Address{ get; set;}
        public String Description {get; set;}
        public String ActivityDateTime {get; set;}
    }
    
	public static testmethod void testGMapLocationsController()
	{
		//Search users for test 
		User ManagerUser;
		//for(Integer i = 0; i < 50 ; i++)
		{
			List<UserRole> tempUsers = [select ID, ParentRoleId from UserRole Limit 30];
			if(tempUsers != null && tempUsers.size() > 0)
			{
				List<ID> ParentRID= new List<ID>(); 
				for(Userrole U : tempUsers)
				{
					ParentRID.Add(U.ParentRoleId);
				} 
			
				List<User> users = [select ID from User where IsActive = true and User.UserRoleId IN: ParentRID];
				if(users != null && users.size() > 0) 
				{ 
					for(integer k=0;k< users.size();k++)
					{
						if(users[k].ID != null) 
							ManagerUser = users[K];
						if(ManagerUser != null) break; //records found
					}
				}
			}
			//if(ManagerUser != null) break; //records found
		}
		
		
		System.debug('------------- ManagerUser = ' + ManagerUser);
		
		System.runAs(ManagerUser)
		{
			//create data for test
			Account acc = new Account();
			acc.Name = 'testAccount';
			acc.BillingCountry = 'United Kingdom'; 
			acc.BillingPostalCode = 'M25 0JH';
			acc.BillingState = 'Greater Manchester';
			acc.BillingCity = 'Prestwich';
			acc.BillingStreet = '2 Fairway';
			
			insert acc;
			
			Contact Con = new Contact();
			Con.FirstName = 'Testuserfirst';
			Con.LastName = 'Testuserlast';
			Con.AccountId = acc.Id;
			
			insert Con;
			
			Event e = new Event();
			e.ActivityDateTime = Datetime.now();
			e.ActivityDate = System.today();
			e.WhatId = acc.Id;
			e.DurationInMinutes = 50;
			Insert e;
			
			String y = e.ActivityDate.Year() + '';
			String m = e.ActivityDate.Month() + '';
			String d = e.ActivityDate.Day() + '';
			
			//run test
			PageReference pageRef = Page.SubOrdinateLocations; //('/apex/SubOrdinateLocations?y=' + y + '&m=' + m + '&d=' + d);
			
			Test.setCurrentPage(pageRef);
			
			ApexPages.currentPage().getParameters().put('y', y);
			ApexPages.currentPage().getParameters().put('m', m);
			ApexPages.currentPage().getParameters().put('d', d);
			
			SubOrdinatesLocationsController controller = new SubOrdinatesLocationsController(); 
			controller.displayLocation();
			GMAPLocationsController gs = new GMAPLocationsController();
			List<LocationData> MyLocations = gs.MyLocations; 
			Boolean p = gs.isDataPresent ;
		
		}
	}
}