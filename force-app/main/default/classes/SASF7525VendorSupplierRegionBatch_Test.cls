/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SASF7525VendorSupplierRegionBatch_Test {

    static testMethod void testdata() {
        //inserting supplier
        
        Supplier__c supp = new Supplier__c(Name='TestSBB Supplier', Supplier_Num__c = '875411', Type__c = 'Resource', 
                                            Resource_Type__c='Own Labour');
        insert supp;
        
        //inserting Region.
        Region__c testRegion = new Region__c(Name='Test Region', Code__c = 'TR99', Type__c='Installation');
        testRegion.Geography_Code__c='34';
        Database.insert(testRegion);
        
        //inserting another region
        
        Region__c testRegion1 = new Region__c(Name='Test Region1', Code__c = 'TR98', Type__c='Installation');
        testRegion1.Geography_Code__c='33';
        Database.insert(testRegion1);
        
        //inserting SASF7525 Batch record   
        
        SASF7525_Batch__c batchsupplierrgn = new SASF7525_Batch__c(Batch_Status__c =1,Geography_Row_Count__c =2,Record_Count__c=2);
        insert batchsupplierrgn;
        
        //Defing the List
        List<SASF7525_Supplier_Region__c> lst_suppregion = new List<SASF7525_Supplier_Region__c>();
        
        //INserting the first supplier region
        
        SASF7525_Supplier_Region__c supplierregion = new SASF7525_Supplier_Region__c(Name='TestSBB Supplier', Vendor_Change_date__c = system.today(),Supplier_Num__c = supp.Supplier_Num__c, SASF7525_Batch__c= batchsupplierrgn.id,Geography_Code__c = '34' ,Business_Stream__c ='CH');
        insert supplierregion;
        lst_suppregion.add(supplierregion);
        
        //inserting the second supplier region
        
        SASF7525_Supplier_Region__c supplierregion1 = new SASF7525_Supplier_Region__c(Name='TestSBB Supplier', Vendor_Change_date__c = system.today(),Supplier_Num__c = supp.Supplier_Num__c, SASF7525_Batch__c= batchsupplierrgn.id,Geography_Code__c = '33' ,Business_Stream__c ='CH');
        insert supplierregion1;
        lst_suppregion.add(supplierregion1);
        
        //Starting the Batch class.
        
        SASF7525VendorSupplierRegionBatch suppregion = new SASF7525VendorSupplierRegionBatch();
        Database.BatchableContext BC;
        Test.startTest();
        suppregion.createVendorBatch();   
        suppregion.execute(BC,lst_suppregion);
        suppregion.finish(BC);
        //batchsupplierrgn.Batch_Status__c =2;
        Test.stopTest();
          
    }
}