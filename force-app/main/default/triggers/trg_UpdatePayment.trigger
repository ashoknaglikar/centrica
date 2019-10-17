trigger trg_UpdatePayment on Payment_Collection__c (after update) {
    
    //PRB00032289
     if(cls_IsRun.transferhrstrg)
     {
         return;
     }
    
    /*
        Developed By Cognizant
        This triggers performs once the Payment Collection Note(PCN) is set to Complete.
        Action Performed:
        PHASE 4 FUNCTIONALITY
        ----------------------
        Once the PCN is set complete, the payments record created as child of PCN will be 
        copied to the BGS_Payment record. Once a record has been synced with the BGS_Payment
        the records will not be synced with the BGS_Payment again.
        If further records are added to child of PCN, the records are immediately synced with 
        BGS_Payment.
        
        A new record is also created in Job Booking History for the integration with Premier
        
        PHASE 5 FUNCTIONALITY
        ---------------------
        Once a PCN is complete and Reason for Discrepancy is Dispute, a new case record will be
        created with recordtype of "Payment Discrepancy". It will be used to track the discrepancy
        with the customer for payments. 
        Amended 11/10/2010:--
        Changed and added a new field update on CHI Lead i.e. Last Installation date.
    
    */
    //PHASE 4 FUNCTIONALITY
    //========================
    if(!cls_IsRun.istrg_UpdatePayment)
    {
        cls_IsRun.setistrg_UpdatePayment();
    }   
    
    Integer iCount=0;
    List<BGS_Payment__c> lst_OppPayment=new List<BGS_Payment__c>{};
    BGS_Payment__c obj_OppPayment;
    Set<Id> set_PayCollId=new Set<Id>{}; 
    Set<Id> Set_OppId=new Set<Id>{};
    Map<String,Payment_Collection__c> map_PayColl=new Map<String,Payment_Collection__c>{};
    //List<Job_Booking_History__c> lst_JobBookingHistory=new List<Job_Booking_History__c>{};
   // Job_Booking_History__c obj_JobBookingHistory;
    Date Installationdate;
    Decimal Finalbalance =0.0;
    Decimal finalquotenet = 0.0;
    // Cognizant support fix - create one jbh per pcn instead of every payment record under it.
    //Map<ID,Job_Booking_History__c> jobAndJBHMap = new Map<ID,Job_Booking_History__c>();
    // Update Unbilled reason code filed on CHI lead
    map<string, string> chiLeadPaymentMap = new map<string, string>();
    Map<id,boolean> oppNPSSentMap = new Map<id,boolean>();
    //Recordtype Ids are fetched from recordtype helper class. For updating CHI Lead Unbiulled Reason
    string cardRTId = RecordTypeIdHelper.getRecordTypeId('Payments__c','Card'); 
    string onlineRTId= RecordTypeIdHelper.getRecordTypeId('Payments__c','Online Card'); 
    string chequeRTId= RecordTypeIdHelper.getRecordTypeId('Payments__c','Cheque'); 
    //code fix - starts as part of too many soql 
    List<Opportunity> oppList = new List<Opportunity> {};
    List<Payments__c> lstPayment = new List<Payments__c> {};
    //code fix - ends as part of too many soql 
    Map<Id, Payment_Collection__c> CHILeadPaymentsMap = new Map<Id, Payment_Collection__c> ();
    
    
    for (Payment_Collection__c obj_PayCollection:Trigger.new){
        if ((obj_PayCollection.Payment_Collection_Status__c=='Complete')) {
            set_PayCollId.add(obj_PayCollection.Id);
            map_PayColl.put(obj_PayCollection.Id,obj_PayCollection);
            Set_OppId.add(obj_PayCollection.Opportunity__c);
            Installationdate = obj_PayCollection.Job_Installation_Date__c;
            Finalbalance = obj_PayCollection.Balance_Outstanding__c;
            finalquotenet  = obj_PayCollection.Quote_Nett_Amount__c;
            CHILeadPaymentsMap.put(obj_PayCollection.Opportunity__c, obj_PayCollection);
            
            /*
            // Cognizant support fix starts- create JBH for pure finance jobs
            if((Trigger.oldMap.get(obj_PayCollection.ID)).Payment_Collection_Status__c!='Complete' &&
               obj_PayCollection.Total_Number_of_Collection__c==0 && 
               obj_PayCollection.Financed_Amount__c>0.0){
                //Populate Job History Booking Record
                obj_JobBookingHistory=new Job_Booking_History__c();
                obj_JobBookingHistory.Interface_Action__c='';
                obj_JobBookingHistory.Interface_Status__c='Awaiting Integration';
                obj_JobBookingHistory.Interface_Status_Reason__c='';
                obj_JobBookingHistory.Payment_Collection__c=true;
                obj_JobBookingHistory.Job__c=obj_PayCollection.Job__c;
                
                if(!jobAndJBHMap.containsKey(obj_PayCollection.Job__c)){
                    lst_JobBookingHistory.add(obj_JobBookingHistory);
                    jobAndJBHMap.put(obj_PayCollection.Job__c,obj_JobBookingHistory);
                }
            }*/
            // Cognizant support fix - end of this part.
           
           /*Date: 18/11/11 
           CR for NPS sent date capture. set it to todays date when sentOnlineNPSForm__c = true.*/
           if((Trigger.oldMap.get(obj_PayCollection.ID)).sentOnlineNPSForm__c!=true && obj_PayCollection.sentOnlineNPSForm__c == true)
           {
                if(!oppNPSSentMap.containskey(obj_PayCollection.Opportunity__c))
                {
                    oppNPSSentMap.put(obj_PayCollection.Opportunity__c, true);
                }
            
           }
        }
    }
    //code fix - starts as part of too many soql 
    if (set_PayCollId.size()>0){
    lstPayment=[Select Id,  ePDQ_Authorisation_Code__c, BGS_Special_Reference_ID__c, 
                                    Sort_Code__c, RecordType.Name,  RecordTypeId,  Payment_Date__c, 
                                    Cheque_Number__c,Is_Online_Payment__c,Status__c,  Bank_Name__c,  Amount_Collected__c,
                                    Payment_Collection_Notice__c,IsSynced__c,Payment_Type__c,Payment_Collection_Notice__r.Opportunity__c From Payments__c
                                    where Payment_Collection_Notice__c In:set_PayCollId and IsSynced__c=false order by CreatedDate];
    }
    if (Set_OppId.size()>0)
    {
    oppList=[Select Id,isSystem__c,Final_Quote_Nett_Amount__c,PCN_Status__c,Final_Balance_to_Collect__c ,Last_Installation_Date__c,LastModifiedDate,sentOnlineNPSFormDate__c From Opportunity where Id In:Set_OppId];
    }
    //code fix - ends as part of too many soql 
    System.debug('opplist-->'+oppList+lstPayment.size()); 
                                    
    if(lstPayment==null) {
        //do nothing
    }else if (lstPayment.size()==0){
        //do nothing
    }else {
        for (Payments__c obj_Payment:lstPayment) {
            obj_OppPayment=new BGS_Payment__c();
            obj_OppPayment.EPDQ_Authorisation__c=obj_Payment.ePDQ_Authorisation_Code__c;
            
            obj_OppPayment.Sort_Code__c=obj_Payment.Sort_Code__c;
            obj_OppPayment.Payment_Type__c=obj_Payment.RecordType.Name;
            obj_OppPayment.Payment_Method__c=obj_Payment.RecordType.Name;
            obj_OppPayment.Is_Online_Payment__c=obj_Payment.Is_Online_Payment__c;
            obj_OppPayment.Status__c=obj_Payment.Status__c;
            obj_OppPayment.Payment_Date__c=obj_Payment.Payment_Date__c; 
            obj_OppPayment.Cheque_Number__c=obj_Payment.Cheque_Number__c;
            obj_OppPayment.Bank_Name__c=obj_Payment.Bank_Name__c;
            obj_OppPayment.Amount__c=obj_Payment.Amount_Collected__c;
            obj_OppPayment.Payment_Type__c=obj_Payment.Payment_Type__c;
            obj_OppPayment.BGS_Special_Reference_ID__c=obj_Payment.BGS_Special_Reference_ID__c;
            obj_OppPayment.BGS_Payment_Reference_Num__c=map_PayColl.get(obj_Payment.Payment_Collection_Notice__c).BGS_Payment_Reference_Num__c;
            obj_OppPayment.Opportunity__c=map_PayColl.get(obj_Payment.Payment_Collection_Notice__c).Opportunity__c;
            obj_Payment.IsSynced__c=true;
            Finalbalance = map_PayColl.get(obj_Payment.Payment_Collection_Notice__c).Balance_Outstanding__c;
            lst_OppPayment.add(obj_OppPayment);
            //Populate Job History Booking Record
            if(!chiLeadPaymentMap.containskey(obj_Payment.Payment_Collection_Notice__r.Opportunity__c))
            {
                chiLeadPaymentMap.put(obj_Payment.Payment_Collection_Notice__r.Opportunity__c, obj_Payment.RecordtypeId);
            }
            /*
            // Cognizant support fix.
            if(!jobAndJBHMap.containsKey(map_PayColl.get(obj_Payment.Payment_Collection_Notice__c).Job__c)){
                
            obj_JobBookingHistory=new Job_Booking_History__c();
            obj_JobBookingHistory.Interface_Action__c='';
            obj_JobBookingHistory.Interface_Status__c='Awaiting Integration';
            obj_JobBookingHistory.Interface_Status_Reason__c='';
            obj_JobBookingHistory.Payment_Collection__c=true;
            obj_JobBookingHistory.Job__c=map_PayColl.get(obj_Payment.Payment_Collection_Notice__c).Job__c;
            lst_JobBookingHistory.add(obj_JobBookingHistory);
            jobAndJBHMap.put(map_PayColl.get(obj_Payment.Payment_Collection_Notice__c).Job__c,obj_JobBookingHistory);
            
            }*/
            
        }
        
        
        if (lst_OppPayment==null) {
            // do nothing
        } else {
            if (lst_OppPayment.size()>0) {
                insert lst_OppPayment;
            }   
        }
        
        update lstPayment;
            
    }
/*
   // Cognizant support fix.
   if (lst_JobBookingHistory==null) {
            // do nothing
        } else {
            if (lst_JobBookingHistory.size()>0) {
                insert lst_JobBookingHistory;
            }   
        }

*/
    try {

        for (Payment_Collection__c obj_Payment:Trigger.new) {

            //Create an approval request for the Payment Collection

            Approval.ProcessSubmitRequest appRequest = new Approval.ProcessSubmitRequest();

            appRequest.setComments('Submitting request for approval');

            appRequest.setObjectId(obj_Payment.id);

            //Submit the approval request for the Payment Collection

            Approval.ProcessResult result = Approval.process(appRequest);

        }

    } catch(Exception ex) {

        System.debug(ex.getMessage());

    }
    
    //PHASE 5 FUNCTIONALITY
    //========================
    /*List<Case> caseList=new List<Case>{};
    
    String strRecordTypeId=RecordTypeIdHelper.getRecordTypeId('Case', 'Payment Discrepancy');
    Case P5_objCase=new Case();
    
    Database.DMLOptions P5_dmoCase = new Database.DMLOptions(); 
    P5_dmoCase.emailHeader.triggerUserEmail=true; 
    P5_dmoCase.assignmentRuleHeader.useDefaultRule = true;
    for (Payment_Collection__c objPCN:Trigger.new) {
        if (objPCN.Payment_Collection_Status__c=='Complete' &&(objPCN.Balance_Outstanding1__c > 5.00 ||objPCN.Balance_Outstanding1__c < -5.00) && (objPCN.Reason_for_Discrepancy__c !='')) {
           
            P5_objCase=new Case();
            P5_objCase.RecordTypeId=strRecordTypeId;
            P5_objCase.Origin='Payment Dispute';
            P5_objCase.Status='New';
            P5_objCase.Priority='Medium';
            P5_objCase.AccountId=objPCN.Account__c;
            P5_objCase.ContactId=objPCN.Contact__c;    
            P5_objCase.Opportunity__c=objPCN.Opportunity__c;
            P5_objCase.Job__c=objPCN.Job__c;
            P5_objCase.Disputed_Amount__c=objPCN.Balance_Outstanding1__c;
            P5_objCase.Subject=objPCN.Reason_for_Discrepancy__c;
            P5_objCase.Description=objPCN.Payment_Notes__c;
            P5_objCase.Case_Source__c='Customer';
            P5_objCase.Type='Complaint';
            P5_objCase.Classification__c='Installation';
            P5_objCase.Communication_sub_status__c='Status 1';
            P5_objCase.Issued_To_Group__c='Customer Service';
            P5_objCase.Reason='Instructions not clear';            
            P5_objCase.Reason_Code__c='Complaint';
            
            // Populate PCN field on Case
            P5_objCase.Payment_Collection__c = objPCN.ID;
            
            P5_objCase.setOptions(P5_dmoCase); 
            caseList.add(P5_objCase);
            }  
         // }
       
          
    }
    if (caseList!=null) {
        Database.insert(caseList,P5_dmoCase);    
    }  */
    system.debug('chiLeadPaymentMap--->'+chiLeadPaymentMap);
    for(Opportunity P5_objOpp:oppList ){
                
           P5_objOpp.PCN_Status__c = true;
           P5_objOpp.isSystem__c=true;
           P5_objOpp.Final_Quote_Nett_Amount__c=finalquotenet ; 
           P5_objOpp.Final_Balance_to_Collect__c = Finalbalance;
           if(Installationdate != null){
           P5_objOpp.Last_Installation_Date__c = Installationdate;
           }
           if(chiLeadPaymentMap.containsKey(P5_objOpp.Id))
           {
               if(chiLeadPaymentMap.get(P5_objOpp.Id) == cardRTId || chiLeadPaymentMap.get(P5_objOpp.Id) == onlineRTId)
               {
                    P5_objOpp.Unbilled_Reason__c = 'Job Complete – card';
               }else if(chiLeadPaymentMap.get(P5_objOpp.Id) == chequeRTId)
               {
                    P5_objOpp.Unbilled_Reason__c = 'Job Complete – chq';
               }
               
           }
        
           if(CHILeadPaymentsMap.containskey(P5_objOpp.Id)  && CHILeadPaymentsMap.get(P5_objOpp.Id).Landlord__c != null && CHILeadPaymentsMap.get(P5_objOpp.Id).Landlord__c.contains('Multi'))
           {
                P5_objOpp.Unbilled_Reason__c = 'Job Complete – Multi-premise Landlord';
           }
           
           /*Date: 18/11/11 
           CR for NPS sent date capture. set it to todays date when sentOnlineNPSForm__c = true.*/
           if(oppNPSSentMap.Containskey(P5_objOpp.Id) && oppNPSSentMap.get(P5_objOpp.Id))
           {
                P5_objOpp.sentOnlineNPSFormDate__c = system.today();
           }
           update  P5_objOpp;
            
           }
           
           
    
}