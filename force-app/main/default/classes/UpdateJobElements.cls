public with sharing class UpdateJobElements {  
    

    @future (callout=false)
    public static void cancelOrderLinesFuture(List<String> orderIds){
        List<String> orderId = new List<String>();
        
        List<Order_Line_Item__c> itemList =[Select id,o.P5_Status_c__c, o.P5_Purchase_Order__c From Order_Line_Item__c o where P5_Purchase_Order__c in :orderIds and P5_Status_c__c !='Cancelled'];

        if(itemList.size() > 0){
            for(Order_Line_Item__c orderLine : itemList)
                orderLine.P5_Status_c__c = 'Cancelled';
            try{
                update itemList;
                
            }catch(DMLException e){
                System.debug('-Cant cancel Order Lines-'+e);
            }
        }   
    }






    @future (callout=false)
    // should cancel Job ELments , Orders and Order Line Items
    public static void cancelJobElementsFuture(Set<String> jobIDs) {
        boolean insertJBH = false;
        List<Job_Element__c> toUpdate = new List<Job_Element__c>();
        List<String> jList = new List<String>();
        List<Installer__c> instList = new List<Installer__c>();
        Job__c[] jobList = [Select id,CHI_Lead__r.Platform__c, (Select Id, Type__c, Status__c, Sub_Status__c From Job_Elements1__r where Status__c != 'Cancelled' ), 
                        (Select Id, Job__c,Installer_Status__c from User_Jobs__r where  Installer_Status__c != 'Inactive') from JOb__c where id in:jobIDs];
        System.debug('#######################################   '+jobList.size());
        for(Job__c newJob : jobList){
            jList.add(newJOb.id);
            for(Job_Element__c je : newJob.Job_Elements1__r){    
            	//added as a part of Parallel Run Functionality
            	if(newJob.CHI_Lead__r.Platform__c != 'Premier')  
            	{         
                	je.Status__c = 'Cancelled'; // Phase 5 Update
            	}
                toUpdate.add(je);            
                if(je.type__c == 'Material')
                    insertJBH = true;
                    
            }
            System.debug('#######################################   '+toUpdate.size());
            for(Installer__c installers : newJob.User_Jobs__r){
                installers.Installer_Status__c = 'Inactive';
                instList.add(installers);  
            } 
            System.debug('#######################################   '+instList.size());          
        }
    
        if(toUpdate.size() > 0){
            try{
                update toUpdate;
                System.debug('#######################################   '+toUpdate.size()); 
                // Updated with static boolean to prevent adding JBH twice
                if(insertJBH && Lock.insertJBH) { 
                    List<Job_Booking_History__c> bookHis = new List<Job_Booking_History__c>();
                    for(String jId : jobIDs)
                        bookHis.add(new Job_Booking_History__c (Job__c = jId, Materials_Affected__c = true));
                    insert (bookHis);
                    // update static variable so this isn't triggered on second run of trigger
                    Lock.insertJBH = false;
                }
            }catch(Exception e){
                System.debug('###  exception '+e);
            }
        }
        if(instList.size() > 0){
            try{
                update instList;
                for(Job__c job :jobList)
                    JobBookingManager.suspendJob(job);
                System.debug('##################success 1  #####################   ');
                JobSharingCls.createJobSharing(jList);
                System.debug('################## success 2  #####################   ');
            }
            catch(Exception ex){
                System.debug('@ Error cacelling installers @ '+instList);
            }
        }
    }
    





    @future (callout=false)
    public static void suspendJobElementsFuture(ID jobID, Boolean updateMatItems) {
        boolean workAffected = false;
        boolean materialsAffected = false;
        List<Job_Element__c> toUpdate = new List<Job_Element__c>();
        
        List<Job_Element__c> JEs = [Select Id, Type__c, Status__c, Order__c,Sub_Status__c From Job_Element__c where job__c=:jobID and Status__c != 'Suspended'];
         System.debug('#######################################   '+JEs.size());
        for(Job_Element__c je : JEs){
            if((je.Status__c == 'Active'||je.Status__c == 'New') && je.type__c == 'Work'){
            	je.Order__c= null;
            	je.Sub_Status__c = 'Awaiting Order';
                je.Status__c = 'Suspended';
                workAffected = true;
                toUpdate.add(je);
            }else if( updateMatItems &&  je.type__c == 'Material' && (je.status__c == 'Active' ||je.Status__c == 'New')){
                je.Status__c = 'Suspended';
                je.Order__c= null;
            	je.Sub_Status__c = 'Awaiting Order';
                materialsAffected = true;
                toUpdate.add(je);
            }
        }
        System.debug('#######################################   '+toUpdate.size());
        if(toUpdate.size() > 0){
            try{
                update toUpdate;
                System.debug('##################success#####################   '+toUpdate);
                // Updated with static boolean to prevent adding JBH twice
                if((workAffected || materialsAffected) && Lock.insertJBH) {
                    insert (new Job_Booking_History__c (Job__c = jobID, Materials_Affected__c = materialsAffected, Work_Affected__c = workAffected));
                    // update static variable so this isn't triggered on second run of trigger
                    Lock.insertJBH = false;
                }
            }catch(Exception e){
                System.debug('###  exception '+e);
            }
        } 
        //Phase 5 functionality - cancel orders
       
        System.debug('################## updateMatItems  #####################   '+updateMatItems);
        List<String> oIds = new List<String>();
        //ADDED BUG FIX FOR FUNCTIONALITY: CANCEL ITINERARY ORDERS ALSO ON JOB SUSPENSION: START: DATE: 17-Feb-2011.
        //FETCHING OLI IN BELOW SOQL: ADDED SUBQUERY.
        List<Order__c> orderList = [select Order_Value__c,P5_Order_Cancellation_Date__c,Cancelled_by__c,status__c,Type__c,id,
        							(Select Order_Line_Item_Number__c, P5_Type__c, P5_Vat_Amount__c, Qty__c From Order_Line_Items__r LIMIT 2) 
        							from Order__c where JOb__c =:jobId and status__c !='Cancelled'];
        //ADDED BUG FIX FOR FUNCTIONALITY: CANCEL ITINERARY ORDERS ALSO ON JOB SUSPENSION: END: DATE: 17-Feb-2011.
        System.debug('################## orderList #####################   '+orderList.size());
        if(orderList.size() > 0){
        	List<Order__c> updOrderList = new List<Order__c>();
        	 for(Order__c order : orderList){
        	 	/*if(updateMatItems && order.Type__c == 'Material'){
        	 		updOrderList.add(order);
        	 		
        	 	}else if(order.Type__c == 'Work' || order.Type__c == 'Itinerary'){
        	 		updOrderList.add(order);
        	 		 
        	 	}*/
        	 	//ADDED BUG FIX FOR FUNCTIONALITY: CANCEL ITINERARY ORDERS ALSO ON JOB SUSPENSION: START: DATE: 17-Feb-2011.
        	 	//COMMENTED ABOVE BLOCK AND ADDED BELOW SECTION.
        	 	
        	 	if(updateMatItems && order.Type__c == 'Material'){
        	 			updOrderList.add(order);
        	 	}
        	 	else if(updateMatItems && order.Type__c == 'Itinerary'){
    	 			String oliType = null;
    	 			for(Order_Line_Item__c oli : order.Order_Line_Items__r){
    	 				if(oli.P5_Type__c.trim() != null && oli.P5_Type__c.equalsIgnoreCase('Material')){
    	 					oliType='Material';
    	 				}
    	 			}
    	 			if(oliType != null){
    	 				updOrderList.add(order);
    	 			}
        	 	}       	 		
        	 	else{
        	 		if(order.Type__c == 'Work'){
        	 			updOrderList.add(order);
        	 		}else if(order.Type__c == 'Itinerary'){
        	 			String oliType = null;
        	 			for(Order_Line_Item__c oli : order.Order_Line_Items__r){
        	 				if(oli.P5_Type__c.trim() != null && oli.P5_Type__c.equalsIgnoreCase('Work')){
        	 					oliType='Work'; 
        	 				}
        	 			}
        	 			if(oliType != null){
        	 				updOrderList.add(order);
        	 			}
        	 		}        	 		
        	 	}
        	 	//ADDED BUG FIX FOR FUNCTIONALITY: CANCEL ITINERARY ORDERS ALSO ON JOB SUSPENSION: END: DATE: 17-Feb-2011.
        	 }
        	
            for(Order__c order : updOrderList){
                order.status__c = 'Cancelled';
                order.Order_Value__c = 0;
                order.P5_Order_Cancellation_Date__c = System.Today();
                Order.Cancelled_by__c = UserInfo.getUserId();
                oIds.add(order.id);
            }
            try{                 
                List<Order_Line_Item__c> itemList =[Select id,o.P5_Status_c__c, o.P5_Purchase_Order__c From Order_Line_Item__c o where P5_Purchase_Order__c in :oIds and P5_Status_c__c !='Cancelled'];
                
                if(itemList.size() > 0){
                    for(Order_Line_Item__c orderLine : itemList)
                        orderLine.P5_Status_c__c = 'Cancelled';
                    try{
                        update itemList;
                    }catch(DMLException e){
                        System.debug('-Cant cancel Order Lines-'+e);
                    }
                } 
                update updOrderList;  
                //Calling class to regenerate the TopCall FAX Header              
                Pagereference pgRef=new Pagereference('/apex/FaxPageGenerate?jid=' +jobID );
	            pgRef.setRedirect(true);
            }catch(DMLException e){
                System.debug('-Cant cancel Order-'+e);
            }
        }
    }
    
    @future (callout=false)
    public static void unsuspendJobElementsFuture(ID jobID) {
        List<Job_Element__c> toUpdate = new List<Job_Element__c>();
        Job__c newJob = [Select (Select Id, Type__c, Status__c, Sub_Status__c From Job_Elements1__r) From Job__c j where id=:jobId];
        for(Job_Element__c je : newJob.Job_Elements1__r){
            if(je.Status__c == 'Suspended'){
                je.Status__c = 'Active';
                je.Sub_Status__c = 'Awaiting Planning';
                toUpdate.add(je);
            }
        }
        
        if(toUpdate.size() > 0)
            update toUpdate;
    }

}