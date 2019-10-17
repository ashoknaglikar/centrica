@isTest
private class SAPHREmployee_Test {
    
    static SAHRSF_Employee__c objSAHRSF;
    static SAHRSF_Employee__c objSAHRSF1;
    static Employee__c emp;
    static List<SAHRSF_Employee__c> SAHRSFlist;
    static SAHRSF_Batch__c SaHrsf_batch;
    
    static testMethod void prepareTestData()
    {
        SaHrsf_batch = new SAHRSF_Batch__c();        
        SaHrsf_batch.Record_Count__c = 2;        
        insert SaHrsf_batch; 
                
        objSAHRSF = new SAHRSF_Employee__c();
        objSAHRSF.Pay_Number__c = '123';
        objSAHRSF.First_Name__c = 'Test1';
        objSAHRSF.Last_Name__c = 'Prod';
        objSAHRSF.Middle_Name__c = 'I';
        objSAHRSF.Error_Text__c = '';
        objSAHRSF.Processed__c = false;
        objSAHRSF.SAHRSF_Batch__c = SaHrsf_batch.id;
        insert objSAHRSF;
        
        /*objSAHRSF1 = new SAHRSF_Employee__c();    
        objSAHRSF1.Pay_Number__c = '123876';
        objSAHRSF1.First_Name__c = 'Test2';
        objSAHRSF1.Last_Name__c = 'Prod2';
        objSAHRSF1.Middle_Name__c = 'J';
        objSAHRSF1.Error_Text__c = '';
        objSAHRSF1.Processed__c = false;
        objSAHRSF1.SAHRSF_Batch__c = SaHrsf_batch.id;
        insert objSAHRSF1;*/
        SAHRSFlist = [Select Pay_Number__c, First_Name__c, Last_Name__c,  Middle_Name__c,Error_Text__c From SAHRSF_Employee__c Where id =:objSAHRSF.id ];
        
        //SAHRSFlist.add(objSAHRSF);
        //SAHRSFlist.add(objSAHRSF1);
        
        /*emp = new Employee__c(Name = 'testJI1', First_Name__c = 'SBB1', Last_Name__c = 'Test1',Supplier__c=supplier.Id,
                                         Employee_Number__c = '0002991',Resource_Id__c='7fejs2',Resource_Type__c='Installer');
        
        employees = new Employee__c[]{emp};                                          
        insert employees;*/
        
        
      
          
        
        
        SAPHREmployee SAPHR = new SAPHREmployee(SaHrsf_batch.id);
        Test.startTest();
        String s1='12';
        SAPHREmployee.ActDeact(s1);
        Database.BatchableContext BC;
        //EDIS.start(BC);
        //SAPHR.execute(BC,SAHRSFlist);
         database.executeBatch(SAPHR);  
        Test.stopTest();                     
     //   SAPHR.finish(BC);
      
     }
    }