public with sharing class ideaClass {
	
	public idea presentIdea {get;set;}
	public boolean likeBln {get;set;}
	public string submittedBy {get;set;}
	public boolean selected{get;set;}
    public string likes {get;set;}
    public string body{get;set;}
	public ideaClass(idea presentIdea)
	{
		id currentUser = userinfo.getuserid();
		this.presentIdea = presentIdea;
		
		list<Vote> v = [Select id from Vote where ParentId  = :presentIdea.Id and  CreatedbyId = : currentUser];
		
		selected = false;
		
		likes = presentIdea.Decimalremove__c;
		
		if(v.size()>0)
		{
            likeBln = false;
		}
		else
		{
			likeBln = true;
            
		}
		
		if(presentIdea.Body!=null)
		{
			
			body = presentIdea.Body;
			if(body.length()>250)
			{
				body = body.substring(0,250);
			}
		}
		 
		if(presentIdea.CreatedById == currentUser || !presentIdea.WithHold_Name__c)
		{
			submittedBy = presentIdea.Submitters_Name__c;
		}else if(presentIdea.WithHold_Name__c)
		{
			submittedBy = 'Name Withheld';
		}
        
	}
	

}