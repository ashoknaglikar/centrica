@isTest
private class sendDiallerDetails_Test {
    
    // ++ Created only one method for preparing test data for Dialler tab CR - Nitish start
    static Account acc;
    static Contact con;
    static Opportunity opp;
    static Employee__c emp;
    static User testUser;
    static BigMachines_Quote__c quot;
    static Date submittedDate;
    static void createData()
    {
        acc = TestClassHelper.createAccout();
        insert acc;
        
        con = TestClassHelper.createContact(acc);
        con.MobilePhone = '01223445898';
        con.OtherPhone = '01223445898';
        con.HomePhone = '01223445898';
        insert con;
        
        opp = TestClassHelper.createCHILead(acc);
        opp.closeDate__c = null;
        insert opp;
        
        
        testUser = TestClassHelper.createUser();
        insert testUser;
        
        emp = TestClassHelper.createEmployee();
        emp.Salesforce_User__c = testUser.Id;
        insert emp;
        
        
        Date now = system.today();
        submittedDate = Date.newInstance(now.year(), now.month(), now.day()-7);
        
        
        quot = TestClassHelper.createBMQuote(opp);
        quot.stage__c = 'Quote Finalised - Not Accepted';
        quot.submittedDate_quote__c = submittedDate;
        quot.sFDCApptStatus__c = 'Happened';
        
        insert quot;
        
    }
    // -- Created only one method for preparing test data for Dialler tab CR - Nitish end
    
    static testmethod void coverBestScenario(){
        
        createData();
        Test.startTest();
        sendDiallerDetails.createDiallerBatch();
        Test.stopTest();
        
    }
    
    static testmethod void DiallerScheduler(){
        
        DiallerScheduler d = new DiallerScheduler();
        SchedulableContext SC;
        d.execute(SC);            
    }
    
    static testmethod void coverDiallerPageCont(){
        
        createData();
        Test.startTest();
        DiallerPageCont d = new DiallerPageCont();
        
        // ++ Updated for Dialler tab CR - Nitish start
        //d.qSubstatus = 'All';
        d.bm = new BigMachines_Quote__c(stage__c = 'Quote Finalised - Not Accepted',submittedDate_quote__c=submittedDate , installationDate__c = system.today() , closeDate__c = system.today()+7);
        // ++ Updated for Dialler tab CR - Nitish end
        List<SelectOption> statusOptions = new List<SelectOption>();
        statusOptions.add(new SelectOption('Quote Finalised - Not Accepted','Quote Finalised - Not Accepted'));
        List<SelectOption> subStatusOptions = new List<SelectOption>();
        subStatusOptions.add(new SelectOption('Affordability','Affordability'));
        List<SelectOption> districtOptions = new List<SelectOption>();
        districtOptions.add(new SelectOption('Leeds','Leeds'));
        List<SelectOption> productOptions = new List<SelectOption>();
        productOptions.add(new SelectOption('C4C','C4C'));
        d.allStatusSelected = statusOptions;
        d.allSubStatusSelected = subStatusOptions;
        d.allDistrictsSelected = districtOptions;
        d.allProductTypesSelected = productOptions;
        d.createDiallerFile();
        d.getSubStatusOPtions();
        d.back();
        
        // ++ Added for Dialler tab CR - Nitish start
        d.getAreaItems();
        d.getProductTypeOPtions();
        d.getStatusOPtions();
        set<String> subStatus = new set<String>();
        set<String> prodType = new set<String>();
        subStatus.add('Affordability');
        prodType.add('C4C');
        d.createCriteria(subStatus, 'bmStatusReason__c');
        d.createCriteria(prodType, 'Product_Type_ID__c');
        // -- Added for Dialler tab CR - Nitish end
        
        Test.stopTest();
        
    }

}