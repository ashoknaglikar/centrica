/*
	Author  : Cognizant
	
	Purpose : The business currently runs a Salesforce report based on a number of filter criteria. 
			  This report is then extracted and updated to make it suitable for the dialler system.
			  Design functionality similar to the quote follow up tab which will allow filters to be applied and produce 
			  a text file sent to a given email address which can then be loaded directly into the dialler system.
			  
	Description : Controller class of DiallerPreCall page.
*/
public with sharing class DiallerPreCallController {
	
	public Appointment__c appointment {get; set;}
	public string email {get;set;}
    public string message {get;set;}
    public boolean flag {get;set;}
    public string status {get; set;}
    public Boolean isNotPickedByDialler {get; set;}
    public Boolean isConsiderPreCallStatus {get; set;}
    
    public DiallerPreCallController()
    {
    	appointment = new Appointment__c();
    	isNotPickedByDialler = true;
    	isConsiderPreCallStatus = true;
    }
    
    // Fetch all Status picklist values from Apoointment object
    public List<SelectOption> getStatusValues()
    {
    	List<selectoption> options = new List<selectoption>();
    	Schema.DescribeFieldResult statusField = Appointment__c.Status__c.getDescribe();
        List <Schema.PicklistEntry>  picklistskills = statusField.getPicklistValues();
        for(Schema.PicklistEntry p : picklistskills)
        {    
            Options.add(new SelectOption(p.getLabel(),p.getLabel()));
        }
        return Options;
    }
    
    public boolean createDiallerFile()
    {
    	string endCriteria;
    	string finalquery;
    	string precallStatusCriteria;
    	Utilities utl = new Utilities();
    	string query = 'Select RecordType.Name,Status__c,Start__c,Id,Date_Visit_Booked__c,CHI_Lead_No__c,Customer_Greeting_Name__c,Visit_Date__c,Contact_Mobile__c,Contact_Home_Phone__c,Pre_Called__c,';
    	query += 'Visit_Day_Of_Year__c , Picked_By_Dialler__c From Appointment__c where Id != null AND CHI_Lead_No__c != null ';
    	if(isNotPickedByDialler == true)
    	{
    		endCriteria = 'RecordType.Name = \'Appointment\' order by CHI_Lead_No__c , Visit_Day_Of_Year__c';
    	}
    	else
    	{
    		endCriteria = 'RecordType.Name = \'Appointment\' and Picked_By_Dialler__c =false order by CHI_Lead_No__c , Visit_Day_Of_Year__c';
    	}
    	if(isConsiderPreCallStatus == true)
    	{
    		precallStatusCriteria = 'Pre_Called__c = null';
    	}
    	/*else
    	{
    		precallStatusCriteria = 'Pre_Called__c != null';
    	}*/
    	string limits = ' limit 100';
    	string statusCriteria = ' Status__c = \''+ status +'\'';
    	string startFilterCriteria = ' Start__c >='+getValue(appointment.Confirmation_Email__c)+' AND Start__c <='+getValue(appointment.NSSE_Email_Sent__c);
    	string visitDateCriteria = 'Date_Visit_Booked__c >=' +getDateToStringValue(appointment.HistrorySOAppDate__c) +' AND Date_Visit_Booked__c <='+getDateToStringValue(appointment.Date_Visit_Booked__c);
    	//finalquery = query + ' AND ('+statusCriteria+ ') AND ('+startFilterCriteria + ') AND ('+visitDateCriteria+') AND '+endCriteria+limits;
    	if(isConsiderPreCallStatus == true)
    	{
    		finalquery = query + ' AND('+precallStatusCriteria+') AND ('+statusCriteria+ ') AND ('+startFilterCriteria + ') AND ('+visitDateCriteria+') AND '+endCriteria+limits;
    	}
    	else
    	{
    		finalquery = query + ' AND ('+statusCriteria+ ') AND ('+startFilterCriteria + ') AND ('+visitDateCriteria+') AND '+endCriteria+limits;
    	}
    	system.debug('QUERY----->'+finalquery);
    	string fileName = 'CHI_DIALLER_PRE_CALL'+userinfo.getuserid()+system.now();
    	string chiLeadNum = queryData(finalquery,fileName);
    	if(chiLeadNum!= null)
    	{
    		system.debug('-----InsideEmail-----');
    		string nextCriteria = 'CHI_Lead_No__c >\''+chiLeadNum+'\'';
    		string secquery;
    		//secquery = query + ' AND ('+statusCriteria+ ') AND ('+startFilterCriteria + ') AND ('+visitDateCriteria+') AND ('+nextCriteria+') AND '+endCriteria+limits;
    		if(isConsiderPreCallStatus == true)
    		{
    			secquery = query + ' AND('+precallStatusCriteria+') AND ('+statusCriteria+ ') AND ('+startFilterCriteria + ') AND ('+visitDateCriteria+') AND ('+nextCriteria+') AND '+endCriteria+limits;
    		}
    		else
    		{
    			secquery = query + ' AND ('+statusCriteria+ ') AND ('+startFilterCriteria + ') AND ('+visitDateCriteria+') AND ('+nextCriteria+') AND '+endCriteria+limits;
    		}
    		system.debug('########secquery#########'+secquery);
    		fileName += '#'+ email +'#'+chiLeadNum;
    		CreateEmail.CretaeSendTextEmail(new list<string>{system.label.DiallerEmailService}, secquery, fileName);
    		message = 'Dialler file is being generated. Please Wait for few minutes before you check in mentioned mailbox';
            utl.setErrorMsg(false,message);
            flag = true;
    	}
    	else
    	{
    		message = 'No Appointments to generate file. Please try changing Date or Status values';
            utl.setErrorMsg(true,message);
            flag = false;
    	}
    	return null;
    }
    
    public string queryData(string query, string filename)
    {
    	List<Appointment__c> appointmentList = database.query(query);
    	if(appointmentList.size() > 0)
    	{
    		//sendDiallerDetails.createTextFileForPreCallDialler(appointmentList, filename);
    		if(sendDiallerDetails.createTextFileForPreCallDialler(appointmentList, filename))
    		{
    			if(cls_IsRun.appointmentSwitch == false)
		    	{
		    		for(Appointment__c appoint : appointmentList)
		    		{
		    			appoint.Picked_By_Dialler__c = true;
		    		}
		    		try
		    		{
		    			if(appointmentList.size() > 0)
				        {
				        	cls_IsRun.setappointmentSwitch();
				        	database.update(appointmentList);
				        }
			        
		    		}
		    		catch(Exception ex)
			        {
			        	system.debug('------Exception Occured--'+ex);
			        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			        	String[] toAddresses = system.label.Dialler_Mails.split(',');
				        String subject = 'Eoor occured in Pre-Call dialler';
				        email.setSubject( subject );
				        email.setToAddresses( toAddresses );
				        email.setPlainTextBody(string.valueOf(ex));
				        Messaging.SendEmailResult [] mssg = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
			        }
		    	}
    		}
    		return (appointmentList[appointmentList.size()-1].CHI_Lead_No__c);
    	}
    	else
    	{
    		return null;
    	}
    }
    
    // Method will redirect to Pre-Call dialler page when user click "Back" button
    public pagereference back()
    {
        flag = false;
        return (new pagereference ('/apex/DiallerPreCall'));
    }
    
    // This method convert date to string format whcih will be used in SOQL
    public static String getDateToStringValue(Date value)
    {
        DateTime dt = Datetime.newInstance(value, Time.newInstance(0,0,0,0));
        return dt.format('yyyy-MM-dd');
    }
    
    // This method convert datetime to string format whcih will be used in SOQL
    public static String getValue(DateTime value)
    {
        return value.format('yyyy-MM-dd') + 'T' + value.format('hh:mm:ss') + '.000Z';
    }

}