@isTest
private class TestDisplayReplanJobsController {
    
    public static testMethod void testDisplayReplanJobsController(){
        
        /////////////////////////////////////////////////////////////////////////////////////////////////////
        //Test Class for DisplayReplanJobsController:                                                      //
        //Setup the environment for the test class to operate on. This requires a Campaign and Account to  //
        //associate with a CHI Lead. Create a job to test.                                                 //
        // - Added region reference as part of change to allow region filter - P.Dennison - 14/06/12       //
        /////////////////////////////////////////////////////////////////////////////////////////////////////
       Region__c region = TestClassHelper.createRegion();
       insert region;
        
       District__c dist = TestClassHelper.createDistrict();
       dist.Region__c = region.Id;
       insert dist;
        
        Account acc = new Account(Name = 'Test DisplayReplanJobs', BillingStreet='18 Display', 
                                        BillingPostalCode='TW18 3HT', BillingCity='London', 
                                        BillingCountry='UK', BillingState='London');
        Database.insert(acc);
        
        Campaign camp = new Campaign(Source__c = 'MA', Media_Cost_Code__c = 'MEDA', Group_Code__c = 'MEDA', Name='Test Display');
        
        Database.insert(camp);
        
        Opportunity opp = new Opportunity (LeadSource = 'MA', name = 'TestDisplay() opp', AccountId = acc.Id,
                                           CloseDate = Date.today().addyears(1), 
                                           StageName = 'Active',
                                           Product_Interest__c='Central Heating Boiler',
                                           CampaignId = camp.Id);
        Database.insert(opp);
        
        Job__c job = new Job__c(CHI_Lead__c = opp.ID, Status__c = 'Pending', Pending_Reason__c = 'Contact Customer', 
                                Mechanical_Hours__c=7, PowerFlush_Hours__c = 4, Customer_Preferred_Date__c = null,
                                Contractors__c=true, Own_Labour__c=true, Double_Handed_Job__c = false, Needs_Re_Planing__c = true, District__c = dist.Id);
                                
        Database.insert(job);
        
        system.debug('job--->'+job);
        
        PageReference pageRef = new PageReference('/apex/DisplayReplanJobs');
        
        Test.setCurrentPage(pageRef);
                    
        DisplayReplanJobsController controller1 = new DisplayReplanJobsController();
        controller1.regionID= null;  
        controller1.areaId = null;
        controller1.fetchJobList();
           
        DisplayReplanJobsController controller2 = new DisplayReplanJobsController();
        controller2.regionID= null;  
        controller2.areaId = dist.Id;
        controller2.fetchJobList();
        system.assert(controller1.jobList.size()==0);
        
        controller1.regionID= region.Id;  
        controller1.fetchJobList();
        //system.assert(controller1.jobList.size()==0);
        controller1.setAreaId('teststring');  
        controller1.setRegionId('teststring');    
        controller1.getRegionItems();
        List<SelectOption> options =  controller1.getAreaItems(); 
        String areaId = controller1.getAreaId();
        String regionId = controller1.getRegionId(); // Region
    }

}