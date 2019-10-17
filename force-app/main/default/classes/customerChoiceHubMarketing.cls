global class customerChoiceHubMarketing {
    
	global contactObj contact = new contactObj();
	global class contactObj{    
	    public string idOrigin;
	    public string id;
	    public string timestamp;
	    public marketingList marketingPermissions =new marketingList ();
	}

	global class marketingList{

		public List <customerChoiceHubMarketingPreference> contactMarketingPermissions =new List <customerChoiceHubMarketingPreference> ();

	}

}