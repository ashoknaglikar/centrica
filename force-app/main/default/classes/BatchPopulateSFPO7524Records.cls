global class BatchPopulateSFPO7524Records implements Database.Batchable<SObject>{ 
    List<SFPO7524_ORDER_detail__c> SFPO7524OrderDetailsList = new List<SFPO7524_ORDER_detail__c>();
    public void GoodReceiptItems(){
        BatchPopulateSFPO7524Records batchRecObj = new BatchPopulateSFPO7524Records();
        ID batchprocessid = Database.executeBatch(batchRecObj);   
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){ 
         return Database.getQueryLocator('Select supplier__r.supplier_num__c,P5_Purchase_Order__r.CreatedDate, Code__c,id,P5_Purchase_Order__r.Quote__c,P5_Purchase_Order__r.Order_complete__c,P5_Purchase_Order__r.Active_Line_Item_Value__c,P5_Purchase_Order__r.Cancelled_Line_Item__c,o.Units__c, Quantity_Returned__c,o.Supplier__c, o.Skill__c, o.P5_Unit_Price_c__c, o.P5_Type__c,o.P5_Sub_Status_c__c, o.P5_Status_c__c, o.P5_Purchase_Order__c, o.P5_Job_Element__c, o.Description__c,P5_Purchase_Order__r.Job__r.CHI_Lead__r.CHI_Lead_Id1__c,P5_Purchase_Order__r.Goods_Receipted_On__c,Rate_Type__c From Order_Line_Item__c o Where P5_Purchase_Order__r.P5_SAP_Status__c = \'Integrated\' and  P5_Purchase_Order__r.P5_Good_Receipting_Status__c = \'Awaiting Integration\' and P5_Purchase_Order__r.Status__c=\'Goods Receipted\' and P5_Purchase_Order__r.Goods_Receipted_On__c != null  and supplier__r.supplier_num__c != \'2017\' and supplier__r.supplier_num__c != \'3163\' ');
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> sampleOrderList){
        //Calling public methods.
        System.debug('------SIZEEEEEEEEE    '+sampleOrderList.size());
        List<Order_Line_Item__c> orderItmList = new List<Order_Line_Item__c>();
        for(Sobject sObj : sampleOrderList)
        {
        	Order_Line_Item__c objLine= (Order_Line_Item__c)sObj;
        	
        	if(objLine.supplier__r.supplier_num__c==system.label.PHJones && objLine.P5_Purchase_Order__r.CreatedDate >= date.valueOf(System.Label.PHJones_Stop_Date))
        	continue;
        	
            orderItmList.add(objLine);
        }   
        if(orderItmList.size() > 0){
            this.generateOrderDetails(orderItmList);
        }
    }
    
    private void generateOrderDetails(List<Order_Line_Item__c> ordrItmList){
        Integer count=1;
       // Map<String,List<Integer>> oliCodeQtyMap = new Map<String,List<Integer>>();    
      //  Map<String,List<Integer>> qpCodeQtyMap = new Map<String,List<Integer>>();  
        Map<String,Integer> pwcMap = new Map<String,Integer>(); 
      //  Set<String> quoteIdSet = new Set<String>();
        Set<String> orderIdSet = new Set<String>();
        Set<String> codeSet = new Set<String>();
        
        for(Order_Line_Item__c oli : ordrItmList){
            if(oli.P5_Type__c == 'Work'){               
                codeSet.add(oli.Code__c);
            }
        }
       /* for(Order_Line_Item__c oli : ordrItmList){
            if(oli.P5_Type__c == 'Work'){
                if(oliCodeQtyMap.containsKey(oli.code__c)){
                    List<Integer> qtyList = oliCodeQtyMap.get(oli.Code__c);
                    qtyList.add((oli.Units__c).intValue());
                    oliCodeQtyMap.put(oli.Code__c,qtyList);
                
                }else{
                    List<Integer> qtyList = new List<Integer>();
                    qtyList.add((oli.Units__c).intValue());
                    oliCodeQtyMap.put(oli.Code__c,qtyList);
                }
                quoteIdSet.add(oli.P5_Purchase_Order__r.Quote__c); 
            }
        }
        System.debug('----oliCodeQtyMap---'+oliCodeQtyMap);
        System.debug('----quoteIdSet---'+quoteIdSet);
        
        */
       // List<Quote_Product__c> packs = [Select q.Quantity__c, q.Part_Number__c From Quote_Product__c q where BigMachines_Quote__c in :quoteIdSet and Part_Number__c in :oliCodeQtyMap.keySet()];
        
        List<Product_Work_Code__c> pwcList = [Select p.Work_Code__c,p.Product_Code__c, p.Hours__c From Product_Work_Code__c p where Start_Date__c <= :System.today() and End_Date__c >= :System.today() and Active__c = true and Work_Code__c in :codeSet];
        
        for(Product_Work_code__c wc : pwcList)
            pwcMap.put(wc.Work_Code__c , (wc.Hours__c).intValue());
        System.debug('----------pwcMap----------'+pwcMap);
       /* for(Quote_Product__c qp : packs){         
            if(qpCodeQtyMap.containsKey(qp.Part_Number__c)){
                List<Integer> qtyList = qpCodeQtyMap.get(qp.Part_Number__c);
                qtyList.add((qp.Quantity__c).intValue());
                qpCodeQtyMap.put(qp.Part_Number__c,qtyList);
            
            }else{
                List<Integer> qtyList = new List<Integer>();
                qtyList.add((qp.Quantity__c).intValue());
                qpCodeQtyMap.put(qp.Part_Number__c,qtyList);
            }       
        }
        System.debug('----qpCodeQtyMap---'+qpCodeQtyMap);
        */
        for(Order_Line_Item__c ordItm : ordrItmList){
            SFPO7524_ORDER_detail__c SFPO7524orderDetail = new SFPO7524_ORDER_detail__c(); 
 
            SFPO7524orderDetail.P5_Enquiry_Number__c = Integer.valueOf(ordItm.P5_Purchase_Order__r.Job__r.CHI_Lead__r.CHI_Lead_Id1__c);  
            if((ordItm.P5_Type__c == 'Work') && (ordItm.Rate_Type__c =='Fixed'||ordItm.Rate_Type__c =='FIXED')){
                /*Integer oliQty = ordItm.Units__c;
                
                List<Integer> qtyList = qpCodeQtyMap.get(oli.Code__c);
                for(Integer qty : qtyList){
                    finalQty +=finalQty+qty;
                    if(finalQty == oliQty){
                        SFPO7524orderDetail.P5_Receipt_Quantity__c = finalQty/(pwcMap.get(oli.Code__c));    
                    }
                }
                
                if(pwcMap.get(ordItm.Code__c) != null && pwcMap.get(ordItm.Code__c) > 0)
                    SFPO7524orderDetail.P5_Receipt_Quantity__c = (ordItm.Units__c)/(pwcMap.get(ordItm.Code__c));    
                else */
                    SFPO7524orderDetail.P5_Receipt_Quantity__c =ordItm.Units__c;
            }else{
                SFPO7524orderDetail.P5_Receipt_Quantity__c = ordItm.Units__c;//order line items unit value
            }
            SFPO7524orderDetail.P5_Unit_Price__c = ordItm.P5_Unit_Price_c__c;//unit price of order line items
            
            SFPO7524orderDetail.P5_GRN_DATE__c = ordItm.P5_Purchase_Order__r.Goods_Receipted_On__c;//good received date for Order Line items
            SFPO7524orderDetail.P5_Quantity_Returned__c = ordItm.Quantity_Returned__c;//Quantity Returned from Order Line
            SFPO7524orderDetail.P5_Order_Line_Num__c = count;
            SFPO7524orderDetail.P5_Document_Number__c = 'PREMIERE';
            if(ordItm.P5_Purchase_Order__r.Order_complete__c > 0 ) 
                SFPO7524orderDetail.P5_Complete_Indicator__c = 0; //0 = not complete / 1 = commplete 
            else if(ordItm.P5_Purchase_Order__r.Order_complete__c == 0  && (ordItm.P5_Purchase_Order__r.Active_Line_Item_Value__c >0 || ordItm.P5_Purchase_Order__r.Cancelled_Line_Item__c >0))
                SFPO7524orderDetail.P5_Complete_Indicator__c = 1; //0 = not complete / 1 = commplete 
            if(ordItm.Quantity_Returned__c != null)
                ordItm.Quantity_Returned__c = 0;
                
            if(ordItm.Quantity_Returned__c != null && ordItm.Units__c != null && ordItm.Units__c - ordItm.Quantity_Returned__c >= 0) 
                SFPO7524orderDetail.P5_Record_Status__c = 101;             
            else
                SFPO7524orderDetail.P5_Record_Status__c = 102;
 
            SFPO7524orderDetail.P5_Purchase_Order__c = ordItm.P5_Purchase_Order__c; 
            SFPO7524orderDetail.Status__c = 'Processing';  
            SFPO7524OrderDetailsList.add(SFPO7524orderDetail);
            orderIdSet.add(ordItm.P5_Purchase_Order__c);
            count++;
        }
        try{
            insert SFPO7524OrderDetailsList;
        }catch(DMLException e){
            System.debug('EXCEPTION : '+e.getMessage());
        }

        this.updateItemGRStatus(orderIdSet);
    }
    public void updateItemGRStatus(Set<String> orderIdList){
        for(SFPO7524_ORDER_detail__c ord : SFPO7524OrderDetailsList)
            ord.Status__c = 'Ready to Integrate';
        try{
            update SFPO7524OrderDetailsList;
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        List<Order__c> orderList = [select id,P5_Good_Receipting_Status__c from Order__c where id in :orderIdList];
        for(order__c ord :orderList)
            ord.P5_Good_Receipting_Status__c = 'Confirmed Processing';
         System.debug('--------------------------------------------------------------');
        try{
            update orderList;
        }catch(Exception e){
            System.debug('Exception '+e);
        }
    }

    global void finish(Database.BatchableContext BC){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'APPS-SALESFORCE-COGSupport@centrica.com'});
        mail.setReplyTo('donotreply@centrica.com');
        mail.setSenderDisplayName('Batch Processing : San-SFPO7524Order');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('&&& Batch Process has completed FOR SFPO');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}