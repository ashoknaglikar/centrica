/*
Type Name: BatchPopulateSFPO7523Records
Author: Cognizant
Change Date: 26/05/2010
Reason: To populate SFPO7523(SFDC to SAP Purchasing and Finance interface) object through batch jobs.
*/

global class BatchPopulateSFPO7523Records implements Database.Batchable<sObject>{

    List<Order__c> orderList = new List<Order__c>();
    Map<String,List<Order_Line_item__c>> oListMap = new Map<String,List<Order_Line_item__c>>();
    List<SFPO7523_Order_Header__c> interfaceOrderHeaderList = new List<SFPO7523_Order_Header__c>(); 
    public Map<String,boolean> exceptionMap = new Map<String,boolean>();
    List<Order__c> badOrders = new LIst<Order__c>();
    List<Order__c> goodOrders = new LIst<Order__c>();
    // Account assignment CR - starts
    Map<Id,Boolean> oppOwnLabourMap = new Map<Id,Boolean>();
    Set<Id> oppIds = new  Set<Id>();
    
     public void createSAPBatch(){
        BatchPopulateSFPO7523Records objSAPOrder = new BatchPopulateSFPO7523Records();
        ID batchprocessid = Database.executeBatch(objSAPOrder);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
      
         // Account assignment CR - starts        
         return Database.getQueryLocator('Select Name, Status__c,Job__r.Id,Job__r.Count_Own_labour_orders__c,Original_Account_Assignment_Flag__c,Is_Active_Own_Labour_Order__c,SAP_batch_created__c,Amendment_Number_Sent_for_SAP__c,could_not_process__c,Original_Order_Value__c,Job__r.Primary_Contact__c, Job__r.quote__r.Pricebook_Id__c,o.Type__c, o.Sync__c,Job__r.Quote__r.App_Assigned_Payroll__c, Supplier__r.Resource_Type__c,o.Supplier__c,o.Supplier_Acceptance_Status__c,o.SAP_Number__c, o.Quote__c, o.P5_Order_Release_Date__c,o.P5_Good_Receipting_Status__c, o.Order_Value__c,o.Order_Note__c,o.Order_Date__c, o.Job__c, o.Job_Delivery_Date__c, o.Id, o.Approved__c, o.CreatedDate,o.Job__r.region__c, o.Supplier__r.Supplier_Num__c, o.Job__r.Name,o.Supplier__r.Type__c, P5_SAP_Status__c,o.Job__r.Account__c,o.Job__r.Account__r.Primary_Contact__c,Job__r.CHI_Lead__r.CHI_Lead_Id1__c,o.Job__r.Account__r.BillingStreet,o.Job__r.Account__r.BillingCity, o.Job__r.Account__r.BillingCountry, o.Job__r.Account__r.BillingPostalCode, o.Job__r.Account__r.BillingState, o.Job__r.Delivery_Date__c, o.P5_Order_Cancellation_Date__c,o.Amendment_Number__c, o.P5_Order_Amendment_Date__c, o.P5_Number_Of_Line_Items__c, o.Cancelled_On__c,Job__r.District__r.Region__r.Code__c, o.P5_Account_Assignment_Category__c,o.Job__r.CHI_Lead__c From order__c o where o.P5_SAP_Status__c = \'Awaiting Integration\' and supplier__r.supplier_num__c != '+'\''+System.Label.BGS_SNUM_1+'\''+' and supplier__r.supplier_num__c != '+'\''+System.Label.BGS_SNUM_2+'\'');
         
    }
  
    global void execute(Database.BatchableContext BC, List<Sobject> sampleOrderList){
        if(sampleOrderList.size() > 0){
          Map<String,Order__c> exceptionOrdMap = new Map<String,Order__c>();
          
            for(Sobject sObj : sampleOrderList){
                Order__c orderObj = (Order__c)sObj;
                if(orderObj.Supplier__r.Supplier_Num__c == System.Label.PHJones && orderObj.CreatedDate >= date.valueOf(System.Label.PHJones_Stop_Date))
                    continue;
                    
                    exceptionOrdMap.put(orderObj.id,orderObj);
                    orderList.add(orderObj);
                              
                    // Account assignment CR - starts       
                    if(orderObj.Job__r.CHI_Lead__c!=null){
                      oppIds.add(orderObj.Job__r.CHI_Lead__c);
                    }
                
            }
            
           if(oppIds.size()>0){
                for(Opportunity opp : [Select Id,(Select Id from Jobs__r where Count_Own_labour_orders__c > 0) from Opportunity where Id in :oppIds]){
                    if(opp.Jobs__r.size()>0){
                        oppOwnLabourMap.put(opp.Id,true);
                    }
                }
            }
            
             // Account assignment CR - Ends     
             
            /*exceptionMap = this.checkInitialOrderExist(exceptionOrdMap);
            System.debug('@ before orderList @'+orderList.size());
            List<Order__c> tempOList = new List<Order__c>();
            System.debug('-------exceptionMap-------'+exceptionMap);
            for(Order__c ord : orderList){
              if((exceptionMap.get(ord.id) == false && ord.Amendment_number__c > 1) || (exceptionMap.get(ord.id) == false && ord.Amendment_number__c == 1 && ord.status__c == 'Cancelled') ){
                tempOList.add(ord);
              }
            }*/
            List<Order__c> tempOList = new List<Order__c>();
            for(Order__c ord : orderList){
              if((ord.SAP_batch_created__c == false && ord.Amendment_number__c > 1) || 
                 (ord.SAP_batch_created__c == false && ord.Amendment_number__c == 1 && ord.status__c == 'Cancelled') ){
                
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
            
            System.debug('@ after orderList @'+orderList.size());         
            createBatchRecords(orderList); 
        }
    }
  /*private Map<String,boolean> checkInitialOrderExist(Map<String,Order__c> inputOrders){
       System.debug('-----chekcing intiial payload ...  '+inputOrders);
       List<String> ordersMapped = new List<String>();
       Map<String,boolean> returnOrderMap = new Map<String,boolean>();
       //check 1 : if there is any SFED7542_Order record created for the orders with transaction code 0430
       
       List<SFPO7523_Order_Header__c> sfedOrders = [Select s.Purchase_Order__c From SFPO7523_Order_Header__c s
                           where Purchase_Order__c in :inputOrders.keySet()];
       
       
       if(sfedOrders.size() > 0){
         for(SFPO7523_Order_Header__c SFED : sfedOrders){
           ordersMapped.add(SFED.Purchase_Order__c);
           returnOrderMap.put(SFED.Purchase_Order__c,true);
         }
       }
      
       System.debug('--return  Map  after check 1 --- '+returnOrderMap);
       // check 2: check if there are any entry in History in case that housekeeping has deleted data from the payload records
       List<order__History> histories = new List<order__History>();
       Set<String> tempOrdList = new Set<String>();
       
       if(returnOrderMap.size() == 0){         
         histories = [Select o.ParentId,o.Id From order__History o where ParentId in :inputOrders.keySet() and  field = 'P5_SAP_Status__c'];
         for(String str2 : inputOrders.keySet()){
           tempOrdList.add(str2);
         }
       }else if(returnOrderMap.size() < inputOrders.size()){         
         for(String str2 : inputOrders.keySet()){
           if(!(returnOrderMap.containsKey(str2))){
             tempOrdList.add(str2);
           }
         }
         histories = [Select o.ParentId,o.Id From order__History o where ParentId in :tempOrdList and  field = 'P5_SAP_Status__c'];
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
        
        count =0 ;
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
   }*/

    public void createBatchRecords(List<Order__c> ordrList){
        
            
            List<String> appAsndList = new List<String>();
            Map<String,String> empAsndToMap =  new Map<String,String>();
            Set<String> contactSet = new Set<String>();
            Map<String,Contact> contactMap = new Map<String,Contact>();
            system.debug('orders--->'+ordrList);
            List<String> orderIdList = new List<String>();
            for(Order__c ord  : ordrList){
              system.debug('ord.Job__r.Quote__r.App_Assigned_Payroll__c-->'+ord.Job__r.Quote__r.App_Assigned_Payroll__c);
                if(null != ord.Job__r.Quote__r.App_Assigned_Payroll__c)
                    appAsndList.add(ord.Job__r.Quote__r.App_Assigned_Payroll__c);
                contactSet.add(ord.Job__r.Primary_Contact__c);
                orderIdList.add(ord.id);
            }
            List<Employee__c> employeeList = [select name,Employee_Number__c,Emp_type__c from Employee__c where Employee_Number__c in :appAsndList];            
            List<Contact> contactObjList = [Select id,c.Phone, c.Name, Salutation,Title,Lastname,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode, c.HomePhone, c.Fax, c.Email From Contact c where id in : contactSet];
            List<Order_Line_item__c> orderItemList = [Select o.Units__c,P5_Product__r.Description,
                         o.Total_Amount__c, o.Supplier__c, o.Skill__c, o.P5_Vat_Amount__c,
                         P5_Purchase_Order__r.P5_SAP_Status__c,Code__c,Rate_Type__c,
                         o.P5_User_Defined_Vat_Code__c, o.P5_Unit_Price_c__c, o.P5_Type__c,
                         o.P5_Sub_Status_c__c, o.P5_Status_c__c, o.P5_Purchase_Order__c,
                         o.P5_Product__c, o.P5_Job_Element__c, o.Name, o.Id ,o.CreatedDate,
                         o.Order_Line_Item_Number__c,o.P5_Purchase_Order__r.Amendment_Number__c,
                         o.P5_Purchase_Order__r.P5_Order_Amendment_Date__c ,Original_Units__c,Original_Value__c               
                         From Order_Line_Item__c o where o.P5_Purchase_Order__c in : orderIdList ]; // and shoudl be sent out 
                         
            for(Order__c order :orderList){
                List<Order_line_item__c> lineList = new List<Order_line_item__c>();
                for(Order_Line_item__c oLineItm : orderItemList){
                    if(oLineItm.P5_Purchase_Order__c == order.id){
                        lineList.add(oLineItm);
                    }
                }
                oListMap.put(order.id,lineList);
            }
            System.debug('Order Map Size ()   '+oListMap.size());
            for(Contact cont : contactObjList ){
                String s_tempCid = (String.valueOf(cont.id)).subString(0,15);
                contactMap.put(s_tempCid,cont);
            }

            for(Employee__c emp : employeeList){
                if(emp.Name != null)
                    empAsndToMap.put(emp.Employee_Number__c,emp.Emp_type__c);
            }
      Set<String> tempSet = new Set<String>();
            for(Order__c ordList : orderList){
              
              if(null != empAsndToMap.get(ordList.Job__r.Quote__r.App_Assigned_Payroll__c)){
              
                   System.debug('Order Name :    '+ordList.Name+' : '+ordList.id);
                  SFPO7523_Order_Header__c interfaceOrderHeaderObject = new SFPO7523_Order_Header__c();
          boolean createExtra = exceptionMap.get(ordList.id);
          Integer s_code = 1;
          System.debug('createExtra :    '+createExtra+' :tempSet: '+tempSet);
          
          if(createExtra == false && !(tempSet.contains(ordList.id))){
            System.debug('##########################################  1   #######################');
            tempSet.add(ordList.id);
            s_code = 1;
            interfaceOrderHeaderObject.P5_Amendment_No__c = 1;
            if(ordList.Original_Order_Value__c != null && ordList.Original_Order_Value__c > 0)
              interfaceOrderHeaderObject.P5_Total_Order_Value__c = ordList.Original_Order_Value__c;
            else
              interfaceOrderHeaderObject.P5_Total_Order_Value__c = ordList.Order_Value__c;
          }else if((createExtra == true) || (createExtra == false && (tempSet.contains(ordList.id)))){
            System.debug('##########################################  2   #######################');
             if(ordList.Status__c == 'Cancelled')
                        s_code = 9;
                    else if(ordList.Amendment_Number__c == 1 && ordList.Status__c != 'Cancelled')
                        s_code = 1;
                    else
                       s_code = 2;
                       
                    if(ordList.P5_Order_Cancellation_Date__c != null){
                       interfaceOrderHeaderObject.P5_Order_Cancel_Date__c = Date.newInstance((ordList.P5_Order_Cancellation_Date__c).year(),(ordList.P5_Order_Cancellation_Date__c).month(),(ordList.P5_Order_Cancellation_Date__c).day());
              interfaceOrderHeaderObject.Cancelled_On__c = ordList.Cancelled_On__c;
                    }
            if(ordList.P5_Order_Amendment_Date__c != null)
                         interfaceOrderHeaderObject.P5_Amendment_Date__c = Date.newInstance((ordList.P5_Order_Amendment_Date__c).year(),(ordList.P5_Order_Amendment_Date__c).month(),(ordList.P5_Order_Amendment_Date__c).day());
            
            if(ordList.Amendment_Number_Sent_for_SAP__c != null && ordList.Status__c == 'Cancelled'){
              interfaceOrderHeaderObject.P5_Amendment_No__c = ordList.Amendment_Number_Sent_for_SAP__c; 
            }
            else if(ordList.Amendment_Number_Sent_for_SAP__c != null && ordList.Amendment_Number__c > ordList.Amendment_Number_Sent_for_SAP__c)
              interfaceOrderHeaderObject.P5_Amendment_No__c = ordList.Amendment_Number_Sent_for_SAP__c+1;
            else
              interfaceOrderHeaderObject.P5_Amendment_No__c = ordList.Amendment_Number__c;
            
            
            
                          
            if(ordList.Order_Value__c == 0)
                        interfaceOrderHeaderObject.P5_Total_Order_Value__c = 0.01;
                    else
                        interfaceOrderHeaderObject.P5_Total_Order_Value__c = ordList.Order_Value__c;
          }else{
            System.debug('##########################################  3   #######################');
          }
          
                  interfaceOrderHeaderObject.Purchase_Order__c = ordList.Id;
                  interfaceOrderHeaderObject.P5_Transaction_Type__c = s_code;    
                                 
                 if(ordList.Supplier__r.Type__c == 'Product' )
                   interfaceOrderHeaderObject.P5_Type_Supplier__c = 'M'; //Merchant.               
                 if(ordList.Supplier__r.Type__c == 'Resource' )
                   interfaceOrderHeaderObject.P5_Type_Supplier__c = 'S'; //Resource.
                 if(ordList.Job__r.CHI_Lead__r.CHI_Lead_Id1__c != null) 
                     interfaceOrderHeaderObject.P5_Job_Number__c = Integer.valueOf(ordList.Job__r.CHI_Lead__r.CHI_Lead_Id1__c);// CHI Lead Number
                 if(ordList.SAP_Number__c != null)
                     interfaceOrderHeaderObject.P5_Order_Num__c = ordList.SAP_Number__c; // SAP Number
                 //if(ordList.P5_Order_Cancellation_Date__c != null)
                   //   interfaceOrderHeaderObject.P5_Order_Cancel_Date__c = Date.newInstance((ordList.P5_Order_Cancellation_Date__c).year(),(ordList.P5_Order_Cancellation_Date__c).month(),(ordList.P5_Order_Cancellation_Date__c).day());
                 interfaceOrderHeaderObject.P5_Order_Date__c = Date.newInstance((ordList.CreatedDate).year(),(ordList.CreatedDate).month(),(ordList.CreatedDate).day());
                 
                if(ordList.Job__r.District__r.Region__r.Code__c != null){
                     String s_GeoCode = ordList.Job__r.District__r.Region__r.Code__c;
                     interfaceOrderHeaderObject.P5_Geographical_Area__c = s_GeoCode.subString(s_GeoCode.length() - 2);
                 }
                 interfaceOrderHeaderObject.P5_Curr_Type__c = 'GBP'; 
                 interfaceOrderHeaderObject.P5_Business_Stream__c = System.Label.Business_ID;
                  //If the order is a materials order, set ACC_ASSIGN_CAT to 'Z'. Otherwise, if the job uses any British Gas Services' own resources, set ACCT_ASSIGN_CAT to 'X'  for any non material orders (e.g. contractors), If the job is being resourced entirely by external labour, all non material orders should have ACC_ASSIGN_CAT set to 'Y'.
                  
                  // Account assignment changes - start
                  
                  Date accAssignDepDate = Date.parse(system.label.Account_Assignment_Dep_Date);
                  system.debug('accAssignDepDate--->'+accAssignDepDate);
                     
                  if(ordList.Type__c == 'Material'){
                      interfaceOrderHeaderObject.Account_Assignment__c = 'Z';}
                  else if(ordList.Supplier__r.Resource_Type__c == 'Own Labour'){
                      interfaceOrderHeaderObject.Account_Assignment__c = 'X';}
                  else{
                      interfaceOrderHeaderObject.Account_Assignment__c = 'Y';}
                      
                 if(ordList.Type__c != 'Material' && ordList.CreatedDate >= accAssignDepDate ){
                   
                   if(ordList.Original_Account_Assignment_Flag__c != null){
                    
                      if(ordList.Original_Account_Assignment_Flag__c == 'X' || ordList.Original_Account_Assignment_Flag__c == 'Y'){
                        
                        interfaceOrderHeaderObject.Account_Assignment__c = ordList.Original_Account_Assignment_Flag__c;
                        
                      }else if(ordList.Job__r.Count_Own_labour_orders__c > 0 || oppOwnLabourMap.containsKey(ordList.Job__r.CHI_Lead__c)){
                        
                        interfaceOrderHeaderObject.Account_Assignment__c = 'X'; 
                        ordList.Original_Account_Assignment_Flag__c = interfaceOrderHeaderObject.Account_Assignment__c;
                        
                      }
                      
                  } else{
                    
                      if(ordList.Job__r.Count_Own_labour_orders__c > 0 || oppOwnLabourMap.containsKey(ordList.Job__r.CHI_Lead__c)){
                        
                        interfaceOrderHeaderObject.Account_Assignment__c = 'X'; 
                        ordList.Original_Account_Assignment_Flag__c = interfaceOrderHeaderObject.Account_Assignment__c;
                        
                      }
                    
                  }   
                   
              }                   
                  ordList.Original_Account_Assignment_Flag__c = interfaceOrderHeaderObject.Account_Assignment__c;
                      
                 // Account assignment changes - end                      
                                      
                  if(ordList.Type__c == 'Material'){
                      interfaceOrderHeaderObject.P5_Skill_Type__c = 'MER'; // Merchant orders are always set to MER
                      interfaceOrderHeaderObject.P5_Type_Purchase_Order__c ='M';
                  }
                  else{
                      interfaceOrderHeaderObject.P5_Type_Purchase_Order__c ='W';
                      interfaceOrderHeaderObject.P5_Skill_Type__c=this.calculateSkillType(ordList.Id,oListMap);
                       
                  }
                  if(null != empAsndToMap.get(ordList.Job__r.Quote__r.App_Assigned_Payroll__c))
                      interfaceOrderHeaderObject.Emp_Type__c = empAsndToMap.get(ordList.Job__r.Quote__r.App_Assigned_Payroll__c); 
  
                  if(ordList.Job__r.Primary_Contact__c != null){
                      Contact contObj = contactMap.get(ordList.Job__r.Primary_Contact__c);
                      if(contObj != null){
                          if(contObj.Title != null){
                                if((contObj.Title).length() > 5){
                                    interfaceOrderHeaderObject.P5_Title__c = (contObj.Title).subString(0,4);
                                }else{
                                  interfaceOrderHeaderObject.P5_Title__c = contObj.Title;
                                }
                               } else{
                          if((contObj.Salutation) != null){
                              if((contObj.Salutation).length() > 5){
                                  interfaceOrderHeaderObject.P5_Title__c = (contObj.Salutation).subString(0,4);
                              }else{
                                interfaceOrderHeaderObject.P5_Title__c = contObj.Salutation;
                              }
                             } //edited on 07-06-2011 to trim the salutation field on the contact object if the length exceeds 5 characters.
                             }
                             
                            if((contObj.Lastname) != null){
                              if((contObj.Lastname.length()) > 30){
                                  interfaceOrderHeaderObject.Surname__c = (contObj.Lastname).subString(0,29);
                              }else{
                                interfaceOrderHeaderObject.Surname__c = contObj.Lastname;
                              }
                             }//edited on 27-07-2011 to trim the lastname field on the contact object if the length exceeds 30 characters.
                             //codefix by BGSAMS Support - 10/10/2014
                          //interfaceOrderHeaderObject.Surname__c = contObj.Lastname;
                          if(contObj.Account.BillingStreet != null){
                            if((contObj.Account.BillingStreet).length() > 36)
                              interfaceOrderHeaderObject.P5_Delivery_Address__c = (contObj.Account.BillingStreet).subString(0,37);
                            else
                              interfaceOrderHeaderObject.P5_Delivery_Address__c = contObj.Account.BillingStreet;
                          }
                          if(contObj.Account.BillingCity != null){  
                            if((contObj.Account.BillingCity).length() > 36)
                              interfaceOrderHeaderObject.P5_ADDR_2__c = (contObj.Account.BillingCity).subString(0,37);
                            else
                              interfaceOrderHeaderObject.P5_ADDR_2__c = contObj.Account.BillingCity;
                          }
                          if(contObj.Account.BillingState != null){
                            if((contObj.Account.BillingState).length() > 36)
                              interfaceOrderHeaderObject.P5_ADDR_3__c = (contObj.Account.BillingState).subString(0,37);
                            else
                              interfaceOrderHeaderObject.P5_ADDR_3__c = contObj.Account.BillingState;  
                          }
                          if(contObj.Account.BillingCountry != null){  
                            if((contObj.Account.BillingCountry).length() > 36)
                              interfaceOrderHeaderObject.ADDR_4__c = (contObj.Account.BillingCountry).subString(0,37);
                            else
                              interfaceOrderHeaderObject.ADDR_4__c = contObj.Account.BillingCountry;  
                          }
                          
                          interfaceOrderHeaderObject.P5_Post_Code__c = contObj.Account.BillingPostalCode;
                      }
                  }
  
                  interfaceOrderHeaderObject.P5_Delivery_Date__c = ordList.Job__r.Delivery_Date__c;
                  interfaceOrderHeaderObject.P5_PRODUCT_TYPE__c = ordList.Job__r.quote__r.Pricebook_Id__c;                
                  interfaceOrderHeaderList.add(interfaceOrderHeaderObject); 
                  interfaceOrderHeaderObject.Status__c = 'Processing';
                  
                 
                  goodOrders.add(ordList);
              }else{
                badOrders.add(ordList);
              }
            }
            try{
                //Inserting "SFPO7523 Order Header" records.
                Database.insert(interfaceOrderHeaderList);  
                // calling method to create Line Items
        
                this.generateOrderLineItemRecords(interfaceOrderHeaderList);

            }catch(Exception e){
                System.debug('### EXCeption: '+e);
                //code fix by BGSAMS Support - 10/10/2014
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('donotreply@centrica.com');
                mail.setSenderDisplayName('BatchPopulateSFPO7523 batch');
                mail.setSubject('Batch Process Failure - order');
                mail.setPlainTextBody('BatchPopulateSFPO7523 batch has an exception while inserting order Header:#'+e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             //code fix by BGSAMS Support - 10/10/2014
            }
        }
        public Map<String,String> skillCodeMap = new Map<String,String>();
    // METHOD TO SET THE GLOAL SKILL CODE MAP PER WORK SKILL BASIS        
    private Map<String,String> setSkillMap(){
        // SETTING THE skillCodeMap 
        
        // Cognizant - CHI Phase III CR-002 implementation... START 
    
      AddNewSkill ObjNewSkill = new AddNewSkill();
      skillCodeMap = ObjNewSkill.setSkillMap();
        
        /*skillCodeMap.put('Asbestos Removal','A');
        skillCodeMap.put('Asbestos Removal Fixed Rate','AF');
        skillCodeMap.put('Building Work','B');
        skillCodeMap.put('Contractor Installation','CI');
        skillCodeMap.put('Electrical','E');
        skillCodeMap.put('Electrical Work ASP','EA');
        skillCodeMap.put('FIRE/WALL HEATER FIXING','FF');
        skillCodeMap.put('FireWall Heater Fixing','FF');
        skillCodeMap.put('LPG Installation','LP');
        skillCodeMap.put('Mechanical','M');
        skillCodeMap.put('Connect Solar Panels','MSL');
        skillCodeMap.put('Payment Collection','PC');
        skillCodeMap.put('Powerflush','PF');
        skillCodeMap.put('Roof Work','R');
        skillCodeMap.put('Scaffolder','S');
        skillCodeMap.put('Specialist Building','SB');
        skillCodeMap.put('Specialist Building Work','SB');
        skillCodeMap.put('Solar','SOL');
        skillCodeMap.put('Unvented Hot Water','UV');
        skillCodeMap.put('Water Heater Fixing','WH');*/
        
        // Cognizant - CHI Phase III CR-002 implementation... END
        
        return skillCodeMap;
    }
    
    //The skill with highest total currency value is used to populate the table SAP_ORDER_EXTRACT_TABLE. 
    //If the above value is same for more than one skill 
    //then highest alphabet for the skill is used. If no skill is found then error is raised in the error table.
    private String calculateSkillType(String orderId,Map<String,List<Order_Line_item__c>> listMap){
        
        List<Order_Line_item__c> tempList = listMap.get(orderId);
        Map<String,Double> skillMap = new Map<String,Double>();
        List<String> SkillSetList = new List<String>(); 
        List<String> SkillSet2List = new List<String>(); 
        
    Map<String,String> skillCodeTempMap = this.setSkillMap();
    
        for(Order_Line_Item__c oLine : tempList){
            if(skillCodeTempMap!= null && skillCodeTempMap.get(oLine.Skill__c) != null && !skillMap.containsKey(skillCodeTempMap.get(oLine.Skill__c)) )
                skillMap.put(skillCodeTempMap.get(oLine.Skill__c),oLine.Total_Amount__c);
            else if(skillCodeTempMap!= null && skillCodeTempMap.get(oLine.Skill__c) != null && skillMap.containsKey(skillCodeTempMap.get(oLine.Skill__c)) ){
                Double amount = skillMap.get(skillCodeTempMap.get(oLine.Skill__c)); 
                if(oLine.Total_Amount__c != null)
                    amount = amount + oLine.Total_Amount__c;
                skillMap.put(skillCodeTempMap.get(oLine.Skill__c),amount);
            }
        }
        if(skillMap.size() > 0){
            // get the max amout value in teh skillMap
            Double maxV=0;
            for(Double maxVal : skillMap.values()){
                if(maxVal > maxV)
                    maxV = maxVal;
            }
            // retireve the no. of skills for teh maxValue identified
            for(String str : skillMap.keySet()){
                if(skillMap.get(str) == maxV)
                    SkillSetList.add(str);
                else
                  SkillSet2List.add(str);
            }
            if(SkillSetList.size() > 0){
                String maxVal = SkillSetList[0];
                /*for(String minVal : SkillSetList){
                    if(minVal > maxV)
                        maxVal = maxVal;
                }*/
              // return maxVal.subString(0,1);
              return maxVal;
            }else{
              //return SkillSetList[0].subString(0,1);
              return SkillSet2List[0];
                
            }
                
        }else
            return 'X';
     
    //return skillCodeTempMap.get(oLine.Skill__c) ;

    }

         /**
         This method retrieves inserted "SFPO7523 Order Header" record's list
         and generate list of corresponding "SFPO7523 Order Line" records.    
         */
      private void generateOrderLineItemRecords(List<SFPO7523_Order_Header__c> orderHeaderList){
        
       
        List<SFPO7523_Order_Line__c> interfaceOrderLineItemList = new List<SFPO7523_Order_Line__c>();        
        Map<String,SFPO7523_Order_Header__c> orderMap = new  Map<String,SFPO7523_Order_Header__c>();
        
        for(SFPO7523_Order_Header__c intHeader : orderHeaderList)
            orderMap.put(intHeader.Purchase_Order__c,intHeader);
       
         Set<String> orderIdLst = new Set<String>();
       
        for(SFPO7523_Order_Header__c intHeader : orderHeaderList)  {
            Integer count=1;
            System.debug('############################   order.id :   '+intHeader.Purchase_Order__c);
            List<Order_line_item__c> lineList = oListMap.get(intHeader.Purchase_Order__c); 
            System.debug('############################   lineList :   '+lineList.size());
            for(Order_Line_item__c oLineItm : lineList){
                SFPO7523_Order_Line__c orderLineItemObj = new SFPO7523_Order_Line__c();
                orderLineItemObj.Amendment_Date__c = intHeader.P5_Amendment_Date__c;                    
                orderLineItemObj.Amendment_No__c = intHeader.P5_Amendment_No__c;                
                orderLineItemObj.P5_SFPO7523_Order_Header__c = intHeader.id;
                
                if(oLineItm.P5_Type__c == 'Work' && (oLineItm.P5_Unit_Price_c__c == 0 || oLineItm.Units__c == 0)){
                  if(intHeader.P5_Amendment_No__c == 1 && oLineItm.Original_Units__c != null && oLineItm.Original_Value__c != null){
                    if(oLineItm.Original_Value__c == 0)
                      orderLineItemObj.P5_Unit_Price__c = 0.01; 
                    else{
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Unit_Price__c = 0.01; 
                      else
                        orderLineItemObj.P5_Unit_Price__c = oLineItm.Original_Value__c; 
                    }
                    if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                    orderLineItemObj.P5_Units__c = 0;
                  else
                      orderLineItemObj.P5_Units__c = oLineItm.Original_Units__c;
                    
                  }
                  else{
                    if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                  orderLineItemObj.P5_Units__c = 0;
                  else  
                       orderLineItemObj.P5_Units__c = oLineItm.Units__c;
                     if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                    orderLineItemObj.P5_Unit_Price__c = 0.01; 
                  else
                      orderLineItemObj.P5_Unit_Price__c = 0.01; 
                  }
                }else if(oLineItm.P5_Type__c == 'Work' && oLineItm.P5_Status_c__c == 'Cancelled'){
                  if(intHeader.P5_Amendment_No__c == 1 && oLineItm.Original_Units__c != null && oLineItm.Original_Value__c != null){
                    if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                    orderLineItemObj.P5_Units__c = 0;
                  else  
                      orderLineItemObj.P5_Units__c = oLineItm.Original_Units__c;
                    if(oLineItm.Original_Value__c == 0)
                      orderLineItemObj.P5_Unit_Price__c = 0.01;
                    else{
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Unit_Price__c = 0.01; 
                      else
                        orderLineItemObj.P5_Unit_Price__c = oLineItm.Original_Value__c;
                    } 
                  }
                  else{
                    if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                    orderLineItemObj.P5_Units__c = 0;
                  else
                      orderLineItemObj.P5_Units__c = 1;
                    if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                    orderLineItemObj.P5_Unit_Price__c = 0.01; 
                  else
                      orderLineItemObj.P5_Unit_Price__c = 0.01;
                  }
                }else if(oLineItm.P5_Type__c == 'Material' && oLineItm.P5_Status_c__c == 'Cancelled'){
                  if(intHeader.P5_Amendment_No__c == 1 && oLineItm.Original_Units__c != null && oLineItm.Original_Value__c != null){
                    if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                    orderLineItemObj.P5_Units__c = 0;
                  else
                      orderLineItemObj.P5_Units__c = oLineItm.Original_Units__c;
                    if(oLineItm.Original_Value__c == 0)
                      orderLineItemObj.P5_Unit_Price__c = 0.01;
                    else{
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Unit_Price__c = 0.01; 
                      else
                        orderLineItemObj.P5_Unit_Price__c = oLineItm.Original_Value__c; 
                    }
                  }
                  else{
                    if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                    orderLineItemObj.P5_Units__c = 0;
                  else  
                      orderLineItemObj.P5_Units__c = 0;
                    if( oLineItm.P5_Unit_Price_c__c == 0)
                      orderLineItemObj.P5_Unit_Price__c = 0.01;
                    else{
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Unit_Price__c = 0.01; 
                      else
                        orderLineItemObj.P5_Unit_Price__c =  oLineItm.P5_Unit_Price_c__c; 
                    }
                  } 
                }else {
                  if(oLineItm.Rate_Type__c == 'Fixed'){
                    if(intHeader.P5_Amendment_No__c == 1 && oLineItm.Original_Units__c != null && oLineItm.Original_Value__c != null){
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Units__c = 0;
                       else
                          orderLineItemObj.P5_Units__c = oLineItm.Units__c;
                      if(intHeader.P5_Transaction_Type__c !=1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Unit_Price__c = 0.01; 
                      else
                        orderLineItemObj.P5_Unit_Price__c = oLineItm.Original_Value__c; 
                    }
                    else{
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Units__c = 0;
                        else
                          orderLineItemObj.P5_Units__c = oLineItm.Units__c;
                      
                      if( oLineItm.P5_Unit_Price_c__c == 0)
                        orderLineItemObj.P5_Unit_Price__c = 0.01;
                      else{
                        if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                          orderLineItemObj.P5_Unit_Price__c = 0.01; 
                        else
                          orderLineItemObj.P5_Unit_Price__c =  oLineItm.P5_Unit_Price_c__c; 
                      }
                    }                    
                  }
                  else{
                    if(intHeader.P5_Amendment_No__c == 1 && oLineItm.Original_Units__c != null && oLineItm.Original_Value__c != null){
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Units__c = 0;
                      else  
                        orderLineItemObj.P5_Units__c = oLineItm.Original_Units__c;
                      if(oLineItm.Original_Value__c == 0)
                        orderLineItemObj.P5_Unit_Price__c = 0.01;
                      else{
                        if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                          orderLineItemObj.P5_Unit_Price__c = 0.01; 
                        else
                          orderLineItemObj.P5_Unit_Price__c = oLineItm.Original_Value__c; 
                      }
                    }
                    else{
                      if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                        orderLineItemObj.P5_Units__c = 0;
                      else
                        orderLineItemObj.P5_Units__c = oLineItm.Units__c;
                      if( oLineItm.P5_Unit_Price_c__c == 0)
                        orderLineItemObj.P5_Unit_Price__c = 0.01;
                      else{
                        if(intHeader.P5_Transaction_Type__c != 1 && oLineItm.P5_Status_c__c == 'Cancelled')
                          orderLineItemObj.P5_Unit_Price__c = 0.01; 
                        else
                          orderLineItemObj.P5_Unit_Price__c =  oLineItm.P5_Unit_Price_c__c;
                      }
                    }
                  }
                }
                orderLineItemObj.P5_Order_Line_No__c = count;
                orderLineItemObj.P5_Line_Item_ID__c = oLineItm.Code__c;
                orderLineItemObj.Order_Type__c = oLineItm.Rate_Type__c;
                orderLineItemObj.P5_Currency_Type__c = 'GBP'; 
                orderLineItemObj.Name = oLineItm.Code__c;        
                
                interfaceOrderLineItemList.add(orderLineItemObj);
                count++;
            }
      }
    try{
        //Inserting "SFPO7523 Order Header" records.
        Database.insert(interfaceOrderLineItemList);

        this.updateOrderPOStatus(orderList);

    }catch(Exception e){
        System.debug('### EXCeption: '+e);
        //code fix by BGSAMS Support - 10/10/2014
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('donotreply@centrica.com');
                mail.setSenderDisplayName('BatchPopulateSFPO7523 batch');
                mail.setSubject('Batch Process Failure - order');
                mail.setPlainTextBody('BatchPopulateSFPO7523 batch has an exception while inserting order line items:#'+e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             //code fix by BGSAMS Support - 10/10/2014
    }

}

public void updateOrderPOStatus(list<Order__c> orderList){ 
  for(SFPO7523_Order_Header__c header : interfaceOrderHeaderList){
    header.Status__c = 'Ready to Integrate';
  }
  try{
        update interfaceOrderHeaderList;
    }catch(Exception e){
        System.debug('Exception '+e);
        //code fix by BGSAMS Support - 10/10/2014
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('donotreply@centrica.com');
                mail.setSenderDisplayName('BatchPopulateSFPO7523 batch');
                mail.setSubject('Batch Process Failure - order');
                mail.setPlainTextBody('BatchPopulateSFPO7523 batch has an exception while inserting interface order header:#'+e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             //code fix by BGSAMS Support - 10/10/2014
    }
    Set<string> ordIds = new Set<String>();
    List<Order__c> finalOrder = new List<Order__c>();
    for(order__c ord :goodOrders){
      if(!(ordIds.contains(ord.id))){
           ord.P5_SAP_Status__c = 'Confirmed Processing';
           if(ord.SAP_batch_created__c == false)
             ord.SAP_batch_created__c = true;
           System.debug('@@@@@@1@@@@'+ord.status__c+'    ##### 2 ####    '+ord.Amendment_Number__c+' ===    '+ord.Amendment_Number_Sent_for_SAP__c);
           if(ord.status__c != 'Cancelled' && ord.Amendment_Number__c > 1){
             if(ord.Amendment_Number_Sent_for_SAP__c == null)
               ord.Amendment_Number_Sent_for_SAP__c = 1;
             if(ord.Amendment_Number_Sent_for_SAP__c <= ord.Amendment_Number__c)
               ord.Amendment_Number_Sent_for_SAP__c = ord.Amendment_Number_Sent_for_SAP__c+1;
           }
           /*
             if(ordList.Amendment_Number_Sent_for_SAP__c != null && ordList.Status__c == 'Cancelled'){
          interfaceOrderHeaderObject.P5_Amendment_No__c = ordList.Amendment_Number_Sent_for_SAP__c; 
        }
        else if(ordList.Amendment_Number_Sent_for_SAP__c != null && ordList.Amendment_Number__c > ordList.Amendment_Number_Sent_for_SAP__c)
          interfaceOrderHeaderObject.P5_Amendment_No__c = ordList.Amendment_Number_Sent_for_SAP__c+1;
        else
          interfaceOrderHeaderObject.P5_Amendment_No__c = ordList.Amendment_Number__c;
           */
           ord.could_not_Process__c = false;
           ordIds.add(ord.id);
           finalOrder.add(ord);
      }
    }
  for(order__c ord :badOrders){
      if(!(ordIds.contains(ord.id))){
        ord.could_not_Process__c = true;
           ordIds.add(ord.id);
           finalOrder.add(ord);
      }
    }
    try{
        update finalOrder;
    }catch(Exception e){
        System.debug('Exception '+e);
        //code fix by BGSAMS Support - 10/10/2014
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('donotreply@centrica.com');
                mail.setSenderDisplayName('BatchPopulateSFPO7523 batch');
                mail.setSubject('Batch Process Failure - order');
                mail.setPlainTextBody('BatchPopulateSFPO7523 batch has an exception while updating orders:#'+e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             //code fix by BGSAMS Support - 10/10/2014
    }
}
global void finish(Database.BatchableContext bc){
    /* AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
          if( a.TotalJobItems == 0 || a.NumberOfErrors>0)
         {             
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = system.label.Exception_emails_for_batches.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('BatchPopulateSFPO7523 ' + a.Status);
        String sPlainText;
        sPlainText='The BatchPopulateSFPO7523 job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures. ';
        mail.setPlainTextBody(sPlainText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

}

*/

}


}