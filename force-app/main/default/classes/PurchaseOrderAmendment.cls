public class PurchaseOrderAmendment {
    /*
    Author            : Cognizant
    Functionality     : The Class perform the creation and maintanence of the Order. 
                        Class takes in data from the Job, Order, Job Element, Order Line Item,Diary Entry, Product Material 
    Create Date       : 03 June 2010
    Change History    :
    Modified Date     :
    */
    Utilities util = new Utilities();
    
    //change to auto populate pts supplier
    public boolean autoPopulateSupplier{get;set;}
    
    //string body, subject ='';
    public class PurchaseOrder{
        public String sSupplierName{get;set;}
        public String sSupplierId{get;set;}
     // Fix for supplier branch number getting flushed out in purchase order amendment - sSupplierBranchNum field added in this inner class.
        public String sSupplierBranchNum{get;set;}
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
        public Boolean blSync{get;set;}
        private String sOrderGenType='Existing';
        // User defined ASP CR
        public Boolean isUserDefinedPO{get;set;}
        public String sOrderStatus{get;set;}
        public String getSOrderGenType(){
            return sOrderGenType;
        } 
        public void setSOrderGenType(String sValue){
            sOrderGenType=sValue;
        }
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
        public Double dblQty{get;set;}
        private List<Job_Element__c> sJobElementLst=new List<Job_Element__c>{};
        public List<Job_Element__c> getSJobElementLst(){return sJobElementLst;}
        public void setSJobElementLst(List<Job_Element__c> value){sJobElementLst=value;}
        //  Defect fix for EDI interface to identify this as user defined order line item.
        public boolean isUserDefinedOrderLine = false;
        public Double rebate{get;set;} {rebate = 0.0;} // PRB00029418
    } 
    // CR - User defined ASP - Made this class public to use in helper
    public class SupplierDetails{
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
        // User defined ASP CR
        public Boolean isUserDefinedItem{get;set;}
    }
    
    public List<underOrderedItem> m_noPriceInformation{get;set;}
    public List<underOrderedItem> im_noPriceInformation{get;set;}
    public List<underOrderedItem> w_noPriceInformation{get;set;}
    public List<underOrderedItem> iw_noPriceInformation{get;set;}
   public  string bo{get;set;}
    
    private String sDistrict;
    public Boolean blError{get;set;}
    public List<underOrderedItem> m_UnOrderedItem{get;set;}
    public List<underOrderedItem> im_UnOrderedItem{get;set;}    
    public boolean blMatUnorder{get;set;}
    public boolean blItMatUnorder{get;set;}    
    public boolean blNoMatPrice{get;set;}
    public boolean blNoItMatPrice{get;set;}
    public boolean blNoWorkPrice{get;set;}
    public boolean blNoItWorkPrice{get;set;}    
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
    // CR - User defined ASP - Made below two class level variables public to use in helper
    public Map<String,SupplierDetails> m_SupplierMap=new Map<String,SupplierDetails>{};
    public Map<String,SupplierDetails> im_SupplierMap=new Map<String,SupplierDetails>{};
    private Map<String,SupplierDetails> l_SupplierMap=new Map<String,SupplierDetails>{};
    private Map<String,SupplierDetails> il_SupplierMap=new Map<String,SupplierDetails>{};    
    private String sPrimarySuppNum;
    private String sSecondarySuppNum;
    
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
    public List<SelectOption> tertiarySupplierLst{get;set;}
    
    // Added these class level variables as part of User defined ASP CR
    public Job__c objJobUDP;
    public List<Selectoption> udp_All_Supplier_List{get;set;}
    public List<Supplier__c> udp_AllMaterialSuppliers{get;set;}
    public List<underOrderedItem> udp_UnOrderedItem{get;set;}
    public List<underOrderedItem> udp_UnOrderedItem_No_Supplier{get;set;}
    public Map<String,List<Job_Element__c>> udp_JobElementMap=new Map<String,List<Job_Element__c>>{};
    public Map<String,Supplier__c> udp_Supplier_Map = new Map<String,Supplier__c>();
    public Map<String,List<Job_Element__c>> um_JobElementMap=new Map<String,List<Job_Element__c>>{}; 
    public Map<String,String> udp_SupplierBranchMAP=new Map<String,String>();
    public Map<Id,String> udp_SuppIdNumMap = new Map<Id,String>();
    
    public List<PurchaseOrder> getPurchaseOrderList (){
        return this.purchaseOrderList;
    }
    public void setPurchaseOrderList (List<PurchaseOrder> value){
        this.purchaseOrderList=value;
    }
   /* public PurchaseOrderAmendment ()
  {
    
  }
  */
    public PurchaseOrderAmendment(Apexpages.standardController controller){
        this.objCurrentJob=(Job__c)controller.getRecord();
        Pagereference p;
        if (blConfirm==false){
            m_noPriceInformation=new List<underOrderedItem>{};
            im_noPriceInformation=new List<underOrderedItem>{};
            w_noPriceInformation=new List<underOrderedItem>{};
            iw_noPriceInformation = new List<underOrderedItem>{};            
            im_UnOrderedItem=new List<underOrderedItem>{};
            m_UnOrderedItem=new List<underOrderedItem>{};   
           
           //change to auto populate supplier
            autoPopulateSupplier = false;
            
            // User defined ASP change - Added one condition in below query to exclude user defined products. 
            // Fix for supplier branch number getting flushed out in purchase order amendment - SupplierBranchNum__c field added in this query.
                   
            objJob=[Select Name, ID, Regenerate_Purchase_Orders__c, CHI_Lead__r.AccountId, CHI_Lead__r.Account.BillingPostalCode,District__c,District__r.Region__c,
                    (Select Id, Line_Item_ID__c, Skill__c, Units__c,Description__c,Status__c, 
                    Sub_Status__c, Supplier_Order_Number__c,Code__c, Merchant_Price__c, Merchant_Order_Number__c,
                    Type__c, Order__c,New_Supplier__c, New_Supplier_Number__c, Current_Supplier__c, 
                    Current_Supplier_Number__c, Order__r.SAP_Number__c,P5_IsItinerary__c,Is_Vanstock__c,Do_Not_Assign_Order__c From  Job_Elements1__r Where Remove_Waste__c='N' and User_Defined_Product__c!=true),
                    (Select Id, SupplierBranchNum__c, Status__c, Sync__c, SAP_Number__c, Supplier__c,Supplier__r.Name,Supplier__r.Supplier_Num__c, Order_Value__c, 
                        Order_Date__c, Amendment_Number__c, Type__c, Amended_or_Removed_Items__c,Fax_Setup__c From Purchase_Orders__r Where Status__c NOT IN ('Cancelled'))
                    ,LastModifiedById,Order_Locking_User__c,order_locking_time__c,Order_Locking_User__r.Name From Job__c  where id= :objCurrentJob.Id]; 
           
           // User defined ASP change - Starts        
            objJobUDP=[Select Name, Regenerate_Purchase_Orders__c, CHI_Lead__r.AccountId, CHI_Lead__r.Account.BillingPostalCode,District__c,District__r.Region__c,
                        (Select Id, Name, Line_Item_ID__c, Skill__c, Units__c,Description__c,Status__c, 
                        Sub_Status__c, Supplier_Order_Number__c,Code__c, 
                        Type__c, Order__c,New_Supplier__c, New_Supplier_Number__c, Current_Supplier__c, 
                        Current_Supplier_Number__c,P5_IsItinerary__c,Is_Vanstock__c,
                        Do_Not_Assign_Order__c,Merchant_Price__c,Merchant_Order_Number__c,Remove_Waste__c,User_Defined_Product__c  From  Job_Elements1__r Where Remove_Waste__c='N' 
                        and User_Defined_Product__c=true and Status__c!='Removed' and Sub_Status__c!='Ordered') From Job__c  where id= :objCurrentJob.Id];

            udp_AllMaterialSuppliers = [Select ID,Supplier_Num__c,Fax_Setup__c,Name,Phone1__c,Van_Stock__c From Supplier__c 
                                        Where Type__c = 'Product' and Available_For_User_Defined__c = True];
            
            if(ApexPages.currentPage().getParameters().get('e')=='1')
            {
                util.setErrorMsg(false, 'Some materials need supplier.');
            }                            
                                        
    /*  if(ApexPages.currentPage().getParameters().get('bookoption')=='1')
       
             {
            
             blConfirm=true;
             p=new PageReference('/'+objJob.id);
             
             //Pagereference pgRef=new Pagereference('/apex/FaxPageGenerate?jid=' + objJob.Id);
            // pgRef.setRedirect(true);
       
            }
            */
            
                                        
                                       
            if(objJob.Order_Locking_User__c!= userinfo.getUserId() && objJob.Order_Locking_User__c!=null)
            {
                 Job__c Job = [select Order_Locking_User__r.Name from Job__c where Id = :objJob.Id];
                 ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order cannot be generated. As the orders are being Processed by '+Job.Order_Locking_User__r.Name);
                 ApexPages.addMessage(errMsg);
                 blConfirm=false;
                 blError = true;
            }                             
            
           udp_All_Supplier_List=new List<SelectOption>();
            udp_All_Supplier_List.add(new Selectoption('','-None-')); 
            for (Supplier__c supp:udp_AllMaterialSuppliers){
                      udp_All_Supplier_List.add(new Selectoption(supp.Supplier_Num__c,supp.Name)); 
                      
                      udp_Supplier_Map.put(supp.Supplier_Num__c,supp); 
                      udp_SuppIdNumMap.put(supp.ID,supp.Supplier_Num__c); 
            }
           
            // Defect fix for removed items getting ordered defect.
            
            List<Job_Element__c> nonUDPJEList = new List<Job_Element__c>();
            for(Job_Element__c je : objJob.Job_Elements1__r){
                //system.debug('jobelements********'+objJob.Job_Elements1__r);
                if(je.Status__c == 'Removed' && je.Order__c == null){
                    continue;
                }else{
                       nonUDPJEList.add(je);
               }
            }
                
            sDistrict=objJob.District__c;            
            List<Job_Element__c> job_ElementLst=new List<Job_Element__c>{};
            String sSupplierNum='';
            for (Job_Element__c objJobElement:nonUDPJEList){
                sSupplierNum='';
                job_ElementLst=new List<Job_Element__c>{};
                if (objJobElement.Type__c=='Material' && objJobElement.P5_IsItinerary__c==false){
                    system.debug('JE###--'+objJobElement);
                
                    if (objJobElement.Order__c==null && objJobElement.Status__c!='Removed') {
                        if (!m_JobElementMap.containsKey(objJobElement.Code__c)){
                            job_ElementLst.add(objJobElement);
                        } else {
                            job_ElementLst=m_JobElementMap.get(objJobElement.Code__c);
                            job_ElementLst.add(objJobElement);                      
                        }//End if
                        m_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                    }
                } else if (objJobElement.Type__c=='Material' && objJobElement.P5_IsItinerary__c==true){
                    if (objJobElement.Order__c==null && objJobElement.Status__c!='Removed') {
                        if (!im_JobElementMap.containsKey(objJobElement.Code__c)){
                            job_ElementLst.add(objJobElement);
                        } else {
                            job_ElementLst=im_JobElementMap.get(objJobElement.Code__c);
                            job_ElementLst.add(objJobElement);                      
                        }//End if
                        im_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                    }
                } else if (objJobElement.Type__c=='Work' && objJobElement.P5_IsItinerary__c==false){
                    if (objJobElement.New_Supplier_Number__c!=null){
                        if (objJobElement.New_Supplier_Number__c=='') {
                            sSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                        } else {
                            sSupplierNumSet.add(objJobElement.New_Supplier_Number__c);  
                            sSupplierNum=objJobElement.New_Supplier_Number__c;
                        }
                    } else {
                        sSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                    }//End if
                    
                    if (objJobElement.Order__c==null && objJobElement.Status__c!='Removed'){
                        if (objJobElement.New_Supplier_Number__c!=null){
                            if (objJobElement.New_Supplier_Number__c=='') {
                                sSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                                sSupplierNum=objJobElement.Current_Supplier_Number__c;  
                            }else {
                                sSupplierNumSet.add(objJobElement.New_Supplier_Number__c);  
                                sSupplierNum=objJobElement.New_Supplier_Number__c;
                            }
                        } else {
                            sSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                            sSupplierNum=objJobElement.Current_Supplier_Number__c;
                        }//End if
                    }
                    
                    w_JobElementMap=new Map<String,List<Job_Element__c>>{};
                    if (sSupplierNum!=''){
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
                        System.debug(w_SupplierJobElementMap);
                    }
                } else if (objJobElement.Type__c=='Work' && objJobElement.P5_IsItinerary__c==true) {
                    if (objJobElement.New_Supplier_Number__c!=null){
                          if (objJobElement.New_Supplier_Number__c=='') {
                            isSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                        } else {
                            isSupplierNumSet.add(objJobElement.New_Supplier_Number__c);  
                            sSupplierNum=objJobElement.New_Supplier_Number__c;
                        }
                    } else {
                        isSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                    }//End if
                    
                     if (objJobElement.Order__c==null && objJobElement.Status__c!='Removed'){
                        if (objJobElement.New_Supplier_Number__c!=null){
                            if (objJobElement.New_Supplier_Number__c=='') {
                                isSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                                sSupplierNum=objJobElement.Current_Supplier_Number__c;  
                            }else {
                                isSupplierNumSet.add(objJobElement.New_Supplier_Number__c);  
                                sSupplierNum=objJobElement.New_Supplier_Number__c;
                            }
                        } else {
                            isSupplierNumSet.add(objJobElement.Current_Supplier_Number__c);
                            sSupplierNum=objJobElement.Current_Supplier_Number__c;
                        }//End if
                    }
                    
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
            }//End For
            
            // User defined ASP CR - Starts
            // Add user defined job elements to the material map created abvove.
             for (Job_Element__c objJobElement:objJobUDP.Job_Elements1__r){
                job_ElementLst=new List<Job_Element__c>{};
                if (objJobElement.Type__c=='Material' && objJobElement.User_Defined_Product__c){
                    if (objJobElement.Order__c==null && objJobElement.Status__c!='Removed') {
                        if (!udp_JobElementMap.containsKey(objJobElement.Code__c)){
                            job_ElementLst.add(objJobElement);
                        } else {
                            job_ElementLst=udp_JobElementMap.get(objJobElement.Code__c);
                            job_ElementLst.add(objJobElement);                      
                        }//End if
                        udp_JobElementMap.put(objJobElement.Code__c,job_ElementLst);
                    }
                } 
             }
            
            if (udp_JobElementMap!=null){
                udp_UnOrderedItem=new List<underOrderedItem>{};
                udp_UnOrderedItem_No_Supplier = new List<underOrderedItem>{};
                underOrderedItem udpObjUnOrdered=new underOrderedItem();
                List<Job_Element__c> udpUnOrderedLst=new List<Job_Element__c>{};
                Job_Element__c udpObjJobElement;
                for (String sTemp: udp_JobElementMap.keySet()){
                    udpObjUnOrdered=new underOrderedItem();
                    udpUnOrderedLst=udp_JobElementMap.get(sTemp);
                    udpObjJobElement=new Job_Element__c();
                    udpObjJobElement.Code__c=udpUnOrderedLst[0].Code__c;
                    udpObjJobElement.Description__c=udpUnOrderedLst[0].Description__c;
                    udpObjJobElement.Units__c=udpUnOrderedLst[0].Units__c;
                    udpObjUnOrdered.objJobElement=udpObjJobElement;
                    udpObjUnOrdered.setSJobElementIdLst(udpUnOrderedLst);
                    udp_UnOrderedItem.add(udpObjUnOrdered);  
                }//End for
            }
            
            List<Job_Element__c> job_ElementLstUDP;
            
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
           // User defined ASP CR - Ends
            Decimal dblTemp=0;
            PurchaseOrder objPurchaseOrder;
            purchaseOrderList=new List<PurchaseOrder>{};
            Set<String> sOrderIdSet = new Set<String>{};
           
            // User defined ASP CR - Shifted the logic for adding existing purchase orders in database in the purchaseorderlist in helper class.
            PurchaseOrderAmendmentHelper p_add_to_plist = new PurchaseOrderAmendmentHelper();
            p_add_to_plist.addSavedOrdersToPurchaseOrderList(objJob, sOrderIdSet, purchaseOrderList, objPurchaseOrder);
            
            List<Order_Line_Item__c> orderLineItemLst=[Select Units__c, Total_Amount__c, Rebate__c, Supplier__c, Skill__c, P5_Unit_Price_c__c, Line_Item_Value__c,P5_Type__c, P5_Status_c__c, P5_Purchase_Order__c, Id, Code__c,Description__c,Sap_Number_Item_Code__c,Rate_Type__c,Qty__c From Order_Line_Item__c Where P5_Purchase_Order__c In:sOrderIdSet];
            OrderLineItem objOrderLine;
            List<Job_Element__c> sJobElementIdLst;
            List<Job_Element__c> w_JobElementLst=new List<Job_Element__c>{};
            // Added 
            Set<String> codeSet = new Set<String>();
            for(Order_Line_Item__c oli : orderLineItemLst){
                if(oli.P5_Type__c == 'Work'){               
                    codeSet.add(oli.Code__c);}}
            List<Product_Work_Code__c> pwcList = [Select p.Work_Code__c,p.Product_Code__c, p.Hours__c From Product_Work_Code__c p where Start_Date__c <= :System.today() and End_Date__c >= :System.today() and Active__c = true and Work_Code__c in :codeSet];
            Map<String,Integer> pwcMap = new Map<String,Integer>(); 
            for(Product_Work_code__c wc : pwcList)
                pwcMap.put(wc.Work_Code__c , (wc.Hours__c).intValue());
            System.debug('----------pwcMap----------'+pwcMap);                
            // End
            //body+='\n'+purchaseOrderList.size();
            
            for (PurchaseOrder objPurcOrder:purchaseOrderList) {
                
                // system.debug('purchaseorderlist************'+purchaseOrderList);
                 
                List<OrderLineItem> orderLineLst=new List<OrderLineItem>{};
                if (objPurcOrder.sOrderType=='Material') {
                     
                    for (Order_Line_Item__c objOrderLineItem:orderLineItemLst) {
                        if (objPurcOrder.sOrderId==objOrderLineItem.P5_Purchase_Order__c) {
                            Double dblQty=0;
                            Double dblIntQty=0;
                            objOrderLine=new OrderLineItem();
                            sJobElementIdLst=new List<Job_Element__c>{};
                            dblQty=objOrderLineItem.Units__c;
                            for (Job_Element__c objJobEle:objPurcOrder.jobElementLst){
                                if (objJobEle.Code__c==objOrderLineItem.Code__c){
                                    if ((objJobEle.Status__c=='Removed' && objJobEle.Sub_Status__c=='Awaiting Order') || (objJobEle.New_Supplier__c!=null)) {
                                        dblQty=dblQty -  objJobEle.Units__c;
                                    } else {
                                        sJobElementIdLst.add(objJobEle); 
                                        dblIntQty=dblIntQty+1; }}}
                            objOrderLine.setSJobElementLst(sJobElementIdLst);
                            objOrderLine.sJobElementDescription=objOrderLineItem.Description__c;
                            objOrderLine.sSAPNumberCode=objOrderLineItem.Sap_Number_Item_Code__c;
                            if (dblQty<objOrderLineItem.Units__c){
                                objPurcOrder.setSOrderGenType('Amended');
                                objOrderLine.sStatus='Amended';
                                objOrderLine.dblUnits=dblQty;
                                objOrderLine.dblQty=dblIntQty;
                                dblTemp=objOrderLineItem.P5_Unit_Price_c__c * dblQty;
                                objOrderLine.dblTotalPrice=dblTemp.setScale(2);
                            } else {
                                objOrderLine.sStatus=objOrderLineItem.P5_Status_c__c;
                                objOrderLine.dblUnits=objOrderLineItem.Units__c;
                                objOrderLine.dblQty=objOrderLineItem.Qty__c;
                                dblTemp=objOrderLineItem.Line_Item_Value__c;
                                objOrderLine.dblTotalPrice=dblTemp.setScale(2);
                            }
                            if (dblQty==0){
                                objPurcOrder.setSOrderGenType('Amended');
                                objOrderLine.sStatus='Removed';
                                objOrderLine.dblUnits=dblQty;
                                objOrderLine.dblQty=dblIntQty;
                                dblTemp=objOrderLineItem.P5_Unit_Price_c__c * dblQty;
                                objOrderLine.dblTotalPrice=dblTemp.setScale(2); 
                            }
                            if (objOrderLineItem.P5_Status_c__c=='Cancelled'){
                                //system.debug('cancelling the purchaseorders******'+objOrderLineItem.P5_Status_c__c);
                                objPurcOrder.setSOrderGenType('Amended');
                                //system.debug('cancelling the orderline items************'+objOrderLine.sStatus);
                                objOrderLine.sStatus='Cancelled';
                                objOrderLine.dblUnits=0;
                                objOrderLine.dblQty=0;
                                objOrderLine.dblTotalPrice=0;   
                            }
                            objOrderLine.sRateType=objOrderLineItem.Rate_Type__c;
                            objOrderLine.sType=objOrderLineItem.P5_Type__c;
                            objOrderLine.dblUnitPrice=objOrderLineItem.P5_Unit_Price_c__c;
                            objOrderLine.sSupplier=objOrderLineItem.Supplier__c;
                            objOrderLine.sSkill=objOrderLineItem.Skill__c;
                            objOrderLine.sItemCode=objOrderLineItem.Code__c;
                            objOrderLine.rebate = objOrderLineItem.Rebate__c; // PRB00029418
                            orderLineLst.add(objOrderLine);}}
                    objPurcOrder.orderLineItemLst=orderLineLst;
                } else if (objPurcOrder.sOrderType=='Work') {
                    for (Order_Line_Item__c objOrderLineItem:orderLineItemLst) {
                        if (objPurcOrder.sOrderId==objOrderLineItem.P5_Purchase_Order__c) {
                            Double dblQty=0;
                            Double dblIntQty=0;
                            objOrderLine=new OrderLineItem();
                            sJobElementIdLst=new List<Job_Element__c>{};
                            dblQty=objOrderLineItem.Units__c;                            
                            Boolean blVariable=true;
                            if (objOrderLineItem.P5_Unit_Price_c__c==0){
                                blVariable=true;
                            }else{ 
                                if (objOrderLineItem.Rate_Type__c=='Variable') {
                                    blVariable=true;
                                } else {blVariable=false;}}
                            
                             if (objOrderLineItem.Rate_Type__c=='Fixed') {
                                    blVariable=false;
                                } 
                                
                            for (Job_Element__c objJobEle:objPurcOrder.jobElementLst){
                                if (objJobEle.Code__c==objOrderLineItem.Code__c){
                                    
                                    if ((objJobEle.Status__c=='Removed' && objJobEle.Sub_Status__c=='Awaiting Order') || (objJobEle.New_Supplier__c!=null)) {
                                        
                                        if(blVariable)
                                          dblQty=dblQty -  objJobEle.Units__c;
                                        else
                                            dblQty=dblQty -  1;
                                            
                                        if(dblIntQty>0)  //code fix as a part of PRB00010783 by BGSAMS Support on 30/1/2013  
                                        dblIntQty=dblIntQty-1;
                                    }else {
                                        sJobElementIdLst.add(objJobEle);
                                        dblIntQty=dblIntQty+1;
                                    }
                                }
                            } 
                            objOrderLine.setSJobElementLst(sJobElementIdLst);
                            objOrderLine.sJobElementDescription=objOrderLineItem.Description__c;
                            objOrderLine.sSAPNumberCode=objOrderLineItem.Sap_Number_Item_Code__c;
                            if (dblQty<objOrderLineItem.Units__c){
                                objPurcOrder.setSOrderGenType('Amended');
                                objOrderLine.sStatus='Amended';
                                objOrderLine.dblUnits=dblQty;
                                objOrderLine.dblQty=dblIntQty;
                                dblTemp=(blVariable==true ? objOrderLineItem.P5_Unit_Price_c__c * dblQty : objOrderLineItem.P5_Unit_Price_c__c * dblQty);
                                if(dblQty <= 0.02 && blVariable){
                                    dblTemp = 0.00;
                                }
                                objOrderLine.dblTotalPrice=dblTemp.setScale(2);
                            } else {
                                objOrderLine.sStatus=objOrderLineItem.P5_Status_c__c;
                                objOrderLine.dblUnits=objOrderLineItem.Units__c;
                                objOrderLine.dblQty=dblIntQty;
                                dblTemp=objOrderLineItem.Line_Item_Value__c;
                                objOrderLine.dblTotalPrice=dblTemp.setScale(2);
                            }
                            if (objOrderLineItem.P5_Status_c__c=='Cancelled'){
                                //system.debug('cancelling the purchaseorders******'+objOrderLineItem.P5_Status_c__c);
                                objPurcOrder.setSOrderGenType('Amended');
                                // system.debug('cancelling the orderline items************'+objOrderLine.sStatus);
                                objOrderLine.sStatus='Cancelled';
                                objOrderLine.dblQty=0;
                                objOrderLine.dblUnits=0;
                                objOrderLine.dblTotalPrice=0;   
                            }
                            System.debug('----rate type '+ objOrderLineItem.Rate_Type__c);
                            System.debug('----rate type '+ objOrderLineItem.P5_Type__c);
                            
                        /*    if(objOrderLineItem.Rate_Type__c == 'Fixed' && ( objOrderLineItem.P5_Type__c == 'Work' || objOrderLineItem.P5_Type__c =='Itinerary')){
                                if(pwcMap.get(objOrderLineItem.code__c) != null){
                                    Integer qty = pwcMap.get(objOrderLineItem.code__c);
                                    if(qty > 0 ){
                                        objOrderLine.dblUnits=dblQty/qty;
                                        objOrderLine.dblQty=dblIntQty/qty;
                                    }
                                }
                            } */
                            
                            objOrderLine.sRateType=objOrderLineItem.Rate_Type__c;
                            objOrderLine.sType=objOrderLineItem.P5_Type__c;
                            objOrderLine.dblUnitPrice=objOrderLineItem.P5_Unit_Price_c__c;
                            objOrderLine.sSupplier=objOrderLineItem.Supplier__c;
                            objOrderLine.sSkill=objOrderLineItem.Skill__c;
                            objOrderLine.sItemCode=objOrderLineItem.Code__c;
                            system.debug('Error---->'+objOrderLine);
                            orderLineLst.add(objOrderLine);
                        }
                    }
                    objPurcOrder.orderLineItemLst=orderLineLst;
                } else if (objPurcOrder.sOrderType=='Itinerary') {
                    for (Order_Line_Item__c objOrderLineItem:orderLineItemLst) {
                        if (objPurcOrder.sOrderId==objOrderLineItem.P5_Purchase_Order__c) {
                            Double dblQty=0;
                            objOrderLine=new OrderLineItem();
                            sJobElementIdLst=new List<Job_Element__c>{};
                            dblQty=objOrderLineItem.Units__c;
                            
                            System.debug('----rate type '+ objOrderLineItem.Rate_Type__c);
                            System.debug('----rate type '+ objOrderLineItem.P5_Type__c);
                            
                         /*   if(objOrderLineItem.Rate_Type__c == 'Fixed' && ( objOrderLineItem.P5_Type__c == 'Work' || objOrderLineItem.P5_Type__c =='Itinerary')){
                                if(pwcMap.get(objOrderLineItem.code__c) != null){
                                    Integer qty = pwcMap.get(objOrderLineItem.code__c);
                                    if(qty > 0 ){
                                        objOrderLine.dblUnits=objOrderLineItem.Units__c/qty;
                                        objOrderLine.dblQty=objOrderLineItem.Units__c/qty;
                                    }
                                }
                            } */
                            
                            
                            Boolean blVariable=true;
                            if (objOrderLineItem.Rate_Type__c=='Variable'){
                                blVariable=true;
                            }else{ 
                                blVariable=false;
                            }
                            for (Job_Element__c objJobEle:objPurcOrder.jobElementLst){
                                if (objJobEle.Code__c==objOrderLineItem.Code__c){
                                    
                                    if ((objJobEle.Status__c=='Removed' && objJobEle.Sub_Status__c=='Awaiting Order') || (objJobEle.New_Supplier__c!=null)) {
                                        if(blVariable)
                                          dblQty=dblQty -  objJobEle.Units__c;
                                        else
                                            dblQty=dblQty -  1;
                                    }else {
                                        sJobElementIdLst.add(objJobEle);
                                    }
                                }
                            } 
                            objOrderLine.setSJobElementLst(sJobElementIdLst);
                            objOrderLine.sJobElementDescription=objOrderLineItem.Description__c;
                            objOrderLine.sSAPNumberCode=objOrderLineItem.Sap_Number_Item_Code__c;
                            if (dblQty<objOrderLineItem.Units__c){
                                objPurcOrder.setSOrderGenType('Amended');
                                objOrderLine.sStatus='Amended';
                                objOrderLine.dblUnits=dblQty;
                                dblTemp=(blVariable==true ? objOrderLineItem.P5_Unit_Price_c__c * dblQty : objOrderLineItem.P5_Unit_Price_c__c * dblQty);
                                if(dblQty <= 0.02 && blVariable){
                                    dblTemp = 0.00;
                                }
                                objOrderLine.dblTotalPrice=dblTemp.setScale(2);
                            } else {
                                objOrderLine.sStatus=objOrderLineItem.P5_Status_c__c;
                                objOrderLine.dblUnits=objOrderLineItem.Units__c;
                                dblTemp=objOrderLineItem.Line_Item_Value__c;
                                objOrderLine.dblTotalPrice=dblTemp.setScale(2);
                            }
                            if (objOrderLineItem.P5_Status_c__c=='Cancelled'){
                                //system.debug('cancelling the purchaseorders******'+objOrderLineItem.P5_Status_c__c);
                                objPurcOrder.setSOrderGenType('Amended');
                               // system.debug('cancelling the orderline items************'+objOrderLine.sStatus);
                                objOrderLine.sStatus='Cancelled';
                                objOrderLine.dblUnits=0;
                                objOrderLine.dblTotalPrice=0;   
                            }
                            objOrderLine.sRateType=objOrderLineItem.Rate_Type__c;
                            objOrderLine.sType=objOrderLineItem.P5_Type__c;
                            objOrderLine.dblUnitPrice=objOrderLineItem.P5_Unit_Price_c__c;
                            objOrderLine.sSupplier=objOrderLineItem.Supplier__c;
                            objOrderLine.sSkill=objOrderLineItem.Skill__c;
                            objOrderLine.sItemCode=objOrderLineItem.Code__c;
                            orderLineLst.add(objOrderLine);
                        }
                    }
                    objPurcOrder.orderLineItemLst=orderLineLst;
                }   
                //body += objPurcOrder.sSAPNumber+' --->' +objPurcOrder.getSOrderGenType(); 
            } 
            //body +='\n';
            String sPostCode=objJob.CHI_Lead__r.Account.BillingPostalCode;
            String sPostCodeSector=sPostCode.substring(0,sPostCode.length()-2);
            objPostCodeSector=[Select P5_Secondary_Supplier__r.Name, P5_Secondary_Supplier__c,P5_Secondary_Supplier__r.Id,
                                                    P5_Secondary_Supplier__r.Supplier_Num__c, 
                                                    P5_Secondary_Supplier__r.Van_Stock__c,
                                                    P5_Secondary_Supplier__r.Phone1__c,P5_Primary_Supplier__c,
                                                    P5_Primary_Supplier__r.Name, P5_Primary_Supplier__r.Id, 
                                                    P5_Secondary_Supplier__r.Fax_Setup__c, P5_Primary_Supplier__r.Fax_Setup__c,
                                                    P5_Primary_Supplier__r.Supplier_Num__c,
                                                    P5_Primary_Supplier__r.Van_Stock__c,
                                                    P5_Primary_Supplier__r.Van_Stock_Value__c,
                                                    P5_Secondary_Supplier__r.Van_Stock_Value__c,
                                                    P5_Primary_Supplier__r.Phone1__c
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
            Map<String,Map<String,Post_Code_Skill_Rate__c>> postCodeSkillRateMap=new Map<String,Map<String,Post_Code_Skill_Rate__c>>{};
            Map<String,Map<String,Rate_Card_Items__c>> rateCardItemMap = new Map<String,Map<String,Rate_Card_Items__c>>{};
            if (w_SupplierJobElementMap==null){
            } else if (w_SupplierJobElementMap.size()>0){
                objRateCard.fetchWorkSupplierRate(l_SupplierMap.keySet(), w_SupplierJobElementMap, sPostCodeId, sRegionId,sDistrict);
                postCodeSkillRateMap=objRateCard.postCodeSkillRateMap;
                rateCardItemMap=objRateCard.rateCardItemMap; 
                for (String sSupplierNumber:l_SupplierMap.keySet()){
                    generateWorkOrder(w_SupplierJobElementMap, postCodeSkillRateMap, rateCardItemMap, sSupplierNumber);
                }
            }
            
            
            fetchSupplier('Work-Itinery');
            
            //Fetching Pricing information for the Work Type Job Element
            Map<String,Map<String,Post_Code_Skill_Rate__c>> iPostCodeSkillRateMap=new Map<String,Map<String,Post_Code_Skill_Rate__c>>{};
            Map<String,Map<String,Rate_Card_Items__c>> iRateCardItemMap = new Map<String,Map<String,Rate_Card_Items__c>>{};
            if (iw_SupplierJobElementMap==null){
            } else if (iw_SupplierJobElementMap.size()>0){
                objRateCard.fetchWorkSupplierRate(il_SupplierMap.keySet(), iw_SupplierJobElementMap, sPostCodeId, sRegionId,sDistrict);
                iPostCodeSkillRateMap=objRateCard.postCodeSkillRateMap;
                iRateCardItemMap=objRateCard.rateCardItemMap; 
                for (String sSupplierNumber:il_SupplierMap.keySet()){
                    generateItineryWorkOrder(iw_SupplierJobElementMap, iPostCodeSkillRateMap, iRateCardItemMap, sSupplierNumber);
                }
            }
            
            //Material Order Generation
            fetchSupplier('Material');
            m_RateCard=new Map<String,Map<String,Rate_Card_Items__c>> {};
            m_RateCard=objRateCard.fetchMaterialSupplierRate(m_SupplierMap.keySet(), m_JobElementMap, sPostCodeId, sRegionId,sDistrict);
            System.debug('1************************ M Rate Card: ' + m_RateCard);
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
            
        }
        
           
   /* if(ApexPages.currentPage().getParameters().get('bookoption')=='1')
             {
            //Job__c Job = [select Order_Locking_User__r.Name from Job__c where id = :job.id];
             blConfirm=true;
              //return new PageReference('/apex/ProcessJobOrders?id='+job.id+'&bookoption='+'1');
             
            }  
            */
                
                
        blMatUnorder=(m_UnOrderedItem.size()>0? true : false);
        blItMatUnorder=(im_UnOrderedItem.size()>0? true : false);
        
        blNoMatPrice=(m_noPriceInformation.size()>0? true : false);
        System.debug('%%%%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^^' + blNoMatPrice);
        System.debug(m_noPriceInformation);
        blNoItMatPrice=(im_noPriceInformation.size()>0? true: false);
        blNoWorkPrice=(w_noPriceInformation.size()>0? true : false);
        blNoItWorkPrice=(iw_noPriceInformation.size()>0? true : false);

        
        
       
    } 
     
 

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
        OrderLineItem objOrderLineItem=new OrderLineItem();
        Map<String,List<Job_Element__c>> w_JobElementIndividualMap=new Map<String,List<Job_Element__c>>{};
        Map<String,Post_Code_Skill_Rate__c> l_PostcodeSkillRate=new Map<String,Post_Code_Skill_Rate__c>{};
        Map<String,Rate_Card_Items__c> l_RateCardItems=new Map<String,Rate_Card_Items__c>{};
        System.debug('^^^^^^^^^^^ : ' + w_SupplierTotalJobElementMap);
        w_JobElementIndividualMap=w_SupplierTotalJobElementMap.get(sSupplierNum);
        l_PostcodeSkillRate=postCodeSkillRateMap.get(sSupplierNum);
        l_RateCardItems=rateCardItemMap.get(sSupplierNum);
        Double dblQty=0;
        Double dblOrderTotal=0; 
        Boolean blnNoPrice=false;
        Boolean blnGenerateOrder=false;
        Decimal dblTemp=0;
        if (w_JobElementIndividualMap!=null){
            if (l_PostcodeSkillRate!=null){  
                objPurchaseOrder=new PurchaseOrder();
                objPurchaseOrder.dtOrderDt=System.today();
                objPurchaseOrder.sDispDate=System.today().format();
                objPurchaseOrder.sOrderType='Work';
                objPurchaseOrder.setSOrderGenType('New');
                objPurchaseOrder.blSync=false;
                objPurchaseOrder.sSupplierId=l_SupplierMap.get(sSupplierNum).sSupplierId;
                objPurchaseOrder.sSupplierName=l_SupplierMap.get(sSupplierNum).sSupplierName;
                objPurchaseOrder.blFaxEnabled=l_SupplierMap.get(sSupplierNum).blFaxEnabled;
                objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
                
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
                    if (l_PostcodeSkillRate.containsKey(objOrderLineItem.sSkill)){
                        if(l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Preference__c=='Fixed'){
                            if (l_RateCardItems!=null){
                                if (l_RateCardItems.containsKey(objOrderLineItem.sItemCode)){
                                    objOrderLineItem.dblUnitPrice=l_RateCardItems.get(objOrderLineItem.sItemCode).Cost__c;
                                    dblTemp=objOrderLineItem.dblUnitPrice*tmpUnits;
                                    objOrderLineItem.sRateType='Fixed';
                                    
                                    // added
                                    
                                    System.debug('############ inside fixed 3 #####    '+ pwcMap);
                                    System.debug('############ inside fixed 4 #####    '+ objOrderLineItem.sItemCode);
                                    
                                    // Fix for fixed rate units calculation - comneted below part
                                    
                                    /*if(pwcMap.get(objOrderLineItem.sItemCode) !=null ){
                                        Integer hrs = pwcMap.get(objOrderLineItem.sItemCode);
                                        if(hrs > 0){
                                            dblTemp= (objOrderLineItem.dblUnitPrice)/hrs;
                                            objOrderLineItem.dblQty = dblTemp;
                                        }
                                    }
                                    objOrderLineItem.dblUnits= dblTemp;*/
                                    
                                     objOrderLineItem.dblQty = tmpUnits;
                                     objOrderLineItem.dblUnits = tmpUnits;
                                    
                                    objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);      
                                }   else {
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
                            }else {
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
            } else {
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
         // Fix for fixed rate units calculation
        Integer tmpUnits = 0;                                
        underOrderedItem objNoPriceInformation=new underOrderedItem();
        PurchaseOrder objPurchaseOrder;
        List<OrderLineItem> orderlineLst;
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
        if (w_JobElementIndividualMap!=null) { 
            if (l_PostcodeSkillRate!=null){  
                objPurchaseOrder=new PurchaseOrder();
                objPurchaseOrder.dtOrderDt=System.today();
                objPurchaseOrder.sDispDate=System.today().format();
                objPurchaseOrder.sOrderType='Itinerary';
                objPurchaseOrder.setSOrderGenType('New');
                objPurchaseOrder.blSync=false;
                objPurchaseOrder.sSupplierId=il_SupplierMap.get(sSupplierNum).sSupplierId;
                objPurchaseOrder.sSupplierName=il_SupplierMap.get(sSupplierNum).sSupplierName;
                objPurchaseOrder.blFaxEnabled=il_SupplierMap.get(sSupplierNum).blFaxEnabled;
                objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
                // Added - Product Work Order
                Map<String,Integer> pwcMap = new Map<String,Integer>();
                Set<String> codeSet = new Set<String>();
                for (String sTemp:w_JobElementIndividualMap.keyset()){
                    l_SelectedJobElementLst=w_JobElementIndividualMap.get(sTemp);
                    for(Job_Element__c objJobEle:l_SelectedJobElementLst){
                        codeSet.add(objJobEle.Code__c);}}
                // added
                List<Product_Work_Code__c> pwcList = [Select p.Work_Code__c,p.Product_Code__c, p.Hours__c From Product_Work_Code__c p where Start_Date__c <= :System.today() and End_Date__c >= :System.today() and Active__c = true and Work_Code__c in :codeSet];
                for(Product_Work_code__c wc : pwcList)
                    pwcMap.put(wc.Work_Code__c , (wc.Hours__c).intValue());
                // end
                for (String sTemp:w_JobElementIndividualMap.keyset()){
                    blnNoPrice=false;
                    objOrderLineItem=new OrderLineItem();
                    objOrderLineItem.dblUnits=0;
                    l_SelectedJobElementLst=w_JobElementIndividualMap.get(sTemp);
                    // Fix for fixed rate units calculation
                    tmpUnits = 0;
                    for(Job_Element__c objJobEle:l_SelectedJobElementLst){
                        objOrderLineItem.sJobElementDescription=objJobEle.Description__c;
                        objOrderLineItem.sStatus='Active';
                        objOrderLineItem.sType=objJobEle.Type__c;
                        objOrderLineItem.sSupplier=il_SupplierMap.get(sSupplierNum).sSupplierId;
                        objOrderLineItem.sSkill=objJobEle.Skill__c;
                        objOrderLineItem.sItemCode=objJobEle.Code__c;
                        objOrderLineItem.dblUnits=objOrderLineItem.dblUnits + objJobEle.Units__c;
                        objOrderLineItem.sSAPNumberCode=''; 
                        tmpUnits++;
                    }
                    objOrderLineItem.setSJobElementLst(l_SelectedJobElementLst);
                    Decimal dblTemp=0;
                    if (l_PostcodeSkillRate.containsKey(objOrderLineItem.sSkill)){
                        if(l_PostcodeSkillRate.get(objOrderLineItem.sSkill).Preference__c=='Fixed'){
                            if (l_RateCardItems!=null){
                                if (l_RateCardItems.containsKey(objOrderLineItem.sItemCode)){
                                    objOrderLineItem.dblUnitPrice=l_RateCardItems.get(objOrderLineItem.sItemCode).Cost__c;
                                    objOrderLineItem.sRateType='Fixed';
                                    dblTemp=objOrderLineItem.dblUnitPrice*tmpUnits;
                                    objOrderLineItem.dblTotalPrice= dblTemp.setScale(2);
                                    // added
                                    
                                    System.debug('############ inside fixed 3 #####    '+ pwcMap);
                                    System.debug('############ inside fixed 4 #####    '+ objOrderLineItem.sItemCode);
                                    
                                    // Fix for fixed rate units calculation - comneted below part
                                    
                                   /* if(pwcMap.get(objOrderLineItem.sItemCode) !=null ){
                                        Integer hrs = pwcMap.get(objOrderLineItem.sItemCode);
                                        if(hrs > 0){
                                            dblTemp= (objOrderLineItem.dblUnitPrice)/hrs;
                                            objOrderLineItem.dblQty = dblTemp;
                                        }
                                    }
                                    objOrderLineItem.dblUnits= dblTemp; */
                                    
                                    //end
                                    
                                      objOrderLineItem.dblQty = tmpUnits;
                                      objOrderLineItem.dblUnits = tmpUnits;
                                    
                                          
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
                            }else {
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
                        System.debug('#########################' );
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
            } else {
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
    
   // User defined ASP CR - shifted the code from below two methods in PurchaseOrderAmendmentHelper.cls
   // Size of this class was going beyond allowed max limit in Salesforce.
    
    public void generateMaterialOrder(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String sSupplierNum,Map<String,Rate_Card_Items__c> m_Rate ){
    
       PurchaseOrderAmendmentHelper poahelperInstance = new PurchaseOrderAmendmentHelper();
       poahelperInstance.generateMaterialOrder(m_SelectedJobElementMap,sSupplierNum,m_Rate,m_SupplierMap,
                                                    m_noPriceInformation,purchaseOrderList,objJobUDP,um_JobElementMap,udp_UnOrderedItem);
    
    }
    
    public void generateItineryMaterialOrder(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String sSupplierNum,Map<String,Rate_Card_Items__c> m_Rate ){
        
       PurchaseOrderAmendmentHelper poahelperInstance = new PurchaseOrderAmendmentHelper();
       poahelperInstance.generateItineryMaterialOrder(m_SelectedJobElementMap,sSupplierNum,m_Rate,im_SupplierMap,
                                               im_noPriceInformation,purchaseOrderList);

    }
    

    /*
        Fetches the supplier Information from the Job Element Record for the Work Type Job Elements and
        from the Post Code for the material supplier. 
        In case of Tiertiary supplier it fetches record from the Rate Card item where suppliers have national rate card
    */ 
    private void fetchSupplier(String sType){
        SupplierDetails objSupplier=new SupplierDetails();
        if (sType=='Work'){
            for (Supplier__c objSupp:[Select Supplier_Num__c,Fax_Setup__c, Name,Phone1__c, Id,Van_Stock__c,Van_Stock_Value__c From Supplier__c 
                                        Where Supplier_Num__c In:sSupplierNumSet ]){
                objSupplier=new SupplierDetails();
                objSupplier.sSupplierId=objSupp.Id;
                objSupplier.blFaxEnabled=objSupp.Fax_Setup__c;
                //objSupplier.sSupplierId=objSupplier.sSupplierId.substring(0,15);
                objSupplier.sSupplierName=objSupp.Name;
                objSupplier.sSupplierNum=objSupp.Supplier_Num__c;
                objSupplier.sSupplierPhone=objSupp.Phone1__c;
                objSupplier.blVanstock=objSupp.Van_Stock__c;
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
            for (Supplier__c objSupp:[Select Supplier_Num__c,Fax_Setup__c, Name,Phone1__c, Id,Van_Stock__c,Van_Stock_Value__c From Supplier__c 
                                        Where Supplier_Num__c In:isSupplierNumSet ]){
                objSupplier=new SupplierDetails();
                objSupplier.sSupplierId=objSupp.Id;
                objSupplier.blFaxEnabled=objSupp.Fax_Setup__c;
                //objSupplier.sSupplierId=objSupplier.sSupplierId.substring(0,15);
                objSupplier.sSupplierName=objSupp.Name;
                objSupplier.sSupplierNum=objSupp.Supplier_Num__c;
                objSupplier.sSupplierPhone=objSupp.Phone1__c;
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
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Primary_Supplier__r.Phone1__c;
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
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Secondary_Supplier__r.Phone1__c;
                objSupplier.blVanstock=objPostCodeSector.P5_Secondary_Supplier__r.Van_Stock__c; 
                //vanstock change start
                objSupplier.vanStockValue = objPostCodeSector.P5_Primary_Supplier__r.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=2;  
                //sSecondarySuppNum=objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c;           
                im_SupplierMap.put(objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c,objSupplier);
            }//End if
            for(Rate_Card__c objRateCard :[Select P5_Supplier__r.Fax_Setup__c, P5_Supplier__r.Van_Stock__c, P5_Supplier__r.Phone1__c, 
                                            P5_Supplier__r.Supplier_Num__c, P5_Supplier__r.Name, P5_Supplier__r.Id, 
                                            P5_Supplier__c,P5_Supplier__r.Van_Stock_Value__c From Rate_Card__c Where Rate_Card_Type__c=0 
                                            And P5_Supplier__r.Type__c='Product' and P5_Supplier__r.Status_code__c='A']){
                objSupplier=new SupplierDetails();      
                objSupplier.sSupplierId=objRateCard.P5_Supplier__r.Id;
                
                objSupplier.sSupplierName=objRateCard.P5_Supplier__r.Name;
                objSupplier.blFaxEnabled=objRateCard.P5_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objRateCard.P5_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objRateCard.P5_Supplier__r.Phone1__c;
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
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Primary_Supplier__r.Phone1__c;
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
                objSupplier.sSupplierPhone=objPostCodeSector.P5_Secondary_Supplier__r.Phone1__c;
                objSupplier.blVanstock=objPostCodeSector.P5_Secondary_Supplier__r.Van_Stock__c; 
                 //vanstock change start
                objSupplier.vanStockValue = objPostCodeSector.P5_Primary_Supplier__r.Van_Stock_Value__c;
                // vanstock change end
                objSupplier.intSupplierPref=2;  
                sSecondarySuppNum=objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c;           
                m_SupplierMap.put(objPostCodeSector.P5_Secondary_Supplier__r.Supplier_Num__c,objSupplier);
            }//End if
            for(Rate_Card__c objRateCard :[Select P5_Supplier__r.Fax_Setup__c, P5_Supplier__r.Van_Stock__c, P5_Supplier__r.Phone1__c, 
                                            P5_Supplier__r.Supplier_Num__c, P5_Supplier__r.Name, P5_Supplier__r.Id, 
                                            P5_Supplier__c,P5_Supplier__r.Van_Stock_Value__c From Rate_Card__c Where Rate_Card_Type__c=0 
                                            And P5_Supplier__r.Type__c='Product' and P5_Supplier__r.Status_code__c='A']){
                objSupplier=new SupplierDetails();      
                objSupplier.sSupplierId=objRateCard.P5_Supplier__r.Id;
                
                objSupplier.sSupplierName=objRateCard.P5_Supplier__r.Name;
                objSupplier.blFaxEnabled=objRateCard.P5_Supplier__r.Fax_Setup__c;
                objSupplier.sSupplierNum=objRateCard.P5_Supplier__r.Supplier_Num__c;
                objSupplier.sSupplierPhone=objRateCard.P5_Supplier__r.Phone1__c;
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
        List<SAP_Number__c> newSAPNumberLst=new List<SAP_Number__c>{};
        sapNumberLst=new List<SAP_Number__c>{};
        sapNumberLst_Used=new List<SAP_Number__c>{};  
        newSAPNumberLst=[Select Id,SAP_Number__c,SAP_Num_Ord__c, Active__c From SAP_Number__c Where Active__c=true 
                      Order By SAP_Num_Ord__c ASC Limit 2000];
        Integer iSAPCount=0;
        
         // Defect fix for duplicate SAP numbers - starts
        
          // Pick one at random
             Integer count = 0;
             Integer size = newSAPNumberLst.size();
                
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
                        
                    sapNumberLst_Used.add(newSAPNumberLst[rdm]);  
                    alreadyTried.add(rdm);
                    count++;
                    
                } while(count < iCount);
        
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$'+purchaseOrderList.size() + ' ~~~~~~~~~~~~~~~~~~~~~~ ' + sapNumberLst.size());
        if(purchaseOrderList.size() > 0 && sapNumberLst_Used.size() >0){
            for (PurchaseOrder objPurchaseOrder:purchaseOrderList) {
                System.debug('$$$$$$$$$$$$$$$$$$$$$$$$'+objPurchaseOrder.sSAPNumber);
                if (objPurchaseOrder.getSOrderGenType()=='New') {
                    objPurchaseOrder.sSAPNumber=String.valueOf(sapNumberLst_Used[iSAPCount].SAP_Number__c);
                    sapNumberLst.add(sapNumberLst_Used[iSAPCount]);
                    for (OrderLineItem objOrderLineItem : objPurchaseOrder.orderLineItemLst){
                        objOrderLineItem.sSAPNumberCode=objPurchaseOrder.sSAPNumber+objOrderLineItem.sItemCode;     
                    }        
                    iSAPCount++;
                }
            }
        }
        for (SAP_Number__c objSAPNumber: sapNumberLst){
            objSAPNumber.Active__c=false;
        }
        if(sapNumberLst.size()>0)
        update sapNumberLst;
    }
    
    public PageReference confirmOrder(){
    
        //System.debug('rohitpanchhi');
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
            // CR User defined ASP Starts
            if(udp_UnOrderedItem!=null){
                if(udp_UnOrderedItem.size()>0){
                    List<underOrderedItem> udp_UnOrderedItem_Temp = new List<underOrderedItem>();
                    udp_UnOrderedItem_No_Supplier = new List<underOrderedItem>();
                    for(underOrderedItem udp_UnOrderedItem_Individual : udp_UnOrderedItem){
                        if(udp_UnOrderedItem_Individual.sSupplierId != null){ 
                            udp_UnOrderedItem_Temp.add(udp_UnOrderedItem_Individual);
                        }else{
                            udp_UnOrderedItem_No_Supplier.add(udp_UnOrderedItem_Individual);
                        }
                    }
                    udp_UnOrderedItem.clear();
                    udp_UnOrderedItem = udp_UnOrderedItem_Temp;
                    PurchaseOrderAmendmentHelper ph = new PurchaseOrderAmendmentHelper();
                    ph.stampSelectedSupplierOnJE(udp_UnOrderedItem, objJobUDP, udp_Supplier_Map);
                }
            }
            // CR User defined ASP Ends
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
            System.debug('%%%%%%%%%%%%%%%%%% :' + m_SelectedSupplierJobElementMap + ' ^^^^^^^^^^^^^:' + m_RateCard);
            
            if (m_SelectedSupplierJobElementMap!=null) {
                for (String sSTemp:m_SelectedSupplierJobElementMap.keySet()){
                    if (m_RateCard.containsKey(sSTemp)) {
                        System.debug('^^^^^^^^^^^^^ Just Before generation Of Order');
                        generateMaterialOrder(m_SelectedSupplierJobElementMap.get(sSTemp), sSTemp, m_RateCard.get(sSTemp)); 
                    } else {
                        System.debug('No Price Information');
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
                                System.debug(m_noPriceInformation);
                            }
                        }
                        
                    }
                }
            }
            }
            Map<String,Map<String,List<Job_Element__c>>> im_SelectedSupplierJobElementMap=new Map<String,Map<String,List<Job_Element__c>>>{};
            List<Job_Element__c> objiJEUnattended;
            Map<String,List<Job_Element__c>> im_SelectedJobElementMap =new Map<String,List<Job_Element__c>>{};
            if (im_UnOrderedItem!=null){
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
                    }else {
                        
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
            
            // User defined ASP CR starts
            // Generate the orders for the remaining user defined job elements where supplier is different.
               PurchaseOrderAmendmentHelper ph_new = new PurchaseOrderAmendmentHelper();
               ph_new.generateMaterialOrderForNewSupp(purchaseOrderList,objJobUDP,udp_UnOrderedItem);
            // User defined ASP CR Ends
            
            fetchActiveSAPNumber();
            blConfirm=true;
            
        } catch(Exception ex){
            System.debug('%%%%%%%%%%%%%%%%' + ex.getMessage());
        }
       
        return null;
      //  return new PageReference('/apex/PurchaseOrderAmendment?='+job.id);
    }
    
    public PageReference back(){
        blConfirm=false;
        for(underOrderedItem uItem : udp_UnOrderedItem_No_Supplier){
            udp_UnOrderedItem.add(uItem);
        }
        purchaseOrderList=new List<PurchaseOrder>{};
        purchaseOrderList.addAll(purchaseOrderIntermList);
        for (SAP_Number__c objSAPNumber: sapNumberLst){
                objSAPNumber.Active__c=true;
        }
        update sapNumberLst;
        return null;
    }
    private void fetchTertiarySupplier(){
        tertiarySupplierLst=new List<SelectOption>();
        //change to auto populate supplier
        if(autoPopulateSupplier){
         for (SupplierDetails objSupplier:m_SupplierMap.values()){
            if (objSupplier.intSupplierPref==3)
            //{
            //if(objSupplier.sSupplierName == 'P.T.S. Plumbing Trade Supplies Ltd')
            {
                tertiarySupplierLst.add(new Selectoption(objSupplier.sSupplierNum,objSupplier.sSupplierName));
            }  
            //}
        }
         tertiarySupplierLst.add(new Selectoption('','-None-'));
        }
        else{
        tertiarySupplierLst.add(new Selectoption('','-None-'));
        for (SupplierDetails objSupplier:m_SupplierMap.values())
        //{
            if (objSupplier.intSupplierPref==3){
            //if(objSupplier.sSupplierName == 'P.T.S. Plumbing Trade Supplies Ltd')
            {
                tertiarySupplierLst.add(new Selectoption(objSupplier.sSupplierNum,objSupplier.sSupplierName));
            }
               
            //}
        }
        }
        
    }
    
    private void fetchudp_All_Supplier_List(){
         udp_All_Supplier_List=new List<SelectOption>();
         for (Supplier__c supp:udp_AllMaterialSuppliers){
                      if(supp.Name=='P.T.S. Plumbing Trade Supplies Ltd'){
                      udp_All_Supplier_List.add(new Selectoption(supp.Supplier_Num__c,supp.Name)); 
                      
                      udp_Supplier_Map.put(supp.Supplier_Num__c,supp); 
                      udp_SuppIdNumMap.put(supp.ID,supp.Supplier_Num__c);
                      } 
            }
            udp_All_Supplier_List.add(new Selectoption('','-None-'));
            for (Supplier__c supp:udp_AllMaterialSuppliers){
                      if(supp.Name!='P.T.S. Plumbing Trade Supplies Ltd'){
                      udp_All_Supplier_List.add(new Selectoption(supp.Supplier_Num__c,supp.Name)); 
                      
                      udp_Supplier_Map.put(supp.Supplier_Num__c,supp); 
                      udp_SuppIdNumMap.put(supp.ID,supp.Supplier_Num__c); 
                      }  
    }
    
    }
    public PageReference saveOrder(){
        
         System.debug('rohitpanchhi123');
        
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
        
        // Fix for supplier branch number getting flushed out in purchase order amendment.
           String suppBranchNumber='';
       
        
        try {
            Map<String,String> supplierMap=new Map<String,String>{};
            for (String sStringTemp:m_SupplierMap.keySet()){
                supplierMap.put(m_SupplierMap.get(sStringTemp).sSupplierId,m_SupplierMap.get(sStringTemp).sSupplierNum);    
                System.debug('$$$$$$$$$$$$$$$$ :' + m_SupplierMap.get(sStringTemp).sSupplierNum);
            }
            for (String sStringTemp:l_SupplierMap.keySet()){
                supplierMap.put(l_SupplierMap.get(sStringTemp).sSupplierId,l_SupplierMap.get(sStringTemp).sSupplierNum);    
                System.debug('$$$$$$$$$$$$$$$$ :' + l_SupplierMap.get(sStringTemp).sSupplierNum);
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
            System.debug('%%%%%%%%%%%%%%%%%: ' +sSupplierNumLst);
            branchMap=objRateCard.findBranchNum(sSupplierNumLst, sRegionId, sPostCodeId);
            System.debug('%%%%%%%%%%%%%%%%%: ' +branchMap);
            List<order__c> OrderLst=new List<order__c>{};
            order__c objOrder;
            // User defined ASP Change.
            // Populate supplier branch number
            String udp_branch_computed = 'No';
             //body +='\n Line 2 '+purchaseOrderList.size()+'\n';
            for (PurchaseOrder objPurchaseOrder : purchaseOrderList) {
                suppBranchNumber = objPurchaseOrder.sSupplierBranchNum;
                System.debug('Test SAP PO ==='+objPurchaseOrder);
                if(objPurchaseOrder.sSupplierId != null && (objPurchaseOrder.sSupplierId).length() > 10){
                    objOrder=new order__c();
                    objOrder.Job__c=objJob.Id;
                    objOrder.Supplier_Fax_number__c='01784874219';
                    objOrder.Order_Date__c=objPurchaseOrder.dtOrderDt;
                    objOrder.Order_Value__c=objPurchaseOrder.dblOrderValue;
                    objOrder.SAP_Number__c=objPurchaseOrder.sSAPNumber;
                    objOrder.Supplier__c=objPurchaseOrder.sSupplierId;
                    objOrder.Type__c=objPurchaseOrder.sOrderType;
                    // CR - User defined ASP added this if condition
                   
                    
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
                    objOrder.SupplierBranchNum__c=supplierMap.get(objPurchaseOrder.sSupplierId);
                    if (branchMap.containsKey(objOrder.SupplierBranchNum__c)) {
                        objOrder.SupplierBranchNum__c=branchMap.get(objOrder.SupplierBranchNum__c);
                    } else {
                        objOrder.SupplierBranchNum__c=supplierMap.get(objPurchaseOrder.sSupplierId);
                    }
                    
                    
                 // Fix for supplier branch number getting flushed out in purchase order amendment.
                 
                    if(suppBranchNumber!=null){
                        if(suppBranchNumber.length()>1){
                            objOrder.SupplierBranchNum__c=suppBranchNumber;
                        }
                    }
                    
                 // Fix ends here.   
                    
                    
                    
                    if (objPurchaseOrder.blSync ){
                        if (objPurchaseOrder.getSOrderGenType()=='Amended'){
                            if (objPurchaseOrder.sOrderStatus=='Goods Receipted') {
                                objOrder.Status__c='Goods Receipted';
                            } else{
                                objOrder.Status__c='Amended';
                            }
                        }

                    } else {
                        if (objPurchaseOrder.getSOrderGenType()=='Amended'){
                            if (objPurchaseOrder.sOrderStatus=='Goods Receipted') {
                                objOrder.Status__c='Goods Receipted';
                            } else{
                                objOrder.Status__c='Amended';
                            }
                        }else {
                            objOrder.Status__c='Active';
                        }
                    }
                    OrderLst.add(objOrder);
                   
                   //body += objOrder.SAP_Number__c+'  ';
                }
            }
            Schema.SObjectField f = order__c.Fields.SAP_Number__c;
              //System.debug('Rohit  ==='+ OrderLst);
           Database.Upsert(OrderLst, f,false);
          //CreateEmail.CretaeSendTextEmail(new list<string>{'ashoknaglikar@hotmail.co.uk'}, body, 'Purchase Order');
            
            Set<String> sOrderIdLst = new Set<String>{};
            List<Order_Line_Item__c> orderLineItemLst=new List<Order_Line_Item__c>{};
            List<Job_Element__c> jobElementLst=new List<Job_Element__c>{};
            Order_Line_Item__c objOrderLineItemActual;
            for (order__c objOrderFinal : OrderLst) {
                sOrderIdLst.add(objOrderFinal.Id);
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
                            objOrderLineItemActual.P5_Status_c__c=objOrderLineItem.sStatus;
                            objOrderLineItemActual.P5_Type__c=objOrderLineItem.sType;
                            objOrderLineItemActual.Units__c=objOrderLineItem.dblUnits;
                            objOrderLineItemActual.Qty__c=objOrderLineItem.dblQty;
                            objOrderLineItemActual.P5_Unit_Price_c__c=objOrderLineItem.dblUnitPrice;
                            objOrderLineItemActual.Line_Item_Value__c=objOrderLineItem.dblTotalPrice;
                            objOrderLineItemActual.Skill__c=objOrderLineItem.sSkill;
                            objOrderLineItemActual.Rebate__c=objOrderLineItem.Rebate;
                            orderLineItemLst.add(objOrderLineItemActual);      
                            for (Job_Element__c objJobElement:objOrderLineItem.getSJobElementLst()){
                                objJobElement.Order__c=objOrderFinal.Id;
                                objJobElement.Sub_Status__c='Ordered';
                                objJobElement.Current_Supplier__c=objPurchaseOrder.sSupplierName;
                                objJobElement.Current_Supplier_Number__c=supplierMap.get(objPurchaseOrder.sSupplierId);
                                objJobElement.New_Supplier__c='';
                                objJobElement.New_Supplier_Number__c='';
                                if (objJobElement.Type__c=='Material'){
                                    objJobElement.Merchant_Order_Number__c=objPurchaseOrder.sSAPNumber;
                                }else if (objJobElement.Type__c=='Work'){
                                    objJobElement.Supplier_Order_Number__c=objPurchaseOrder.sSAPNumber;
                                }
                                jobElementLst.add(objJobElement);
                            }
                        }
                    }   
                }
            }

            Schema.SObjectField s = Order_Line_Item__c.Fields.Sap_Number_Item_Code__c;
              System.debug('Rohit Test123 ==='+ orderLineItemLst);
            Database.upsert(orderLineItemLst, s,false);
             update jobElementLst;
            
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
            
            for (SAP_Number__c objSapNumber: sapNumberLst) {
                objSapNumber.Active__c=false;
            }
            if(sapNumberLst.size()>0)
            update sapNumberLst;
            
            // When status of the job element is removed, and since this is purchase order amendment flow we need to remove the link between 
            // job element and order to ensure that next time same ASP removal is not considered by the purchase order amendment flow. 
            // This method takes care of this scenario.
            
            PurchaseOrderAmendmentHelper pOAH = new PurchaseOrderAmendmentHelper();
            pOAH.removeOrderLinkFromJE(objJob);
            
            // Fix - delete any orders which are being created without any job elements associated with them.
               pOAH.deleteNonJEOrders(objJob);
               pOAH.unlockJob(objJob);  
            List<Attachment> attachmentLst=[Select ParentId, Id From Attachment Where ParentId In:sOrderIdLst];
             //Job__c Job = [select Purchase_Orders__c from Job__c where Id = :objJob.Id];
            // Integer numberOfOrders = 0;
             //numberOfOrders = objJob.Purchase_Orders__r.size();
            if (attachmentLst!=null) {
                delete attachmentLst;
            }
            
             
            Pagereference pgRef=new Pagereference('/apex/FaxPageGenerate?jid=' + objJob.Id);
            pgRef.setRedirect(true);
            
            return pgRef;
            
           
         
        } catch(Exception ex) {
            Database.rollback(sp);
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% :' + ex.getMessage());
            return null;
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
   
    //Change Name Regeneration of orders while replan of job: Start-Cognizant 5 september 2013
   // Method to check whether the auto regeneration parameter is present (coming from bookjoboptionpage) and we are doing automatic click of confirm and save method on  order on amendment page to avoid manual click
    public PageReference Automaticlick()
    {
         Pagereference pgRef ;
        //system.debug('entering in the automatic click***********');
        // if there are some materials to be orders then dont stop the generation of work order. make sure that 
        //work order is generated. & display the material orders display page to user to say make him aware that there are some 
        // materials to be ordered. As in some instances all the material need not to be orderd or Delivery date might be different in some instnace.
       if(ApexPages.currentPage().getParameters().get('AutoRegeneration')=='1'  )
       {
            confirmOrder();
            pgRef = saveOrder();
            if(m_UnOrderedItem.size()!=0  || im_UnOrderedItem.size()!=0)
            {
                pgRef = new Pagereference ('/apex/PurchaseOrderAmendment?e=1&id='+objJob.Id);
                pgRef.setredirect(true);
                return pgRef;
            }
            return pgRef;
         
        }
        
        
        return null;
         
             
    }
    //change end
    
    //Change to auto populate PTS supplier
    public void onSelectAutoPopulateSupplier(){      
           autoPopulateSupplier = true;
           fetchTertiarySupplier();
           fetchudp_All_Supplier_List();
           
    }
   
   
   }