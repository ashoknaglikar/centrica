public class TopcallFaxExtension {
    
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
        public Double dblHrlyRate{get;set;}
        public Double dblTotalAmount{get;set;}
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
    public class MaterialItemDetailsLst{
    	public List<MaterialItemDetails> materialItemDetailLst{get;set;}
    	public Integer PageNo {get; set;}
    	/*
    	public List<MaterialItemDetails> getMaterialItemDetailLst(){
    		return materialItemDetailLst;
    	}
    	public void setMaterialItemDetailLst(List<MaterialItemDetails> values){
    		values=materialItemDetailLst;
    	}
    	*/
    }
    
    public Double dblTotalJobHrs{get;set;}
    public String strScaffolding{get;set;}
    public String strElectrical{get;set;}
    public String strAsbestos{get;set;}
    public String strElectricalDesc{get;set;}
    public String strElectricalProdId{get;set;}
    public Integer TotalPages{get; set;}
    
    public List<Job_Element__c> jobEleScaffold{get;set;}
    public List<Job_Element__c> jobEleElectrical{get;set;}
    public List<Job_Element__c> jobEleAsbestos{get;set;}
    public List<Job_Element__c> jobEleDisconnElemList{get;set;}
        
    
    public List<RateItemDetails> fixedRateItems{get;set;}
    public List<RateItemDetails> hourlyRateItems{get;set;}
    public List<MaterialItemDetails> materialItemLst{get;set;}
    
    public List<MaterialItemDetailsLst> materialItemLstLst{get;set;}
    
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
    public Double sAmendmentNo{get;set;}
    
    private Integer iInitialLineCount=14;
    private Integer descPerLine = 35;
    private Integer iLinesInPage=65;
    
    public List<Order_Line_Item__c> orderElementList{get;set;}
    private List<Order_Line_Item__c> m_orderElementList;
    public TopcallFaxExtension(ApexPages.StandardController controller) {
        this.objActOrder=(order__c)controller.getRecord();
        materialItemLst=new List<MaterialItemDetails>{};
        materialItemLstLst=new List<MaterialItemDetailsLst>{};
        MaterialItemDetails objMaterialItem=new MaterialItemDetails();
        MaterialItemDetailsLst materialInfo=new MaterialItemDetailsLst();
        m_orderElementList=new List<Order_Line_Item__c>{};
        objOrder=[Select Type__c,Sales_By__c,Job__r.Quote__r.createdDate_quote__c,Job__r.Quote__r.submittedDate_quote__c,Job__r.Id,
                        Job_Delivery_Date__c,Job__r.Delivery_Slot__c,Job__r.Installation_Date__c,Job__c,Amendment_Number__c,Job__r.Document_Return_Date__c
                        From order__c Where Id=:objActOrder.Id];
         try {
         dtReturnDate=objOrder.Job__r.Document_Return_Date__c;
         dtReturnDate=dtReturnDate.addDays(5);
         
         cls_IsRun objMonthName=new cls_IsRun();
         sReturnDate= dtReturnDate.day().format() + '-' + objMonthName.returnMonth(dtReturnDate.month()) + '-' + dtReturnDate.year();
         } catch(Exception ex){
             //do nothing
         }                       
        sAmendmentNo=objOrder.Amendment_Number__c.setScale(0);
        
        if (objOrder.Type__c=='Work'){
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
                /*
                if (objDiary.Sub_Type__c=='Mechanical'){
                    strPrimInstaller=objDiary.Employee_Name__c.split('-')[0];
                    strPrimInstaStreet=objDiary.Week__r.Employee__r.Street__c;
                    strPrimInstaCity=objDiary.Week__r.Employee__r.City__c;
                    strPrimInstaCounty=objDiary.Week__r.Employee__r.State__c;
                    strPrimInstaPostCode=objDiary.Week__r.Employee__r.Postcode__c;
                    strPrimInstaCountry=objDiary.Week__r.Employee__r.Country__c;    
                } 
                */  
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
            
            DiaryEntryList=new List<Diary_Entry__c>{};
            DiaryEntryList=[Select Employee_Name__c,Week__r.Employee__r.Phone_No__c,Sub_Type__c,Week__r.Employee__r.Street__c,
                                    Week__r.Employee__r.City__c,Week__r.Employee__r.State__c,Week__r.Employee__r.Country__c,
                                    Week__r.Employee__r.Postcode__c  
                                    From Diary_Entry__c where Job__c=:objOrder.Job__r.Id 
                                    And Record_Type__c='Job Booking' And Week__r.Employee__r.Supplier__r.Supplier_Num__c=:sSupplierNum];
            for (Diary_Entry__c objDiaryEntry:DiaryEntryList){
                if (objDiaryEntry.Sub_Type__c=='Mechanical'){
                    strPrimInstaller=objDiaryEntry.Employee_Name__c.split('-')[0];
                    strPrimInstaStreet=objDiaryEntry.Week__r.Employee__r.Street__c;
                    strPrimInstaCity=objDiaryEntry.Week__r.Employee__r.City__c;
                    strPrimInstaCounty=objDiaryEntry.Week__r.Employee__r.State__c;
                    strPrimInstaPostCode=objDiaryEntry.Week__r.Employee__r.Postcode__c;
                    strPrimInstaCountry=objDiaryEntry.Week__r.Employee__r.Country__c;    
                    break;
                } else {
                    strPrimInstaller=objDiaryEntry.Employee_Name__c.split('-')[0];
                    strPrimInstaStreet=objDiaryEntry.Week__r.Employee__r.Street__c;
                    strPrimInstaCity=objDiaryEntry.Week__r.Employee__r.City__c;
                    strPrimInstaCounty=objDiaryEntry.Week__r.Employee__r.State__c;
                    strPrimInstaPostCode=objDiaryEntry.Week__r.Employee__r.Postcode__c;
                    strPrimInstaCountry=objDiaryEntry.Week__r.Employee__r.Country__c;    
                }       
            }
            
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
                    objRateItemDetails.dblHrlyRate=objOrderLine.P5_Unit_Price_c__c;
                    objRateItemDetails.dblTotalAmount=objOrderLine.Total_Amount__c;
                    System.debug('@@@@@@@@@@@@objOrderLine.Rate_Type__c :' + objOrderLine.Rate_Type__c);
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
            m_orderElementList=[Select Code__c, Description__c, 
                                    Units__c, P5_Unit_Price_c__c,Total_Amount__c,Actual_Code__c 
                                     From Order_Line_Item__c Where P5_Type__c='Material' and  
                                     P5_Purchase_Order__r.Job__c=:objOrder.Job__r.Id and P5_Status_c__c<>'Cancelled'
                                     Order By Description__c Asc];
            Double dblQty=0;
            for (Order_Line_Item__c objOrderLineItem:m_orderElementList){
                objMaterialItem=new MaterialItemDetails();
                objMaterialItem.sCode=objOrderLineItem.Actual_Code__c;
                objMaterialItem.sDescription=objOrderLineItem.Description__c;
                dblQty=objOrderLineItem.Units__c;
                objMaterialItem.iQty=dblQty.intValue();
                materialItemLst.add(objMaterialItem);       
            }
            BoilerLst=new List<QuoteProduct>{};
            RadiatorLst=new List<QuoteProduct>{};
            ValvesLst=new List<QuoteProduct>{};
            ControlsLst =new List<QuoteProduct>{};
            CylinderLst= new List<QuoteProduct>{};
            QuoteProductTypeMap=new Map<String,QuoteProductType>{};
            QuoteProduct objQuotePrd;
            QuoteProductType objQuotePrdType=new QuoteProductType();
            List<Quote_Product__c> quoteActualProductLst=[Select Component_Group_Type__c, installationNotes__c, 
                                                        installationLocation__c, Product_Description__c From
                                                        Quote_Product__c Where BigMachines_Quote__c=:objOrder.Job__r.Quote__c];
            for (Quote_Product__c objQuoteProduct:quoteActualProductLst){
                quoteProductLst= new List<QuoteProduct>{};
                objQuotePrdType=new QuoteProductType();
                objQuotePrd=new QuoteProduct();
                objQuotePrd.sDescription=objQuoteProduct.Product_Description__c;
                objQuotePrd.sRoom=objQuoteProduct.installationLocation__c;
                objQuotePrd.sPosition='';
                objQuotePrd.sNotes=objQuoteProduct.installationNotes__c;    
                if (objQuoteProduct.Component_Group_Type__c=='Boiler')  {
                    BoilerLst.add(objQuotePrd); 
                }else if (objQuoteProduct.Component_Group_Type__c=='Radiator')  {
                    RadiatorLst.add(objQuotePrd);   
                } else if (objQuoteProduct.Component_Group_Type__c=='Valves'){
                    ValvesLst.add(objQuotePrd);
                } else if (objQuoteProduct.Component_Group_Type__c=='Control') {
                    ControlsLst.add(objQuotePrd);
                } else if (objQuoteProduct.Component_Group_Type__c=='Cylinder'){
                    CylinderLst.add(objQuotePrd);
                } else {
                    if (objQuoteProduct.Component_Group_Type__c!=null ){
                        if (objQuoteProduct.Component_Group_Type__c!=''){
                            if(!QuoteProductTypeMap.containskey(objQuoteProduct.Component_Group_Type__c)){
                                objQuotePrdType.sType=objQuoteProduct.Component_Group_Type__c;
                                quoteProductLst.add(objQuotePrd);
                                objQuotePrdType.setQuoteProductLst(quoteProductLst);
                            }   else {
                                objQuotePrdType=QuoteProductTypeMap.get(objQuoteProduct.Component_Group_Type__c);
                                quoteProductLst=objQuotePrdType.getQuoteProductLst();
                                quoteProductLst.add(objQuotePrd);
                                objQuotePrdType.setQuoteProductLst(quoteProductLst);
                            }
                            QuoteProductTypeMap.put(objQuoteProduct.Component_Group_Type__c,objQuotePrdType);
                        }
                    } 
                }

            }
            if (BoilerLst.size()==0){
                BoilerLst=null;
            }
            if (RadiatorLst.size()==0){
                RadiatorLst=null;
            }
            if (ValvesLst.size()==0){
                ValvesLst=null;
            }
            if (ControlsLst.size()==0){
                ControlsLst=null;
            }
            if (CylinderLst.size()==0){
                CylinderLst=null;
            }
            
            
            //jobElementList=new List<Job_Element__c>{};
            jobEleAsbestos=new List<Job_Element__c>{};
            jobEleScaffold=new List<Job_Element__c>{};
            jobEleElectrical=new List<Job_Element__c>{};
            jobEleDisconnElemList=new List<Job_Element__c>{};
            List<String> productIdList=new List<String>{};
            //Check whether Asbestos Removal required or not
            jobEleAsbestos = [Select Description__c From Job_Element__c Where Job_Element__c.Description__c Like:'Licensed Asbestos Removal%' and Job__c=:objOrder.Job__c];
            strAsbestos=((jobEleAsbestos.size()>0) ? 'Y' : 'N' );
            
            //Check whether Scaffolding is required or Not
            jobEleScaffold=[Select Description__c From Job_Element__c Where Job_Element__c.Description__c Like:'SCAFFOLDING%' and Job__c=:objOrder.Job__c];
            strScaffolding=((jobEleScaffold.size()>0) ? 'Y' : 'N' );
            
            //Check whether any Electrical Bonding is required or not
            productIdList=new List<String>{};
            productIdList.add('P296');
            productIdList.add('P2962');
            productIdList.add('P2963');
            productIdList.add('P2967');
            productIdList.add('PAQ07');
            productIdList.add('PL200');
            productIdList.add('PL201');
            productIdList.add('PM160');
            productIdList.add('PR20');
            jobEleElectrical=[Select Description__c, Product_ID__c From Job_Element__c Where Product_ID__c In: productIdList and Job__c=:objOrder.Job__c limit 1];
            strElectrical=((jobEleElectrical.size()>0) ? 'Y' : 'N' );
            strElectricalProdId=((strElectrical=='Y') ? jobEleElectrical[0].Product_ID__c : '');
            strElectricalDesc=((strElectrical=='Y') ? jobEleElectrical[0].Description__c : '');
            
            
            //Check whether any Electrical 
            productIdList=new List<String>{};

            productIdList.add('P334');
            productIdList.add('P335');
            jobEleDisconnElemList=[Select Description__c, Units__c From Job_Element__c Where Product_ID__c In: productIdList and Job__c=:objOrder.Job__c];
            
            
        }else if (objOrder.Type__c=='Material'){
        	
        	
            m_orderElementList=[Select Units__c, Description__c, Code__c,Actual_Code__c 
                                From Order_Line_Item__c Where P5_Type__c=:'Material' 
                                and P5_Purchase_Order__c=:objOrder.Id and P5_Status_c__c!='Cancelled'
                                Order By Description__c Asc];   
            Double dblQty=0;
            Integer pageNo = 1;
            Long lineNum = iInitialLineCount;
            for (Order_Line_Item__c objOrderLineItem:m_orderElementList){
            	Decimal tempNo = (Decimal)objOrderLineItem.Description__c.length()/descPerLine;
            	Long descLines = tempNo.round(System.RoundingMode.CEILING);
            	System.debug('^^^^^^^^^^^^^^^^^^^^^' + (lineNum + descLines));
            	if(lineNum + descLines >= iLinesInPage){
            		lineNum= descLines ;
            		materialInfo=new MaterialItemDetailsLst();
            		System.debug('%%%%%%%%%%%%% ' + materialItemLst);
            		materialInfo.materialItemDetailLst=materialItemLst;
            		materialInfo.PageNo = pageNo++;
            		System.debug('#####################' + materialInfo);
                	materialItemLstLst.add(materialInfo);
                	System.debug('%%%%%%%%%%%%% ' + materialItemLstLst);
                	
                	materialItemLst = new List<MaterialItemDetails>{};
                	objMaterialItem=new MaterialItemDetails();
                	objMaterialItem.sCode=objOrderLineItem.Actual_Code__c;
                	objMaterialItem.sDescription=objOrderLineItem.Description__c;
                	dblQty=objOrderLineItem.Units__c;
                	objMaterialItem.iQty=dblQty.intValue();
                	materialItemLst.add(objMaterialItem);  
            	} else {
            		lineNum+= descLines;
            		
            		objMaterialItem=new MaterialItemDetails();
                	objMaterialItem.sCode=objOrderLineItem.Actual_Code__c;
                	objMaterialItem.sDescription=objOrderLineItem.Description__c;
                	dblQty=objOrderLineItem.Units__c;
                	objMaterialItem.iQty=dblQty.intValue();
                	materialItemLst.add(objMaterialItem);  
                	System.debug('%%%%%%%%%%%%% ' + materialItemLst);
            	}     
            }
            if(materialItemLst.size() > 0){
	            materialInfo=new MaterialItemDetailsLst();
            	materialInfo.materialItemDetailLst=materialItemLst;
            	materialInfo.PageNo = pageNo;
                materialItemLstLst.add(materialInfo);
        	}
        	TotalPages = materialItemLstLst.size();
        	System.debug('%%%%%%%%%%%%% ' + materialItemLstLst);
        }
    }

}