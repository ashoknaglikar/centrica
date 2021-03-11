trigger bUPD_Task on Task (before update) {
    
    /*
        Developed By Cognizant
        This triggers fires when the Send Overdue Task Email check box is checked
        Action Performed:
        The check box is checked by the workflow time trigger. The time trigger fires when the task due date is over.
        As Email alert templates can't be created, the email to the users are sent using the trigger.
        The trigger checks whether the Send Overdue task email is checked, if checked a html email template is created
        and sent to the task owner.
        Copy post installation call related details on CHC.
    
    */
    
    
    // Changes for copying post installation call related details on CHC - Starts
    /*
   
   try{ 
        
      if(Trigger.new.size() == 1 && Trigger.New[0].Is_post_installation_call_task__c && Trigger.New[0].Status == 'Completed' && Trigger.old[0].Status != 'Completed' && Trigger.New[0].Post_installation_call_completed_by__c == null){
        
          Customer_history_card__c chc = [Select Id, Any_issues_post_installation__c, Date_of_post_call_check_completion__c,
                                                 Post_installation_call_notes__c from Customer_history_card__c where Payment_Collection__r.Id = :Trigger.New[0].WhatId limit 1];
          
          if(chc != null){
            
               System.debug('------1---------'+chc);
               
               chc.Any_Issues_with_Installation__c = Trigger.New[0].Any_Issues_with_Installation__c;
               chc.Date_of_post_call_check_completion__c = Trigger.New[0].Date_of_post_call_check_completion__c;
               chc.Post_installation_call_notes__c = Trigger.New[0].Post_installation_call_notes__c;
               chc.Issue_description__c = Trigger.New[0].Issue_description__c;
               
               if(Trigger.New[0].Date_of_post_call_check_completion__c == null){
                 
                  chc.Date_of_post_call_check_completion__c = Datetime.now();
                  Trigger.New[0].Date_of_post_call_check_completion__c = Datetime.now();
                  
               }
            
            Trigger.New[0].Post_installation_call_completed_by__c = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
            
            chc.Post_installation_call_completed_by__c = Trigger.New[0].Post_installation_call_completed_by__c;
            
            List<Task> restOfTheTasks = [Select id from Task where WhatId = :Trigger.New[0].WhatId];
            
            List<Task> taskToUpdate = new List<Task>();
            
            for(Task t : restOfTheTasks){
                
                if(t.Id != Trigger.New[0].Id && t.Is_post_installation_call_task__c == true){
                
                        t.Date_of_post_call_check_completion__c = Trigger.New[0].Date_of_post_call_check_completion__c;
                        t.Any_Issues_with_Installation__c = Trigger.New[0].Any_Issues_with_Installation__c;
                        t.Post_installation_call_notes__c = Trigger.New[0].Post_installation_call_notes__c;
                        t.Post_installation_call_completed_by__c = Trigger.New[0].Post_installation_call_completed_by__c;
                        t.Issue_description__c = Trigger.New[0].Issue_description__c;
                        t.Status = Trigger.New[0].Status;
                        taskToUpdate.add(t);
                        
                }
                
            }
             
             System.debug('------1---------'+chc);
             
             Database.update(chc);
             
             if(taskToUpdate != null && taskToUpdate.size() > 0){
                
                Database.update(taskToUpdate);
                
             }
            
          }
        
      }
      
   }catch(Exception excp){
    
      System.debug('Could not copy data from task to chc due to an error : '+excp.getMessage());
    
   }  
    // Changes for copying post installation call related details on CHC - Ends
    
    
    Boolean blnSendMail=false; 
    Messaging.SingleEmailMessage[] mailsTask = new Messaging.SingleEmailMessage[]{};
    String strMailBody='';
    Set<String> contactIdSet=new Set<String>{};
    Map<String,Contact> contactMap=new Map<String,Contact>{};
    for(Task objTask1:Trigger.new){
        contactIdSet.add(objTask1.WhoId);    
    }
    for (Contact objContact: [Select Name,OtherPhone, HomePhone, Id From Contact Where Id In: contactIdSet]){
        contactMap.put(objContact.Id,objContact);    
    }
    for (Task objTask:Trigger.new) {
        try {
            if (objTask.Send_Overdue_Task_Email__c==true) {
                Messaging.SingleEmailMessage mailTask = new Messaging.SingleEmailMessage();
                mailTask.setTargetObjectId(objTask.OwnerId);               
                mailTask.setSubject('Task Overdue email to Customer service Team');
                mailTask.setSaveAsActivity(false);
                strMailBody='<HTML><BODY><TABLE><TR><TD>';
                strMailBody= strMailBody + '<IMG SRC="https://cs2.salesforce.com/resource/1271663989000/British_Gas_Logo" alt="British Gas Logo"/></TD>';
                strMailBody= strMailBody + '<TD></TD></TR></TABLE><BR><BR><P>';
                strMailBody=strMailBody + 'Please find the contact details below:';
                try {
                    String sHomePhone=contactMap.get(objTask.WhoId).HomePhone;
                    String sWorkPhone=contactMap.get(objTask.WhoId).OtherPhone;
                    sHomePhone=(sHomePhone==null? '': sHomePhone);
                    sWorkPhone=(sWorkPhone==null? '': sWorkPhone);
                    strMailBody=strMailBody + '<TABLE><TR><TD>Contact Name:</TD><TD>' + contactMap.get(objTask.WhoId).Name + '</TD></TR>';
                    strMailBody=strMailBody + '<TR><TD>Home Phone:</TD><TD>' + sHomePhone+ '</TD></TR>';
                    strMailBody=strMailBody + '<TR><TD>Work Phone:</TD><TD>' + sWorkPhone+ '</TD></TR></TABLE>';
                } catch(Exception ex){
                //do nothing
                }
                strMailBody=strMailBody + 'Please find the task which has past the due date. Please follow the link to detail of the task.';
                strMailBody=strMailBody + '<BR><BR><P>Link : <a href="https://cs2.salesforce.com/' + objTask.Id + '" >Click Here</a>';
                strMailBody=strMailBody + '</BODY></HTML>';
                mailTask.setHtmlBody(strMailBody);
                mailsTask.add(mailTask);
                blnSendMail=true;
            }
        } catch(Exception ex){
            objTask.addError(ex.getMessage());    
        }
    }
    try {
        if (blnSendMail==true) {
            Messaging.sendEmail(mailsTask);
        }
    } catch (Exception emailEx) {
        System.debug(emailEx.getMessage());
    }
    */
}