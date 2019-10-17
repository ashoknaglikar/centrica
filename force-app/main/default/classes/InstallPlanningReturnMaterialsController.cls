public with sharing class InstallPlanningReturnMaterialsController {

    //////////////////////////////////////////////////////////////////////////////////////////////////
    //Controller class for visualforce page 'InstallationPlanningReturnMaterials'. Logic to find and//
    //display a jobs active material elements, whos quantity can then be reduced by the user. If a  //
    //material is reduced the job element is updated with the new quantity and a Job Booking History// 
    //record is created to be picked up by interfaces. A new job element is created for the removed //
    //amount of materials with a status of removed.													//
    //////////////////////////////////////////////////////////////////////////////////////////////////    
    
    Job__c thisJob;
    String userMessage;        
    Boolean showUserMessage;
    Job_Element__c[] jobElements;
    availDataSet [] retList;
    boolean showData;    
    String[] workElementsToReturn; 
    String currentQuantity;
    Map<ID,Job_Element__c> jobElementsMap;
    
    /////////////////////
    //Constructor class//
    /////////////////////
    
    public InstallPlanningReturnMaterialsController() {
        
        //retrieve job information based on job ID in the URL parameter            
        this.thisJob = [select ID, Name, Job_Locked__c from Job__c where ID=:System.currentPageReference().getParameters().get('job')];    
        //retrieve all active material job elements related to the job
        
        if(thisJob.Job_Locked__c == 'Y'){
        	setShowData(false);
        	setuserMessage('This job is currently locked. The job elements cannot be updated at this time.');
        	return;
        }
        jobElements = [select Name, Units__c, Status__c, Product_ID__c, Line_Item_ID__c, ID, Description__c, Code__c, Supplier_Order_Number__c, Sub_Status__c, New_Supplier__c, New_Supplier_Number__c, Merchant_Order_Number__c, Current_Supplier__c, Current_Supplier_Number__c from Job_Element__c where type__c='Material' AND Status__c='Active' AND Job__c=:thisJob.ID order by Line_Item_ID__c];                           
        
        //put in a map used later on button click
        jobElementsMap = new Map<ID,Job_Element__c>();
        for(integer x=0;x<jobElements.size();x++){
        	jobElementsMap.put(jobElements[x].ID,jobElements[x]);
        }
        
        //set user message to inform of how to use screen. Inform if no active material elements were found.    
        if(jobElements.size()>0){
            setuserMessage('To return materials enter the new required quantity in the \'New Quantity\' column for the desired material and then click \'Return Materials\'.');
            setShowData(true);  
        } 
        else{
            setuserMessage('No active material job elements were found for this job.'); 
            setShowData(false);
        }   
		
		//Create a list of custom objects for the VF datatable to itterate over
        retList = new availDataSet[]{};
        currentQuantity = '';                     
        for(integer x=0;x<jobElements.size();x++){
            availDataSet show = new availDataSet();            
            show.setName(jobElements[x].Name);     
            show.setUnits(jobElements[x].Units__c.intValue());
            show.setStatus(jobElements[x].Status__c); 
            show.setnewUnits(null);
            show.setProduct_ID(jobElements[x].Product_ID__c);
            show.setLine_Item_ID(jobElements[x].Line_Item_ID__c); 
            show.setjobElementID(jobElements[x].ID);
            show.setDescription(jobElements[x].Description__c); 
            show.setCode(jobElements[x].Code__c); 
            show.setSupplier_Order_Number(jobElements[x].Supplier_Order_Number__c);
        	show.setSub_Status(jobElements[x].Sub_Status__c); 
        	show.setNew_Supplier(jobElements[x].New_Supplier__c); 
        	show.setNew_Supplier_Number(jobElements[x].New_Supplier_Number__c); 
        	show.setMerchant_Order_Number(jobElements[x].Merchant_Order_Number__c); 
        	show.setCurrent_Supplier(jobElements[x].Current_Supplier__c); 
        	show.setCurrent_Supplier_Number(jobElements[x].Current_Supplier_Number__c);   
            retList.add(show);  
            //construct a string of current units. this is used in javascript in the page to ensure values entered for new quantities are lower than the current quantities
            if(currentQuantity=='')
                currentQuantity = string.valueOf(jobElements[x].Units__c.intValue());         
            else
                currentQuantity = currentQuantity+' '+string.valueOf(jobElements[x].Units__c.intValue());         
        }               
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    //Define jobElements dataset to return to datatable on InstallationPlanningReturnWork Page//        
    ////////////////////////////////////////////////////////////////////////////////////////////
        
    public class availDataSet {
                
        public String Name;     
        public Double Units;
        public String Status; 
        public string newUnits;
        public String Product_ID;
        public String Line_Item_ID; 
        public ID jobElementID;
        public String Description; 
        public String Code;  
        public String Supplier_Order_Number;
        public String Sub_Status; 
        public string New_Supplier; 
        public string New_Supplier_Number; 
        public string Merchant_Order_Number; 
        public string Current_Supplier; 
        public string Current_Supplier_Number;       
                   
        //
        //Setter methods
        //       
        public void setName(String elementname) {
            Name = elementname;
        }
        
        public void setUnits(Double elementUnits) {            
            Units = elementUnits;            
        }
  
        public void setnewUnits(string newUnitsEntered) {
            newUnits = newUnitsEntered;
        }                
        
        public void setStatus(String elementstatus) {
            Status = elementstatus;
        }
            
        public void setProduct_ID(String ProductID) {
            Product_ID = ProductID;       
        }
        
        public void setLine_Item_ID(String elementLine_Item_ID) {
            Line_Item_ID = elementLine_Item_ID;
        }
  
        public void setjobElementID(String ElementID) {
            jobElementID = ElementID;
        }                
        
        public void setDescription(String elementDescription) {
            Description = elementDescription;
        }
            
        public void setCode(String elementCode) {
            Code = elementCode;       
        }
        
        public void setSupplier_Order_Number(String SupplierOrderNumber){
        	Supplier_Order_Number = SupplierOrderNumber;
        }
        
        public void setSub_Status(String SubStatus){
        	Sub_Status=SubStatus;
        } 
        
        public void setNew_Supplier(String NewSupplier){
        	New_Supplier=NewSupplier;
        } 
        
        public void setNew_Supplier_Number(String NewSupplierNumber){
        	New_Supplier_Number=NewSupplierNumber;
        } 
        
        public void setMerchant_Order_Number(String MerchantOrderNumber){
        	Merchant_Order_Number=MerchantOrderNumber;
        } 
        
        public void setCurrent_Supplier(String CurrentSupplier){
        	Current_Supplier=CurrentSupplier;
        } 
        public void setCurrent_Supplier_Number(String CurrentSupplierNumber){
        	Current_Supplier_Number=CurrentSupplierNumber;
        } 
        
        //
        //Getter methods
        //       
        public String getName() {        	
            return Name;
        }
        
        public integer getUnits() {
            return Units.intValue();
        }
  
        public string getnewUnits() {
            newUnits = null;
            return newUnits;
        }                
        
        public String getStatus() {
            return Status;
        }
            
        public String getProduct_ID() {
            return Product_ID;       
        }
        
        public String getLine_Item_ID() {
            return Line_Item_ID;
        }
  
        public String getjobElementID() {
            return jobElementID;
        }                
        
        public String getDescription() {
            return Description;
        }
            
        public String getCode() {
            return Code;       
        }        
        
        public String getSupplier_Order_Number(){
        	return Supplier_Order_Number;
        }
        
        public String getSub_Status(){
        	return Sub_Status;
        } 
        
        public String getNew_Supplier(){
        	return New_Supplier;
        } 
        
        public String getNew_Supplier_Number(){
        	return New_Supplier_Number;
        } 
        
        public String getMerchant_Order_Number(){
        	return Merchant_Order_Number;
        } 
        
        public String getCurrent_Supplier(){
        	return Current_Supplier;
        } 

        public String getCurrent_Supplier_Number(){
        	return Current_Supplier_Number;
        }               
    }   
    
    
    ///////////////////////////////////////
    //Button functionality defined below.//
    ///////////////////////////////////////
    
    //The button user clicks to return Job Elements. Updates job element quantity and creates job booking history record
    //for interface to pick up.                                  
    public PageReference returnJobElements() {        
        
        List<Job_Element__c> jobElementToUpdateList = new List<Job_Element__c>();    
        //cycle through the new quantity values to find any are not blank   
        for(integer x=0;x<retList.size();x++){        	
            if(retList[x].newUnits!=''){            	            	
            	Job_Element__c jobElementToUpdate = jobElementsMap.get(retList[x].jobElementID);
            	//If new quantity is made 0 just set job element to be removed. Else, update active job element with the new value
            	//and create a new 'removed' job element record for the amount returned.             	
            	if(retList[x].newUnits=='0')  
            		jobElementToUpdate.Status__c='Removed';
            	else{          	            	           
            		jobElementToUpdate.Units__c = decimal.valueOf(retList[x].newUnits).intValue();
            		Job_Element__c jobElementToInsert = new Job_Element__c(Units__c=(decimal.valueOf(retList[x].Units).intValue()-decimal.valueOf(retList[x].newUnits).intValue()), Type__c='Material',Status__c='Removed', Product_ID__c=retList[x].Product_ID, Line_Item_ID__c=retList[x].Line_Item_ID, Description__c=retList[x].Description, Code__c=retList[x].Code, Job__c=this.thisJob.ID, Supplier_Order_Number__c=retList[x].Supplier_Order_Number, Sub_Status__c=retList[x].Sub_Status, New_Supplier__c=retList[x].New_Supplier, New_Supplier_Number__c=retList[x].New_Supplier_Number, Merchant_Order_Number__c=retList[x].Merchant_Order_Number, Current_Supplier__c=retList[x].Current_Supplier, Current_Supplier_Number__c=retList[x].Current_Supplier_Number); 
            		jobElementToUpdateList.add(jobElementToInsert);            	    
            	}    
            	jobElementToUpdateList.add(jobElementToUpdate);    	   
            }                        
        }        
        upsert(jobElementToUpdateList);
        
        //create a job booking history record for merchant ordering interface to pick up
        Job_Booking_History__c materialsAffectedBookingHistory = new Job_Booking_History__c(Materials_Affected__c=true, Job__c=this.thisJob.Id);
        insert materialsAffectedBookingHistory;
        
        //refresh the page to display the new reduced quantities of the active job elements
        //PageReference pageRef = new PageReference('/apex/InstallationPlanningReturnMaterials?job='+this.thisJob.Id);
        PageReference pageRef = new PageReference('/'+this.thisJob.Id);                                                   
        pageRef.setRedirect(true);      
        return pageRef;
    }
            
    
    //The back button to navigate the user back to the job record if required                             
    public PageReference returnToJob() {              
        PageReference pageRef = new PageReference('/'+this.thisJob.ID);                                                
        pageRef.setRedirect(true);      
        return pageRef;
    }
    
    
    
    ////////////////////////////
    //Page Getters and Setters//
    ////////////////////////////                                     
     
    public String getCurrentQuantity(){                          
        return currentQuantity;
    }  
                  
    public Job__c getJob(){                             
        return thisJob;
    }         
    
    public availDataSet[] getAvailDataSet(){                            
        return retList;
    }       
    
    public String getUserMessage() {     
        return userMessage;
    }  
    
    public boolean getshowData(){ 
        return showData;
    }      
            
    public void setUserMessage(String message) {     
        userMessage=message;
    }       
    
    public void setshowData(boolean data) {     
        showData=data;
    } 
    
  /*  
    ////////////////
    //Test Methods//
    ////////////////
    
    //Test class to ensure the page renders as expected
    @isTest
    static void TestInstallationPlanningReturnMaterials(){           
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
    
    
    @isTest
    private static Opportunity TestScenarioCreateOppty(){
        
        Campaign newCampaign = new Campaign(Name = 'Test Temp Campaign', Group_Code__c='MEDA', Source__c='XP', Media_Cost_Code__c='atestvalue');
        insert newCampaign;         
        Opportunity opty = new Opportunity(Name = 'Test for Quote Decompile', StageName = 'Prospecting', CloseDate = Date.today(),LeadSource = 'Marcomms', CampaignId=newCampaign.ID, Product_Interest__c='Solar');        
        insert opty;        
        return opty;
    }
    
	@isTest
	private static ID TestScenarioCreateDistrict(){
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
    }        */    
 }