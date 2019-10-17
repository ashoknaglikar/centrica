@isTest(SeeAllData=true)
private class captureMeasures_test 
{
    static string oppId;
    static testMethod void TestMethod_CallActionFunctions() 
    {
        Account Acc = TestClassHelper.createAccout();
        insert Acc;
        
        Opportunity opp = TestClassHelper.createCHILead(Acc);
        insert opp;
        oppId=opp.id;
        
        List<Green_Deal_Reconsilliation__c> gdlist = new List<Green_Deal_Reconsilliation__c>();
        gdlist = [select id from Green_Deal_Reconsilliation__c where Opportunity__c=:oppId];  
        Green_Deal_Reconsilliation__c gd = new Green_Deal_Reconsilliation__c(Opportunity__c=oppId);
        insert gd;
        gdlist.add(gd);
        Green_Deal_Measures__c gdm = new Green_Deal_Measures__c(
                                                                Recommended_measure__c = 'Solid Wall Insulation',
                                                                Installation_date__c = system.today(),
                                                                Measure_Gross_Value__c = 0,
                                                                Green_Deal_Record__c = gd.Id,
                                                                Customer_Taken_Up_measure__c = 'Yes',
                                                                Scaffolding_Required__c = 'Yes',
                                                                Extra_Gross_Value__c = 0,
                                                                solid_wall_insulation__c = 'Unplanned survey',
                                                                Accepted_Dates__c = system.today(),
                                                                Planning_Application__c = system.today()
                                                                );
                        
        ApexPages.standardController SC = new ApexPages.standardController(gdm);
        test.setCurrentPage(new pagereference('/apex/GreenDealReconcillation?retUrl='+gd.Id));
        captureMeasures cmObj = new captureMeasures(SC);

        //ApexPages.currentPage().getParameters().put('recMeas', 'Condensing Boiler');
        //cmObj.fecthIntall();
        
        ApexPages.currentPage().getParameters().put('recMeas', 'Solid wall insulation');
        cmObj.fecthIntall();

        ApexPages.currentPage().getParameters().put('incdate', '11/10/2013');
        cmObj.accptddte();
        
        ApexPages.currentPage().getParameters().put('incdate', '');
        cmObj.accptddte();
        
        ApexPages.currentPage().getParameters().put('status', 'Rejected');
        cmObj.installdate();
        
        ApexPages.currentPage().getParameters().put('status', '');
        cmObj.installdate();
        
        ApexPages.currentPage().getParameters().put('recMeas', ' ');
        cmObj.fecthIntall();

        cmObj.cancel(); 
    }
    
    static testMethod void TestMethod_CallActionFunctions1() 
    {
        Account Acc = TestClassHelper.createAccout();
        insert Acc;
        
        Opportunity opp = TestClassHelper.createCHILead(Acc);
        insert opp;
        oppId=opp.id;
        
        List<Green_Deal_Reconsilliation__c> gdlist = new List<Green_Deal_Reconsilliation__c>();
        gdlist = [select id from Green_Deal_Reconsilliation__c where Opportunity__c=:oppId];  
        Green_Deal_Reconsilliation__c gd = new Green_Deal_Reconsilliation__c(Opportunity__c=oppId);
        insert gd;
        gdlist.add(gd);
        Green_Deal_Measures__c gdm = new Green_Deal_Measures__c(
                                                                Recommended_measure__c = 'Solid Wall Insulation',
                                                                Installation_date__c = system.today(),
                                                                Measure_Gross_Value__c = 0,
                                                                Green_Deal_Record__c = gd.Id,
                                                                Customer_Taken_Up_measure__c = 'Yes',
                                                                Scaffolding_Required__c = 'Yes',
                                                                Extra_Gross_Value__c = 0,
                                                                solid_wall_insulation__c = 'Unplanned survey',
                                                                Accepted_Dates__c = system.today(),
                                                                Planning_Application__c = system.today()
                                                                );
        
        insert gdm;
        ApexPages.standardController SC = new ApexPages.standardController(gdm);
        test.setCurrentPage(new pagereference('/apex/GreenDealReconcillation?retUrl='+gdm.Id));
        captureMeasures cmObj = new captureMeasures(SC);

        //ApexPages.currentPage().getParameters().put('recMeas', 'Condensing Boiler');
        //cmObj.fecthIntall();
        
        ApexPages.currentPage().getParameters().put('recMeas', 'Solid wall insulation');
        cmObj.fecthIntall();

        ApexPages.currentPage().getParameters().put('incdate', '11/10/2013');
        cmObj.accptddte();
        
        ApexPages.currentPage().getParameters().put('incdate', '');
        cmObj.accptddte();
        
        ApexPages.currentPage().getParameters().put('status', 'Rejected');
        cmObj.installdate();
        
        ApexPages.currentPage().getParameters().put('status', '');
        cmObj.installdate();
        
        ApexPages.currentPage().getParameters().put('recMeas', ' ');
        cmObj.fecthIntall();

        cmObj.cancel(); 
    }
}