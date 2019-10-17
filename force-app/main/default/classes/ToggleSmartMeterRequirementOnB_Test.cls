@isTest
private class ToggleSmartMeterRequirementOnB_Test {
    
    static testmethod void toogelSmartMeterScenario()
    {
        Account acc = TestClassHelper.createAccout();
        insert acc;
        Opportunity  opp = TestClassHelper.createCHILead(acc);
        insert opp;
        
        District__c dist = TestClassHelper.createDistrict();
        insert dist;
        
        BigMachines_Quote__c bmQuote = TestClassHelper.createBMQuote(opp);
        bmQuote.Smart_Meter_Required_Flag__c = 'No';
        insert bmQuote;
        
        Job__c job = TestClassHelper.createJob('Planned', 'Planned', opp.Id, dist.Id);
        job.RHCUsername__c = 'test@test.com';
        job.Quote__c = bmQuote.Id;
        insert job;
                      
        PageReference pageRef= new PageReference('apex/ToggleSmartMeterRequirementOnBMQuote?id='+bmQuote.Id);
        Test.setCurrentPage(pageRef);
        ToggleSmartMeterRequirementOnBMQuote tg= new ToggleSmartMeterRequirementOnBMQuote();
        tg.reloadBMQuotePage();
        
        job.Status__c = 'Planned';
        update job;
        tg.reloadBMQuotePage();
        
        
        
    }
    
    static testmethod void toogelSmartMeterScenario2()
    {
        Account acc = TestClassHelper.createAccout();
        insert acc;
        Opportunity  opp = TestClassHelper.createCHILead(acc);
        insert opp;
        
        District__c dist = TestClassHelper.createDistrict();
        insert dist;
        
        BigMachines_Quote__c bmQuote = TestClassHelper.createBMQuote(opp);
        bmQuote.Smart_Meter_Required_Flag__c = 'No';
        insert bmQuote;
        
        Job__c job = TestClassHelper.createJob('Cancelled', 'Cancelled', opp.Id, dist.Id);
        job.RHCUsername__c = 'test@test.com';
        job.Quote__c = bmQuote.Id;
        insert job;
        
        PageReference pageRef= new PageReference('apex/ToggleSmartMeterRequirementOnBMQuote?id='+bmQuote.Id);
        Test.setCurrentPage(pageRef);
        ToggleSmartMeterRequirementOnBMQuote tg= new ToggleSmartMeterRequirementOnBMQuote();
        tg.reloadBMQuotePage();
        
    }

}