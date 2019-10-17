/*
* CLASS - EDIStatusUpdate
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to use the batch apex functionality to bulk process orders and 
* update teh EDI status of the orders appropriately
*/
global class EDIStatusUpdate implements Database.Batchable<sObject>{

    List<String> headerList = new List<String>();
    
    public void updateOrders(){
        EDIStatusUpdate objUpdOrder = new EDIStatusUpdate();
        ID batchprocessid = Database.executeBatch(objUpdOrder);
    }

        /*
      *  Input - Current Btch Context
      *  Output - Query Set
      *  Purpose - retrieves the query set to be processed by the current & future batches 
      */ 
      global Database.QueryLocator start(Database.BatchableContext BC){
        date createdDate = system.today().adddays(-2);
        return Database.getQueryLocator('Select e.Id, EDSF7541_Header__r.Processed__c,EDSF7541_Header__r.Transaction_code__c,Amendment_Number__c,e.Customer_Order_No__c From EDSF7541_ACKMNT__c e where CreatedDate >= : createdDate and  EDSF7541_Header__r.processed__c = false' );
      } 

      /*
      *  Input - current batch context and list of records to process
      *  Output - None
      *  Purpose - processes the orders and caretes batch objects and then makes call to methods to create subsequent records
      */ 
      global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
            List<String> sapNumberList = new List<String>();
            Map<String,Integer> amendMap = new Map<String,Integer>();
            // put the sObject in List and sap Number - Amendment in a map
            for(sObject sObjAck : lstRecords){
                EDSF7541_ACKMNT__c ackObj = ((EDSF7541_ACKMNT__c)sObjAck);  
                if(ackObj.Customer_Order_No__c !=null){
                    if(ackObj.Amendment_Number__c != null)              
                        amendMap.put((ackObj.Customer_Order_No__c).trim(),Integer.valueOf(ackObj.Amendment_Number__c));
                    if(ackObj.Amendment_Number__c == null)                  
                        amendMap.put((ackObj.Customer_Order_No__c).trim(),0);
                    sapNumberList.add((ackObj.Customer_Order_No__c).trim());
                }
            } 
            System.debug(' --- chkpnt 1 --- '+amendMap+'  ::::::    '+sapNumberList); 
            // retrieves teh Orders per teh Order acknowledgement records       
            List<Order__c> orderListTemp = new List<Order__c>();
            List<Order__c> orderList = [select id,status__c,SAP_Number__c,Order_Value__c,Sync__c,P5_Order_Cancellation_Date__c,Cancelled_by__c,Synched_to_EDI__c,EDI_Status__c,Amendment_Number__c,SupplierBranchNum__c from Order__c where SAP_Number__c in :sapNumberList and EDI_Status__c != 'awaiting integration'];
            List<Order__c> orderRem = new List<Order__c>();

            Map<string,order__c> orderMap = new Map<string,order__c>();
            for(Order__c order : orderList)
                orderMap.put(order.SAP_Number__c,order);
                
            List<EDSF7541_ACKMNT__c> unsuccessAckObj = new List<EDSF7541_ACKMNT__c>();
          
            
            Set<String> orderIds = new Set<String>();
            
            for(sObject sObjAck : lstRecords){
                EDSF7541_ACKMNT__c ackObj = (EDSF7541_ACKMNT__c)sObjAck; 
                headerList.add(ackObj.EDSF7541_Header__c); 
                System.debug('-------order 1 ---------'+ackObj.Customer_Order_No__c);
                Order__c order = orderMap.get(ackObj.Customer_Order_No__c);
                System.debug('-------order---------'+order);
                if(order != null){
                    if(ackObj.EDSF7541_Header__r.Transaction_code__c == 3100){ 
                        order.Supplier_Acceptance_Status__c = 'Received';
                    }else if(ackObj.EDSF7541_Header__r.Transaction_code__c == 3120){
                        order.Supplier_Acceptance_Status__c = 'Accepted';
                    }else if(ackObj.EDSF7541_Header__r.Transaction_code__c == 3145){
                        order.Supplier_Acceptance_Status__c = 'Rejected';
                        orderRem.add(order);
                    }else if(ackObj.EDSF7541_Header__r.Transaction_code__c == 3170){
                        order.Supplier_Acceptance_Status__c = 'Cancellation Confirmed';                 
                    }
                    if(order.Amendment_Number__c == null || (order.Amendment_Number__c != null && order.Amendment_Number__c <= amendMap.get(order.SAP_Number__c)))
                        order.Amendment_Number__c = amendMap.get(order.SAP_Number__c);
                    if(!order.Sync__c)
                        order.Sync__c=true;
                    order.Synched_to_EDI__c = true;
                    order.EDI_Status__c = 'Integrated'; 
                    //Storing valid orders
                    if(orderIds!= null && !(orderIds.contains(order.id))){
                        orderListTemp.add(order);
                        orderIds.add(order.id);
                    }
                }else{
                    //Storing the invalid ack records
                   
                        unsuccessAckObj.add(ackObj);
                        
                    
                }
            }
            try{
                update orderListTemp;
                System.debug('@sucess : @'+orderList.size());
                if(orderRem.size() > 0)
                   // this.releaseItems(orderRem);
                      update orderRem;
            }catch(Exception e){
                   Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
                   String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                   mail1.setToAddresses(toAddresses);
                   mail1.setSubject('Exception ocurred in updating merchant order EDI status to Integrated');
                   mail1.setPlainTextBody('Exception ocurred in updating merchant order EDI status to Integrated: ' + e.getMessage());
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                   System.debug('exception: '+e);
                
            }
            // Setting the processed field in every header fetched so that they do not get picked up next time by the batch
            if(headerList.size() > 0){
                List<EDSF7541_Header__c> hList = [select id,Processed__c from EDSF7541_Header__c where id in :headerList]; 
                for(EDSF7541_Header__c hdr : hList)
                    hdr.Processed__c = true;
                try{
                    update hList;
                    // Added : to timestamp the Order acknowledgement object in case of error
                    if(unsuccessAckObj.size() > 0){
                        // sending all teh unsuccessfull Ack records to teh method
                        this.updateErrorDesc(unsuccessAckObj);
                    }
                }catch(DMLException e){
                    System.debug('Exception Cannot set integartion status on batch header'+e.getMessage());
                }
            }
            
      }
 /*     private void releaseItems(List<Order__c> orders){
        Set<String> ordSet = new Set<String>();
        for(Order__c ord : orders)
            ordSet.add(ord.id);
        List<Order_Line_Item__c> Ord_lines = [select id,P5_Status_c__c From Order_Line_Item__c o
                                            where P5_Status_c__c not in ('Inactive','Removed','Cancelled')
                                            and P5_Purchase_Order__c in : orders ];
        if(Ord_lines.size() > 0){
            for(Order_Line_Item__c oli : Ord_lines)
                oli.P5_Status_c__c = 'Cancelled';
                
            List<Job_Element__c> elementList = [select id,Status__c,order__c from job_Element__c where order__c in :orders];
            if(elementList.size() > 0){
                for(Job_Element__c je : elementList){
                    je.order__c = null;
                    je.Status__c = 'Active';
                    je.Sub_Status__c = 'Awaiting Order';
                }
                try{
                    update elementList;
                }catch(DMLException e){
                    System.debug('@Exception = @'+e);
                }
            }
            try{
                update Ord_lines;
            }catch(DMLException e){
                System.debug('@Exception = @'+e);
            }
        }
        for(Order__c order : orders){
            order.Status__c = 'Cancelled';
            order.Order_Value__c = 0;
            order.P5_Order_Cancellation_Date__c = System.Today();
            Order.Cancelled_by__c = UserInfo.getUserId();
        }try{
                update orders;
            }catch(DMLException e){
                System.debug('@Exception = @'+e);
            }
            List<Attachment> attachments = [Select id From Attachment a where Parent.Id in :ordSet];
            try{
                if(attachments.size() > 0)
                    delete attachments;
            }catch(Exception e){
                System.debug('Exception : '+e.getMessage());
            }                       
    }  */
    
      private void updateErrorDesc(List<EDSF7541_ACKMNT__c> unsuccessfullObjList){
        for(EDSF7541_ACKMNT__c unsucObj : unsuccessfullObjList){
            unsucObj.Error_Description__c = 'No Order is updated due to faulty Order number.Processed on - '+System.now();
        }
        try{
            update unsuccessfullObjList;
        }catch(Exception e){
            System.debug('Exception :  '+e.getMessage());
        }
      }
      global void finish(Database.BatchableContext BC){
        

      }
}