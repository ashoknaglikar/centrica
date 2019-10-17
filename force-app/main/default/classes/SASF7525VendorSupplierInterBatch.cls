/*
    Type Name:      Class SASF7525VendorSupplierInterBatch
    Author:         Cognizant
    Created Date:   06/03/2010
    Reason:         Centrica Phase 5 - SAP Vendor Details Integration
    Change History: 
*/
    global class SASF7525VendorSupplierInterBatch implements Database.Batchable<SObject>{
                
    global final String query;
    global List<SASF7525_Supplier__c> sampleSASF7525BatchSupplierList =  new List<SASF7525_Supplier__c>();
    global Map<String, SASF7525_Batch__c> statusBatch = new Map<String, SASF7525_Batch__c>();
    List<SASF7525_Supplier__c> SASF7525SupplierList;
    final List<SASF7525_Batch__c> currentBatches;
    Map<String, SASF7525_Supplier__c> batchSuplierNumberMap = new Map<String, SASF7525_Supplier__c>();///
    List<Supplier__c> upsertSupplierList = new List<Supplier__c>();//
    
      
    public void createVendorBatch()
    {    
        SASF7525VendorSupplierInterBatch SASF7525Vendor = new SASF7525VendorSupplierInterBatch();    
        ID batchprocessid = Database.executeBatch(SASF7525Vendor);
    }
    
    global SASF7525VendorSupplierInterBatch() 
    {
        query = 'Select s.Supplier_Num__c, s.Supplier_Name__c, s.Supplier_Change_Date__c, s.Street__c, s.Status_code__c, s.SASF7525_Batch__r.Batch_Status__c, s.SASF7525_Batch__c, s.Postcode__c, s.Phone2__c, s.Phone1__c, s.Name, s.Id, s.Fax__c, s.City__c From SASF7525_Supplier__c s where s.SASF7525_Batch__r.Batch_Status__c = 0';                             
        SASF7525SupplierList = new List<SASF7525_Supplier__c>();
        
        currentBatches = [Select id, Batch_Status__c From  SASF7525_Batch__c where Batch_Status__c = 0];
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
         System.debug('Inside start: QueryLocator: '+Database.getQueryLocator(query));
         return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> sampleSASF7525BatchSupplierList)    
    {
        System.debug('Inside execute: sampleSASF7525BatchList: '+ sampleSASF7525BatchSupplierList.size());
        for(Sobject o : sampleSASF7525BatchSupplierList)
        {
           SASF7525_Supplier__c s = (SASF7525_Supplier__c)o;
           SASF7525SupplierList.add(s);
           //statusBatch.put(s.SASF7525_Batch__c, s.SASF7525_Batch__r);
           system.debug('--statusBatch' +statusBatch);
        }       
        System.debug('Inside execute sampleSASF7525BatchIdList' +SASF7525SupplierList);
        //calling the main methods
        FetchVendorData(SASF7525SupplierList);
        System.debug('$$$$ after creation of batch records... ');
    }
    
    global void finish(Database.BatchableContext BC)
    { /*
    	List<string> str = new List<string>();
    	str.add('1');
        system.debug('---statusB' +statusBatch.values());
        List<SASF7525_Batch__c> lstBatches = new List<SASF7525_Batch__c>(); 
                      
        for(SASF7525_Batch__c batchObj : statusBatch.values()){
            batchObj.Batch_Status__c = 1;
            lstBatches.add(batchObj);
        }
        
        if(lstBatches.size() > 0)
        {
            update lstBatches; 
        }*/
        
       List<SASF7525_Batch__c> lstBatches = new List<SASF7525_Batch__c>(); 
       for(SASF7525_Batch__c batchObj : currentBatches){
            batchObj.Batch_Status__c = 1;
            lstBatches.add(batchObj);
        }
        
        if(lstBatches.size() > 0)
        {
            update lstBatches; 
        }
       
        //** call the supplier region scheduler     
       
        DateTime dtNow=System.now();
        dtNow=dtNow.addMinutes(10);
        String sDay=String.ValueOf(dtNow.day());
        String sMonth=String.ValueOf(dtNow.month());
        String sYear=String.ValueOf(dtNow.year());    
        String sHour=String.ValueOf(dtNow.hour());
        String sMinute=String.ValueOf(dtNow.minute());
        String sSecond=String.ValueOf(dtNow.second());
        String sInvokeRegScheduler = '0 ' + sMinute + ' ' + sHour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        System.schedule('Create Update Vendor Region', sInvokeRegScheduler, new SASF7525VendorRegionScheduler ());
        //** 
            
       
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'sanhita.mitra@cognizant.com'});
        mail.setReplyTo('sanhita.mitra@cognizant.com');
        mail.setSenderDisplayName('Batch Processing : SASF7525Vendor');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('&&& Batch Process has completed FOR Supplier SFPO' );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
   //main methods
   public void FetchVendorData(List<SASF7525_Supplier__c> SASF7525BatchSuppList) {
   
       Map<String,Supplier__c> suppMap = new Map<String,Supplier__c>();
       List<SASF7525_Supplier__c> batchSupList = new List<SASF7525_Supplier__c>();
       
        //get the batch Supplier 
        //get te list of Supplier number which is unique
        for(SASF7525_Supplier__c SASF7525SupplierLoop : SASF7525BatchSuppList)
            {
                batchSuplierNumberMap.put(SASF7525SupplierLoop.Supplier_Num__c, SASF7525SupplierLoop);
            }
                    
        //Inserting/updating suppliers.
            for(SASF7525_Supplier__c SASF7525Supp : batchSuplierNumberMap.values()){
                        
                Supplier__c suppObj = new Supplier__c();
        
                suppObj.Supplier_Num__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Supplier_Num__c;
                suppObj.Street__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Street__c;
                suppObj.Status_code__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Status_code__c;
                suppObj.City__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).City__c;
                suppObj.Postcode__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Postcode__c;
                suppObj.Phone1__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Phone1__c;
                suppObj.Phone2__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Phone2__c;
                suppObj.Fax__c = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Fax__c;
                suppObj.Name = batchSuplierNumberMap.get(SASF7525Supp.Supplier_Num__c).Supplier_Name__c; 
                upsertSupplierList.add(suppObj);
                
            }
            //insert/update supplier 
            if(upsertSupplierList != null && upsertSupplierList.size()> 0){
            
                try
                {
                    upsert upsertSupplierList Supplier_Num__c;
                } 
                catch(Exception ex)
                {
                    system.debug('-----ex' +ex);
                }
             }
      
 }   


}