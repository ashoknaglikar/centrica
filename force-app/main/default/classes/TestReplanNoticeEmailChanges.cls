public with sharing class TestReplanNoticeEmailChanges {

  public static testMethod void testReplanNoticeEmailChanges(){
  	
  	// Create job record
  	Job__c job = Phase3TestHelper.createJob1();
  	job.Delivery_Date__c = (Date.Today() - 1000);
  	job.Delivery_Slot__c = '13:00 - 15:00';
  	Database.update(job);
  	
  	// Create supplier record
  	Supplier__c supplier = new supplier__c(Name='Test Replan',Type__c='Product',Supplier_Num__c='RR2184',Resource_Type__c='Product');
    insert supplier;
    
    // Create merchant order record
    order__c ord = new order__c();
    ord.Job__c= job.Id;
    ord.Status__c = 'Active';
    ord.Supplier__c=supplier.Id;
    ord.Type__c = 'Material';
    insert ord;
    
    // Create controller references and instances from VF controller
  	ApexPages.StandardController controller = new ApexPages.StandardController(job);
    PageReference pageRef = new PageReference('/apex/DeliveryDetailsReadInline?id='+job.Id);
    Test.setCurrentPage(pageRef);
    DeliveryDetailsReadEditInlineController controller1 = new DeliveryDetailsReadEditInlineController(controller);
    
    // Test genReplanNotice method from VF controller
    ord.Delivery_Date_Changed__c = true;
    Pagereference pgGenReplanPDF = controller1.genReplanNotice();
    ord.Delivery_Date_Changed__c = false;
    Database.update(ord);
    
    // Test editJob and cancelEdit methods from VF controller
    Pagereference editJob = controller1.editJob();
    Pagereference cancelEdit = controller1.cancelEdit();
    
    // Test saveJob method
    controller1.priorDeliveryDate = ((Date.Today() - 2000));
    controller1.priorDeliverySlot = '15:00 - 17:00';
    Pagereference saveJob = controller1.saveJob();
    
    // Test replan batch now
     Test.startTest();
     ord.Send_via_email__c = true;
     Database.update(ord);
     Order__c ordRecord = [Select Name,Status__c,could_not_process__c,Original_Order_Value__c,
							         Job__r.Primary_Contact__c, Type__c,Supplier__r.Resource_Type__c,Order_Date__c, Job__c, Job_Delivery_Date__c, Id, Approved__c, CreatedDate,
							         Job__r.region__c, Supplier__r.Supplier_Num__c, Job__r.Name,Supplier__r.Type__c, 
							         P5_SAP_Status__c,Job__r.Account__c,Job__r.Account__r.Primary_Contact__c,
							         Job__r.CHI_Lead__r.CHI_Lead_Id1__c,Job__r.Account__r.BillingStreet,Job__r.Account__r.BillingCity,
							         Job__r.Account__r.BillingCountry, Job__r.Account__r.BillingPostalCode, 
							         Job__r.Account__r.BillingState, Job__r.Delivery_Date__c, P5_Order_Cancellation_Date__c,
							         Amendment_Number__c, P5_Order_Amendment_Date__c, P5_Number_Of_Line_Items__c, 
							         Job__r.District__r.Region__r.Code__c, P5_Account_Assignment_Category__c,Job__r.CHI_Lead__c 
							         From order__c where Id = :ord.Id];
     List<Order__c> ordList = new List<Order__c>();
     ordList.add(ordRecord);
     SendReplanPDFViaEmail sendReplanPDF = new SendReplanPDFViaEmail();
     Database.BatchableContext BC; 
     sendReplanPDF.execute(BC,ordList);
     sendReplanPDF.finish(BC);
     sendReplanPDF.getDummyCoverage();
     Test.StopTest();
    
  }

}