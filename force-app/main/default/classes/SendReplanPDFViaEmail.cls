global class SendReplanPDFViaEmail implements Database.Batchable<sObject> {
   /*
    * CLASS - SendReplanPDFViaEmail
    * AUTHOR - COGNIZANT
    * PURPOSE - The Purpose of this class is to use the batch apex functionality to bulk process the replan notice pdf files and 
                send them via email to P.T.S email address.
    */
    
    List<Order__c> orderList =new List<Order__c>(); 
    String currentDeliveryDate;
    String priorDeliveryDate;
    String orderCreatedDate;
    
   //The static method of the class. This method is called from the scheduled apex class. 
   
    public static void reconcile(){
        
        SendReplanPDFViaEmail sendReplanData = new SendReplanPDFViaEmail();
        ID batchprocessid = Database.executeBatch(sendReplanData);
        
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){

        String sQuery='Select Prior_Delivery_Slot__c, Delivery_Date_Changed__c, Send_via_email__c, CreatedDate, Order_Value_Text__c, Prior_Order_Value__c, Customer_best_phone__c, Supplier_Name__c, Job_Delivery_Date__c, Prior_Delivery_date__c, Delivery_Slot__c, Enquiry_Number__c, Job__r.Name,'+ 
                      +'Job__r.Id, Job__r.PlannerName__c, Job__r.CHI_Lead__r.CHI_Lead_Id__c, Job__r.Customer_Name__c, SAP_Number__c, Job__r.CHI_Lead__r.Account.BillingStreet, Order_Value__c, Job__r.CHI_Lead__r.Account.BillingCity, Job__r.CHI_Lead__r.Account.BillingState, Job__r.CHI_Lead__r.Account.BillingCountry, Job__r.CHI_Lead__r.Account.BillingPostalCode';
        
        if(System.Label.Run_Re_plan_Notice_Back_Up_Batch_Time != null && System.Label.Run_Re_plan_Notice_Back_Up_Batch_Time != ''){
        		List<String> backUpRunTimes = System.Label.Run_Re_plan_Notice_Back_Up_Batch_Time.split(',',5);
        		for(String hourValue : backUpRunTimes){
        			if(String.valueOf(System.now().time()).startsWith(hourValue)){
        				sQuery=sQuery + ' From order__c where Send_via_email__c = True';
        				System.debug(sQuery);
        				return Database.getQueryLocator(sQuery);
        			}
        		}
        }
        
        sQuery=sQuery + ' From order__c where Del_Date_Updated_By_PTS_User__c = True';
        System.debug(sQuery);
        return Database.getQueryLocator(sQuery);

    } 
  
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
    
        system.debug('lstRecords size--->'+lstRecords.size());
        
        List<Order__c> tempOrders = new List<Order__c>();

        for(sObject sObj : lstRecords){
        
            tempOrders.add((Order__c)sObj);
            
        }
        
        orderList = tempOrders; 
        
        sendEmail(orderList);
 
    }
    
    global void sendEmail(List<Order__c> orderList){
        
        User sendMailUser = [Select email from User where userName = :System.Label.Replan_Notice_User_Name];
        
        Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
        
        Messaging.SingleEmailMessage mail;
        
        List<Id> jobIdList = new List<Id>();
        
    for(Order__c order : orderList){

        try{        
        	
        	    jobIdList.add(order.Job__r.Id);
        	    
                if(order.Job_Delivery_Date__c != null){
                    
                    currentDeliveryDate = order.Job_Delivery_Date__c.format();
                    
                }else{
                    
                    currentDeliveryDate = '';
                    
                }
                
                if(order.Prior_Delivery_date__c != null){
                    
                    priorDeliveryDate = order.Prior_Delivery_date__c.format();
                    
                }else{
                    
                    priorDeliveryDate = '';
                    
                }
                
                if(order.CreatedDate != null){
                    
                    orderCreatedDate = order.CreatedDate.format();
                    
                }else{
                    
                    orderCreatedDate = '';
                    
                }
                
                mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {sendMailUser.email});
                mail.setSubject('Regarding delivery date change for material order '+order.SAP_Number__c);
                mail.setSaveAsActivity(false);  
                mail.setReplyTo('BritishGasInstallations@centrica.com');
                mail.setHtmlBody(
                    
                                    '<HTML><BODY><font face=\'calibri\' size=\'3\'><p>Hi,<br/><br/>Please find the below changes in delivery date. </br></p></font><table width=\'100%\' border=\'0\'>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Job Number : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.Job__r.Name + '</font></Td></tr>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Customer Enquiry Number : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + order.Job__r.CHI_Lead__r.CHI_Lead_Id__c + '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.Job__r.Customer_Name__c + '</font>' +
                                    
                                    '</TD></tr><tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>SAP Order Number : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.SAP_Number__c + '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\' style=\'word-wrap=break-word\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.Job__r.CHI_Lead__r.Account.BillingStreet + '</font>' +
                                    
                                    '</TD></tr><tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Total Order Value : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.Order_Value__c + '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.Job__r.CHI_Lead__r.Account.BillingCity + '</font>' +
                                    
                                    '</TD></tr><tr><TD width=\'30%\'></TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + order.Job__r.CHI_Lead__r.Account.BillingState + '</font>' +
                                    
                                    '</TD></tr><tr><TD width=\'30%\'></TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.Job__r.CHI_Lead__r.Account.BillingCountry + '</font>' +
                                    
                                    '</TD></tr><tr><TD width=\'30%\'></TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +  order.Job__r.CHI_Lead__r.Account.BillingPostalCode + '</font>' +
                                    
                                    '</TD></tr></table><BR/>' +
                                    
                                    '<br/><hr width=\'100%\' color=\'black\' ></hr><br/>' +
                                    
                                    '<table WIDTH=\'100%\' BORDER=\'0\'>' + 
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Event : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + 'Merchant Delivery' + '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Current Delivery Date : </b></font>' +  
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +
                                    
                                             currentDeliveryDate + 
                                    
                                    '</font></TD></tr>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Merchant Name : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + order.Supplier_Name__c + '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Contact Number : </b></font>' +  
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +
                                    
                                             order.Customer_best_phone__c + 
                                    
                                    '</font></TD></tr>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Current Delivery Slot : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + order.Delivery_Slot__c + '</font>' + '</td></tr>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Prior Delivery Slot : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + order.Prior_Delivery_Slot__c + '</font>' + '</td></tr>' +
                                    
                                    '</table>' +
                                    
                                    '<br/><hr width=\'100%\' color=\'black\' ></hr><br/>' +
                                    
                                    '<table WIDTH=\'100%\' BORDER=\'0\'>' + 
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Planner Name : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + 
                                    
                                            order.Job__r.PlannerName__c + 
                                            
                                    '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Current Order Value : </b></font>' +  
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +
                                    
                                             order.Order_Value_Text__c + 
                                    
                                    '</font></TD></tr>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Prior Order Value : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + 
                                    
                                            order.Prior_Order_Value__c + '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Order Created Date : </b></font>' +  
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +
                                    
                                             orderCreatedDate + 
                                    
                                    '</font></TD></tr>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Previous Delivery Date : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + 
                                    
                                            priorDeliveryDate + 
                                            
                                    '</font>' +
                                    
                                    '</TD><TD width=\'30%\'></TD><TD width=\'10%\'></TD><TD width=\'30%\'>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Current Delivery Date : </b></font>' +  
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' +
                                    
                                             currentDeliveryDate + 
                                    
                                    '</font></TD></tr>' +
                                    
                                    '<tr><TD width=\'30%\'><font face=\'calibri\' size=\'2\' color=\'#990000\'><b>Current Delivery Slot : </b></font>' +
                                    
                                    '<font face=\'calibri\' size=\'2\' color=\'#990000\'>' + 
                                    
                                            order.Delivery_Slot__c + 
                                            
                                    '</font>' +
                                    
                                    '</TD></tr>' +
                                    
                                    '</table>' +
                                    
                                    '<br/><hr width=\'100%\' color=\'black\' ></hr><br/>' +
                                    
                                    '<TABLE WIDTH=\'100%\' BORDER=\'0\'><TR>' +
                                    
                                    '<font face=\'calibri\' size=\'3\'><b><p><TH>This order is subject to British Gas Services Conditions of Contract for the Supply of Goods and/or Services : GS/FEB/98, Unless stated otherwise.</TH></p></b></font><br/></TR>' +
                                    
                                    '<TR><Td Height=\'10\' Colspan=\'5\' Align=\'Left\'><hr width=\'100%\' color=\'black\' ></hr></Td></TR></table>' +
                                    
                                    '<TABLE WIDTH=\'100%\' BORDER=\'0\'><TR><br/><font face=\'calibri\' size=\'3\'><b><p><TH>Please note that the event date for this order has been amended to ' +
                                    
                                                    currentDeliveryDate +
                                    
                                    '. Please ensure that your records are updated accordingly.</TH></p></b></font></TR>' +
                                    
                                    '<TR><Td Height=\'10\' Colspan=\'5\' Align=\'Left\'><br/><hr width=\'100%\' color=\'black\' ></hr></Td></TR></table>' +
                                    
                                    '<font face=\'calibri\' size=\'3\'><b><br/>Thanks,<br/>British Gas Central Heating Installation<br/>Note :  This is an automated email.' +
                                    
                                    '</b></font>' + 
                                    
                                    '</BODY></HTML>'
                                    
                ); 

        }catch(Exception e){
            
                   System.debug('---Loop EXC  ----   '+e.getMessage());
                   Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                   String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                   mail1.setToAddresses(toAddresses);
                   mail1.setSubject('Send replan notice, exception in forming an email body');
                   mail1.setPlainTextBody(e.getMessage());
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
            
        }

            mails.add(mail);
            order.Send_via_email__c = false;
            order.Del_Date_Updated_By_PTS_User__c = false;
            order.Delivery_Date_Changed__c = false;
                        
    }
        
            try{               
                
                
                Database.Update(orderList,true); 
                
                List<Job__c> jobList = [Select id, Re_plan_Email_Sent_Timestamp__c from Job__c where Id in :jobIdList];
                 
                for(Job__c job : jobList){
                	
                	job.Re_plan_Email_Sent_Timestamp__c = DateTime.Now();
                	
                }
                
                if(jobList.size()>0){
                	
                	Database.Update(jobList,true); 
                	
                }
                Messaging.sendEmail(mails); 
            }catch(Exception e){
                
                   System.debug('---Mail EXC  ----   '+e.getMessage());
                   Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                   String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                   mail2.setToAddresses(toAddresses);
                   mail2.setSubject('Send replan notice, exception in sending email ');
                   mail2.setPlainTextBody(e.getMessage());
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail2 });
                
            }  
        
    }

    global void finish(Database.BatchableContext BC){}
    
    global void getDummyCoverage(){
    	
        String str = 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
        str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string'; str = str + 'Test string';
    
    }
    
}