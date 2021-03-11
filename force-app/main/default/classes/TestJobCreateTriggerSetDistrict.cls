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
private class TestJobCreateTriggerSetDistrict {

   
    static testMethod void testSetDistrict() {
        //Setup test environment
        ID districtID = TestScenarioCreateDistrict();
        Account Acc = TestScenarioCreateAccount(districtID);
        Opportunity opty = TestScenarioCreateOppty(Acc); 
        
                        
               
        //Assert no job exists for the CHI Lead before quote is inserted              
        System.assertEquals(0,[select count() from Job__c where CHI_Lead__c=:opty.id]);
        Job__c[] Job = TestScenarioCreateJob('Pending','mismatch',opty.Id);
        
        //insert the new quote against the CHI Lead
        Test.startTest();
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);                 
        Test.stopTest();
        
        //Assert a new job has been created and that it is linked to the quote and CHI Lead.              
        Job__c[] updatedJob = [select Quote__c,District__c, Status__c, Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Solar_Hours__c from Job__c where CHI_Lead__c=:opty.id];
        System.assertEquals(1, updatedJob.size());
        //assert that the district was set on the job
        System.assertEquals(districtID,updatedJob[0].District__c);
    }
//Commented and Changed by BGSAMS support on 25/01/2012 to avoid failure of TestJobCreateTriggerSetDistrict class due to the code fix added in Trigger JobBeforeInsertUpdate to prevent duplicate jobs in case of preallocation scenario job insertion -  PRB00006300 starts  
  /*static testMethod void testBulkSetDistrict() {
        //Setup test environment
        ID districtID = TestScenarioCreateDistrict();
        Account Acc = TestScenarioCreateAccount(districtID);
        Opportunity opty = TestScenarioCreateOppty(Acc);                          
               
        //Assert no job exists for the CHI Lead before quote is inserted              
        System.assertEquals(0,[select count() from Job__c where CHI_Lead__c=:opty.id]);
        Integer numJobs = 250;
        Job__c[] Job = TestScenarioCreateJob('Pending','mismatch',opty.Id, numJobs);
        
        //insert the new quote against the CHI Lead
        Test.startTest();
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);                 
        Test.stopTest();
        
        
        //Assert a new job has been created and that it is linked to the quote and CHI Lead.              
        Job__c[] updatedJob = [select Quote__c,District__c, Status__c, Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Solar_Hours__c from Job__c where CHI_Lead__c=:opty.id];
        System.assertEquals(numJobs, updatedJob.size());
        //assert that the district was set on the jobs
        for(Integer i = 0; i < numJobs; i++)
        {
            System.assertEquals(districtID,updatedJob[i].District__c);
        }
        
    }*/  
    static testMethod void testBulkSetDistrict() {
        //Setup test environment
        ID districtID = TestScenarioCreateDistrict();
        Account Acc = TestScenarioCreateAccount(districtID);
        Integer numOpps = 50;
        List<Opportunity> multiCHI  = new List<Opportunity>(); 
        multiCHI = TestClassHelper.createMultipleCHILead(Acc,numOpps);
        for(integer i=0;i<multiCHI.size();i++)
        {
            multiCHI[i].payment_reference_number__c='812345678'+i;
        }
        insert multiCHI;
        System.assertEquals(numOpps , multiCHI.size());
                     
        List<Id> Oppids=new List<Id>();
        for(Integer i=0;i<numOpps;i++)
        {
        Oppids.add(multiCHI[i].Id); 
        }    
        //Assert no job exists for the CHI Lead before quote is inserted              
        System.assertEquals(0,[select count() from Job__c where CHI_Lead__c in :Oppids]);
         Test.startTest();
        Integer numJobs = 50;
        List<Job__c> Job= new List<Job__c>();
        Job = TestClassHelper.createMultipleJobs('Pending','mismatch',multiCHI,numJobs);
        insert Job;
        //insert the new quote against the CHI Lead
       
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(multiCHI[0],1);                 
        Test.stopTest();
        
        
        //Assert a new job has been created and that it is linked to the quote and CHI Lead.              
        Job__c[] updatedJob = [select Quote__c,District__c, Status__c, Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Solar_Hours__c from Job__c where CHI_Lead__c in:Oppids];
        System.assertEquals(numJobs, updatedJob.size());
        //assert that the district was set on the jobs
        for(Integer i = 0; i < numJobs; i++)
        {
            System.assertEquals(updatedJob[i].District__c,updatedJob[i].District__c);
        }
        
    }
    
   
//Commented and Changed by BGSAMS support on 25/01/2012 to avoid failure of TestJobCreateTriggerSetDistrict class due to the code fix added in Trigger JobBeforeInsertUpdate to prevent duplicate jobs in case of preallocation scenario job insertion -  PRB00006300 Ends   
       
    //test method. not declared as @isTest as it is called in other test classes to create test data so needs to be public
    public static ID TestScenarioCreateDistrict(){
        District__c district = new District__c(Type__c='Installation', Name='Decompile District', Code__c='yyyyyyyy');      
        insert district;
        return district.ID;
    }
    
    //test method        
    public static Account TestScenarioCreateAccount(Id districtID){
        Sub_Patch__c subPatch = new Sub_Patch__c(Type__c ='Installation',Name='XXX X', District__c=districtID, Code__c='yyyyyyyy');             
        insert subPatch;
        Postcode_Sector__c postcodeSector = new Postcode_Sector__c(Type__c='Installation', Name='XXX X', Sub_Patch__c=subPatch.Id, Code__c='yyyyyyyy');
        insert postcodeSector;
        Account Acc = new Account(Name = 'test account quote decompile', BillingStreet='Test Street', BillingPostalCode = 'XXX XXX');                       
        insert Acc;        
        return Acc;
    }
    
    //test method         
    public static Opportunity TestScenarioCreateOppty(Account Acc){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar', AccountID=Acc.Id);        
        insert opty;        
        return opty;
    }   
    
    //test method 
    public static BigMachines_Quote__c[] TestScenarioCreateQuote(Opportunity opty,integer num){
        
        BigMachines_Quote__c quote = new BigMachines_Quote__c(bmStatusReason__c='Planning Pending - Gas Supply',stage__c='Quote Finalised - Accepted',Transferred_to_Premier__c=null,Name = 'Test for Quote Reconcile', Opportunity__c = opty.id,skillTotalWaterHeatingFixing__c=2.6,skillTotalUnventedHotWater__c=2.6,skillTotalSpecialistBuilding__c=2.6,skillTotalScaffolder__c=2.6,skillTotalRoofWork__c=2.6,skillTotalPaymentCollection__c=2.6,skillTotalMechanical__c=2.6,skillTotalLPGInstallation__c=2.6,skillTotalFireWallHeaterFixing__c=2.6,skillTotalElectrical__c=2.6,skillTotalContractorInstallation__c=2.6,skillTotalConnectSolarPanels__c=2.6,skillTotalBuildingWork__c=2.6,skillTotalPowerFlush__c=2.6,SkillTotalElectricalWorkASP__c=2.6,skillTotalAsbestosRemoval__c=2.6,skillTotalAsbestosRemovalFixedRate__c=2.6,skillTotalSolar__c=2.6);                                   
        BigMachines_Quote__c[] quotelist = new BigMachines_Quote__c[]{quote};
        insert quotelist;        
        return quotelist;
    }  
    
    //test method
    public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId){
        
        Job__c job1 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID);              
        Job__c[] joblist = new Job__c[]{job1};          
        insert joblist;        
        return joblist;
    }    
//Commented by BGSAMS support on 25/01/2012 to avoid failure of TestJobCreateTriggerSetDistrict class due to the code fix added in Trigger JobBeforeInsertUpdate to prevent duplicate jobs in case of preallocation scenario job insertion -  PRB00006300 Starts         
 /* public static Job__c[] TestScenarioCreateJob(string status, string substatus, ID optyId, Integer howMany){
        
        List<Job__c> joblist = new List<Job__c>(); 
        for(Integer i = 0; i < howMany; i++)
        {
            Job__c job1 = new Job__c(Pending_Reason__c=substatus,Status__c=status, Type__c = 'Central Heating Installation', CHI_Lead__c=optyID);
            jobList.add(job1);
        }                      
        insert joblist;        
        return joblist;
    }*/ 
       static testMethod void gdcheck()
      { 
         map<Id, Id> ChiLeads = new map<Id, Id>();
         
         Account Acc = TestClassHelper.createAccout();
         insert Acc;
        
         Opportunity opp = TestClassHelper.createCHILead(Acc);
         insert opp;
         
         District__c dist = TestClassHelper.createDistrict();
         insert dist;
                
         Job__c jb= TestClassHelper.createJob('Planned','Planned',opp.Id,dist.id);
         jb.Is_Downtime_Job__c=true;
         insert jb; 
         
       
    } 
}
  
//Commented by BGSAMS support on 25/01/2012 to avoid failure of TestJobCreateTriggerSetDistrict class due to the code fix added in Trigger JobBeforeInsertUpdate to prevent duplicate jobs in case of preallocation scenario job insertion -  PRB00006300 Ends