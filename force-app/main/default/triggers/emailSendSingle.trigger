trigger emailSendSingle on Appointment__c (after update) {
    
    if(cls_IsRun.appointmentSwitch || cls_IsRun.istrg_emailSendSingle)
    {
    	return;
    }
    
    map<id,Appointment__c> AccIdAptID = new map<id,Appointment__c>();
    // Send single mail to contact of each updated appointment where the contact is a Landlord.
    for (Appointment__c uapp : Trigger.new ) {
    
       if(trigger.oldmap.get(uapp.Id).Opportunity__c == null && uapp.Opportunity__c!=null && !AccIdAptID.containskey(uapp.Account_Id__c) && uapp.Status__c != 'Cancelled' && uapp.Type__c == 'Sales')
       { 
       		if(!AccIdAptID.containskey(uapp.Account_Id__c))
            AccIdAptID.put(uapp.Account_Id__c,uapp);
       }
    }
    if(AccIdAptID.size() >0)
	{
	    list<Contact> updatingCons = new list<Contact>();
        For (Contact c:[SELECT Email,AccountId,Preferred_Contact_Method__c ,Send_Email_To_Landlord__c  FROM contact 
                        WHERE accountID in : AccIdAptID.keyset()
                        AND( Contact_Type__c = 'Landlord' or Contact_Type__c ='Agent')])
        {
        	 // ++ Added for CR#792 start
        	 c.Send_Email_To_Landlord__c = false;
             updatingCons.add(c);
             // -- Added for CR#792 end
            if(!Lock.emailSendSingle)
            {
                Lock.setemailSendSingle();
                Id EmialTempId;
                Id TargetID ;
                Id WhatID;
                boolean isBGFrom;
                if(c.Preferred_Contact_Method__c =='Text (SMS)')
                {
                    c.AppointmentVisitDate__c= AccIdAptID.get(c.AccountId).Visit_Date__c;
                    c.Appt_Start_Time__c = AccIdAptID.get(c.AccountId).Start_Time__c;
                    c.Appt_End_Time__c = AccIdAptID.get(c.AccountId).End_Time__c;
                    c.Send_Email_To_Landlord__c = false;
                    //updatingCons.add(c);
                                            
                }else if(c.Preferred_Contact_Method__c =='Email'&& system.label.LandlordHTMLTemplate != 'off')
                {
                    TargetID = c.Id;
                    WhatID = AccIdAptID.get(c.AccountId).Id;
                    EmialTempId = system.label.LandlordHTMLTemplate;
                    isBGFrom = false;
                    
                }
                
                if(updatingCons.size()>0)
                {
                    update updatingCons;
                }
                if(EmialTempId != null)
                CreateEmail.CretaeSendEmailByTemplate(null, null, EmialTempId, TargetID, WhatID, isBGFrom);
            }
            
        }
        
    }
}