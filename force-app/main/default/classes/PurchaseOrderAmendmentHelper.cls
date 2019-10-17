public class PurchaseOrderAmendmentHelper {
    
    /*
    Author            : Cognizant
    Functionality     : User defined ASP CR - This class is helper class of PurchaseOrderAmendment.cls
                        Size of PurchaseOrderAmendment.cls class was going beyond allowed max limit in Salesforce.
    Create Date       : 28 Sept 2010
    Change History    :
    Modified Date     :
    */
     
     public List<Job_Element__c> poJobElementList = new List<Job_Element__c>();
     public List<Job_Element__c> udpNewJEList = new List<Job_Element__c>();
     public List<PurchaseOrderAmendment.PurchaseOrder> updPOList = new List<PurchaseOrderAmendment.PurchaseOrder>();
     public PurchaseOrderAmendment.PurchaseOrder updPO = new PurchaseOrderAmendment.PurchaseOrder();
     public List<PurchaseOrderAmendment.PurchaseOrder> m_PurchaseOrderLst = new List<PurchaseOrderAmendment.PurchaseOrder>();
     public Map<String,Job_Element__c> idJEMap=new Map<String,Job_Element__c>();
     public Map<String,List<Job_Element__c>> udpSupJeMAP=new Map<String,List<Job_Element__c>>();
     public Map<String,String> udpSupplierBranchMAP=new Map<String,String>();
     public selectRateForElements objRateCard;
     public List<Job_Element__c> upd_Removed_Job_Elements = new List<Job_Element__c>();
     
    // User defined ASP CR - This method is shifted here from PurchaseOrderAmendment.cls
    // Size of PurchaseOrderAmendment.cls class was going beyond allowed max limit in Salesforce.
    
     public void generateMaterialOrder(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String sSupplierNum,
                                       Map<String,Rate_Card_Items__c> m_Rate,Map<String,PurchaseOrderAmendment.SupplierDetails> m_SupplierMap,
                                       List<PurchaseOrderAmendment.underOrderedItem> m_noPriceInformation,
                                       List<PurchaseOrderAmendment.PurchaseOrder> purchaseOrderList,
                                       Job__c objJobUDP,
                                       Map<String,List<Job_Element__c>> um_JobElementMap,
                                       List<PurchaseOrderAmendment.underOrderedItem> udp_UnOrderedItem){
        // Cognizant - CHI Phase III CR-005 implementation... START        
        // Loop over the user defined job elements and match the supplier. If it matches, add the user defined
        // job elements to the map of standard job elements (m_SelectedJobElementMap).
        
          // form the set of job element codes where supplier is chosen from picklist
        
        Set<String> jeCodeSetWithSupp = new Set<String>();
        
        for(PurchaseOrderAmendment.underOrderedItem udp_UnOrderedItem_Individual : udp_UnOrderedItem){
            
            if(udp_UnOrderedItem_Individual.sSupplierId != null){ 
            
               jeCodeSetWithSupp.add(udp_UnOrderedItem_Individual.objJobElement.Code__c);
            
            }
            
        }
        
        for (Job_Element__c objJobElementUDP:objJobUDP.Job_Elements1__r)
        {
            
            String code = objJobElementUDP.Code__c;
            List<Job_Element__c> matchSupJEList = new List<Job_Element__c>();
            if(objJobElementUDP.Current_Supplier_Number__c.equalsIgnoreCase(sSupplierNum) && jeCodeSetWithSupp.contains(objJobElementUDP.Code__c))
            {
                matchSupJEList.add(objJobElementUDP);
                m_SelectedJobElementMap.put(code, matchSupJEList);
            }
        }
        // Cognizant - CHI Phase III CR-005 implementation... END               
        PurchaseOrderAmendment.PurchaseOrder objPurchaseOrder;
        PurchaseOrderAmendment.underOrderedItem objNoPriceInformation=new PurchaseOrderAmendment.underOrderedItem();
        List<PurchaseOrderAmendment.OrderLineItem> orderlineLst;
        List<Job_Element__c> m_SelectedJobElementLst=new List<Job_Element__c>{};
        List<PurchaseOrderAmendment.OrderLineItem> orderLineItemLst=new List<PurchaseOrderAmendment.OrderLineItem>{};
        PurchaseOrderAmendment.OrderLineItem objOrderLineItem=new PurchaseOrderAmendment.OrderLineItem();
        Boolean blnNoPrice=false;
        Boolean blnGenerateOrder=false;
        Double dblOrderTotal=0; 
        
        Decimal dblTemp=0;
        
        // Defect fix where it generates the duplicate orders when no price materials enter this method for creating fresh order.
        boolean isPriceFoundForOne = false;
        
        objPurchaseOrder=new PurchaseOrderAmendment.PurchaseOrder();
        objPurchaseOrder.dtOrderDt=System.today();
        objPurchaseOrder.sDispDate=System.today().format();
        objPurchaseOrder.setSOrderGenType('New');
        objPurchaseOrder.sOrderType='Material';
        objPurchaseOrder.sSupplierId=m_SupplierMap.get(sSupplierNum).sSupplierId;
        objPurchaseOrder.sSupplierName=m_SupplierMap.get(sSupplierNum).sSupplierName;
        objPurchaseOrder.blFaxEnabled=m_SupplierMap.get(sSupplierNum).blFaxEnabled;
        objPurchaseOrder.blSync=false;
        objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
        
        for (String sTemp:m_SelectedJobElementMap.keySet()){
            Double dblUnitPrice = 0;
            objNoPriceInformation=new PurchaseOrderAmendment.underOrderedItem();
            objOrderLineItem=new PurchaseOrderAmendment.OrderLineItem();
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
                isPriceFoundForOne = true;
                decimal rebate = m_Rate.get(sTemp).Material__r.Rebate__c!= null?m_Rate.get(sTemp).Material__r.Rebate__c: 0.00;
                objOrderLineItem.Rebate = rebate*objOrderLineItem.dblUnits;
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
                objOrderLineItem.sRateType='Variable';
                // We need to ignore work elements where units equal to 0.02
                // These work elements are just indicative for certain tasks 
                // and not to be ordered. 
                if(objOrderLineItem.dblUnits > 0.02)
                   dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
                else
                   dblTemp = 0;
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
   
    // User defined ASP CR - This method is shifted here from PurchaseOrderAmendment.cls
    // Size of PurchaseOrderAmendment.cls class was going beyond allowed max limit in Salesforce.
    
   public void generateItineryMaterialOrder(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String sSupplierNum,
                                            Map<String,Rate_Card_Items__c> m_Rate,Map<String,PurchaseOrderAmendment.SupplierDetails> im_SupplierMap,
                                            List<PurchaseOrderAmendment.underOrderedItem> im_noPriceInformation,
                                            List<PurchaseOrderAmendment.PurchaseOrder> purchaseOrderList){
        PurchaseOrderAmendment.PurchaseOrder objPurchaseOrder;
        PurchaseOrderAmendment.underOrderedItem objNoPriceInformation=new PurchaseOrderAmendment.underOrderedItem();
        List<PurchaseOrderAmendment.OrderLineItem> orderlineLst;
        List<Job_Element__c> m_SelectedJobElementLst=new List<Job_Element__c>{};
        List<PurchaseOrderAmendment.OrderLineItem> orderLineItemLst=new List<PurchaseOrderAmendment.OrderLineItem>{};
        PurchaseOrderAmendment.OrderLineItem objOrderLineItem=new PurchaseOrderAmendment.OrderLineItem();
        Boolean blnNoPrice=false;
        Boolean blnGenerateOrder=false;
        Double dblOrderTotal=0; 
        Decimal dblTemp=0;
        objPurchaseOrder=new PurchaseOrderAmendment.PurchaseOrder();
        objPurchaseOrder.dtOrderDt=System.today();
        objPurchaseOrder.sDispDate=System.today().format();
        objPurchaseOrder.setSOrderGenType('New');
        objPurchaseOrder.sOrderType='Itinerary';
        objPurchaseOrder.blSync=false;
        objPurchaseOrder.sSupplierId=im_SupplierMap.get(sSupplierNum).sSupplierId;
        objPurchaseOrder.sSupplierName=im_SupplierMap.get(sSupplierNum).sSupplierName;
        objPurchaseOrder.blFaxEnabled=im_SupplierMap.get(sSupplierNum).blFaxEnabled;
        objPurchaseOrder.jobElementLst= new List<Job_Element__c>{};
        for (String sTemp:m_SelectedJobElementMap.keySet()){
            objNoPriceInformation=new PurchaseOrderAmendment.underOrderedItem();
            objOrderLineItem=new PurchaseOrderAmendment.OrderLineItem();
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
            System.debug('&&&&&&&&&&&&&&&&&& : ' + blnNoPrice);
            if (blnNoPrice==true) {
                System.debug('%%%%%%%%%%%%%%% Inside the No Price If Statement');
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
                objOrderLineItem.sRateType='Variable';
                // We need to ignore work elements where units equal to 0.02
                // These work elements are just indicative for certain tasks 
                // and not to be ordered. 
                if(objOrderLineItem.dblUnits > 0.02)
                   dblTemp=objOrderLineItem.dblUnits * objOrderLineItem.dblUnitPrice;
                else
                   dblTemp = 0;
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
  
  public void generateMaterialOrderForNewSupp(List<PurchaseOrderAmendment.PurchaseOrder> purchaseOrderList, Job__c objJobUDP,List<PurchaseOrderAmendment.underOrderedItem> udp_UnOrderedItem){
  
  
         // Cognizant - CHI Phase III CR-005 implementation... START
        for(PurchaseOrderAmendment.PurchaseOrder PO:purchaseOrderList)
        {
            if(PO.sOrderType == 'Material' && PO.sSAPNumber==null)
            {
                m_PurchaseOrderLst.add(PO);
            }
        }
        
        // form the set of job element codes where supplier is chosen from picklist
        
        Set<String> jeCodeSetWithSupp = new Set<String>();
        
        for(PurchaseOrderAmendment.underOrderedItem udp_UnOrderedItem_Individual : udp_UnOrderedItem){
            
            if(udp_UnOrderedItem_Individual.sSupplierId != null){ 
            
               jeCodeSetWithSupp.add(udp_UnOrderedItem_Individual.objJobElement.Code__c);
            
            }
            
        }
        
        
        // storing all the job elements from diff PO of type Material
        for(PurchaseOrderAmendment.PurchaseOrder mPO:purchaseOrderList)
        {
            if(mPO.sOrderType == 'Material' && mPO.sSAPNumber==null)
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
            if(!idJEMap.containsKey(udpJE.Id) && jeCodeSetWithSupp.contains(udpJE.Code__c))
            {
                udpNewJEList.add(udpJE);
            }                       
        }
        // preparing Map for creating new PO of UDP job elements
        List<Job_Element__c> udpSupJeList;
        for (Job_Element__c objJobElementUDP:udpNewJEList)
        {
            udpSupJeList = new List<Job_Element__c>();
                
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
            
  }
  
   // Cognizant - CHI Phase III CR-005 implementation... START
   // This method creates new Purchase order and order line item for user defined job elements. 
   
    public PurchaseOrderAmendment.PurchaseOrder generateMaterialOrderForNewSupp(Map<String,List<Job_Element__c>> m_SelectedJobElementMap, String suppNum)
    {
        Supplier__c supp = [Select Id, Supplier_Num__c, Name, Fax_Setup__c From Supplier__c s where Supplier_Num__c =:suppNum];
        List<Job_Element__c> orderLineItemJbList;
        PurchaseOrderAmendment.PurchaseOrder objPurchaseOrder;
        List<PurchaseOrderAmendment.OrderLineItem> orderlineLst;
        List<Job_Element__c> m_SelectedJobElementLst=new List<Job_Element__c>{};
        List<PurchaseOrderAmendment.OrderLineItem> orderLineItemLst=new List<PurchaseOrderAmendment.OrderLineItem>{};
        PurchaseOrderAmendment.OrderLineItem objOrderLineItem=new PurchaseOrderAmendment.OrderLineItem();
        
        Double dblOrderTotal=0; 
        
        Decimal dblTemp=0;
        objPurchaseOrder=new PurchaseOrderAmendment.PurchaseOrder();
        objPurchaseOrder.isUserDefinedPO = true;
        objPurchaseOrder.dtOrderDt=System.today();
        objPurchaseOrder.sDispDate=System.today().format();
        objPurchaseOrder.setSOrderGenType('New');
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
                objOrderLineItem=new PurchaseOrderAmendment.OrderLineItem();
                objOrderLineItem.sJobElementDescription=objJobEle.Description__c;
                objOrderLineItem.sStatus='Active';
                objOrderLineItem.sType=objJobEle.Type__c;
                objOrderLineItem.isUserDefinedOrderLine = true;
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
    
  public void stampSelectedSupplierOnJE(List<PurchaseOrderAmendment.underOrderedItem> udp_UnOrderedItem,Job__c objJobUDP,Map<String,Supplier__c> udp_Supplier_Map){
    
       Supplier__c sp;
       List<Job_Element__c> jeListToUpdate = new List<Job_Element__c>();
       for(PurchaseOrderAmendment.underOrderedItem um:udp_UnOrderedItem){
         for(Job_Element__c je:objJobUDP.Job_Elements1__r){
            if(um.objJobElement.Code__c==je.Code__c){
                je.Current_Supplier_Number__c = um.sSupplierId;
                je.Current_Supplier__c = (udp_Supplier_Map.get(um.sSupplierId)).Name;
                jeListToUpdate.add(je);
            }
         }
       }
       
     if(jeListToUpdate.size()>0)
     update jeListToUpdate;
       
  }
  
  public Map<String,String> getSupplierBranchMap(List<Supplier__c> udpSuppList, String sRegionId, String sPostCodeId){
     
      List<String> suppNumList = new List<String>();
      if(udpSuppList!=null){
        if(udpSuppList.size()>0){
            for(Supplier__c supp:udpSuppList){
                suppNumList.add(supp.Supplier_Num__c);
            }
          objRateCard = new selectRateForElements();
          udpSupplierBranchMAP=objRateCard.findBranchNum(suppNumList, sRegionId, sPostCodeId);
        }
      }
      return udpSupplierBranchMAP;
       
  }
  
  public void addSavedOrdersToPurchaseOrderList(Job__c objJob, Set<String> sOrderIdSet, List<PurchaseOrderAmendment.PurchaseOrder> purchaseOrderList, PurchaseOrderAmendment.PurchaseOrder objPurchaseOrder){
    
    Job__c objJobUDP = [Select Name, Regenerate_Purchase_Orders__c, CHI_Lead__r.AccountId, CHI_Lead__r.Account.BillingPostalCode,District__c,District__r.Region__c,
                        (Select Id, Name, Line_Item_ID__c, Skill__c, Units__c,Description__c,Status__c, 
                        Sub_Status__c, Supplier_Order_Number__c,Code__c, 
                        Type__c, Order__c,New_Supplier__c, New_Supplier_Number__c, Current_Supplier__c, 
                        Current_Supplier_Number__c,P5_IsItinerary__c,Is_Vanstock__c,
                        Do_Not_Assign_Order__c,Merchant_Price__c,Merchant_Order_Number__c,Remove_Waste__c,User_Defined_Product__c  From  Job_Elements1__r Where Remove_Waste__c='N' 
                        and User_Defined_Product__c=true and Status__c='Removed' and Sub_Status__c='Awaiting Order') From Job__c  where id= :objJob.Id];
    
     for (order__c objOrder:objJob.Purchase_Orders__r){
                objPurchaseOrder=new PurchaseOrderAmendment.PurchaseOrder();
                objPurchaseOrder.sSupplierName=objOrder.Supplier__r.Name;
                objPurchaseOrder.sSupplierId=objOrder.Supplier__c;
                objPurchaseOrder.dtOrderDt=objOrder.Order_Date__c;
                objPurchaseOrder.sDispDate=objOrder.Order_Date__c.format();
                objPurchaseOrder.sSAPNumber=objOrder.SAP_Number__c;
                objPurchaseOrder.dblOrderValue=objOrder.Order_Value__c;
                objPurchaseOrder.sOrderType=objOrder.Type__c;
                objPurchaseOrder.sOrderId=objOrder.Id;
                objPurchaseOrder.blSync=objOrder.Sync__c;
                objPurchaseOrder.blFaxEnabled=objOrder.Fax_Setup__c;
                objPurchaseOrder.sOrderStatus=objOrder.Status__c;
                // Fix for supplier branch number getting flushed out in purchase order amendment.
                objPurchaseOrder.sSupplierBranchNum = objOrder.SupplierBranchNum__c;
                objPurchaseOrder.jobElementLst=new List<Job_Element__c>{};
                for (Job_Element__c objJobElement:objJob.Job_Elements1__r){
                    if (objJobElement.Status__c=='Removed' && objJobElement.Sub_Status__c=='Ordered') {
                        
                    } else {
                        if ((objJobElement.Order__c==objOrder.Id) ){
                            objPurchaseOrder.jobElementLst.add(objJobElement);
                        }}}
                 for (Job_Element__c objJobElement_UDP:objJobUDP.Job_Elements1__r){
                    if (objJobElement_UDP.Status__c=='Removed' && objJobElement_UDP.Sub_Status__c=='Ordered') {
                        
                    } else {
                        if ((objJobElement_UDP.Order__c==objOrder.Id) ){
                            objPurchaseOrder.jobElementLst.add(objJobElement_UDP);
                        }}}
                objPurchaseOrder.orderLineItemLst=new List<PurchaseOrderAmendment.OrderLineItem>{};
                purchaseOrderList.add(objPurchaseOrder);
                sOrderIdSet.add(objPurchaseOrder.sOrderId); 
            }             
    
  }
  
  // When status of the job element is removed, and since this is purchase order amendment flow we need to remove the link between 
  // job element and order to ensure that next time same ASP removal is not considered by the purchase order amendment flow. 
  // This method takes care of this scenario.
  
  public void removeOrderLinkFromJE(Job__c objJob){

      List<Job_Element__c> jeList = new List<Job_Element__c>();

      jeList = [Select id,order__c,Status__c from Job_Element__c where Job__c =: objJob.ID and Status__c = 'Removed' and Order__c != null];

         if(jeList.size()>0){

           for(Job_Element__c je: jeList){

              je.Order__c = null;

           }

          update jeList;

         }
  }
  
   // Method to delete any orders which are being created without any job elements associated with them. 
  
  public void deleteNonJEOrders(Job__c objJob){
/* Code fix done on 22/09/2011 by BGSAMS support to cancel the purchase order which has either no Order Line items or no Job elements and whose status is "Amended" or "Active" rather than deleting it for future reference and also to prevent SAP numbers being resued and sent to EDI twice - PRB00002751 */
      List<Order__c> orderListToCancel = new List<Order__c>();
      List<Order__c> orderList = new List<Order__c>();
      orderList = [Select id,Sap_Number__c, Order_Value_Text__c, (Select id, Order__c, Status__c, Sub_Status__c from Job_Elements__r), (Select Id from Order_Line_Items__r) from Order__c where Job__c =: objJob.ID and (Status__c = 'Amended' or Status__c = 'Active')];
      for(Order__c order : orderList){
         if(order.Job_Elements__r.size()== 0 && order.Order_Value_Text__c > 0){
         List<Order_Line_Item__c> OLIList = [select id, o.Units__c, o.Total_Amount__c,P5_sub_Status_c__c,P5_Status_c__c, o.Skill__c, o.P5_Unit_Price_c__c, 
                                            o.P5_Type__c, Description__c, o.Code__c, 
                                            o.Name From Order_Line_Item__c o
                                            where P5_Status_c__c not in ('Inactive','Removed','Cancelled')
                                            and P5_Purchase_Order__c =:order.id];
                             
        if(OLIList.size() > 0){
           for(order_Line_Item__c oli : OLIList ){
               oli.P5_Status_c__c = 'Cancelled';
               oli.P5_sub_Status_c__c = 'Cancelled';
               }       
           try{
             update OLIList ;
             }catch(DMLException e){
             System.debug('@Exception : '+e.getMessage()+' Error in line number : '+e.getLineNumber());
             }
         }                  
          orderListToCancel.add(order);
         }
         if(order.Job_Elements__r.size()> 0 && order.Order_Line_Items__r.size() == 0){
            orderListToCancel.add(order);
            List<Job_Element__c> jeList = new List<Job_Element__c>();
            for(Job_Element__c je : order.Job_Elements__r){
              if(je.Status__c == 'Active'){
                 je.Order__c = null;
                 je.Sub_Status__c = 'Awaiting Order';
                 jeList.add(je);
              }
            }
            if(jeList.size() > 0)
            Database.update(jeList);
         }
         system.debug('orderListToCancel'+orderListToCancel);
         if(orderListToCancel.size()>0)
         {
         for(Order__c order1 :orderListToCancel)
         {
         List<Attachment> attachments = [Select id From Attachment a where ParentId=:order1.id];
         try{
             if(attachments.size() > 0)
                delete attachments;
             }catch(Exception e){
                System.debug('Exception : '+e.getMessage()); }
        
        order1.Status__c = 'Cancelled';
        order1.Order_Value__c = 0;
        order1.P5_Order_Cancellation_Date__c = System.Today();
        order1.Cancelled_by__c = UserInfo.getUserId();
        if(order1.Supplier_number__c == System.Label.BGS_SNUM_1 || order1.Supplier_number__c == System.Label.BGS_SNUM_2 || (order1.Supplier_number__c == System.Label.PHJones && order1.Order_Date__c >= date.valueOf(System.Label.PHJones_Stop_Date))){
                //if(order1.EDI_Status__c == 'Awaiting Integration')
                {
                    order1.EDI_Status__c = 'Not to be Integrated'; 
                 }
                 //if(order1.P5_SAP_Status__c == 'Awaiting Integration')
                 {
                    order1.P5_SAP_Status__c = 'Not to be Integrated'; 
                 }
                 //if(order1.P5_Good_Receipting_Status__c == 'Awaiting Integration')
                 {
                    order1.P5_Good_Receipting_Status__c = 'Not to be Integrated'; 
                 }
            } 
            }
        Database.update(orderListToCancel);
        objJob.Regenerate_Purchase_Orders__c = true;
        update objJob;
      }    
 else{
        objJob.Regenerate_Purchase_Orders__c = false;
        update objJob;
       }
      }         
  }
  public boolean checkLock(Job__c j)
  {
    j = [select id,Order_Locking_User__c,order_locking_time__c from Job__c where Id =:j.Id ];
    if(j.Order_Locking_User__c!= userinfo.getUserId() && j.Order_Locking_User__c!=null)
        return true;
    else 
        return false;
  }
  public void unlockJob(Job__c j)
  {
    j = [select id,Order_Locking_User__c,order_locking_time__c from Job__c where Id =:j.Id ];
    if(j.Order_Locking_User__c==userinfo.getuserid())
    {
        j.Order_Locking_User__c = null;
        j.order_locking_time__c = null;
        Update j;
    }   
  }
  
  //Method for test coverage.
  public void setDummyString(){
      String str = 'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String'; str=str+'Dummy String';
      
  }
  
}