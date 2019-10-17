public with sharing class CancelOrderLineItemsCntrl {
    public Order__c order = new Order__c();
    public List<innerLineItem> lineItemList = new List<innerLineItem>();
    public String result='';
    public boolean selectAll;
    private boolean cancelAll;
    public boolean showDetails=true;
    
    // ++ variables created for PTS CR start
    public Job__c job {get; set;}
    public Boolean isMaterialOrder {get; set;} // variable decides whether redirect to PTS or not
    String jobId;
    order__c purchaseOrder = new order__c();
    String newDeliveryId; // stores DeliveryId after cancelling slot in PTS
    MessageConstants messageConst = new MessageConstants();
   // -- variables created for PTS CR end
    
    public boolean getShowDetails(){
        return this.showDetails;
    }
    public void setShowDetails(boolean val){
        if(val != null){
            this.showDetails = val;
        }
    }
    public CancelOrderLineItemsCntrl(){
        
    }
    public CancelOrderLineItemsCntrl(ApexPages.StandardController controller) {
        order = (Order__c) controller.getRecord();
        
        // ++ Added for PTS CR start
        purchaseOrder = [select id,Type__c from order__c where id =: order.id];
        jobId = ApexPages.currentPage().getParameters().get('jid');
        job = new Job__c();
        if(purchaseOrder.Type__c == 'Material')
        {
            isMaterialOrder = true;
            system.debug('-----isMaterialOrder------'+isMaterialOrder);
        }
        else
        {
            isMaterialOrder = false;
        }
        if(jobId != null)
        {
            job = [select id,Delivery_Date__c , DeliveryID__c,Formatted_Delivery_Date__c from Job__c where id =: jobId];
            
        }
        // -- Added for PTS CR end
    }
    public boolean getSelectAll(){
        return this.selectAll;
    }
    public void setSelectAll(boolean val){
        if(val != null){
            this.selectAll = val;
        }
    }
    public String getResult(){
        return this.result;
    }
    public void setResult(String val){
        if(val != null)
            this.result = val;
    }
    public void setCancelAll(boolean val){
        if(val != null)
            cancelAll = val;
    }
    public boolean getCancelAll(){
        return this.cancelAll;
    }
    public List<innerLineItem> getLineItems(){      
        if(lineItemList.size() > 0)
            return lineItemList;   
        List<Order_Line_Item__c> OLIList = [select id, o.Units__c, o.Total_Amount__c,P5_sub_Status_c__c,P5_Status_c__c, o.Skill__c, o.P5_Unit_Price_c__c, 
                                            o.P5_Type__c, Description__c, o.Code__c, 
                                            o.Name From Order_Line_Item__c o
                                            where P5_Status_c__c not in ('Inactive','Removed','Cancelled')
                                            and P5_Purchase_Order__c =:order.id];
        if(OLIList.size() > 0){
            this.setShowDetails(true);
            for(Order_Line_Item__c oli : OLIList){
                innerLineItem iOLI = new innerLineItem();
                iOLI.isSelected  = false;
                iOLI.ordLineItm = oli;
                lineItemList.add(iOLI);
            }
            return lineItemList;
        }else if(this.getCancelAll() == true && OLIList.size() == 0){   
            this.setShowDetails(false);          
            this.setResult('Order and the selected Order Line Items are successfully Cancelled.');
            return null;
        }else{
            this.setShowDetails(false);
            if(result != '')
                result = '';
            ApexPages.Message myMsg;            
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'No non-cancelled order lines items found for this order.Either there are no line items present or all of them are either Removed or Cancelled');
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    public PageReference cancelOLI(){  
        
        // ++ Added for PTS CR start
        job = [select id,Delivery_Date__c , DeliveryID__c,Formatted_Delivery_Date__c from Job__c where id =: jobId]; // Query Job again to fetch updated DeliveryID by PTS
        newDeliveryId = job.DeliveryID__c;
        if((newDeliveryId != null) && (isMaterialOrder == true)&& (System.Label.PTS_Switch == 'On'))
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR,messageConst.ERR_PTS_SLOT_NOT_CANCELLED_IN_PTS);
            ApexPages.addMessage(msg);
            return null;
        }
        // -- Added for PTS CR end
             
        List<Order_Line_Item__c> ordrLinesList = this.getSelectedLines();
        if(ordrLinesList != null){
            try{
                String res1 = this.cancelOrderLines(ordrLinesList);
                if(res1 == 'success'){
                    List<Attachment> attachments = [Select id From Attachment a where ParentId=:order.id];
                    try{
                        if(attachments.size() > 0)
                            delete attachments;
                        if(this.getCancelAll() == false){
                            //Calling class to regenerate the TopCall FAX Header
                            ApexPages.currentPage().getParameters().put('jid',System.currentPageReference().getParameters().get('jid'));
                            Pagereference pgRef=new Pagereference('/apex/FaxPageGenerate?jid=' + System.currentPageReference().getParameters().get('jid'));
                            pgRef.setRedirect(true);                            
                            return pgRef;
                        } 
                    }catch(Exception e){
                        System.debug('Exception : '+e.getMessage());
                    }                         
                    result = 'Selected Order Line Items are successfully Cancelled.';
                }
                else{
                    if(result != '')
                        result ='';
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error cancelling Order Lines');
                    ApexPages.addMessage(myMsg);
                }
            }catch(DMLException e){
                System.debug('  ##EXCEPTION##  '+e);
            }
        }else{
            if(result != '')
                        result =''; 
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select atleast one Line Item to cancel');
            ApexPages.addMessage(myMsg); 
        }
        return null;        
    }
    private List<Order_Line_Item__c> getSelectedLines(){
        boolean entered =false;
        boolean cancelAll = false;
        List<Order_Line_Item__c> ordrLinesList = new List<Order_Line_Item__c>();
        
        List<innerLineItem> tempInrList = new List<innerLineItem>();
        
        for(innerLineItem iOLI : lineItemList){
            if(iOLI.isSelected != null && iOLI.isSelected){
                ordrLinesList.add(iOLI.ordLineItm);                    
                entered = true;
            }else if(iOLI.isSelected != null && iOLI.isSelected == false){
                tempInrList.add(iOLI);
            }
        }        
        if(entered){
            if(ordrLinesList.size() == lineItemList.size())
                this.setCancelAll(true);
            else
                this.setCancelAll(false);
            
            lineItemList.clear();
            if(tempInrList.size() > 0)
                lineItemList.addAll(tempInrList);
            return ordrLinesList;
        }
        else{
            this.setCancelAll(false);
            return null;
        }
    }
    private String cancelOrderLines(List<order_Line_Item__c> oliList){
        String res ='';
        Integer presentUnits=0;
        Set<String> codeSet = new set<String>();
       if(oliList.size() > 0){
            for(order_Line_Item__c oli : oliList ){
                oli.P5_Status_c__c = 'Cancelled';
                oli.P5_sub_Status_c__c = 'Cancelled';
                codeSet.add(oli.Code__c);
                presentUnits = presentUnits+(oli.Total_Amount__c).intValue();
            }
            try{
                update oliList ;
                System.debug('CANCEL ALLLL   :    '+this.getCancelAll());
                res = this.releaseElements(order,this.getCancelAll(),codeSet,presentUnits);
                //res = 'success';
            }catch(DMLException e){
                System.debug('@Exception = @'+e);
                res = e.getMessage();
            }
        }else{
            res = 'success';
        }
        return res;
    } 
    private String releaseElements(Order__c order,boolean cancelAll,Set<String> codeSet,Integer presentUnits){
        String res ='';
        List<Job_Element__c> elementList = [select id,Status__c,order__c from job_Element__c where order__c =:order.id and code__c in :codeSet and Job__c = :System.currentPageReference().getParameters().get('jid')];
        system.debug('Entered releaseElements. elementList.size() = ' + elementList.size());
        if(elementList.size() > 0){
            for(Job_Element__c je : elementList){
                je.order__c = null;
                je.Status__c = 'Active';
                je.Sub_Status__c = 'Awaiting Order';
            }
            try{
                system.debug('Trying to update elementList');
                update elementList;
                if(cancelAll == true){
                    order.Status__c = 'Cancelled';
                    system.debug('Checking order value/present units = ' + order.Order_Value__c + ' / ' + presentUnits);
                   /* if(order.Order_Value__c == 0 && presentUnits ==0){
                        order.Amendment_number__c += 1;
                        system.debug('Order amendment number incremented (Cancel All)');
                    }*/
                    // TEMP TEST
                    system.debug('order.Amendment_number__c = ' + order.Amendment_number__c);
                    //order.Amendment_number__c -= 1;
                    
                    order.Order_Value__c = 0;
                    
                    order.P5_Order_Cancellation_Date__c = System.Today();
                    Order.Cancelled_by__c = UserInfo.getUserId();
                    update order;
                    res = 'success';
                }else{
                    order.Status__c = 'Amended';
                    system.debug('PresentUnits-->'+presentUnits);
                    if(presentUnits == 0){
                    system.debug('Amendment number --->'+order.Amendment_number__c);
                 /*   if(order.Amendment_number__c != null){
                        order.Amendment_number__c += 1;
                        system.debug('Order amendment number incremented (Amended)');
                        }*/
                    }
                    //order.Order_Value__c = order.Order_Value__c - presentUnits;
                    update order;
                    res = 'success';
                }
                // REMOVED - ADDED TO INCLUDE THE PROFIT/LOSS MARGIN LOGIN
                // COGNIZANT : 19 JULY 2010
                //selectRateForElements profLossObj = new selectRateForElements();
                //profLossObj.materialandLabourcharges(new List<Order__c> {order});
            }catch(DMLException e){
                System.debug('@Exception = @'+e);
                res = e.getMessage();
            }
        }else{
            try{
                order.Status__c = 'Cancelled';
                update order;
                res = 'success';
            }catch(DMLException e){
                System.debug('@Exception = @'+e);
                res = e.getMessage();
            }
            res = 'success';
        }
        return res;
    }
    public PageReference goBack(){
        PageReference pg = new PageReference('/'+order.id);  
        pg.setRedirect(true);
        return pg;      
    } 
    public PageReference selectAll(){
        
        if(this.selectAll != null){
            for(innerLineItem iOLI : lineItemList)
                iOLI.isSelected = selectAll;
        }
        
        System.debug('finally :   '+lineItemList);
        return null;      
    }  
    public order__c setOrderStat(Order__c inOrder){
        if(inOrder != null){
            if(inOrder.Supplier_number__c == System.Label.BGS_SNUM_1 || inOrder.Supplier_number__c == System.Label.BGS_SNUM_2 || (inOrder.Supplier_number__c == System.Label.PHJones && inOrder.Order_Date__c >= date.valueOf(System.Label.PHJones_Stop_Date))){
                if(inOrder.EDI_Status__c == 'Awaiting Integration'){
                    inOrder.EDI_Status__c = 'Not to be Integrated'; 
                 }
                 if(inOrder.P5_SAP_Status__c == 'Awaiting Integration'){
                    inOrder.P5_SAP_Status__c = 'Not to be Integrated'; 
                 }
                 if(inOrder.P5_Good_Receipting_Status__c == 'Awaiting Integration'){
                    inOrder.P5_Good_Receipting_Status__c = 'Not to be Integrated'; 
                 }
            }             
        }
        return inOrder;
    }
    public class innerLineItem{
        public boolean isSelected;
        public Order_Line_item__c ordLineItm;
        
        public void setIsSelected(boolean val){
            if(val != null){
                this.isSelected = val;
            }
        }
        public boolean getIsSelected(){
            return this.isSelected;
        }
        public Order_line_item__c getOrdLineItm(){
            return this.ordLineItm;
        }
        public void setOrdLineItm(Order_line_item__c val){
            if(val != null){
                this.ordLineItm = val;
            }
        }
    }
    
    
 
}