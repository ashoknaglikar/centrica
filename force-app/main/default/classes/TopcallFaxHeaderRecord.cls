global class TopcallFaxHeaderRecord implements Database.Batchable<sObject> {
    /*
    * CLASS - TopcallFaxHeaderRecord
    * AUTHOR - COGNIZANT
    * PURPOSE - The Purpose of this class is to use the batch apex functionality to bulk process the Topcall Attachment data related to the Purchase order 
                and update relevant Purchase order status to Integrated accordingly.
                The class fetches all the order and also the related order details where the topcall fax status is "Awaiting Integration".
                
    */
    List<Order__c> orderList =new List<Order__c>(); 
    private class TopcallFaxRecord{
        /*
            Class: TopcallFaxRecord
            Author: Cognizant
            Purpose: The inner class is used for storing the details of individual attachment for each order.
                        
        */
        public String sPurchaseOrder{get;set;}
        public String sFaxNo {get;set;}
        public String sNewId{get;set;}
        public String sActBodyName{get;set;}
        public String sNewBodyName{get;set;}
        public Blob blbBody{get;set;}
        public String sSequenceNo{get;set;}
    }
    //the static method of the class. The method is called from the scheduled apex class. 
    public static void reconcile(String status){
    	if(status == 'OFF'){
    		return;
    	}
        TopcallFaxHeaderRecord objCopyTopcallAttachment = new TopcallFaxHeaderRecord();
        ID batchprocessid = Database.executeBatch(objCopyTopcallAttachment);
    }
    
    global Integer iCount;
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
         // Auto-generate purchase orders  - If planners have not yet clicked generate purchase order button on job then 
         // all such orders related to this job must be ignorted by topcall interface.
        String sQuery='Select SAP_Number__c,Topcall_Fax_Status__c,Returned_Items__c,Status__c,Supplier_Communication_Preference__c,Delivery_Date_Changed__c,SupplierBranchNum__c,Amendment_Number__c, Supplier_Fax_number__c, Supplier__c,Sync__c,Job_Delivery_Date__c, Id, Fax_Setup__c,Supplier__r.name,Supplier__r.Supplier_Num__c,Supplier__r.P5_Order_Lead_Time__c,Supplier__r.EDI_Tolerance_Value__c,'; 
        sQuery=sQuery +'(Select Id,ParentId, Name From Attachments)'; 
       	sQuery=sQuery + 'From order__c where Fax_Enabled__c=1 And Send_via_email__c = False AND Topcall_Fax_Status__c=\'Awaiting Integration\' and Supplier__r.Supplier_Num__c!= \'2017\'';
     
        return Database.getQueryLocator(sQuery);
    } 
  
    global void execute(Database.BatchableContext BC, List<sObject> lstRecords){
        iCount=0;
        system.debug('lstRecords size--->'+lstRecords.size());
        List<Order__c> tempOrders = new List<Order__c>();
        for(sObject sObj : lstRecords)
            tempOrders.add((Order__c)sObj);
        orderList = this.populateComStatus(tempOrders); 
        
        Set<String> sIdSet =new Set<String>{};
        List<order__c> orderActLst=new List<order__c>{};
        for (order__c objOrderId: orderList) {
            //order__c objOrderId=(order__c)objSobject;
            if(objOrderId.Supplier__c==null){
                continue;
            }
            sIdSet.add(objOrderId.Id);
            orderActLst.add(objOrderId);
        }
         system.debug('orderActLst size--->'+orderActLst.size());
        if (orderActLst.size()>0) {
            Map<String,Attachment> attachmentMap=new Map<String,Attachment>{};
            for (Attachment objAttachmentAct:[Select Id,ParentId, Name,Body,ContentType From Attachment where ParentId In:sIdSet]) {
                attachmentMap.put(objAttachmentAct.Id, objAttachmentAct);               
            }
            system.debug('attachment ID---->'+attachmentMap);
            List<TopcallFaxRecord> topcallClsLst=new List<TopcallFaxRecord>{};
            List<TopcallFaxHeader__c> topcallLst=new List<TopcallFaxHeader__c>{};
            List<Attachment> attachmentLst=new List<Attachment>{};
            TopcallFaxHeader__c objTopcall;
            List<order__c> orderLst=new List<order__c>{};
            TopcallFaxRecord objTopcallHeader;
            system.debug('lstRecords--->'+lstRecords);
            for (order__c objOrder: orderActLst) {
                //order__c objOrder=(order__c)objSobject;
                for (Attachment attachment:objOrder.Attachments){
                    iCount=iCount +1;
                    objTopcallHeader=new TopcallFaxRecord();
                    if (attachmentMap.containsKey(attachment.Id)){
                        objTopcallHeader.blbBody=attachmentMap.get(attachment.Id).Body;
                        objTopcallHeader.sPurchaseOrder=attachment.ParentId;
                        objTopcallHeader.sActBodyName=attachment.Name;
                        objTopcallHeader.sFaxNo=objOrder.Supplier_Fax_number__c;
                        objTopcallHeader.sNewBodyName=generateFileName(iCount,objOrder.SAP_Number__c);
                        objTopcallHeader.sSequenceNo=String.valueOf(iCount);    
                        topcallClsLst.add(objTopcallHeader);
                    }
                }
                system.debug('topcallClsLst-->'+topcallClsLst);
            }
            //Create TopcallFaxHeader Insert List
            for (TopcallFaxRecord objTopcallHeaderLoop: topcallClsLst){
                objTopcall=new TopcallFaxHeader__c();
                objTopcall.Integration_Status__c='Awaiting Integration';
                objTopcall.Purchase_Order__c=objTopcallHeaderLoop.sPurchaseOrder;
                objTopcall.Supplier_Fax_Number__c=objTopcallHeaderLoop.sFaxNo;
                objTopcall.Sequence__c=objTopcallHeaderLoop.sSequenceNo;
                topcallLst.add(objTopcall);
            }
            Savepoint sp = Database.setSavepoint();
            try {
                
                Database.insert(topcallLst, false);
                Attachment objAttachment;
                for (TopcallFaxRecord objTopcallHeaderLoop1: topcallClsLst){
                    for (TopcallFaxHeader__c objTopcall1:topcallLst){
                        if ((objTopcallHeaderLoop1.sSequenceNo==objTopcall1.Sequence__c) && 
                            (objTopcallHeaderLoop1.sPurchaseOrder==objTopcall1.Purchase_Order__c)) {
                            objAttachment=new Attachment(); 
                            objAttachment.ParentId=objTopcall1.Id;
                            objAttachment.Body=objTopcallHeaderLoop1.blbBody;
                            objAttachment.Name=objTopcallHeaderLoop1.sNewBodyName;
                            objAttachment.ContentType='application/pdf';
                            attachmentLst.add(objAttachment);                           
                        }
                    }   
                }
                Database.insert(attachmentLst, false);
                for(order__c objOrderUpdate: orderActLst){
                    objOrderUpdate.Topcall_Fax_Status__c='Integrated'; 
                    if(!objOrderUpdate.Sync__c) 
                        objOrderUpdate.Sync__c = true;
                }
                Database.update(orderActLst, false);
                
                //Database.delete(attachmentMap.values());
            
            }catch(Exception ex){
                System.debug('@Exception : ' + ex.getMessage());
                Database.rollback(sp);
            }
        }
        
    }
    

    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job 
       // from Database.BatchableContext. 
       // Query the AsyncApexJob object to retrieve the current job's information.  
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
       // Send an email to the Apex job's submitter notifying of job completion. 
       /*
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'avishek.kundu@centrica.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Apex Sharing Recalculation ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job processed ' + a.TotalJobItems +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       */
    }
    
    private String generateFileName(Integer iCount, String sapNumber){
        
        String sFileName=formatString(6,iCount);
        String sYear=formatString(4, DateTime.now().year());
        String sMonth=formatString(2, DateTime.now().month());
        String sDay=formatString(2,DateTime.now().day());    
        String sHour=formatString(2, DateTime.now().hour());
        String sMin=formatString(2, DateTime.now().minute());
        String sSec=formatString(2, DateTime.now().second());
        String sMiliSec=formatString(2, DateTime.now().millisecond());
        sFileName = sYear + sDay + sMonth + sHour + sMin + sSec + sMiliSec + '_' + sapNumber + sFileName + '.pdf';
        return sFileName;
        
    }
    
    private String formatString(Integer iFormatMaxLen, Integer iValue){
        String sTemp=String.valueOf(iValue);
        for (Integer iLoop=0;iLoop<(iFormatMaxLen-(sTemp.length()));iLoop++) {
            sTemp='0' + sTemp;
        }
        return sTemp;
    }
    
    /*
      * This method inputs all the eligible orders that are to be sent and process it against the Communication preference table
      * Based on primary or secondary pref a List of orders specific to be sent to Topcall or EDI is returned
      */
      // Added : 14 July : Include the changes for communication preference status
      public List<Order__c> populateComStatus(List<Order__c> lstRecords){
           // List<Order__c> orderList = new List<Order__c>();
            Map<String,Order__c> orderMap = new Map<String,Order__c>();
            Set<String> branchesSet = new Set<String>();
            Map<String,String> ordTypeMap = new Map<String,String>();
            Integer daysBetween =0;
            for(Order__c odrObj : lstRecords){              
                String orderType=''; 
                /*
                    I Initial Order : A Order Amendment  :  R Order Return  :  X Order Cancellation  :  N Notification  :  P RE-PLAN NOTICE
                */
                System.debug('################   '+odrObj.Amendment_Number__c +':'+odrObj.Returned_Items__c +':'+odrObj.Status__c+':'+odrObj.Delivery_Date_Changed__c);
                if(odrObj.Amendment_Number__c ==1 && odrObj.Delivery_Date_Changed__c ==false) 
                    orderType='I'; 
                else if(odrObj.Returned_Items__c != null && odrObj.Returned_Items__c > 0 && odrObj.Amendment_Number__c > 1)
                    orderType='R';
                else if(odrObj.Status__c == 'Cancelled' && odrObj.Amendment_Number__c > 1) 
                    orderType='X';
                else if(odrObj.Delivery_Date_Changed__c && odrObj.Amendment_Number__c >= 1)
                    orderType='P';
                else if(odrObj.Amendment_Number__c > 1) 
                    orderType='A';  
                else
                    orderType='N'; // never used - confirmed by amit agarwal(Steria)        
                
                    
                ordTypeMap.put(odrObj.id,orderType);
                branchesSet.add(odrObj.SupplierBranchNum__c);   
                orderMap.put(odrObj.id,odrObj);
                
            }  
            System.debug('----ordTypeMap & branchesSet & orderMap--------'+ordTypeMap +'   : ' +branchesSet+'   :   '+orderMap);
            List<Communication_Preference__c> commprefList = [Select order_type__c,Supplier_Branch__r.Branch_Num__c,c.Secondary_Destination__c, c.Primary_Destination__c 
                                    From Communication_Preference__c c where 
                                    Supplier_Branch__r.Branch_Num__c in :branchesSet and Order_Type__c in :ordTypeMap.values()];
            List<Communication_Preference__c> tempPrefLst;
            Map<String,List<Communication_Preference__c>> branchPrefMap = new Map<String,List<Communication_Preference__c>>();
            for(String branch : branchesSet){
                tempPrefLst = new List<Communication_Preference__c>();
                for(Communication_Preference__c compref : commprefList){
                    if(branch == compref.Supplier_Branch__r.Branch_Num__c){
                        tempPrefLst.add(compref);
                    }   
                }
                if(tempPrefLst.size() > 0)
                    branchPrefMap.put(branch,tempPrefLst);
            }
            System.debug('----branchPrefMap -----'+branchPrefMap);
            // checking for exclusion criterions
            List<Order__c> onlyUpdate = new List<Order__c>();
            for(Order__c odrObj : lstRecords){          
                String orderType = ordTypeMap.get(odrObj.id);
                
                
                String primPrefType='';
                String secPrefType='';
                List<Communication_Preference__c> prefLst = branchPrefMap.get(odrObj.SupplierBranchNum__c);
                
                if(prefLst != null){
                    for(Communication_Preference__c pref  : prefLst){
                        if(pref.order_type__c == (orderType)){
                            primPrefType = pref.Primary_Destination__c;
                            secPrefType = pref.Secondary_Destination__c;
                            break;
                        }
                    }               
                }
                System.debug('----primPrefType -----'+primPrefType);
                System.debug('----secPrefType -----'+secPrefType);
      if((odrObj.Supplier__r.Supplier_Num__c)!= '2017'){
                              System.debug('Supplier not British Gas ...');
                    Decimal leadTime =odrObj.supplier__r.P5_Order_Lead_Time__c;
                    Decimal ediTolerance =0;
                    if(odrObj.supplier__r.EDI_Tolerance_Value__c != null)                   
                        ediTolerance = odrObj.supplier__r.EDI_Tolerance_Value__c;
                        if(odrObj.Job_Delivery_Date__c!=null)
                    daysBetween = (System.today()).daysBetween(odrObj.Job_Delivery_Date__c);
                    System.debug('daysBetween -->'+daysBetween);
                    
                    
                     /*
                    1) It checks and use the lead time of the supplier first and use the logic of (delivery date - supplier lead time)  < sysdate. 
                    If the value is true then it will proceed further even if delivery date is less than or equal to current date. 
                       If it is false then it will go the point 6.
                    2) On the basis of different order types (A, I , R, N, P) it finds the Primary and secondary destination of the supplier order
                        without looking into the value of EDI tolerance or EDI set up flag. 
                    
                    3) Exit from the logic 
                                    */ 
                    //
                    System.debug('Checking for =================   '+odrObj.id);
                    System.debug('leadTime.intValue()  '+leadTime.intValue());
                    if(((System.today()).addDays(leadTime.intValue())) >= (odrObj.Job_Delivery_Date__c)){
                        System.debug('###########################  step 1 ');
                                if(daysBetween !=null){             
                                if(daysBetween > 0 && daysBetween < ediTolerance){
                                    System.debug('###########################  step 2 ');
                                    odrObj.Supplier_Communication_Preference__c = secPrefType;
                                    odrObj.Topcall_Fax_Status__c = 'Secondary Preference Selected';
                                    
                                    onlyUpdate.add(odrObj);
                                }else{
                                   // if(odrObj.Topcall_Fax_Status__c == '0'){
                                        System.debug('###########################  step 3 ');
                                        if(primPrefType == 'F' || primPrefType == 'f')
                                            orderList.add(odrObj);
                                        else{
                                            System.debug('###########################  step 4 ');
                                            odrObj.Supplier_Communication_Preference__c = secPrefType;
                                            odrObj.Topcall_Fax_Status__c = 'Secondary Preference Selected';
                                            onlyUpdate.add(odrObj);
                                        }
                                   // }
                                 /*   else{
                                        System.debug('###########################  step 5 ');
                                        odrObj.Supplier_Communication_Preference__c = secPrefType;
                                        odrObj.Topcall_Fax_Status__c = 'Secondary Preference Selected';
                                        onlyUpdate.add(odrObj);
                                    }*/
                                }
                                }
                         }
                }
            }
                    
            if(onlyUpdate.size() > 0){
                try{
                    update onlyUpdate;
                }catch(Exception e){
                    System.debug('Exception  = '+e.getMessage());
                }
            }
           return orderList;    
      }
}