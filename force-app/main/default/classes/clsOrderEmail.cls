public class clsOrderEmail {
    
    private final order__c objCurrentOrder;
    public String sMessage{get;set;}
    public class clsOrder{
        public String sOrderId{get;set;}
        public String sSupplierName{get;set;}
        public String sSapNumber{get;set;}
        public String sEmailAddress{get;set;}
        public String sMessage{get;set;}
    }
    public List<clsOrder> orderLst{get;set;}
    private List<order__c> orderList=new List<order__c>{};
    private Boolean blnMultiple=false;
    private String sRetURL='';
    
    public clsOrderEmail(Apexpages.standardController controller){
        this.objCurrentOrder=(order__c)controller.getRecord();
        blnMultiple=false;
        orderLst=new List<clsOrder>{};
        
        clsOrder objOrder=new clsOrder();
        objOrder.sOrderId=objCurrentOrder.Id;
        objOrder.sSapNumber=objCurrentOrder.SAP_Number__c;
        objOrder.sEmailAddress=objCurrentOrder.Supplier_Email_Address__c;
        
        orderLst.add(objOrder);
        
        sMessage='';
        String str_Email=objCurrentOrder.Supplier_Email_Address__c;
        if (orderLst[0].sEmailAddress==null ) {
            sMessage = 'Supplier email address not provided.';
        } else {
            if (orderLst[0].sEmailAddress==''){
                sMessage = 'Supplier email address not provided.';    
            } else {
                //sendMail();   
                sMessage=orderLst[0].sMessage; 
            }
        }
            
    } 
    
    public PageReference CancelGoBack(){
        Pagereference pgRef;
        String sPrefix=order__c.SObjectType.getDescribe().getKeyPrefix();
        if (sRetURL!=null){
            if (sRetURL==''){
                pgRef=new Pagereference('/' + sPrefix + '/o');     
            }else {
                pgRef=new Pagereference(sRetURL); 
            }
        }else {
            pgRef=new Pagereference('/' + sPrefix + '/o');       
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public clsOrderEmail(ApexPages.StandardSetController controller) {
        sRetURL=System.currentPageReference().getParameters().get('retURL');
        controller.setPageSize(200);
        blnMultiple=true;
        orderList=(List<order__c>)controller.getSelected();
        orderLst=new List<clsOrder>{};
        clsOrder objOrder=new clsOrder();
        Set<Id> orderIdSet=new Set<Id>{};
        
        for (order__c objOrderDetail:orderList) {
            orderIdSet.add(objOrderDetail.Id);
        }
        ApexPages.StandardSetController orderSetController = new ApexPages.StandardSetController(Database.getQueryLocator([select Id, Supplier__r.Name,Supplier_Email_Address__c,SAP_Number__c,Email_Sent__c,Email_Sent_By__c,Email_Sent_Date__c  from order__c where Id In:orderIdSet]));
        orderList=(List<order__c>)orderSetController.getRecords();
        
        for (order__c objOrderDetail:orderList){
            objOrder=new clsOrder();
            objOrder.sOrderId=objOrderDetail.Id;
            objOrder.sSapNumber=objOrderDetail.SAP_Number__c;
            objOrder.sEmailAddress=objOrderDetail.Supplier_Email_Address__c;
            objOrder.sSupplierName=objOrderDetail.Supplier__r.Name;
            orderLst.add(objOrder);
        }
        if (orderLst.size()>0) {
            
        } else {
            orderLst=null;    
        }
    }
    
    public PageReference sendMail(){
        Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{};
        for (clsOrder objOrderCls:orderLst) {
            try {
                if (objOrderCls.sEmailAddress==null) {
                    objOrderCls.sMessage='Supplier email address not provided.';  
                } else {
                    if (objOrderCls.sEmailAddress==''){
                        objOrderCls.sMessage='Supplier email address not provided.';  
                    } else {
                        String sFileName=objOrderCls.sSapNumber;
                        String sURL='/apex/Order_Print?id=' + objOrderCls.sOrderId;
                        PageReference pgPdf =  new PageReference(sURL);
                        pgPdf.setRedirect(true);
                        system.debug(sURL);
                        
                        Blob b = pgPdf.getContent();
                        
                        
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                        email.setSubject('Order Details: ' + sFileName);
                        String [] toAddresses = new String[] {objOrderCls.sEmailAddress};
                        email.setToAddresses(toAddresses);
                        email.setPlainTextBody('Please Find PDF document of order. The Order number is ' + sFileName);
                        
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        
                        efa.setFileName(sFileName + '.pdf'); // neat - set name of PDF
                        efa.setBody(b); //attach the PDF
                        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
                        mails.add(email);
                    }
                }                
            } catch(Exception ex) {
                System.debug('%%%%%%%%%%%%%%:' + ex.getMessage());
            }    
        }
        try {
        
            Messaging.SendEmailResult [] result = Messaging.sendEmail(mails,false);   
            Integer iCount=0;
            for (clsOrder objOrderCls:orderLst){
                Messaging.SendEmailResult mailResult=result[iCount];
                String sResult='';
                if (objOrderCls.sMessage==null){
                    if (objOrderCls.sMessage=='') {
                        if (mailResult.isSuccess()){
                            objOrderCls.sMessage='Mail sent successfully';   
                            
                        }else {
                            objOrderCls.sMessage=mailResult.getErrors()[0].getMessage();
                        }        
                    }
                }
            }
            if (!blnMultiple){
                sMessage=orderLst[0].sMessage;
                
                objCurrentOrder.Email_Sent__c=true;
                objCurrentOrder.Email_Sent_By__c=UserInfo.getName();
                objCurrentOrder.Email_Sent_Date__c=System.today();
                update objCurrentOrder;
                
            } else {
                for (clsOrder objOrderCls:orderLst){
                    if (objOrderCls.sMessage=='Mail sent successfully'){
                        for (order__c orderObj:orderList){
                            String sTemp=orderObj.Id;
                            if (sTemp.contains(objOrderCls.sOrderId)){
                                orderObj.Email_Sent__c=true;
                                orderObj.Email_Sent_By__c=UserInfo.getName();
                                orderObj.Email_Sent_Date__c=System.today();    
                            }
                        }
                    }
                }
                update orderList;
                    
            }
        } catch(Exception ex){
            System.debug('££££££££££:' + ex.getMessage());
        }
        
        return null;
    }
}