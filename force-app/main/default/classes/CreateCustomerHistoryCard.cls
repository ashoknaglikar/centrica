/*
*  Added as part of customer history card change request.
*  CLASS - CreateCustomerHistoryCard
*  AUTHOR - 14 Sep 2011, Cognizant
*  PURPOSE - To create customer history card.
* 
*/
global without sharing class CreateCustomerHistoryCard {
    
    webservice static String createCustHistoryCard(String jobId,boolean ignoreNumCards){
        
        Job__c job; 
        District__c d;
        Commissioning_Report__c gasDoc;
        Payment_Collection__c paymentCollDoc;
        List<Diary_Entry__c> booked;
        
        if(System.Label.Customer_Journey_Flag != 'TRUE'){
        	
 	   	   return 'This change request is turned off at the moment. Please contact your system admin.';
 	   	   
 	    }
 	   
        try{
        	
         if(!jobId.contains('a0n')){
       	  
       	    jobId = 'a0n' + jobId;
      
         } 	

        job = [Select j.Id, j.District__r.Id, 
                             j.CHI_Lead__r.Account.BillingPostalCode, j.Customer_Journey__c, j.Installation_Date__c
                             From Job__c j 
                             where Id = :jobId 
                                               and Is_Downtime_Job__c = false
                                               and Is_Remedial_Job__c = false 
                                               and isCancellation_Job__c = false 
                                               limit 1];
                                               
        d = [Select DHMName__r.DHM_Email_Address__c, 
                    Customer_account_manager__r.email, 
                    Customer_Manager_Email_Address__c 
                    from District__c where Id = :job.District__r.Id limit 1];
        
        }catch(Exception excp){                                       

            return 'We can not create customer history card against this type of job.';
            
        }
        
        Integer count = [Select count() from Customer_history_card__c where Job__r.Id = :jobId];
        
        if(count > 0 && !ignoreNumCards){
            
            return 'There can be only one customer history card for a job.';
            
        }
        
        try{
        	
        	gasDoc = [Select id from Commissioning_Report__c where RecordType.Name = 'Gas Installation Works' and Job_Number__r.Id = :job.Id limit 1];
        	paymentCollDoc = [Select id from Payment_Collection__c where Job__r.Id = :job.Id limit 1];
        	booked = [select Name, Start__c, End__c, Hours__c, Sub_Type__c, ID, Week__r.Employee__r.Name
                                             from Diary_Entry__c where Job__c = :jobID order by End__c desc];
            for(Diary_Entry__c de : booked){
              	if(de.Sub_Type__c == 'Mechanical'){
              		job.Mechanical_Skill_End_Date__c = de.End__c.date();
              		break;
              	}
              }
              
        }catch(Exception excp){                                       

            // Do nothing
            
        }
        
        String postCode = job.CHI_Lead__r.Account.BillingPostalCode;
        
        String postCodeSector = postCode.substring(0,postCode.length()-2);
        
        Postcode_Sector__c postSector = [Select Sub_Patch__r.Name From Postcode_Sector__c where name = :postCodeSector and type__c = 'Installation' limit 1];
        
        Customer_history_card__c custHistCard = new Customer_history_card__c();
        
        custHistCard.Sub_Patch__c = postSector.Sub_Patch__r.Name;
        
        custHistCard.Job__c = job.Id;
        
        job.Customer_Journey_Status_Change_Date__c = Date.today();
        job.DHM_Email_Address__c = d.DHMName__r.DHM_Email_Address__c;
        job.CAM_Email_Address__c = d.Customer_account_manager__r.email;
        job.Customer_manager_email_address__c = d.Customer_Manager_Email_Address__c;
        custHistCard.DHM_Email__c = d.DHMName__r.DHM_Email_Address__c;
        custHistCard.CAM_Email_Address__c = d.Customer_account_manager__r.email;
        custHistCard.Customer_Manager_Email_Address__c = d.Customer_Manager_Email_Address__c;
        
        if(gasDoc != null)
        custHistCard.Job_Completion_Document__c = gasDoc.Id;
        if(paymentCollDoc != null)
        custHistCard.Payment_Collection__c = paymentCollDoc.Id;
        
        if(job.Customer_Journey__c == null || job.Customer_Journey__c == '' ||
           job.Customer_Journey__c == 'Pending welcome call' ||
           job.Customer_Journey__c == 'Welcome call not made – unable to contact customer'){
        
             if(job.Customer_Journey__c == null || job.Customer_Journey__c == '' || job.Customer_Journey__c == 'Pending welcome call'){
             job.Customer_Journey__c = 'Pending welcome call';
             job.Customer_journey_status_index__c = 1;
             custHistCard.Customer_journey_status_index__c = 1;
             }else if(job.Customer_Journey__c == 'Welcome call not made – unable to contact customer'){
             job.Customer_Journey__c = 'Welcome call not made – unable to contact customer';
             job.Customer_journey_status_index__c = 2;
             custHistCard.Customer_journey_status_index__c = 2;
             }
             Database.update(job);
             Database.Insert(custHistCard);
             Customer_journey_event_history__c c = new Customer_journey_event_history__c();
             c.Customer_journey_status__c = job.Customer_Journey__c;
             c.Customer_history_card__c = custHistCard.Id;
             c.Mid_Call_Date__c = job.Mid_Call_Date__c;
             c.Customer_Journey_Status_Change_Date__c = job.Customer_Journey_Status_Change_Date__c;
             Database.Insert(c);
             
        }else{
        	
        	job.Customer_Journey_Status_Change_Date__c = Date.today();
            
            if(job.Customer_Journey__c == 'Welcome call made - 28 day call required'){
            	
            	job.Customer_journey_status_index__c = 3; 
				custHistCard.Customer_journey_status_index__c = 3;
				custHistCard.Mid_call_required__c = 'No';
				custHistCard.Confirmation_of_pre_installation_call_ma__c = 'Yes';
				custHistCard.Customer_Ready_for_installation__c = 'Yes';
			    custHistCard.Any_Issues_with_Installation__c = 'No';
				
            }else if(job.Customer_Journey__c == 'Welcome call made - mid call required'){
            	
				job.Customer_journey_status_index__c = 4; 
				custHistCard.Customer_journey_status_index__c = 4;
				custHistCard.Mid_call_required__c = 'Yes';
				job.Mid_call_date__c = Date.today();
				if(job.Installation_Date__c != null){
					job.Mid_call_date__c = job.Installation_Date__c - 7;
				}
				
            }else if(job.Customer_Journey__c == 'Mid Call failed - 28 day call required'){
            	
            	job.Customer_journey_status_index__c = 5; 
				custHistCard.Customer_journey_status_index__c = 5;
				custHistCard.Mid_call_required__c = 'Yes';
				job.Mid_call_date__c = Date.today();
				if(job.Installation_Date__c != null){
					job.Mid_call_date__c = job.Installation_Date__c - 7;
				}
				custHistCard.Confirmation_of_pre_installation_call_ma__c = 'Yes';
				custHistCard.Customer_Ready_for_installation__c = 'Yes';
			    custHistCard.Any_Issues_with_Installation__c = 'No';
				
            }else if(job.Customer_Journey__c == 'Mid call completed - 28 day call required'){
            	
            	job.Customer_journey_status_index__c = 6; 
				custHistCard.Customer_journey_status_index__c = 6;
				custHistCard.Mid_call_required__c = 'Yes';
				custHistCard.Mid_call_Made__c = true;
				job.Mid_call_date__c = Date.today();
				if(job.Installation_Date__c != null){
					job.Mid_call_date__c = job.Installation_Date__c - 7;
				}
				custHistCard.Confirmation_of_pre_installation_call_ma__c = 'Yes';
				custHistCard.Customer_Ready_for_installation__c = 'Yes';
			    custHistCard.Any_Issues_with_Installation__c = 'No';
				
            }else if(job.Customer_Journey__c == 'Journey completion call failed - unable to contact customer'){
            	
            	job.Customer_journey_status_index__c = 7; 
				custHistCard.Customer_journey_status_index__c = 7;
	            job.Mid_call_date__c = Date.today();
			    custHistCard.Mid_call_required__c = 'Yes';
				custHistCard.Mid_call_Made__c = true;
				custHistCard.Confirmation_of_pre_installation_call_ma__c = 'Yes';
				custHistCard.Customer_Ready_for_installation__c = 'Yes';
				custHistCard.Any_Issues_with_Installation__c = 'No';
				if(job.Installation_Date__c != null){
					job.Mid_call_date__c = job.Installation_Date__c - 7;
				}
				
            }else if(job.Customer_Journey__c == 'Journey completion call not made - customer issues to be resolved'){
            	
            	job.Customer_journey_status_index__c = 8; 
				custHistCard.Customer_journey_status_index__c = 8;
	            job.Mid_call_date__c = Date.today();
			    custHistCard.Mid_call_required__c = 'Yes';
				custHistCard.Mid_call_Made__c = true;
				custHistCard.Confirmation_of_pre_installation_call_ma__c = 'Yes';
				custHistCard.Customer_Ready_for_installation__c = 'Yes';
				custHistCard.Any_Issues_with_Installation__c = 'No';
				if(job.Installation_Date__c != null){
					job.Mid_call_date__c = job.Installation_Date__c - 7;
				}
				
            }else if(job.Customer_Journey__c == 'Journey completion call made – customer issues to be resolved'){
            	
            	job.Customer_journey_status_index__c = 9; 
				custHistCard.Customer_journey_status_index__c = 9;
	            job.Mid_call_date__c = Date.today();
			    custHistCard.Mid_call_required__c = 'Yes';
				custHistCard.Mid_call_Made__c = true;
				custHistCard.Confirmation_of_pre_installation_call_ma__c = 'Yes';
				custHistCard.Customer_Ready_for_installation__c = 'Yes';
				custHistCard.Any_Issues_with_Installation__c = 'No';
				if(job.Installation_Date__c != null){
					job.Mid_call_date__c = job.Installation_Date__c - 7;
				}
				
            }else if(job.Customer_Journey__c == 'Journey completed – 28 day handover'){
	            
	            custHistCard.Customer_journey_status_index__c = 10;
	            job.Customer_journey_status_index__c = 10;
	            job.Have_issues_been_resolved__c = 'Yes';
	            job.Mid_call_date__c = Date.today();
			    custHistCard.Mid_call_required__c = 'Yes';
				custHistCard.Mid_call_Made__c = true;
				custHistCard.Confirmation_of_pre_installation_call_ma__c = 'Yes';
				custHistCard.Customer_Ready_for_installation__c = 'Yes';
				custHistCard.Any_Issues_with_Installation__c = 'No';
				if(job.Installation_Date__c != null){
					job.Mid_call_date__c = job.Installation_Date__c - 7;
				}
				
            }
			
            custHistCard.Welcome_call_made__c = true;
			custHistCard.DHM_Email__c = d.DHMName__r.DHM_Email_Address__c;
            custHistCard.CAM_Email_Address__c = d.Customer_account_manager__r.email;
            custHistCard.Customer_Manager_Email_Address__c = d.Customer_Manager_Email_Address__c;
                    
            Database.update(job);
            
            Database.Insert(custHistCard);
            
            Customer_journey_event_history__c c = new Customer_journey_event_history__c();
            
            c.Customer_journey_status__c = job.Customer_Journey__c;
            
            c.Customer_history_card__c = custHistCard.Id;
            
            c.Mid_Call_Date__c = job.Mid_Call_Date__c;
            
            c.Customer_Journey_Status_Change_Date__c = job.Customer_Journey_Status_Change_Date__c;
            
            Database.Insert(c);
            
        }
        
        return custHistCard.Id;
        
    }

}
// End customer history card change request.