public with sharing class BigMachinesQuoteInsertJobReconciliation {
    
    //
    //This class reconciles a job with a quote. when a big machines quote is inserted it looks to find if a job already exists for the CHI Lead and if it does
    //it will link it to the quote. If a job record does not exist then the code creates one and populates skill hours based on those on the quote.
    //The code populates the district field on the Job record and sets the status and substatus fields accordingly.
    // 
    
    // Cognizant - CHI Phase III CR-002 implementation... START 
    
    public AddNewSkill ObjNewSkill = new AddNewSkill();
    
    // Cognizant - CHI Phase III CR-002 implementation... END    
    
    public void JobReconciliation(BigMachines_Quote__c triggerQuote){
                
        try{
            system.debug('triggerQuote.Consider_for_Installation_Planning__c is: '+triggerQuote.Consider_for_Installation_Planning__c);       
            system.debug('triggerQuote.Stage__c is: '+triggerQuote.Stage__c);
            system.debug('triggerQuote.Transferred_to_Premier__c is: '+triggerQuote.Transferred_to_Premier__c);
            system.debug('triggerQuote.bmStatusReason__c is: '+triggerQuote.bmStatusReason__c);
            system.debug('triggerQuote.quote_reconciled__c is: '+triggerQuote.quote_reconciled__c);
            if(triggerQuote.Consider_for_Installation_Planning__c=='Y' && triggerQuote.quote_reconciled__c==false){   
                //check to see if CHI Lead linked to the quote has a job record created. There should only ever be one job per Chi Lead so this will relate to this quote being inserted
                
                // Cognizant - CHI Phase III CR-002 implementation... START
    	 
    			Job__c[] quoteJobs = ObjNewSkill.fetchJobByCHILead(triggerQuote);
                //Job__c[] quoteJobs = [Select j.Delivery_Notes__c, j.Installation_Special_Instructions__c, j.Sub_Status__c, j.Status__c, j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Total_Job_Hours__c, j.Specialist_Building_Hours__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.Quote__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c, j.Electrical_Hours__c, j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.CHI_Lead__c, j.Building_Work_Hours__c, CHI_Lead__r.Account.BillingPostalCode From Job__c j where CHI_Lead__c=:triggerQuote.Opportunity__c AND Type__c = 'Central Heating Installation'];
                
                // Cognizant - CHI Phase III CR-002 implementation... END
                
                system.debug('quoteJobs.size() is:'+quoteJobs.size());
                //If a job exists update it with relevant info
                if(quoteJobs.size()<=1){                                            
                    //if one job found associated it with the quote. 
                    if(quoteJobs.size()==1){
                        Job__c quoteJob = quoteJobs[0];
                        quoteJob.Quote__c=triggerQuote.Id;                  
                        
                        //CR - Send text message to Salesman when the job is planned - starts
                          quoteJob.Quote_app_assigned_to__c = triggerQuote.App_Assigned_To__c;
                        //CR - Send text message to Salesman when the job is planned - Ends
                        
                        //Calculate postcode sector of the postcode by taking off the last 2 characters             
                        String postCodeSector = quoteJob.CHI_Lead__r.Account.BillingPostalCode.substring(0,quoteJob.CHI_Lead__r.Account.BillingPostalCode.length()-2);                                                      
                        //set district on job
                        quoteJob.District__c=getDistrict(postCodeSector);
                        //If job is Pending update hours with those from quote (they ae treated as the master data) and set sub status to inform planning is required
                        if( quoteJob.Status__c=='Pending'){
                            quoteJob = setJobHoursFromQuote(quoteJob,triggerQuote);
                            quoteJob.Sub_Status__c='Install date required';                 
                        }
                        // brm - 08-01-2010 - Gets around the validation rules when changing hours
                        quoteJob.Trigger_Update_Work_Hours__c = System.Now();
                        //ae - 16-01-2010 - Appends Delivery Notes from BM_Quote to Delivery Notes in Job (addresses Defect No 205)
                        //ae - 17-01-2010 - Only append if they will fit in 255 characters (including space)
                        if(quoteJob.Delivery_Notes__c <> null && triggerQuote.deliveryNotes__c <> null){
                            if(quoteJob.Delivery_Notes__c.length()+triggerQuote.deliveryNotes__c.length()<=254){ 
                               quoteJob.Delivery_Notes__c=quoteJob.Delivery_Notes__c + ' ' + triggerQuote.deliveryNotes__c;
                            }
                        } else if(quoteJob.Delivery_Notes__c == null && triggerQuote.deliveryNotes__c <> null){
                            quoteJob.Delivery_Notes__c = triggerQuote.deliveryNotes__c;
                        }
                        //ae - 16-01-2010 - Appends Installation_Special_Instructions from BM_Quote to Installation_Special_Instructions in Job (addresses Defect No 205)
                        //ae - 17-01-2010 - Only append if they will fit in 255 characters (including space)
                        if(quoteJob.Installation_Special_Instructions__c <> null && triggerQuote.Installation_Special_Instructions__c <> null){
                            if(quoteJob.Installation_Special_Instructions__c.length()+triggerQuote.Installation_Special_Instructions__c.length()<=254){ 
                                quoteJob.Installation_Special_Instructions__c = quoteJob.Installation_Special_Instructions__c + ' ' + triggerQuote.Installation_Special_Instructions__c;
                            }
                        } else if (quoteJob.Installation_Special_Instructions__c == null && triggerQuote.Installation_Special_Instructions__c <> null    ) {
                               quoteJob.Installation_Special_Instructions__c = triggerQuote.Installation_Special_Instructions__c;
                        }   
                        // change RHC : Set the RHC 
                        quoteJob.RHCUsername__c = triggerQuote.RHCUsername__c;
                        update quoteJob;
                        system.debug('quoteJob.Sub_Status__c is:'+quoteJob.Sub_Status__c);
                    }
                    //else if a job does not exist create a new one with the relevant info
                    else if(quoteJobs.size()==0){                   
                        //Calculate postcode sector of the postcode by taking off the last 2 characters             
                        //String postCode = [Select Account.BillingPostalCode from Opportunity where ID=:triggerQuote.Opportunity__c].Account.BillingPostalCode;
                        //String postCodeSector = postCode.substring(0,postCode.length()-2);                                                  
                        Job__c newQuoteJob = new Job__c(Quote__c=triggerQuote.Id,
                                                        //ae - 16-01-2010 - Copies Delivery Notes from BM_Quote to Delivery Notes in Job (addresses Defect No 205)
                                                        Delivery_Notes__c=triggerQuote.deliveryNotes__c,
                                                        //ae - 16-01-2010 - Copies Installation_Special_Instructions from BM_Quote to Installation_Special_Instructions in Job (addresses Defect No 205)
                                                        Installation_Special_Instructions__c = triggerQuote.Installation_Special_Instructions__c,
                                                        Status__c='Pending',
                                                        //District__c=getDistrict(postCodeSector),
                                                        CHI_Lead__c=triggerQuote.Opportunity__c,
                                                        Type__c = 'Central Heating Installation',
                                                        //RHC Change
                                                        RHCUsername__c = triggerQuote.RHCUsername__c);
                        
                        //CR - Send text message to Salesman when the job is planned - starts
                          newQuoteJob.Quote_app_assigned_to__c = triggerQuote.App_Assigned_To__c;
                        //CR - Send text message to Salesman when the job is planned - Ends
                                                        
                        boolean bmStatusReasonNotBlank = false;
                        if(triggerQuote.bmStatusReason__c!=null){
                            if(triggerQuote.bmStatusReason__c.length()>0)
                                bmStatusReasonNotBlank = true;                          
                        }
                        
                        
                        //Note - it should not occur that bmStatusReason is blank as it always has a value entered in Big Machines.  
                        if(bmStatusReasonNotBlank)
                            newQuoteJob.Sub_Status__c=triggerQuote.bmStatusReason__c;
                        else{
                            newQuoteJob.Sub_Status__c='Awaiting Planning';
                        }
                        
                        if(triggerQuote.POC_Payment_Method__c=='Finance')
                        {
                             List<Finance_Application__c> faList = [select id,Application_status__c from finance_application__c 
                                                where CHI_Lead__c=:triggerQuote.Opportunity__c and Application_status__c='Parked'];
                                                
                             if(faList.size()>0)
                             newQuoteJob.Sub_Status__c='Install date required';
                             else
                             newQuoteJob.Sub_Status__c='QFU - Awaiting finance paperwork';
                        }
                        
                        /*boolean isFinanceAccept= false;
                        List<Finance_Application__c> faList = [select id,Application_status__c from finance_application__c 
                                                where CHI_Lead__c=:triggerQuote.Opportunity__c and (Application_status__c='Accepted' OR Application_status__c='Parked') order by Application_status__c desc];
                        if(!faList.isEmpty())
                        {
                             for(Finance_Application__c fa: faList)
                             {
                                 if(fa.Application_status__c=='Parked')
                                 break;
                                 else
                                 isFinanceAccept=true; 
                             }
                        }
                        
                        if(isFinanceAccept)
                        {
                            newQuoteJob.Sub_Status__c='QFU - Awaiting finance paperwork';
                        }*/
                        newquoteJob = setJobHoursFromQuote(newQuoteJob,triggerQuote);   
                        insert newQuoteJob;                                                                                     
                    }
                    //Set checkbox to ensure quote doesnt get reconciled again
                    BigMachines_Quote__c bmquote = new BigMachines_Quote__c(ID=triggerQuote.ID);
                    bmquote.quote_reconciled__c=true;
                    update bmquote;
                } 
                //Combi Swap Change: Create a Task to CGC Agent if quote is Job Type Is 10.
                /*
                Commented By Cognizant on 06/04/2017#
                This functioanlity is not used any more.
                if(triggerQuote.Job_Type__c == '10')
                {
                	List<Task> taskList = new List<Task>();
                	for(Employee__c e :[Select  Salesforce_User__c from Employee__c where Employee_Number__c = :triggerQuote.App_Assigned_Payroll__c and Salesforce_User__r.isTeleSalesAgent__c = true and Salesforce_User__r.isActive = true])
                	{
                		Task  t = new task(WhatId = triggerQuote.Opportunity__c, OwnerId= e.Salesforce_User__c,Subject='Send Quote',Reason_Code__c='Send Combi Swap quote to Customer',ActivityDate=system.today(),Status='Not Started',Priority='High',RecordTypeId =system.label.SGCRecordType,ReminderDateTime = system.now(),IsReminderSet = true );
                		taskList.add(t);
                	}	
                	try{
                		insert taskList;
                	}catch(Exception e)
                	{
                		system.debug('Catch Excpetion --->'+e);
                	}
                }  */    
                
                
                
                if(IV_Vectors__c.getinstance('PhotoLabelChange')!=null && IV_Vectors__c.getinstance('PhotoLabelChange').Key__c == 'on')
                {
                	Map<string,DepotPhotoSettings1__c> photoSettings  = DepotPhotoSettings1__c.getAll();
					map<string, string> changedLabels = new map<string, string>();
					string whereClause = '';
					for(DepotPhotoSettings1__c d: photoSettings.values())
					{
					    if(d.Changed__c)
					    {
					        //changedLabels.add(d.Old_Label__c);
					        whereClause+= ' Name like \'%'+d.New_Label__c+'%\' OR';
					        
					        changedLabels.put(d.New_Label__c,d.Old_Label__c);
					    }
					}
					whereClause = whereClause.substring(0, whereClause.length()-2);
					system.debug('---->'+triggerQuote.Opportunity__c+triggerQuote);
					string oppId  = triggerQuote.Opportunity__c;
					String baseQuery = 'Select id, Name from Attachment where ParentId = :oppId And ';
					baseQuery+='('+whereClause+')';
					
					system.debug('---->'+baseQuery);
					
					if(changedLabels.size()>0)
					{
					    list<Attachment> attachementsAffected  = database.query(baseQuery);
					    if(attachementsAffected.size()>0)
					    {
					        for(Attachment a: attachementsAffected)
					        {
					            for(string s: changedLabels.keyset())
					            {
					                if(a.Name.contains(s))
					                {
					                    a.name = a.Name.replace(s, changedLabels.get(s));
					                    break;
					                }
					            }
					        }
					        
					        update attachementsAffected;
					    }
					}
				}
        	}
                
                
            }catch(exception e){
            system.debug('Exception occurred reconciling the Quote with a Job. Error reported was: '+e);
            triggerQuote.addError('Exception occurred reconciling the Quote with a Job. Error reported was: '+e);
        }
    }
    
    //set skill hours on Job record based on whats on the quote record
    //Note - this method is also called from the 'QuoteProductDecompile.cls'
    public Job__c setJobHoursFromQuote(Job__c job, BigMachines_Quote__c triggerQuote){
        
        // Cognizant - CHI Phase III CR-002 implementation... START
    	 
    	job = ObjNewSkill.setJobHoursFromQuote(job, triggerQuote);	
        
        /*job.Water_Heating_Fixing_Hours__c = triggerQuote.skillTotalWaterHeatingFixing__c;
        job.Unvented_Hot_Water_Hours__c = triggerQuote.skillTotalUnventedHotWater__c;
        job.Specialist_Building_Hours__c = triggerQuote.skillTotalSpecialistBuilding__c;
        job.Scaffolder_Hours__c = triggerQuote.skillTotalScaffolder__c;
        job.Roof_Work_Hours__c = triggerQuote.skillTotalRoofWork__c;
        job.Payment_Collection_Hours__c = triggerQuote.skillTotalPaymentCollection__c; 
        job.Mechanical_Hours__c = triggerQuote.skillTotalMechanical__c;
        job.LPG_Installation_Hours__c = triggerQuote.skillTotalLPGInstallation__c;
        job.Fire_Wall_Heater_Fixing_Hours__c = triggerQuote.skillTotalFireWallHeaterFixing__c;
        job.Electrical_Hours__c = triggerQuote.skillTotalElectrical__c;
        job.Contractor_Installation_Hours__c = triggerQuote.skillTotalContractorInstallation__c;
        job.Connect_Solar_Panel_Hours__c =triggerQuote.skillTotalConnectSolarPanels__c;
        job.Building_Work_Hours__c = triggerQuote.skillTotalBuildingWork__c;
        job.PowerFlush_Hours__c =triggerQuote.skillTotalPowerFlush__c;
        job.Electrical_Work_ASP_Hours__c=triggerQuote.SkillTotalElectricalWorkASP__c;
        job.Asbestos_Removal_Hours__c = triggerQuote.skillTotalAsbestosRemoval__c;
        job.Asbestos_Removal_Fixed_Rate_Hours__c =triggerQuote.skillTotalAsbestosRemovalFixedRate__c;
        job.Solar_Hours__c = triggerQuote.skillTotalSolar__c;*/
        
        // Cognizant - CHI Phase III CR-002 implementation... END
        
        return job;
    }
    
    //This select gets the district for the post code sector of type 'installation'                                       
    public ID getDistrict(String postCodeSector){

        system.debug('postCodeSector is: '+postCodeSector);         
        ID postCodeDistrict = [Select Sub_Patch__r.District__c From Postcode_Sector__c where name =:postCodeSector and type__c = 'Installation'].Sub_Patch__r.District__c;                  
        system.debug('postCodeDistrictID is: '+postCodeDistrict);       
        return postCodeDistrict;                
    }           
                
     //////////////////////////////
    //                          //
    //      TESTING CLASSES     //
    //                          //
    ////////////////////////////// 
    
    //Test Class to test the reconcile of a quote to a job. Insert a quote against a CHI Lead that does not have an associated 
    //job record. The class should create a new job associated to the quote and CHI Lead. The job district field should get populated
    //based on the chi leads account post code, the work hours should get copied to the new job from the quote, and the job status' should be set correctly.
    @isTest
    static void TestQuoteReconcile1(){          
        
        //Setup test environment
        ID districtID = TestScenarioCreateDistrict();
        Account Acc = TestScenarioCreateAccount(districtID);
        Opportunity opty = TestScenarioCreateOppty(Acc);                          
        
        //Assert no job exists for the CHI Lead before quote is inserted              
        System.assertEquals(0,[select count() from Job__c where CHI_Lead__c=:opty.id]);
        
        //insert the new quote against the CHI Lead
        Test.startTest();
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,1);                 
        Test.stopTest();
        
        //Assert a new job has been created and that it is linked to the quote and CHI Lead.              
        Job__c[] updatedJob = [select Quote__c,District__c, Status__c, Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Solar_Hours__c from Job__c where CHI_Lead__c=:opty.id]; 
        System.assertEquals(1, updatedJob.size()); 
        System.assertEquals(quote[0].Id, updatedJob[0].Quote__c); 
        //Assert status was successfully set to Pending
        System.assertEquals('Pending', updatedJob[0].Status__c);    
        //Assert sub status was successfully set to the field bmStatusReason from the quote
        System.assertEquals('Planning Pending - Gas Supply', updatedJob[0].Sub_Status__c);   
        System.assertEquals(districtID,updatedJob[0].District__c); 
        //Assert quote skill hours were copied to the quote 
        System.assertEquals(2.6,updatedJob[0].Water_Heating_Fixing_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Unvented_Hot_Water_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Specialist_Building_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Scaffolder_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Roof_Work_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Payment_Collection_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Mechanical_Hours__c);
        System.assertEquals(2.6,updatedJob[0].LPG_Installation_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Fire_Wall_Heater_Fixing_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Electrical_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Contractor_Installation_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Connect_Solar_Panel_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Building_Work_Hours__c);
        System.assertEquals(2.6,updatedJob[0].PowerFlush_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Electrical_Work_ASP_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Asbestos_Removal_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Asbestos_Removal_Fixed_Rate_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Solar_Hours__c);  
        //Assert checkbox checked to indicate quote was reconciled correctly  
        BigMachines_Quote__c quoteAfter = [select quote_reconciled__c from BigMachines_Quote__c where ID=:quote[0].Id];        
        System.assertEquals(true,quoteAfter.quote_reconciled__c);
    }       
    
    //Insert a quote against a CHI Lead, but this time ensure a job does exist for the CHI Lead before the quote is inserted
    //Assert the quote is linked to this existing job and assert that the status and hours on the job have been set according;y
    @isTest
    static void TestQuoteReconcile2(){          
        
        //Setup test environment
        ID districtID = TestScenarioCreateDistrict();
        Account Acc = TestScenarioCreateAccount(districtID); 
        Opportunity opty = TestScenarioCreateOppty(Acc);    
        Job__c[] Job = TestScenarioCreateJob('Pending','mismatch',opty.Id);                      
        
        //Assert a job exists before quote is inserted              
        System.assertEquals(1,[select count() from Job__c where CHI_Lead__c=:opty.id]);
        
        //insert quote when a Job exists against the CHI Lead
        Test.startTest();
        BigMachines_Quote__c[] quote = TestScenarioCreateQuote(opty,2);                 
        Test.stopTest();
        
        Job__c[] updatedJob = [select Quote__c,District__c, Status__c, Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Solar_Hours__c from Job__c where CHI_Lead__c=:opty.id]; 
        //Assert no new job was created
        System.assertEquals(1, updatedJob.size()); 
        //Assert the job now is linked to the quote after insertion and substatus is set correctly                     
        System.assertEquals(quote[0].Id, updatedJob[0].Quote__c); 
        System.assertEquals('Pending', updatedJob[0].Status__c);    
        System.assertNotEquals('Awaiting Planning', updatedJob[0].Sub_Status__c);                     
        //Assert district populated correctly       
        System.assertEquals(districtID,updatedJob[0].District__c);  
        //Assert skill hours copied correctly
        System.assertEquals(2.6,updatedJob[0].Water_Heating_Fixing_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Unvented_Hot_Water_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Specialist_Building_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Scaffolder_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Roof_Work_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Payment_Collection_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Mechanical_Hours__c);
        System.assertEquals(2.6,updatedJob[0].LPG_Installation_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Fire_Wall_Heater_Fixing_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Electrical_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Contractor_Installation_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Connect_Solar_Panel_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Building_Work_Hours__c);
        System.assertEquals(2.6,updatedJob[0].PowerFlush_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Electrical_Work_ASP_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Asbestos_Removal_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Asbestos_Removal_Fixed_Rate_Hours__c);
        System.assertEquals(2.6,updatedJob[0].Solar_Hours__c);  
        //Assert checkbox checked to indicate quote was reconciled correctly  
        BigMachines_Quote__c quoteAfter = [select quote_reconciled__c from BigMachines_Quote__c where ID=:quote[0].Id];        
        System.assertEquals(true,quoteAfter.quote_reconciled__c);
    }
    
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
}