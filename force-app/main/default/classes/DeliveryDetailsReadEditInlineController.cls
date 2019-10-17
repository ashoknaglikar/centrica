public with sharing class DeliveryDetailsReadEditInlineController{

  //added an instance varaible for the standard controller
  public ApexPages.StandardController controller {get; set;}
  Public Job__c job{get;set;}
  Public Date priorDeliveryDate{get;set;}
  Public String priorDeliverySlot{get;set;}
  

    public DeliveryDetailsReadEditInlineController(ApexPages.StandardController controller) {

       //initialize the stanrdard controller
        this.controller = controller;
        this.job = (Job__c)controller.getRecord();
        System.debug('Id is : '+job.Id);
        this.job = [Select Id, Re_plan_Email_Sent_Timestamp__c, Delivery_Date__c,PTS_Rollout__c, Delivery_Slot__c, Delivery_Notes__c, Installer_Notes__c, Mechanical_Installer__c, Installation_Special_Instructions__c, Electrical_Installer__c, Specialist_Builder__c from Job__c where Id = :job.Id];
        this.priorDeliveryDate = this.job.Delivery_Date__c;
        this.priorDeliverySlot = this.job.Delivery_Slot__c;
    
    }
    
    public Pagereference saveJob(){
    
       try{
       
           Update job;
           boolean generateReplanNotice = false;
           
           System.debug('current del date '+job.Delivery_Date__c);
           System.debug('prior del date '+priorDeliveryDate);
           System.debug('current del slot '+job.Delivery_Slot__c);
           System.debug('prior del slot '+priorDeliverySlot);
           
           if(job.Delivery_Date__c != null && this.priorDeliveryDate != null && job.Delivery_Date__c != this.priorDeliveryDate){
             generateReplanNotice = true;
           }
           
           if(job.Delivery_Slot__c != null && this.priorDeliverySlot != null && job.Delivery_Slot__c != this.priorDeliverySlot){
             generateReplanNotice = true;
           }
           
           if(generateReplanNotice){
            
            try{
                  
                  List<Order__c> orderLst = [Select Prior_Delivery_Slot__c,Delivery_Date_Changed__c, Send_via_email__c, CreatedDate, Order_Value_Text__c, 
                                                     Prior_Order_Value__c, Customer_best_phone__c, Supplier_Name__c, Job_Delivery_Date__c, Prior_Delivery_date__c, 
                                                        Delivery_Slot__c, Enquiry_Number__c, Job__r.Name, Job__r.PlannerName__c, Job__r.CHI_Lead__r.CHI_Lead_Id__c, 
                                                          Job__r.Customer_Name__c, SAP_Number__c, Job__r.CHI_Lead__r.Account.BillingStreet, Order_Value__c, 
                                                            Job__r.CHI_Lead__r.Account.BillingCity, Job__r.CHI_Lead__r.Account.BillingState, 
                                                              Job__r.CHI_Lead__r.Account.BillingCountry, Job__r.Id, Job__r.CHI_Lead__r.Account.BillingPostalCode From order__c 
                                                                 where Job__c=:this.job.Id And Delivery_Date_Changed__c = true And Type__c = 'Material' And 
                                                                                                           Status__c Not In('Cancelled','Rejected','Inactive')];    
                  for(Order__c ord : orderLst){
                     ord.Send_via_email__c = true;
                  }
                  
                  Database.Update(orderLst,true);
                  SendReplanPDFViaEmail s = new SendReplanPDFViaEmail();
                  s.sendEmail(orderLst);
              
            }catch(Exception excp){
                
                 System.debug('Exception Type 1 In Replan '+excp.getMessage());
                 
              }
           
        }
           
       
       }catch(Exception excp){
         
           System.debug('Exception Type 2 In Replan '+excp.getMessage()); 
           ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excp.getMessage());
           ApexPages.addMessage(msg);
           return null;
       
       }
       
       PageReference pageRef = new PageReference('/apex/DeliveryDetailsReadInline?id='+this.job.Id);
       pageRef.setRedirect(true);
       return pageRef;

    }
    
     public Pagereference genReplanNotice(){
    
       try{
       
           if(job.Delivery_Date__c != null){
            
            try{
                
                List<Order__c> orderLst = [Select Prior_Delivery_Slot__c,Delivery_Date_Changed__c, Send_via_email__c, CreatedDate, Order_Value_Text__c, 
                                                     Prior_Order_Value__c, Customer_best_phone__c, Supplier_Name__c, Job_Delivery_Date__c, Prior_Delivery_date__c, 
                                                        Delivery_Slot__c, Enquiry_Number__c, Job__r.Name, Job__r.PlannerName__c, Job__r.CHI_Lead__r.CHI_Lead_Id__c, 
                                                          Job__r.Customer_Name__c, SAP_Number__c, Job__r.CHI_Lead__r.Account.BillingStreet, Order_Value__c, 
                                                            Job__r.CHI_Lead__r.Account.BillingCity, Job__r.CHI_Lead__r.Account.BillingState, 
                                                              Job__r.CHI_Lead__r.Account.BillingCountry, Job__r.CHI_Lead__r.Account.BillingPostalCode From order__c 
                                                                 where Job__c=:this.job.Id And Delivery_Date_Changed__c = true And Type__c = 'Material' And 
                                                                                                           Status__c Not In('Cancelled','Rejected','Inactive')];
                SendReplanPDFViaEmail s = new SendReplanPDFViaEmail();
                s.sendEmail(orderLst);
                
              }catch(Exception excp){
                
                 System.debug('Exception Type 2 In Replan '+excp.getMessage());
                
              }
                
           }
       
       }catch(Exception excp){
       
           ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, excp.getMessage());
           ApexPages.addMessage(msg);
           return null;
       
       }
    
       PageReference pageRef = new PageReference('/apex/DeliveryDetailsReadInline?id='+this.job.Id);
       pageRef.setRedirect(true);
       return pageRef;

    }
    
    public Pagereference editJob(){

       PageReference pageRef = new PageReference('/apex/DeliveryDetailsEditInline?id='+this.job.Id);
       pageRef.setRedirect(true);
       return pageRef;
    
    }
    
    public Pagereference cancelEdit(){
    
       PageReference pageRef = new PageReference('/apex/DeliveryDetailsReadInline?id='+this.job.Id);
       pageRef.setRedirect(true);
       return pageRef;
    
    }

}