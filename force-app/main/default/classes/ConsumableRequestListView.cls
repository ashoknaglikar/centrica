public class ConsumableRequestListView {
		public boolean isDHM {get;set;}
        
        public ApexPages.StandardSetController con{get; set;}
        public string title {get;set;}
        
        public list<Consumables_Requests__c> conReqList {get  
        {  
            if(con != null)  
                return (List<Consumables_Requests__c>)con.getRecords();  
            else  
                return null ;  
        }  
        set; }
        
        public integer pageSize;
        public boolean contBtn{get;set;}
        
        Public Consumables_Requests__c conReq {get;set;} 	
       
        public ConsumableRequestListView()
        {
        	pageSize = 50;
            conReqList = new list<Consumables_Requests__c>();
            conReq = new Consumables_Requests__c();
            User loggedInUser = [select id, ProfileId, Profile.Name from User where id = :userinfo.getuserid()];
            if((loggedInUser.Profile.Name).contains('DHM')) 
            {
            	isDHM = true;
            	try{
            		District__c dhmDistrict = [select Name from District__c where DHMName__r.Salesforce_User__c = :loggedInUser.Id and Type__c = 'Installation' limit 1]; 
            		system.debug('dhmDistrict-->'+dhmDistrict);
            		con = new ApexPages.StandardSetController(Database.getQueryLocator([Select c.Status__c,Employee__c,Approved_Date_Time__c, c.Request_Total_Value__c, c.Order_Name__c, c.Name, c.CreatedDate, c.Approved__c From Consumables_Requests__c c where District__c = :dhmDistrict.Name and Status__c = 'Submitted' order by CreatedDate desc limit 2000]));
            		con.setPageSize(pageSize);   
            		title = 'All Requests from '+dhmDistrict.Name;
            	}catch (Exception e)
            	{
            		
            	}
            }
            else if(userinfo.getuserid() != null)
            { 
                con = new ApexPages.StandardSetController(Database.getQueryLocator([Select c.Status__c,Employee__c, c.Request_Total_Value__c,Approved_Date_Time__c, c.Order_Name__c, c.Name, c.CreatedDate, c.Approved__c From Consumables_Requests__c c where CreatedById = :loggedInUser.Id order by CreatedDate desc limit 2000]));  
   
            // sets the number of records in each page set  
            	con.setPageSize(pageSize);  
            	title = 'All My Requests';
            	
	        }  
	        else  
	        {  
	            con = null;  
	        }  
	        try{
	        conReq = [Select c.Status__c,Employee__c, c.Request_Total_Value__c,Approved_Date_Time__c, c.Order_Name__c, c.Name, c.CreatedDate, c.Approved__c From Consumables_Requests__c c where CreatedById = :loggedInUser.Id and IsShoppingBasket__c = true and Status__c = 'In Progress'];
	        
	        if(conReq!=null)
	        {
	        	contBtn = true;
	        }
	        }catch(exception e)
	        {
	        	
	        }
	        
        }
        
         //Boolean to check if there are more records after the present displaying records  
    public Boolean hasNext  
    {  
        get  
        {  
            return con.getHasNext();  
        }  
        set;  
    }  
   
    //Boolean to check if there are more records before the present displaying records  
    public Boolean hasPrevious  
    {  
        get  
        {  
            return con.getHasPrevious();  
        }  
        set;  
    }  
   
    //Page number of the current displaying records  
    public Integer pageNumber  
    {  
        get  
        {  
            return con.getPageNumber();  
        }  
        set;  
    }  
  
    //Returns the previous page of records  
    public void previous()  
    {  
        con.previous();  
    }  
   
    //Returns the next page of records  
    public void next()  
    {  
        con.next();  
    }  
    
    public pagereference newmethod()
    {
        return (new pagereference('/apex/ConsumableSearch'));
    }
    
    public pagereference contMethod()
    {
        return (new pagereference('/apex/copyConsumableOrder?crId='+conReq.Id+'&Bas=t'));
    }

}