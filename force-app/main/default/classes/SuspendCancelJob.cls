public class SuspendCancelJob { 
    public Opportunity opp;
    public String orderChoice;
    public String s_msg;
    
   // ++ variables created for PTS CR start
   public Boolean isPTSEnabled {get; set;} // variable decides whether redirect to PTS or not
   public String deliverDate {get; set;} // holds Delivery Date in dd/mm/yyyy format
   Map<Id,String> newDeliveryIdMap = new Map<Id,String>(); // stores DeliveryId after cancelling slot in PTS
   public List<Job__c> suspendJobList {get; set;} // list of Jobs related to CHI Lead except downtime jobs
   MessageConstants messageConst = new MessageConstants();
   // -- variables created for PTS CR end
   
    public String getS_msg(){
        return this.s_msg;
    }   
    public void setS_msg(String val){
        if(val != null && val != '')
            this.s_msg = val;
    }
    public List<SelectOption> getChoices() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Work','Work'));
        options.add(new SelectOption('Material','Material'));
        options.add(new SelectOption('All','All'));
        return options;
    }
        
    public String getorderChoice() {
        return this.orderChoice;
    }
        
    public void setorderChoice(String choice) {
        if(choice != null && choice != '')
            this.orderChoice = choice;
    }
    public SuspendCancelJob(){
        
    }
    
    public SuspendCancelJob(ApexPages.StandardController controller){
        this.opp = (Opportunity)controller.getRecord();
        // ++ Added for PTS CR start
        suspendJobList = new List<Job__c>();
        suspendJobList = [Select j.Name , j.Suspend_Job__c, sub_Status__c,Suspension_Reason__c,Suspension_Reason_List__c,
                                Cancel_Merchant_Orders__c,j.Status__c, j.CHI_Lead__c,
                                Is_Downtime_Job__c , DeliveryID__c ,Delivery_Date__c,Formatted_Delivery_Date__c
                                From Job__c j where CHI_Lead__c =:opp.id and Is_Downtime_Job__c =false
                                and DeliveryID__c != null];
        
        // -- Added for PTS CR end
        
    }
    public void cancelJobAndChildren(String oppId){
        this.opp = [select isSystem__c,StageName, Suspension_Reason__c,isClosed , Opportunity_Cancellation_Reason_For_Job__c, Stage_Reason_CHICR__c,Deposit_outcome__c, id from opportunity where id=:oppId];
        this.cancelLead();
    }
    public PageReference suspendLead(){
        System.debug('#  orderChoice  #  '+this.orderChoice);
        if(orderChoice == null || orderChoice == '' ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error : Please select which orders need to be Cancelled');
            ApexPages.addMessage(myMsg);
            this.setS_msg('Error : Please select which orders need to be Cancelled');
            return new PageReference('/apex/SuspendCancelLead?id='+opp.id+'&action=suspend&showdet=true');
        }
        
        // Updated SOQL to fecth updated DeliveryId by PTS system for PTS CR    
        List<Job__c> jobList = [Select j.Suspend_Job__c, sub_Status__c,Suspension_Reason__c,Suspension_Reason_List__c,
                                Cancel_Merchant_Orders__c,j.Status__c, j.CHI_Lead__c,
                                Is_Downtime_Job__c , DeliveryID__c , Delivery_Date__c,Formatted_Delivery_Date__c,
                                (Select Type__c,Name,order__c,id,Status__c,sub_status__c from Job_Elements1__r where Status__c  != 'Suspended'),
                                (Select id from Purchase_Orders__r where Status__c != 'Cancelled' and Status__c != 'Goods Receipted'),
                                (Select Id, Installer_Status__c from User_Jobs__r where Installer_Status__c !='Inactive') 
                                From Job__c j where CHI_Lead__c =:opp.id 
                                and Is_Downtime_Job__c =false];
      
        if(jobList.size() > 0){
            
            // ++ Added for PTS CR start
            for(Job__c job : jobList)
            {
                newDeliveryIdMap.put(job.id , job.DeliveryID__c);
                system.debug('----------newDelMap----'+newDeliveryIdMap);
            }
            if((newDeliveryIdMap != null) && (orderChoice == 'Material' || orderChoice == 'All')&& (System.Label.PTS_Switch == 'On'))
            {
                for(Id jobId : newDeliveryIdMap.keySet())
                {
                    if((newDeliveryIdMap.get(jobId)!= null))
                    {
                        isPTSEnabled = true;
                        ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR,messageConst.ERR_PTS_SLOT_NOT_CANCELLED_IN_PTS);
                        ApexPages.addMessage(msg);
                        return null;
                    }
                }
            }
            // -- Added for PTS CR end
            
            List<String> orderIds = new List<String>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            List<Installer__c> instList = new List<Installer__c>();
            List<JOb_Element__c> elementList = new List<JOb_Element__c>();
            List<String> jobIds = new List<String>();
            
            for(Job__c job : jobList){
                if(job.Status__c != 'Suspended' || job.Status__c != 'Cancelled' || job.Status__c != 'Installed')
                {
                    job.Status__c = 'Suspended';
                    job.sub_Status__c = 'Suspended';
                    job.Suspension_Reason__c='Lead Is Supended'; 
                    job.Suspension_Reason_List__c=(this.opp).Suspension_reason__c; 
                    job.Suspend_Job__c=true;
                    
                    System.debug('# order choice picked = #'+this.orderChoice);
                    
                    if(this.orderChoice == 'Work')
                        job.Cancel_Merchant_Orders__c ='No';
                    else if(this.orderChoice == 'Material')
                        job.Cancel_Merchant_Orders__c ='Yes';
                    else if(this.orderChoice == 'All')
                        job.Cancel_Merchant_Orders__c ='Yes';
                    else
                        job.Cancel_Merchant_Orders__c ='No';
                        
                    for(Job_Element__c je : job.Job_Elements1__r){
                        if(je.Type__c != 'Material' ||(job.Cancel_Merchant_Orders__c == 'Yes' && je.Type__c == 'Material'))
                       { je.Status__c = 'Suspended';
                        je.sub_status__c ='Suspended';
                        elementList.add(je);
                       }
                    }
                    if(this.orderChoice != ''){
                        for(Order__c order : job.Purchase_Orders__r){
                            orderIds.add(order.id);
                        }
                    }
                    for(Installer__c inst : job.User_Jobs__r){
                        inst.Installer_Status__c='Inactive';
                        instList.add(inst);
                    }
                    jobIds.add(job.id);
               }
           }
           
            // code fix done by BGSAMS Support as part of PRB00010155 - starts 
              
           /* List<Order__c> orders = [Select o.Type__c, o.Topcall_Fax_Status__c, o.Status__c, o.SAP_Number__c, o.P5_SAP_Status__c, 
                                    Order_Value__c,o.EDI_Status__c, o.P5_Order_Cancellation_Date__c, o.Cancelled_By__c, (Select P5_Status_c__c, P5_Sub_Status_c__c, 
                                    P5_Type__c From Order_Line_Items__r where P5_Sub_Status_c__c != 'Suspended') From order__c o 
                                    where id in :orderIds]; */
           
                   List<Order__c> orders = [Select o.Type__c, o.Topcall_Fax_Status__c, o.Status__c, o.SAP_Number__c, o.P5_SAP_Status__c, 
                                    Order_Value__c,o.EDI_Status__c, o.P5_Order_Cancellation_Date__c, o.Cancelled_By__c, (Select P5_Status_c__c, P5_Sub_Status_c__c, 
                                    P5_Type__c From Order_Line_Items__r where P5_Status_c__c !='Cancelled') From order__c o 
                                    where id in :orderIds];
           // code fix done by BGSAMS Support as part of PRB00010155 - ends
           
            if(orders.size() > 0){
                for(Order__c ord : orders ){                        
                    boolean entered = false;
                    if(this.orderChoice == 'Work'){
                        if(ord.Type__c == 'Work')
                            entered = true;
                    }else if(this.orderChoice == 'Material'){
                        if(ord.Type__c == 'Material')
                             entered = true;                        
                    }else if(this.orderChoice == 'All')                     
                         entered = true;
                    if(entered == true){
                        ord.Status__c = 'Cancelled';
                        ord.Order_Value__c = 0;
                        ord.P5_Order_Cancellation_Date__c = System.Today();
                        Ord.Cancelled_by__c = UserInfo.getUserId();
                        orderList.add(ord);
                        for(Order_Line_Item__c item : ord.Order_Line_Items__r){
                        // code fix done by BGSAMS Support as part of PRB00010155 - starts  
                        item.P5_Status_c__c = 'Cancelled';
                            /*item.P5_Status_c__c = 'Removed';
                            item.P5_Sub_Status_c__c = 'Suspended';*/
                        // code fix done by BGSAMS Support as part of PRB00010155 - ends
                            oliList.add(item);
                        }
                        for(Job_Element__c je : elementList){
                            if(je.Order__c == ord.id){
                                je.Order__c = null;
                            }
                        }
                    }
                }
            }
            try{
                if(orders.size() > 0){
                    // code fix done by BGSAMS Support as part of PRB00010155 - starts
                    update orders;
                    update oliList;
                    // code fix done by BGSAMS Support as part of PRB00010155 - ends
                   }
                update elementList;
                update instList;
                // ++ Updated for PTS CR start
                if(jobList.size() > 0)
                {
                    update jobList;  
                }
                // -- Updated for PTS CR end            
                String result = suspendOppty();
                       
                for(Job__c job : jobList)
                    JobBookingManager.suspendJob(job);
                    
            }catch(DMLException e){
                System.debug(' - EXCEPTION - '+e);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg); 
                return null;
            }
        }else{
            this.setS_msg('No relevant jobs found to suspend.Only suspended the CHI Lead.');
            String result = this.suspendOppty();
            System.debug('result =======     '+result);
            if(result == 'success'){
                System.debug('# suspend as nothign else matters #'+result);
                PageReference pg = new PageReference('/apex/SuspendCancelLead?id='+opp.id+'&action=cancel&showdet=false');
                pg.setredirect(true);
                return pg;
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,result);
                ApexPages.addMessage(myMsg); 
                return null;
            }
        }
        PageReference pg = new PageReference('/apex/SuspendCancelLead?id='+opp.id+'&action=cancel&showdet=false');
        pg.setredirect(true);
        return pg;
        
    }
    public PageReference cancelLead(){
        
        
        List<Job__c> jobList = [Select j.Suspend_Job__c, sub_Status__c,Suspension_Reason__c,Suspension_Reason_List__c,
                                Cancel_Merchant_Orders__c,j.Status__c, j.CHI_Lead__c, 
                                (Select Type__c,Name,id,Status__c,sub_status__c from Job_Elements1__r where Status__c  != 'Cancelled'),
                                (Select id from Purchase_Orders__r where Status__c != 'Cancelled' and Status__c != 'Goods Receipted'),
                                (Select Id, Installer_Status__c from User_Jobs__r where Installer_Status__c !='Inactive') 
                                From Job__c j where CHI_Lead__c =:opp.Id and Status__c not in ('Cancelled','Installed') and Is_Downtime_Job__c =false];
      
      
        if(jobList.size() > 0){
            List<String> orderIds = new List<String>();
            List<Order_Line_Item__c> oliList = new List<Order_Line_Item__c>();
            List<Order__c> orderList = new List<Order__c>();
            List<Installer__c> instList = new List<Installer__c>();
            List<JOb_Element__c> elementList = new List<JOb_Element__c>();
            List<String> jobIds = new List<String>();
            
            for(Job__c job : jobList){
                job.Status__c = 'Cancelled';
                job.sub_status__c='Cancelled';
                job.Cancellation_Reason__c=(this.opp).Opportunity_Cancellation_Reason_For_Job__c;
                job.Cancel_Merchant_Orders__c ='Yes';
                
                for(Job_Element__c je : job.Job_Elements1__r){
                    je.Status__c = 'Cancelled';
                    je.Sub_Status__c = 'Returned';
                                   
                    elementList.add(je);
                }
                if(this.orderChoice != ''){
                    for(Order__c order : job.Purchase_Orders__r){
                        orderIds.add(order.id);
                    }
                }
                for(Installer__c inst : job.User_Jobs__r){
                    inst.Installer_Status__c='Inactive';
                    instList.add(inst);
                }
                jobIds.add(job.id);
            }
           List<Order__c> orders = [Select o.Type__c, o.Topcall_Fax_Status__c, o.Status__c, o.SAP_Number__c, o.P5_SAP_Status__c, 
                                    Order_Value__c,o.EDI_Status__c, o.P5_Order_Cancellation_Date__c, o.Cancelled_By__c, (Select P5_Status_c__c, P5_Sub_Status_c__c, 
                                    P5_Type__c From Order_Line_Items__r where P5_Sub_Status_c__c != 'Suspended') From order__c o 
                                    where id in :orderIds];
           
            if(orders.size() > 0){
                for(Order__c ord : orders ){ 
                    ord.Status__c = 'Cancelled';
                    ord.Order_Value__c = 0;
                    ord.P5_Order_Cancellation_Date__c = System.Today();
                    Ord.Cancelled_by__c = UserInfo.getUserId();
                    orderList.add(ord);
                    for(Order_Line_Item__c item : ord.Order_Line_Items__r){
                        item.P5_Status_c__c = 'Cancelled';
                        item.P5_Sub_Status_c__c = 'Returned';
                        oliList.add(item);
                    }
                    for(Job_Element__c je : elementList){
                        if(je.Order__c == ord.id){
                            je.Order__c = null;
                        }
                    }
                }
            }
            try{
                if(orders.size() > 0){
                    update oliList;
                    update orders;
                }
                update elementList;
                update instList;
                update jobList;                
                String result = CancelOppty();
                       
                for(Job__c job : jobList)
                    JobBookingManager.suspendJob(job);
                    
            }catch(DMLException e){
                System.debug(' - EXCEPTION - '+e);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg); 
                return null;
            }
        }else{
            this.setS_msg('No relevant jobs found to cancel.Only Closed Lost the CHI Lead.');
            String result = this.CancelOppty();
            if(result == 'success'){
                System.debug('# suspend as nothign else matters #'+result);
                PageReference pg = new PageReference('/apex/SuspendCancelLead?id='+opp.id+'&action=cancel&showdet=false');
                pg.setredirect(true);
                return pg;
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,result);
                ApexPages.addMessage(myMsg); 
                return null;
            }
        }
        PageReference pg = new PageReference('/apex/SuspendCancelLead?id='+opp.id+'&action=cancel&showdet=false');
        pg.setredirect(true);
        return pg;
    }
    
   
    public String suspendOppty(){
        String res = '';
        Opportunity opps = [select isSystem__c,StageName, Suspension_Reason__c,isClosed ,Deposit_outcome__c, id from opportunity where id=:opp.id];
        if(opps.StageName != 'Suspended' && !(opps.isClosed)){
            opps.StageName = 'Suspended';
            opps.Suspension_Reason__c = (this.opp).Suspension_Reason__c;
            opps.Deposit_outcome__c = (this.opp).Deposit_outcome__c; //Change by Ashok G
            opps.isSystem__c =true;
            try{
                update opps;
                res ='success';
            }catch(DMLException e){
                System.debug(' - EXCEPTION - '+e);
                res = e.getMessage();
            }
        }else{          
            res='success';
        }
        return res;
    }
    public String CancelOppty(){
        String res = '';
        Opportunity opps = [select auto_cancel__c,isSystem__c,StageName ,isClosed , Suspension_Reason__c, Deposit_outcome__c, id from opportunity where id=:opp.id];
        if(!(opps.isClosed) || opps.StageName == 'Suspended'){
            opps.StageName = 'Closed Lost'; 
            opps.Opportunity_Cancellation_Reason_For_Job__c = (this.opp).Opportunity_Cancellation_Reason_For_Job__c;
            opps.Stage_Reason_CHICR__c = (this.opp).Stage_Reason_CHICR__c;
            opps.Deposit_outcome__c = (this.opp).Deposit_outcome__c; //Change by Ashok G
            opps.isSystem__c =true;
        }else{
            opps.auto_cancel__c = false;
            opps.isSystem__c =true;
        }  
            try{
                update opps;
                
                res ='success';
            }catch(DMLException e){
                System.debug(' - EXCEPTION - '+e);
                res = e.getMessage();
            }
        
        return res;
    }
    
    // Method sets variable whcih decides wheteher user is redirected to PTS screen or not
    public void redirectToPTS()
     {
        if(orderChoice == 'Material' || orderChoice == 'All')
        {
            isPTSEnabled = true;
        }
        else
        {
            isPTSEnabled = false;
        }
        
     }
    
}