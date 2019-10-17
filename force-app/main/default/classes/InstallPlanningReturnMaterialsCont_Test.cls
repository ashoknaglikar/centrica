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
 * The  class annotation indicates this class only contains test
 * methods. Classes defined with the  annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class InstallPlanningReturnMaterialsCont_Test {

        static testmethod void TestInstallationPlanningReturnMaterials(){           
        //set up environment with test data
        ID districtID = TestScenarioCreateDistrict();
        Account Acc = TestScenarioCreateAccount(districtID);
        Opportunity opty = TestScenarioCreateOppty(Acc);
        Job__c Job = new Job__c(Status__c='Pending',Sub_status__c='Awaiting Planning', CHI_Lead__c=opty.Id);
        insert Job;
        //BigMachines_Quote__c[] quote = new BigMachines_Quote__c(Quote__c = Job.Id,bmStatusReason__c='Planning Pending - Gas Supply',stage__c='Quote Finalised - Accepted',Transferred_to_Premier__c=null,Name = 'Test for Quote Reconcile', Opportunity__c = opty.id,skillTotalWaterHeatingFixing__c=2.6,skillTotalUnventedHotWater__c=2.6,skillTotalSpecialistBuilding__c=2.6,skillTotalScaffolder__c=2.6,skillTotalRoofWork__c=2.6,skillTotalPaymentCollection__c=2.6,skillTotalMechanical__c=2.6,skillTotalLPGInstallation__c=2.6,skillTotalFireWallHeaterFixing__c=2.6,skillTotalElectrical__c=2.6,skillTotalContractorInstallation__c=2.6,skillTotalConnectSolarPanels__c=2.6,skillTotalBuildingWork__c=2.6,skillTotalPowerFlush__c=2.6,SkillTotalElectricalWorkASP__c=2.6,skillTotalAsbestosRemoval__c=2.6,skillTotalAsbestosRemovalFixedRate__c=2.6,skillTotalSolar__c=2.6);                                   
        //Insert quote;
        
        Job_Element__c jobElement1 = new Job_Element__c(Units__c=8, Type__c='Material', Supplier_Order_Number__c='12345', Sub_Status__c='Awaiting Order', Status__c='Active', Skill__c='Elec', Product_ID__c='456', Merchant_Order_Number__c='321', Line_Item_ID__c='123', Job__c=Job.Id,  Description__c='Material Element', Current_Supplier__c='', Current_Supplier_Number__c='');
        Job_Element__c jobElement2 = new Job_Element__c(Units__c=7, Type__c='Material', Supplier_Order_Number__c='12345', Sub_Status__c='Awaiting Order', Status__c='Active', Skill__c='Elec', Product_ID__c='4567', Merchant_Order_Number__c='321', Line_Item_ID__c='123', Job__c=Job.Id, Description__c='Material Element', Current_Supplier__c='', Current_Supplier_Number__c='');
        Job_Element__c jobElement3 = new Job_Element__c(Units__c=5, Type__c='Material', Supplier_Order_Number__c='12345', Sub_Status__c='Awaiting Order', Status__c='Active', Skill__c='Elec', Product_ID__c='4568', Merchant_Order_Number__c='321', Line_Item_ID__c='123', Job__c=Job.Id, Description__c='Material Element', Current_Supplier__c='', Current_Supplier_Number__c='');
        Job_Element__c jobElement4 = new Job_Element__c(Units__c=4, Type__c='Material', Supplier_Order_Number__c='12345', Sub_Status__c='Awaiting Order', Status__c='Active', Skill__c='Elec', Product_ID__c='4569', Merchant_Order_Number__c='321', Line_Item_ID__c='123', Job__c=Job.Id, Description__c='Material Element', Current_Supplier__c='', Current_Supplier_Number__c='');
        Job_Element__c jobElement5 = new Job_Element__c(Units__c=3, Type__c='Material', Supplier_Order_Number__c='12345', Sub_Status__c='Awaiting Order', Status__c='Active', Skill__c='Elec', Product_ID__c='4561', Merchant_Order_Number__c='321', Line_Item_ID__c='123', Job__c=Job.Id, Description__c='Material Element', Current_Supplier__c='', Current_Supplier_Number__c='');
        Job_Element__c jobElement6 = new Job_Element__c(Units__c=2, Type__c='Material', Supplier_Order_Number__c='12345', Sub_Status__c='Awaiting Order', Status__c='Active', Skill__c='Elec', Product_ID__c='4562', Merchant_Order_Number__c='321', Line_Item_ID__c='123', Job__c=Job.Id, Description__c='Material Element', Current_Supplier__c='', Current_Supplier_Number__c='');
        Job_Element__c[] jobElements = new  Job_Element__c[] {jobElement1,jobElement2,jobElement3,jobElement4,jobElement5,jobElement6};                    
        insert jobElements;
                               
        //ensure job has no job booking history records
        Job_Booking_History__c[] historyItemsBefore = [select Materials_Affected__c from Job_Booking_History__c where Job__c=:Job.ID AND Materials_Affected__c=true];
        System.assertEquals(historyItemsBefore.size(),0);
        
        //render the VF page passing in the job ID which should now have job elements created for it
        PageReference pageRef = new PageReference('/apex/InstallationPlanningReturnMaterials?job='+job.Id);       
        Test.setCurrentPage(pageRef);
        
        InstallPlanningReturnMaterialsController controller1 = new InstallPlanningReturnMaterialsController();
        InstallPlanningReturnMaterialsController.availDataSet[] data = controller1.getAvailDataSet();
        InstallPlanningReturnMaterialsController.availDataSet controller2 = new InstallPlanningReturnMaterialsController.availDataSet();                                                     
        
        //call getter methods to achieve Apex code coverage 
        controller2.getCode();
        controller2.getDescription();
        controller2.getjobElementID();
        controller2.getLine_Item_ID();
        controller2.getProduct_ID();
        controller2.getStatus();
        controller2.getnewUnits();        
        controller2.getName();
        controller1.getCurrentQuantity();
        controller1.getUserMessage();
        controller2.getSupplier_Order_Number();
		controller2.getSub_Status();
		controller2.getNew_Supplier();
		controller2.getNew_Supplier_Number();
		controller2.getMerchant_Order_Number();
		controller2.getCurrent_Supplier();
		controller2.getCurrent_Supplier_Number();
                
        //array should have 6 elements for 6 'material' elements inserted by the two quote lines inserted (2 lots of 3 materials)
        System.assertEquals(6,data.size());
        //variable should be true as rows were found        
        System.assertEquals(true,controller1.getshowData());
        //return the job
        job__c jobreturn = controller1.getJob();        
        //Assert using 'back' button navigates back to correct URL of the job       
        String nextPage = controller1.returnToJob().getUrl(); 
        System.assertEquals('/'+job.Id, nextpage);                      
        //set new quantity to be 1 for one material item - this should cause a new job element record to be created of type removed   
        data[0].newUnits='1';
        //Set new quantity data to be 0 for all other materials displayed - this should cause these existing job element record to have their status changed from Active to Removed
        for(integer y=1;y<data.size();y++){
        	data[y].newUnits='0';
        }          
        //Assert using 'Return Materials' button navigates back to correct URL        
        String nextPage2 = controller1.returnJobElements().getUrl();
        //System.assertEquals('/apex/InstallationPlanningReturnMaterials?job='+job.Id, nextpage2);   
        System.assertEquals('/'+job.Id, nextpage2);
        //ensure job now has a job booking history record to be picked up by the interface
        Job_Booking_History__c[] historyItemsAfter = [select Materials_Affected__c from Job_Booking_History__c where job__c=:job.ID AND Materials_Affected__c=true];
        System.assertEquals(1,historyItemsAfter.size());  
        
        //Only 1 active material should now remain
        Integer countOfActiveJobElements = [Select count() From Job_Element__c where job__c=:job.ID and status__c='Active' and type__c='material'];     
    	System.assertEquals(1,countOfActiveJobElements);
    	
    	//6 removed job elements should now exist
    	Integer countOfRemovedJobElements = [Select count() From Job_Element__c where job__c=:job.ID and status__c='Removed' and type__c='material'];     
    	System.assertEquals(6,countOfRemovedJobElements);
    }
    
    
    
    static testmethod Opportunity TestScenarioCreateOppty(){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar');        
        insert opty;        
        return opty;
    }
    
	
	static testmethod ID TestScenarioCreateDistrict(){
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
}