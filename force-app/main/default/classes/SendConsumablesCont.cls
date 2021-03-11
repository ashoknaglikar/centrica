/*
    Author: cognizant 01/12/2011
    description: This page is used to fetch all the cosumable requests created between two particular dates and uncheck the Picked by Email flag set to false.
    this page also has capability to fetch Consumable request based on the file name as well. 
    It also send out text mail to callidus team if they want to place the orders mannually apart fron the daily batch.
    
    TestClass for this class is present in : sendConsumableRequests_Test
*/
public with sharing class SendConsumablesCont {
    
    public integer consumablesWaiting{get;set;}
    
    public void invokeBatch()
    {
        if(consumablesWaiting>0)
        {
            sendConsumableRequests sCR = new sendConsumableRequests();
         	sCR.createConReqBatch();
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.info, 'Request has been taken. An email should arrive shortly to the consumable inbox.');
            ApexPages.addMessage(msg);
        }else
        {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.error, 'There are no orders to process.');
            ApexPages.addMessage(msg);
            
        }
        
    }
    
    public SendConsumablesCont() {
        
        date CreatedDate = system.today().addDays(-365);
        consumablesWaiting = [Select count()  From Consumables_Requests__c where Picked_Up_by_Email__c = false and lastModifiedDate >=:CreatedDate and Status__c = 'Submitted' and (Approval_Required__c= 'No' OR (Approval_Required__c= 'Yes' and Approved__c = true)) and Employee__c != null];
        
    }
    
    /* ++++++++++++ Commented as this has not been used for long time improves the test class +++++++++++++++++
    
    
    public Consumables_Requests__c cReq1 {get;set;}
    public Consumables_Requests__c cReq2 {get;set;}
    public list<conReqInner> cReqInnrList {get;set;}
    public boolean conr {get;set;}
    public string message{get;set;}
    public string FieldType{get;set;}
    public boolean selectAll{get;set;}
    public List<selectoption> getFieldTypeOptions(){
         List<selectoption> options = new List<selectoption>();
         Options.add(new SelectOption('','--None--'));
         Options.add(new SelectOption('File Name','File Name'));
         Options.add(new SelectOption('Created Date','Created Date'));
         return options;
    }
    
    
    
    public PageReference selectAll(){
        
        if(this.selectAll != null){
            for(conReqInner u : cReqInnrList)
                u.isSelected = selectAll;
             for(conReqInner u : cReqInnrList)
                u.isSelected = selectAll;    
        }
        
        
        return null;      
    }
    public pagereference fetchRequests()
    {
        list<Consumables_Requests__c> cReqLst = new list<Consumables_Requests__c>();
        DateTime startDate = cReq1.Submitted_DateTime__c;
        DateTime endDate = cReq2.Submitted_DateTime__c;
        string searchText = cReq1.File_Name__c;
        
        if(startDate>endDate)
        {
            return null;
        }
        if(FieldType == 'Created Date')
            cReqLst  = [Select Id,Name,Picked_Up_by_Email__c,Employee__c  From Consumables_Requests__c where CreatedDate >= :startDate and CreatedDate <= :endDate];
        else if(FieldType == 'File Name')
        {
            searchText +='*';
            cReqLst  = (List<Consumables_Requests__c>)[FIND :searchText IN ALL FIELDS RETURNING Consumables_Requests__c ( Id,Picked_Up_by_Email__c,Employee__c,Name, File_Name__c)][0];
        }   
            
        
        if(cReqLst.size()>0){ 
            conr= true;
            cReqInnrList = new list<conReqInner>();
            for(Consumables_Requests__c cr :cReqLst)
            {
                conReqInner cInner = new conReqInner(cr);
                cReqInnrList.add(cInner);
                    
            }
            return null;
            
        }else
        {
            // display no Requests
            message = 'No Requests were Found in this interval';
            conr = false;
            setErrorMsg(true);
            return null;
            
        }
        
    }
    public SendConsumablesCont(){
        cReq1 = new Consumables_Requests__c(Delivery_Date__c = system.today());
        cReq2 = new Consumables_Requests__c(Delivery_Date__c = system.today()+1);
    }
    
    
    public pagereference updateConsumables()
    {
        list<Consumables_Requests__c> updatingCReqs = new list<Consumables_Requests__c>();
        for(conReqInner c:cReqInnrList)
        {
            if(c.isSelected && c.cReqIn.Picked_Up_by_Email__c)
            {
                c.cReqIn.Picked_Up_by_Email__c = false;
                updatingCReqs.add(c.cReqIn);
            }
            
        }
        if(updatingCReqs.size()>0)
        {
            
            update updatingCReqs;
            message = 'Sucessfully Updated';
            conr = false;
            setErrorMsg(false);
            // sucessfull message
            return null;
        }else{
            message = 'No Requests were selected';
            setErrorMsg(true);
            //error mesdage;
            return null;
        }
        
    }
    
    public  class conReqInner
    {
        public boolean isSelected {get;set;}
        public Consumables_Requests__c cReqIn{get;set;}
        conReqInner(Consumables_Requests__c c)
        {
            cReqIn = c;
            isSelected = false;
        }
    }
    
    public pagereference EmailConsumables()
    {
        sendConsumableRequests s = new sendConsumableRequests();
        s.createConReqBatch();
        message = 'All the pending requests have been Mailed if there were any.';
        setErrorMsg(false);
        return null;
    }
    
    public void setErrorMsg(boolean flag)
    {
        ApexPages.Message msg;
        if(flag)
        msg = new ApexPages.Message(Apexpages.Severity.error, message);
        else
        msg = new ApexPages.Message(Apexpages.Severity.info, message);
        ApexPages.addMessage(msg);
    }
    
    ++++++++++++ Commented as this has not been used for long time improves the test class +++++++++++++++++
    
    */

}