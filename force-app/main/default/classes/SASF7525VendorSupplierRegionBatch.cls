/*
    Type Name:      Class SASF7525VendorSupplierRegionBatch
    Author:         Cognizant
    Created Date:   06/03/2010
    Reason:         Centrica Phase 5 - SAP Vendor Details Integration
    Change History: 
*/

    global class SASF7525VendorSupplierRegionBatch implements Database.Batchable<SObject>{
                
    global final String query;
    global List<SASF7525_Supplier_Region__c> sampleSASF7525SupplierRegionList = new List<SASF7525_Supplier_Region__c>();
    List<SASF7525_Supplier_Region__c> SASF7525SupplierRegList;
    final List<SASF7525_Batch__c> currentBatches;
    
    Map<String, Region__c> regionMap = new Map<String, Region__c>();//
    Map<String, SASF7525_Supplier_Region__c> batchSuplierNumberRegionMap = new Map<String, SASF7525_Supplier_Region__c>();///
    List<Supplier_Region__c> upsertSupplierRegionList = new List<Supplier_Region__c>();//
    
    public void createVendorBatch()
    {    
        SASF7525VendorSupplierRegionBatch SASF7525Vendor = new SASF7525VendorSupplierRegionBatch();    
        ID batchprocessid = Database.executeBatch(SASF7525Vendor);
    }
    global SASF7525VendorSupplierRegionBatch() 
    {
        SASF7525SupplierRegList = new List<SASF7525_Supplier_Region__c>();
        query = 'Select s.Vendor_Change_date__c, s.Supplier_Num__c, s.Status_Code__c, s.SASF7525_Batch__r.Batch_Status__c, s.SASF7525_Batch__c, s.Name, s.Id, s.Geography_Code__c, s.Business_Stream__c From SASF7525_Supplier_Region__c s where s.SASF7525_Batch__r.Batch_Status__c = 1';
        currentBatches = [Select id, Batch_Status__c From  SASF7525_Batch__c where Batch_Status__c = 1];                             
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
         System.debug('Inside start: QueryLocator: '+Database.getQueryLocator(query));
         return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Sobject> sampleSASF7525SupplierRegionList)    
    {
        System.debug('Inside execute: sampleSASF7525BatchList: '+ sampleSASF7525SupplierRegionList);
        for(Sobject o : sampleSASF7525SupplierRegionList)
        {
           SASF7525_Supplier_Region__c s = (SASF7525_Supplier_Region__c)o;
           SASF7525SupplierRegList.add(s);
        }       
        System.debug('Inside execute SASF7525SupplierRegList' +SASF7525SupplierRegList);
        //calling the main methods
        FetchVendorData(SASF7525SupplierRegList);
        System.debug('$$$$ after creation of batch records... ');
    }
    
    global void finish(Database.BatchableContext BC)
    {
    	//udpate the processed__c field in the SASF7525_Batch__c   
      	List<SASF7525_Batch__c> lstBatches = new List<SASF7525_Batch__c>();    
	    for(SASF7525_Batch__c batchObj : currentBatches){
            batchObj.Batch_Status__c = 2;
            lstBatches.add(batchObj);
        }
	    if(lstBatches.size() > 0)
        {
            update lstBatches; 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'sanhita.mitra@cognizant.com'});
        mail.setReplyTo('sanhita.mitra@cognizant.com');
        mail.setSenderDisplayName('Batch Processing : SASF7525Vendor Region');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('&&& Batch Process has completed FOR Supplier Region SFPO');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
   //main methods
   public void FetchVendorData(List<SASF7525_Supplier_Region__c> SASF7525SuppRegList) 
   {
       List<String> suppNumList = new List<String>();
       List<SASF7525_Supplier_Region__c> batchRegionList = new List<SASF7525_Supplier_Region__c>();
       Map<String,Supplier__c> suppMap = new Map<String,Supplier__c>();
     
        //get the batch Supplier region maps
            for(SASF7525_Supplier_Region__c SASF7525SupplierRegionLoop : SASF7525SuppRegList)
            {
                batchSuplierNumberRegionMap.put(SASF7525SupplierRegionLoop.Supplier_Num__c, SASF7525SupplierRegionLoop);
                suppNumList.add(SASF7525SupplierRegionLoop.Supplier_Num__c);
            }
      
        //get the region according to geocode
        for(Region__c region : [select r.Id, r.Name, r.Geography_Code__c from Region__c r]){
            regionMap.put(region.Geography_Code__c, region);
           }
           
    
         //create a map of the suppliers
         for(Supplier__c suppObject : [select s.Supplier_Num__c, s.Status_code__c, s.Name, s.Id From Supplier__c s where Supplier_Num__c IN : suppNumList]){
            suppMap.put(suppObject.Supplier_Num__c,suppObject); 
         }
        
    
    //Inserting suppliers regions.
     for(SASF7525_Supplier_Region__c SASF7525Supp : batchSuplierNumberRegionMap.values()){
                        
            Supplier_Region__c suppRegionObj = new Supplier_Region__c();
           
            String supplierNumber = SASF7525Supp.Supplier_Num__c;
            if(suppMap.get(supplierNumber) != null)
            {
                suppRegionObj.Supplier__c = suppMap.get(supplierNumber).Id;
                suppRegionObj.Name = SASF7525Supp.Name;
                suppRegionObj.Business_Unit__c = SASF7525Supp.Business_Stream__c;
                suppRegionObj.Status_Code__c = SASF7525Supp.Status_Code__c;
                String geoCode =null;
                if(regionMap.get(SASF7525Supp.Geography_Code__c) != null)
                {
                    geoCode = regionMap.get(SASF7525Supp.Geography_Code__c).Id;
                }
                if((SASF7525Supp.Geography_Code__c != null || SASF7525Supp.Geography_Code__c.length() > 0) && (geoCode != null )){
                     suppRegionObj.Region__c =regionMap.get(SASF7525Supp.Geography_Code__c).Id;
                }
                else {//this is temporary since there are many dummy records without geo code.
                    suppRegionObj.Region__c = 'a0ER0000005PIEx';
                }
                //suppRegionObj.Postcode_Sector__c =SASF7525Supp.Geography_Code__c;    
                suppRegionObj.Supplier_Number__c = SASF7525Supp.Supplier_Num__c;
                suppRegionObj.Vendor_Change_date__c = SASF7525Supp.Vendor_Change_date__c;
                upsertSupplierRegionList.add(suppRegionObj);
             }
    }
   
    if(upsertSupplierRegionList != null && upsertSupplierRegionList.size()> 0){
       
       try{
        upsert upsertSupplierRegionList Supplier_Number__c; 
        }
        catch(exception ex){
        system.debug('----ex--'+ex);
       }
   } 
   
   
   
 }   
}