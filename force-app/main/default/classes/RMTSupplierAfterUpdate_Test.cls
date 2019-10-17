// Test Class Created by Phil Dennison on 06/07/12

@isTest
private class RMTSupplierAfterUpdate_Test {

static RMT_Supplier__c          RMTSupplier;
static P5_RMT_Contractors__c    Contractor; 
static Supplier__c              supplier;
static employee__c              employee;
static id                       SuppplierRecTypeID = RecordTypeIdHelper.getRecordTypeId('Supplier__c','Resource Supplier');
static id                       RMTSuppRecTypeID = RecordTypeIdHelper.getRecordTypeId('RMT_Supplier__c','Supplier');


    static void createTestData() {

        //Create RMT Supplier - ACTIVE 
        RMTSupplier = TestClassHelper.createRMTSupplier();
		RMTSupplier.RecordTypeId = RMTSuppRecTypeID;
        insert RMTSupplier;
    
        //Create Contractor  - ACTIVE
        Contractor = TestClassHelper.createContractor();
        Contractor.Supplier__c = RMTSupplier.Id;
        insert Contractor;
        
        //Create Supplier - ACTIVE
        Supplier = TestClassHelper.createSupplier();
        Supplier.RecordTypeId = SuppplierRecTypeID;
        insert supplier;
        
        //Create Employee - ACTIVE
        employee = TestClassHelper.createEmployee();
        employee.Supplier__c = supplier.Id;
        insert employee;        
    }
    
    static testMethod void runTest(){
        createTestData();  
        
        RMTSupplier.supplier_status__c = 'Inactive';
        update RMTSupplier;

        RMTSupplier.supplier_status__c = 'Active';
        update RMTSupplier;    
    }
}