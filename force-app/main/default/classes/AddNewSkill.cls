public with sharing class AddNewSkill 
{
    public static final String PRIMARY_SKILL = 'MECHANICAL'; // test this comment // add another one
    public static final Set<String> SKILLS_TO_IGNORE = new Set<String>{'SCAFFOLDER'};
    public static final Set<String> SKILLS_PLANNED_FROM_END = new Set<String>{'ELECTRICAL'};
    
    public AddNewSkill(){}
    
    public Job__c[] fetchJobByCHILead(BigMachines_Quote__c triggerQuote) //BigMachinesQuoteInsertJobReconciliation    
    {
        // fetch the newly added skill in below SOQL 
        
        Job__c[] quoteJobs = [Select j.Delivery_Notes__c, j.Installation_Special_Instructions__c, j.Sub_Status__c, j.Status__c, j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Total_Job_Hours__c, j.Specialist_Building_Hours__c, j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.Quote__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c, j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Work_ASP_Hours__c, j.Electrical_Hours__c, j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.CHI_Lead__c, j.Building_Work_Hours__c, j.Ecogen_Electrical_Hours__c, j.Ecogen_Mechanical_Hours__c,Remote_Heating__c,CHI_Lead__r.Account.BillingPostalCode , j.ECO_Hours__c, Trial_Names__c,j.Landlord_Check_Hours__c From Job__c j where CHI_Lead__c=:triggerQuote.Opportunity__c AND Type__c = 'Central Heating Installation'];
        return quoteJobs;
    }
    
    public List<Job__c> fetchJobforTransferringHours(ID jobID) //InstallPlanningReturnTransferController
    {
        // fetch the newly added skill in below SOQL
        
        List<Job__c> jobs = [select ID, Name,
                                j.Water_Heating_Fixing_Hours__c,
                                j.Unvented_Hot_Water_Hours__c, 
                                j.Total_Job_Hours__c,
                                j.Specialist_Building_Hours__c,
                                j.Solar_Hours__c,
                                j.Scaffolder_Hours__c,
                                j.Roof_Work_Hours__c,
                                j.PowerFlush_Hours__c,
                                j.Payment_Collection_Hours__c,
                                j.Mechanical_Hours__c,
                                j.LPG_Installation_Hours__c,
                                j.Fire_Wall_Heater_Fixing_Hours__c,
                                j.Electrical_Work_ASP_Hours__c,
                                j.Electrical_Hours__c,
                                j.Contractor_Installation_Hours__c,
                                j.Connect_Solar_Panel_Hours__c,
                                j.Building_Work_Hours__c,
                                j.Asbestos_Removal_Hours__c, 
                                j.Asbestos_Removal_Fixed_Rate_Hours__c,
                                j.Ecogen_Electrical_Hours__c,
                                j.Ecogen_Mechanical_Hours__c,
                                j.ECO_Hours__c,
                                j.Landlord_Check_Hours__c,
                                Job_Locked__c,
                                Remote_Heating__c,
                                Install_Postcode__c,
                                Latest_Customer_Category__c,status__c,
                                CHI_Lead__c,Is_Remedial_Job__c,Is_Downtime_Job__c,
            (select IsDeleted, Name, Order__c, Sub_Status__c, New_Supplier__c, New_Supplier_Number__c, Current_Supplier__c, Current_Supplier_Number__c, Units__c, Status__c, Skill__c, Product_ID__c, Line_Item_ID__c, ID, Description__c, Code__c from Job_Elements1__r where type__c='Work' AND Status__c='Active' AND Sub_Status__c != 'Returned' AND P5_IsItinerary__c!=TRUE order by Skill__c,Line_Item_ID__c),
            (select id,name,Week__c,week__r.Employee__c,supplier_num__c,Start__c,End__c,Employee_ID_18__c,Employee_Name__c,Sub_Type__c,Overbooked_Hours__c,Hours__c,Employee_ID__c, Job_Hours__c from Diary_Entries__r where RecordTypeId =: RecordTypeIdHelper.getRecordTypeId('Diary_Entry__c', 'Job Booking') order by sub_Type__c,Employee_ID__c )       
            from Job__c j where j.ID =: jobID];  
             
             // code changed to exclude itenary job elements from being listed while transferring work    
             
         return jobs;
    }
    
    public Job__c fetchJobByJob(ID jobID) //JobInformation    
    {
        // fetch the newly added skill in below SOQL
        // Named electritian change                
        Job__c job = [select j.ID, j.Named_Electritian__c, j.CHI_Lead__r.Install_Postcode__c, j.Total_Job_Hours__c,skip_8_12_Rule__c,Squeeze_Job__c,j.S_P_Hours__c,
                        j.Contractors__c, j.Own_Labour__c, Customer_Preferred_Date__c, j.Double_Handed_Job__c,j.Status__c,j.Sub_Status__c,j.Named_Employee__r.Always_Works_With_Electrician__c,
                        j.Water_Heating_Fixing_Hours__c, j.Unvented_Hot_Water_Hours__c, j.Specialist_Building_Hours__c, 
                        j.Scaffolder_Hours__c, j.Roof_Work_Hours__c, j.PowerFlush_Hours__c, j.Payment_Collection_Hours__c,j.Named_Employee_2__c,j.Named_Employee_2__r.Supplier_Branch_Num__c, 
                        j.Mechanical_Hours__c, j.LPG_Installation_Hours__c, j.Fire_Wall_Heater_Fixing_Hours__c, j.Electrical_Hours__c,
                        j.Contractor_Installation_Hours__c, j.Connect_Solar_Panel_Hours__c, j.Building_Work_Hours__c, j.Ecogen_Electrical_Hours__c, j.Ecogen_Mechanical_Hours__c, 
                        j.Named_Employee__r.Always_Works_With__c,j.Named_Employee__r.Supplier_Branch_Num__c,job_locked__c, j.Too_Many_Script_Statements__c, j.Landlord_Check_Hours__c,
                        j.Override_Gap_Size_Tolerance__c, j.Named_Employee__r.Resource_Type__c,Remote_Heating__c , j.ECO_Hours__c,Latest_customer_category__c, Balancing_Skill__c,
                        District__r.Contractor__c,  District__r.Contractor_Band1__c, District__r.Contractor_Band2__c, District__r.Contractor_Band3__c, District__r.Own_Labour__c,
                        District__r.Consider_Contractors__c, District__r.Consider_Own_Labour__c ,j.Finance_Expiry_Date__c,j.Installation_Date__c, Simple_Skills__c,Heavy_Appliance__c,Override_Heavy_Appliance__c,Scaffolding_Required__c,Boiler_Location__c,Installation_Type__c,
                        (select id,Week__c,Start__c,End__c,Employee_ID_18__c,Employee_Name__c,Sub_Type__c,Hours__c,Employee_ID__c from Diary_Entries__r), Overbooking_Identifier__c      
                        from Job__c j where j.ID = :jobID];
        
        return job;
    }
    //To validate the Skill Hours When HSA Plan the Job
    public void validateJobSkillHoursHSA(map<string,Double> skillsAndHours){
       system.debug(LoggingLevel.INFO,'Validate--->'+skillsAndHours);
       Set<String> simple = new Set<String>{'BUILDING WORK','ELECTRICAL','MECHANICAL','POWERFLUSH','ROOF WORK','SPECIALIST BUILDING','LANDLORD CHECK','REMOTE HEATING','SCAFFOLDER'};
        boolean complextype = FALSE;
        Double totalSkills = 0.0;
        
         for(String sk : skillsAndHours.keySet()) {
               If(simple.contains(sk)){
                   if(sk!='ELECTRICAL')
                   totalSkills += skillsAndHours.get(sk);
              
               continue;
               }
               else
               complextype = TRUE;
               
            }    
        
        system.debug(LoggingLevel.INFO,'00000'+complextype+totalSkills+system.label.TotalSkillhours);
        
        if(complextype){
        throw new SearchWorker.SearchException('This Job is classified as complex, please contact the office to plan.');
        }
        
        else if(!complextype && totalSkills>integer.valueOf(system.label.TotalSkillhours)){
        throw new SearchWorker.SearchException('Job skills should not exceed '+system.label.TotalSkillhours+' hours');     
        }
       
    }
    
    
    
    public Job__c fetchJobforSharing(ID quoteID)//JobSharingCls    
    {
        // fetch the newly added skill in below SOQL
        JOb__c job = [select id,name,CHI_Lead__c,Status__c,Mechanical_Hours__c,PowerFlush_Hours__c,Building_Work_Hours__c,Ecogen_Electrical_Hours__c,Ecogen_Mechanical_Hours__c,Installation_Date__c,Customer_Preferred_Date__c,Remote_Heating__c , ECO_Hours__c , Landlord_Check_Hours__c from Job__c where Quote__c =: quoteID];
        return job;
    }
    
    public Job__c fetchJobByJobId(Id jobId) //updateJobDetails    
    {
        Job__c job = [select Quote__r.skillTotalWaterHeatingFixing__c,Overriden__c,Quote__r.skillTotalUnventedHotWater__c,Quote__r.Remote_Heating__c,Quote__r.skillTotalSpecialistBuilding__c,Quote__r.skillTotalScaffolder__c,Quote__r.skillTotalRoofWork__c,Quote__r.skillTotalPaymentCollection__c,Quote__r.skillTotalMechanical__c,Quote__r.skillTotalLPGInstallation__c,Quote__r.skillTotalFireWallHeaterFixing__c,Quote__r.skillTotalElectrical__c,Quote__r.skillTotalContractorInstallation__c,Quote__r.skillTotalConnectSolarPanels__c,Quote__r.skillTotalBuildingWork__c,Quote__r.skillTotalPowerFlush__c,Quote__r.SkillTotalElectricalWorkASP__c,Quote__r.skillTotalAsbestosRemoval__c,Quote__r.skillTotalAsbestosRemovalFixedRate__c,Quote__r.skillTotalSolar__c,Quote__r.skillTotal_ecogenElectrical__c,Quote__r.skillTotal_ecogenMechanical__c,Quote__r.installationDate__c,Quote__r.deliveryDate__c,Installation_Date__c,Delivery_Date__c , Quote__r.skillTotalECO__c,Quote__r.Landlord_Check__c from Job__c where id =:jobId];
        return job;
    }
    
    public List<Job__c> fetchJobList(List<String> jobL) //SplitJobController    
    {
        List<Job__c> jobList = [select dont_override_hours__c,order_created__c,Split_Job__c,Water_Heating_Fixing_Hours__c,Building_Work_Hours__c,Connect_Solar_Panel_Hours__c,Contractor_Installation_Hours__c,Electrical_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,LPG_Installation_Hours__c,Mechanical_Hours__c,Payment_Collection_Hours__c,Roof_Work_Hours__c,Specialist_Building_Hours__c,Unvented_Hot_Water_Hours__c,PowerFlush_Hours__c,Solar_Hours__c,Ecogen_Electrical_Hours__c,Ecogen_Mechanical_Hours__c,id,Secondary_Job_Type_New__c,Remote_Heating__c , ECO_Hours__c , Landlord_Check_Hours__c from job__c where id in :jobL];                                
        return jobList;
    }
    
    public BigMachines_Quote__c fetchQuoteByQuote(ID quoteID) //QuoteProductDecompile    
    {
        System.debug('Quote received is :' +quoteID);
        // fetch the newly added skill in below SOQL 
        //CHI 2011 Commission Channge - added column 'X2011_Commission_Sales_value__c', 'Consider_for_Installation_Planning__c' in the select statetment , Average_Labour_Cost_Quote__c, Average_Material_Cost_Quote__c, quote_decompile_result__c
        BigMachines_Quote__c triggerQuote = [Select b.X2011_Commission_Sales_value__c , b.Projected_Commissionable_Margin__c, b.Consider_for_Installation_Planning__c, b.Average_Material_Cost_Quote__c, b.Average_Labour_Cost_Quote__c, b.quote_decompile_result__c, b.Is_Primary__c, b.finalPriceVisibleToCustomer__c, b.quote_reconciled__c, b.Line_Items_Decompiled__c, b.skillTotalWaterHeatingFixing__c, b.skillTotalUnventedHotWater__c, b.skillTotalSpecialistBuilding__c, b.skillTotalSolar__c, b.skillTotalScaffolder__c, b.skillTotalRoofWork__c, b.skillTotalPowerFlush__c, b.skillTotalPaymentCollection__c, b.skillTotalMechanical__c, 
        b.skillTotalLPGInstallation__c, b.skillTotalFireWallHeaterFixing__c, b.skillTotalElectrical__c, b.skillTotalContractorInstallation__c, b.skillTotalConnectSolarPanels__c, b.skillTotalBuildingWork__c, b.skillTotalAsbestosRemoval__c,
        isSystem__c, b.skillTotalAsbestosRemovalFixedRate__c, b.SkillTotalElectricalWorkASP__c, b.skillTotal_ecogenElectrical__c, b.skillTotal_ecogenMechanical__c, b.ASP_after_Billed__c,b.stage__c,b.Charge_to_Cutomer_after_Billed__c,b.Billed__c,
        Product_Type_ID__c,Remote_Heating__c , b.skillTotalECO__c, CS_Allowance_1__c,CS_Allowance_2__c, CS_Allowance_3__c, CS_Allowance_4__c, CS_Allowance_5__c, CS_Allowance_6__c,
        appliedAmount1__c, appliedAmount2__c, appliedAmount3__c, appliedAmount4__c,appliedAmount5__c, appliedAmount6__c,Non_Commissionable_sales_value__c,ECO_AW_GD__c,Opportunity__c,Landlord_Check__c
        From BigMachines_Quote__c b where Id=:quoteID];
                System.debug('Quote received is :' +triggerQuote);

                return triggerQuote;        
    }
    
    public Job__c[] fetchJobByQuote(ID quoteID, boolean stat) //QuoteProductDecompile    
    {
        // fetch the newly added skill in below SOQL 
        System.debug('Entering job by Quote');
        Job__c[] associatedJob = new Job__c[]{};
        
        if(stat == true)
            associatedJob = [Select Installation_Type__c, Boiler_Location__c, Total_Hours__c, Installation_Date__c,Quote__r.bmStatusReason__c,Job_Locked__c, Interface_Outstanding_Count__c, Id, Status__c,CHI_Lead__c,District__c,Quote__c,Type__c,Installer_Notes__c,Installation_Special_Instructions__c,Double_Handed_Job__c,Delivery_Notes__c,CRD_Code__c,Contractors__c,Contractor_Installation_Status__c,Bring_Forward_Job__c,Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Ecogen_Electrical_Hours__c,Ecogen_Mechanical_Hours__c,Delivery_Date__c,Solar_Hours__c,Is_Remedial_Job__c,Is_Downtime_Job__c,Pre_Electrical_Hours__c,Quote__r.Product_Type_ID__c,Remote_Heating__c , ECO_Hours__c , Landlord_Check_Hours__c, District__r.Premier_ready__c From Job__c where Quote__c =:quoteID and Status__c in ('Pending','Planned','Allocated','Installed','Installed - Awaiting Payment')and Is_Remedial_Job__c != true and Is_Downtime_Job__c != true limit 1];
        else
          System.debug('Entering else block');
            associatedJob = [Select Installation_Type__c, Boiler_Location__c ,Total_Hours__c, Installation_Date__c,Quote__r.bmStatusReason__c,Job_Locked__c, Interface_Outstanding_Count__c, Id, Status__c,CHI_Lead__c,District__c,Quote__c,Type__c,Installer_Notes__c,Installation_Special_Instructions__c,Double_Handed_Job__c,Delivery_Notes__c,CRD_Code__c,Contractors__c,Contractor_Installation_Status__c,Bring_Forward_Job__c,Sub_Status__c,Water_Heating_Fixing_Hours__c,Unvented_Hot_Water_Hours__c,Specialist_Building_Hours__c,Scaffolder_Hours__c,Roof_Work_Hours__c,Payment_Collection_Hours__c,Mechanical_Hours__c,LPG_Installation_Hours__c,Fire_Wall_Heater_Fixing_Hours__c,Electrical_Hours__c,Contractor_Installation_Hours__c,Connect_Solar_Panel_Hours__c,Building_Work_Hours__c,PowerFlush_Hours__c,Electrical_Work_ASP_Hours__c,Asbestos_Removal_Hours__c,Asbestos_Removal_Fixed_Rate_Hours__c,Ecogen_Electrical_Hours__c,Ecogen_Mechanical_Hours__c,Delivery_Date__c,Solar_Hours__c,Is_Remedial_Job__c,Is_Downtime_Job__c,Pre_Electrical_Hours__c,Quote__r.Product_Type_ID__c,Remote_Heating__c , ECO_Hours__c , Landlord_Check_Hours__c, District__r.Premier_ready__c  From Job__c where Quote__c =:quoteID and Is_Remedial_Job__c != true and Is_Downtime_Job__c != true limit 1];
        
        return associatedJob;
    }
    
    public boolean matchSkillHours(BigMachines_Quote__c triggerQuote, Job__c Job) //QuoteProductDecompile    
    {
        boolean skillHoursMatch=false;
        
        // Append the checks for new skill in below if block as it is done for rest of the skills.       
         
        if( ((Job.Water_Heating_Fixing_Hours__c == triggerQuote.skillTotalWaterHeatingFixing__c) || ((Job.Water_Heating_Fixing_Hours__c == null || Job.Water_Heating_Fixing_Hours__c == 0.00) && (triggerQuote.skillTotalWaterHeatingFixing__c == null || triggerQuote.skillTotalWaterHeatingFixing__c==0.00))) &&
            ((Job.Unvented_Hot_Water_Hours__c == triggerQuote.skillTotalUnventedHotWater__c) || ((Job.Unvented_Hot_Water_Hours__c == null || Job.Unvented_Hot_Water_Hours__c ==0.00) && (triggerQuote.skillTotalUnventedHotWater__c==null || triggerQuote.skillTotalUnventedHotWater__c==0.00))) &&
            ((Job.Specialist_Building_Hours__c == triggerQuote.skillTotalSpecialistBuilding__c) || ((Job.Specialist_Building_Hours__c == null || Job.Specialist_Building_Hours__c == 0.00) && (triggerQuote.skillTotalSpecialistBuilding__c==null || triggerQuote.skillTotalSpecialistBuilding__c==0.00))) &&
            ((Job.Scaffolder_Hours__c == triggerQuote.skillTotalScaffolder__c) || ((Job.Scaffolder_Hours__c == null || Job.Scaffolder_Hours__c == 0.00) && (triggerQuote.skillTotalScaffolder__c == null || triggerQuote.skillTotalScaffolder__c == 0.00))) &&
            ((Job.Roof_Work_Hours__c == triggerQuote.skillTotalRoofWork__c) || ((Job.Roof_Work_Hours__c == null || Job.Roof_Work_Hours__c==0.00) && (triggerQuote.skillTotalRoofWork__c ==null || triggerQuote.skillTotalRoofWork__c == 0.00))) &&
            ((Job.Payment_Collection_Hours__c == triggerQuote.skillTotalPaymentCollection__c) || ((Job.Payment_Collection_Hours__c == null || Job.Payment_Collection_Hours__c ==0.00) && (triggerQuote.skillTotalPaymentCollection__c == null || triggerQuote.skillTotalPaymentCollection__c == 0.00))) && 
            ((Job.Mechanical_Hours__c == triggerQuote.skillTotalMechanical__c) || ((Job.Mechanical_Hours__c == null || Job.Mechanical_Hours__c ==0.00) && (triggerQuote.skillTotalMechanical__c == null || triggerQuote.skillTotalMechanical__c==0.00))) &&
            ((Job.LPG_Installation_Hours__c == triggerQuote.skillTotalLPGInstallation__c) || ((Job.LPG_Installation_Hours__c == null || Job.LPG_Installation_Hours__c == 0.00) && (triggerQuote.skillTotalLPGInstallation__c==null || triggerQuote.skillTotalLPGInstallation__c==0.00))) &&
            ((Job.Fire_Wall_Heater_Fixing_Hours__c == triggerQuote.skillTotalFireWallHeaterFixing__c) || ((Job.Fire_Wall_Heater_Fixing_Hours__c == null || Job.Fire_Wall_Heater_Fixing_Hours__c == 0.00) && (triggerQuote.skillTotalFireWallHeaterFixing__c == null || triggerQuote.skillTotalFireWallHeaterFixing__c == 0.00))) &&
            ((Job.Electrical_Hours__c == triggerQuote.skillTotalElectrical__c) || ((Job.Electrical_Hours__c == 0.00 || Job.Electrical_Hours__c == null) && (triggerQuote.skillTotalElectrical__c == null || triggerQuote.skillTotalElectrical__c == 0.00))) &&
            ((Job.Contractor_Installation_Hours__c == triggerQuote.skillTotalContractorInstallation__c) || ((Job.Contractor_Installation_Hours__c == null || Job.Contractor_Installation_Hours__c == 0.00) && (triggerQuote.skillTotalContractorInstallation__c == null || triggerQuote.skillTotalContractorInstallation__c == 0.00))) &&
            ((Job.Connect_Solar_Panel_Hours__c ==triggerQuote.skillTotalConnectSolarPanels__c) || ((Job.Connect_Solar_Panel_Hours__c == null || Job.Connect_Solar_Panel_Hours__c ==0.00) && (triggerQuote.skillTotalConnectSolarPanels__c==null || triggerQuote.skillTotalConnectSolarPanels__c==0.00))) &&
            ((Job.Building_Work_Hours__c == triggerQuote.skillTotalBuildingWork__c) || ((Job.Building_Work_Hours__c == null || Job.Building_Work_Hours__c == 0.00) && (triggerQuote.skillTotalBuildingWork__c == null || triggerQuote.skillTotalBuildingWork__c==0.00))) &&
            ((Job.PowerFlush_Hours__c ==triggerQuote.skillTotalPowerFlush__c) || ((Job.PowerFlush_Hours__c ==null || Job.PowerFlush_Hours__c ==0.00) && (triggerQuote.skillTotalPowerFlush__c == null || triggerQuote.skillTotalPowerFlush__c == 0.00))) &&
            ((Job.Electrical_Work_ASP_Hours__c==triggerQuote.SkillTotalElectricalWorkASP__c) || ((Job.Electrical_Work_ASP_Hours__c==null || Job.Electrical_Work_ASP_Hours__c== 0.00) && (triggerQuote.SkillTotalElectricalWorkASP__c == null || triggerQuote.SkillTotalElectricalWorkASP__c == 0.00))) &&
            ((Job.Asbestos_Removal_Hours__c == triggerQuote.skillTotalAsbestosRemoval__c) || ((Job.Asbestos_Removal_Hours__c == null || Job.Asbestos_Removal_Hours__c == 0.00) && (triggerQuote.skillTotalAsbestosRemoval__c==null || triggerQuote.skillTotalAsbestosRemoval__c==0.00))) &&
            ((Job.Asbestos_Removal_Fixed_Rate_Hours__c ==triggerQuote.skillTotalAsbestosRemovalFixedRate__c) || ((Job.Asbestos_Removal_Fixed_Rate_Hours__c == null || Job.Asbestos_Removal_Fixed_Rate_Hours__c == 0.00) && (triggerQuote.skillTotalAsbestosRemovalFixedRate__c==null || triggerQuote.skillTotalAsbestosRemovalFixedRate__c==0.00))) &&
            ((Job.Solar_Hours__c == triggerQuote.skillTotalSolar__c) || ((Job.Solar_Hours__c == null || Job.Solar_Hours__c == 0.00) && (triggerQuote.skillTotalSolar__c == null || triggerQuote.skillTotalSolar__c == 0.00))) &&
            ((Job.Ecogen_Electrical_Hours__c == triggerQuote.skillTotal_ecogenElectrical__c) || ((Job.Ecogen_Electrical_Hours__c == null || Job.Ecogen_Electrical_Hours__c == 0.00) && (triggerQuote.skillTotal_ecogenElectrical__c == null || triggerQuote.skillTotal_ecogenElectrical__c == 0.00))) &&
            ((Job.Ecogen_Mechanical_Hours__c == triggerQuote.skillTotal_ecogenMechanical__c) || ((Job.Ecogen_Mechanical_Hours__c == null || Job.Ecogen_Mechanical_Hours__c == 0.00) && (triggerQuote.skillTotal_ecogenMechanical__c == null || triggerQuote.skillTotal_ecogenMechanical__c == 0.00))) &&
            ((Job.ECO_Hours__c == triggerQuote.skillTotalECO__c) || ((Job.ECO_Hours__c == null || Job.ECO_Hours__c == 0.00) && (triggerQuote.skillTotalECO__c == null || triggerQuote.skillTotalECO__c == 0.00))) &&
            ((Job.Remote_Heating__c == triggerQuote.Remote_Heating__c) || ((Job.Remote_Heating__c == null || Job.Remote_Heating__c == 0.00) && (triggerQuote.Remote_Heating__c == null || triggerQuote.Remote_Heating__c == 0.00))) &&
            ((Job.Landlord_Check_Hours__c == triggerQuote.Landlord_Check__c) || ((Job.Landlord_Check_Hours__c == null || Job.Landlord_Check_Hours__c == 0.00) && (triggerQuote.Landlord_Check__c == null || triggerQuote.Landlord_Check__c == 0.00)))){
                                    
                skillHoursMatch=true;
            }      
        return skillHoursMatch; 
    }
    
    public List<Job__c> setJobHours(List<Job__c> jobList,Map<String,String> pwMap,Map<String,boolean> jobBMap,Map<String,Integer> qtyMap)//SplitJobController  
    {
        Integer posNeg=1;      
        boolean ordrCreated = false;
        
        //added : 06/09
        for(Job__c job : jobList){
            boolean rem = jobBMap.get(job.id);
            if(rem == true){
              ordrCreated = job.Order_Created__c;
           }
        }
        boolean splitjob=true;
        //end
        for(Job__c job : jobList){
           job.Status__c ='Pending';
           job.Sub_Status__c = 'Awaiting Planning'; 
           if(splitjob == true)
           {
            splitjob = false;
           }else{
           job.Secondary_Job_Type_New__c = 'Split Job';
           }
           job.Split_Job__c = true;
           job.Trigger_Update_Work_Hours__c = System.Now();   //To get around validation  . 04/03/2010
           boolean rem = jobBMap.get(job.id);
           if(rem == true){
              posNeg = -1;
              job.dont_override_hours__c = true;
              //ordrCreated = job.Order_Created__c;
           }
           else{
             posNeg = 1;
             job.order_Created__c =ordrCreated;
           }
            system.debug('pwMap----->'+pwMap);
           for(String code : pwMap.keySet()){
                String[] strList = (pwMap.get(code)).split('/');
                Integer qtyTotal = qtyMap.get(code);
                for(String str : strList){
                    String[] tempStr = str.split(':');
                    String skillStr = tempStr[0];
                    String hoursStr = tempStr[1];
                    if(skillStr.contains('Ecogen Mechanical'))
                        job.Ecogen_Mechanical_Hours__c = job.Ecogen_Mechanical_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Ecogen Electrical'))
                        job.Ecogen_Electrical_Hours__c = job.Ecogen_Electrical_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Water Heater Fixing'))
                        job.Water_Heating_Fixing_Hours__c = job.Water_Heating_Fixing_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Building Work'))
                        job.Building_Work_Hours__c = job.Building_Work_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Connect Solar'))
                    {system.debug('Connect Solar');
                        job.Connect_Solar_Panel_Hours__c =job.Connect_Solar_Panel_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    }
                    else if(skillStr.contains('Contractor Installation'))
                        job.Contractor_Installation_Hours__c = job.Contractor_Installation_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Electrical'))
                        job.Electrical_Hours__c = job.Electrical_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('FIRE'))
                        job.Fire_Wall_Heater_Fixing_Hours__c = job.Fire_Wall_Heater_Fixing_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('LPG'))
                        job.LPG_Installation_Hours__c = job.LPG_Installation_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Mechanical')){
                        job.Mechanical_Hours__c = job.Mechanical_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    }
                    else if(skillStr.contains('Payment Collection'))
                        job.Payment_Collection_Hours__c = job.Payment_Collection_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Roof Work'))
                        job.Roof_Work_Hours__c = job.Roof_Work_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Specialist Building'))
                        job.Specialist_Building_Hours__c = job.Specialist_Building_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('Unvented'))
                        job.Unvented_Hot_Water_Hours__c = job.Unvented_Hot_Water_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    else if(skillStr.contains('POWERFLUSH')){
                        job.PowerFlush_Hours__c = job.PowerFlush_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                    }
                    else if(skillStr.contains('INSTALL SOLAR'))
                      {system.debug('INSTALL SOLAR');
                        job.Solar_Hours__c = job.Solar_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                      }
                   else if(skillStr.contains('Remote Heating'))
                      {
                        job.Remote_Heating__c = job.Remote_Heating__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                      }
                   else if(skillStr.contains('ECO'))
                      {
                        job.ECO_Hours__c = job.ECO_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);
                      }
                   else if(skillStr.contains('Landlord Check'))
                      {                      
                        job.Landlord_Check_Hours__c = job.Landlord_Check_Hours__c+(qtyTotal)*(posNeg)*Double.valueOf(hoursStr);   
                      } 
                }
           }
       }
       return jobList;
    }
    
    public Map<String,String> setSkillMap() //BatchPopulateSFPO7523Records    
    {
        Map<String,String> skillCodeMap = new Map<String,String>();
        
        skillCodeMap.put('Asbestos Removal','A');
        skillCodeMap.put('Asbestos Removal Fixed Rate','AF');
        skillCodeMap.put('Building Work','B');
        skillCodeMap.put('Contractor Installation','CI');
        skillCodeMap.put('Electrical','E');
        skillCodeMap.put('Electrical Work ASP','EA');
        skillCodeMap.put('FIRE/WALL HEATER FIXING','FF');
        skillCodeMap.put('FireWall Heater Fixing','FF');
        skillCodeMap.put('LPG Installation','LP');
        skillCodeMap.put('Mechanical','M');
        skillCodeMap.put('Connect Solar Panels','MSL');
        skillCodeMap.put('Payment Collection','PC');
        skillCodeMap.put('Powerflush','PF');
        skillCodeMap.put('Roof Work','R');
        skillCodeMap.put('Scaffolder','S');
        skillCodeMap.put('Specialist Building','SB');
        skillCodeMap.put('Specialist Building Work','SB');
        skillCodeMap.put('Solar','SOL');
        skillCodeMap.put('Unvented Hot Water','UV');
        skillCodeMap.put('Water Heater Fixing','WH');
        skillCodeMap.put('Ecogen Mechanical','MEG');
        skillCodeMap.put('Bespoke Installation Work','BIW');
        skillCodeMap.put('Professional Cleaning','PC');
        skillCodeMap.put('Core Cutting (Scotland)','CC');
        skillCodeMap.put('Carpentry','C');
        skillCodeMap.put('Remote Heating','RH');
        skillCodeMap.put('ECO','ECO');
        skillCodeMap.put('INSTALL SOLAR PANELS','ISP');
        skillCodeMap.put('Landlord Check','LC');
        for(Planning_Skill__mdt ps : [Select id , MasterLabel , Code__c from Planning_Skill__mdt ] )
        {
            skillCodeMap.put(ps.MasterLabel,ps.Code__c);
        }
        return skillCodeMap;
    }
    
    public List<Search_Result__c> orderResultOptions(List<Search_Result__c> resultOptions, Map<String, Boolean> skillToDoubleHandedMap, List<Search_Result__c> tempResultOptions) //JobBookingManager    
    {
        // If new skill to be added is to be a primary skill on the job or need to have some specific location for the new skill diary entry while
        // planning the job then we need to change the below method.
        
        //List<Search_Result__c> tempResultOptions = new List<Search_Result__c>();
        Search_Result__c firstResult;
        Search_Result__c secondResult;
        List<Search_Result__c> doubleHandedResults = new List<Search_Result__c>();
        List<Search_Result__c> otherResults = new List<Search_Result__c>();
        List<Search_Result__c> TravelFront = new List<Search_Result__c>();
        List<Search_Result__c> TravelBack = new List<Search_Result__c>(); 
        //categorise the results
        for(Search_Result__c resultOption : resultOptions)
        {
            //Engineer Travel - Change start
            if(resultOption.Skill__c == 'Travel Time')
            {
                if(resultOption.Order__c == 'Front')
                {
                    TravelFront.add(resultOption);
                }else
                {
                    TravelBack.add(resultOption);
                }
                continue;
                //Engineer Travel - End
            }else if(resultOption.Skill__c == 'Mechanical')
            {
                firstResult = resultOption;
            }
            else if(resultOption.Skill__c == 'Powerflush')
            {
                secondResult = resultOption;
            }
            else if(skillToDoubleHandedMap.get(resultOption.Skill__c) == true)
            {
                doubleHandedResults.add(resultOption);
            }
            else
            {
                otherResults.add(resultOption);
            }           
        }
        
        //now put everything in the correct order
        if(firstResult != null) tempResultOptions.add(firstResult);
        if(secondResult != null) tempResultOptions.add(secondResult);           
        //put double handed and other results in alphabetical order   
        
        if(doubleHandedResults.size() > 0)
        {
            doubleHandedResults = makeResultsAlphabetical(doubleHandedResults);
            tempResultOptions.addAll(doubleHandedResults);
        }
        if(otherResults.size() > 0)
        {
            otherResults = makeResultsAlphabetical(otherResults);
            tempResultOptions.addAll(otherResults);
        }
        //Engineer Travel - Change start
        TravelFront.addall(tempResultOptions);
        TravelFront.addall(TravelBack);
        tempResultOptions = TravelFront;
        
        //Engineer Travel - End
        //this.resultOptions.clear();
        //this.resultOptions = tempResultOptions;
        return tempResultOptions;
    }
    
    private List<Search_Result__c> makeResultsAlphabetical(List<Search_Result__c> unorderedList) //JobBookingManager    
    {
        Map<String, Search_Result__c> skillToResultMap = new Map<String, Search_Result__c>();
        List<Search_Result__c> orderedList = new List<Search_Result__c>();
        for(Search_Result__c unorderedItem : unorderedList)
        {
            skillToResultMap.put(unorderedItem.Skill__c, unorderedItem);
        }   
        List<String> skillNames = new List<String>(skillToResultMap.keySet());
        skillNames.sort();
        for(String skillName : skillNames)
        {
            orderedList.add(skillToResultMap.get(skillName));
        }
        return orderedList;
    }   
    
    public Job__c setJobHoursFromQuote(Job__c job, BigMachines_Quote__c triggerQuote) //BigMachinesQuoteInsertJobReconciliation   
    {
        // Add the code to set the new skill in job
                
        job.Water_Heating_Fixing_Hours__c = triggerQuote.skillTotalWaterHeatingFixing__c;
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
        job.Solar_Hours__c = triggerQuote.skillTotalSolar__c;
        job.Ecogen_Electrical_Hours__c = triggerQuote.skillTotal_ecogenElectrical__c;
        job.Ecogen_Mechanical_Hours__c = triggerQuote.skillTotal_ecogenMechanical__c;
        job.Remote_Heating__c = triggerQuote.Remote_Heating__c;
        job.ECO_Hours__c = triggerQuote.skillTotalECO__c;
        job.Landlord_Check_Hours__c = triggerQuote.Landlord_Check__c;
        
        return job;
    }   
    
    public Job__c reduceSkillValues(Job__c thisJob, String Skill, Double totalReduction)//InstallPlanningReturnTransferController
    {
        // Add a similar if statement for the new skill as we are doing for rest of the skills.
         
        if(skill == 'Mechanical')
            thisJob.Mechanical_Hours__c -= totalReduction; 
        else if(Skill == 'Building Work')
            thisJob.Building_Work_Hours__c -= totalReduction;
        else if(Skill == 'Unvented_Hot_Water')
            thisJob.Unvented_Hot_Water_Hours__c -= totalReduction; 
        else if(Skill == 'Specialist_Building_Work')
            thisJob.Specialist_Building_Hours__c -= totalReduction;
        else if(Skill == 'Scaffolder')
            thisJob.Scaffolder_Hours__c -= totalReduction;
        else if(Skill == 'Roof_Work')
            thisJob.Roof_Work_Hours__c -= totalReduction;
        else if(Skill == 'Powerflush')
            thisJob.PowerFlush_Hours__c -= totalReduction;
        else if(Skill == 'Payment_Collection')
            thisJob.Payment_Collection_Hours__c -= totalReduction;
        else if(Skill == 'LPG_Installation')
            thisJob.LPG_Installation_Hours__c -= totalReduction;
        else if(Skill == 'Fire/Wall_Heater_Fixing')
            thisJob.Fire_Wall_Heater_Fixing_Hours__c -= totalReduction;
        else if(Skill == 'Electrical_Work_ASP')
            thisJob.Electrical_Work_ASP_Hours__c -= totalReduction;
        else if(Skill == 'Electrical')
            thisJob.Electrical_Hours__c -= totalReduction;
        else if(Skill == 'Contractor_Installation')
            thisJob.Contractor_Installation_Hours__c -= totalReduction;
        else if(Skill == 'Connect_Solar_Panels')
            thisJob.Connect_Solar_Panel_Hours__c -= totalReduction;
        else if(Skill == 'Asbestos_Removal')
            thisJob.Asbestos_Removal_Hours__c -= totalReduction;
        else if(Skill == 'Asbestos_Removal-Fixed_Rate')
            thisJob.Asbestos_Removal_Fixed_Rate_Hours__c -= totalReduction;
        else if(Skill == 'Water_Heater_Fixing')
            thisJob.Water_Heating_Fixing_Hours__c -= totalReduction;
        else if(Skill == 'Ecogen Electrical')
            thisJob.Ecogen_Electrical_Hours__c -= totalReduction;
        else if(Skill == 'Ecogen Mechanical')
            thisJob.Ecogen_Mechanical_Hours__c -= totalReduction;
        else if(Skill == 'Remote Heating')
            thisJob.Remote_Heating__c -= totalReduction;
        else if(Skill == 'ECO')
            thisJob.ECO_Hours__c -= totalReduction;
        else if(Skill == 'Landlord Check')
            thisJob.Landlord_Check_Hours__c -= totalReduction;

        return thisJob;
    }
    
    public Map<String, Double> setSkillHoursInfo(Job__c job, Map<String, Double> skillsAndHours) //JobInformation    
    {
        // Add a similar if statement for the new skill as we are doing for rest of the skills.
        
        if(job.Building_Work_Hours__c > 0){
          skillsAndHours.put('BUILDING WORK', job.Building_Work_Hours__c);
        }
        if(job.Connect_Solar_Panel_Hours__c > 0){
          skillsAndHours.put('CONNECT SOLAR PANELS', job.Connect_Solar_Panel_Hours__c);
        }
        if(job.Contractor_Installation_Hours__c > 0){
          skillsAndHours.put('CONTRACTOR INSTALLATION', job.Contractor_Installation_Hours__c);
        }
        if(job.Electrical_Hours__c > 0){
          skillsAndHours.put('ELECTRICAL', job.Electrical_Hours__c);
        }
        if(job.Fire_Wall_Heater_Fixing_Hours__c > 0) {
          skillsAndHours.put('FIRE/WALL HEATER FIXING', job.Fire_Wall_Heater_Fixing_Hours__c);
        }
        if(job.LPG_Installation_Hours__c > 0) {
          skillsAndHours.put('LPG INSTALLATION', job.LPG_Installation_Hours__c);  
        }
        if(job.Mechanical_Hours__c > 0) {
            decimal mechanicalHours = job.Mechanical_Hours__c;
            if(job.Balancing_Skill__c !=null)
            mechanicalHours  += job.Balancing_Skill__c;
            
            system.debug('Mechanical Skill After Balancing--->'+mechanicalHours);   
          skillsAndHours.put('MECHANICAL', mechanicalHours);
        }
        if(job.Payment_Collection_Hours__c > 0) {
          skillsAndHours.put('PAYMENT COLLECTION', job.Payment_Collection_Hours__c);
        }
        if(job.PowerFlush_Hours__c > 0) {
          skillsAndHours.put('POWERFLUSH', job.PowerFlush_Hours__c);
        }
        if(job.Roof_Work_Hours__c > 0) {
          skillsAndHours.put('ROOF WORK', job.Roof_Work_Hours__c);
        }


        /* Cognizant----------Phase 5 Development---------------------- 30/07/2010:---------
        Scaffolder Skiil need to be removed from Job Planning module.
        Scaffolder is and itinary item and this needs to be handled by booking the 
        Appointment for the Job element.
        ----------------------------
        
        if(job.Scaffolder_Hours__c > 0) {
          skillsAndHours.put('SCAFFOLDER', job.Scaffolder_Hours__c);
        }
    
        ending here...
        */
        if(job.Specialist_Building_Hours__c > 0) {
          skillsAndHours.put('SPECIALIST BUILDING', job.Specialist_Building_Hours__c);
        }
        if(job.Unvented_Hot_Water_Hours__c > 0) {
          skillsAndHours.put('UNVENTED HOT WATER', job.Unvented_Hot_Water_Hours__c);
        }
        if(job.Water_Heating_Fixing_Hours__c > 0) {
          skillsAndHours.put('WATER HEATER FIXING', job.Water_Heating_Fixing_Hours__c);
        }
        if(job.Ecogen_Electrical_Hours__c > 0) {
            skillsAndHours.put('ECOGEN ELECTRICAL', job.Ecogen_Electrical_Hours__c);
        }
        if(job.Ecogen_Mechanical_Hours__c > 0) {
            skillsAndHours.put('ECOGEN MECHANICAL', job.Ecogen_Mechanical_Hours__c);
        }
        if(job.Remote_Heating__c > 0) {
            skillsAndHours.put('REMOTE HEATING', job.Remote_Heating__c);
        }
        if(job.ECO_Hours__c > 0) {
            skillsAndHours.put('ECO', job.ECO_Hours__c);
        }
        if(job.Landlord_Check_Hours__c > 0) {
            skillsAndHours.put('LANDLORD CHECK', job.Landlord_Check_Hours__c);
        }

        return skillsAndHours;
    }

    public list<string> setSimpleSkills (Job__c job)
    {

        if(job.Simple_Skills__c!=null)
        return job.Simple_Skills__c.split(';');
        else 
        return new list<string>();


    }
    
    public void setNewSkillHours(Job__c associatedJob, BigMachines_Quote__c triggerQuote, List<Job_Element__c> workJobElementsToInsert, List<Job_Element__c> jobElementsToRemove, boolean[] hoursAffected) //QuoteProductDecompile   
    {
        
    
        //intialise hours counters to zero
        double Water_Heating_Fixing_Hours = 0;
        double Unvented_Hot_Water_Hours = 0;
        double Specialist_Building_Hours = 0;
        double Scaffolder_Hours = 0;
        double Roof_Work_Hours = 0;
        double Payment_Collection_Hours = 0;
        double Mechanical_Hours = 0;
        double LPG_Installation_Hours = 0;
        double Fire_Wall_Heater_Fixing_Hours = 0;
        double Electrical_Hours = 0;
        double Contractor_Installation_Hours = 0;
        double Connect_Solar_Panel_Hours = 0;
        double Building_Work_Hours = 0;
        double PowerFlush_Hours = 0;
        double Electrical_Work_ASP_Hours = 0;
        double Asbestos_Removal_Hours = 0;
        double Asbestos_Removal_Fixed_Rate_Hours = 0;
        double Solar_Hours = 0; 
        double PreElectrical_Hours = 0;  
        double Ecogen_Mechanical_Hours = 0; 
        double Ecogen_Electrical_Hours = 0;              
        double Remote_Heating_Hours = 0;
        double ECO_Hours = 0;
        double Landlord_Check_Hours = 0;
        
        system.debug('here 1');
        system.debug('workJobElementsToInsert is: ' +workJobElementsToInsert);
        //for any Added work elements increament the correct hours counter
        if(!workJobElementsToInsert.isEmpty()){
            hoursAffected[0]=true;
            for(integer y=0;y<workJobElementsToInsert.size();y++){
                if(workJobElementsToInsert[y].Skill__c != null){ //rjd - 2010/01/07 - Bug 120 - stop NPE
                    if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='MECHANICAL')
                        Mechanical_Hours = Mechanical_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='WATER HEATER FIXING')
                        Water_Heating_Fixing_Hours = Water_Heating_Fixing_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='SPECIALIST BUILDING')
                        Specialist_Building_Hours = Specialist_Building_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='SCAFFOLDER')
                        Scaffolder_Hours = Scaffolder_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ROOF WORK')
                        Roof_Work_Hours = Roof_Work_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='PAYMENT COLLECTION')
                        Payment_Collection_Hours = Payment_Collection_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ELECTRICAL')
                        Electrical_Hours = Electrical_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='LPG INSTALLATION')
                        LPG_Installation_Hours = LPG_Installation_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='FIREWALL HEATER FIXING')
                        Fire_Wall_Heater_Fixing_Hours = Fire_Wall_Heater_Fixing_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='CONTRACTOR INSTALLATION')
                        Contractor_Installation_Hours = Contractor_Installation_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='CONNECT SOLAR PANELS')
                        Connect_Solar_Panel_Hours = Connect_Solar_Panel_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='BUILDING WORK')             
                        Building_Work_Hours = Building_Work_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='POWERFLUSH')
                        PowerFlush_Hours = PowerFlush_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ELECTRICAL WORK ASP')
                        Electrical_Work_ASP_Hours = Electrical_Work_ASP_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ASBESTOS REMOVAL')
                        Asbestos_Removal_Hours = Asbestos_Removal_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ASBESTOS REMOVAL FIXED RATE')
                        Asbestos_Removal_Fixed_Rate_Hours = Asbestos_Removal_Fixed_Rate_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='SOLAR')
                        Solar_Hours = Solar_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='PRE-ELECTRICAL SURVEY')
                        PreElectrical_Hours = PreElectrical_Hours + workJobElementsToInsert[y].Units__c;  
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ECOGEN MECHANICAL')
                        Ecogen_Mechanical_Hours = Ecogen_Mechanical_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ECOGEN ELECTRICAL')
                        Ecogen_Electrical_Hours = Ecogen_Electrical_Hours + workJobElementsToInsert[y].Units__c;  
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='Remote Heating')
                        Remote_Heating_Hours = Remote_Heating_Hours + workJobElementsToInsert[y].Units__c;
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='ECO')
                        ECO_Hours = ECO_Hours + workJobElementsToInsert[y].Units__c; 
   
                    //++PRB00013941 coding starts 
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='UNVENTED HOT WATER'){
                        Unvented_Hot_Water_Hours = Unvented_Hot_Water_Hours + workJobElementsToInsert[y].Units__c; 
                    }   
                    //--PRB00013941 coding ends  
                        
                    else if(workJobElementsToInsert[y].Skill__c.toUpperCase()=='Landlord Check')
                        Landlord_Check_Hours = Landlord_Check_Hours + workJobElementsToInsert[y].Units__c;    
                       
                                 
                }   
            }
        }
        system.debug('jobElementsToRemove: '+jobElementsToRemove);
       
        //for any Removed work elements decrease the correct hours counter
        
        if(!jobElementsToRemove.isEmpty()){         
            hoursAffected[0]=true;
            for(integer y=0;y<jobElementsToRemove.size();y++){
                if(jobElementsToRemove[y].Skill__c != null)   //rjd - 2010/01/07 - Bug 120 - stop NPE
                {   
                    if(jobElementsToRemove[y].Skill__c.toUpperCase()=='MECHANICAL')
                        Mechanical_Hours = Mechanical_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='WATER HEATER FIXING')
                        Water_Heating_Fixing_Hours = Water_Heating_Fixing_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='SPECIALIST BUILDING')
                        Specialist_Building_Hours = Specialist_Building_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='SCAFFOLDER')
                        Scaffolder_Hours = Scaffolder_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ROOF WORK')
                        Roof_Work_Hours = Roof_Work_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='PAYMENT COLLECTION')
                        Payment_Collection_Hours = Payment_Collection_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ELECTRICAL')
                        Electrical_Hours = Electrical_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='LPG INSTALLATION')
                        LPG_Installation_Hours = LPG_Installation_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='FIREWALL HEATER FIXING')
                        Fire_Wall_Heater_Fixing_Hours = Fire_Wall_Heater_Fixing_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='CONTRACTOR INSTALLATION')
                        Contractor_Installation_Hours = Contractor_Installation_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='CONNECT SOLAR PANELS')
                        Connect_Solar_Panel_Hours = Connect_Solar_Panel_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='BUILDING WORK')
                        Building_Work_Hours = Building_Work_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='POWERFLUSH')
                        PowerFlush_Hours = PowerFlush_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ELECTRICAL WORK ASP')
                        Electrical_Work_ASP_Hours = Electrical_Work_ASP_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ASBESTOS REMOVAL')
                        Asbestos_Removal_Hours = Asbestos_Removal_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ASBESTOS REMOVAL FIXED RATE')
                        Asbestos_Removal_Fixed_Rate_Hours = Asbestos_Removal_Fixed_Rate_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='SOLAR')
                        Solar_Hours = Solar_Hours - jobElementsToRemove[y].Units__c; 
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='PRE-ELECTRICAL SURVEY')
                        PreElectrical_Hours = PreElectrical_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ECOGEN MECHANICAL')
                        Ecogen_Mechanical_Hours = Ecogen_Mechanical_Hours - jobElementsToRemove[y].Units__c;  
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ECOGEN ELECTRICAL')
                        Ecogen_Electrical_Hours = Ecogen_Electrical_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='Remote Heating')
                        Remote_Heating_Hours = Remote_Heating_Hours - jobElementsToRemove[y].Units__c;   
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='ECO')
                        ECO_Hours = ECO_Hours - jobElementsToRemove[y].Units__c;  
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='Landlord Check')
                        Landlord_Check_Hours = Landlord_Check_Hours - jobElementsToRemove[y].Units__c;
                    else if(jobElementsToRemove[y].Skill__c.toUpperCase()=='UNVENTED HOT WATER') // PRB00029545
                        Unvented_Hot_Water_Hours = Unvented_Hot_Water_Hours - jobElementsToRemove[y].Units__c;
                }   
            }
        }  
      
        system.debug('associatedJob is:'+associatedJob);
        ///    
        //Update the Job record with the new skill hours counter values     
        ///
        if(associatedJob.Mechanical_Hours__c!=null && Mechanical_Hours!=0)
            associatedJob.Mechanical_Hours__c = associatedJob.Mechanical_Hours__c + Mechanical_Hours;
        else if(associatedJob.Mechanical_Hours__c==null && Mechanical_Hours!=0)
            associatedJob.Mechanical_Hours__c = Mechanical_Hours;
       
        if(associatedJob.Water_Heating_Fixing_Hours__c!=null && Water_Heating_Fixing_Hours!=0)
            associatedJob.Water_Heating_Fixing_Hours__c = associatedJob.Water_Heating_Fixing_Hours__c + Water_Heating_Fixing_Hours;
        else if(associatedJob.Water_Heating_Fixing_Hours__c==null && Water_Heating_Fixing_Hours!=0)
            associatedJob.Water_Heating_Fixing_Hours__c = Water_Heating_Fixing_Hours;
        
        if(associatedJob.Unvented_Hot_Water_Hours__c!=null && Unvented_Hot_Water_Hours!=0)
            associatedJob.Unvented_Hot_Water_Hours__c = associatedJob.Unvented_Hot_Water_Hours__c + Unvented_Hot_Water_Hours;
        else if(associatedJob.Unvented_Hot_Water_Hours__c==null && Unvented_Hot_Water_Hours!=0)
            associatedJob.Unvented_Hot_Water_Hours__c = Unvented_Hot_Water_Hours;
        
        if(associatedJob.Specialist_Building_Hours__c!=null && Specialist_Building_Hours!=0)
            associatedJob.Specialist_Building_Hours__c = associatedJob.Specialist_Building_Hours__c + Specialist_Building_Hours;
        else if(associatedJob.Specialist_Building_Hours__c==null && Specialist_Building_Hours!=0)
            associatedJob.Specialist_Building_Hours__c = Specialist_Building_Hours;
        
        if(associatedJob.Scaffolder_Hours__c!=null && Scaffolder_Hours!=0)
            associatedJob.Scaffolder_Hours__c = associatedJob.Scaffolder_Hours__c + Scaffolder_Hours;
        else if(associatedJob.Scaffolder_Hours__c==null && Scaffolder_Hours!=0)
            associatedJob.Scaffolder_Hours__c = Scaffolder_Hours;
        
        if(associatedJob.Roof_Work_Hours__c!=null && Roof_Work_Hours!=0)
            associatedJob.Roof_Work_Hours__c = associatedJob.Roof_Work_Hours__c + Roof_Work_Hours;
        else if(associatedJob.Roof_Work_Hours__c==null && Roof_Work_Hours!=0)
            associatedJob.Roof_Work_Hours__c = Roof_Work_Hours;
       
        if(associatedJob.Payment_Collection_Hours__c!=null && Payment_Collection_Hours!=0)
            associatedJob.Payment_Collection_Hours__c = associatedJob.Payment_Collection_Hours__c + Payment_Collection_Hours;
        else if(associatedJob.Payment_Collection_Hours__c==null && Payment_Collection_Hours!=0)
            associatedJob.Payment_Collection_Hours__c =  Payment_Collection_Hours;
        
        if(associatedJob.LPG_Installation_Hours__c!=null && LPG_Installation_Hours!=0)
            associatedJob.LPG_Installation_Hours__c = associatedJob.LPG_Installation_Hours__c + LPG_Installation_Hours;
        else if(associatedJob.LPG_Installation_Hours__c==null && LPG_Installation_Hours!=0)
            associatedJob.LPG_Installation_Hours__c = LPG_Installation_Hours;
            
        if(associatedJob.Fire_Wall_Heater_Fixing_Hours__c!=null && Fire_Wall_Heater_Fixing_Hours!=0)
            associatedJob.Fire_Wall_Heater_Fixing_Hours__c = associatedJob.Fire_Wall_Heater_Fixing_Hours__c + Fire_Wall_Heater_Fixing_Hours;
        else if(associatedJob.Fire_Wall_Heater_Fixing_Hours__c==null && Fire_Wall_Heater_Fixing_Hours!=0)
            associatedJob.Fire_Wall_Heater_Fixing_Hours__c = Fire_Wall_Heater_Fixing_Hours;
        
        if(associatedJob.Electrical_Hours__c!=null && Electrical_Hours!=0)
            associatedJob.Electrical_Hours__c = associatedJob.Electrical_Hours__c + Electrical_Hours;
        else if(associatedJob.Electrical_Hours__c==null && Electrical_Hours!=0)
            associatedJob.Electrical_Hours__c = Electrical_Hours;

        if(associatedJob.Contractor_Installation_Hours__c!=null && Contractor_Installation_Hours!=0)
            associatedJob.Contractor_Installation_Hours__c = associatedJob.Contractor_Installation_Hours__c + Contractor_Installation_Hours;
        else if(associatedJob.Contractor_Installation_Hours__c==null && Contractor_Installation_Hours!=0)
            associatedJob.Contractor_Installation_Hours__c = Contractor_Installation_Hours;
        
        if(associatedJob.Connect_Solar_Panel_Hours__c!=null && Connect_Solar_Panel_Hours!=0)
            associatedJob.Connect_Solar_Panel_Hours__c = associatedJob.Connect_Solar_Panel_Hours__c + Connect_Solar_Panel_Hours;
        else if(associatedJob.Connect_Solar_Panel_Hours__c==null && Connect_Solar_Panel_Hours!=0)
            associatedJob.Connect_Solar_Panel_Hours__c = Connect_Solar_Panel_Hours;
        
        if(associatedJob.Building_Work_Hours__c!=null && Building_Work_Hours!=0)
            associatedJob.Building_Work_Hours__c = associatedJob.Building_Work_Hours__c + Building_Work_Hours;
        else if(associatedJob.Building_Work_Hours__c==null && Building_Work_Hours!=0)
            associatedJob.Building_Work_Hours__c = Building_Work_Hours;
            
        if(associatedJob.PowerFlush_Hours__c!=null && PowerFlush_Hours!=0)
            associatedJob.PowerFlush_Hours__c = associatedJob.PowerFlush_Hours__c + PowerFlush_Hours;
        else if(associatedJob.PowerFlush_Hours__c==null && PowerFlush_Hours!=0)
            associatedJob.PowerFlush_Hours__c = PowerFlush_Hours;
        
        if(associatedJob.Electrical_Work_ASP_Hours__c!=null && Electrical_Work_ASP_Hours!=0)
            associatedJob.Electrical_Work_ASP_Hours__c = associatedJob.Electrical_Work_ASP_Hours__c + Electrical_Work_ASP_Hours;
        else if(associatedJob.Electrical_Work_ASP_Hours__c==null && Electrical_Work_ASP_Hours!=0)
            associatedJob.Electrical_Work_ASP_Hours__c = Electrical_Work_ASP_Hours;
        
        if(associatedJob.Asbestos_Removal_Hours__c!=null && Asbestos_Removal_Hours!=0)
            associatedJob.Asbestos_Removal_Hours__c = associatedJob.Asbestos_Removal_Hours__c + Asbestos_Removal_Hours;
        else if(associatedJob.Asbestos_Removal_Hours__c==null && Asbestos_Removal_Hours!=0)
            associatedJob.Asbestos_Removal_Hours__c = Asbestos_Removal_Hours;
        
        if(associatedJob.Asbestos_Removal_Fixed_Rate_Hours__c!=null && Asbestos_Removal_Fixed_Rate_Hours!=0)
            associatedJob.Asbestos_Removal_Fixed_Rate_Hours__c = associatedJob.Asbestos_Removal_Fixed_Rate_Hours__c + Asbestos_Removal_Fixed_Rate_Hours;
        else if(associatedJob.Asbestos_Removal_Fixed_Rate_Hours__c==null && Asbestos_Removal_Fixed_Rate_Hours!=0)
            associatedJob.Asbestos_Removal_Fixed_Rate_Hours__c = Asbestos_Removal_Fixed_Rate_Hours;

        if(associatedJob.Solar_Hours__c!=null && Solar_Hours!=0)
            associatedJob.Solar_Hours__c = associatedJob.Solar_Hours__c + Solar_Hours;     
        else if(associatedJob.Solar_Hours__c==null && Solar_Hours!=0)
            associatedJob.Solar_Hours__c = Solar_Hours;   
        
         if(associatedJob.Pre_Electrical_Hours__c!=null && PreElectrical_Hours!=0)
            associatedJob.Pre_Electrical_Hours__c = associatedJob.Pre_Electrical_Hours__c + PreElectrical_Hours;     
        else if(associatedJob.Pre_Electrical_Hours__c==null && PreElectrical_Hours!=0)
            associatedJob.Pre_Electrical_Hours__c = PreElectrical_Hours; 
            
         if(associatedJob.Ecogen_Mechanical_Hours__c!=null && Ecogen_Mechanical_Hours!=0)
            associatedJob.Ecogen_Mechanical_Hours__c = associatedJob.Ecogen_Mechanical_Hours__c + Ecogen_Mechanical_Hours;     
        else if(associatedJob.Ecogen_Mechanical_Hours__c==null && Ecogen_Mechanical_Hours!=0)
            associatedJob.Ecogen_Mechanical_Hours__c = Ecogen_Mechanical_Hours; 
            
        if(associatedJob.Ecogen_Electrical_Hours__c!=null && Ecogen_Electrical_Hours!=0)
            associatedJob.Ecogen_Electrical_Hours__c = associatedJob.Ecogen_Electrical_Hours__c + Ecogen_Electrical_Hours;     
        else if(associatedJob.Ecogen_Electrical_Hours__c==null && Ecogen_Electrical_Hours!=0)
            associatedJob.Ecogen_Electrical_Hours__c = Ecogen_Electrical_Hours;   
        
        if(associatedJob.Remote_Heating__c!=null && Remote_Heating_Hours!=0)
            associatedJob.Remote_Heating__c = associatedJob.Remote_Heating__c + Remote_Heating_Hours;     
        else if(associatedJob.Remote_Heating__c==null && Remote_Heating_Hours!=0)
            associatedJob.Remote_Heating__c = Remote_Heating_Hours;                    
        
        if(associatedJob.ECO_Hours__c!=null && ECO_Hours!=0)
            associatedJob.ECO_Hours__c = associatedJob.ECO_Hours__c + ECO_Hours;     
        else if(associatedJob.ECO_Hours__c==null && ECO_Hours!=0)
            associatedJob.ECO_Hours__c = ECO_Hours;          
        ///
        //set all the quote skill hours if required
        ///
        if(triggerQuote.skillTotalWaterHeatingFixing__c==null && Water_Heating_Fixing_Hours!=0)
            triggerQuote.skillTotalWaterHeatingFixing__c = Water_Heating_Fixing_Hours;
        else if(triggerQuote.skillTotalWaterHeatingFixing__c!=null && Water_Heating_Fixing_Hours!=0)
            triggerQuote.skillTotalWaterHeatingFixing__c = triggerQuote.skillTotalWaterHeatingFixing__c + Water_Heating_Fixing_Hours;
        
        if(triggerQuote.skillTotalUnventedHotWater__c==null && Unvented_Hot_Water_Hours!=0)
            triggerQuote.skillTotalUnventedHotWater__c = Unvented_Hot_Water_Hours;
        else if(triggerQuote.skillTotalUnventedHotWater__c!=null && Unvented_Hot_Water_Hours!=0)
            triggerQuote.skillTotalUnventedHotWater__c = triggerQuote.skillTotalUnventedHotWater__c + Unvented_Hot_Water_Hours;
        
        if(triggerQuote.skillTotalSpecialistBuilding__c==null && Specialist_Building_Hours!=0)
            triggerQuote.skillTotalSpecialistBuilding__c = Specialist_Building_Hours;
        else if(triggerQuote.skillTotalSpecialistBuilding__c!=null && Specialist_Building_Hours!=0)
            triggerQuote.skillTotalSpecialistBuilding__c = triggerQuote.skillTotalSpecialistBuilding__c + Specialist_Building_Hours;
        
        if(triggerQuote.skillTotalScaffolder__c==null && Scaffolder_Hours!=0)
            triggerQuote.skillTotalScaffolder__c = Scaffolder_Hours;
        else if(triggerQuote.skillTotalScaffolder__c!=null && Scaffolder_Hours!=0)
            triggerQuote.skillTotalScaffolder__c = triggerQuote.skillTotalScaffolder__c + Scaffolder_Hours;
        
        if(triggerQuote.skillTotalRoofWork__c==null && Roof_Work_Hours!=0)
            triggerQuote.skillTotalRoofWork__c = Roof_Work_Hours;
        else if(triggerQuote.skillTotalRoofWork__c!=null && Roof_Work_Hours!=0)
            triggerQuote.skillTotalRoofWork__c = triggerQuote.skillTotalRoofWork__c + Roof_Work_Hours;
        
        if(triggerQuote.skillTotalPaymentCollection__c==null && Payment_Collection_Hours!=0)
            triggerQuote.skillTotalPaymentCollection__c = Payment_Collection_Hours;
        else if(triggerQuote.skillTotalPaymentCollection__c!=null && Payment_Collection_Hours!=0)
            triggerQuote.skillTotalPaymentCollection__c = triggerQuote.skillTotalPaymentCollection__c + Payment_Collection_Hours;
        
        if(triggerQuote.skillTotalMechanical__c==null && Mechanical_Hours!=0)
            triggerQuote.skillTotalMechanical__c = Mechanical_Hours;
        else if(triggerQuote.skillTotalMechanical__c!=null && Mechanical_Hours!=0)
            triggerQuote.skillTotalMechanical__c = triggerQuote.skillTotalMechanical__c + Mechanical_Hours;
        
        if(triggerQuote.skillTotalLPGInstallation__c==null && LPG_Installation_Hours!=0)
            triggerQuote.skillTotalLPGInstallation__c = LPG_Installation_Hours;
        else if(triggerQuote.skillTotalLPGInstallation__c!=null && LPG_Installation_Hours!=0)
            triggerQuote.skillTotalLPGInstallation__c = triggerQuote.skillTotalLPGInstallation__c + LPG_Installation_Hours;
        
        if(triggerQuote.skillTotalFireWallHeaterFixing__c==null && Fire_Wall_Heater_Fixing_Hours!=0)
            triggerQuote.skillTotalFireWallHeaterFixing__c = Fire_Wall_Heater_Fixing_Hours; 
        else if(triggerQuote.skillTotalFireWallHeaterFixing__c!=null && Fire_Wall_Heater_Fixing_Hours!=0)
            triggerQuote.skillTotalFireWallHeaterFixing__c = triggerQuote.skillTotalFireWallHeaterFixing__c + Fire_Wall_Heater_Fixing_Hours; 
         
        if(triggerQuote.skillTotalElectrical__c==null && Electrical_Hours!=0)
            triggerQuote.skillTotalElectrical__c = Electrical_Hours;
        else if(triggerQuote.skillTotalElectrical__c!=null && Electrical_Hours!=0)
            triggerQuote.skillTotalElectrical__c = triggerQuote.skillTotalElectrical__c + Electrical_Hours;

        if(triggerQuote.skillTotalContractorInstallation__c==null && Contractor_Installation_Hours!=0)
            triggerQuote.skillTotalContractorInstallation__c = Contractor_Installation_Hours;
        else if(triggerQuote.skillTotalContractorInstallation__c!=null && Contractor_Installation_Hours!=0)
            triggerQuote.skillTotalContractorInstallation__c = triggerQuote.skillTotalContractorInstallation__c + Contractor_Installation_Hours;
                
        if(triggerQuote.skillTotalConnectSolarPanels__c==null && Connect_Solar_Panel_Hours!=0)
            triggerQuote.skillTotalConnectSolarPanels__c = Connect_Solar_Panel_Hours;
        else if(triggerQuote.skillTotalContractorInstallation__c!=null && Connect_Solar_Panel_Hours!=0)
            triggerQuote.skillTotalConnectSolarPanels__c = triggerQuote.skillTotalConnectSolarPanels__c + Connect_Solar_Panel_Hours;
                    
        if(triggerQuote.skillTotalBuildingWork__c==null && Building_Work_Hours!=0)
            triggerQuote.skillTotalBuildingWork__c = Building_Work_Hours;
        else if(triggerQuote.skillTotalBuildingWork__c!=null && Building_Work_Hours!=0)
            triggerQuote.skillTotalBuildingWork__c = triggerQuote.skillTotalBuildingWork__c + Building_Work_Hours;

        if(triggerQuote.skillTotalPowerFlush__c==null && PowerFlush_Hours!=0)
            triggerQuote.skillTotalPowerFlush__c = PowerFlush_Hours;        
        else if(triggerQuote.skillTotalPowerFlush__c!=null && PowerFlush_Hours!=0)
            triggerQuote.skillTotalPowerFlush__c = triggerQuote.skillTotalPowerFlush__c + PowerFlush_Hours;

        if(triggerQuote.SkillTotalElectricalWorkASP__c==null && Electrical_Work_ASP_Hours!=0)
            triggerQuote.SkillTotalElectricalWorkASP__c = Electrical_Work_ASP_Hours;
        else if(triggerQuote.SkillTotalElectricalWorkASP__c!=null && Electrical_Work_ASP_Hours!=0)
            triggerQuote.SkillTotalElectricalWorkASP__c = triggerQuote.SkillTotalElectricalWorkASP__c + Electrical_Work_ASP_Hours;

        if(triggerQuote.skillTotalAsbestosRemoval__c==null && Asbestos_Removal_Hours!=0)
            triggerQuote.skillTotalAsbestosRemoval__c = Asbestos_Removal_Hours;
        else if(triggerQuote.skillTotalAsbestosRemoval__c!=null && Asbestos_Removal_Hours!=0)
            triggerQuote.skillTotalAsbestosRemoval__c = triggerQuote.skillTotalAsbestosRemoval__c + Asbestos_Removal_Hours;

        if(triggerQuote.skillTotalAsbestosRemovalFixedRate__c==null && Asbestos_Removal_Fixed_Rate_Hours!=0)
            triggerQuote.skillTotalAsbestosRemovalFixedRate__c = Asbestos_Removal_Fixed_Rate_Hours;
        else if(triggerQuote.skillTotalAsbestosRemovalFixedRate__c!=null && Asbestos_Removal_Fixed_Rate_Hours!=0)
            triggerQuote.skillTotalAsbestosRemovalFixedRate__c = triggerQuote.skillTotalAsbestosRemovalFixedRate__c + Asbestos_Removal_Fixed_Rate_Hours;

        if(triggerQuote.skillTotalSolar__c==null && Solar_Hours!=0)
            triggerQuote.skillTotalSolar__c = Solar_Hours;
        else if(triggerQuote.skillTotalSolar__c!=null && Solar_Hours!=0)
            triggerQuote.skillTotalSolar__c = triggerQuote.skillTotalSolar__c + Solar_Hours;      
            
        if(triggerQuote.skillTotal_ecogenElectrical__c==null && Ecogen_Electrical_Hours!=0)
            triggerQuote.skillTotal_ecogenElectrical__c = Ecogen_Electrical_Hours;
        else if(triggerQuote.skillTotal_ecogenElectrical__c!=null && Ecogen_Electrical_Hours!=0)
            triggerQuote.skillTotal_ecogenElectrical__c = triggerQuote.skillTotal_ecogenElectrical__c + Ecogen_Electrical_Hours;  
            
        if(triggerQuote.skillTotal_ecogenMechanical__c==null && Ecogen_Mechanical_Hours!=0)
            triggerQuote.skillTotal_ecogenMechanical__c = Ecogen_Mechanical_Hours;
        else if(triggerQuote.skillTotal_ecogenMechanical__c!=null && Ecogen_Mechanical_Hours!=0)
            triggerQuote.skillTotal_ecogenMechanical__c = triggerQuote.skillTotal_ecogenMechanical__c + Ecogen_Mechanical_Hours;          
        
        if(triggerQuote.Remote_Heating__c==null && Remote_Heating_Hours!=0)
            triggerQuote.Remote_Heating__c = Remote_Heating_Hours;
        else if(triggerQuote.Remote_Heating__c!=null && Remote_Heating_Hours!=0)
            triggerQuote.Remote_Heating__c = triggerQuote.Remote_Heating__c + Remote_Heating_Hours;
            
        if(triggerQuote.skillTotalECO__c==null && ECO_Hours!=0)
            triggerQuote.skillTotalECO__c = ECO_Hours;
        else if(triggerQuote.skillTotalECO__c!=null && ECO_Hours!=0)
            triggerQuote.skillTotalECO__c = triggerQuote.skillTotalECO__c + ECO_Hours; 
            
        if(triggerQuote.Landlord_Check__c==null && Landlord_Check_Hours!=0)
              triggerQuote.Landlord_Check__c = Landlord_Check_Hours;
        else if(triggerQuote.Landlord_Check__c!=null && Landlord_Check_Hours!=0)
                triggerQuote.Landlord_Check__c = triggerQuote.Landlord_Check__c + Landlord_Check_Hours;
 
    }  
    
    public List<Job_Skill_History__c> setJobSkillHistory(Map<id,Job__c> oldJob, Map<id,Job__c> newJob){
        //Map<id,Job__c> oldJob = new Map<id,Job__c>();
        //Map<id,Job__c> newJob1 = new Map<id,Job__c>();
        List<Job_Skill_History__c> jsh = new List<Job_Skill_History__c>();
        /*for(Job__c j : oldJob){
            if(!oldJob.containsKey(j.id))
                oldJob.put(j.id,j);
        }
        for(Job__c j : newJob){
            if(!newJob1.containsKey(j.id))
                newJob1.put(j.id,j);
        }*/
        
        for(Job__c j : newJob.values()){
            if(j.Mechanical_Hours__c != oldJob.get(j.id).Mechanical_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Mechanical', After_Hours__c=j.Mechanical_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Mechanical_Hours__c));
            }
            
            if(j.Building_Work_Hours__c != oldJob.get(j.id).Building_Work_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Building Work', After_Hours__c=j.Building_Work_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Building_Work_Hours__c));
            }
            
            if(j.PowerFlush_Hours__c != oldJob.get(j.id).PowerFlush_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Powerflush', After_Hours__c=j.PowerFlush_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).PowerFlush_Hours__c));
            }
               
            if(j.Roof_Work_Hours__c != oldJob.get(j.id).Roof_Work_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Roof Work', After_Hours__c=j.Roof_Work_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Roof_Work_Hours__c));
            }
            
            if(j.Electrical_Hours__c != oldJob.get(j.id).Electrical_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Electrical', After_Hours__c=j.Electrical_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Electrical_Hours__c));
            }
            
            if(j.ECO_Hours__c != oldJob.get(j.id).ECO_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'ECO', After_Hours__c=j.ECO_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).ECO_Hours__c));
            }
            
            if(j.Balancing_Skill__c != oldJob.get(j.id).Balancing_Skill__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Balancing Mechanical', After_Hours__c=j.Balancing_Skill__c,
                                                Before_Hours__c=oldJob.get(j.id).Balancing_Skill__c));
            }
            
            if(j.Specialist_Building_Hours__c != oldJob.get(j.id).Specialist_Building_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Specialist Building', After_Hours__c=j.Specialist_Building_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Specialist_Building_Hours__c));
            }
            
            if(j.Scaffolder_Hours__c != oldJob.get(j.id).Scaffolder_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Scaffolder', After_Hours__c=j.Scaffolder_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Scaffolder_Hours__c));
            }
            
            if(j.Connect_Solar_Panel_Hours__c != oldJob.get(j.id).Connect_Solar_Panel_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'INSTALL SOLAR PANELS', After_Hours__c=j.Connect_Solar_Panel_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Connect_Solar_Panel_Hours__c));
            }
            
            if(j.Unvented_Hot_Water_Hours__c != oldJob.get(j.id).Unvented_Hot_Water_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Unvented Hot Water', After_Hours__c=j.Unvented_Hot_Water_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Unvented_Hot_Water_Hours__c));
            }
            
            if(j.Contractor_Installation_Hours__c != oldJob.get(j.id).Contractor_Installation_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Contractor Installation', After_Hours__c=j.Contractor_Installation_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Contractor_Installation_Hours__c));
            }
            
            if(j.Water_Heating_Fixing_Hours__c != oldJob.get(j.id).Water_Heating_Fixing_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Water Heater Fixing', After_Hours__c=j.Water_Heating_Fixing_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Water_Heating_Fixing_Hours__c));
            }
            
            if(j.Fire_Wall_Heater_Fixing_Hours__c != oldJob.get(j.id).Fire_Wall_Heater_Fixing_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'FIRE/WALL HEATER FIXING', After_Hours__c=j.Fire_Wall_Heater_Fixing_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Fire_Wall_Heater_Fixing_Hours__c));
            }
            
            if(j.Electrical_Work_ASP_Hours__c != oldJob.get(j.id).Electrical_Work_ASP_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Electrical Work ASP', After_Hours__c=j.Electrical_Work_ASP_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Electrical_Work_ASP_Hours__c));
            }
            
            if(j.LPG_Installation_Hours__c != oldJob.get(j.id).LPG_Installation_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'LPG Installation', After_Hours__c=j.LPG_Installation_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).LPG_Installation_Hours__c));
            }
            
            if(j.Asbestos_Removal_Hours__c != oldJob.get(j.id).Asbestos_Removal_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Asbestos Removal', After_Hours__c=j.Asbestos_Removal_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Asbestos_Removal_Hours__c));
            }
            
            if(j.Payment_Collection_Hours__c != oldJob.get(j.id).Payment_Collection_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Payment Collection', After_Hours__c=j.Payment_Collection_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Payment_Collection_Hours__c));
            }
            
            if(j.Asbestos_Removal_Fixed_Rate_Hours__c != oldJob.get(j.id).Asbestos_Removal_Fixed_Rate_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Asbestos Removal', After_Hours__c=j.Asbestos_Removal_Fixed_Rate_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Asbestos_Removal_Fixed_Rate_Hours__c));
            }
            
            if(j.Ecogen_Mechanical_Hours__c != oldJob.get(j.id).Ecogen_Mechanical_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Ecogen Mechanical', After_Hours__c=j.Ecogen_Mechanical_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Ecogen_Mechanical_Hours__c));
            }
            
            if(j.Ecogen_Electrical_Hours__c != oldJob.get(j.id).Ecogen_Electrical_Hours__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Ecogen Electrical', After_Hours__c=j.Ecogen_Electrical_Hours__c,
                                                Before_Hours__c=oldJob.get(j.id).Ecogen_Electrical_Hours__c));
            }
            
            if(j.Remote_Heating__c != oldJob.get(j.id).Remote_Heating__c){
                jsh.add(new Job_Skill_History__c(Job__c = j.id, Skill__c = 'Remote Heating', After_Hours__c=j.Remote_Heating__c,
                                                Before_Hours__c=oldJob.get(j.id).Remote_Heating__c));
            }
        }
        return jsh;
    }    
}