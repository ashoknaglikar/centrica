/*
* CLASS - DispatchOrdertoEDI 
* AUTHOR - COGNIZANT
* PURPOSE - The Purpose of this class is to use the batch apex functionality to bulk process orders and send those 
* to EDI Interface 
*/ 
global class DispatchOrdertoEDI implements Database.Batchable<sObject>{  
  public Map<String,boolean> exceptionMap = new Map<String,boolean>();
  String result = '';
  List<Order__c> orderList =new List<Order__c>(); 
  List<SFED7542_Batch__c> orderBatchList = new List<SFED7542_Batch__c>();
  Map<String,String> tran_codeMap = new Map<String,String>();
  Map<String,String> ordDetAndTrnsMap = new Map<String,String>();
  
  public void createOrderBatch(){
      DispatchOrdertoEDI objSendOrder = new DispatchOrdertoEDI();
      // Defect fix for EDI interface - Number of SOQL goes beyond 200 if batch size is 200
      ID batchprocessid = Database.executeBatch(objSendOrder,150);
  }

  /*
  *  Input - Current Btch Context
  *  Output - Query Set
  *  Purpose - retrieves the query set to be processed by the current & future batches 
  */  
  global Database.QueryLocator start(Database.BatchableContext BC){
     // Change - Send Merchant Orders To Installation Address on Account - Added a field in below query called Job__r.Account_Id__c
        return Database.getQueryLocator('Select Name,P5_Number_Of_Line_Items__c,batch_created__c,Amendment_Number_sent__c,Amendment_Number__c,Job__r.CHI_Lead__r.Address_Number__c,Job__r.CHI_Lead__r.Address_Number_EDI__c,Synched_to_EDI__c,EDI_Setup__c,id,Delivery_Date_Changed__c,Topcall_Fax_Status__c,supplier__r.P5_Order_Lead_Time__c,supplier__r.EDI_Tolerance_Value__c,Supplier_Communication_Preference__c,Job_Delivery_Date__c,Job__r.Delivery_Date__c,CreatedDate,Returned_Items__c,Amendment_Synched__c,Amended__c,supplier__r.name,Status__c,EDI_Status__c,SupplierBranchNum__c,Supplier__r.Supplier_Num__c,Order_Note__c,SAP_Number__c,supplier__c,Sync__c,Job__r.Delivery_Notes__c,Job__r.Installation_date__c,Job__r.Primary_Contact__c,Supplier__r.ANA_Number__c,LastModifiedBy.Name,LastModifiedBy.Phone,Delivery_Slot__c,Job__r.Account_Id__c from Order__c where EDI_Status__c=\'Awaiting Integration\' and (Type__c = \'Material\' or (Type__c = \'Itinerary\' and Supplier__r.Type__c = \'Product\')) and Job__c != null and supplier__c != null and P5_Number_Of_Line_Items__c > 0 and supplier__r.supplier_num__c != \'2017\' and supplier__r.supplier_num__c != \'3163\' ' );
        //return Database.getQueryLocator('Select Name,P5_Number_Of_Line_Items__c,batch_created__c,Amendment_Number_sent__c,Amendment_Number__c,Job__r.CHI_Lead__r.Address_Number__c,Job__r.CHI_Lead__r.Address_Number_EDI__c,Synched_to_EDI__c,EDI_Setup__c,id,Delivery_Date_Changed__c,Topcall_Fax_Status__c,supplier__r.P5_Order_Lead_Time__c,supplier__r.EDI_Tolerance_Value__c,Supplier_Communication_Preference__c,Job_Delivery_Date__c,Job__r.Delivery_Date__c,CreatedDate,Returned_Items__c,Amendment_Synched__c,Amended__c,supplier__r.name,Status__c,EDI_Status__c,SupplierBranchNum__c,Supplier__r.Supplier_Num__c,Order_Note__c,SAP_Number__c,supplier__c,Sync__c,Job__r.Delivery_Notes__c,Job__r.Installation_date__c,Job__r.Primary_Contact__c,Supplier__r.ANA_Number__c,LastModifiedBy.Name,LastModifiedBy.Phone,Delivery_Slot__c,Job__r.Account_Id__c from Order__c where id =\'a1HP0000000RwML\'');
  } 
  /*
  * This method inputs all the eligible orders that are to be sent and process it against the Communication preference table
  * Based on primary or secondary pref a List of orders specific to be sent to Topcall or EDI is returned
  */
  // Added : 14 July : Include the changes for communication preference status
  public List<Order__c> populateComStatus(List<Order__c> lstRecords){
       // List<Order__c> orderList = new List<Order__c>();
        Map<String,Order__c> orderMap = new Map<String,Order__c>();
        Set<String> branchesSet = new Set<String>();
        Map<String,String> ordTypeMap = new Map<String,String>();
        Integer daysBetween =0;
        for(Order__c odrObj : lstRecords){              
            String orderType=''; 
            /*
                I Initial Order : A Order Amendment  :  R Order Return  :  X Order Cancellation  :  N Notification  :  P RE-PLAN NOTICE
            */
            System.debug('################   '+odrObj.Amendment_Number__c +':'+odrObj.Returned_Items__c +':'+odrObj.Status__c+':'+odrObj.Delivery_Date_Changed__c);
            if(odrObj.Amendment_Number__c ==1 && odrObj.Status__c <> 'Cancelled') 
                orderType='I'; 
            else if(odrObj.Returned_Items__c != null && odrObj.Returned_Items__c > 0 && odrObj.Amendment_Number__c > 1 && odrObj.Status__c != 'Cancelled')
                orderType='R';
            else if(odrObj.Status__c == 'Cancelled') 
                orderType='X';
            else if(odrObj.Delivery_Date_Changed__c && odrObj.Amendment_Number__c > 1)
                orderType='P';
            else if(odrObj.Amendment_Number__c > 1) 
                orderType='A';  
            else
                orderType='N'; // never used - confirmed by amit agarwal(Steria)        
            
                
            ordTypeMap.put(odrObj.id,orderType);
            branchesSet.add(odrObj.SupplierBranchNum__c);   
            orderMap.put(odrObj.id,odrObj);
            
        }  
        System.debug('----ordTypeMap & branchesSet & orderMap--------'+ordTypeMap +'   : ' +branchesSet+'   :   '+orderMap);
        List<Communication_Preference__c> commprefList = [Select order_type__c,Supplier_Branch__r.Branch_Num__c,c.Secondary_Destination__c, c.Primary_Destination__c 
                                From Communication_Preference__c c where 
                                Supplier_Branch__r.Branch_Num__c in :branchesSet and Order_Type__c in :ordTypeMap.values()];
        List<Communication_Preference__c> tempPrefLst;
        Map<String,List<Communication_Preference__c>> branchPrefMap = new Map<String,List<Communication_Preference__c>>();
        for(String branch : branchesSet){
            tempPrefLst = new List<Communication_Preference__c>();
            for(Communication_Preference__c compref : commprefList){
                if(branch == compref.Supplier_Branch__r.Branch_Num__c){
                    tempPrefLst.add(compref);
                }   
            }
            if(tempPrefLst.size() > 0)
                branchPrefMap.put(branch,tempPrefLst);
        }
        System.debug('----branchPrefMap -----'+branchPrefMap);
        // checking for exclusion criterions
        List<Order__c> onlyUpdate = new List<Order__c>();
        for(Order__c odrObj : lstRecords){          
            String orderType = ordTypeMap.get(odrObj.id);
            
            
            String primPrefType='';
            String secPrefType='';
            List<Communication_Preference__c> prefLst = branchPrefMap.get(odrObj.SupplierBranchNum__c);
            
            if(prefLst != null){
                for(Communication_Preference__c pref  : prefLst){
                    if(pref.order_type__c == (orderType)){
                        primPrefType = pref.Primary_Destination__c;
                        secPrefType = pref.Secondary_Destination__c;
                        break;
                    }
                }               
            }
            System.debug('----primPrefType -----'+primPrefType);
            System.debug('----secPrefType -----'+secPrefType);
            if((odrObj.supplier__r.Supplier_Num__c)!= '2017'){
                System.debug('Supplier not British Gas ...');
                Decimal leadTime =odrObj.supplier__r.P5_Order_Lead_Time__c;
                Decimal ediTolerance =0;
                if(odrObj.supplier__r.EDI_Tolerance_Value__c != null)                   
                    ediTolerance = odrObj.supplier__r.EDI_Tolerance_Value__c;
                if(odrObj.Job_Delivery_Date__c!=null)   
                daysBetween = (System.today()).daysBetween(odrObj.Job_Delivery_Date__c);
                 System.debug('daysBetween -->'+daysBetween);
                 
                //Date firstDayOfTheYear = Date.newInstance((System.today()).Year(),1,1);
                List<Business_Holiday__c> holidays = new List<Business_Holiday__c>();
                
                if(odrObj.Job_Delivery_Date__c > System.today()){
                    holidays = [Select b.Holiday_On__c, b.Description__c, b.Country_Code__c, b.Active__c 
                                                    From Business_Holiday__c b where Holiday_On__c < :odrObj.Job_Delivery_Date__c and Holiday_On__c > today and Active__c = true and Country_Code__c='ENG'];
                }else{
                    holidays = [Select b.Holiday_On__c, b.Description__c, b.Country_Code__c, b.Active__c 
                                                    From Business_Holiday__c b where Holiday_On__c < today and Holiday_On__c > :odrObj.Job_Delivery_Date__c and Active__c = true and Country_Code__c='ENG'];
                }
                  
                
                if(holidays.size() > 0){ 
                    if(daysBetween < 0)
                        daysBetween = daysBetween + (holidays.size());
                    else
                        daysBetween = daysBetween - (holidays.size());
                }
                System.debug('HOLIDAY '+holidays);                  
                System.debug('DEL DATE '+odrObj.Job_Delivery_Date__c+' @ DAYSBTWEEN after@'+daysBetween +'@ EDI TOLERANCE '+ediTolerance.intValue());
                System.debug('PREFERENCE primary = : '+primPrefType);
                System.debug('PREFERENCE = : '+primPrefType);
                //
                //Priyanka : 
                /*
                1) It checks and use the lead time of the supplier first and use the logic of (delivery date - supplier lead time)  < sysdate. 
                If the value is true then it will proceed further even if delivery date is less than or equal to current date. 
                   If it is false then it will go the point 6.
                2) On the basis of different order types (A, I , R, N, P) it finds the Primary and secondary destination of the supplier order
                    without looking into the value of EDI tolerance or EDI set up flag. 
                3) It then uses the concept of EDI tolerance -
                It finds the number of working days between delivery date of the order and the current date (If deliver date >= current date). 
                It excludes the Saturday, Sunday and holidays defined for the country code.
                if the count found at Step 4 is less than EDI tolerance value for the supplier then the orders need to go to the secondary destination.
                4) It then uses the concept of EDI setup flag [If the value of EDI setup flag = 1 then send to the secondary destination.].
                5) On the basis of destinations worked out at point 2 , 3 & 4 data is sent to the supplier.
                    Please note that point 3 & 4 only use the concept of secondary destination else for all other cases it 
                    go the Primary destination found at point 2 irrespective of delivery date.
                6) Exit from the logic 
                                */ 
                //
                System.debug('Checking for =================   '+odrObj.id);
                if(((System.today()).addDays(leadTime.intValue())) >= (odrObj.Job_Delivery_Date__c)){
                    System.debug('###########################  step 1 ');
                // if((odrObj.Job_Delivery_Date__c - leadTime) <= System.today())){
                   // if(odrObj.Job_Delivery_Date__c <= System.today()){
                        System.debug('###########################  step 2 ');
                        //if(daysBetween < 0){
                            //daysBetween *= (-1);
                            if(daysBetween !=null){
                            if(daysBetween > 0 && daysBetween < ediTolerance){
                                System.debug('###########################  step 3 ');
                                odrObj.Supplier_Communication_Preference__c = secPrefType;
                                odrObj.EDI_Status__c = 'Secondary Preference Selected';
                                onlyUpdate.add(odrObj);
                            }else{
                                if(odrObj.EDI_Setup__c == '0'){
                                    System.debug('###########################  step 4 ');
                                    if(primPrefType == 'E' || primPrefType == 'e')
                                        orderList.add(odrObj);
                                    else{
                                        System.debug('###########################  step 5 ');
                                        odrObj.Supplier_Communication_Preference__c = secPrefType;
                                        odrObj.EDI_Status__c = 'Secondary Preference Selected';
                                        onlyUpdate.add(odrObj);
                                    }
                                }
                                else{
                                    System.debug('###########################  step 6 ');
                                    odrObj.Supplier_Communication_Preference__c = secPrefType;
                                    odrObj.EDI_Status__c = 'Secondary Preference Selected';
                                    onlyUpdate.add(odrObj);
                                }
                            }
                            }
                        //}
                   // }
                }
            }
        }
                
        if(onlyUpdate.size() > 0){
            try{
                update onlyUpdate;
            }catch(Exception e){
            //alert mail fix start
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('donotreply@centrica.com');
                mail.setSenderDisplayName('DispatchOrdertoEDI - order');
                mail.setSubject('Batch Process Failure - order');
                mail.setPlainTextBody('DispatchOrdertoEDI has an exception while updating order:#'+e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             //alert mail fix start
            }
        }
       return orderList;    
  }
  /*
  *  Input - current batch context and list of ecords to process
  *  Output - None
  *  Purpose - processes the orders and caretes batch objects and then makes call to methods to create subsequent records
  */ 
  global void execute(Database.BatchableContext BC, List<sObject> lstRecords){  
        
        
        List<Order__c> tempOrders = new List<Order__c>();
        for(sObject sObj : lstRecords)
            tempOrders.add((Order__c)sObj);
            
        orderList = this.populateComStatus(tempOrders); 
        System.debug('--orderlist size --'+orderList);
        if(orderList.size() > 0){
            
            Map<String,List<order__c>> batchSuppOrderMap = new Map<String,List<order__c>> ();
            Set<String> suppIdSet = new Set<String>();
            Map<String,Order__c> exceptionOrdMap = new Map<String,Order__c>();
            
            for(Order__c order : orderList)
                suppIdSet.add(order.supplier__c);
                
            Map<String,Order__c> orderMap = new Map<String,Order__c>();
            for(Order__c ordr : orderList){
                String supp = ordr.supplier__c;
                String s_code = '';
                if(ordr.Amendment_Number__c ==1 && ordr.Status__c <> 'Cancelled' ){
                  s_code = '0430';
                  exceptionOrdMap.put(ordr.id,ordr);
                }
                else if(ordr.Status__c == 'Cancelled'){
                  s_code = '0400';
                  exceptionOrdMap.put(ordr.id,ordr);
                }
                  else{
                     s_code = '0440';
                     exceptionOrdMap.put(ordr.id,ordr);
                  }
                if(!tran_codeMap.containsKey(supp+':'+s_code)){
                    tran_codeMap.put(supp+':'+s_code,s_code);
                }
                 orderMap.put(ordr.id,ordr);       
            }
            
            
            
           
            System.debug('--OrderMap ---- '+orderMap+' : exceptionOrdMap : '+exceptionOrdMap);
            // calling method to check if initial order batch is created ot not
            /* ********************   added on : 29 july   ********************** */
            
            
            /*if(exceptionOrdMap.size() > 0 )
                exceptionMap = this.checkInitialOrderExist(exceptionOrdMap);
            System.debug('####  exceptionMap ####'+exceptionMap);
            */
            List<Order__c> tempOList = new List<Order__c>();
            for(Order__c ord : orderList){
                if((ord.batch_created__c == false && ord.Amendment_number__c > 1) || 
                   (ord.batch_created__c == false && ord.Amendment_number__c == 1 && ord.status__c == 'Cancelled') ){
                    
                    tempOList.add(ord);
                }
            }
            Set<String> oids = new Set<String>();
            
            for(Order__c ord : tempOList){
                exceptionMap.put(ord.id,false);
                oids.add(ord.id);
            }
            
            if(tempOList.size() > 0)
                orderList.addAll(tempOList);  
            
            for(Order__c ordin : orderList){
                if(!(oids.contains(ordin.id))){
                    exceptionMap.put(ordin.id,true);
                }
            }
            
            for(String str : exceptionMap.keyset()){
                Order__c tempOrd = orderMap.get(str);
                if(exceptionMap.get(str) == false ){
                    tran_codeMap.put(tempOrd.Supplier__c+':0430','0430');
                    orderList.add(tempOrd);
                }
            }
            System.debug('####  1 ####'+tran_codeMap);
            System.debug('####  2 ####'+orderList);
            
            for(String supp : suppIdSet){
                List<Order__c> orderListTemp = new List<Order__c>();
                for(Order__c ordr : orderList){
                    if(ordr.supplier__c == supp){
                        orderListTemp.add(ordr);
                    } 
                }
                batchSuppOrderMap.put(supp,orderListTemp);           
            }
             System.debug('####  23 ####'+batchSuppOrderMap);
            Map<String,String> batchSuppKeyMap = new Map<String,String>();
            
            for(String supp : tran_codeMap.keySet()){            
                SFED7542_Batch__c orderBatchObj = new SFED7542_Batch__c();
                String[] s_SupplierLst = supp.split(':');
                System.debug(': 1 :' +s_SupplierLst[0] +' : '+s_SupplierLst[1]);
                orderBatchObj.Supplier__c = s_SupplierLst[0];// supplier of the order
                orderBatchObj.Trnx_Code__c = s_SupplierLst[1];
                orderBatchObj.Status__c = 'Processing';
                orderBatchList.add(orderBatchObj);  
                  
            }
    
            try{
                System.debug('@ batches :    @'+orderBatchList);
                insert orderBatchList;
                
                
                Map<String,String> batchIdSuppKey = new Map<String,String>();
                
                for(SFED7542_Batch__c tempB: orderBatchList){
                    String s_cod_batch = tempB.Supplier__c +':'+tempB.Trnx_Code__c;
                    batchSuppKeyMap.put(s_cod_batch,tempB.id);
                }
                result = 'success';
                System.debug('# checkpoint 1 :[batch\'s supplier id:0440,batch id ] '+batchSuppKeyMap);
            }catch(Exception e){
                System.debug('@Exception creating batch @ '+e);
                //alert email fix start
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('donotreply@centrica.com');
                mail.setSenderDisplayName('DispatchOrdertoEDI - order');
                mail.setSubject('Batch Process Failure - order');
                mail.setPlainTextBody('Exception creating batch:#'+e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             //alert email fix start
                result = 'error';
                return;
                
                
            }
            this.createBatchOrder(batchSuppKeyMap,batchSuppOrderMap);
        }
    }
     //1st Arg : [MAP[batch's supplier id:0440,batch id ]]
     //2nd Arg : [MAP[supp id,(o1,o2)]]
     // This method should create batchSuppKeyMap.size() number of order header each linked to individual batch header
  

    public void createBatchOrder(Map<String,String> batchSuppKeyMap,Map<String,List<order__c>> batchSuppOrderMap ){
        List<SFED7542_Order__c> batchOrderList = new List<SFED7542_Order__c>();
        for(String str : batchSuppKeyMap.keySet()){
        
            String btchIds = batchSuppKeyMap.get(str);// gets the Batch Id
            String s_trnascode = str.split(':')[1]; // gets the transaction code : 0440,0400,0430

            SFED7542_Order__c batchOrderObj = new SFED7542_Order__c();
            //CUSTOMER’S ANA AND ID LOCATION CODE.
            batchOrderObj.Customer_EAN_Location_Number__c = System.Label.Customer_ANA_Code; 
            batchOrderObj.Customer_Id_allocated_by_Supplier__c = System.Label.CUSTOMER_ID; //British Gas operating unit will be identified in this sub element :pseudo ANA code
            //SUPPLIER'S ANA AND ID LOCATION CODE.
            
           // SETTING REFERENCES
            
            batchOrderObj.SFED7542_Batch__c = btchIds ;// BATCH TO WHICH THE ORDER HEADER IS LINKED TO
            batchOrderObj.Supplier__c = str.split(':')[0];
            batchOrderObj.File_Created_On__c = System.today();
            batchOrderObj.Transanction_Code__c = s_trnascode;
        
            batchOrderList.add(batchOrderObj);
        }
        try{
            
            insert batchOrderList;
            
            result = 'success';
            List<SFED7542_Order_Details__c> orderDetailsList = this.createOrderDetails(batchOrderList,batchSuppOrderMap,tran_codeMap);
            this.createOrderSubDetails(orderDetailsList,batchSuppOrderMap);
            result = 'success';
            this.updateEDItatus(batchSuppOrderMap.values());
        }catch(Exception e){
            System.debug('@Exception creating order batch @ '+e);
            //alert email fix start
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('donotreply@centrica.com');
                mail.setSenderDisplayName('DispatchOrdertoEDI - order');
                mail.setSubject('Batch Process Failure - order');
                mail.setPlainTextBody('Exception creating order batch:#'+e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             //alert email fix start
            result = 'error';
            return;
            
        }
        
    }
    // Arg 1 : [order header id 1 , order header id 2, ...]
    // Arg 2 : [MAP[supp id,(o1,o2)]]
    // Arg 3 : [(suppid:0400, 0400),(suppid:0440,0440),.....]
    // this should create all orders per trans code basis under order header

    public List<SFED7542_Order_Details__c> createOrderDetails(List<SFED7542_Order__c> orderHeader,Map<String,List<order__c>> batchSuppOrderMap,Map<String,String> trancodeMap ){

        Set<string> contactSet = new Set<string>();
       
        // Change - Send Merchant Orders To Installation Address on Account
        Set<string> accountSet = new Set<string>();
        Map<String,Account> accountMap = new Map<String,Account>();
        
        Map<String,Contact> contactMap = new Map<String,Contact>();
        List<SFED7542_Order_Details__c> orderDetailsList = new List<SFED7542_Order_Details__c>();
        
        System.debug('@orderHeader '+orderHeader +'@ = @'+trancodeMap +'@ =BIGGIE @'+batchSuppOrderMap);

        for(Order__c odr : orderList){
            contactSet.add(odr.Job__r.Primary_Contact__c);
            accountSet.add(odr.Job__r.Account_Id__c);
        }
        
        List<Contact> contactDetails = [Select id,c.Phone, c.Name, OtherPhone,LastName,Salutation,Title,c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingCountry, c.MailingCity, c.HomePhone, c.Fax, c.Email From Contact c where id in : contactSet];
        
        // Change - Send Merchant Orders To Installation Address on Account
        List<Account> accountDetails = [Select a.ID, a.BillingPostalCode, a.BillingStreet, a.BillingCity, a.BillingState, a.BillingCountry from Account a where ID in :accountSet];
        for(Account acc : accountDetails){
            String s_tempAid = (String.valueOf(acc.id)).subString(0,15);
            accountMap.put(s_tempAid,acc);
        }
        
        for(Contact cont : contactDetails ){
            String s_tempCid = (String.valueOf(cont.id)).subString(0,15);
            contactMap.put(s_tempCid,cont);
        }
        Set<String> tempSet = new Set<String>();
        Set<String> temp2Set = new Set<String>();
        System.debug('IMPPPPPPPPPPPPP' +orderList.size());
        //batchSuppOrderMap :[S1-(O1,O2),S2-(O3),S3-(O4,O5)]  
        System.debug('-----orderHeader-----'+orderHeader);  
       
        for(SFED7542_Order__c header : orderHeader){ 
            System.debug('####outer#######################################');             
            for(Order__c orderObj : orderList){
                
                System.debug('---iterating --orderObj-----'+orderObj);  
                boolean createExtra = exceptionMap.get(orderObj.id);
                boolean entered = false;
                String s_code ='';
                System.debug('@createExtra == @'+createExtra+'¬¬¬¬¬¬¬¬¬¬¬¬'+orderObj.id+'@@@@'+tempSet);
                if(createExtra == false && header.Transanction_Code__c != '0430' && !(tempSet.contains(orderObj.id))){
                    System.debug('hreeeeeeeeeeeeeeeeeeeeeee');
                    if(orderObj.Amendment_Number__c == 1 && orderObj.Status__c <> 'Cancelled' )
                      s_code = '0430';
                    else if(orderObj.Status__c == 'Cancelled')
                      s_code = '0400';
                      else
                         s_code = '0440';
                    tempSet.add(orderObj.id);
                }else{
                    if(createExtra == true){
                        System.debug('hreeeeeeeeeeeeeeeeeeeeeee 111111111');
                        if(orderObj.Amendment_Number__c == 1 && orderObj.Status__c <> 'Cancelled')
                          s_code = '0430';
                        else if(orderObj.Status__c == 'Cancelled')
                          s_code = '0400';
                          else
                             s_code = '0440';
                             entered = true;
                             
                    }else{
                        if(createExtra == false && header.Transanction_Code__c == '0430' && !(temp2Set.contains(orderObj.id))){
                             System.debug('hreeeeeeeeeeeeeeeeeeeeeee  2222222222');
                             s_code = '0430';   
                             temp2Set.add(orderObj.id);
                             entered = true;
                        }else{
                            s_code='';
                        }
                    }
                }
                
                if((header.Transanction_Code__c  == '0430' && entered == true && s_code == header.Transanction_Code__c && orderObj.supplier__c == header.Supplier__c) ||
                (header.Transanction_Code__c  != '0430' && s_code == header.Transanction_Code__c && orderObj.supplier__c == header.Supplier__c)){
                    System.debug('REC CREATED>>>>>>>>>>>>>>>>>>>>>>>>>>');
                    //entered = false;
                    SFED7542_Order_Details__c orderDetailsObj = new SFED7542_Order_Details__c(); 
                    
                    
                    if(orderObj.Amendment_Number_sent__c != null && orderObj.Status__c == 'Cancelled'){
                        orderDetailsObj.Amendment_Number_Synched__c = orderObj.Amendment_Number_Sent__c; 
                    }
                    else if(orderObj.Amendment_Number_sent__c != null && orderObj.Amendment_Number__c > orderObj.Amendment_Number_sent__c)
                        orderDetailsObj.Amendment_Number_Synched__c = orderObj.Amendment_Number_Sent__c+1;
                    else
                        orderDetailsObj.Amendment_Number_Synched__c = orderObj.Amendment_Number__c;
                            
                    
                                                
                    Contact contactObj = contactMap.get(orderObj.Job__r.Primary_Contact__c);
                    
                    // Change - Send Merchant Orders To Installation Address on Account
                    Account accountObj = accountMap.get(orderObj.Job__r.Account_Id__c);
                    System.debug('Order Name is : '+orderObj.Name);
                    // SETTING CONTACT DETAILS
                    
                    // Change - Setting Account Install Address Instead of Contact Mailing Address - Starts
                    if(accountObj.BillingCity != null)
                        orderDetailsObj.City__c = accountObj.BillingCity;
                    if(accountObj.BillingCountry != null)
                        orderDetailsObj.Country__c = accountObj.BillingCountry;
                    if(accountObj.BillingState != null)
                        orderDetailsObj.County__c = accountObj.BillingState;
                    if(accountObj.BillingPostalCode != null)
                        orderDetailsObj.Post_Code__c = accountObj.BillingPostalCode;
                    if(accountObj.BillingStreet != null && (accountObj.BillingStreet).length() > 35)
                        orderDetailsObj.Street__c = (accountObj.BillingStreet).subString(0,35);
                    else if(accountObj.BillingStreet != null)
                        orderDetailsObj.Street__c = accountObj.BillingStreet;
                    // Change - Setting Account Install Address Instead of Contact Mailing Address - Ends
                         
                    // SETTING CUSTOMER PERSONAL DETAILS
                    if(contactObj.Salutation == null){
                        if(contactObj.Title == null){
                            orderDetailsObj.Customer_Name__c = contactObj.LastName;
                         }else{
                             orderDetailsObj.Customer_Name__c = contactObj.Title+' '+contactObj.LastName;
                         }
                    }
                    else{                
                        orderDetailsObj.Customer_Name__c = contactObj.Salutation+' '+contactObj.LastName;
                    }
                    //PRB00034304
                    
                    if((orderDetailsObj.Customer_Name__c != null)&&(orderDetailsObj.Customer_Name__c.length()>=39)){
                    system.debug(LoggingLevel.info,'orderDetailsObj.Customer_Name__c length'+orderDetailsObj.Customer_Name__c.length());
                    orderDetailsObj.Customer_Name__c = orderDetailsObj.Customer_Name__c.substring(0,39);
                    }
                    if(contactObj.HomePhone != null && contactObj.HomePhone != '')
                        orderDetailsObj.Customer_Telephone_Number__c = contactObj.HomePhone;
                    else
                        orderDetailsObj.Customer_Telephone_Number__c = 'No Phone';
                        
                    orderDetailsObj.Customer_Work_Telephone_Number__c = contactObj.OtherPhone == null?'No Phone' : contactObj.OtherPhone ;
                    //FOR INITIAL ORDERS, THIS IS DERIVED FROM JOB.DELIVERY_INSTRUCTION.FOR SUBSEQUENT AMENDMENTS, FROM ORDER.NOTE
                    String[] s_delInstn = new String[5];
                    String s_delNote = '';
                    system.debug('s_code ::: '+s_code);
                    if((createExtra == false && s_code == '0430') || (createExtra == true && s_code == '0430')){
                      if(orderObj.Delivery_Slot__c != null && orderObj.Job__r.Delivery_Notes__c != null)
                        s_delNote = orderObj.Delivery_Slot__c+' : '+ orderObj.Job__r.Delivery_Notes__c;
                      else if(orderObj.Delivery_Slot__c != null && orderObj.Job__r.Delivery_Notes__c == null)
                        s_delNote = orderObj.Delivery_Slot__c;
                      else if(orderObj.Delivery_Slot__c == null && orderObj.Job__r.Delivery_Notes__c != null)
                        s_delNote = orderObj.Job__r.Delivery_Notes__c;
                    }
                    else {  
                        s_delNote = orderObj.Order_Note__c;                                     
                    }
                    system.debug('s_delNote ::: '+s_delNote);
                    if(s_delNote != '' && s_delNote != null){/* Code change done by BGSAMS Support on 1-11-2011 as a part of PRB00005449 to populate the delivery instruction1 and 2. */
                        for(integer j = 0,i=39; j<4 ; j++){
                            if(s_delNote.length() > 40 && s_delNote.substring(i,40) != null){
                                s_delInstn[j] = s_delNote.substring(0,i);
                                s_delNote = s_delNote.substring(i);
                            }else{
                                s_delInstn[j] = s_delNote.substring(0);
                                break;
                            }
                        }
                        orderDetailsObj.Delivery_Instruction_1__c =  s_delInstn[0] != null ? s_delInstn[0]:'';
                        orderDetailsObj.Delivery_Instruction_2__c =  s_delInstn[1] != null ? s_delInstn[1]:'';
                        orderDetailsObj.Delivery_Instruction_3__c =  s_delInstn[2] != null ? s_delInstn[2]:'';
                        
                        //PRB00029751
                        if(orderDetailsObj.Delivery_Instruction_1__c != null )
                        orderDetailsObj.Delivery_Instruction_1__c = orderDetailsObj.Delivery_Instruction_1__c.normalizeSpace();
                        
                        if(orderDetailsObj.Delivery_Instruction_2__c != null)
                        orderDetailsObj.Delivery_Instruction_2__c = orderDetailsObj.Delivery_Instruction_2__c.normalizeSpace();
                        
                        if(orderDetailsObj.Delivery_Instruction_3__c != null)
                        orderDetailsObj.Delivery_Instruction_3__c = orderDetailsObj.Delivery_Instruction_3__c.normalizeSpace();
                        
                        //PRB00029751
                        
                    }else{
                        orderDetailsObj.Delivery_Instruction_1__c = 'Not Specified';
                        orderDetailsObj.Delivery_Instruction_2__c = 'Not Specified';
                    }
                    // SETTING VALUES FROM ORDER AND RELATED JOB
                    orderDetailsObj.Last_Updated_By_Employee_Name__c = orderObj.LastModifiedBy.Name; //Name of employee who last updated the order
                    if(orderObj.LastModifiedBy.Phone != null && orderObj.LastModifiedBy.Phone != '')
                        orderDetailsObj.Last_Updated_By_Employee_Phone__c = orderObj.LastModifiedBy.Phone; //Telephone Number of employee who last updated the order
                    else
                        orderDetailsObj.Last_Updated_By_Employee_Phone__c = 'Not Specified';
                        
                    orderDetailsObj.Latest_Delivery_Date__c = orderObj.Job__r.Installation_date__c;
                    orderDetailsObj.Earliest_Delivery_Date__c = orderObj.Job_Delivery_Date__c;
                    
                    if(orderDetailsObj.Last_Updated_By_Employee_Name__c != null || orderDetailsObj.Last_Updated_By_Employee_Phone__c != NULL
                    ||  orderDetailsObj.Customer_Telephone_Number__c != null || orderDetailsObj.Customer_Work_Telephone_Number__c != null){
                        orderDetailsObj.Delivery_Instruction_4__c = '*';  
                    }
                        
                    // SETTING REFERENCES
                    orderDetailsObj.Orders_Id__c = orderObj.id;
                    orderDetailsObj.SFED7542_Order__c = header.id;   
                    orderDetailsObj.Supplier_Id__c = header.supplier__c;// dev Use only 

                    // SETTING ANA AND ID VALUES FOR CUSTOMER
                    if(orderObj.Job__r.CHI_Lead__r.Address_Number_EDI__c == null)
                        orderDetailsObj.Customer_Location_Code__c = orderObj.SupplierBranchNum__c; 
                    else
                        orderDetailsObj.Customer_Location_Code__c = orderObj.Job__r.CHI_Lead__r.Address_Number_EDI__c; 
                    orderDetailsList.add(orderDetailsObj);
                    
                    
                    
                    
                    System.debug(' -----------------ttt------------------'+orderDetailsList.size());
                }
            
            }
            
        }
        
        try{
            insert orderDetailsList;
            for(SFED7542_Order__c header : orderHeader){
                for(SFED7542_Order_Details__c odet : orderDetailsList){
                    if(odet.SFED7542_Order__c == header.id){
                        ordDetAndTrnsMap.put(odet.id,header.Transanction_Code__c);
                    }
                }
            }
            result = 'success';
            System.debug('-------------imp-------'+orderDetailsList.size());
        }catch(Exception e){
            	
                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
               String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail1 .setToAddresses(toAddresses);
                mail1.setSubject('Exception ocurred in creating SFED7542 Order Details records');
                mail1.setPlainTextBody('Exception ocurred in creating SFED7542 Order Details records: ' + e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                System.debug('@Exception creating order details @ '+e);
                result = 'error';
                return null;
        }
        return orderDetailsList;        
    }


// Arg 1 : order details Ids
    //Arg 2 : MAP[S1,(o1,o2) : S2,(o3)...]
    // This should create order sub details i.e actual order line correspondence payload records under order detail object

    public void createOrderSubDetails(List<SFED7542_Order_Details__c> orderDetailsIds,Map<String,List<order__c>> batchSuppOrderMap){  
        List<String> orderIds = new List<String>();
        Map<String,List<Order_Line_Item__c>> ordrToItemMap = new Map<String,List<Order_Line_Item__c>>();
        Set<String> partNumSet = new Set<String>();
        system.debug('Testing4-->'+orderList);
        system.debug('Testing5-->'+orderDetailsIds);
        system.debug('Testing6-->'+batchSuppOrderMap);
        for(Order__c order : orderList)         
              orderIds.add(order.Id);        
        
        //  Defect fix for EDI interface to identify this as user defined order line item - Starts
        List<Order_Line_Item__c> ordrItmList = [Select Original_Units__c,isUserDefinedOrderLine__c,Description__c,Original_Value__c,o.Units__c, o.Total_Amount__c, o.Supplier__c, o.P5_Unit_Price_c__c, o.P5_Type__c, o.P5_Sub_Status_c__c, o.P5_Status_c__c, o.P5_Purchase_Order__c, o.P5_Product__c, o.P5_Job_Element__c,Code__c,o.Id From Order_Line_Item__c o where  P5_Purchase_Order__c in : orderIds];
        //  Defect fix for EDI interface to identify this as user defined order line item - Ends
        
       for(Order_Line_Item__c ordrItm : ordrItmList){
          String code ='';
          if((ordrItm.Code__c).startsWith('C')){
            code = (ordrItm.Code__c).subString(1);
          }else{
            code = ordrItm.Code__c;
          }
            partNumSet.add(code);
        }
        System.debug('=====    partNumSet   ====  '+partNumSet);
system.debug('Testing3-->'+ordrItmList);
       for(String ordr : orderIds){
            List<Order_Line_Item__c> orderLines = new List<Order_Line_Item__c>();
            for(Order_Line_Item__c items : ordrItmList){
                if(items.P5_Purchase_Order__c == ordr)
                    orderLines.add(items);
            }
            ordrToItemMap.put(ordr,orderLines);
        }

        List<Product_Order__c> prodOrderList = [Select  p.quote_description__c, p.Product_Number__c, p.order_flag__c, p.Material_Type__c, 
            p.Manufactuer__c, p.lead_time__c, p.Id, p.EAN_code__c, p.Description__c, p.dw_ind__c, p.delmkr__c, p.Currency_Type__c, p.Brand__c, 
            p.bgc_number__c From Product_Order__c p where Product_Number__c in: partNumSet and order_flag__c !='N'];
        
        Map<String,Product_Order__c> prodOrderMap = new Map<String,Product_Order__c>();
        for(Product_Order__c prodOrder : prodOrderList)
            prodOrderMap.put(prodOrder.Product_Number__c ,prodOrder);


        List<SFED7542_Order_Sub_Detail__c> orderSubDetList = new List<SFED7542_Order_Sub_Detail__c>();
        system.debug('Testing1......'+ordrToItemMap);
        
        for(SFED7542_Order_Details__c ordDet : orderDetailsIds){
            List<Order_Line_Item__c> ordrItmLst = ordrToItemMap.get(ordDet.Orders_id__c);
            boolean createExtra = exceptionMap.get(ordDet.Orders_id__c);
            system.debug('Testing2......'+ordrItmLst);
            for(Order_Line_Item__c item : ordrItmLst){
                SFED7542_Order_Sub_Detail__c orderSubDetObj = new SFED7542_Order_Sub_Detail__c();
                String code ='';
                if((item.Code__c).startsWith('C')){
                  code = (item.Code__c).subString(1);
                }else{
                  code = item.Code__c;
                }
                Product_Order__c prodOrder = prodOrderMap.get(code);
                if(prodOrder != null){
                    orderSubDetObj.Product_EAN__c = prodOrder.EAN_code__c != null ? prodOrder.EAN_code__c : null;
                    orderSubDetObj.Supplier_Code_for_Traded_Unit__c = item.Code__c;
                    orderSubDetObj.Customer_Item_Code__c = item.Code__c;   
                    
                    if(createExtra == false && ordDetAndTrnsMap.get(ordDet.id) == '0430'){
                        if(item.Original_Units__c != null){
                            orderSubDetObj.Number_Of_Units_Ordered__c = item.Original_Units__c;
                            orderSubDetObj.Unit_Price__c = (item.Original_Value__c)*10000;     
                        }else{
                            orderSubDetObj.Number_Of_Units_Ordered__c = item.Units__c;
                            orderSubDetObj.Unit_Price__c = (item.P5_Unit_Price_c__c)*10000;     
                        }
                    } else{
                        if(item.P5_Status_c__c == 'Cancelled'){
                            orderSubDetObj.Number_Of_Units_Ordered__c = 0;
                            orderSubDetObj.Unit_Price__c = (item.P5_Unit_Price_c__c)*10000;   
                        }else{
                            orderSubDetObj.Number_Of_Units_Ordered__c = item.Units__c;
                            orderSubDetObj.Unit_Price__c = (item.P5_Unit_Price_c__c)*10000;  
                        } 
                    } 
                    String s_prodDesc = prodOrder.Description__c;
                    if(s_prodDesc != null){
                    if(s_prodDesc.length() > 40){
                      System.debug('#s_prodDesc = #'+s_prodDesc);
                        orderSubDetObj.Traded_Unit_Description_1__c = s_prodDesc.subString(0,40);
                        orderSubDetObj.Traded_Unit_Description_2__c = s_prodDesc.subString(40);
                    }else{
                        orderSubDetObj.Traded_Unit_Description_1__c = s_prodDesc;
                        orderSubDetObj.Traded_Unit_Description_2__c = '';
                    }
                    }
                    orderSubDetObj.SFED7542_Order_Detail__c = ordDet.Id;
                    orderSubDetList.add(orderSubDetObj);
                }
             //  Defect fix for EDI interface to identify this as user defined order line item - Starts
                 else if(item.isUserDefinedOrderLine__c){
                    orderSubDetObj.Product_EAN__c = null;
                    orderSubDetObj.Supplier_Code_for_Traded_Unit__c = item.Code__c;
                    orderSubDetObj.Customer_Item_Code__c = item.Code__c;   
                    
                    if(createExtra == false && ordDetAndTrnsMap.get(ordDet.id) == '0430'){
                        if(item.Original_Units__c != null){
                            orderSubDetObj.Number_Of_Units_Ordered__c = item.Original_Units__c;
                            orderSubDetObj.Unit_Price__c = (item.Original_Value__c)*10000;     
                        }else{
                            orderSubDetObj.Number_Of_Units_Ordered__c = item.Units__c;
                            orderSubDetObj.Unit_Price__c = (item.P5_Unit_Price_c__c)*10000;     
                        }
                    } else{
                        if(item.P5_Status_c__c == 'Cancelled'){
                            orderSubDetObj.Number_Of_Units_Ordered__c = 0;
                            orderSubDetObj.Unit_Price__c = (item.P5_Unit_Price_c__c)*10000;   
                        }else{
                            orderSubDetObj.Number_Of_Units_Ordered__c = item.Units__c;
                            orderSubDetObj.Unit_Price__c = (item.P5_Unit_Price_c__c)*10000;  
                        } 
                    } 
                    
                    String udp_prodDesc = item.Description__c;
                    if(udp_prodDesc.length() > 40){
                      System.debug('#udp_prodDesc = #'+udp_prodDesc);
                        orderSubDetObj.Traded_Unit_Description_1__c = udp_prodDesc.subString(0,40);
                        if(udp_prodDesc.length()>80){
                           orderSubDetObj.Traded_Unit_Description_2__c = udp_prodDesc.subString(40,80);
                        }else{
                           orderSubDetObj.Traded_Unit_Description_2__c = udp_prodDesc.subString(40,udp_prodDesc.length());  
                        }
                    }else{
                        orderSubDetObj.Traded_Unit_Description_1__c = udp_prodDesc;
                        orderSubDetObj.Traded_Unit_Description_2__c = '';
                    }   

                    orderSubDetObj.SFED7542_Order_Detail__c = ordDet.Id;
                    orderSubDetList.add(orderSubDetObj);
                
                }
            //  Defect fix for EDI interface to identify this as user defined order line item - Ends
            }  
        }
        try{
            insert orderSubDetList;
            result = 'success';
            System.debug('# checkpoint :6  finally must be 19 or 20#   '+orderSubDetList.size());
       
               
        }catch(Exception e){
            System.debug('@Exception creating order sub details @ '+e);
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
               String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail1.setToAddresses(toAddresses);
                mail1.setSubject('Exception creating order sub details');
                mail1.setPlainTextBody('Exception creating order sub details: ' +e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                
            result = 'error';
            return; 
            
        }
    }
     private void updateEDItatus(List<List<Order__c>> ordersList){
        for(SFED7542_Batch__c batch : orderBatchList){
            batch.Status__c= 'Ready to Integrate';
        }
         try{
             
            update orderBatchList;
             
        }
         
         
        catch(Exception e){
        //alert mail fix start
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
        mail.setReplyTo('donotreply@centrica.com');
        mail.setSenderDisplayName('DispatchOrdertoEDI - batch');
        mail.setSubject('Batch Process Failure - batch');
        mail.setPlainTextBody('DispatchOrdertoEDI has an exception while updating batch:#'+e.getMessage());
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //alert mail fix end
            }
        Set<string> ordIds = new Set<String>();
        List<order__c> finalOrder = new List<order__c>();
        for(Integer i =0;i<orderslist.size() ;i++){        
            List<order__c> orderList = orderslist.get(i);
            for(Order__c ord : orderList){
                if(!(ordIds.contains(ord.id))){
                    ord.EDI_Status__c ='Confirmed Processing';
                    ord.batch_created__c = true;
                    if(ord.status__c != 'Cancelled' && ord.Amendment_Number__c > 1){
                        if(ord.Amendment_Number_sent__c == null)
                            ord.Amendment_Number_sent__c = 1;
                        if(ord.Amendment_Number_sent__c <= ord.Amendment_Number__c)
                            ord.Amendment_Number_sent__c = ord.Amendment_Number_sent__c+1;
                    }
                    ord.Delivery_Date_Changed__c =false;
                    ord.Amendment_Synched__c =false;
                    ord.Supplier_Communication_Preference__c ='';
                    ordIds.add(ord.id);
                    finalOrder.add(ord);
                }
            }
        }
        try{  
            update finalOrder;
            
        }
         
              catch(Exception e){
            	   
                   Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();        
                   String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                   mail1.setToAddresses(toAddresses);
                   mail1.setSubject('Exception ocurred in updating merchant order EDI status to confirmed processing');
                   mail1.setPlainTextBody('Exception ocurred in updating merchant order EDI status to confirmed processing: ' + e.getMessage());
                   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                   System.debug('exception: '+e);
                  	for(SFED7542_Batch__c batch : orderBatchList){
            			batch.Status__c= 'Failed Integration';
        			}
                     try{
                         
                        update orderBatchList;
                         
                    }
                  catch(Exception ex){}
                             
                 }
    }

  /* private Map<String,boolean> checkInitialOrderExist(Map<String,Order__c> inputOrders){
        
        System.debug('-----chekcing intiial payload ...  '+inputOrders);
        List<String> ordersMapped = new List<String>();
        
        
        Map<String,boolean> returnOrderMap = new Map<String,boolean>();  
        
        //check 1 : if there is any SFED7542_Order record created for the orders with transaction code 0430
        
        List<SFED7542_Order_Details__c> sfedOrders = [Select id,s.Orders_Id__c From SFED7542_Order_Details__c s 
                                                where SFED7542_order__r.Transanction_code__c = '0430' and Orders_Id__c in :inputOrders.keySet()];
        
        
        if(sfedOrders.size() > 0){
            for(SFED7542_Order_Details__c SFED : sfedOrders){
                ordersMapped.add(SFED.Orders_Id__c);
                returnOrderMap.put(SFED.Orders_Id__c,true);
            }
        }
       
        System.debug('--return  Map  after check 1 --- '+returnOrderMap);
        // check 2: check if there are any entry in History in case that housekeeping has deleted data from the payload records
        List<order__History> histories = new List<order__History>();
        Set<String> tempOrdList = new Set<String>();
        if(returnOrderMap.size() == 0){         
            histories = [Select o.ParentId,o.Id From order__History o where ParentId in :inputOrders.keySet() and  field = 'EDI_Status__c'];
            for(String str2 : inputOrders.keySet()){
                tempOrdList.add(str2);
            }   
        }else if(returnOrderMap.size() < inputOrders.size()){
            
            for(String str2 : inputOrders.keySet()){
                if(!(returnOrderMap.containsKey(str2))){
                    tempOrdList.add(str2);
                }
            }               
            
            histories = [Select o.ParentId,o.Id From order__History o where ParentId in :tempOrdList and  field = 'EDI_Status__c'];
        }else if(returnOrderMap.size() == inputOrders.size()){
            return returnOrderMap;
        }
        
        System.debug('-----chekcing histories...  '+histories); 
    
        Integer count=0;
        if(histories.size() == 0){
            for(String ord : tempOrdList){
                returnOrderMap.put(ord,false);
            }
        }else{
            for(String ord : tempOrdList){
                
                count=0;
                System.debug('outside' +ord);
                for(order__History ordHis : histories){
                    if(ordHis.ParentId == ord){                     
                        System.debug('inside' +ordHis);                 
                        count++;
                        System.debug('#count  #'+count);
                    }
                }
                if(count >= 2){                 
                    if(!(returnOrderMap.containsKey(ord)))  {           
                        returnOrderMap.put(ord,true);
                    }
                }else{
                    if(!(returnOrderMap.containsKey(ord)))  
                        returnOrderMap.put(ord ,false);
                }
            }
        }
        System.debug('@ returnOrderMap @'+returnOrderMap);
        // true : no need to create separate batch
        // false : need to create separate batch
        return returnOrderMap;
   } */
   global void finish(Database.BatchableContext BC){
    
    /* AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
          if( a.TotalJobItems == 0 || a.NumberOfErrors>0)
         {             
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('DispatchordertoEDI ' + a.Status);
        String sPlainText;
        sPlainText='The DispatchordertoEDI job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. ';
        mail.setPlainTextBody(sPlainText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }*/
        /* 
        boolean schedule = true;
        
        fOR(CronTrigger c : [SELECT Id, CronJobDetail.Id, NextFireTime, CronJobDetail.Name, CronJobDetail.JobType  FROM CronTrigger 
                             where CronJobDetail.JobType = '7' and CronJobDetail.Name like : 'Trimble%' ORDER BY CreatedDate ASC LIMIT 20])
        {
            system.debug(c.CronJobDetail.Name);
            system.debug(c.NextFireTime);
            
            if(c.NextFireTime> system.now() && c.NextFireTime< system.now().addhours(1))
               {
                   	
        			schedule = false;
                    
               }else if(c.NextFireTime> system.now())
               {
                   System.abortJob(c.Id);
               }
        }
        
        if(schedule )
        {
            try{
            new minScheduler().callTheNextMinuteJob(null);
            }catch (exception e) {}
            
        }
        */
   
   }
   
}