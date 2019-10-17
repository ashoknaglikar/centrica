public with sharing class SendASPAcknowledgments implements Database.Batchable<sObject>{
	
	public static void sendAckListLink(){
        SendASPAcknowledgments sendAck = new SendASPAcknowledgments();
        ID batchprocessid = Database.executeBatch(sendAck);
    }
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		
		list<string> statusList = new list<string> {'Escalated', 'In Progress'};
		
		string query =  'Select  Status__c, Description__c, Name, Id, ASP__R.Name,Exception_User__r.Name,CreatedDate, LeadNumber__c,'+ 
		    			'Exception_User__c, Escalted_To__c, Due_Date__c, Comments__c, Assigned_To__c, '+
		    			'Accept_Reject__c, ASP__c, Assigned_To_Email__c, Assigned_To__r.Name,Assigned_To__r.ManagerId, Assigned_To__r.Manager.Email From ASP_Exception__c Where Status__c in : statusList and Assigned_To__c != null order by Assigned_To__c';
		    			
		return Database.getQueryLocator(query);
		
	}
	
	OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'British Gas (DO NOT REPLY)' limit 1];
	
	public void execute(Database.BatchableContext BC, List<sObject> lstRecords){
		
		Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
       
        map<Id, List<ASP_Exception__c>> aspExceptionByUserMap = new map<Id, List<ASP_Exception__c>>();
        map<Id, List<ASP_Exception__c>> escaltedAspsByUserMap = new map<Id, List<ASP_Exception__c>>();
        list<ASP_Exception__c> updatingList = new list<ASP_Exception__c>();
        OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where DisplayName = 'British Gas (DO NOT REPLY)' limit 1];
        if(lstRecords.size() > 0){
        	
        	for(sObject sObj : lstRecords){
        		ASP_Exception__c exc = (ASP_Exception__c)sObj;
        		
        		if(exc.Status__c =='In Progress' )
        		{
        			if(exc.Due_Date__c < system.today())
        			{
        				exc.Status__c = 'Escalated';
        				if(exc.Assigned_To__r.ManagerId!=null)
        				{
	        				exc.Escalted_To__c = exc.Assigned_To__r.ManagerId ;
	        				updatingList.add(exc);
	        				if(escaltedAspsByUserMap.containsKey(exc.Escalted_To__c))
		        			escaltedAspsByUserMap.get(exc.Escalted_To__c).add(exc);
		        			else
		        			escaltedAspsByUserMap.put(exc.Escalted_To__c, new list<ASP_Exception__c>{exc});
        				}
        				
        			}else
        			{
        			
	        			if(aspExceptionByUserMap.containsKey(exc.Assigned_To__c))
	        			aspExceptionByUserMap.get(exc.Assigned_To__c).add(exc);
	        			else
	        			aspExceptionByUserMap.put(exc.Assigned_To__c, new list<ASP_Exception__c>{exc});
        			}
        			
        			
        		}else if(exc.Status__c =='Escalated' )
        		{
        			if(escaltedAspsByUserMap.containsKey(exc.Escalted_To__c))
        			escaltedAspsByUserMap.get(exc.Escalted_To__c).add(exc);
        			else
        			escaltedAspsByUserMap.put(exc.Escalted_To__c, new list<ASP_Exception__c>{exc});
        		}
        	}
        	
        	for(id i: aspExceptionByUserMap.keyset())
        	{
        		if(aspExceptionByUserMap.get(i)[0].Assigned_To_Email__c!=null)
        		{
	        		Messaging.SingleEmailMessage mail = createHTMLEmail(aspExceptionByUserMap.get(i));
	        		list<string> emaillist = new list<string>();
	        	    emaillist.add(aspExceptionByUserMap.get(i)[0].Assigned_To_Email__c);
	        	    if(system.label.includeAdmin!='off')
	        	    {
	        	        emaillist.addall(system.label.includeAdmin.split(','));
	        	    }
	        	    
	        	    mail.setToAddresses(emaillist);
	        		mail.setOrgWideEmailAddressId(owa.Id); 
	        		mails.add(mail);
        		}
        	}
        	for(id i: escaltedAspsByUserMap.keyset())
        	{
        		if(escaltedAspsByUserMap.get(i)[0].Assigned_To__r.Manager.Email!=null)
        		{
	        		Messaging.SingleEmailMessage mail = createHTMLEmail(escaltedAspsByUserMap.get(i));
	        		list<string> emaillist = new list<string>();
	        		emaillist.add(escaltedAspsByUserMap.get(i)[0].Assigned_To__r.Manager.Email);
	        		if(system.label.includeAdmin!='off')
	        	    {
	        	        emaillist.addall(system.label.includeAdmin.split(','));
	        	    }
	        	    
	        	    mail.setToAddresses(emaillist);
	        		mail.setOrgWideEmailAddressId(owa.Id); 
	        		mails.add(mail);
        		}
        	}

        	
        	if(updatingList.size()>0)
        	{
        		update updatingList;
        	}
        	
        	try{
                Messaging.sendEmail(mails);                
            }catch(Exception e){
             system.debug( e); 
                
            }  
        	
        }
      
      
		
	}
	
	public Messaging.SingleEmailMessage createHTMLEmail (list<ASP_Exception__c> aspExceptionlist)
	{
		date startdt = system.today();
		integer count = 1;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setToAddresses(new String[] {'ashokkumar.nagaleekar@centrica.com'});
	    mail.setSaveAsActivity(false);
	    
	    string subject = 'ASP Exception Report For '+startdt.day()+'-'+startdt.month() +'-'+startdt.year();
	    String str_emailBody = '<font face=\'calibri\' size=\'4\' color=\'#990000\' ><b>ASP Exception List</b></font>'+'<table cellpadding=\'5\' width=\'100%\'><tr ><td></td></tr>';
	    str_emailBody += '<tr><td><b>Sr.No.</b></td><td><b>Lead Number</b></td><td><b>Date Raised</b></td><td><b>Status</b></td><td><b>Approver</b></td><td><b>Reason</b></td><td><b>Link</b></td></tr>';
		for(ASP_Exception__c ae :  aspExceptionlist)
		{
		
        	str_emailBody = str_emailBody +'<tr><td>'+count+'</td><td>'+ae.LeadNumber__c+'</td><td>'+Date.valueof(ae.CreatedDate)+'</td><td>'+ae.Status__c+'</td><td>'+ae.Exception_User__r.Name+'</td><td>'+ae.Description__c+'</td><td><a href =\'https://'+system.label.Salesforce_Server+'.salesforce.com/'+ae.ASP__c+'\'>'+ae.Name+'</a></td></tr>';
        
            count++;
        
		}
		str_emailBody+='</table>';
		mail.setSubject(subject);
		mail.setHtmlBody(str_emailBody); 
		mail.setOrgWideEmailAddressId(owa.Id); 
		return mail;
	}
	
	public void finish(Database.BatchableContext BC){
		
	}
	

}