public class TopcallFaxExtn {
    
    private final order__c objActOrder;
    private order__c objOrder;
    public String sReturnDate{get;set;}
    private Date dtReturnDate;
    public class EventDetails{
        public String sEvent{get;set;}
        public String sEventDt{get;set;}
        public String sContactNo{get;set;}
        public String sEventText{get;set;}  
        public String sResponsible{get;set;}
    }
    public class RateItemDetails{
        public String sCode{get;set;}
        public String sDescription{get;set;}
        public String sSkill{get;set;}
        public Integer sQty{get;set;}    
        public Double dblUnitValue{get;set;}
        public Double dblTotalHrs{get;set;}     
    }
    
    public class MaterialItemDetails{
        public String sCode{get;set;}
        public String sDescription{get;set;}
        public Integer iQty{get;set;}
    }
    public class QuoteProduct{
        public String sDescription{get;set;}
        public String sRoom{get;set;}
        public String sPosition{get;set;}
        public String sNotes{get;set;}
    }
    public class QuoteProductType{
        public String sType{get;set;}
        private List<QuoteProduct> quoteProductLst= new List<QuoteProduct>{};
        public List<QuoteProduct> getQuoteProductLst(){
            return quoteProductLst;
        }
        public void setQuoteProductLst(List<QuoteProduct> value){
            quoteProductLst=value;
        }
    }
    public Double dblTotalJobHrs{get;set;}
    public String strScaffolding{get;set;}
    public String strElectrical{get;set;}
    public String strAsbestos{get;set;}
    public String strElectricalDesc{get;set;}
    public String strElectricalProdId{get;set;}
    
    public List<Job_Element__c> jobEleScaffold{get;set;}
    public List<Job_Element__c> jobEleElectrical{get;set;}
    public List<Job_Element__c> jobEleAsbestos{get;set;}
    public List<Job_Element__c> jobEleDisconnElemList{get;set;}
        
    
    public List<RateItemDetails> fixedRateItems{get;set;}
    public List<RateItemDetails> hourlyRateItems{get;set;}
    public List<MaterialItemDetails> materialItemLst{get;set;}
    public List<EventDetails> eventDetailsLst{get;set;}
    public List<Diary_Entry__c> DiaryEntryList{get;set;} 
    public Map<String,QuoteProductType> QuoteProductTypeMap{get;set;}
    private List<QuoteProductType> quotePrdTypeList=new List<QuoteProductType>{};
    public List<QuoteProductType> getQuotePrdTypeList(){
        return QuoteProductTypeMap.values();
    }
    
    public List<QuoteProduct> BoilerLst{get;set;}
    public List<QuoteProduct> RadiatorLst{get;set;}
    public List<QuoteProduct> ValvesLst{get;set;}
    public List<QuoteProduct> ControlsLst{get;set;}
    public List<QuoteProduct> CylinderLst{get;set;}
    
    

    public String strPrimInstaller{get;set;}
    public String strPrimInstaStreet{get;set;}
    public String strPrimInstaCity{get;set;}
    public String strPrimInstaCounty{get;set;}
    public String strPrimInstaPostCode{get;set;}
    public String strPrimInstaCountry{get;set;}
    public String strSalesBy{get;set;}
    public String strSalesByPhone{get;set;}
    public List<order__c> orderList{get;set;}
    public List<Order_Line_Item__c> orderElementList{get;set;}
    private List<Order_Line_Item__c> m_orderElementList;

    public TopcallFaxExtn(ApexPages.StandardController controller) {
        
        String sInstallerId=ApexPages.currentPage().getParameters().get('resourceId');
        this.objActOrder=(order__c)controller.getRecord();
        materialItemLst=new List<MaterialItemDetails>{};
        MaterialItemDetails objMaterialItem=new MaterialItemDetails();
        m_orderElementList=new List<Order_Line_Item__c>{};
        objOrder=[Select Type__c,Sales_By__c,Job__r.Quote__r.createdDate_quote__c,Job__r.Quote__r.submittedDate_quote__c,Job__r.Id,
                        Job_Delivery_Date__c,Job__r.Delivery_Slot__c,Job__r.Installation_Date__c,Job__c,Job__r.Document_Return_Date__c 
                        From order__c Where Id=:objActOrder.Id];
        
        try {
         dtReturnDate=objOrder.Job__r.Document_Return_Date__c;
         dtReturnDate=dtReturnDate.addDays(5);
         
         cls_IsRun objMonthName=new cls_IsRun();
         sReturnDate= dtReturnDate.day().format() + '-' + objMonthName.returnMonth(dtReturnDate.month()) + '-' + dtReturnDate.year().format();
         } catch(Exception ex){
             //do nothing
         }
        eventDetailsLst=new List<EventDetails>{};
        EventDetails objEventDetails=new EventDetails();
        strSalesBy=objOrder.Sales_By__c;
        System.debug(strSalesBy);
        if (strSalesBy!='') {
            Employee__c objEmployee=[Select First_Name__c, Last_Name__c, Phone_No__c From Employee__c where Employee_Number__c=:strSalesBy];
            strSalesByPhone=objEmployee.Phone_No__c;
            strSalesBy=objEmployee.First_Name__c + ' ' + objEmployee.Last_Name__c;
        }
        objEventDetails.sEvent='Generated By';
        Date dtCreatedDate=objOrder.Job__r.Quote__r.createdDate_quote__c;
        objEventDetails.sEventDt=dtCreatedDate.format();
        objEventDetails.sResponsible=strSalesBy;
        objEventDetails.sContactNo=strSalesByPhone;
        objEventDetails.sEventText='';
        eventDetailsLst.add(objEventDetails);
        
        objEventDetails=new EventDetails();
        objEventDetails.sEvent='Sale';
        dtCreatedDate=objOrder.Job__r.Quote__r.submittedDate_quote__c;
        objEventDetails.sEventDt=dtCreatedDate.format();
        objEventDetails.sResponsible=strSalesBy;
        objEventDetails.sContactNo=strSalesByPhone;
        objEventDetails.sEventText='';
        eventDetailsLst.add(objEventDetails);
        
        objEventDetails=new EventDetails();
        objEventDetails.sEvent='Waste Collection Office';
        objEventDetails.sEventDt='';
        objEventDetails.sResponsible='';
        objEventDetails.sContactNo='';
        objEventDetails.sEventText='';
        eventDetailsLst.add(objEventDetails);
        
        orderList=[Select Supplier__r.Name, Supplier__r.Phone1__c from order__c Where Job__c=:objOrder.Job__r.Id and Type__c='Material' And order__c.Status__c <>'Cancelled'];
        for (order__c objCurrentOrder:orderList) {
            objEventDetails=new EventDetails();
            objEventDetails.sEvent='Merchant Delivery';
            dtCreatedDate=objOrder.Job_Delivery_Date__c; 
            objEventDetails.sEventDt=dtCreatedDate.format();
            objEventDetails.sResponsible=objCurrentOrder.Supplier__r.Name;
            objEventDetails.sContactNo=objCurrentOrder.Supplier__r.Phone1__c;
            objEventDetails.sEventText=objOrder.Job__r.Delivery_Slot__c;
            eventDetailsLst.add(objEventDetails);
        }
        
        List<QuoteProduct> quoteProductLst= new List<QuoteProduct>{};
        DiaryEntryList=new List<Diary_Entry__c>{};
        DiaryEntryList=[Select Employee_Name__c,Week__r.Employee__r.Phone_No__c,Sub_Type__c,Week__r.Employee__r.Street__c,
                                Week__r.Employee__r.City__c,Week__r.Employee__r.State__c,Week__r.Employee__r.Country__c,
                                Week__r.Employee__r.Postcode__c  
                                From Diary_Entry__c where Job__c=:objOrder.Job__r.Id 
                                And Record_Type__c='Job Booking']; 
                                   
        for (Diary_Entry__c objDiary:DiaryEntryList){
            objEventDetails=new EventDetails();
            objEventDetails.sEvent='Installation';
            dtCreatedDate=objOrder.Job__r.Installation_Date__c;
            objEventDetails.sEventDt=dtCreatedDate.format();
            objEventDetails.sResponsible=objDiary.Employee_Name__c;
            objEventDetails.sContactNo=objDiary.Week__r.Employee__r.Phone_No__c;
            objEventDetails.sEventText=objOrder.Job__r.Delivery_Slot__c;
            eventDetailsLst.add(objEventDetails); 
        }
        
        String sSupplierNum=[Select Supplier__r.Supplier_Num__c From order__c Where Id=:objOrder.Id].Supplier__r.Supplier_Num__c;
        

        Employee__c objEmployee=[Select Phone_No__c,Street__c,City__c,State__c,Country__c,Postcode__c,First_Name__c, Last_Name__c From Employee__c
                                Where Employee_Number__c=:sInstallerId];
        strPrimInstaller=objEmployee.First_Name__c + ' ' + objEmployee.Last_Name__c;
        strPrimInstaStreet=objEmployee.Street__c;
        strPrimInstaCity=objEmployee.City__c;
        strPrimInstaCounty=objEmployee.State__c;
        strPrimInstaPostCode=objEmployee.Postcode__c;
        strPrimInstaCountry=objEmployee.Country__c;    

        fixedRateItems=new List<RateItemDetails>{};
        hourlyRateItems=new List<RateItemDetails>{};
        RateItemDetails objRateItemDetails=new RateItemDetails();
        
        
        List<Order_Line_Item__c> w_orderElementList=[Select Code__c, Description__c,Rate_Type__c, 
                                Units__c, P5_Unit_Price_c__c,Total_Amount__c,Skill__c,Qty__c,P5_Status_c__c
                                 From Order_Line_Item__c Where P5_Type__c='Work' and  
                                 P5_Purchase_Order__c=:objOrder.Id and P5_Status_c__c<>'Cancelled'
                                 Order By Description__c Asc];
        dblTotalJobHrs=0; 
        Double hourlyQty=0;
        for (Order_Line_Item__c objOrderLine: w_orderElementList){
            hourlyQty=0;
            if (objOrderLine.P5_Status_c__c!='Cancelled') {
                objRateItemDetails=new RateItemDetails();
                objRateItemDetails.sCode=objOrderLine.Code__c;
                objRateItemDetails.sDescription=objOrderLine.Description__c;
                objRateItemDetails.sSkill=objOrderLine.Skill__c;
                hourlyQty=objOrderLine.Qty__c;
                objRateItemDetails.sQty=hourlyQty.intValue();
                if (hourlyQty!=0 || hourlyQty!=null) {
                    objRateItemDetails.dblUnitValue=(objOrderLine.Units__c/hourlyQty);
                } else {
                    objRateItemDetails.dblUnitValue=objOrderLine.Units__c;
                    objRateItemDetails.sQty=1;
                }
                objRateItemDetails.dblTotalHrs=objOrderLine.Units__c;
                dblTotalJobHrs=dblTotalJobHrs+ objOrderLine.Units__c;
                if (objOrderLine.Rate_Type__c=='Fixed'){
                    fixedRateItems.add(objRateItemDetails);
                }else {
                    hourlyRateItems.add(objRateItemDetails);                    
                }   
            }
        }
        if (fixedRateItems.size()==0){
            fixedRateItems=null;
        }
        if (hourlyRateItems.size()==0){
            hourlyRateItems=null;
        }
        /* 
        //Material Order Details Related to this Job

        */
        
        /* 
        //Quote product related to this Job
        */
        
        /*
        //Asbestos and electrical Element 
        
        //Check whether any Electrical Bonding is required or not
        
        
        //Check whether any Electrical 
        */
        
    }

}