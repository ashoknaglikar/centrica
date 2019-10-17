trigger bINSUPDFaxNumber on order__c (before insert, before update) {
    
    Map<String,String> branchFaxNumberMap=new Map<String,String>{};
    Map<String,String> branchEmailAddress=new Map<String,String>{};
    Set<String> branchNumberSet=new Set<String>{};
   
    try {
         for(order__c objOrder:Trigger.new){
         
          order__c oldorder = trigger.oldMap.get(objOrder.Id);
          if(oldorder.SupplierBranchNum__c!= objOrder.SupplierBranchNum__c){
          
            branchNumberSet.add(objOrder.SupplierBranchNum__c);
            branchFaxNumberMap.put(objOrder.SupplierBranchNum__c,'');
            branchEmailAddress.put(objOrder.SupplierBranchNum__c,'');  
          
          }
          
        /*for (order__c objOrder:Trigger.new){
             string oldval=oldOrderList.SupplierBranchNum__c;
             String newval=objOrder.SupplierBranchNum__c;
            branchNumberSet.add(objOrder.SupplierBranchNum__c);
            branchFaxNumberMap.put(objOrder.SupplierBranchNum__c,'');
            branchEmailAddress.put(objOrder.SupplierBranchNum__c,'');  
            */ 
        }
        
        for(Supplier_Branch__c objSupplierBranch:[Select Branch_Num__c, Fax_Number__c,
                                                    Branch_Email__c from Supplier_Branch__c Where Branch_Num__c In:branchNumberSet]){
            branchFaxNumberMap.put(objSupplierBranch.Branch_Num__c,objSupplierBranch.Fax_Number__c);
            branchEmailAddress.put(objSupplierBranch.Branch_Num__c,objSupplierBranch.Branch_Email__c);  
        }
        for (Supplier__c objSupplier:[Select Supplier_Num__c,Fax__c,Supplier_Email__c
                                        from Supplier__c Where Supplier_Num__c In:branchNumberSet]){
            branchFaxNumberMap.put(objSupplier.Supplier_Num__c,objSupplier.Fax__c);
            branchEmailAddress.put(objSupplier.Supplier_Num__c,objSupplier.Supplier_Email__c);                                      
        }
        
        for (order__c objOrderNew:Trigger.new){
            objOrderNew.Supplier_Email_Address__c=branchEmailAddress.get(objOrderNew.SupplierBranchNum__c);
            objOrderNew.Supplier_Fax_number__c=branchFaxNumberMap.get(objOrderNew.SupplierBranchNum__c);
        }
    } catch(Exception ex){
        System.debug('Error : ' + ex.getMessage());
    }
    
}