trigger RMTSupplier on RMT_Supplier__c (after update) {


List<id> RMTSupplier = new list<id> ();
List<id> RMTSupplier1 = new list<id> (); //For Email Change
List<id> RMTSupplier2 = new list<id> (); //For RMT supplier is Inactive
Map<id,string> RMTMap = new Map<id,string>();

//list<week__c> updateWeekList= new list<week__c>();
string newStatus;
Boolean newEmpStatus;
string rmtSubStatus;
string rmtStatus;
string newStatus1;
string newSubstatus1;
map<string, string> riskCategoryMap = new map<string, string>();

if(Trigger.isUpdate && Trigger.isAfter){
    for (RMT_Supplier__c supplier : trigger.new)
    {
        RMT_Supplier__c oldRMT = trigger.oldmap.get(supplier.id); 
        RMT_Supplier__c newRMT = trigger.newmap.get(supplier.id);
        rmtStatus = newRMT.Supplier_status__c;
        
        if(newRMT.P5_Vendor_Number__c!= null && oldRMT.Risk_Category__c != newRMT.Risk_Category__c ||  system.label.SystemAdminId.contains(userinfo.getProfileId()) )
        {
            riskCategoryMap.put(newRMT.P5_Vendor_Number__c, newRMT.Risk_Category__c);
        }
        //Where the RMT Supplier is made inactive
        if ((oldRMT.Supplier_status__c <> newRMT.Supplier_status__c) && newRMT.Supplier_status__c == 'Active')
        {
            system.debug('Inside Active');
            newStatus = 'Active';
            newEmpStatus = false;
            RMTSupplier.add(newRMT.id);
            
        }
        
        if(oldRMT.Supplier_Email__c <> newRMT.Supplier_Email__c){
           system.debug('Inside Email Change');
           RMTSupplier1.add(newRMT.id);
           RMTMap.put(supplier.id,newRMT.Supplier_Email__c);
        }
        
        //Where the RMT supplier is made Inactive
        if ((oldRMT.Supplier_status__c <> newRMT.Supplier_status__c) && newRMT.Supplier_status__c == 'Inactive')
        {
            system.debug('Inside Inactive');
            newStatus1 = 'Inactive';
            newSubstatus1 = newRMT.Sub_status__c;
            RMTSupplier2.add(newRMT.id);
            
        }
        
     }
     
     if(RMTSupplier.size()>0 && newStatus != null){
               system.debug('---------->'+newStatus+' '+rmtStatus);
               RMTsupplierUtility.ActivateSupplier(newStatus,newEmpStatus,RMTSupplier,rmtStatus);
     }
     
     if(RMTSupplier1.size()>0 && RMTMap.size()>0){
              RMTsupplierUtility.RunEmailChange(RMTSupplier1,RMTMap);
     }
     
     if(RMTSupplier2.size()>0 && newStatus1 != null){
              system.debug('--->'+newstatus1+' '+newSubstatus1);
              RMTsupplierUtility.RunInactiveSupplier(newStatus1,newSubstatus1,RMTSupplier2);
     }
     
     
     if(riskCategoryMap.size()>0)
     RMTsupplierUtility.updateRiskCategory(riskCategoryMap);
          
     
 }  
}