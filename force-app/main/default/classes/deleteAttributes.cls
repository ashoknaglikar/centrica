public with sharing class deleteAttributes implements Database.Batchable<sObject>{
	
	public static void deleteStart(){
        deleteAttributes delAtt = new deleteAttributes();
        ID batchprocessid = Database.executeBatch(delAtt,200);  
    }
	
	public Database.QueryLocator start(Database.BatchableContext BC){
	    
	    list<string> queryDef =  system.label.AttrigbuteQueryStartDate.split(',');
	    
	    Date Enddate = system.today().addDays(-180);
	    Date startDate = Enddate.addDays(-360);
	    
		
		
		
		if(queryDef[0] != 'ON')
		{
		    startDate = date.valueof(queryDef[0]);
		    endDate = startDate.adddays(integer.valueof(decimal.valueof(queryDef[1].trim())));
		}
		
		system.debug('---------'+startDate);
	    system.debug('---------'+Enddate);
		string query = system.label.Attribute_Query_Delete;
		
		return Database.getQueryLocator(query);
		
	}
	

	
	public void execute(Database.BatchableContext BC, List<sObject> lstRecords){
		
		delete lstRecords;
	
      
      
		
	}
	
	
	
	public void finish(Database.BatchableContext BC){
		
	}
	

}