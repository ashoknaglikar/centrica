public with sharing class SplitOrderController {
    public SplitOrderController() {

    }


    public SplitOrderController(ApexPages.StandardController controller) {

    }


    
    public List<orderDetails> orderDetailsList = new List<orderDetails>();
    public List<elementDetails> elementDetailsList = new List<elementDetails>();
    Job__c objJob = new Job__c();    
    public String s_ErrorMsg = '';
    public String s_orderId = '';
    
    public void setS_orderId(String selected){
        System.debug('@ s_orderId called ######  @'+s_orderId );
        if(selected != '' && selected != null)
            this.s_orderId = selected;
    }
    public String getS_orderId(){
        return this.s_orderId;
    }
    public String gets_ErrorMsg(){
        System.debug('@ s_ErrorMsg called @');
        this.getAllDetails();
        return this.s_ErrorMsg; 
    }
    public List<orderDetails> getOrderDetailsList(){
        System.debug('@ orderList called @');
        return this.orderDetailsList;
    }
    
    public Job__c getObjJob(){
        System.debug('@ objJob called @');
        
        return this.objJob;
    }
    public String getAllDetails(){
        System.debug('@ AllDetails called @');
        String jobId = System.currentpagereference().getparameters().get('JobId');
        if('' == jobId || null == jobId){
            s_ErrorMsg = 'Error in Fetching Required Parameter - "JOB NUMBER"';
        }else{
            if(orderDetailsList.size() == 0){
                objJob = [Select name,j.Region__c, j.Installation_Date__c, j.Delivery_Date__c, j.Customer_Name__c, 
                                (Select Id, Name,Job__c, Status__c From Purchase_Orders__r), 
                                (Select Id,Name, Code__c,Order__c, Current_Supplier_Number__c, Current_Supplier__c, Description__c,  Skill__c, Status__c, Sub_Status__c, Type__c, Units__c,unit_price__c From Job_Elements1__r order by supplier__c asc) 
                                From Job__c j where id =:jobId];
                System.debug('#JOB IS + '+objJob);
                if((objJob.Purchase_Orders__r).size() <= 1){
                    s_ErrorMsg = 'Cannot Proceed - "There is Zero/One order against the job "';
                }else if((objJob.Job_Elements1__r).size() <=1){
                    s_ErrorMsg = 'Cannot Proceed - "There is Zero/One Job Element/Order Line against the job "';
                }else{
                    for(Order__c order : objJob.Purchase_Orders__r){
                        orderDetailsList.add(new orderDetails(false,order));
                    }
                    s_ErrorMsg = null;
                }
            }
        }
        return s_ErrorMsg;
    }
    public PageReference actnFetchElements(){
        System.debug('@ Called actnFetchElements @'+s_orderId);
        System.debug('orderDetailsList = '+orderDetailsList);
        System.debug('elementDetailsList = '+elementDetailsList);
        if(s_orderId != '' && s_orderId != null){
            if(!(elementDetailsList.isEmpty()))
                elementDetailsList.clear();
            for(Job_Element__c JE : objJob.Job_Elements1__r){
                if(JE.Order__c == s_orderId)
                    elementDetailsList.add(new elementDetails(false,JE));
            }
        }
        return null;
    }
    public PageReference actnSplit(){
        System.debug('@ Called actnSplit @'+s_orderId);
        System.debug('orderDetailsList = '+orderDetailsList);
        System.debug('elementDetailsList = '+elementDetailsList);
        Order__c selectedOrder = new Order__c();
        List<Job_Element__c> element = new List<Job_Element__c>();
        
        for(elementDetails eDet : elementDetailsList){
            if(eDet.b_IsElementSelected != null && eDet.b_IsElementSelected){
                Job_Element__c objElement = eDet.objElement;
                objElement.Order__c = s_orderId;
                element.add(objElement);
            }
        }
        System.debug(' updated elementDetailsList = '+element);
        try{
            update element;
        }catch(Exception e){
            System.debug('Cannot update JE as --'+e.getMessage());
        }
        return new Pagereference('/'+System.currentpagereference().getparameters().get('JobId'));
    }
    
    public List<elementDetails> getElementDetailsList(){
        //System.debug('@ elementList called @'+s_orderId);
        
        //if(s_orderId != '' && s_orderId != null){
            //System.debug('###   elementDetailsList = '+elementDetailsList);
            //for(Job_Element__c JE : objJob.Job_Elements1__r){
              //  if(JE.Order__c == s_orderId)
                //    elementDetailsList.add(new elementDetails(false,JE));
            //}
            return this.elementDetailsList;
        //}
        //return null;
    }
   
    
    
    class orderDetails{
        
        public Order__c objOrder = new Order__c();
        public orderDetails(boolean selected,Order__c order){
            
            this.objOrder = order;
        }
        
        public Order__c getObjOrder(){
            return this.objOrder;
        }
    } 
    class elementDetails{
        public boolean b_IsElementSelected = false;
        public Job_Element__c objElement = new Job_Element__c();
        public elementDetails(boolean selected,Job_Element__c JE){
            this.b_IsElementSelected = selected;
            this.objElement = JE;
        }
        public void setB_IsElementSelected(boolean selected){
            this.B_IsElementSelected = selected;
        }
        public boolean getB_IsElementSelected(){
            return this.b_IsElementSelected;
        }
        public Job_Element__c getObjElement(){
            return this.objElement;
        }
    }
}