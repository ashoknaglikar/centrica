// comment this class is used to generate orders for job
public class PurchaseOrderGenertion {
    public class PurchaseOrder{
        public String sSupplierName{get;set;}
        public String sSupplierId{get;set;}
        public Date dtOrderDt{get;set;}
        public String sDispDate{get;set;}
        public String sSAPNumber{get;set;}
        public List<Job_Element__c> jobElementLst{get;set;}
        public List<OrderLineItem> orderLineItemLst{get;set;}
        public Double dblOrderValue{get;set;}
        public String sOrderType{get;set;}
        public String sOrderId{get;set;}
        private Double dblTotal;
        public Boolean blFaxEnabled{get;set;}
        public Boolean isUserDefinedPO{get;set;}
    }
    public class OrderLineItem { 
        public String sJobElementDescription{get;set;}
        public String sStatus{get;set;}
        public String sSubStatus{get;set;}
        public String sType{get;set;}
        public Double dblUnits{get;set;}
        public Double dblUnitPrice{get;set;}
        public String sSupplier{get;set;}
        public String sSkill{get;set;}
        public String sItemCode{get; set;}
        public Double dblTotalPrice{get;set;}
        public String sSAPNumberCode{get;set;}
        public String sRateType{get;set;}
        Public Double dblQty{get;set;}
        private List<Job_Element__c> sJobElementLst=new List<Job_Element__c>{};
        public List<Job_Element__c> getSJobElementLst(){return sJobElementLst;}
        public void setSJobElementLst(List<Job_Element__c> value){sJobElementLst=value;}
        //  Defect fix for EDI interface to identify this as user defined order line item.
        public boolean isUserDefinedOrderLine = false;
        // rebate
        double Rebate = 0.00;
        
    } 
    private class SupplierDetails{
        public String sSupplierName{get;set;}
        public String sSupplierId{get;set;}
        public String sSupplierNum{get;set;}
        public String sSupplierPhone{get;set;}
        public Boolean blVanstock{get;set;}
        public Integer intSupplierPref{get;set;}
        public Boolean blFaxEnabled{get;set;}
        public decimal vanStockValue{get;set;}
    }  
    
    public class underOrderedItem{
        public Job_Element__c objJobElement{get;set;}
        public String sSupplierId{get;set;} 
        public Boolean blNoPrice{get;set;}
        private List<Job_Element__c> sJobElementIdLst=new List<Job_Element__c>{};
        public List<Job_Element__c> getSJobElementIdLst(){return sJobElementIdLst;}
        public void setSJobElementIdLst(List<Job_Element__c> value){sJobElementIdLst=value;}
        public String sErrorText{get;set;}
        public String sSupplierName{get;set;}
    }
    
    public List<underOrderedItem> m_noPriceInformation{get;set;}
    public List<underOrderedItem> im_noPriceInformation{get;set;}
    public List<underOrderedItem> w_noPriceInformation{get;set;}
    public List<underOrderedItem> iw_noPriceInformation{get;set;}
    
    public Boolean blError{get;set;}
    public List<underOrderedItem> m_UnOrderedItem{get;set;}
    public List<underOrderedItem> im_UnOrderedItem{get;set;}
    
    public boolean blMatUnorder{get;set;}
    public boolean blItMatUnorder{get;set;}
    
    public boolean blNoMatPrice{get;set;}
    public boolean blNoItMatPrice{get;set;}
    public boolean blNoWorkPrice{get;set;}
    public boolean blNoItWorkPrice{get;set;}
    
    // Cognizant - CHI Phase III CR-005 implementation... START
    
    private Job__c objJobUDP;
    private PurchaseOrder updPO = new PurchaseOrder();
    private List<PurchaseOrder> updPOList = new List<PurchaseOrder>();
    private List<PurchaseOrder> m_PurchaseOrderLst = new List<PurchaseOrder>();
    private List<Job_Element__c> poJobElementList = new List<Job_Element__c>();
    private List<Job_Element__c> udpNewJEList = new List<Job_Element__c>();
    private List<Job_Element__c> job_ElementLstUDP=new List<Job_Element__c>{};
    private Map<String,Job_Element__c> idJEMap=new Map<String,Job_Element__c>();
    private Map<String,List<Job_Element__c>> udpSupJeMAP=new Map<String,List<Job_Element__c>>();
    private Map<String,List<Job_Element__c>> um_JobElementMap=new Map<String,List<Job_Element__c>>{}; 
    public Map<String,String> udp_SupplierBranchMAP=new Map<String,String>();
    public Map<Id,String> udp_SuppIdNumMap = new Map<Id,String>();
    public List<Supplier__c> udp_AllMaterialSuppliers{get;set;}
    // Cognizant - CHI Phase III CR-005 implementation... END
    
    private Map<String,List<Job_Element__c>> m_JobElementMap=new Map<String,List<Job_Element__c>>{};
    private Map<String,List<Job_Element__c>> w_JobElementMap=new Map<String,List<Job_Element__c>>{};
    private Map<String,List<Job_Element__c>> im_JobElementMap=new Map<String,List<Job_Element__c>>{};
    private Map<String,List<Job_Element__c>> iw_JobElementMap=new Map<String,List<Job_Element__c>>{};
    private Map<String,List<Job_Element__c>> vanStock_JobElementMap=new Map<String,List<Job_Element__c>>{};
    private Map<String,List<Job_Element__c>> nonOrderable_JobElementMap=new Map<String,List<Job_Element__c>>{};
    private Map<String,List<Job_Element__c>> m_PrimaryJobElementMap=new Map<String,List<Job_Element__c>>{};
    private Map<String,List<Job_Element__c>> m_SecondaryJobElementMap=new Map<String,List<Job_Element__c>>{};
    
    private List<PurchaseOrder> purchaseOrderIntermList=new List<PurchaseOrder>{};
    private Map<String,Map<String,List<Job_Element__c>>> w_SupplierJobElementMap=new Map<String,Map<String,List<Job_Element__c>>>{};
    private Map<String,Map<String,List<Job_Element__c>>> iw_SupplierJobElementMap=new Map<String,Map<String,List<Job_Element__c>>>{};
    private Map<String,Map<String,Rate_Card_Items__c>> m_RateCard;
    private Map<String,Map<String,Rate_Card_Items__c>> im_RateCard;
    private Set<String> sSupplierNumSet = new Set<String>{};
    private Set<String> isSupplierNumSet = new Set<String>{};
    private Map<String,SupplierDetails> m_SupplierMap=new Map<String,SupplierDetails>{};
    private Map<String,SupplierDetails> l_SupplierMap=new Map<String,SupplierDetails>{};
    private Map<String,SupplierDetails> im_SupplierMap=new Map<String,SupplierDetails>{};
    private Map<String,SupplierDetails> il_SupplierMap=new Map<String,SupplierDetails>{};

    private String sPrimarySuppNum;
    private String sSecondarySuppNum;
    private String sDistrict;
    private Job__c objJob;
    private final Job__c objCurrentJob;
    private Boolean blConfirm =false;
    public Boolean getBlConfirm() {return blConfirm;}
    public void setBlConfirm(Boolean value) {blConfirm=value;}
    private Boolean blVanStock=false;
    
    // Vanstock change Begin : 18/05/11
    private decimal maxVanStockValue = 0;
    private String supplId;
    //Vanstock change: End
   
        
    private Postcode_Sector__c objPostCodeSector= new Postcode_Sector__c();
    private String sPostCodeId;//=objJob.CHI_Lead__r.Account.BillingPostalCode;
    private String sRegionId;//=sPostCode.substring(0,sPostCode.length()-2);
    private List<SAP_Number__c> sapNumberLst;
    // Defect fix for duplicate SAP number issue.
    private List<SAP_Number__c> sapNumberLst_Used; 
    public List<PurchaseOrder> purchaseOrderList = new List<PurchaseOrder>();
    private selectRateForElements objRateCard;
    
    public List<PurchaseOrder> getPurchaseOrderList (){
        return this.purchaseOrderList;
    }
    public void setPurchaseOrderList (List<PurchaseOrder> value){
        this.purchaseOrderList=value;
    }
    
    public PurchaseOrderGenertion(Apexpages.standardController controller){
        this.objCurrentJob=(Job__c)controller.getRecord();
 
              if (blConfirm==false){
            m_noPriceInformation=new List<underOrderedItem>{};
            im_noPriceInformation=new List<underOrderedItem>{};
            w_noPriceInformation=new List<underOrderedItem>{};
            iw_noPriceInformation = new List<underOrderedItem>{};
            
            m_UnOrderedItem = new List<underOrderedItem>{};
            im_UnOrderedItem=new List<underOrderedItem>{};
    
            // Cognizant - CHI Phase III CR-005 implementation... START
            
            // Added fields of user defined asp in the query. Below query will not fetch the user defined job elements.
            objJob=[Select Id,Name, Regenerate_Purchase_Orders__c, CHI_Lead__r.AccountId, CHI_Lead__r.Account.BillingPostalCode,District__c,District__r.Region__c,
                    (Select Id, Line_Item_ID__c, Skill__c, Units__c,Description__c,Status__c, 
                    Sub_Status__c, Supplier_Order_Number__c,Code__c, 
                    Type__c, Order__c,New_Supplier__c, New_Supplier_Number__c, Current_Supplier__c, 
                    Current_Supplier_Number__c,P5_IsItinerary__c,Is_Vanstock__c,
                    Do_Not_Assign_Order__c,Merchant_Price__c,Merchant_Order_Number__c,Remove_Waste__c,User_Defined_Product__c  From  Job_Elements1__r Where Remove_Waste__c='N' 
                    and User_Defined_Product__c=false and Status__c!='Removed'),LastModifiedById,Order_Locking_User__c,order_locking_time__c,Order_Locking_User__r.Name From Job__c  where id= :objCurrentJob.Id];     
            
            // Below query fetches only user defined job elements whose status is not Removed.        
            objJobUDP=[Select Name, Regenerate_Purchase_Orders__c, CHI_Lead__r.AccountId, CHI_Lead__r.Account.BillingPostalCode,District__c,District__r.Region__c,
                        (Select Id, Name, Line_Item_ID__c, Skill__c, Units__c,Description__c,Status__c, 
                        Sub_Status__c, Supplier_Order_Number__c,Code__c, 
                        Type__c, Order__c,New_Supplier__c, New_Supplier_Number__c, Current_Supplier__c, 
                        Current_Supplier_Number__c,P5_IsItinerary__c,Is_Vanstock__c,
                        Do_Not_Assign_Order__c,Merchant_Price__c,Merchant_Order_Number__c,Remove_Waste__c,User_Defined_Product__c  From  Job_Elements1__r Where Remove_Waste__c='N' 
                        and User_Defined_Product__c=true and Status__c!='Removed' and Sub_Status__c!='Ordered') From Job__c  where id= :objCurrentJob.Id];
            
            udp_AllMaterialSuppliers = [Select ID,Supplier_Num__c,Fax_Setup__c,Name,Phone1__c,Van_Stock__c From Supplier__c 
                                        Where Type__c = 'Product' and Available_For_User_Defined__c = True];
        
            if(objJob.Order_Locking_User__c!= userinfo.getUserId()&& objJob.Order_Locking_User__c!=null)
            {
                 Job__c Job = [select Order_Locking_User__r.Name from Job__c where Id = :objJob.Id];
                 ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order cannot be generated. As the orders are being Processed by '+Job.Order_Locking_User__r.Name);
                 ApexPages.addMessage(errMsg);
                 blConfirm=false;
                 blError = true;
            }
            
           /*  if(ApexPages.currentPage().getParameters().get('bookoption')=='1')
        {
        	
             blConfirm=true;
        }
        */
                                         
            for (Supplier__c supp:udp_AllMaterialSuppliers){
                      //udp_All_Supplier_List.add(new Selectoption(supp.Supplier_Num__c,supp.Name)); 
                      //udp_Supplier_Map.put(supp.Supplier_Num__c,supp); 
                      udp_SuppIdNumMap.put(supp.ID,supp.Supplier_Num__c); 
            }
            
            // Preparing the Map<JE Code,List<JE>> for all user defined job elements            
            for (Job_Element__c objJobElementUDP:objJobUDP.Job_Elements1__r)
            {
                if (objJobElementUDP.Status__c!='Removed' || objJobElementUDP.Remove_Waste__c!='Y')
                {
                    job_ElementLstUDP=new List<Job_Element__c>{};
                    
                    if (!um_JobElementMap.containsKey(objJobElementUDP.Code__c))
                    {
                        job_ElementLstUDP.add(objJobElementUDP);
                    } 
                    else 
                    {
                        job_ElementLstUDP=um_JobElementMap.get(objJobElementUDP.Code__c);
                        job_ElementLstUDP.add(objJobElementUDP);                      
                    }
                    um_JobElementMap.put(objJobElementUDP.Code__c,job_ElementLstUDP);                       
                }                   
            }              
            // Cognizant - CHI Phase III CR-005 implementation... END
            
            sDistrict=objJob.District__c;
            List<Job_Element__c> job_ElementLst=new List<Job_Element__c>{};            
            String sSupplierNum='';
            
            for (Job_Element__c objJobElement:objJob.Job_Elements1__r){
            
                if (objJobElement.Status__c!='Removed' || objJobElement.Remove_Waste__c!='Y'){
                    job_ElementLst=new List<Job_Element__c>{};
                    sSupplierNum='';
                    if (objJobElement.Type__c=='Material' && objJobElement.P5_IsItinerary__c==false){
                        if (!m_JobElementMap.containsKey(objJobElement.Code__c)){
                            job_ElementLst.add(objJobElement);
                        } else {
                            job_ElementLst=m_JobElementMap.get(objJobElement.Code__c);
                            job_ElementLst.add(objJobElement);                      
                        }//End if
                        m_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                    } else if (objJobElement.Type__c=='Work' && objJobElement.P5_IsItinerary__c==false){
                        if (objJobElement.New_Supplier_Number__c!=null){
                            sSupplierNumSet.add(objJobElement.New_Supplier_Number__c);  
                            sSupplierNum=objJobElement.New_Supplier_Number__c;
                        } else {
                            sSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                            sSupplierNum=objJobElement.Current_Supplier_Number__c;
                        }//End if
                        w_JobElementMap=new Map<String,List<Job_Element__c>>{};
                        if (!w_SupplierJobElementMap.containsKey(sSupplierNum)){
                            if (!w_JobElementMap.containsKey(objJobElement.Code__c)){
                                job_ElementLst.add(objJobElement);
                            } else {
                                job_ElementLst=w_JobElementMap.get(objJobElement.Code__c);
                                job_ElementLst.add(objJobElement);                      
                            }//End if
                            w_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                        }else {
                            w_JobElementMap=w_SupplierJobElementMap.get(sSupplierNum);
                            if (!w_JobElementMap.containsKey(objJobElement.Code__c)){
                                job_ElementLst.add(objJobElement);
                            } else {
                                job_ElementLst=w_JobElementMap.get(objJobElement.Code__c);
                                job_ElementLst.add(objJobElement);                      
                            }//End if   
                            w_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                        }//End if
                        w_SupplierJobElementMap.put(sSupplierNum,w_JobElementMap);
                    } else if (objJobElement.Type__c=='Material' && objJobElement.P5_IsItinerary__c==true){
                        if (!im_JobElementMap.containsKey(objJobElement.Code__c)){
                            job_ElementLst.add(objJobElement);
                        } else {
                            job_ElementLst=im_JobElementMap.get(objJobElement.Code__c);
                            job_ElementLst.add(objJobElement);                      
                        }//End if
                        im_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                    } else if (objJobElement.Type__c=='Work' && objJobElement.P5_IsItinerary__c==true) {
                        if (objJobElement.New_Supplier_Number__c!=null){
                            isSupplierNumSet.add(objJobElement.New_Supplier_Number__c);  
                            sSupplierNum=objJobElement.New_Supplier_Number__c;
                        } else if (objJobElement.Current_Supplier_Number__c!=null){
                            isSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                            sSupplierNum=objJobElement.Current_Supplier_Number__c;
                        }//End if
                        if (sSupplierNum!=''){
                            iw_JobElementMap=new Map<String,List<Job_Element__c>>{};
                            if (!iw_SupplierJobElementMap.containsKey(sSupplierNum)){
                                if (!iw_JobElementMap.containsKey(objJobElement.Code__c)){
                                    job_ElementLst.add(objJobElement);
                                } else {
                                    job_ElementLst=iw_JobElementMap.get(objJobElement.Code__c);
                                    job_ElementLst.add(objJobElement);                      
                                }//End if
                                iw_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                            }else {
                                iw_JobElementMap=iw_SupplierJobElementMap.get(sSupplierNum);
                                if (!iw_JobElementMap.containsKey(objJobElement.Code__c)){
                                    job_ElementLst.add(objJobElement);
                                } else {
                                    job_ElementLst=iw_JobElementMap.get(objJobElement.Code__c);
                                    job_ElementLst.add(objJobElement);                      
                                }//End if   
                                iw_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                            }//End if
                            iw_SupplierJobElementMap.put(sSupplierNum,iw_JobElementMap);
                        }
                    }//End if
                }//End if
            }//End For
            
            String sPostCode=objJob.CHI_Lead__r.Account.BillingPostalCode;
            String sPostCodeSector=sPostCode.substring(0,sPostCode.length()-2);

            objPostCodeSector=[Select P5_Secondary_Supplier__r.Name, P5_Secondary_Supplier__c,P5_Secondary_Supplier__r.Id,
                                                    P5_Secondary_Supplier__r.Supplier_Num__c, 
                                                    P5_Secondary_Supplier__r.Van_Stock__c,
                                                    P5_Secondary_Supplier__r.Fax__c,P5_Primary_Supplier__c,
                                                    P5_Primary_Supplier__r.Name, P5_Primary_Supplier__r.Id, 
                                                    P5_Secondary_Supplier__r.Fax_Setup__c, P5_Primary_Supplier__r.Fax_Setup__c,
                                                    P5_Primary_Supplier__r.Supplier_Num__c,
                                                    P5_Primary_Supplier__r.Van_Stock__c,
                                                    P5_Primary_Supplier__r.Van_Stock_Value__c,
                                                    P5_Secondary_Supplier__r.Van_Stock_Value__c,
                                                    P5_Primary_Supplier__r.Fax__c
                                                    From Postcode_Sector__c Where Code__c=:sPostCodeSector
                                                    And Type__c=:'Installation'];
            sPostCodeId=objPostCodeSector.Id;
            sRegionId=objJob.District__r.Region__c;
            objRateCard=new selectRateForElements();
            //Work Order
            fetchSupplier('Work');
            
            
            //vanstock change
            maxVanStockValue = objRateCard.fetchMaxVanstockvalue(sSupplierNumSet,sRegionId);
            system.debug('Max Vanstock value----->'+maxVanStockValue);
            //vanstock change end
            objRateCard.segregateNonOrderableComponent(m_JobElementMap);
            nonOrderable_JobElementMap=objRateCard.getNonOrderableElementMap();
            m_JobElementMap=new Map<String,List<Job_Element__c>>{};
            m_JobElementMap=objRateCard.getOrderableElementMap();
            
            
            //objRateCard.segregateVanstockElements(m_JobElementMap,blVanStock);
            if(maxVanStockValue > 0) 
            {
                objRateCard.segregateVanstockElementsByRegion(m_JobElementMap,maxVanStockValue);
                m_JobElementMap=new Map<String,List<Job_Element__c>>{};
                m_JobElementMap=objRateCard.getNotVanStockElementMap();
                vanStock_JobElementMap=objRateCard.getVanStockElementMap();
            }
            
            //Fetching Pricing information for the Work Type Job Element
            // Putting the check for not data 
            if (w_SupplierJobElementMap != null){
                Map<String,Map<String,Post_Code_Skill_Rate__c>> postCodeSkillRateMap=new Map<String,Map<String,Post_Code_Skill_Rate__c>>{};
                Map<String,Map<String,Rate_Card_Items__c>> rateCardItemMap = new Map<String,Map<String,Rate_Card_Items__c>>{};
                objRateCard.fetchWorkSupplierRate(l_SupplierMap.keySet(), w_SupplierJobElementMap, sPostCodeId, sRegionId, sDistrict);
                postCodeSkillRateMap=objRateCard.postCodeSkillRateMap;
                rateCardItemMap=objRateCard.rateCardItemMap; 
                for (String sSupplierNumber:l_SupplierMap.keySet()){
                    generateWorkOrder(w_SupplierJobElementMap, postCodeSkillRateMap, rateCardItemMap, sSupplierNumber);
                }
            }
            
            //Itinery Work Order Generation
            
            fetchSupplier('Work-Itinery');
            
            //Fetching Pricing information for the Work Type Job Element
            Map<String,Map<String,Post_Code_Skill_Rate__c>> iPostCodeSkillRateMap=new Map<String,Map<String,Post_Code_Skill_Rate__c>>{};
            Map<String,Map<String,Rate_Card_Items__c>> iRateCardItemMap = new Map<String,Map<String,Rate_Card_Items__c>>{};
            objRateCard.fetchWorkSupplierRate(il_SupplierMap.keySet(), iw_SupplierJobElementMap, sPostCodeId, sRegionId, sDistrict);
            iPostCodeSkillRateMap=objRateCard.postCodeSkillRateMap;
            iRateCardItemMap=objRateCard.rateCardItemMap; 
            for (String sSupplierNumber:il_SupplierMap.keySet()){
                generateItineryWorkOrder(iw_SupplierJobElementMap, iPostCodeSkillRateMap, iRateCardItemMap, sSupplierNumber);
            }
            
            
            //Material Order Generation
            fetchSupplier('Material');
            m_RateCard=new Map<String,Map<String,Rate_Card_Items__c>> {};
            m_RateCard=objRateCard.fetchMaterialSupplierRate(m_SupplierMap.keySet(), m_JobElementMap, sPostCodeId, sRegionId,sDistrict);
            Boolean blnPrimary=true;
            Map<String,Rate_Card_Items__c> m_PrimaryRate=new Map<String,Rate_Card_Items__c>{};
            if (!m_RateCard.containsKey(sPrimarySuppNum)) {
                blnPrimary=false;
            } else {
                m_PrimaryRate=m_RateCard.get(sPrimarySuppNum);
                System.debug('$$$$$$$$$$$$$$  1:' + m_PrimaryRate);
                if (m_PrimaryRate!=null){
                    for (String sTemp:m_JobElementMap.keySet()){
                        if (!m_PrimaryRate.containsKey(sTemp)){
                            blnPrimary=false;
                            break;
                        }//End if
                    }//End For
                } else {
                    blnPrimary=false;
                }//End if
            }//End if
            System.debug('$$$$$$$$$$$$$$  2:' + m_PrimaryRate);
            if (blnPrimary){
                m_PrimaryJobElementMap=new Map<String,List<Job_Element__c>>{};
                m_PrimaryJobElementMap.putAll(m_JobElementMap); 
                generateMaterialOrder(m_PrimaryJobElementMap, sPrimarySuppNum, m_PrimaryRate);
            }else {
                Boolean blnSecondary=true;
                Map<String,Rate_Card_Items__c> m_SecondaryRate=new Map<String,Rate_Card_Items__c>{};
                if (!m_RateCard.containsKey(sSecondarySuppNum)) {
                    blnSecondary=false; 
                } else {
                    m_SecondaryRate=m_RateCard.get(sSecondarySuppNum);
                    if (m_SecondaryRate!=null){
                        for (String sTemp:m_JobElementMap.keySet()){
                            if (!m_SecondaryRate.containsKey(sTemp)){
                                blnSecondary=false;
                                break;
                            }//End if
                        }//End For
                    } else {
                        blnSecondary=false;
                    }//End if
                }//End if 
                if (blnSecondary){
                    m_SecondaryJobElementMap=new Map<String,List<Job_Element__c>>{};
                    m_SecondaryJobElementMap.putAll(m_JobElementMap);   
                    generateMaterialOrder(m_SecondaryJobElementMap, sSecondarySuppNum, m_SecondaryRate);    
                }else {
                    m_PrimaryJobElementMap=new Map<String,List<Job_Element__c>>{};
                    m_SecondaryJobElementMap=new Map<String,List<Job_Element__c>>{};
                    List<String> sJEIDLst=new List<String>{};
                    if (m_PrimaryRate!=null){
                        for (String sTemp:m_JobElementMap.keySet()){
                            if (m_PrimaryRate.containsKey(sTemp)){
                                m_PrimaryJobElementMap.put(sTemp,m_JobElementMap.get(sTemp)); 
                                sJEIDLst.add(sTemp);
                                  
                            }//End if
                        }//end For
                        for (String sJEID:sJEIDLst){
                            m_JobElementMap.remove(sJEID);  
                        }
                    }//End if
                    if (m_PrimaryJobElementMap==null){
                        
                    }else if (m_PrimaryJobElementMap.size()>0){
                        generateMaterialOrder(m_PrimaryJobElementMap, sPrimarySuppNum, m_PrimaryRate);
                    }
                    if (m_SecondaryRate!=null){
                        List<String> sSecJEIDLst=new List<String>{};
                        for (String sTemp:m_JobElementMap.keySet()){
                            if (m_SecondaryRate.containsKey(sTemp)){
                                m_SecondaryJobElementMap.put(sTemp,m_JobElementMap.get(sTemp)); 
                                sSecJEIDLst.add(sTemp);
                                //m_JobElementMap.remove(sTemp);   
                            }//End if
                        }//End For
                        for (String sJEID1:sSecJEIDLst){
                            m_JobElementMap.remove(sJEID1);     
                        }
                    }// End if
                    if (m_SecondaryJobElementMap==null) {
                        
                    } else if (m_SecondaryJobElementMap.size()>0) {
                        generateMaterialOrder(m_SecondaryJobElementMap, sSecondarySuppNum, m_SecondaryRate);
                    }
                    if (m_JobElementMap!=null){
                        m_UnOrderedItem=new List<underOrderedItem>{};
                        underOrderedItem objUnOrdered=new underOrderedItem();
                        List<Job_Element__c> mUnOrderedLst=new List<Job_Element__c>{};
                        Job_Element__c objJobElement;
                        for (String sTemp: m_JobElementMap.keySet()){
                            objUnOrdered=new underOrderedItem();
                            mUnOrderedLst=m_JobElementMap.get(sTemp);
                            objJobElement=new Job_Element__c();
                            objJobElement.Code__c='';
                            objJobElement.Description__c='';
                            objJobElement.Units__c=0;
                            for(Job_Element__c objJobEle:mUnOrderedLst){
                                if(objJobElement.Units__c==0){
                                    objJobElement.Code__c=objJobEle.Code__c;
                                    objJobElement.Description__c=objJobEle.Description__c;
                                    objJobElement.Units__c=objJobEle.Units__c;
                                }else {
                                    objJobElement.Units__c=objJobElement.Units__c + objJobEle.Units__c;
                                }           
                            }
                            objUnOrdered.objJobElement=objJobElement;
                            objUnOrdered.setSJobElementIdLst(mUnOrderedLst);
                            m_UnOrderedItem.add(objUnOrdered);  
                        }//End for
                        fetchTertiarySupplier();
                    }//End if
                    
                      
                }//End if
            }//End if
            if (im_JobElementMap!=null){
                fetchSupplier('Material-Itinery');
                
                im_RateCard=new Map<String,Map<String,Rate_Card_Items__c>> {};
                im_RateCard=objRateCard.fetchMaterialSupplierRate(im_SupplierMap.keySet(), im_JobElementMap, sPostCodeId, sRegionId,sDistrict);
                
                im_UnOrderedItem=new List<underOrderedItem>{};
                underOrderedItem objUnOrdered=new underOrderedItem();
                List<Job_Element__c> imUnOrderedLst=new List<Job_Element__c>{};
                Job_Element__c objJobElement;
                for (String sTemp: im_JobElementMap.keySet()){
                    objUnOrdered=new underOrderedItem();
                    imUnOrderedLst=im_JobElementMap.get(sTemp);
                    objJobElement=new Job_Element__c();
                    objJobElement.Code__c='';
                    objJobElement.Description__c='';
                    objJobElement.Units__c=0;
                    for(Job_Element__c objJobEle:imUnOrderedLst){
                        if(objJobElement.Units__c==0){
                            objJobElement.Code__c=objJobEle.Code__c;
                            objJobElement.Description__c=objJobEle.Description__c;
                            objJobElement.Units__c=objJobEle.Units__c;
                        }else {
                            objJobElement.Units__c=objJobElement.Units__c + objJobEle.Units__c;
                        }           
                    }
                    objUnOrdered.objJobElement=objJobElement;
                    objUnOrdered.setSJobElementIdLst(imUnOrderedLst);
                    im_UnOrderedItem.add(objUnOrdered);  
                }//End for
                fetchitinerySupplier();
            }//End if
                    
            
        }//End if
        
        // Cognizant - CHI Phase III CR-005 implementation... START
        
        // fetching all the PO of type Material
        for(PurchaseOrder PO:purchaseOrderList)
        {
            if(PO.sOrderType == 'Material')
            {
                m_PurchaseOrderLst.add(PO);
            }
        }
        
        // storing all the job elements from diff PO of type Material
        for(PurchaseOrder mPO:purchaseOrderList)
        {
            poJobElementList.addAll(mPO.jobElementLst);
        }
        
        // preparing Map<Job Element Id, Job Element>
        for(Job_Element__c mJE:poJobElementList)
        {           
            idJEMap.put(mJE.Id, mJE);
        }
        
        // removing UDP job elements from the list and storing the new UDP job elements into the list
        for (Job_Element__c udpJE:objJobUDP.Job_Elements1__r)
        {
            if(!idJEMap.containsKey(udpJE.Id))
            {
                udpNewJEList.add(udpJE);
            }                       
        }
        // preparing Map for creating new PO of UDP job elements
        for (Job_Element__c objJobElementUDP:udpNewJEList)
        {
            List<Job_Element__c> udpSupJeList = new List<Job_Element__c>();
                
            if (!udpSupJeMAP.containsKey(objJobElementUDP.Current_Supplier_Number__c))
            {
                udpSupJeList.add(objJobElementUDP);
            } 
            else 
            {
                udpSupJeList=udpSupJeMAP.get(objJobElementUDP.Current_Supplier_Number__c);
                udpSupJeList.add(objJobElementUDP);
            }
            udpSupJeMAP.put(objJobElementUDP.Current_Supplier_Number__c,udpSupJeList);
        }        
        
        // calling generateMaterialOrderForNewSupp() to create new PO for UDP job elements
        for (String sTemp1:udpSupJeMAP.keySet()) 
        {
            Map<String,List<Job_Element__c>> suppJE = new Map<String,List<Job_Element__c>>();
            suppJE.put(sTemp1,udpSupJeMAP.get(sTemp1)); 
            updPO = generateMaterialOrderForNewSupp(suppJE,sTemp1);
            updPOList.add(updPO);               
        }
        //adding UDP po to existing purchaseOrderList
        if(updPOList.size() > 0)
        {
            purchaseOrderList.addAll(updPOList); 
        }  
        // Cognizant - CHI Phase III CR-005 implementation... END
              
        blMatUnorder=(m_UnOrderedItem.size()>0? true : false);
        blItMatUnorder=(im_UnOrderedItem.size()>0? true : false);
        
        blNoMatPrice=(m_noPriceInformation.size()>0? true : false);
        blNoItMatPrice=(im_noPriceInformation.size()>0? true: false);
        blNoWorkPrice=(w_noPriceInformation.size()>0? true : false);
        blNoItWorkPrice=(iw_noPriceInformation.size()>0? true : false);
        
    }//End Of Method
    
    public void generateWorkOrder(Map<String,Map<String,List<Job_Element__c>>> w_SupplierTotalJobElementMap,
                                    Map<String,Map<String,Post_Code_Skill_Rate__c>> postCodeSkillRateMap, 
                                    Map<String,Map<String,Rate_Card_Items__c>> rateCardItemMap,
                                    String sSupplierNum){
        // Fix for fixed rate units calculation
        Integer tmpUnits = 0;
        underOrderedItem objNoPriceInformation=new underOrderedItem();
        PurchaseOrder objPurchaseOrder;
        List<OrderLineItem> orderlineLst;
        List<Job_Element__c> l_SelectedJobElementLst=new List<Job_Element__c>{};
        List<OrderLineItem> orderLineItemLst=new List<OrderLineItem>{};
        Double dblQty=0;
        OrderLineItem objOrderLineItem=new OrderLineItem();
        Map<String,List<Job_Element__c>> w_JobElementIndividualMap=new Map<String,List<Job_Element__c>>{};
        Map<String,Post_Code_Skill_Rate__c> l_PostcodeSkillRate=new Map<String,Post_Code_Skill_Rate__c>{};
        Map<String,Rate_Card_Items__c> l_RateCardItems=new Map<String,Rate_Card_Items__c>{};
        w_JobElementIndividualMap=w_SupplierTotalJobElementMap.get(sSupplierNum);
        l_PostcodeSkillRate=postCodeSkillRateMap.get(sSupplierNum);
        l_RateCardItems=rateCardItemMap.get(sSupplierNum);
        Boolean blnNoPrice=false;
        Boolean blnGenerateOrder=false;
        
        // Added - Product Work Order
        Map<String,Integer> pwcMap = new Map<String,Integer>();
        Set<String> codeSet = new Set<String>();
        
        for (String sTemp:w_JobElementIndividualMap.keyset()){
            l_SelectedJobElementLst=w_JobElementIndividualMap.get(sTemp);
            for(Job_Element__c objJobEle:l_SelectedJobElementLst){
                codeSet.add(objJobEle.Code__c);
            }
        }
        // added
        List<Product_Work_Code__c> pwcList = [Select p.Work_Code__c,p.Product_Code__c, p.Hours__c From Product_Work_Code__c p where Start_Date__c <= :System.today() and End_Date__c >= :System.today() and Active__c = true and Work_Code__c in :codeSet];
        
        for(Product_Work_code__c wc : pwcList)
            pwcMap.put(wc.Work_Code__c , (wc.Hours__c).intValue());
        // end
        Double dblOrderTotal=0; 
        if (w_JobElementIndividualMap!=null){
            if (l_PostcodeSkillRate!=null){    
                objPurchaseOrder=new PurchaseOrder();
                objPurchaseOrder.dtOrderDt=System.today();
                objPurchaseOrder.sDispDate=System.today().format();
                objPurchaseOrder.sOrderType='Work';
                objPurchaseOrder.sSupplierId=l_SupplierMap.get(sSupplierNum).sSupplierId;
                objPurchaseOrder.sSupplierName=l_SupplierMap.get(sSupplierNum).sSupplierName;
                objPurchaseOrder.blFaxEnabled=l_SupplierMap.get(sSupplierNum).blFaxEnabled;
                objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
                for (String sTemp:w_JobElementIndividualMap.keyset()){
                    blnNoPrice=false;
                    objOrderLineItem=new OrderLineItem();
                    objOrderLineItem.dblUnits=0;
                    dblQty=0;
                    objOrderLineItem.dblQty=0;
                    l_SelectedJobElementLst=w_JobElementIndividualMap.get(sTemp);
                    // Fix for fixed rate units calculation
                    tmpUnits = 0;
                    for(Job_Element__c objJobEle:l_SelectedJobElementLst){
                        objOrderLineItem.sJobElementDescription=objJobEle.Description__c;
                        objOrderLineItem.sStatus='Active';
                        objOrderLineItem.sType=objJobEle.Type__c;
                        objOrderLineItem.sSupplier=l_SupplierMap.get(sSupplierNum).sSupplierId;
                        objOrderLineItem.sSkill=objJobEle.Skill__c;
                        objOrderLineItem.sItemCode=objJobEle.Code__c;
                        dblQty=dblQty+1;
                        
                        objOrderLineItem.dblUnits=objOrderLineItem.dblUnits + objJobEle.Units__c;
                        objOrderLineItem.sSAPNumberCode='';
                        // Fix for fixed rate units calculation 
                        tmpUnits++;
                    }
                    objOrderLineItem.dblQty=dblQty;
                    objOrderLineItem.setSJobElementLst(l_SelectedJobElementLst);
                    Decimal dblTemp=0;
                    System.debug('$$$$$$$$$$$$$$$ :' + objOrderLineItem.sSkill + ' $$$$$$$$$$ : ' + l_PostcodeSkillRate);
                    if (l_PostcodeSkillRate.containsKey(objOrderLineItem.sSkill)){
                        if(l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Preference__c=='Fixed'){
                            System.debug('############ inside fixed ##############');
                            if (l_RateCardItems!=null) {
                                if (l_RateCardItems.containsKey(objOrderLineItem.sItemCode)){
                                    System.debug('############ inside fixed 2 ##############');
                                    objOrderLineItem.dblUnitPrice=l_RateCardItems.get(objOrderLineItem.sItemCode).Cost__c;
                                    objOrderLineItem.sRateType='Fixed';
                                    // added
                                    
                                    System.debug('############ inside fixed 3 #####    '+ pwcMap);
                                    System.debug('############ inside fixed 4 #####    '+ objOrderLineItem.sItemCode);
                                  
                                  // Fix for fixed rate units calculation - comneted below part
                                  
                                  /*  if(pwcMap.get(objOrderLineItem.sItemCode) !=null ){
                                        Integer hrs = pwcMap.get(objOrderLineItem.sItemCode);
                                        if(hrs > 0){
                                            dblTemp= (objOrderLineItem.dblUnitPrice)/hrs;
                                            objOrderLineItem.dblQty = dblTemp;
                                        }
                                    }
                                    objOrderLineItem.dblUnits= dblTemp;
                                    //end :  
                                   */
                                   
                                    objOrderLineItem.dblQty = tmpUnits;
                                    objOrderLineItem.dblUnits = tmpUnits;
                                    dblTemp=objOrderLineItem.dblUnitPrice*tmpUnits;
                                    objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                                    
                                          
                                }   else {
                                    objOrderLineItem.dblUnitPrice=l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Cost__c;
                                    objOrderLineItem.sRateType='Variable';
                                    // We need to ignore work elements where units equal to 0.02
            				   		// These work elements are just indicative for certain tasks 
            				   		// and not to be ordered. 
                                    if(objOrderLineItem.dblUnits > 0.02)
					                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
					                else
					                dblTemp = 0;
                                    objOrderLineItem.dblTotalPrice= dblTemp.setScale(2); 
                                }
                            } else {
                                objOrderLineItem.dblUnitPrice=l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Cost__c;
                                objOrderLineItem.sRateType='Variable';
                                // We need to ignore work elements where units equal to 0.02
            				   	// These work elements are just indicative for certain tasks 
            				   	// and not to be ordered. 
                                if(objOrderLineItem.dblUnits > 0.02)
				                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
				                else
				                dblTemp = 0;
                                objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                               }
                        } else {
                            objOrderLineItem.dblUnitPrice=l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Cost__c;
                            // We need to ignore work elements where units equal to 0.02
            				// These work elements are just indicative for certain tasks 
                            // and not to be ordered. 
                            if(objOrderLineItem.dblUnits > 0.02)
			                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
			                else
			                dblTemp = 0;
                            objOrderLineItem.sRateType='Variable';
                            objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                              }   
                    } else {
                        objNoPriceInformation.setSJobElementIdLst(l_SelectedJobElementLst);
                        Job_Element__c objUnOrderJE=new Job_Element__c();
                        objUnOrderJE.Code__c=sTemp;
                        objUnOrderJE.Description__c=objOrderLineItem.sJobElementDescription;
                        objUnOrderJE.Units__c=objOrderLineItem.dblUnits;
                        objNoPriceInformation.objJobElement=objUnOrderJE;
                        objNoPriceInformation.sErrorText='No Price Information';
                        objNoPriceInformation.sSupplierName=l_SupplierMap.get(sSupplierNum).sSupplierName;
                        w_noPriceInformation.add(objNoPriceInformation);
                        blnNoPrice=true;
                    }
                    if (!blnNoPrice)
                    {
                    orderLineItemLst.add(objOrderLineItem);
                    objPurchaseOrder.orderLineItemLst=orderLineItemLst;
                    dblOrderTotal=dblOrderTotal + objOrderLineItem.dblTotalPrice;
                    objPurchaseOrder.jobElementLst.addall(l_SelectedJobElementLst);
                    blnGenerateOrder=true;
                    }
                }
                
                if (blnGenerateOrder)
                {
                objPurchaseOrder.dblOrderValue=dblOrderTotal;
                purchaseOrderList.add(objPurchaseOrder);}
            }else {
                try {
                    for (String sTemp:w_JobElementIndividualMap.keyset()){
                        objNoPriceInformation=new underOrderedItem();
                        objNoPriceInformation.setSJobElementIdLst(w_JobElementIndividualMap.get(sTemp));
                        Job_Element__c objUnOrderJE=new Job_Element__c();
                        objUnOrderJE.Code__c=sTemp;
                        objUnOrderJE.Description__c=w_JobElementIndividualMap.get(sTemp)[0].Description__c;
                        Double dblUnit=0;
                        for (Job_Element__c objJE1: w_JobElementIndividualMap.get(sTemp)){
                            dblUnit=dblUnit + objJE1.Units__c;
                        }
                        objUnOrderJE.Units__c=dblUnit;
                        objNoPriceInformation.objJobElement=objUnOrderJE;
                        objNoPriceInformation.sErrorText='No Price Information';
                        objNoPriceInformation.sSupplierName=l_SupplierMap.get(sSupplierNum).sSupplierName;
                        w_noPriceInformation.add(objNoPriceInformation);
                    }       
                } catch (Exception ex){
                    System.debug('$$$$$$$$$$$$$$$$$$:' + ex.getMessage());
                }
            }
        }
    }
    
    public void generateItineryWorkOrder(Map<String,Map<String,List<Job_Element__c>>> w_SupplierTotalJobElementMap,
                                    Map<String,Map<String,Post_Code_Skill_Rate__c>> postCodeSkillRateMap, 
                                    Map<String,Map<String,Rate_Card_Items__c>> rateCardItemMap,
                                    String sSupplierNum){
        
        underOrderedItem objNoPriceInformation=new underOrderedItem();
        PurchaseOrder objPurchaseOrder;
        List<OrderLineItem> orderlineLst;
        Double dblQty=0;
        List<Job_Element__c> l_SelectedJobElementLst=new List<Job_Element__c>{};
        List<OrderLineItem> orderLineItemLst=new List<OrderLineItem>{};
        OrderLineItem objOrderLineItem=new OrderLineItem();
        Map<String,List<Job_Element__c>> w_JobElementIndividualMap=new Map<String,List<Job_Element__c>>{};
        Map<String,Post_Code_Skill_Rate__c> l_PostcodeSkillRate=new Map<String,Post_Code_Skill_Rate__c>{};
        Map<String,Rate_Card_Items__c> l_RateCardItems=new Map<String,Rate_Card_Items__c>{};
        w_JobElementIndividualMap=w_SupplierTotalJobElementMap.get(sSupplierNum);
        l_PostcodeSkillRate=postCodeSkillRateMap.get(sSupplierNum);
        l_RateCardItems=rateCardItemMap.get(sSupplierNum);
        Boolean blnNoPrice=false;
        Boolean blnGenerateOrder=false;
        Double dblOrderTotal=0; 
        if (w_JobElementIndividualMap!=null){
            if (l_PostcodeSkillRate!=null){
                objPurchaseOrder=new PurchaseOrder();
                objPurchaseOrder.dtOrderDt=System.today();
                objPurchaseOrder.sDispDate=System.today().format();
                objPurchaseOrder.sOrderType='Itinerary';
                objPurchaseOrder.sSupplierId=il_SupplierMap.get(sSupplierNum).sSupplierId;
                objPurchaseOrder.sSupplierName=il_SupplierMap.get(sSupplierNum).sSupplierName;
                objPurchaseOrder.blFaxEnabled=il_SupplierMap.get(sSupplierNum).blFaxEnabled;
                objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
                for (String sTemp:w_JobElementIndividualMap.keyset()){
                    blnNoPrice=false;
                    objOrderLineItem=new OrderLineItem();
                    objOrderLineItem.dblUnits=0;
                    dblQty=0;
                    objOrderLineItem.dblQty=0;
                    l_SelectedJobElementLst=w_JobElementIndividualMap.get(sTemp);
                    for(Job_Element__c objJobEle:l_SelectedJobElementLst){
                        objOrderLineItem.sJobElementDescription=objJobEle.Description__c;
                        objOrderLineItem.sStatus='Active';
                        objOrderLineItem.sType=objJobEle.Type__c;
                        objOrderLineItem.sSupplier=il_SupplierMap.get(sSupplierNum).sSupplierId;
                        objOrderLineItem.sSkill=objJobEle.Skill__c;
                        objOrderLineItem.sItemCode=objJobEle.Code__c;
                        objOrderLineItem.dblUnits=objOrderLineItem.dblUnits + objJobEle.Units__c;
                        objOrderLineItem.sSAPNumberCode=''; 
                        dblQty=dblQty+1;
                    }
                    objOrderLineItem.dblQty=dblQty;
                    objOrderLineItem.setSJobElementLst(l_SelectedJobElementLst);
                    Decimal dblTemp=0;
                    if (l_PostcodeSkillRate.containsKey(objOrderLineItem.sSkill)){
                        if(l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Preference__c=='Fixed' && l_RateCardItems != null){
                            // Fix for fixed rate units calculation - Starts
                            // Fix for fixed rate units calculation - Ends
                            if (l_RateCardItems.containsKey(objOrderLineItem.sItemCode)){
                                objOrderLineItem.dblUnitPrice=l_RateCardItems.get(objOrderLineItem.sItemCode).Cost__c;
                                objOrderLineItem.sRateType='Fixed';
                                dblTemp=objOrderLineItem.dblUnitPrice*dblQty;
                                objOrderLineItem.dblUnits = dblQty;
                                objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                        }   else {
                                objOrderLineItem.dblUnitPrice=l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Cost__c;
                                objOrderLineItem.sRateType='Variable';
                                // We need to ignore work elements where units equal to 0.02
            				   	// These work elements are just indicative for certain tasks 
            				   	// and not to be ordered. 
                                if(objOrderLineItem.dblUnits > 0.02)
				                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
				                else
				                dblTemp = 0;
                                objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                               }
                        } else {
                            objOrderLineItem.dblUnitPrice=l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Cost__c;
                            // We need to ignore work elements where units equal to 0.02
            				// These work elements are just indicative for certain tasks 
            				// and not to be ordered. 
                            if(objOrderLineItem.dblUnits > 0.02)
			                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
			                else
			                dblTemp = 0;
                            objOrderLineItem.sRateType='Variable';
                            objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                             
                        }   
                    } else {
                        objNoPriceInformation.setSJobElementIdLst(l_SelectedJobElementLst);
                        Job_Element__c objUnOrderJE=new Job_Element__c();
                        objUnOrderJE.Code__c=sTemp;
                        objUnOrderJE.Description__c=objOrderLineItem.sJobElementDescription;
                        objUnOrderJE.Units__c=objOrderLineItem.dblUnits;
                        objNoPriceInformation.objJobElement=objUnOrderJE;
                        objNoPriceInformation.sErrorText='No Price Information';
                        objNoPriceInformation.sSupplierName=il_SupplierMap.get(sSupplierNum).sSupplierName;
                        iw_noPriceInformation.add(objNoPriceInformation);
                        blnNoPrice=true;
    
                    }
                    if (!blnNoPrice){
                        orderLineItemLst.add(objOrderLineItem);
                        objPurchaseOrder.orderLineItemLst=orderLineItemLst;
                        dblOrderTotal=dblOrderTotal + objOrderLineItem.dblTotalPrice;
                        objPurchaseOrder.jobElementLst.addall(l_SelectedJobElementLst);
                        blnGenerateOrder=true;
                    }
                    
                }
                if (blnGenerateOrder){
                    objPurchaseOrder.dblOrderValue=dblOrderTotal;
                    purchaseOrderList.add(objPurchaseOrder);
                }
            }else {
                try {
                    for (String sTemp:w_JobElementIndividualMap.keyset()){
                        objNoPriceInformation=new underOrderedItem();
                        objNoPriceInformation.setSJobElementIdLst(w_JobElementIndividualMap.get(sTemp));
                        Job_Element__c objUnOrderJE=new Job_Element__c();
                        objUnOrderJE.Code__c=sTemp;
                        objUnOrderJE.Description__c=w_JobElementIndividualMap.get(sTemp)[0].Description__c;
                        Double dblUnit=0;
                        for (Job_Element__c objJE1: w_JobElementIndividualMap.get(sTemp)){
                            dblUnit=dblUnit + objJE1.Units__c;
                        }
                        objUnOrderJE.Units__c=dblUnit;
                        objNoPriceInformation.objJobElement=objUnOrderJE;
                        objNoPriceInformation.sErrorText='No Price Information';
                        objNoPriceInformation.sSupplierName=il_SupplierMap.get(sSupplierNum).sSupplierName;
                        iw_noPriceInformation.add(objNoPriceInformation);
                    }       
                } catch (Exception ex){
                    System.debug('$$$$$$$$$$$$$$$$$$:' + ex.getMessage());
                }
            }
        }
    }
    
    public void generateMaterialOrder(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String sSupplierNum,Map<String,Rate_Card_Items__c> m_Rate )
    {
        // Cognizant - CHI Phase III CR-005 implementation... START        
        // Loop over the user defined job elements and match the supplier. If it matches, add the user defined
        // job elements to the map of standard job elements (m_SelectedJobElementMap).
        for (Job_Element__c objJobElementUDP:objJobUDP.Job_Elements1__r)
        {
            String code = objJobElementUDP.Code__c;
            List<Job_Element__c> matchSupJEList = new List<Job_Element__c>();
            if(objJobElementUDP.Current_Supplier_Number__c.equalsIgnoreCase(sSupplierNum))
            {
                matchSupJEList.add(objJobElementUDP);
                m_SelectedJobElementMap.put(code, matchSupJEList);
            }
        }
        // Cognizant - CHI Phase III CR-005 implementation... END               
        PurchaseOrder objPurchaseOrder;
        underOrderedItem objNoPriceInformation=new underOrderedItem();
        List<OrderLineItem> orderlineLst;
        List<Job_Element__c> m_SelectedJobElementLst=new List<Job_Element__c>{};
        List<OrderLineItem> orderLineItemLst=new List<OrderLineItem>{};
        OrderLineItem objOrderLineItem=new OrderLineItem();
        Boolean blnNoPrice=false;
        Boolean blnGenerateOrder=false;
        Double dblOrderTotal=0; 
        
        Decimal dblTemp=0;
        objPurchaseOrder=new PurchaseOrder();
        objPurchaseOrder.dtOrderDt=System.today();
        objPurchaseOrder.sDispDate=System.today().format();
        objPurchaseOrder.sOrderType='Material';
        objPurchaseOrder.sSupplierId=m_SupplierMap.get(sSupplierNum).sSupplierId;
        objPurchaseOrder.sSupplierName=m_SupplierMap.get(sSupplierNum).sSupplierName;
        objPurchaseOrder.blFaxEnabled=m_SupplierMap.get(sSupplierNum).blFaxEnabled;
        objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
        
     // Defect fix where it generates the duplicate orders when no price materials enter this method for creating fresh order.
        boolean isPriceFoundForOne = false;
        
        for (String sTemp:m_SelectedJobElementMap.keySet()){
            Double dblUnitPrice = 0;
            objNoPriceInformation=new underOrderedItem();
            objOrderLineItem=new OrderLineItem();
            objOrderLineItem.dblUnits=0;
            m_SelectedJobElementLst=m_SelectedJobElementMap.get(sTemp);
            for(Job_Element__c objJobEle:m_SelectedJobElementLst){
                objOrderLineItem.sJobElementDescription=objJobEle.Description__c;
                objOrderLineItem.sStatus='Active';
                objOrderLineItem.sType=objJobEle.Type__c;
                objOrderLineItem.sSupplier=m_SupplierMap.get(sSupplierNum).sSupplierId;
                objOrderLineItem.sSkill=objJobEle.Skill__c;
                objOrderLineItem.sItemCode=objJobEle.Code__c;
                
                dblUnitPrice = objJobEle.Merchant_Price__c; 
                
                objOrderLineItem.dblUnits=objOrderLineItem.dblUnits + objJobEle.Units__c;
                objOrderLineItem.sSAPNumberCode='';         
            }// End For
            
            objOrderLineItem.setSJobElementLst(m_SelectedJobElementLst);
            blnNoPrice=false;            
            if (m_Rate.containsKey(sTemp)){
                objOrderLineItem.dblUnitPrice=m_Rate.get(sTemp).Cost__c;
                decimal rebate = m_Rate.get(sTemp).Material__r.Rebate__c!= null?m_Rate.get(sTemp).Material__r.Rebate__c: 0.00;
                objOrderLineItem.Rebate = rebate*objOrderLineItem.dblUnits;
                isPriceFoundForOne = true;
            }
            // Cognizant - CHI Phase III CR-005 implementation... START
            // Added an else if block to set the unit price of orderlineitem with merchant price of user defined job element. 
            else if(um_JobElementMap.containsKey(sTemp))
            {
                objOrderLineItem.dblUnitPrice = dblUnitPrice;
                objOrderLineItem.isUserDefinedOrderLine = true;
            } 
            // Cognizant - CHI Phase III CR-005 implementation... END
            else 
            {
                blnNoPrice=true;
            }
            
            if (blnNoPrice==true) {
                objNoPriceInformation.setSJobElementIdLst(m_SelectedJobElementLst);
                Job_Element__c objUnOrderJE=new Job_Element__c();
                objUnOrderJE.Code__c=sTemp;
                objUnOrderJE.Description__c=objOrderLineItem.sJobElementDescription;
                objUnOrderJE.Units__c=objOrderLineItem.dblUnits;
                objNoPriceInformation.objJobElement=objUnOrderJE;
                objNoPriceInformation.sErrorText='No Price Information';
                objNoPriceInformation.sSupplierName=m_SupplierMap.get(sSupplierNum).sSupplierName;
                m_noPriceInformation.add(objNoPriceInformation);
            }else {
            	// We need to ignore work elements where units equal to 0.02
            	// These work elements are just indicative for certain tasks 
            	// and not to be ordered. 
                if(objOrderLineItem.dblUnits > 0.02)
                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
                else
                dblTemp = 0;
                objOrderLineItem.sRateType='Variable';
                objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);                  
                orderLineItemLst.add(objOrderLineItem);
                objPurchaseOrder.orderLineItemLst=orderLineItemLst;
                dblOrderTotal=dblOrderTotal + objOrderLineItem.dblTotalPrice;
                objPurchaseOrder.jobElementLst.addall(m_SelectedJobElementLst);
                blnGenerateOrder=true; 
               }
        }
        if (blnGenerateOrder && isPriceFoundForOne){
            objPurchaseOrder.dblOrderValue=dblOrderTotal;
            purchaseOrderList.add(objPurchaseOrder);            
        }        
    }//End if
    
    // Cognizant - CHI Phase III CR-005 implementation... START
    // This method creates new Purchase order and order line item for user defined job elements. 
    public PurchaseOrder generateMaterialOrderForNewSupp(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String suppNum)
    {
        Supplier__c supp = [Select Id, Supplier_Num__c, Name, Fax_Setup__c From Supplier__c s where Supplier_Num__c =:suppNum];
        
        PurchaseOrder objPurchaseOrder;
        List<OrderLineItem> orderlineLst;
        List<Job_Element__c> orderLineItemJbList;
        List<Job_Element__c> m_SelectedJobElementLst=new List<Job_Element__c>{};
        List<OrderLineItem> orderLineItemLst=new List<OrderLineItem>{};
        OrderLineItem objOrderLineItem=new OrderLineItem();
        
        Double dblOrderTotal=0; 
        
        Decimal dblTemp=0;
        objPurchaseOrder=new PurchaseOrder();
        objPurchaseOrder.dtOrderDt=System.today();
        objPurchaseOrder.sDispDate=System.today().format();
        objPurchaseOrder.sOrderType='Material';
        objPurchaseOrder.sSupplierId=supp.Id;
        objPurchaseOrder.sSupplierName=supp.Name;
        objPurchaseOrder.blFaxEnabled=supp.Fax_Setup__c;
        objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
        for (String sTemp:m_SelectedJobElementMap.keySet()){
            
            m_SelectedJobElementLst=m_SelectedJobElementMap.get(sTemp);
            
            for(Job_Element__c objJobEle:m_SelectedJobElementLst){
                orderLineItemJbList = new List<Job_Element__c>();
                orderLineItemJbList.add(objJobEle);
                objOrderLineItem=new OrderLineItem();
                objOrderLineItem.sJobElementDescription=objJobEle.Description__c;
                objOrderLineItem.sStatus='Active';
                objOrderLineItem.sType=objJobEle.Type__c;
                objOrderLineItem.sSupplier=supp.Id;
                objOrderLineItem.sSkill=objJobEle.Skill__c;
                objOrderLineItem.sItemCode=objJobEle.Code__c;
                objOrderLineItem.dblUnits = objJobEle.Units__c;
                objOrderLineItem.sSAPNumberCode='';         
                objOrderLineItem.setSJobElementLst(orderLineItemJbList);                
                objOrderLineItem.dblUnitPrice = objJobEle.Merchant_Price__c;
                objOrderLineItem.sRateType='Variable';
                // We need to ignore work elements where units equal to 0.02
            	// These work elements are just indicative for certain tasks 
            	// and not to be ordered. 
                if(objOrderLineItem.dblUnits > 0.02)
                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
                else
                dblTemp = 0;  
                objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                objOrderLineItem.isUserDefinedOrderLine = true;             
                orderLineItemLst.add(objOrderLineItem);
                dblOrderTotal=dblOrderTotal + objOrderLineItem.dblTotalPrice;     
               }
            objPurchaseOrder.orderLineItemLst=orderLineItemLst;
            objPurchaseOrder.jobElementLst.addall(m_SelectedJobElementLst);
            objPurchaseOrder.dblOrderValue=dblOrderTotal;
            
        }
        return objPurchaseOrder;
    }
    // Cognizant - CHI Phase III CR-005 implementation... END
    
    public void generateItineryMaterialOrder(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String sSupplierNum,Map<String,Rate_Card_Items__c> m_Rate ){
        underOrderedItem objNoPriceInformation=new underOrderedItem();
        PurchaseOrder objPurchaseOrder;
        List<OrderLineItem> orderlineLst;
        List<Job_Element__c> m_SelectedJobElementLst=new List<Job_Element__c>{};
        List<OrderLineItem> orderLineItemLst=new List<OrderLineItem>{};
        OrderLineItem objOrderLineItem=new OrderLineItem();
        Boolean blnNoPrice=false;
        Boolean blnGenerateOrder=false;
        Double dblOrderTotal=0; 
        Decimal dblTemp=0;
        objPurchaseOrder=new PurchaseOrder();
        objPurchaseOrder.dtOrderDt=System.today();
        objPurchaseOrder.sDispDate=System.today().format();
        objPurchaseOrder.sOrderType='Itinerary';
        objPurchaseOrder.sSupplierId=im_SupplierMap.get(sSupplierNum).sSupplierId;
        objPurchaseOrder.sSupplierName=im_SupplierMap.get(sSupplierNum).sSupplierName;
        objPurchaseOrder.blFaxEnabled=im_SupplierMap.get(sSupplierNum).blFaxEnabled;
        objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
        for (String sTemp:m_SelectedJobElementMap.keySet()){
            objNoPriceInformation=new underOrderedItem();
            objOrderLineItem=new OrderLineItem();
            objOrderLineItem.dblUnits=0;
            m_SelectedJobElementLst=m_SelectedJobElementMap.get(sTemp);
            for(Job_Element__c objJobEle:m_SelectedJobElementLst){
                objOrderLineItem.sJobElementDescription=objJobEle.Description__c;
                objOrderLineItem.sStatus='Active';
                objOrderLineItem.sType=objJobEle.Type__c;
                objOrderLineItem.sSupplier=im_SupplierMap.get(sSupplierNum).sSupplierId;
                objOrderLineItem.sSkill=objJobEle.Skill__c;
                objOrderLineItem.sItemCode=objJobEle.Code__c;
                
                objOrderLineItem.dblUnits=objOrderLineItem.dblUnits + objJobEle.Units__c;
                objOrderLineItem.sSAPNumberCode='';         
            }// End For
            
            objOrderLineItem.setSJobElementLst(m_SelectedJobElementLst);
            blnNoPrice=false;
            if (m_Rate.containsKey(sTemp)){
                objOrderLineItem.dblUnitPrice=m_Rate.get(sTemp).Cost__c;
                decimal rebate = m_Rate.get(sTemp).Material__r.Rebate__c!= null?m_Rate.get(sTemp).Material__r.Rebate__c: 0.00;
                objOrderLineItem.Rebate = rebate*objOrderLineItem.dblUnits;
            } else {
                blnNoPrice=true;
            }
            if (blnNoPrice==true) {
                objNoPriceInformation.setSJobElementIdLst(m_SelectedJobElementLst);
                Job_Element__c objUnOrderJE=new Job_Element__c();
                objUnOrderJE.Code__c=sTemp;
                objUnOrderJE.Description__c=objOrderLineItem.sJobElementDescription;
                objUnOrderJE.Units__c=objOrderLineItem.dblUnits;
                objNoPriceInformation.objJobElement=objUnOrderJE;
                objNoPriceInformation.sErrorText='No Price Information';
                objNoPriceInformation.sSupplierName=im_SupplierMap.get(sSupplierNum).sSupplierName;
                im_noPriceInformation.add(objNoPriceInformation);
            }else {
            	// We need to ignore work elements where units equal to 0.02
            	// These work elements are just indicative for certain tasks 
            	// and not to be ordered. 
            	if(objOrderLineItem.dblUnits > 0.02)
                dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
                else
                dblTemp = 0;
                objOrderLineItem.sRateType='Variable';
                objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);  
                orderLineItemLst.add(objOrderLineItem);
                objPurchaseOrder.orderLineItemLst=orderLineItemLst;
                dblOrderTotal=dblOrderTotal + objOrderLineItem.dblTotalPrice;
                objPurchaseOrder.jobElementLst.addall(m_SelectedJobElementLst);
                blnGenerateOrder=true;
                }
        }// End If
        if (blnGenerateOrder){
            objPurchaseOrder.dblOrderValue=dblOrderTotal;
            purchaseOrderList.add(objPurchaseOrder);
        }
    }//End if

    /*
        Fetches the supplier Information from the Job Element Record for the Work Type Job Elements and
        from the Post Code for the material supplier. 
        In case of Tiertiary supplier it fetches record from the Rate Card item where suppliers have national rate card
    */ 
    private void fetchSupplier(String sType){
        SupplierDetails objSupplier=new SupplierDetails();
        if (sType=='Work'){
            for (Supplier__c objSupp:[Select Supplier_Num__c,Fax_Setup__c, Fax__c,Name,Phone1__c, Id,Van_Stock__c,Van_Stock_Value__c  From Supplier__c 
                                        Where Supplier_Num__c In:sSupplierNumSet ]){
                objSupplier=new SupplierDetails();
                objSupplier.sSupplierId=objSupp.Id;
                objSupplier.blFaxEnabled=objSupp.Fax_Setup__c;
                //objSupplier.sSupplierId=objSupplier.sSupplierId.substring(0,15);
                objSupplier.sSupplierName=objSupp.Name;
                objSupplier.sSupplierNum=objSupp.Supplier_Num__c;
                objSupplier.sSupplierPhone=objSupp.Fax__c;
                objSupplier.blVanstock=objSupp.Van_Stock__c;
                objSupplier.vanStockValue = objSupp.Van_Stock_Value__c;
                //Vanstock change begin : 18/05/11               
                if (objSupp.Van_Stock__c==true){
                    if(objSupp.Van_Stock_Value__c>0)
                    {
                        blVanStock=objSupp.Van_Stock__c;
                       
                    }//End if
                }
                objSupplier.vanStockValue = objSupp.Van_Stock_Value__c;  
                // vanstock change end   
                objSupplier.intSupplierPref=0;
                l_SupplierMap.put(objSupp.Supplier_Num__c,objSupplier);    
            }//End Query For  
        } else if (sType=='Work-Itinery'){
            for (Supplier__c objSupp:[Select Supplier_Num__c,Fax_Setup__c, Name,Fax__c,Phone1__c, Id,Van_Stock__c,Van_Stock_Value__c  From Supplier__c 
                                        Where Supplier_Num__c In:isSupplierNumSet ]){
                objSupplier=new SupplierDetails();
                objSupplier.sSupplierId=objSupp.Id;
                objSupplier.blFaxEnabled=objSupp.Fax_Setup__c;
                //objSupplier.sSupplierId=objSupplier.sSupplierId.substring(0,15);
                objSupplier.sSupplierName=objSupp.Name;
                objSupplier.sSupplierNum=objSupp.Supplier_Num__c;
                objSupplier.sSupplierPhone=objSupp.Fax__c;
                objSupplier.blVanstock=objSupp.Van_Stock__c;
                //vanstock change start
                objSupplier.vanStockValue = objSupp.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=0;
                il_SupplierMap.put(objSupp.Supplier_Num__c,objSupplier);    
            }//End Query For   
        } else if (sType=='Material-Itinery') {
            if(objPostCodeSector.P5_Primary_Supplier__c != null){
                objSupplier.sSupplierId=objPostCodeSector.P5_Primary_Supplier__r.Id;
                objSupplier.sSupplierName=objPostCodeSector.P5_Primary_Supplier__r.Name;
                objSupplier.blFaxEnabled=objPostCodeSector.P5_Primary_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objPostCodeSector.P5_Primary_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Primary_Supplier__r.Fax__c;
                objSupplier.blVanstock=objPostCodeSector.P5_Primary_Supplier__r.Van_Stock__c;
                //vanstock change start
                objSupplier.vanStockValue = objPostCodeSector.P5_Primary_Supplier__r.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=1;
                //sPrimarySuppNum=objPostCodeSector.P5_Primary_Supplier__r.Supplier_Num__c;
                im_SupplierMap.put(objPostCodeSector.P5_Primary_Supplier__r.Supplier_Num__c,objSupplier);
            }//End if
            if(objPostCodeSector.P5_Secondary_Supplier__c != null){
                objSupplier=new SupplierDetails();
                objSupplier.sSupplierId=objPostCodeSector.P5_Secondary_Supplier__r.Id;
                objSupplier.sSupplierName=objPostCodeSector.P5_Secondary_Supplier__r.Name;
                objSupplier.blFaxEnabled=objPostCodeSector.P5_Secondary_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Secondary_Supplier__r.Fax__c;
                objSupplier.blVanstock=objPostCodeSector.P5_Secondary_Supplier__r.Van_Stock__c; 
                //vanstock change start
                objSupplier.vanStockValue = objPostCodeSector.P5_Primary_Supplier__r.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=2;  
                //sSecondarySuppNum=objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c;           
                im_SupplierMap.put(objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c,objSupplier);
            }//End if
            for(Rate_Card__c objRateCard :[Select P5_Supplier__r.Fax_Setup__c, P5_Supplier__r.Van_Stock__c, P5_Supplier__r.Fax__c, 
                                            P5_Supplier__r.Supplier_Num__c, P5_Supplier__r.Name, P5_Supplier__r.Id, 
                                            P5_Supplier__c,P5_Supplier__r.Van_Stock_Value__c  From Rate_Card__c Where Rate_Card_Type__c=0 
                                            And P5_Supplier__r.Type__c='Product' and P5_Supplier__r.Status_code__c='A']){
                objSupplier=new SupplierDetails();      
                objSupplier.sSupplierId=objRateCard.P5_Supplier__r.Id;
                
                objSupplier.sSupplierName=objRateCard.P5_Supplier__r.Name;
                objSupplier.blFaxEnabled=objRateCard.P5_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objRateCard.P5_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objRateCard.P5_Supplier__r.Fax__c;
                objSupplier.blVanstock=objRateCard.P5_Supplier__r.Van_Stock__c;
                //vanstock change start
                objSupplier.vanStockValue = objRateCard.P5_Supplier__r.Van_Stock_Value__c;
                // vanstock change end 
                objSupplier.intSupplierPref=3;             
                im_SupplierMap.put(objRateCard.P5_Supplier__r.Supplier_Num__c,objSupplier);
            }//End Query For 
        } else if (sType=='Material') {
            if(objPostCodeSector.P5_Primary_Supplier__c != null){
                objSupplier.sSupplierId=objPostCodeSector.P5_Primary_Supplier__r.Id;
                objSupplier.sSupplierName=objPostCodeSector.P5_Primary_Supplier__r.Name;
                objSupplier.blFaxEnabled=objPostCodeSector.P5_Primary_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objPostCodeSector.P5_Primary_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Primary_Supplier__r.Fax__c;
                objSupplier.blVanstock=objPostCodeSector.P5_Primary_Supplier__r.Van_Stock__c;
                //vanstock change start
                objSupplier.vanStockValue = objPostCodeSector.P5_Primary_Supplier__r.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=1;
                sPrimarySuppNum=objPostCodeSector.P5_Primary_Supplier__r.Supplier_Num__c;
                m_SupplierMap.put(objPostCodeSector.P5_Primary_Supplier__r.Supplier_Num__c,objSupplier);
            }//End if
            if(objPostCodeSector.P5_Secondary_Supplier__c != null){
                objSupplier=new SupplierDetails();
                objSupplier.sSupplierId=objPostCodeSector.P5_Secondary_Supplier__r.Id;
                objSupplier.sSupplierName=objPostCodeSector.P5_Secondary_Supplier__r.Name;
                objSupplier.blFaxEnabled=objPostCodeSector.P5_Secondary_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Secondary_Supplier__r.Fax__c;
                objSupplier.blVanstock=objPostCodeSector.P5_Secondary_Supplier__r.Van_Stock__c; 
                 //vanstock change start
                objSupplier.vanStockValue = objPostCodeSector.P5_Primary_Supplier__r.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=2;  
                sSecondarySuppNum=objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c;           
                m_SupplierMap.put(objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c,objSupplier);
            }//End if
            for(Rate_Card__c objRateCard :[Select P5_Supplier__r.Fax_Setup__c, P5_Supplier__r.Van_Stock__c, P5_Supplier__r.Fax__c, 
                                            P5_Supplier__r.Supplier_Num__c, P5_Supplier__r.Name, P5_Supplier__r.Id, 
                                            P5_Supplier__c,P5_Supplier__r.Van_Stock_Value__c From Rate_Card__c Where Rate_Card_Type__c=0 
                                            And P5_Supplier__r.Type__c='Product' and P5_Supplier__r.Status_code__c='A']){
                objSupplier=new SupplierDetails();      
                objSupplier.sSupplierId=objRateCard.P5_Supplier__r.Id;
                
                objSupplier.sSupplierName=objRateCard.P5_Supplier__r.Name;
                objSupplier.blFaxEnabled=objRateCard.P5_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objRateCard.P5_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objRateCard.P5_Supplier__r.Fax__c;
                objSupplier.blVanstock=objRateCard.P5_Supplier__r.Van_Stock__c; 
                 //vanstock change start
                objSupplier.vanStockValue = objRateCard.P5_Supplier__r.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=3;             
                m_SupplierMap.put(objRateCard.P5_Supplier__r.Supplier_Num__c,objSupplier);
            }//End Query For
                
        }//End if
    }//End of Method
    private void fetchActiveSAPNumber(){
        Integer iCount=purchaseOrderList.size();
        sapNumberLst=new List<SAP_Number__c>{}; 
        sapNumberLst_Used=new List<SAP_Number__c>{};  
        sapNumberLst=[Select Id,SAP_Number__c,SAP_Num_Ord__c, Active__c From SAP_Number__c 
        Where Active__c=true order by SAP_Number__c Limit 2000];
        Integer iSAPCount=0;
       
       // Defect fix for duplicate SAP numbers - starts
        
          // Pick one at random
             Integer count = 0;
             Integer size = sapNumberLst.size();
                
          // Use a set to check that this SAP number hasn't been tried already.
          
             Set<Integer> alreadyTried = new Set<Integer>();
             
                do {
                    
                    // Get a random number
                    Integer rdm = (Math.random() * 2000).intValue();
                        
                    if(rdm >= size)
                        rdm = size-1;
                        
                    // If we've tried this SAP number already, move onto the next one.
                    if(alreadyTried.contains(rdm))
                        continue;
                        
                    sapNumberLst_Used.add(sapNumberLst[rdm]);  
                    alreadyTried.add(rdm);
                    count++;
                    
                } while(count < iCount);
                
         // Defect fix for duplicate SAP numbers - ends
         
        if(purchaseOrderList.size() > 0 && sapNumberLst_Used.size() >0){
            for (PurchaseOrder objPurchaseOrder:purchaseOrderList) {
                System.debug('$$$$$$$$$$$$$$$$$$$$$$$$'+objPurchaseOrder.sSAPNumber);
                objPurchaseOrder.sSAPNumber=String.valueOf(sapNumberLst_Used[iSAPCount].SAP_Number__c);
                for (OrderLineItem objOrderLineItem : objPurchaseOrder.orderLineItemLst){
                    objOrderLineItem.sSAPNumberCode=objPurchaseOrder.sSAPNumber+objOrderLineItem.sItemCode;     
                }        
                iSAPCount++;
            }
            for (SAP_Number__c objSAPNumber: sapNumberLst_Used){
                objSAPNumber.Active__c=false;
            }
            update sapNumberLst_Used;
        }
    }
    
    public PageReference confirmOrder(){
        PurchaseOrderAmendmentHelper poH = new PurchaseOrderAmendmentHelper();
        if(poH.checkLock(objJob))
        {
             Job__c Job = [select Order_Locking_User__r.Name from Job__c where Id = :objJob.Id];
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order cannot be generated. As the orders are being Processed by '+Job.Order_Locking_User__r.Name);
             ApexPages.addMessage(errMsg);
             blConfirm=false;
             blError = true;
             return null;
        }
        try {
            m_noPriceInformation=new List<underOrderedItem>{};
            im_noPriceInformation=new List<underOrderedItem>{};
            purchaseOrderIntermList=new List<PurchaseOrder>{};
            underOrderedItem objNoPriceInformation=new underOrderedItem();
            System.debug('@--  step 1 --@'+purchaseOrderList);
            purchaseOrderIntermList.addAll(purchaseOrderList);
            Map<String,Map<String,List<Job_Element__c>>> m_SelectedSupplierJobElementMap=new Map<String,Map<String,List<Job_Element__c>>>{};
            List<Job_Element__c> objJEUnattended;
            
            
            Map<String,List<Job_Element__c>> m_SelectedJobElementMap =new Map<String,List<Job_Element__c>>{};
            if (m_UnOrderedItem!=null) {
                for (underOrderedItem unAttendedItem:m_UnOrderedItem){
                    if (unAttendedItem.sSupplierId!=null){
                        m_SelectedJobElementMap =new Map<String,List<Job_Element__c>>{};
                        objJEUnattended=new List<Job_Element__c>{};
                        if (!m_SelectedSupplierJobElementMap.containskey(unAttendedItem.sSupplierId)){
                            m_SelectedJobElementMap.put(unAttendedItem.objJobElement.Code__c,unAttendedItem.getSJobElementIdLst());
                        } else {
                            m_SelectedJobElementMap=m_SelectedSupplierJobElementMap.get(unAttendedItem.sSupplierId);
                            if (!m_SelectedJobElementMap.containsKey(unAttendedItem.objJobElement.Code__c)){
                                m_SelectedJobElementMap.put(unAttendedItem.objJobElement.Code__c,unAttendedItem.getSJobElementIdLst()); 
                            }else {
                                objJEUnattended=m_SelectedJobElementMap.get(unAttendedItem.objJobElement.Code__c);
                                objJEUnattended.addall(unAttendedItem.getSJobElementIdLst());
                                m_SelectedJobElementMap.put(unAttendedItem.objJobElement.Code__c,objJEUnattended);  
                            }
                        }
                        m_SelectedSupplierJobElementMap.put(unAttendedItem.sSupplierId,m_SelectedJobElementMap);
                    }
                }
                if (m_SelectedSupplierJobElementMap!=null) {
                    for (String sSTemp:m_SelectedSupplierJobElementMap.keySet()){
                        if (m_RateCard.containsKey(sSTemp)) {
                            generateMaterialOrder(m_SelectedSupplierJobElementMap.get(sSTemp), sSTemp, m_RateCard.get(sSTemp)); 
                        } else{
                            if (m_SelectedSupplierJobElementMap.get(sSTemp)!=null){
                                for(String sJECode:m_SelectedSupplierJobElementMap.get(sSTemp).keySet()){
                                    objNoPriceInformation=new underOrderedItem();
                                    objNoPriceInformation.setSJobElementIdLst(m_SelectedSupplierJobElementMap.get(sSTemp).get(sJECode));
                                    Job_Element__c objUnOrderJE=new Job_Element__c();
                                    objUnOrderJE.Code__c=sJECode;
                                    objUnOrderJE.Description__c=m_SelectedSupplierJobElementMap.get(sSTemp).get(sJECode)[0].Description__c;
                                    Double dblUnOrderedQty=0;
                                    for (Job_Element__c objJE12: m_SelectedSupplierJobElementMap.get(sSTemp).get(sJECode)){
                                        dblUnOrderedQty=dblUnOrderedQty + objJE12.Units__c;        
                                    }
                                    objUnOrderJE.Units__c=dblUnOrderedQty;
                                    objNoPriceInformation.objJobElement=objUnOrderJE;
                                    objNoPriceInformation.sErrorText='No Price Information';
                                    objNoPriceInformation.sSupplierName=m_SupplierMap.get(sSTemp).sSupplierName;
                                    m_noPriceInformation.add(objNoPriceInformation);
                                }
                            }
                        }
                    }
                }
            }
            
            Map<String,Map<String,List<Job_Element__c>>> im_SelectedSupplierJobElementMap=new Map<String,Map<String,List<Job_Element__c>>>{};
            List<Job_Element__c> objiJEUnattended;
            Map<String,List<Job_Element__c>> im_SelectedJobElementMap =new Map<String,List<Job_Element__c>>{};
            if (im_UnOrderedItem!=null) {
                for (underOrderedItem uniAttendedItem:im_UnOrderedItem){
                    if (uniAttendedItem.sSupplierId!=null){
                        im_SelectedJobElementMap =new Map<String,List<Job_Element__c>>{};
                        objiJEUnattended=new List<Job_Element__c>{};
                        if (!im_SelectedSupplierJobElementMap.containskey(uniAttendedItem.sSupplierId)){
                            im_SelectedJobElementMap.put(uniAttendedItem.objJobElement.Code__c,uniAttendedItem.getSJobElementIdLst());
                        } else {
                            im_SelectedJobElementMap=im_SelectedSupplierJobElementMap.get(uniAttendedItem.sSupplierId);
                            if (!im_SelectedJobElementMap.containsKey(uniAttendedItem.objJobElement.Code__c)){
                                im_SelectedJobElementMap.put(uniAttendedItem.objJobElement.Code__c,uniAttendedItem.getSJobElementIdLst()); 
                            }else {
                                objiJEUnattended=im_SelectedJobElementMap.get(uniAttendedItem.objJobElement.Code__c);
                                objiJEUnattended.addall(uniAttendedItem.getSJobElementIdLst());
                                im_SelectedJobElementMap.put(uniAttendedItem.objJobElement.Code__c,objiJEUnattended);  
                            }
                        }
                        im_SelectedSupplierJobElementMap.put(uniAttendedItem.sSupplierId,im_SelectedJobElementMap);
                    }
                }
                if (im_SelectedSupplierJobElementMap!=null) {
                    for (String sSTemp:im_SelectedSupplierJobElementMap.keySet()){
                        if (im_RateCard.containsKey(sSTemp)) {
                            generateItineryMaterialOrder(im_SelectedSupplierJobElementMap.get(sSTemp), sSTemp, im_RateCard.get(sSTemp)); 
                        } else {
                            if (im_SelectedSupplierJobElementMap.get(sSTemp)!=null){
                                for(String sJECode:im_SelectedSupplierJobElementMap.get(sSTemp).keySet()){
                                    objNoPriceInformation=new underOrderedItem();
                                    objNoPriceInformation.setSJobElementIdLst(m_SelectedSupplierJobElementMap.get(sSTemp).get(sJECode));
                                    Job_Element__c objUnOrderJE=new Job_Element__c();
                                    objUnOrderJE.Code__c=sJECode;
                                    objUnOrderJE.Description__c=im_SelectedSupplierJobElementMap.get(sSTemp).get(sJECode)[0].Description__c;
                                    Double dblUnOrderedQty=0;
                                    for (Job_Element__c objJE12: im_SelectedSupplierJobElementMap.get(sSTemp).get(sJECode)){
                                        dblUnOrderedQty=dblUnOrderedQty + objJE12.Units__c;        
                                    }
                                    objUnOrderJE.Units__c=dblUnOrderedQty;
                                    objNoPriceInformation.objJobElement=objUnOrderJE;
                                    objNoPriceInformation.sErrorText='No Price Information';
                                    objNoPriceInformation.sSupplierName=im_SupplierMap.get(sSTemp).sSupplierName;
                                    im_noPriceInformation.add(objNoPriceInformation);
                                }
                            }   
                        }
                    }
                }
            }
            fetchActiveSAPNumber();
            blConfirm=true;
            
        } catch(Exception ex){
            System.debug(ex.getMessage());
        }
        return null;
    }
    
    public PageReference back(){
        blConfirm=false;
        purchaseOrderList=new List<PurchaseOrder>{};
        purchaseOrderList.addAll(purchaseOrderIntermList);
        for (SAP_Number__c objSAPNumber: sapNumberLst_Used){
                objSAPNumber.Active__c=true;
        }
        update sapNumberLst_Used;
        return null;
    }
    public PageReference saveOrder(){
        PurchaseOrderAmendmentHelper poH = new PurchaseOrderAmendmentHelper();
        if(poH.checkLock(objJob))
        {
            Job__c Job = [select Order_Locking_User__r.Name from Job__c where Id = :objJob.Id];
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order cannot be generated. As the orders are being Processed by '+Job.Order_Locking_User__r.Name);
             ApexPages.addMessage(errMsg);
             blConfirm=false;
             blError = true;
             return null;
        }
        Savepoint sp = Database.setSavepoint();
        try {
            Map<String,String> supplierMap=new Map<String,String>{};
            for (String sStringTemp:m_SupplierMap.keySet()){
                supplierMap.put(m_SupplierMap.get(sStringTemp).sSupplierId,m_SupplierMap.get(sStringTemp).sSupplierNum);    
            }
            for (String sStringTemp:l_SupplierMap.keySet()){
                supplierMap.put(l_SupplierMap.get(sStringTemp).sSupplierId,l_SupplierMap.get(sStringTemp).sSupplierNum);    
            }
            for (String sStringTemp:im_SupplierMap.keySet()){
                supplierMap.put(im_SupplierMap.get(sStringTemp).sSupplierId,im_SupplierMap.get(sStringTemp).sSupplierNum);    
            }
            
            for (String sStringTemp:il_SupplierMap.keySet()){
                supplierMap.put(il_SupplierMap.get(sStringTemp).sSupplierId,il_SupplierMap.get(sStringTemp).sSupplierNum);    
            }
            
            List<String> sSupplierNumLst=supplierMap.values();
            Map<String,String> branchMap=new Map<String,String>{};
            
            //String sPostCodeId=objPostCodeSector.Id;
            //String sRegionId=objJob.District__r.Region__c;
            //selectRateForElements objRateCard=new selectRateForElements();
            
            branchMap=objRateCard.findBranchNum(sSupplierNumLst, sRegionId, sPostCodeId);
            
            List<order__c> OrderLst=new List<order__c>{};
            order__c objOrder;
            // User defined ASP Change.
            // Populate supplier branch number
            String udp_branch_computed = 'No';
            for (PurchaseOrder objPurchaseOrder : purchaseOrderList) {
                System.debug('Test SAP PO ==='+objPurchaseOrder);
                if(objPurchaseOrder.sSupplierId != null && (objPurchaseOrder.sSupplierId).length() > 10){
                    objOrder=new order__c();
                    objOrder.Job__c=objJob.Id;
                    objOrder.Order_Date__c=objPurchaseOrder.dtOrderDt;
                    objOrder.Order_Value__c=objPurchaseOrder.dblOrderValue;
                    objOrder.SAP_Number__c=objPurchaseOrder.sSAPNumber;
                    objOrder.Supplier_Fax_number__c='01784874219';
                    objOrder.Supplier__c=objPurchaseOrder.sSupplierId;
                    objOrder.Type__c=objPurchaseOrder.sOrderType;   
                    // Cognizant - CHI Phase III CR-005 implementation... START
                    if(objPurchaseOrder.isUserDefinedPO!=null){
                        if(objPurchaseOrder.isUserDefinedPO==true){
                          if(udp_branch_computed == 'No'){
                            PurchaseOrderAmendmentHelper p = new PurchaseOrderAmendmentHelper();
                            udp_SupplierBranchMAP = p.getSupplierBranchMap(udp_AllMaterialSuppliers,sRegionId,sPostCodeId);
                            udp_branch_computed = 'Yes';
                        }
                        if(udp_SupplierBranchMAP.containsKey(udp_SuppIdNumMap.get(objPurchaseOrder.sSupplierId))){
                        objOrder.SupplierBranchNum__c=udp_SupplierBranchMAP.get(udp_SuppIdNumMap.get(objPurchaseOrder.sSupplierId));}
                        else{
                        objOrder.SupplierBranchNum__c = udp_SuppIdNumMap.get(objPurchaseOrder.sSupplierId);}
                        objOrder.Status__c='Active';
                        OrderLst.add(objOrder);
                        continue;
                      }
                    }
                    // Cognizant - CHI Phase III CR-005 implementation... END
                    objOrder.SupplierBranchNum__c=supplierMap.get(objPurchaseOrder.sSupplierId);
                    if (branchMap.containsKey(objOrder.SupplierBranchNum__c)) {
                        objOrder.SupplierBranchNum__c=branchMap.get(objOrder.SupplierBranchNum__c);
                    } else {
                        objOrder.SupplierBranchNum__c=supplierMap.get(objPurchaseOrder.sSupplierId);
                    }
                    objOrder.Status__c='Active';
                    OrderLst.add(objOrder);
                }
            }
            system.debug('list of orders'+OrderLst);            
            OrderLst =  new list<order__c>(new set<order__c>(OrderLst));
            insert OrderLst;
            
            List<Order_Line_Item__c> orderLineItemLst=new List<Order_Line_Item__c>{};
            List<Job_Element__c> jobElementLst=new List<Job_Element__c>{};
            //Job_Element__c objJobElement=new Job_Element__c();
            Order_Line_Item__c objOrderLineItemActual;
            for (order__c objOrderFinal : OrderLst) {
                for (PurchaseOrder objPurchaseOrder : purchaseOrderList){
                    if (objPurchaseOrder.sSAPNumber==objOrderFinal.SAP_Number__c){
                        for (OrderLineItem objOrderLineItem:objPurchaseOrder.orderLineItemLst){
                            objOrderLineItemActual=new Order_Line_Item__c();
                            //  Defect fix for EDI interface to identify this as user defined order line item - Starts
                            if(objOrderLineItem.isUserDefinedOrderLine){
                                objOrderLineItemActual.isUserDefinedOrderLine__c = true;    
                            }
                            //  Defect fix for EDI interface to identify this as user defined order line item - Ends
                            objOrderLineItem.sSAPNumberCode=objOrderFinal.SAP_Number__c + objOrderLineItem.sItemCode;
                            objOrderLineItemActual.Description__c=objOrderLineItem.sJobElementDescription;    
                            objOrderLineItemActual.Sap_Number_Item_Code__c=objOrderLineItem.sSAPNumberCode;
                            objOrderLineItemActual.Code__c=objOrderLineItem.sItemCode;
                            objOrderLineItemActual.P5_Purchase_Order__c=objOrderFinal.Id;
                            objOrderLineItemActual.Rate_Type__c=objOrderLineItem.sRateType;
                            objOrderLineItemActual.P5_Status_c__c='Active';
                            objOrderLineItemActual.Qty__c=objOrderLineItem.dblQty;
                            objOrderLineItemActual.P5_Type__c=objOrderLineItem.sType;
                            objOrderLineItemActual.Units__c=objOrderLineItem.dblUnits;
                            objOrderLineItemActual.P5_Unit_Price_c__c=objOrderLineItem.dblUnitPrice;
                            objOrderLineItemActual.Line_Item_Value__c=objOrderLineItem.dblTotalPrice;
                            objOrderLineItemActual.Skill__c=objOrderLineItem.sSkill;
                            objOrderLineItemActual.Rebate__c = objOrderLineItem.Rebate;
                            orderLineItemLst.add(objOrderLineItemActual);      
                            for (Job_Element__c objJobElement:objOrderLineItem.getSJobElementLst()){
                                objJobElement.Order__c=objOrderFinal.Id;
                                objJobElement.Sub_Status__c='Ordered';
                                objJobElement.Current_Supplier__c=objPurchaseOrder.sSupplierName;
                                objJobElement.Current_Supplier_Number__c=supplierMap.get(objPurchaseOrder.sSupplierId);
                                if (objJobElement.Type__c=='Material'){
                                    objJobElement.Merchant_Order_Number__c=objPurchaseOrder.sSAPNumber;
                                }else if (objJobElement.Type__c=='Work'){
                                    objJobElement.Supplier_Order_Number__c=objPurchaseOrder.sSAPNumber;
                                }
                                objJobElement.New_Supplier__c='';
                                objJobElement.New_Supplier_Number__c='';
                                jobElementLst.add(objJobElement);
                            }
                        }
                    }   
                }
            }
            insert orderLineItemLst;
            List<Job_Element__c> vanStockElementLst=new List<Job_Element__c>{};
            if (vanStock_JobElementMap!=null){
                for (String sVanStockItem:vanStock_JobElementMap.keySet()){
                    vanStockElementLst.addAll(vanStock_JobElementMap.get(sVanStockItem));
                }
                
                for (Job_Element__c objJobElementVanStock:vanStockElementLst){
                    objJobElementVanStock.Is_Vanstock__c=true;
                }
                update vanStockElementLst;
            }
            
            update jobElementLst;
            
            List<Job_Element__c> nonOrderableElementLst=new List<Job_Element__c>{};
            if (nonOrderable_JobElementMap!=null){
                for (String sNonOrderable:nonOrderable_JobElementMap.keySet()){
                    nonOrderableElementLst.addAll(nonOrderable_JobElementMap.get(sNonOrderable));   
                }   
                
                for (Job_Element__c objNonOrderJobElement:nonOrderableElementLst){
                    objNonOrderJobElement.Do_Not_Assign_Order__c=true;
                }
                update nonOrderableElementLst;
            }
            
            for (SAP_Number__c objSapNumber: sapNumberLst_Used) {
                objSapNumber.Active__c=false;
            }
            update sapNumberLst_Used;
            
            // Fix - delete any orders which are being created without any job elements associated with them. 
            PurchaseOrderAmendmentHelper pOAH = new PurchaseOrderAmendmentHelper();
            pOAH.deleteNonJEOrders(objJob);
            pOAH.unlockJob(objJob);
            Pagereference pgRef=new Pagereference('/apex/FaxPageGenerate?jid=' + objJob.Id);
            pgRef.setRedirect(true);
            
            return pgRef;
        } catch(Exception ex) {
            Database.rollback(sp);
            System.debug('%%%%%%%%%%%%' +  ex.getMessage());
            return null;
        }
    }
        public List<SelectOption> tertiarySupplierLst{get;set;}

    private void fetchTertiarySupplier(){
        tertiarySupplierLst=new List<SelectOption>();
        tertiarySupplierLst.add(new Selectoption('','-None-'));
        for (SupplierDetails objSupplier:m_SupplierMap.values()){
            if (objSupplier.intSupplierPref==3){
                tertiarySupplierLst.add(new Selectoption(objSupplier.sSupplierNum,objSupplier.sSupplierName));   
            }
        }
        
    }
    public List<SelectOption> itinerySupplierLst{get;set;}
    private void fetchitinerySupplier(){
        itinerySupplierLst=new List<SelectOption>();
        itinerySupplierLst.add(new Selectoption('','-None-')); 
        for (SupplierDetails objSupplier:im_SupplierMap.values()){
            itinerySupplierLst.add(new Selectoption(objSupplier.sSupplierNum,objSupplier.sSupplierName));   
        }
        
    }
   public PageReference cancel()
   {
        PurchaseOrderAmendmentHelper pOAH = new PurchaseOrderAmendmentHelper();
        pOAH.unlockJob(objJob);
        return( new PageReference('/'+objJob.Id));
    
   } 
    
}