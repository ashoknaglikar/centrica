/*
	This Class is used for sending mails where we have to use a email template template. This Method is designed in such a way that 
	if can be used in future by just passing appropriate parameters to this method.
*/
public with sharing class CreateEmail {
    
    public static void CretaeSendEmailByTemplate(list<string> toaddress,list<string> ccaddress, Id EmialTempId, id TargetID, Id WhatID, boolean isBGfrom)
    {
        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
       		
       	if(toaddress!=null)
        	email1.setToAddresses(toaddress);   
        	
        if(ccaddress!=null)
        	email1.setCcAddresses(ccaddress);
        	
        if(TargetID!=null)
        	email1.setTargetObjectId(TargetID);
        	
        if(WhatID!=null)
        	email1.setWhatId(WhatID); 
        	
        if(EmialTempId != null)
        	email1.setTemplateId(EmialTempId);
        	
        id emailId;
        if(isBGfrom == true)
        	emailId = system.label.britishgasinstallationsEmail;
        else
        	emailId= system.label.noreplyEmail;
        	
	    email1.setOrgWideEmailAddressId(emailId);
       	try{
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});
       	}
       	catch (exception e)
       	{
       		system.debug('There was an exception in sending email');
       	}
        //email1.
    }
    
    public static void CretaeSendTextEmail(list<string> toaddress, string body, string subject)
    {
        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
       		
       	if(toaddress!=null)
        	email1.setToAddresses(toaddress);   
        if(body != null)
        	email1.setPlainTextBody(body);
        if(subject!=null)
        	email1.setSubject(subject);
      
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});
        //email1.
    }

}