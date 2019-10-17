public with sharing class CCHP190Extension {
    private final order__c objActOrder;
    private order__c objOrder;
    public class EventDetails{
        public String sEvent{get;set;}
        public String sEventDt{get;set;}
        public String sContactNo{get;set;}
        public String sEventText{get;set;}  
        public String sResponsible{get;set;}
    }
    public class AspDetails{
        public String sCode{get;set;}
        public String sDescription{get;set;}
        public String sEnquiries{get;set;}
        public Decimal sValue{get;set;}  
        public String sOrderDate{get;set;}
        public String sDeliveryDate{get;set;}
    }
    public class NoAspDetails{
        public String sCode{get;set;}
        public String sDescription{get;set;}
        public String sEnquiries{get;set;}
        public Decimal sValue{get;set;}  
        public String sOrderDate{get;set;}
        public String sDeliveryDate{get;set;}
    }
    public List<Diary_Entry__c> DiaryEntryList{get;set;}
    public List<EventDetails> eventDetailsLst{get;set;}
    public List<AspDetails> ASPList{get;set;}
    public List<NoAspDetails> NoAspList{get;set;}
    public List<order__c> orderList{get;set;} 
    public List<ASP__c> ASPdetailList{get;set;} 
    public Date dtCreatedDate;
    public Date dtorderDate;
    public String dtdeliverydate{get;set;}
    public CCHP190Extension(ApexPages.StandardController controller) {
    
        this.objActOrder=(order__c)controller.getRecord();
        NoAspList= new List<NoAspDetails>{};
        AspList= new List<AspDetails>{};
        objOrder=[Select Type__c,Job__r.Id,Job_Delivery_Date__c,Job__r.Delivery_Slot__c,Job__r.Installation_Date__c,
                    Job__r.Installation_Special_Instructions__c,Job__c,Prior_Order_Value__c, Quote_ID__c,Job__r.PlannerName__c,Order_Value__c,
                    Job__r.Delivery_Date__c,Order_Date__c,Prior_Delivery_date__c From order__c Where Id=:objActOrder.Id];
        if (objOrder.Type__c=='Material'){
        eventDetailsLst=new List<EventDetails>{};
        orderList=[Select Type__c,Job__r.Id,Job_Delivery_Date__c,Job__r.Delivery_Slot__c,Job__r.Installation_Date__c,Job__c,
                        Supplier__r.Name, Supplier__r.Phone1__c,Prior_Order_Value__c from order__c Where Job__c=:objOrder.Job__r.Id and Type__c='Material' 
                        And order__c.Status__c <>'Cancelled'];
        EventDetails objEventDetails=new EventDetails();
            for (order__c objCurrentOrder:orderList) {
                objEventDetails=new EventDetails();
                objEventDetails.sEvent='Merchant Delivery';
                dtCreatedDate=objOrder.Job_Delivery_Date__c; 
                objEventDetails.sEventDt=dtCreatedDate.format();
                dtdeliverydate = dtCreatedDate.format();
                objEventDetails.sResponsible=objCurrentOrder.Supplier__r.Name;
                objEventDetails.sContactNo=objCurrentOrder.Supplier__r.Phone1__c;
                objEventDetails.sEventText=objOrder.Job__r.Delivery_Slot__c;
                eventDetailsLst.add(objEventDetails);
            }
            
        DiaryEntryList=new List<Diary_Entry__c>{};
        DiaryEntryList=[Select Employee_Name__c,Week__r.Employee__r.Phone_No__c,Sub_Type__c From Diary_Entry__c 
                        where Job__c=:objOrder.Job__r.Id  And Record_Type__c='Job Booking']; 
                                       
            for (Diary_Entry__c objDiary:DiaryEntryList){
                objEventDetails=new EventDetails();
                objEventDetails.sEvent='Installation';
                dtCreatedDate=objOrder.Job__r.Installation_Date__c;
                objEventDetails.sEventDt=dtCreatedDate.format();
                objEventDetails.sResponsible=objDiary.Employee_Name__c;
                objEventDetails.sContactNo=objDiary.Week__r.Employee__r.Phone_No__c;
                objEventDetails.sEventText=objOrder.Job__r.Installation_Special_Instructions__c;
                eventDetailsLst.add(objEventDetails); 
            }          
            objEventDetails=new EventDetails();
            objEventDetails.sEvent='Waste Collection Office';
            objEventDetails.sEventDt='';
            objEventDetails.sResponsible='';
            objEventDetails.sContactNo='';
            objEventDetails.sEventText='';
            eventDetailsLst.add(objEventDetails);
        }
        if(objOrder.Type__c=='Material'){
        ASPdetailList=new List<ASP__c>{};
        ASPdetailList = [Select Quote__c,Name from ASP__c where Quote__c =:objOrder.Quote_ID__c];
        if(ASPdetailList.size()>0){
        AspDetails objAspDetails=new AspDetails(); 
         objAspDetails=new AspDetails();
            objAspDetails.sCode='I';
            objAspDetails.sDescription='INITIAL ORDER';
            objAspDetails.sEnquiries=objOrder.Job__r.PlannerName__c;
            objAspDetails.sValue=objOrder.Order_Value__c;
            dtorderDate=objOrder.Order_Date__c; 
            objAspDetails.sOrderDate=dtorderDate.format();
            dtCreatedDate=objOrder.Prior_Delivery_date__c;  
            objAspDetails.sDeliveryDate=dtCreatedDate.format();
            ASPList.add(objAspDetails);
        
        for (ASP__c objAsp:ASPdetailList){
                objAspDetails=new AspDetails();
                 objAspDetails.sCode= objAsp.Name;
                objAspDetails.sDescription='ASP PILOT';
                objAspDetails.sEnquiries=objOrder.Job__r.PlannerName__c;
                objAspDetails.sValue=objOrder.Prior_Order_Value__c;
                dtorderDate=objOrder.Order_Date__c; 
                objAspDetails.sOrderDate=dtorderDate.format();
                dtCreatedDate=objOrder.Job__r.Delivery_Date__c;  
                objAspDetails.sDeliveryDate=dtCreatedDate.format(); 
                ASPList.add(objAspDetails);
            } 
        }
        else{
            NoAspDetails objAspDetails=new NoAspDetails(); 
             objAspDetails=new NoAspDetails();
            objAspDetails.sCode='I';
            system.debug('1----'+objAspDetails.sCode);
            objAspDetails.sDescription='INITIAL ORDER';
            system.debug('2----'+objAspDetails.sDescription);
            if(objOrder.Job__r.PlannerName__c !=null||objOrder.Job__r.PlannerName__c!=''){
            objAspDetails.sEnquiries=objOrder.Job__r.PlannerName__c;
            }else
            {
            objAspDetails.sEnquiries='';    
            }
            system.debug('3----'+objAspDetails.sEnquiries);
            objAspDetails.sValue=objOrder.Order_Value__c;
            system.debug('4----'+objAspDetails.sValue);
            dtorderDate=objOrder.Order_Date__c; 
            if(dtorderDate!=null){
            objAspDetails.sOrderDate=dtorderDate.format();
            }
            system.debug('5----'+objAspDetails.sOrderDate);
            dtCreatedDate=objOrder.Job__r.Delivery_Date__c; 
            if(dtCreatedDate !=null){
            objAspDetails.sDeliveryDate=dtCreatedDate.format();
            } 
            system.debug('6----'+objAspDetails.sDeliveryDate);
            NoAspList.add(objAspDetails);
            
            
        } 
        
       }   
     }
}