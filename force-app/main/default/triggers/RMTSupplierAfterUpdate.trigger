trigger RMTSupplierAfterUpdate on RMT_Supplier__c (after update) {
/*
// Created by Phil Dennison 08-07-2012

List<P5_RMT_Contractors__c> Contractors;
List<employee__c> employeeList;
List<string> supplierNums = new List<string> ();
List<id> RMTSupplier = new list<id> ();
string newStatus;
Boolean newEmpStatus;
string rmtSubStatus;
string rmtStatus;

    for (RMT_Supplier__c supplier : trigger.new)
    {
        RMT_Supplier__c oldRMT = trigger.oldmap.get(supplier.id); 
        RMT_Supplier__c newRMT = trigger.newmap.get(supplier.id);
        rmtStatus = newRMT.Supplier_status__c;
    
        //Where the RMT Supplier is made inactive
        if ((oldRMT.Supplier_status__c <> newRMT.Supplier_status__c) && newRMT.Supplier_status__c == 'Inactive')
        {
            newStatus = 'Inactive';          
            rmtSubStatus = newRMT.Sub_status__c;
            newEmpStatus = true;
            RMTSupplier.add(newRMT.id);
            if(newRMT.supplier_number__c!=null){
                supplierNums.add(newRMT.supplier_number__c);
            }
        }
        
        //Where the RMT Supplier is made inactive
        if ((oldRMT.Supplier_status__c <> newRMT.Supplier_status__c) && newRMT.Supplier_status__c == 'Active')
        {
            newStatus = 'Active';
            newEmpStatus = false;
            RMTSupplier.add(newRMT.id);
            if(newRMT.supplier_number__c!=null){
                supplierNums.add(newRMT.supplier_number__c);
            }
        }
     }
          
     Contractors = [SELECT id, autoInactiveUpdate__c FROM P5_RMT_Contractors__c 
                    WHERE P5_Status__c !=: newStatus AND Supplier__c in :RMTSupplier];   
     
     if(newStatus == 'Active')
        {
         for (P5_RMT_Contractors__c childContractor: Contractors)
         {
             If(childContractor.AutoInactiveUpdate__c == true)
             {
                 childContractor.P5_Status__c = 'Active';
                 childContractor.AutoInactiveUpdate__c = false;
                 childContractor.Sub_status__c = '';
             }
         }
    }else{
         for (P5_RMT_Contractors__c childContractor: Contractors){
             childContractor.P5_Status__c = 'Inactive';
             childContractor.AutoInactiveUpdate__c = true;
             childContractor.Sub_status__c = rmtSubStatus;
         }
    } 
     
     if(contractors.size() > 0){      
     update Contractors;     // Set all contractors to inactive status.
     } 
     
     List<Note> empNotes = new List<Note> ();

     if(supplierNums.size() > 0){     
         if(rmtStatus == 'Active'){
         // Active
         EmployeeList = [   SELECT id FROM employee__c 
                            WHERE inactive__c !=: newEmpStatus 
                            AND employee__c.autoInactiveUpdate__c = true  
                            AND supplier_Branch_num__c in :supplierNums];
         for (employee__c childEmployee: EmployeeList){
             Note note = new Note();
             childEmployee.inactive__c = newEmpStatus;
             childEmployee.Locked_By_Admin__c = newEmpStatus;
             childEmployee.RMT_Suspended_Date__c = null;
             childEmployee.autoInactiveUpdate__c = false;
             childEmployee.RMT_Suspended_Reason__c = '';
             note.Title = 'Made active';
             note.ParentId = childEmployee.id; 
             empNotes.add(note);
         }    
         }else{
         // Inactive
         EmployeeList = [SELECT id FROM employee__c 
                            WHERE inactive__c !=: newEmpStatus 
                            AND supplier_Branch_num__c in :supplierNums];
         for (employee__c childEmployee: EmployeeList){
             Note note = new Note();
             childEmployee.inactive__c = newEmpStatus;
             childEmployee.Locked_By_Admin__c = newEmpStatus;
             childEmployee.RMT_Suspended_Date__c = system.today();
             childEmployee.autoInactiveUpdate__c = true;
             childEmployee.RMT_Suspended_Reason__c = rmtSubStatus;
             note.Title = 'Made inactive - ' + rmtSubStatus;         
             note.ParentId = childEmployee.id; 
             empNotes.add(note);
         }
        }
      
        if(EmployeeList.size() > 0){update EmployeeList;}
        if(empNotes.size() > 0){insert empNotes;}
     }*/
}