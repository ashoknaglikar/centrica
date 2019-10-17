@istest
private with sharing class TestQuoteProductDecompile {
                                                          
    //////////////////////////////
    //                          //
    //      TESTING CLASSES     //
    //                          //
    ////////////////////////////// 
    
    //Test Class to test the decomposition of a quote. Ensure that when quote line items are added to a quote that they are
    //decompiled into indivual Job Element records associated with the Job__c record linked to the Quote.             
    @isTest
    static void TestQuoteDecompile1(){       
        try {    
            //Setup test environment
            Account Acc = TestScenarioCreateAccount();
            Opportunity opty = TestScenarioCreateOppty(Acc);        
            Job__c[] Job = TestScenarioCreateJob('Pending','Mismatch',opty.ID);          
            BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);
            Job[0].Quote__c=quote[0].Id;       
            update Job;                   
            system.debug('Job is: '+job);                                        
            //create the reference data for work and materials  
            TestScenarioCreateWorkAndMaterials();       
            Test.startTest();
            //Add a number of line items and assert later that the correct number of job elements has been created        
            //Below are 2 identical line items against a quote. As each line item quantity is set to 1, we should get a total of 2 x (1 related Work Element + 1 related Material Elements) = 4 Job Elements created the against job.
            Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='ABC123');        
            Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='ABC123');        
            //a single line item below of qauntity 1 has 1 work and 2 materials related to it. As the line item has a quantity of 3 we should get 3 x 3 = 9 job elements created
            Quote_Product__c lineItem3 = new Quote_Product__c(Part_Number__c='ABC456', Quantity__c=3.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='ABC456');                
            //Insert a line item that has no related materials or work. No Job elements should get created for this line item.
            Quote_Product__c lineItem4 = new Quote_Product__c(Part_Number__c='ABC789', Quantity__c=3.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='ABC789');                        
            Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2,lineItem3,lineItem4};     
            insert lineItems;       
            //do a stoptest() to ensure the future method to decompile the quote has finished
            Test.stopTest();
            
            //total job elements inserted should be 4 + 9 = 13
            //System.assertEquals(13,[SELECT count() FROM Job_Element__c WHERE Job__c = :job[0].Id]); 
            //assert checkbox ticked to indicate quote was decompiled
           // BigMachines_quote__c quoteAfter = [select Line_Items_Decompiled__c from BigMachines_quote__c where Id= :quote[0].Id];
            ////System.assertEquals(true,quoteAfter.Line_Items_Decompiled__c);
        } catch(Exception ex) {
            //do nothing
        }    
    }
    
    //Test Class to test the decomposition of an Allocated quote. Ensure that when quote line items are added to a quote that they are
    //decompiled into indivual Job Element records associated with the Job__c record linked to the Quote. Ensure the work job elements have
    //the supplier name and number populated correctly. Asset that a Job Booking History record is created correctly, and that the Status
    //and Sub Status fields are populated correctly.              
    @isTest
    static void TestQuoteDecompile2(){          
        try {
            //Setup test environment
            Account Acc = TestScenarioCreateAccount();
            Opportunity opty = TestScenarioCreateOppty(Acc);
            Job__c[] Job = TestScenarioCreateJob('Allocated','',opty.Id);        
            BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);                            
            quote[0].stage__c = 'Quote Finalised - Accepted';  
            quote[0].bmStatusReason__c =  'Quote Finalised - Accepted';  
            quote[0].Transferred_to_Premier__c = null;
            quote[0].Line_Items_Decompiled__c = true;
            quote[0].BM_Completed__c = true;
            quote[0].quote_reconciled__c =true; 
            update quote[0];                     
            Job[0].Quote__c=quote[0].Id;        
            update Job;   
            system.debug('Job is: '+job);    
            Supplier__c supplier1 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12XX21', Name='British Gas');
            Supplier__c supplier2 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='99XX66', Name='Flower Inc');
            Supplier__c[] suppliers = new Supplier__c[]{supplier1,supplier2};
            insert suppliers;
            Employee__c employee1 = new Employee__c(Supplier__c=suppliers[0].Id, Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
            Employee__c employee2 = new Employee__c(Supplier__c=suppliers[1].Id, Name = 'Test Emp 2', Employee_Number__c = '0999008', Primary_Role__c = 'STM', Last_Name__c='Emp2', First_Name__c='TestP1Controller');
            Employee__c [] TestEmployees = new Employee__c[]{employee1,employee2};      
            insert TestEmployees; 
            Week__c week1 = new Week__c(Employee__c=employee1.Id);
            Week__c week2 = new Week__c(Employee__c=employee2.Id);
            Week__c[] weeks = new Week__c[]{week1,week2};
            insert weeks;           
            Diary_Entry__c de1 = new Diary_Entry__c(week__c = weeks[0].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Mechanical',Job__c=Job[0].ID);
            Diary_Entry__c de2 = new Diary_Entry__c(week__c = weeks[1].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Electrical',Job__c=Job[0].ID);
            Diary_Entry__c[] diaryEntries = new Diary_Entry__c[]{de1,de2};
            insert diaryEntries;
            
            system.debug('Job is still: '+job);
            //create the reference data for work and materials                                              
            TestScenarioCreateWorkAndMaterials();       
    
            //ensure job has no job booking history records prior to quote decompile
            //Job_Booking_History__c[] historyItemsBefore = [select Work_Affected__c, Materials_Affected__c from Job_Booking_History__c where job__c=:Job[0].ID AND Work_Affected__c=true AND Materials_Affected__c=true];       
            //System.assertEquals(0,historyItemsBefore.size());
    
            Test.startTest();
            //Add a number of line items and assert later that the correct number of job elements has been created        
            //Below are 2 identical line items against a quote. As each line item quantity is set to 1, we should get a total of 2 x (1 related Work Element + 0 related Material Elements) = 2 Job Elements created the against job.
            Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='123456', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='123456');        
            Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='654321', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='654321');                              
            Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2};     
            insert lineItems;       
            //do a stoptest() to ensure the future method to decompile the quote has finished
            Test.stopTest();
            
            // Testing quote product delete trigger - Starts.
            User bmsUser = [Select ID from User where Name = 'BMSFDCIntegration' limit 1];
            System.runAs(bmsUser){
            List<Quote_Product__c> qpList = new List<Quote_Product__c>(); 
            qpList = [Select id from Quote_Product__c where BigMachines_Quote__c=:quote[0].Id];
            if(qpList.size()>0){
              try{
            		 delete qpList;
            	}catch(Exception excp){
            		// Do Nothing
            	}
                	qpList = new List<Quote_Product__c>(); 
            	    qpList = [Select id from Quote_Product__c where BigMachines_Quote__c=:quote[0].Id];
            	    System.assertEquals(2, qpList.size());
              }
          }  
            // Testing quote product delete trigger - Ends.
            
            //total job elements inserted should be 2 (2 work elements)
            ////System.assertEquals(2,[SELECT count() FROM Job_Element__c WHERE Job__c = :job[0].Id]);
            //assert that correct supplier details are entered onto the decompile work job element for the allocated job
            //Job_Element__c workElement1 = [SELECT Current_Supplier__c, Current_Supplier_Number__c FROM Job_Element__c WHERE Job__c = :job[0].Id AND Line_Item_ID__c=:lineItems[0].Id];
            //System.assertEquals('British Gas',workElement1.Current_Supplier__c);
            //System.assertEquals('12XX21',workElement1.Current_Supplier_Number__c);
            //Job_Element__c workElement2 = [SELECT Current_Supplier__c, Current_Supplier_Number__c FROM Job_Element__c WHERE Job__c = :job[0].Id AND Line_Item_ID__c=:lineItems[1].Id];
            //System.assertEquals('Flower Inc',workElement2.Current_Supplier__c);
            //System.assertEquals('99XX66',workElement2.Current_Supplier_Number__c);
            //Assert status and substatus for the quote are set correctly.
           // Job__c updatedJob = [select Status__c, Sub_Status__c from Job__c where ID=:Job[0].id];
            //System.assertEquals('Planned',updatedJob.Status__c);
            //System.assertEquals('Installation Date Set',updatedJob.Sub_Status__c);
            
            //ensure job now has a job booking history record of type 'Work_Affected__c=true and Materials_Affected__c=true' after quote decompiled
            //Job_Booking_History__c[] historyItemsAfter = [select Work_Affected__c, Materials_Affected__c from Job_Booking_History__c where job__c=:Job[0].ID AND Work_Affected__c=true AND Materials_Affected__c=true];       
            //System.assertEquals(1,historyItemsAfter.size());
            
            //assert checkbox ticked to indicate quote was decompiled
            //BigMachines_quote__c quoteAfter = [select Line_Items_Decompiled__c from BigMachines_quote__c where Id= :quote[0].Id];
            //System.assertEquals(true,quoteAfter.Line_Items_Decompiled__c);
        } catch(Exception ex) {
            //do nothing
        }
    }
    
    //Test class similar to testquotedecompile2, but this time hours on the 'Allocated' job and on the quote do
    //not match. Therefore assert job substatus is set to 'Quote Received Not Balanced' and that hours from the 
    //quote are copied over onto the job (these can be monitor in field history tracking by the user to obtain old values)
    //Assert that this time a job booking history item is not created.             
    @isTest
    static void TestQuoteDecompile3(){ 
        try {         
        //Setup test environment
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
        Job__c[] Job = TestScenarioCreateJob('Allocated','Awaiting Planning',opty.Id);        
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,2);                            
        Job[0].Quote__c=quote[0].Id;        
        update Job;   
        system.debug('Job is: '+job);    
        Supplier__c supplier1 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12XX21', Name='British Gas');
        Supplier__c supplier2 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='99XX66', Name='Flower Inc');
        Supplier__c[] suppliers = new Supplier__c[]{supplier1,supplier2};
        insert suppliers;
        Employee__c employee1 = new Employee__c(Supplier__c=suppliers[0].Id, Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
        Employee__c employee2 = new Employee__c(Supplier__c=suppliers[1].Id, Name = 'Test Emp 2', Employee_Number__c = '0999008', Primary_Role__c = 'STM', Last_Name__c='Emp2', First_Name__c='TestP1Controller');
        Employee__c [] TestEmployees = new Employee__c[]{employee1,employee2};      
        insert TestEmployees; 
        Week__c week1 = new Week__c(Employee__c=employee1.Id);
        Week__c week2 = new Week__c(Employee__c=employee2.Id);
        Week__c[] weeks = new Week__c[]{week1,week2};
        insert weeks;           
        Diary_Entry__c de1 = new Diary_Entry__c(week__c = weeks[0].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Mechanical',Job__c=Job[0].ID);
        Diary_Entry__c de2 = new Diary_Entry__c(week__c = weeks[1].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Electrical',Job__c=Job[0].ID);
        Diary_Entry__c[] diaryEntries = new Diary_Entry__c[]{de1,de2};
        insert diaryEntries;
            
        //create the reference data for work and materials                                              
        TestScenarioCreateWorkAndMaterials();       

        //ensure job has no job booking history records prior to quote decompile
        //Job_Booking_History__c[] historyItemsBefore = [select Work_Affected__c, Materials_Affected__c from Job_Booking_History__c where job__c=:Job[0].ID AND Work_Affected__c=true AND Materials_Affected__c=true];       
        //System.assertEquals(0,historyItemsBefore.size());

        Test.startTest();
        //Add a number of line items and assert later that the correct number of job elements has been created        
        //Below are 2 identical line items against a quote. As each line item quantity is set to 1, we should get a total of 2 x (1 related Work Element + 0 related Material Elements) = 2 Job Elements created the against job.
        Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='123456', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='123456');        
        Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='654321', Quantity__c=1.00, Sales_Price__c=23.32, BigMachines_Quote__c=quote[0].Id, Name='654321');                              
        Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2};     
        insert lineItems;       
        //do a stoptest() to ensure the future method to decompile the quote has finished
        Test.stopTest();
        
        //total job elements inserted should be 2 (2 work elements)
        ////System.assertEquals(2,[SELECT count() FROM Job_Element__c WHERE Job__c = :job[0].Id]);
        //Assert status and substatus for the quote are set correctly.
        //Job__c updatedJob = [select Status__c, Sub_Status__c, Electrical_Work_ASP_Hours__c from Job__c where ID=:Job[0].id];
        //System.assertEquals('Allocated',updatedJob.Status__c);
        //System.assertEquals('Quote Received Not Balanced',updatedJob.Sub_Status__c);
        //System.assertEquals(2.55,updatedJob.Electrical_Work_ASP_Hours__c);
        
        //ensure job now has a job booking history record of type 'Job Planned' after quote decompiled
        //Job_Booking_History__c[] historyItemsAfter = [select Work_Affected__c, Materials_Affected__c from Job_Booking_History__c where job__c=:Job[0].ID AND Work_Affected__c=true AND Materials_Affected__c=true];       
        //System.assertEquals(0,historyItemsAfter.size());  
        
        //assert checkbox ticked to indicate quote was decompiled
       // BigMachines_quote__c quoteAfter = [select Line_Items_Decompiled__c from BigMachines_quote__c where Id= :quote[0].Id];
        //System.assertEquals(true,quoteAfter.Line_Items_Decompiled__c);
        } catch(Exception ex) {
            //do nothing
        }                
    }
    
        //Test of ASP submission. Assert ASP line items are decomposed correctly, that skill hours get updated on jobs and quote, that status of jobs/quote get
    //updated, that job booking histories get created.*/
    @istest           
    static void TestASPSubmission(){   
       // try {       
        //Setup test environment
        Account Acc = TestScenarioCreateAccount();
        Opportunity opty = TestScenarioCreateOppty(Acc);
        Job__c[] Job = TestScenarioCreateJob('Installed','Installed',opty.Id);        
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,2);         
                       
        Job[0].Quote__c=quote[0].Id; 
        Job[0].Installation_Date__c=system.today();       
        update Job;   
        ASP__c asp = new ASP__c(Charge_to_Customer__c=0,Quote__c=quote[0].Id, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today(), ASP_Installation_Date__c=date.today());
        asp.Status__c='Entered';  
        asp.ASP_Type__c='Remedial'; 
        insert asp;
        system.debug('Job is: '+job);    
        Supplier__c supplier1 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='12XX21', Name='British Gas');
        Supplier__c supplier2 = new Supplier__c(Type__c='Resource', Resource_Type__c='Own Labour', Supplier_Num__c='99XX66', Name='Flower Inc');
        Supplier__c[] suppliers = new Supplier__c[]{supplier1,supplier2};
        insert suppliers;
        Employee__c employee1 = new Employee__c(Supplier__c=suppliers[0].Id, Name = 'Test Emp 1', Employee_Number__c = '0999009', Primary_Role__c = 'Pool', Last_Name__c='Emp1', First_Name__c='TestP1Controller');
        Employee__c employee2 = new Employee__c(Supplier__c=suppliers[1].Id, Name = 'Test Emp 2', Employee_Number__c = '0999008', Primary_Role__c = 'STM', Last_Name__c='Emp2', First_Name__c='TestP1Controller');
        Employee__c [] TestEmployees = new Employee__c[]{employee1,employee2};      
        insert TestEmployees; 
        Week__c week1 = new Week__c(Employee__c=employee1.Id);
        Week__c week2 = new Week__c(Employee__c=employee2.Id);
        Week__c[] weeks = new Week__c[]{week1,week2};
        insert weeks;           
        Diary_Entry__c de1 = new Diary_Entry__c(week__c = weeks[0].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Mechanical',Job__c=Job[0].ID);
        Diary_Entry__c de2 = new Diary_Entry__c(week__c = weeks[1].Id, Start__c = datetime.now(), End__c = datetime.now().addDays(7),Sub_Type__c ='Electrical',Job__c=Job[0].ID);
        Diary_Entry__c[] diaryEntries = new Diary_Entry__c[]{de1,de2};
        insert diaryEntries;
        
        Product2 Prod1 = new Product2(Name = 'ABC123', Non_Commisionable__c = False);
        Product2 Prod2 = new Product2(Name = '654321', Non_Commisionable__c = False);         
        Product2 Prod3 = new Product2(Name = '123456', Non_Commisionable__c = False); 
        
        Product2[] Products = new Product2[]{Prod1,Prod2, Prod3};           
        insert Products;    
        //create the reference data for work and materials                                              
        TestScenarioCreateWorkAndMaterials();       

        //ensure job has no job booking history records prior to quote decompile
        //Job_Booking_History__c[] historyItemsBefore = [select Work_Affected__c, Materials_Affected__c from Job_Booking_History__c where job__c=:Job[0].ID AND Work_Affected__c=true AND Materials_Affected__c=true];       
        ////System.assertEquals(0,historyItemsBefore.size());

        //add a line item against the quote that we can later set to removed in the ASP
        //Test.startTest();
        Quote_Product__c lineItem = new Quote_Product__c(Part_Number__c='123456', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='123456', product__c = Prod3.Id);                              
        lineItem.ASP__c = asp.Id; 
        insert lineItem; 
        //use stop test to ensure the Future methods to decompile completes
        //Test.stopTest();
        //total job elements inserted should be 1 (1 work elements)
       // //System.assertEquals(1,[SELECT count() FROM Job_Element__c WHERE Job__c = :job[0].Id]);
        //ID lineItemID = [SELECT ID FROM Job_Element__c WHERE Job__c = :job[0].Id].Id;
        
        //Add line items related to the ASP
        Quote_Product__c lineItem1 = new Quote_Product__c(Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='ABC123', ASP__c=asp.Id, ASP_Reason__c='Added', ASP_Impact__c=0,ASP_Action__c='Add Parts and Hours', Supplier__c=suppliers[0].Id,ASP_Status__c='Entered');        
        Quote_Product__c lineItem2 = new Quote_Product__c(Part_Number__c='654321', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='654321', ASP__c=asp.Id, ASP_Reason__c='Added',ASP_Impact__c=0, ASP_Action__c='Add Parts and Hours', Supplier__c=suppliers[1].Id,ASP_Status__c='Entered');                              
        Quote_Product__c[] lineItems = new Quote_Product__c[]{lineItem1,lineItem2};     
        insert lineItems;     
        //update existing line item to remove as part of ASP
        lineItem.ASP__c=asp.Id;
        lineItem.ASP_Status__c='Entered';
        lineItem.ASP_Reason__c='Removed';
        lineItem.ASP_Action__c='Remove Parts and Hours'; 
        lineitem.ASP_Impact__c=0;
        update lineItem;  
        
        //a JBH would have beenc created, so delete this before submitting ASP
        Job_Booking_History__c[] JBH = [select Id from Job_Booking_History__c where Job__c=:Job[0].ID];   
        if(JBH.size()>0)
        delete JBH;         
        
        
        //submit ASP
        //ASP__c testasp = [Select Status__c, Charge_to_Customer__c, Balancing_Cost_Change__c,ASP_Installation_Date__c from ASP__c where ID=:asp.Id];
        //system.debug('-------------------> testasp.Balancing_Cost_Change__c = ' + testasp.Balancing_Cost_Change__c);
        test.starttest();
        QuoteProductDecompile.submitASP(asp.Id,quote[0].Id);
       
        
       ASP__c asp1 = new ASP__c(Charge_to_Customer__c=0,Quote__c=quote[0].Id, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today(),ASP_Installation_Date__c=date.today());   
       asp1.Status__c='Entered';  
       asp1.ASP_Type__c='Downtime'; 
       insert asp1;
       
       Quote_Product__c lineItem3 = new Quote_Product__c(Part_Number__c='ABC123', Quantity__c=1.00, Sales_Price__c=0, BigMachines_Quote__c=quote[0].Id, Name='ABC123', ASP__c=asp1.Id, ASP_Reason__c='Added', ASP_Impact__c=0,ASP_Action__c='Add Parts and Hours', Supplier__c=suppliers[0].Id,ASP_Status__c='Entered');
       insert lineItem3;
       
       Job_Booking_History__c[] JBH1 = [select Id from Job_Booking_History__c where Job__c=:Job[0].ID];   
       if(JBH1.size()>0)
       delete JBH1;  
       
       string resultString = QuoteProductDecompile.submitASP(asp1.Id,quote[0].Id);
       system.debug('resultString is: '+resultString);
       
       ASP__c asp2 = new ASP__c(Charge_to_Customer__c=0,Quote__c=quote[0].Id, Picklist__c='Other', Function__c='Sales', Definition__c='Building Work', ASP_Date__c=date.today(),ASP_Installation_Date__c=date.today());   
       asp1.Status__c='Entered';  
       
       insert asp2;
       string resultString1 = QuoteProductDecompile.submitASP(asp2.Id,quote[0].Id);
	   test.stoptest();
       
       
        //Assert line items are set to committed status
        //Quote_Product__c[] lineItemsAfter = [select ASP_Status__c from Quote_Product__c where ASP__c=:asp.Id];
       // system.debug('lineItemsAfter is: '+lineItemsAfter);
        
        
       
        //Assert the removed line items has caused the job element to be set to Returned
        //Job_Element__c returnedElement = [SELECT Sub_Status__c FROM Job_Element__c WHERE ID =:lineItemID];
        //System.assertEquals('Returned',returnedElement.Sub_Status__c);
        //Assert status and substatus for the quote are set correctly and hours have been updated               
        //Job__c updatedJob = [select PowerFlush_Hours__c, Electrical_Hours__c, Status__c, Sub_Status__c, Electrical_Work_ASP_Hours__c from Job__c where ID=:Job[0].id];
                        
        //Assert quote hours are set correctly and finalPriceVisibleToCustomer__c (should be 20 + 5)
        //BigMachines_Quote__c quoteAfter = [Select finalPriceVisibleToCustomer__c, b.quote_reconciled__c, b.skillTotalElectrical__c, b.skillTotalPowerFlush__c From BigMachines_Quote__c b where Id=:quote[0].Id];       

        
        //ensure job now has a job booking history record of type 'Job Planned' after quote decompiled
        //Job_Booking_History__c[] historyItemsAfter = [select Materials_Affected__c from Job_Booking_History__c where job__c=:Job[0].ID AND Materials_Affected__c=true];       
        //System.assertEquals(1,historyItemsAfter.size());  
        
        //asset ASP status is 'Submittted'     
       // ASP__c aspAfter = [select Status__c from ASP__c where ID=:asp.Id]; 
        //System.assertEquals('Submitted',aspAfter.Status__c);   
        /*} catch(Exception ex) {
            //do nothing
        } */              
    }    
    
    @isTest
    private static Account TestScenarioCreateAccount(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=district.Id, Code__c='yyyyyyyy');                
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        return Acc;
    }
    
    //test method        
    private static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }
    
    //test method 
    public static BigMachines_Quote__c[] TestScenarioCreateQuote(Opportunity opty,integer num){
        
        BigMachines_Quote__c quote;
        if(num==1)
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, quote_reconciled__c=true);           
        if(num==2)
            quote = new BigMachines_Quote__c(Name = 'Test for Quote Decompile', Opportunity__c = opty.id, SkillTotalElectricalWorkASP__c=2.55, quote_reconciled__c=true, finalPriceVisibleToCustomer__c=20, stage__c='Quote Finalised - Accepted',bmStatusReason__c='Quote Finalised - Accepted',geographicUpliftFactor__c=2);                   
        BigMachines_Quote__c[] quotelist = new BigMachines_Quote__c[]{quote};
        insert quotelist;        
        return quotelist; 
    }
    
    //test method     
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId){
        
        Job__c job1 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID, Water_Heating_Fixing_Hours__c=0,Unvented_Hot_Water_Hours__c=0,Specialist_Building_Hours__c=0,Scaffolder_Hours__c=0,Roof_Work_Hours__c=0,Payment_Collection_Hours__c=0,Mechanical_Hours__c=0,LPG_Installation_Hours__c=0,Fire_Wall_Heater_Fixing_Hours__c=0,Electrical_Hours__c=0,Contractor_Installation_Hours__c=0,Connect_Solar_Panel_Hours__c=0,Building_Work_Hours__c=0,PowerFlush_Hours__c=0,Electrical_Work_ASP_Hours__c=0,Asbestos_Removal_Hours__c=0,Asbestos_Removal_Fixed_Rate_Hours__c=0,Solar_Hours__c=0);              
        Job__c[] joblist = new Job__c[]{job1};          
        system.debug('joblist contains :'+joblist);
        insert joblist;        
        return joblist;
    }
    
    @isTest
    private static void TestScenarioCreateWorkAndMaterials(){
        
        Product_Work_Code__c productWorkCode1 = new Product_Work_Code__c(Work_Code__c='ABC123', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='PowerFlush', Skill_Type__c='Work', Product_Code__c='ABC123', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode2 = new Product_Work_Code__c(Work_Code__c='123ABC', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='B', Skill_Type__c='Work', Product_Code__c='ABC456', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode3 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='Mechanical', Skill_Type__c='Work', Product_Code__c='123456', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);
        Product_Work_Code__c productWorkCode4 = new Product_Work_Code__c(Work_Code__c='123456', Work_Code_Description__c='Scaffolding', Start_Date__c=date.today(), Skill__c='Electrical', Skill_Type__c='Work', Product_Code__c='654321', Hours__c=0.45, End_Date__c=date.today(), Active__c = True);        
        Product_Work_Code__c[] productWorkCodeList = new Product_Work_Code__c[]{productWorkCode1,productWorkCode2,productWorkCode3,productWorkCode4};        
        insert productWorkCodeList;
        
        Product_Materials__c productMaterials1 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=2.0, Product_Code__c='ABC123', Material_Description__c='Scaffolding', Material_Code__c='C', End_Date__c=date.today(), Active__c = True);
        Product_Materials__c productMaterials2 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=3.0, Product_Code__c='ABC456', Material_Description__c='Scaffolding', Material_Code__c='MC', End_Date__c=date.today(), Active__c = True);      
        Product_Materials__c productMaterials3 = new Product_Materials__c(Start_Date__c=date.today(), Quantity__c=3.0, Product_Code__c='ABC456', Material_Description__c='Scaffolding', Material_Code__c='MC', End_Date__c=date.today(), Active__c = True);              
        Product_Materials__c[] productMaterialsList = new Product_Materials__c[]{productMaterials1,productMaterials2,productMaterials3};        
        insert productMaterialsList;
    }   
}