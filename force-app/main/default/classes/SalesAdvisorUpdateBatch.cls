global class SalesAdvisorUpdateBatch implements Database.Batchable<sObject> {
	
	public string query='';
	
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
    	 query = 'Select id,name,'+system.label.SalesAdvisorBatchQuery+' from opportunity where id!=null and '+system.label.SalesAdvisorBatchWhereClause;
         return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<opportunity> opplist)
    {
    	List<Opportunity> updateOpportunities = new List<Opportunity>();
    	set<id> oppIds = new set<id>();
    
    	set<string> postcodesector = new set<string>();
    	for(Opportunity op: opplist)
		{   
		    if(op.Account.BillingPostalCode!=null)
			postcodesector.add(op.Account.BillingPostalCode.substring(0,op.Account.BillingPostalCode.length()-2));
			oppIds.add(op.id);
		}  
		
		map<string, string> postCodeManagerMap = new map<string, string>();
        for(PostCode_Sector__c pc : [select Name, Area_Group__c from PostCode_Sector__c where Name in :postcodesector and Type__c = 'Sales' and Area_Group__c != null])
        {
            postCodeManagerMap.put(pc.name, pc.Area_Group__c);
        }
        
        /*
        Map<id,List<Appointment__c>> oppAppointmentMap = new Map<id,List<Appointment__c>>();
        for(Appointment__c app: [select id,name,Assigned_To__c,Assigned_to__r.Employee_Number__c,Opportunity__c from Appointment__c where Opportunity__c=:oppIds and status__c!='Cancelled' order by start__c desc])
		{
		    if(oppAppointmentMap.containsKey(app.Opportunity__c))
		    {
		        List<Appointment__c> appointlist = oppAppointmentMap.get(app.Opportunity__c);
		        appointlist.add(app);
		        oppAppointmentMap.put(app.Opportunity__c,appointlist);
		    }
		    else
		    {
		        oppAppointmentMap.put(app.Opportunity__c,new list<Appointment__c>{app});
		    }
		}
		
		*/
		map<string, string> areaManagerMap = new Map<string, string>();
		for(Employee__c e : [Select id, Area_Group__c from Employee__c where Area_group__c in : postCodeManagerMap.values()])
		{
		    areaManagerMap.put(e.Area_Group__c, e.Id);
		}
		
    	for(opportunity opp : opplist)
        {
            if(opp.Account.BillingPostalCode!=null)
            {
                string pc = opp.Account.BillingPostalCode.substring(0,opp.Account.BillingPostalCode.length()-2);
                if(postCodeManagerMap.containsKey(pc))
                {
                    string areaGroup = postCodeManagerMap.get(opp.Account.BillingPostalCode.substring(0,opp.Account.BillingPostalCode.length()-2));
                    if(areaManagerMap.containsKey(areaGroup))
                    {
                        opp.L6_PC_Manager__c  = areaManagerMap.get(areaGroup);
                        updateOpportunities.add(opp);
                    }
                }
            }
        }
        
        cls_isRun.generalTriggerSwitch = true;
        cls_isRun.dontFireTriggers = true;
        if(updateOpportunities.size()>0)
           Database.update(updateOpportunities,false);
    }
    
    global void finish(Database.BatchableContext bc){
        //CreateEmail.CretaeSendTextEmail(new list<string>{'suguna.chinnasamy@cognizant.com'}, 'Complete', system.label.GeographyBatchContext+ ': Batch is complete');
    }
	
}