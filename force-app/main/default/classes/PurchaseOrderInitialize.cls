public class PurchaseOrderInitialize {
    /**
            Author            : Cognizant
            Functionality     : This is a extension controller class.The visualforce page related to this class is called "PurchaseOrderInitialize".
                                The Class checks that whether the Job is planned or not. It also checks that whether the Job is properly planned.
                                It also checks that whether the Job has orders or not.  
                                Based on the existence of order, the order creation or order amendment page is rendered. 
            Create Date       : 03 June 2010
            Change History    : Added Code Comments
            Modified Date     : 05 July 2010
    **/
    private final Job__c objCurrentJob; //Final variable storing the Job Information fetched by the PurchaseOrderInitialize screen in the url query string.
    private String sStatus='';// Stores the Job status 
    public Boolean blError {get;set;} // Stores the error information. 
    public Boolean blPlanned {get;set;}
    public Boolean blInstalled {get;set;}
    
    public Boolean blNoDiaryEntry{get;set;} // Stores the data for whether any diary entries are there for the planned Job
    public Integer iDiaryCount{get;set;}// Stores the diary entry count of the Job
    private String sPlatform='';//Stores the platform of the Job.
    public String sErrorMsg{get;set;}

    /*
        Default constructor of the class. 
        This constructor fetches the data from the Job based on the Job from which the "Generate Purchase Order" button has been clicked.
        It also fetches whether the job has any diary entry has been made to the job when the job status was set to planned.
    */
    public PurchaseOrderInitialize(Apexpages.standardController controller){
        this.objCurrentJob=(Job__c)controller.getRecord();
        sStatus=objCurrentJob.Status__c;
        blError =false;
        blPlanned =false;
        blInstalled =false;
        iDiaryCount=[Select count() from Diary_Entry__c where Job__c=:objCurrentJob.Id];
        blNoDiaryEntry=(iDiaryCount==0? true:false);
        System.debug('$$$$$$$$$$ : ' + objCurrentJob.CHI_Lead__r.Platform__c);
        sErrorMsg='';
        if (objCurrentJob.CHI_Lead__r.Platform__c==null) {
            
            sPlatform='';
        } else {
            sPlatform=objCurrentJob.CHI_Lead__r.Platform__c;
        }
    }//End of Method
    
    /*
        This is an action method called from when the page is loaded.
        This action method redirects the user to the order creation or order amendment based on the criteria specified.
        The criteria for the order generation or amendment which checks the order status are :
        1. Cancelled
        2. Rejected - By Supplier
        3. Rejected
        4. Inactive
        If the count of order is 0, which excludes the orders of the status mentioned above.
        
    */
    public PageReference init(){
        Pagereference pgRef;
        System.debug('%%%%%%%%%%%%%: ' + sPlatform);
        Job__c j = [Select Id,Order_Locking_User__c,Order_Locking_User__r.Name,order_locking_time__c from Job__c where Id=: objCurrentJob.Id];
        integer minutes = integer.valueof(system.label.Order_Lock_Time);
        if((j.order_locking_time__c!= null && system.now()> j.order_locking_time__c.addminutes(minutes))||j.order_locking_time__c== null)
            {
                
                j.Order_Locking_User__c = userinfo.getUserId();
                j.order_locking_time__c = system.now();
                update j;
            }else
            {
                if(j.Order_Locking_User__c!= userinfo.getUserId())
                {
                    //sErrorMsg='Order cannot be generated. As this is locked by'+userinfo.getName();
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order cannot be generated. As the orders are being Processed by '+j.Order_Locking_User__r.Name);
                    ApexPages.addMessage(errMsg);
                    return null;
                }   
            } 
            
       if (sPlatform =='Premier'){
            blError = true;
            sErrorMsg='Order cannot be generated. The job planning platform is Premier.';
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order cannot be generated. The job planning platform is Premier.');
            pgRef=null;
       } else {
            if (sStatus=='Planned' || sStatus=='Installed'){
                //Enters if the Job Status is Planned
                blPlanned =false;
                if (blNoDiaryEntry==true){
                    //Enters if the Job is not planned by clicking the "Plan Job" button. There by throwing an error information to the user. 
                    pgRef=null;
                } else {
                    //Enters if the Job is planned and it finds diary entries related to the Job.
                    List<String> OrderStatusList=new List<String>{};
                    OrderStatusList.add('Cancelled');
                    OrderStatusList.add('Rejected - By Supplier');
                    OrderStatusList.add('Rejected');
                    OrderStatusList.add('Inactive');
                    blError = false;
                    //Checks whether any valid order exists with the Job
                    Integer iCount=[Select count() from order__c where Job__c=:objCurrentJob.Id and order__c.Status__c NOT In: OrderStatusList];
                    if(iCount>0){
                        //If valid order exists, redirects the user to the order amendment screen
                        pgRef=new Pagereference('/apex/PurchaseOrderAmendment?id=' + objCurrentJob.Id);    
                    } else {
                        // if no order or no valid order is present, redirects to the order generation screen
                        pgRef=new Pagereference('/apex/ProcessJobOrders?id=' + objCurrentJob.Id);
                    }//End of If Else
                    pgRef.setRedirect(true);
                }//End of If Else
            } else if (sStatus!='Planned' && sStatus!='Installed') {
                blPlanned =true;
                sErrorMsg='Order cannot be generated. To process order Job needs to be planned or Installed';
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order cannot be generated. To process order Job needs to be planned');
                pgRef=null; 
            } else {
                blError = true;  
            }//End of if else
        }
        return pgRef;
    }//End of Method
    
    /**
        This action method is used for the returning the control to Job Screen 
        if there is any problem for generating the order for the Job.
        
    **/
    public PageReference returnBack(){
    	
    	objCurrentJob.Order_Locking_User__c = null;
        objCurrentJob.order_locking_time__c = null;
        update objCurrentJob;

        Pagereference pgRef;
        pgRef=new Pagereference('/' + objCurrentJob.Id);   
        pgRef.setRedirect(true);
        return pgRef;         
    }//End of Method 
    
}//End of Class